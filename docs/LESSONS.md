# Why it took so long, and why it will not next time

The upgrade itself was never the hard part. Reconciling 27 behaviours against a
new upstream release, building, and deploying is a day of work. The week went
into four things, and every one of them is now either fixed or structurally
avoided.

## 1. The acceptance scope was wrong, twice

The first acceptance run executed a **full 4,230-file matrix** — an estimated
11–15 hours of compute for a change that touched a small fraction of the corpus.
The second attempt then repeated work that had already been proven, because
nothing recorded which greens were still valid.

**Fix:** a delta planner that derives the declared tests covering the changed
files and runs those, while refusing to reuse a prior green for any file that is
currently failing. Reuse is allowed only against a fingerprint that has not
changed. The full corpus is not re-run to change a status.

**Lesson:** scope is a correctness property, not an optimization. A test plan that
runs everything is not more rigorous — it is less, because it is too expensive to
run when it matters and it buries the signal.

## 2. Heavy work ran inside a memory-capped worker

Two runs died with OOM at exactly the same point. The cause was not the build:
the build was correct and complete. The worker was capped at 4 GiB as deliberate
host protection, and the build was being run *inside* it.

**Fix:** a helper that runs heavy commands in their own bounded transient unit.
The worker cap stayed exactly as it was.

**Lesson:** when something OOMs, the question is not "raise the limit" but "is
this the right process to run it in". Widening a safety limit to make a failure
go away is how safety limits stop being safety limits.

## 3. Two real product defects surfaced late

- **A lifecycle bug:** a cycle's completion timestamps invalidated the
  source-state stamp captured earlier by its publication step, so a
  correctly-published state read as stale. The tempting "fix" — exclude the
  offending fields from the drift check — would have disabled the check. The
  real fix makes the cycle complete atomically with its derived publications.
- **A lock-inheritance bug:** long-lived children inherited the update-lock file
  descriptor. Killing the parent left an orphan still holding the lock, so the
  next scheduled run did nothing at all and recorded a clean skip. Fixed by
  closing the descriptor in every long-lived child, with a controlled
  reproduction on pre-fix, fixed and installed bytes.

**Lesson:** both were found by verification that was explicitly trying to falsify
claims, not confirm them. The verification was worth more than the build.

## 4. False greens were tolerated for too long

Two gates could not fail:

- the post-update **behaviour** gate checked binary existence, health endpoints
  and a script file — never actual behaviour;
- the acceptance phase could complete with **zero suites executed**, because a
  planner failure inside a process substitution was invisible and an empty
  inventory was treated as success.

Both now fail closed, with regression fixtures that reproduce the original
defects and prove the gate goes red.

**Lesson:** an unproven gate is a liability that compounds. Every hour spent
trusting a green gate that could not fail was an hour of false confidence, and
the eventual discovery cost more than building it correctly would have.

## The structural answer for next time

1. **Reconcile first, mechanically.** Classify every behaviour RETAIN /
   UPSTREAM-EQUIVALENT / CONFIG-REPLACED against upstream's real seams, and delete
   what upstream absorbed.
2. **Make the plan data.** One JSON registry holds the pinned candidate, suites,
   probes and inventory. The next upgrade edits a file.
3. **Run the delta, not the universe.** Declared tests for changed files, with
   fingerprint-validated reuse.
4. **Bound heavy work explicitly.** Builds and matrices run in their own unit with
   an intentional ceiling, never inside a small worker.
5. **Prove the gate fails before trusting it.** Induce a regression in a
   disposable environment first.
6. **Report honestly, including the negatives.** "Certified with these named
   exceptions" beats "all green" every time — the second one is what let the
   false greens survive.

The single biggest time sink was not any one bug. It was the absence of a
mechanism that made *not knowing* visible: unmeasured scope, unattributable OOMs,
and gates that reported success without evidence. Those are the things that are
fixed.
