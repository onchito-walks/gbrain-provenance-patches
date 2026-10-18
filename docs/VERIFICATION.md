# Verification record — and its limits

The overlay was certified and deployed in production before publication. This
document records what was actually proven, and — more importantly — what was
**not**. Read the second section before trusting the first.

## Certified identity

| Item | Value |
|---|---|
| Base official release | `v0.60.178.0` |
| Certified overlay commit | the head of this patch series |
| Native schema | 239 (migrated from 165) |
| Engine | PostgreSQL |

## What was proven

**Runtime identity.** Every brain process was confirmed to be executing the
installed release, using `/proc` and the service manager as primary evidence —
not the deployment tool's own report. The application process is a child of a
lock wrapper, so its real PID had to be enumerated from the cgroup rather than
assumed from the unit's main PID.

**Behaviour, not liveness.** Two independent doctor paths were run and compared:
a CLI doctor (173 checks) and an authenticated MCP doctor (61 checks). Zero status
disagreements. A drift-completeness check reported 4570 candidates with
`verification_complete=true` and no coverage issues.

**The behaviour gate can fail.** Three independent regressions were injected in
disposable sandboxes — a truncated drift verdict, an unregistered federated
source, and a silent binary swap — plus a crashing probe. The gate went red every
time; a healthy control stayed green.

**No duplicate work.** Four real scheduled runs recorded only receipt and
behaviour events. Artifact trees showed zero changes, no rebuild, and no redeploy.
Absence of per-run work directories was the positive evidence.

**Preservation.** All eight tracked tables showed zero lost ids and zero lost
keys. Migration and recovery evidence was captured across six raw phases with an
exact eight-table recovery comparison.

**Failure visibility.** Failure delivery was proven end-to-end at the real
delivery-helper boundary with actual provider acknowledgements, not a fake sender.

## What was NOT proven — read this

The certification is **"certified with named exceptions"**, deliberately not
"all green". These limits were known, recorded, and not papered over:

- **Three inherited IPC/socket test failures** remain red. They are accepted, not
  repaired. 240 explicit non-pass entries exist in the acceptance record.
- **Raw acceptance status is failure.** The matrix's raw `failed` flag stayed
  true, and retention reported false for two retained failed producer roots. Those
  are the authorized inherited non-passes.
- **Migration preservation flags stay literal.** The raw flags
  `original_rows_preserved=false`, `provenance_preserved=false` and
  `verdict=incomplete` were left exactly as observed. A separate attribution model
  showed zero unattributed changes — that does **not** turn the raw booleans true,
  and no blanket "no data changed" claim is made.
- **Schema activation is pending.** Shared-skill host activation was deliberately
  left PENDING / not activated.
- **Overall doctor status is warnings, not clean.** A passing health score was
  never treated as evidence of correctness.
- **One sub-item was never attempted:** independent product-database execution of
  the source-alias / covered-atom / type / exclusion behaviours. An empty live
  quarantine made the quarantine probes explicit *named skips* rather than passes
  — a skip is not a pass.
- **Interruption/resume is proven only for the post-deployment checkpoint**, not
  for interruption during a build or a migration.
- **The MCP posture assertions** are proven by an in-process HTTP MCP stand-in in
  the fixtures plus the live authenticated MCP doctor path — not by an
  authenticated MCP call inside the isolated test brain, which has no MCP
  authorization.

## Verification method

The verification was performed by a separate effort from the implementation, with
the explicit goal of **falsifying** the claims rather than confirming them. It
re-derived every claim from primary evidence — files, process tables, the service
manager, live probes, disposable databases — and treated any statement of the form
"the summary says X" as a failed verification.

No build, test matrix, migration rehearsal, deployment, service restart or
scheduled fire was repeated merely to re-state a status. Existing evidence was
reused where its fingerprints were still valid, and every reused check is
annotated with what changed, what failed, what expired, or what was never
verified in the first place.

## Applying this to your own deployment

Do not inherit this verification. It certifies *this* artifact in *this*
environment. Re-run the acceptance suites, prove your gate can fail, and check
preservation against *your* data before deploying.
