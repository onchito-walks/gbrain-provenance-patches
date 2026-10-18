# Patching and building next time

The goal of this document is that the next upstream upgrade is an afternoon, not
a week. Everything here is deliberately mechanical.

## The loop

```
reconcile -> integrate -> build -> accept -> certify -> deploy
```

### 1. Reconcile

Inventory every local behaviour against the new upstream release and classify it:

| Class | Meaning | Action |
|---|---|---|
| **RETAIN** | upstream does not provide the guarantee | carry the patch, adapted |
| **UPSTREAM-EQUIVALENT** | upstream now provides it | **delete the patch** |
| **CONFIG-REPLACED** | a config value covers it | delete the patch, set config |

Do this by reading upstream's **actual execution seams**, not by searching for
filenames. A same-named file proves nothing; a same-named function that no longer
implements the policy proves the opposite. Missing text is a discovery hint, not
proof of absence.

### 2. Integrate

Carry the *guarantee*, not the old file layout. If upstream reorganised, adapt
the patch to the new structure. If upstream already supplies the policy and only
the local code has the extra refusal, carry the extra refusal only — do not
duplicate upstream's machinery.

For each retained behaviour, the acceptance test must assert the **failure it
prevents**, and ideally assert that the refusal has no side effect.

### 3. Build

**Toolchain:** upstream `>= v0.60.178.0` declares `engines.bun >= 1.4.0` and calls
`process.threadCpuUsage`. An older Bun fails to build. Install a Bun `>= 1.4.0`
and make sure the build account can execute it — the fence matters when the brain
data filesystem is owned by a different account than the builder.

```bash
bun --version          # must be >= 1.4.0
bun install
bun run build
```

**Do not run heavy builds inside a small, memory-capped worker.** A build in a
4 GiB-capped process dies with an OOM that looks like a test failure. Run builds
and full test matrices in their own bounded unit (a transient systemd unit, a
container with an explicit memory limit, or simply a shell with the ceiling you
intend) so an OOM is attributable instead of mysterious.

### 4. Accept

Run the **declared** suites for the changed surface — not the whole corpus.

- Prefer a **delta** plan: derive which declared tests cover the changed files and
  run those. Reuse a prior green **only** if the fingerprint of that file is
  unchanged; if a file is currently failing, it must run, never be reused.
- Keep an explicit `planned / executed / passed` accounting line. A phase that
  planned zero suites has not passed — it has failed to plan.
- Capture the producer's exit code **before** executing anything. A shell process
  substitution hides the failure of the command inside it and will happily approve
  an empty suite inventory.
- Keep one deadline and one file budget across all phases.

### 5. Prove the gate can fail

Before trusting any acceptance gate, break something on purpose in a disposable
environment and confirm the gate goes red. A gate that cannot fail is worse than
no gate: it converts "we did not check" into "we checked and it is fine".

This is not optional and it is cheap. Three induced regressions in throwaway
sandboxes took minutes and caught two real defects in the gate itself.

### 6. Certify and deploy

Freeze the revision, record the artifact hash, verify preservation and
provenance deltas, then deploy through a single release pointer under whatever
lock protects it. Keep the previous release directory until the recovery window
closes — a pre-migration database cannot be recreated from a post-migration one.

## Making the plan data

Put the pinned candidate, its acceptance suites, the live behaviour probes and
the behaviour inventory in **one JSON registry**, and have the automation read it.
A newer upstream release must **not** silently restart work on a pinned
candidate; changing the pin is an explicit edit.

That single decision is what turns the next upgrade from re-deriving doctrine
into editing a file.

## Applying this patch series

```bash
tools/apply-overlay.sh <path-to-gbrain-clone> <path-to-patches>
tools/verify-overlay.sh <path-to-gbrain-clone>
```

`apply-overlay.sh` checks out the base release and applies the series with
`git am`, failing loudly on the first conflict rather than leaving a half-applied
tree. `verify-overlay.sh` runs the declared acceptance suites and prints the
planned/executed/passed accounting.
