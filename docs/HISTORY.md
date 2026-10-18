# Overlay commit history

The overlay is 93 commits (plus two merge commits) on top of upstream `v0.60.178.0`.
This is the readable record of what changed and why. The published patch in
`patches/` is a single squashed diff: the history contains merges, so a linear
per-commit series cannot reproduce the tree.

```text

  1  docs(upgrade): inventory deployed overlay against official v0.60.178
  2  docs(upgrade): preserve official negative-discovery command receipts
  3  port(drift): coverage-honesty + identity parity overlay onto official v0.60.178.0
  4  fix(drift): close budget and DB-down coverage gaps on official overlay
  5  fix(guards): parse marketplace refs independently of colon filenames
  6  docs(upgrade): record Stage 2 drift acceptance and installation boundary
  7  fix(ai): retain GO session identity on unified auth path (B06)
  8  fix(autopilot): isolate global maintenance queue (B14)
  9  fix(search): exclude quarantined exact identities (B07)
 10  fix(search): isolate quarantine recovery cache posture (B08)
 11  fix(mentions): exclude quarantined names and aliases (B16)
 12  fix(mentions): reconcile quarantined origins in rebuild (B17)
 13  fix(upgrade): reconcile fixture typing and scoped size accounting
 14  docs(upgrade): record partial Stage 3 behavior acceptance
 15  feat(pages): B01 canonical put_page type admission (Stage 3A)
 16  docs(upgrade): record Stage 3A B01 commit and B02 remainder
 17  fix(guards): restore the size ratchets and typecheck after B01
 18  feat(pages): B02 sync.exclude admission guard on put_page, dry run included
 19  docs(upgrade): record Stage 3A B02 commit, ratchet repair and env caveats
 20  docs(upgrade): record Stage 3A fast-forward integration onto staging
 21  fix(serial-runner): B24 exact unsharded scheduler permutation, fail-closed shards
 22  feat(quarantine): operator quarantine-set/rollback lane with exact-row guards (B15)
 23  tools(codegraph): local-only disposable-brain codegraph probe + regression (B25)
 24  test(persistence): scoped RSS observer and intact serial persistence workloads (B26)
 25  docs(upgrade): record Stage 3D B15/B24/B25/B26 commits and verification
 26  docs(upgrade): record Stage 3D fast-forward integration and parent re-verification
 27  fix(extract_atoms): B11 refuse an unpriced chat/embed route under the default cap too
 28  feat(extract_atoms): B12 quarantine filter in discovery/backlog + fail-closed execution-boundary re-check
 29  docs(upgrade): Stage 3C extraction checkpoint — B11/B12 committed, B13 open
 30  feat(extract_atoms): B13 a refused drain batch is a visible retryable stop, not a false-green
 31  docs(upgrade): Stage 3C acceptance receipt — B11/B12/B13 committed, integration owed to parent
 32  docs(upgrade): record Stage 3C cherry-pick integration, fenced-toolchain verification, inventory reconciliation
 33  feat(search): B03 expose slug-prefix exclusion on the public search/query ops
 34  feat(search): B04 default covered-atom retrieval policy with opt-out and cache identity
 35  feat(search): B05 verified legacy source-root alias for frozen atom bindings
 36  feat(atoms): B09 read-time atom provenance quote status (search + doctor)
 37  fix(provenance): B10 respect quarantine visibility in source evidence
 38  docs(upgrade): Stage 3B receipt — B03/B04/B05/B09/B10 committed, B27 preserved and remaining
 39  docs(upgrade): Stage 3B receipt correction — staging advanced independently, ff-only refused, integration owed to <task>
 40  feat(search): B27 read-time atom_disposition enrichment from companion assessments
 41  docs(upgrade): Stage 3B receipt — B27 committed, cohort complete (6/6), integration range 0eb6d6b37..62ac5fd6d owed to <task>
 42  fix(guards): register the B27 serial file in the serial manifest
 43  docs(upgrade): record Stage 3B integration, serial-manifest repair, Stage 3 closing position
 44  test(search): reconcile the CLI atom-recovery slow test with the B04 default
 45  docs(upgrade): record Stage 3 final acceptance at the integrated SHA
 46  fix(agent-contract): quarantine refusal wording and placeholder-free managed-brain suggestion
 47  docs(key-files): split tooling-and-tests.md below the 60 KB reference-doc cap
 48  chore(generated): regenerate the operation manifest for B03/B04 retrieval params
 49  fix(doctor): do not emit multi_source_drift when the DB phase has no engine
 50  test(doctor): reconcile the B22 coverage case with the pinned upstream doctor surface
 51  fix(migrations): preserve legacy link evidence in additive backfills
 52  fix(migrations): fail closed when a rehearsal writer target escapes its allowlist
 53  test(rehearsal): pin isolation enforcement and v0.32.2 facts pairing
 54  fix(migrations): make the v0.12.0 timeline backfill additive, like links
 55  fix(migrations): close the v0.32.2 facts-pairing drift losslessly
 56  fix(migrations): accept the three pre-existing v0.32.2 verify drifts by name
 57  fix(acceptance): reconcile the repair lane's repository-guard failures
 58  test(migrations): reconcile additive facts backfill expectations
 59  fix(acceptance): restore extract ceiling with unchanged inference peel
 60  fix(admission): normalize scoped generated types before strict vocabulary admission
 61  fix(cli): preserve remote transport recovery instead of PostgreSQL classification
 62  fix(acceptance): compact retained schemas and restore reviewed writer inventories
 63  fix(search): correlate covered atoms by page identity and retain HNSW plans
 64  test(acceptance): reconcile scoped contract and reviewed overlay diagnostics
 65  test(sql): pin existing snapshot config reads and preserve link-write invariants
 66  fix(schema): accept the existing snapshot reader return contract
 67  fix(build): retain both compile autoload protections and exact caller controls
 68  fix(admission): share one request-scoped pack resolve without changing strict read semantics
 69  fix(admission): refuse an out-of-scope generated write before normalizing it
 70  test(sql): reconcile per-key read goldens and review ledger
 71  Calibrate measured persistence admission and tighten aggregate budget
 72  Repair certification sandbox dependencies and restore admission and routing contracts
 73  Restore B03 slug-prefix exclusion surface and regenerate the pinned CLI goldens
 74  Recapture the two Postgres doctor goldens (stale since B09/drift-overlay)
 75  Isolate certification producers and retain unproven scratch scopes
 76  Refresh two stale tool-catalog descriptions from canonical manifest
 77  test-producer: subreaper kernel completion, registered consumer leases, guarded retired-scope recovery
 78  cert: close schema budgets and preservation-safe structural regressions
 79  fix: keep serial timing monotonic and isolate pool sandboxes; align query prose and native generated artifacts
 80  fix: preserve search-query routing phrases within schema budgets; refresh CLI goldens
 81  fix: keep search match description nonempty within unchanged schema budgets
 82  repair: add literal-original-preserving derived fence planner and refusal controls
 83  repair: publish the preserved fence document through the existing owner/journal path
 84  repair: phase B adoption publishes the derived document instead of rewriting originals
 85  repair: phase C verifies original and derived coordinates independently
 86  repair: derived publication is a true no-op when current; phase C scope refined; migration tests moved to the strict contract
 87  repair: reconcile exempts a bound row unless the fence pairs it exactly; migration-level control
 88  repair: every superseded-contract test moved to the strict contract; the whole affected surface is green
 89  preserved-fence store: satisfy the jsonb-binding and core-guard write-path guards
 90  preserved-fence: retain exact PostgreSQL bigint fact identities
 91  v0.32.2 verify: index a current derived binding to its existing fence
 92  run lifecycle repair: complete a cycle atomically with its derived publications
 93  test: retire stale unfenced-facts writer exemption after preservation migration
```

