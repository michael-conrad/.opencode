# Triage — .opencode#2649

Verdict: **valid defect** — both reported parts confirmed against the code
(`.opencode/tests-v2/behaviors/helpers.sh`). Convert to spec.

## Part 1 — flock self-contention (fact-decidable, CONFIRMED)

`__count_undetermined_cycle` (helpers.sh ~line 777) performs its
read-modify-write on the SC-9 counter state file while taking an exclusive
flock on the shared `$PARENT_REPO_DIR/tmp/.behavior-run.lock` (fd 9, `flock
-x -w 30`), the same lock file the main run loop flocks exclusive (`flock -x
-w 30 200`, ~line 1875). The counter's own state-file access needs no
serialization against the run loop — its read-modify-write only needs
mutual exclusion against other counter invocations. During the #2639 SC-8
escalation this shared-lock acquisition produced ~30s waits while the run
loop held the behavior-run.lock, inflating halt-class latency and muddying
stall attribution. Root cause: the counting path piggybacks the run-loop
lock domain for a data structure it could lock in its own domain (the state
file itself or a dedicated lock file). Fix is mechanical and bounded.

## Part 2 — auto-recorded terminate decision (intent-decidable, CONFIRMED at surface)

Two machine paths fabricate orchestrator decision values on
`determination.yaml`:

- **Halt-class auto-record** (helpers.sh ~line 2291–2301): on
  `MONITOR-HALTED` + non-zero exit, the harness calls
  `__record_orchestrator_decision --decision terminate-with-root-cause`
  derived solely from `exit_code` — the "orchestrator decision point" is
  recorded by a machine default derived from the run outcome, not by an
  orchestrator.
- **SC-13 diagnosis-rewrite** (helpers.sh ~line 911–925): when the
  diagnosis gate fires, the gate *rewrites* the decision variable to
  `terminate-with-root-cause` and synthesizes the root-cause string before
  the entry is appended — machine-authored decision content.

The deck's halt-class design intends the determination/decision to be the
orchestrator's human-directed judgment. The observed instance was benign
(`terminate-with-root-cause` PERMITS resume per the §10.7 gate), but the same
auto-record on a genuinely off-track run would silently authorize a
continuation-shaped outcome on machine-authority — and in the observed case
it compounded the monitor's false-signal classification (annotated per #2456
SC-10). Design decision required: machine paths record observations and
diagnosis evidence; the decision value itself awaits orchestrator judgment.

## Disposition

- Part 1 → spec SC on lock-domain separation (fact-decidable instrument).
- Part 2 → spec SC barring machine-authored decision values on the
  halt-class auto-record and SC-13 paths (behavioral instrument); the
  SC-13 validation-gate semantics (rejecting a human-entered
  non-diagnosis `continue-new-dispatch`) are preserved — validation is not
  authorship.