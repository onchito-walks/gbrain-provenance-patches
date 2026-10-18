# Independent verification of the scrubbed source

## Scope and frozen identities

Official base: `v0.60.178.0`, `0460af288227a193c2031eca2e6a64f808cbd8bd`.
Public package input: `b3d184cc0fc56e270fd3c8a241164e60ea60b2bc`.
The existing public patch was applied in an independent source sandbox, not the shared package checkout.
Bun 1.4.3 was fenced locally; no global toolchain was changed.

## Observed results

- Public patch applies and `bun run build` succeeds.
- Declared acceptance: `bun test --timeout 180000 test/multi-source-drift.test.ts` and
  `bun test --timeout 180000 test/multi-source-drift-coverage.test.ts`: **46 pass, zero fail**.
- Candidate fix revision `df4e5d52b0a87cc64e1665f1089a37184ba8e0dd`: **331 pass, zero fail** across
  25 individually executed regression files; `bun run typecheck` exits zero.
- Additional serial/preservation runs: **51 pass, zero fail, one skip**. The compiled drift suite skipped
  its sole test; it must NOT be described as verified compiled behaviour.
- Official next candidate `v0.60.179.0`, `1f26200e304910cadc61fe1d1786a67ea5d87ea4`:
  candidate fix revision `9f7109bca193352cec21aaba8100498b0d431b57`, **231 pass, zero fail** across 20 files.
  Build succeeds. The existing public patch had one generated CLI registry conflict; regeneration with
  `bun run build:flag-registry` resolved it. No atom-lifecycle source conflict.

These are selected-surface tests, not a whole-corpus certification. Initial managed-fixture failures
were caused by the temporary directory being nested in an operator metadata path. Those suites passed
when rerun with a separate temporary root; the failed attempts remain recorded locally.

## Atom defect and candidate repair

Upstream [issue #7013](https://github.com/garrytan/gbrain/issues/7013) and
[PR #7017](https://github.com/garrytan/gbrain/pull/7017) describe zero-yield re-extraction retiring the
previous generation. The defect was reproduced against pristine official v0.60.178.0 and against the
scrubbed patched source through real extraction/persistence modules, with mocked model responses.

The candidate repair is additive: a zero-yield batch admits no retirement, and a retirement refuses
until its replacement atom requests committed. A completed scan without a replacement atom is not
sufficient evidence for stale-atom repair. A regression adapted from upstream H-1 reproduces the
failure before repair and passes after it; historical records are not purged to make assertions pass.
The newer upstream partial-input-length feature is not claimed as backported.

## Artifacts

SHA-256 of compiled source artifacts:

- Public patch before repair, base 178: `caef854c13836c5e60e83b4e8177e038cf25beef54e422c4188de75bb9ba3d8a`.
- Candidate lifecycle repair, base 178: `fc2afabd50f3bcfa14194156cdafbadce86d2a0da1403da14e0a07bfd843cf06`.
- Candidate lifecycle repair, base 179: `09c906a0baf2e09630e76f71f8f0d2a22de72ddad3fb486bef7e6fb53b7a0215`.

## Pending gates

Isolated PostgreSQL reproduction/acceptance, read-only production impact investigation, and gated
production deployment/caller verification are in progress. None is claimed complete here.
No private database contents, connection strings, infrastructure identifiers or operator paths belong
in this public record. Production investigation is not permission to erase or rewrite historical atoms.
