# Plan — .opencode#2649

Consumes the validated spec (`.opencode/.issues/2649/spec.md`, validation
round 1 PASS, zero findings — audit/validation.yaml; round 2 instrument-only
amendment to SC-3/SC-5 instruments recorded in the same record). All plan
items trace to
one of SC-1..SC-5. Probe scripts follow the sanctioned non-model precedent
(`tests-v2/2650-manifest-recording-probe.sh`): direct shell tests of harness
helpers, registered into no runner scenario registry, never an `opencode run`.

## Item 1 — Counter lock-domain separation (SC-1, SC-2 ← R-1, R-2)

- **Deliverable:** `__count_undetermined_cycle` in
  `tests-v2/behaviors/helpers.sh` acquires its exclusive counter lock on a
  dedicated lock file `${state_file}.lock` (its own lock domain) instead of
  the shared `$PARENT_REPO_DIR/tmp/.behavior-run.lock`. The run loop's
  behavior-run.lock use is unchanged.
- **Coverage of the counter's lock domain** (spec edge cases): the
  read-modify-write increment and the ceiling gate's read/ceiling-clear paths
  (`__undetermined_ceiling_check`: the `developer-cleared` reset write and
  the count read) lock on the same `${state_file}.lock` domain, so the
  ceiling gate's read consistency is covered by the state file's own lock
  domain.
- **RED:** create `tests-v2/2649-sc13-probe.sh` (the spec-derived non-model
  probe for this plan — created in this item's RED step before any code
  change) with the SC-2 lock-domain case — hold an exclusive flock on
  `tmp/.behavior-run.lock` from a long-lived holder; launch 4 parallel
  `__count_undetermined_cycle` invocations on an undetermined synthetic
  fixture record. Pre-change behavior: each waits up to 30s on the holder and
  fails (counter lost updates / non-zero returns). Assert: all 4 calls
  succeed, counter == 4, and combined wall time is far below the 30s lock
  wait (the subshell lock was acquired without waiting on the run-loop lock).
- **GREEN:** replace `flock -x -w 30 9` fd 9 target with
  `${state_file}.lock`; adjust the lock-contention message to name the
  counter lock file; update the function's header comment.
- **Verification instrument (SC-1, structural):** grep the counting path —
  no `flock` line in it references `.behavior-run.lock`; the lock target
  names `${state_file}.lock`. Shown in the GREEN evidence.

## Item 2 — Machine-observation recording on the halt-class path (SC-3 ← R-3)

- **Deliverable:** the halt-class auto-record block in `behavior_run`
  (helpers.sh ~2291–2303) is removed and replaced by a machine-observation
  append. New helper `__record_run_outcome <artifact_dir> <exit_code>` —
  extracted so the probe can call it — appends one observation entry
  (exit code, evidence pointers stdout.log/stderr.log/monitor.log,
  `observed_at:` timestamp) to a `run_outcome_observations` list on
  determination.yaml, mirroring `__fold_false_signal`'s append-only awk.
  `__write_determination_record` seeds
  `run_outcome_observations: []`. No machine path appends a `decision:`
  entry with either SC-7 value `{continue-new-dispatch,
  terminate-with-root-cause}` (R-3 covers the exit_code=0 auto
  continue-new-dispatch too).
- **RED (one coherent mechanism):** probe — seed a determination record for
  a halt-class scenario, simulate the halt-class outcome-recording inputs
  (`MONITOR-HALTED` marker in monitor.log, exit_code 1), and invoke the
  outcome-recording entry point `__record_run_outcome`, asserting the SC-3
  outcome (zero `decision:` entries, one observation entry). Pre-change the
  helper does not exist — the probe fails on the absent helper (RED run
  recorded). The pre-change defect state (the inline legacy block appending
  a machine-authored `decision:` entry) is the spec's motivation, not a RED
  assertion: the extraction puts the halt-class recording on a callable
  code path the probe can exercise, and the probe asserts the GREEN record
  state. The `behavior_run` block's wiring (calls `__record_run_outcome`,
  no `__record_orchestrator_decision` call remains) is asserted structurally
  by grep.
- **GREEN** verifies: `behavior_run` halt-class block calls
  `__record_run_outcome` instead of `__record_orchestrator_decision`.
