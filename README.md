# gbrain-guardrails

Guardrails for [GBrain](https://github.com/garrytan/gbrain): the house rules our
production brain needs, stapled onto the official release as a patch.

**We hope to delete this repository.** Every rule here is something upstream
should do itself, and when it does, our copy goes away — two already have. The
correct end state is an empty patch: upstream GBrain plus configuration.

## Why guardrails, in plain terms

GBrain is the clerk who keeps everything we know — years of notes, decisions,
records, the lot. The clerk is good. But it was built for everyone, and the way
it was built, when something goes wrong inside a drawer it can still finish the
job and report *done*.

For a demo, that is fine. For the only copy of everything, it is not. A system
that quietly says "done" when it isn't is worse than one that stops and shouts,
because you stop checking — and the moment you stop checking is the moment you
find out years later that a drawer has been empty since March.

So we wrote house rules for our clerk:

- **If a drawer is jammed, stop and tell me.** Never report a success you did not
  achieve. A page that could not be read is not a page that passed.
- **One heavy job at a time.** Never start tonight's rebuild while last night's
  is still running, and never let a killed job leave the lock held so tomorrow's
  fire silently skips.
- **Never destroy the only copy.** Keep the previous version until the new one
  has proved itself, then keep the restore point until the recovery window
  closes — because you cannot rebuild yesterday's database from today's.
- **Prove it before you trust it.** "Installed" is not a claim about a file on
  disk; it means the running process is executing the new bytes and the new bytes
  passed their own checks in the place they actually run.
- **A check that cannot fail is worse than no check.** Before we trust a gate, we
  break something on purpose and confirm the gate notices.

The clerk cannot be retrained. Upstream ships a new clerk every few weeks and we
do not control that release, so the house rules are applied as edits on top of
whatever official version we install. That stack of edits is this repository.

That is also why it is a patch and not a fork: a fork drifts away from upstream
and leaves us maintaining a whole clerk. A patch is small, reviewable, and
deleted the moment it stops being needed.

Concretely, **today GBrain can lose data, or claim a success it did not achieve,
in ways that matter to us and do not yet matter to upstream.** Each rule is
written up in [`docs/WHY-THIS-EXISTS.md`](docs/WHY-THIS-EXISTS.md) as *the failure
it prevents*, so the retirement test for every single one is obvious.

## What is in here

```
patches/     the overlay as a single squashed patch against upstream v0.60.178.0
docs/        why it exists, how to patch next time, what was and was not verified
tools/       apply / build / verify / clean-check scripts
```

The patch applies in one step with `git am` onto the official release tag and
reproduces the published tree exactly (verified: the tree hash after applying
matches the tree the patch was generated from). The overlay's own commit history
is published separately as [`docs/HISTORY.md`](docs/HISTORY.md) — it contains
merges, so a linear per-commit series cannot reproduce the tree, which is why the
patch itself is squashed.

## Quick start

```bash
# 1. Clone upstream at the exact base release
git clone https://github.com/garrytan/gbrain.git
cd gbrain
git checkout v0.60.178.0

# 2. Apply the overlay
git am /path/to/gbrain-guardrails/patches/*.patch

# 3. Install the toolchain the overlay needs (upstream >= v0.60.178.0 requires it)
#    Bun >= 1.4.0 — see docs/PATCHING.md

# 4. Build and verify
bun install
bun run build
bun test <the suites named in docs/PATCHING.md>
```

`tools/apply-overlay.sh` does steps 1–2, `tools/verify-overlay.sh` does step 4
with the declared acceptance suites.

## The behaviours

The overlay carries 27 behaviour rows: 24 RETAIN, 2 that were already
upstream-equivalent and were retired locally, and 1 replaced by configuration.
They cluster into write-path admission, retrieval policy, quarantine integrity,
honest failure reporting, provider/queue behaviour, and tooling. Each is
described in [`docs/WHY-THIS-EXISTS.md`](docs/WHY-THIS-EXISTS.md) with the
failure it prevents.

Two of them (honest reporting of unreadable/skipped drift roots, and Git
work-tree prefix matching) are now provided upstream and were dropped from the
overlay — which is the intended direction of travel.

## Design rules this overlay follows

1. **Carry the guarantee, not the layout.** When upstream renames or reorganises
   files, the patch is adapted to the new structure. Reinstating old layout just
   to keep a diff applying is not acceptable.
2. **A patch is retired the moment upstream provides the same guarantee.** The
   classification is RETAIN / UPSTREAM-EQUIVALENT / CONFIG-REPLACED, decided by
   reading upstream's actual execution seams — not by looking for a filename.
3. **The plan is data, not doctrine.** The pinned candidate, acceptance suites,
   live behaviour probes and the behaviour inventory live in one JSON registry,
   so the next upgrade edits a file and reruns a pipeline.
4. **A gate that cannot fail is worse than no gate.** The acceptance layer proves
   its own teeth by inducing regressions in disposable environments before it is
   trusted.

## Licence

The patches are derivative of GBrain and carry upstream's MIT licence. See
[`LICENSE`](LICENSE).

## Provenance and scrubbing

This repository is a **scrubbed** derivative of a private production overlay. Every
machine-specific path, host name, private network address, account name, task
identifier and internal repository name has been replaced with a placeholder. The
resulting patch is functionally the same overlay, but it is **not byte-identical**
to the certified artifact it came from, and it has **not** been re-certified in
its scrubbed form.

`tools/check-clean.sh` is the scanner used before publication; it passes on this
tree. Run it after any change.

## Status

Base release: `v0.60.178.0`. Overlay: 93 commits (plus two merges), 192 files
changed by the overlay itself, ~20.4k insertions. Certified and deployed in
production before publication; the honest limits of that verification are
recorded in [`docs/VERIFICATION.md`](docs/VERIFICATION.md) — including what was
*not* proven.
