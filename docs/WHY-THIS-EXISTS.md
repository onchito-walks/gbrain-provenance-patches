# Why this overlay exists

GBrain upstream is a capable general-purpose brain. This overlay exists because
a production deployment needed guarantees upstream does not yet supply. Each
behaviour below is written as *the failure it prevents* — that is the test for
whether it is still needed, and the test for whether upstream has absorbed it.

**Retirement rule:** the moment upstream provides the same guarantee at the same
seam, the patch is deleted. Two behaviours have already retired this way.

---

## 1. Write-path admission and exclusion

**B01 — Canonical type admission for `put_page`.**
Upstream only emits a type *warning* when content arrives with an alias or an
undeclared type, and then persists it. The overlay loads the active vocabulary
before publication: aliases normalise, and an undeclared explicit type is
refused *before* anything is written.
*Prevents:* new aliases and undeclared types being persisted verbatim, silently
fragmenting a typed brain.

**B02 — `sync.exclude` guard on `put_page`, including dry run.**
Upstream applies exclusions during discovery and purge, but not at the
pre-admission seam. The overlay checks the lowercased slug against the same
comma/newline and trailing-slash glob semantics.
*Prevents:* direct page writes bypassing indexing exclusions.
*Boundary:* a config-read failure still fails open, logged, as it does today.

**B03 — Public slug-prefix exclusion plumbing.**
Upstream's engine `SearchOpts` already supports `exclude_slug_prefixes`; the
public search/query operation definitions never expose it. The overlay carries
the validation and the keyword/hybrid/image/CRAG forwarding — not a duplicate
engine.
*Prevents:* caller exclusions being lost at operation or hybrid-rebuild seams.

## 2. Retrieval policy

**B04 — Default covered-atom retrieval policy, opt-out and cache-key bit.**
Carries `include_covered_atoms` through to the SQL leg, with a same-source live
non-atom coverage check and a cache-key bit.
*Prevents:* redundant source-covered atoms crowding out uncovered unique atoms.
*Note for porters:* the local SQL follows atom **outgoing** links to non-atom
sources. Early comments claiming the opposite direction are wrong — do not
reverse the edge when porting.

**B05 — Verified legacy source-root alias resolution for frozen atom bindings.**
One code-reviewed, prefix-only allowlist shared by the covered-atom SQL and the
provenance classifier. Exact slug first, then a de-prefix inside the same source.
*Prevents:* frozen old source-slug prefixes falsely reading as source-gone or
uncovered.
*Boundary:* this is not generic alias functionality, and it never mutates frozen
fields or infers aliases by basename.

**B27 — Historical companion assessment enrichment.**
Makes validated historical repair work visible on search and direct page reads
through an `atom_disposition` view, including cache-hit behaviour.
*Prevents:* repair work being invisible — while never rewriting original atoms or
frozen provenance.

## 3. Quarantine (hidden-content) integrity

The largest cluster. "Quarantine" hides content that must not surface; the
failure mode is a hidden row leaking through some path nobody checked.

**B07 — Quarantine exclusion in structural exact-slug lookup.**
Upstream's structural exact lookup reads the page and pushes it with no
quarantine check. The overlay filters by default, with a narrowly scoped internal
opt-in, while preserving upstream's remote-safe body handling.
*Prevents:* exact-identity injection leaking hidden pages.
*Important distinction:* direct recovery reads are intentional and separate from
search. Do not "fix" the recovery read — see B15.

**B08 — Quarantine posture in the search `knobsHash`.**
Carries a quarantine bit into the hash, adapted to upstream's current hash
version rather than resetting it.
*Prevents:* cross-posture search-key collisions.
*Not claimed:* cache reuse. Semantic response reuse is disabled upstream; this is
storage-key identity discipline only.

**B10 — Quarantine-aware source evidence and provenance population.**
Applies visibility to *all three* lookup populations and to quote resolution —
not only the top-level count.
*Prevents:* hidden pages and atoms serving as live evidence or polluting
provenance counts.