- **Verification instrument:** probe asserts (behavioral, container-local —
  pure shell, no model run); grep for the auto-record call sites.

## Item 3 — SC-13 gate validates, never rewrites (SC-4 ← R-4)

- **Deliverable:** in `__record_orchestrator_decision`, the SC-13 diagnosis
  gate (~911–925) keeps its detection logic and validation semantics but
  drops the rewrite: when the record is non-progressing (off-track or
  undetermined) with an identifiable external cause — (a) an orchestrator
  `continue-new-dispatch` is rejected with a `VALIDATION-ERROR` naming the
  undiagnosed cause, return 1, no entry appended; (b) a
  `terminate-with-root-cause` whose root_cause does not name the diagnosed
  cause is rejected the same way; (c) a diagnosis-named
  `terminate-with-root-cause` is accepted and appended byte-identical
  (entered values never modified). No machine synthesis of a decision or
  root_cause string anywhere.
- **RED:** probe feeds four pre-written determination records through the
  gate: (1) off-track + cause + `continue-new-dispatch` → pre-change
  behavior rewrites the value; probe asserts on GREEN: non-zero return, no
  appended entry; (2) undetermined + cause + generic root_cause → rejected,
  values untouched; (3) undetermined + cause + diagnosis-naming root_cause →
  accepted, appended entry byte-identical to entered values; (4) record
  without cause (off-track, no evidence) → gate does not fire, decision
  appended unchanged. Pre-change, cases 1–2 pass with rewritten content
  (assert fails).
- **Verification instrument:** the probe's byte-identity assertion.

## Item 4 — SC-7 write-path contract unchanged (SC-5 ← R-5)

- **Deliverable:** none (regression guard). `__record_orchestrator_decision`
  keeps the value-set validation and the terminate-with-root-cause
  root-cause requirement.
- **Verification instrument:** the Item 3 probe additionally carries the
  SC-5 cases per the amended instrument (spec round 2 — the previously
  referenced "existing SC-7 validation tests" do not exist in the repo):
  accepted `continue-new-dispatch` on a progressing record (no cause), and
  accepted `terminate-with-root-cause --root-cause "..."` on a
  cause-free record; rejected: terminate-with-root-cause without a root
  cause, invalid value-set member, missing determination record — non-zero
  exits with `HARNESS_FAILURE` naming the contract, no entry appended.

## Item 5 — Documentation and comment currency (spec scope)

- **Deliverable:** update the comment blocks that document the changed
  mechanics: helpers.sh header comment at the counter (`EXISTING flock
  discipline` paragraph), the SC-13 gate comment inside
  `__record_orchestrator_decision` (states "The gate rewrites the decision"),
  the SC-7 caller comment block at the halt-class path, and tests-v2/
  AGENTS.md §10.7 predicate-mirror lines describing `__record_orchestrator_decision`
  (add that machine paths never author decisions) — where they document the
  SC-7/SC-9 record mechanics.
- **Verification instrument:** reference-integrity check on touched docs +
  grep confirming no stale "auto-record"/"rewrites" prose at the touched
  sites.

## Dependency order

Item 1 → Item 2 → Item 3 (probe infrastructure shared) → Item 4 (rides Item
3's probe) → Item 5 (comment currency follows the final code shape).

## Verification summary

- Non-model probes: `tests-v2/2649-sc13-probe.sh` (SC-1..SC-5) — RED run
  recorded before GREEN, GREEN run after.
- Structural: grep audits per SC-1; reference-integrity on touched markdown.
- Backward compat check: the §10.7 gate (`__sc8_determination_gate` in
  `with-test-home`) reads old records with machine-authored `decision:`
  entries unchanged (read path untouched; grep verifies no read-path edit).

## Traceability (derived from spec)

| Item | Spec source |
|---|---|
| 1 | R-1, R-2 (spec defect 1; helpers.sh ~777 lock) |
| 2 | R-3 (spec defect 2; helpers.sh ~2291–2301) |
| 3 | R-4 (spec defect 2; helpers.sh ~911–925) |
| 4 | R-5 | 
| 5 | spec Scope (docs update), R-1..R-4 surface currency |

No plan item exists without an SC trace; no padding items.