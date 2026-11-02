# Spec — .opencode#2649

## Problem

During the .opencode#2639 SC-8 monitor-halt investigation (2026-10-20), the
SC-13 escalation path exhibited two coupled defects in the behavioral-harness
shell code (`.opencode/tests-v2/behaviors/helpers.sh`):

1. **Flock self-contention.** The SC-9 undetermined-cycle counting path
   (`__count_undetermined_cycle`) takes its exclusive lock on the shared
   `tmp/.behavior-run.lock`, the lock the main run loop holds for the whole
   monitored run. During the escalation this yielded ~30s lock waits inside
   the counting path itself, inflating halt-class latency and muddying stall
   attribution (the stall initially attributed to the run was partly the
   counting path's own lock wait).
2. **Machine-authored orchestrator decision.** On the stale halt, machine
   paths auto-recorded a `terminate-with-root-cause` decision on
   `determination.yaml`: the halt-class auto-record path
   (`helpers.sh` ~2291–2301) calls `__record_orchestrator_decision` with a
   decision derived solely from `exit_code`, and the SC-13 diagnosis gate
   (~911–925) rewrites the decision variable and synthesizes the root-cause
   string before the entry is appended. The halt-class design intends the
   determination decision to be the orchestrator's judgment, not a machine
   default. The observed instance was benign (that decision class permits
   resume per the §10.7 gate, allowing the recovery passes), but the same
   auto-record on a genuinely off-track run would silently authorize a
   continuation-shaped outcome on machine authority — and here it compounded
   the monitor's false-signal classification (annotated per .opencode#2456
   SC-10, 2026-10-21).

Full triage: [triage.md](triage.md).

## Scope

The change targets the behavioral harness shell code:
`.opencode/tests-v2/behaviors/helpers.sh` — the `__count_undetermined_cycle`
locking, the halt-class auto-record block, and the SC-13 diagnosis-gate
rewrite. It also updates the affected tests-v2 behavior documentation where
it documents the SC-7/SC-9 record mechanics. No deck (.opencode/skills/,
guidelines/) change, no production-source change, no test-runner
infrastructure change.

## Approach

- **Lock domain separation (defect 1):** the SC-9 counter's
  read-modify-write serializes against its own lock domain — a dedicated
  lock file for the counter state (or direct file-locking on the state
  file) — never against `tmp/.behavior-run.lock`. The run loop's existing
  use of `tmp/.behavior-run.lock` is unchanged.
- **Decision authorship (defect 2):** machine paths in the harness record
  *observations* (classification, exit evidence, diagnosed external cause)
  but never author or rewrite an orchestrator decision value or
  machine-synthesize a decision entry. On the halt-class path, the run
  outcome is recorded as evidence under the record's non-decision sections;
  the `decision:` list awaits an actual orchestrator-recorded entry made
  through `__record_orchestrator_decision`. The SC-13 gate keeps its
  validation semantics — it rejects an orchestrator-entered
  `continue-new-dispatch` whose record carries an identifiable external
  cause, and rejects a root cause that does not name the diagnosed cause —
  but it validates, never rewrites or authors. The §10.7 SC-8 resume gate
  semantics are unchanged: a resume still requires a non-undetermined
  determination; removal of the auto-record means a resume on a halt-class
  record waits for the orchestrator's actual decision, which is the
  intended surface.

## Requirements

- **R-1 (SHALL):** `__count_undetermined_cycle` acquires its exclusive
  counter lock on a lock domain disjoint from `tmp/.behavior-run.lock` —
  no flock of the behavior-run.lock file descriptor occurs anywhere in the
  counting path.
- **R-2 (SHALL):** concurrent invocations of `__count_undetermined_cycle`
  remain mutually exclusive on the counter's own lock domain: parallel
  increments produce no lost updates.
- **R-3 (SHALL):** the halt-class auto-record path records the run outcome
  (exit code, evidence pointers) as machine-observation entries — no
  `decision:` entry with a value {continue-new-dispatch,
  terminate-with-root-cause} is appended by any machine path.
- **R-4 (SHALL):** the SC-13 diagnosis gate validates
  orchestrator-recorded decisions (rejecting non-diagnosis
  `continue-new-dispatch` and non-diagnosis-derived root causes) and never
  rewrites a decision variable or synthesizes a decision/root_cause value.
- **R-5 (SHALL):** orchestrator decision authorship remains available
  through `__record_orchestrator_decision` with its SC-7 value-set
  contract (terminate-with-root-cause requires a root cause) unchanged.

## Success criteria