**B12 — Atom candidate quarantine exclusion + execution-boundary recheck.**
Filters quarantined candidates at discovery *and* re-checks at the execution
boundary, failing closed if the recheck cannot be performed.
*Prevents:* quarantined content reaching inference after discovery, or on a DB
recheck failure.

**B15 — Operator quarantine-set lane with exact-row guards.**
A guarded operator lane for setting quarantine state, with exact-row guards and
reversible, projection-safe metadata writes.
*Prevents:* a wrong-root quarantine that cannot be undone without content or
version loss, or that permanently breaks projections.
*Preserved deliberately:* direct local recovery reads (a local operator CLI
reading a quarantined page) remain available and are documented behaviour, not a
leak.

**B16 / B17 — Quarantined entities out of the mention gazetteer, and derived
edges swept on rebuild.**
*Prevents:* hidden entities being regenerated as mention targets, and
pre-existing derived mention links surviving their origin's quarantine forever.

## 4. Honest failure and accounting

The theme: a tool must never report success it did not earn.

**B09 — Read-time atom provenance quote-status enrichment.**
Distinguishes a surviving source passage from a disappeared source using fresh,
`quote_present_in_live_page`, `quote_orphaned`, `source_gone` and `slug_unbound`.
*Prevents:* "the source is fine" and "the source is gone" being indistinguishable.
*Not claimed:* quote presence is not current-claim certification and not a
restored source binding.

**B11 — Unpriced embedding/chat refusal and honest accounting.**
Upstream's *explicit* operator budget already refuses an unpriced route, but the
*default* budget runs uncapped. The overlay retains only the extra default-route
refusal and truthful unknown accounting.
*Prevents:* default caps silently disappearing, and unpriced embedding being
reported as priced zero.
*Not claimed:* a listed price or API-rate equivalent is not an actual subscription
charge. This behaviour does not authorize new spend ceilings.

**B13 — A blocked drain batch becomes a visible retryable failure.**
*Prevents:* a preflight-blocked or skipped batch falsely completing as
"no progress, green".

**B20 — One deadline and one file budget across roster/config/Git/files/DB.**
*Prevents:* a partial verifier outliving its budget, or presenting unfinished
sources as clean.

**B21 — Drift sync-identity and eligibility parity.**
*Prevents:* wrong-slug misroute advice arising from restored legacy identities,
collisions, or excluded files.

**B22 — Honest DB-unavailable / roster / config failure, and unauthorized
comparison scope.**
*Prevents:* omitted drift checks, and reading comparison-source data outside the
caller's grants.

## 5. Provider and queue behaviour

**B06 — Provider session-header injection in the gateway.**
This is **deployed code, not configuration**: a gateway patch merges required
session headers into the auth resolution path, scoped to the specific hosts, with
an auth-shadow guard and a stable non-secret fallback.
*Prevents:* compatible provider requests missing a required session header.
*Boundary:* service environment variables alone are not transport proof; the
regression asserts the actual SDK transport.

**B14 — Dedicated global maintenance queue.**
*Prevents:* brain-wide maintenance occupying the per-source default work queue.

## 6. Tooling

**B24 — Serial runner membership preservation under bad scheduler output.**
*Prevents:* an ordering helper silently shrinking the executed serial corpus.

**B25 — Local-only disposable codegraph probe.**
Caller/blast inspection without reindexing a live brain or changing grants.

**B26 — Scoped RSS observer and intact serial persistence workload tests.**
*Prevents:* process-global memory spies contaminating later workload tests.

## Retired

**B18 — Unreadable roots/subdirectories and skipped Git sources warn "not
verified"** — now upstream-equivalent. Retired locally.
**B19 — Git work-tree prefix matching and safe unresolved skip** — now
upstream-equivalent. Retired locally.
**B23 — Live drift budget** — replaced by configuration rather than a code patch.