| ID | Criterion | Class | Instrument |
|----|-----------|-------|------------|
| SC-1 | No flock acquisition of `tmp/.behavior-run.lock` inside `__count_undetermined_cycle`; its lock target is a distinct lock domain (dedicated lock file or the counter state file). | Structural | Code inspection + grep: no `flock` call in the counting path references the behavior-run.lock path or its fd; the counting path's lock target names its own domain. |
| SC-2 | While a run-loop holder keeps `tmp/.behavior-run.lock` flocked, N concurrent `__count_undetermined_cycle` invocations on an undetermined determination still all complete and leave the counter exactly N (no lost updates, no lost increments blocked by the run-loop lock). | Behavioral | Harness-level test: flock behavior-run.lock from a long-lived holder, run N parallel counter calls under the held lock, assert all N calls return success and the counter == N. |
| SC-3 | After the halt-class path completes (MONITOR-HALTED + non-zero exit), the determination record's entry lists have zero `decision:` entries appended by machine paths, and the run outcome evidence (exit code, evidence pointers) is present as machine-observation content. | Behavioral | Harness-level probe of the halt-class outcome-recording path (instrument revised round 2, 2026-11-02: "behavioral harness run" was not achievable without a full model run; non-model container-local probe per the 2650 precedent): exercise the halt-class outcome-recording path (a determination record + monitor.log carrying MONITOR-HALTED, non-zero exit_code) and assert the record gains zero `decision:` entries and one observation entry carrying the exit code and evidence pointers; the run-outcome block's wiring (no `__record_orchestrator_decision` call remains there) is asserted structurally. |
| SC-4 | The SC-13 gate rejects an orchestrator-entered `continue-new-dispatch` on a non-progressing record with an identifiable external cause, and accepts a diagnosis-named `terminate-with-root-cause`, without modifying the entered values. | Behavioral | Harness test: feed pre-written determination records with orchestrator-entered decision values through the gate; assert rejection/validation outcomes and byte-identical entered values in the appended entry. |
| SC-5 | `__record_orchestrator_decision` still accepts both value-set members and enforces the root-cause requirement for terminate-with-root-cause. | Structural | Harness-level probe of the SC-7 write path (instrument revised round 2, 2026-11-02: the named "existing SC-7 validation tests" do not exist — no runnable test in the repo references `__record_orchestrator_decision`; the probe replaces the dangling reference): both value-set members accepted, terminate-with-root-cause without a root cause rejected (non-zero, no entry), invalid values rejected. |

## Verification

Behavioral SCs (SC-2, SC-3, SC-4) run through the tests-v2 behavioral
harness — per the behavioral-testing card, never an ad-hoc `opencode run`.
The harness provisions its self-contained GitBucket container where a
remote is needed; lock-domain and decision-record scenarios are
container-local. Structural SCs (SC-1, SC-5) verify by inspection and the
existing harness test suite with shown output.

## Edge cases

- Determination records written by *prior* harness versions already carry
  machine-authored `decision:` entries; the changed paths must read such
  records without failure (backward-compatible read; the §10.7 gate reads
  unchanged).
- The SC-9 ceiling gate (`__undetermined_ceiling_check`) reads the same
  counter state file — the lock-domain change must not weaken the gate's
  read consistency; the state file's own lock domain covers both the
  counting increment and the gate/ceiling-clear paths.
- A halt-class run with exit_code 0: the prior auto-record of
  `continue-new-dispatch` is equally machine-authored and is removed by
  the same change (R-3 covers both value-set members).

## Out of scope

- The monitor's false-signal classification itself (dispatch starvation) —
  owned by .opencode#2456's SC-10 annotation; not this ticket.
- The §10.7 SC-8 resume gate semantics and the SC-7 value-set.
- Any deck (.opencode/skills/, guidelines/, floor.md) content.
- Production source outside tests-v2.

## Traceability

| Requirement | Source |
|---|---|
| R-1, R-2 | Issue defect 1 (flock self-contention, ~30s observed waits) — confirmed at helpers.sh ~777 (`flock -x -w 30 9` on behavior-run.lock) vs. run-loop flock ~1875. |
| R-3 | Issue defect 2 (auto-recorded terminate decision, recorded_at 2026-10-20T16:33:00Z evidence) — confirmed at helpers.sh ~2291–2301. |
| R-4 | Issue defect 2 (SC-13 rewrite path) — confirmed at helpers.sh ~911–925. |
| R-5 | Issue statement: the SC-7 record path must remain the orchestrator's decision surface. |

🤖 OpenCode (huggingface/zai-org/GLM-5.3-Flash)