# Spec: The behavioral harness can complete and judge a capped run

Provenance: the measurement concern separated from `.opencode#2657` (the
deck's path-selection work), where it is a stated dependency of that work's
behavioral criteria; the two carry different gates — the harness's
change-control rules and the deck's admission gate — and the separation keeps
each gate exercisable on its own terms. Observed failures: the anchorless
cap-hit resume, recorded in the deck's correction catalogue
`.opencode/.issues/lessons-learned/session-2026-10-20/README.md` LL-3 (first
observed on the `#2639` scenario's recovery path: the default resume message
"gives the model no state anchor, so it reconstructs from a ~65k-token context
every turn" and issues "ZERO tool calls"); and this deck's own run —
`tmp/behavioral-evidence-2657-sc1-stage-request-runs-stage-GREEN-ollama-qwen3.8-27b-256k-gguf4/`,
whose `stderr.log` carries three consecutive `FATAL: resume failed — no
non-undetermined determination exists … determination.yaml not found in any
scenario evidence dir … no inference dispatched`, whose `determination.yaml`
carries `classification: undetermined` with a recorded
`terminate-with-root-cause` decision carrying a root cause, and whose
`monitor.log` ends `MONITOR-HALTED polls=4`.

## Problem

A behavioral run in the Docker tier whose turn ends at the harness's per-turn
output cap cannot be resumed, cannot be judged, and never produces the
artifact its criterion asks about. The path carries three defects. One is
repaired; two are open, and two surfaces describe the path in terms the code
does not have. The refusal is a Docker-tier defect: on the host tier the
gate's `TMP_DIR` root is the parent repository's `tmp/`, where the artifact
directory sits at a depth the gate scans, so the host tier's gate finds the
record.

### Defect 1 — the resume gives the model no state anchor (repaired)

The cap-hit resume sent "Continue the task from where you left off." The
model then re-derives the session's history from a long context, spends the
whole per-turn budget re-deriving, and issues no tool call; the resume makes
no progress and the run exhausts the cap-resume ceiling with no artifact. The
deck records this in its own catalogue, on the `#2639` scenario's bespoke
recovery path; the generic path every scenario takes still sent the
anchorless form. The repair composes the resume message from the run's own
session database — the agent's last recorded reasoning and the recorded
in-flight tool call — so the resumed turn continues the recorded work.

### Defect 2 — the Docker tier's gate never scans the record's directory (open)

In the Docker tier the gate that guards a resume scans the tier's staging
root and the run's behaviour-test directory. The determination record is
written to the run's artifact directory, which is neither: the tier's
`TMP_DIR` is the staging root and does not contain it. The gate therefore
refused every cap-hit resume with `determination.yaml not found in any
scenario evidence dir` — the message the preserved run's `stderr.log` carries
three times, naming the two roots it scanned — before any inference was
dispatched. On the host tier the same gate scans the parent repository's
`tmp/` root, and the artifact directory sits inside it at a depth the gate
searches, so the host tier's gate finds the record; the defect is in the
Docker tier's scan roots, not in the gate's rule.

The repair has two halves, and one of them is in place. The launcher now
names the run's artifact directory among the roots it passes to the gate, and
the gate's scan roots are the runner's `TMP_DIR` plus every root named in
`BEHAVIOR_DETERMINATION_SCAN_DIR`. The second half is not in place: the gate
parses that colon-separated list with
`printf '%s' "$BEHAVIOR_DETERMINATION_SCAN_DIR" | tr ':' '\n'`, whose output
carries no trailing newline, so the final element is read into the loop's
variable but the loop body never runs for it. The artifact directory is the
final element of the list the launcher builds — `dirname "$err_file"` and then
`$artifact_dir` — so the one root the repair added is the one root the gate
drops, and the gate's scanned roots are still the staging root and the
evidence directory. The refusal the repair targeted still occurs.

The record the gate cannot see is present in the preserved run's artifact
directory, and it carries what the gate accepts: `classification: undetermined`
with a recorded `terminate-with-root-cause` decision carrying a root cause.
The gate's own rule — a resume is permitted when the record carries a
non-undetermined classification or a valid recorded decision — would permit
that record. The refusal is the missing root, not the record's content.

### Defect 3 — the path's documentation states behavior the code does not have (open)

Two surfaces describe the gate in terms the code does not have, and a third
states a rule the gate does not implement.

`tests-v2/with-test-home`'s `__sc8_determination_gate` carries a comment
stating that the cap-hit resume "cannot exist yet — it is written when the
attempt ends, which is after the resume it would have permitted", and that
"the gate therefore permits the resume when the target home's own session
record shows the last assistant turn ended with finish=length". The function
contains no such check — the word `finish` appears in the file only in that
comment — and the premise is false: the harness writes the determination
record, then appends the orchestrator decision on the monitor's halt-class
path, and only then attempts the cap-hit resume. The ordering is deliberate
and is documented where it is implemented, in
`tests-v2/behaviors/helpers.sh`'s monitored post-run block, whose comment
names the observed refusals the ordering answered.

`tests-v2/AGENTS.md` §14 (the "Layered Hang Diagnosis and Abort Completeness"
table, rule 6) states that an unmonitored run "records no monitor
classification, so its determination record carries the run's exit code and a
recorded orchestrator decision; the §10.7 resumption path then passes the SC-8
determination gate on that record, and a hang in an unmonitored run is
recoverable by resume". An unmonitored run writes no record at all:
`__write_determination_record` runs only under `BEHAVIOR_SEMANTIC_MONITOR=1`.
It also never attempts a cap-hit resume — the resume path returns immediately
when the monitor is off. The row's claim is false in both directions, and the
row's own recovery guidance — the §10.5 full re-run fallback — remains the
truth.

`skills/behavioral-testing/SKILL.md` rule 9 states that "a run whose record
carries no valid orchestrator decision cannot resume through the §10.7 path".
The gate permits a resume on a non-undetermined classification with no
decision at all — `progressing-directionally` or `off-track` returns
immediately — so the rule as stated is narrower than the rule the code
implements, and it names a condition that is not necessary for the refusal it
describes.

The consequence is that the repair is described by a rule that is not the
rule, and the unmonitored path is described as recoverable by a route it does
not have. A reader — or a later agent — taking either statement at face value
draws the wrong conclusion about when a capped run may resume.

## Root causes

- **RC-1** — The generic cap-hit resume path carried the anchorless default
  message; the repair that fixed one scenario's bespoke recovery path was
  never applied to the path every scenario takes. *Repaired:* the message is
  composed from the run's session database, and both resume paths use it.
- **RC-2** — The gate's scan roots were the two directories the launcher
  named, and neither is the directory the record is written to; the gate
  could not find what it looked for. *Repaired in the launcher:* the launcher
  now names the artifact directory too.
- **RC-3** — The gate's scan-root list is parsed by a loop whose last
  element is dropped, so a root named at the end of the list is never
  scanned. The launcher appends the artifact directory last, and the one
  root the repair adds is the one root the parser discards. *Open.*
- **RC-4** — The gate's rule is expressed only in terms of the determination
  record, and the path's documentation reached past it: it explained the
  cap-hit case with a premise the harness's own ordering contradicts,
  described an exemption the code does not implement, described the
  unmonitored path as recoverable by a route it does not have, and narrowed
  the gate's rule to one of its two branches. The documentation and the code
  were written and revised apart, and nothing checked the correspondence.
  *Open.*

## Requirements

- **R-1** — The cap-hit resume's message is composed from the run's own
  session database: the agent's last recorded reasoning, and the recorded
  in-flight tool call when there is one. Both resume paths use it — the host
  path in `tests-v2/behaviors/helpers.sh` and the Docker launcher's own
  default in `tests-v2/docker/docker-harness.sh` — so a caller that passes no
  message does not reintroduce the anchorless form. The anchorless literal
  survives in comments only.
- **R-2** — The Docker tier's gate scans every root the launcher names. The
  gate's scan roots are the runner's `TMP_DIR` plus every root named in
  `BEHAVIOR_DETERMINATION_SCAN_DIR` — a colon-separated list carrying the
  run's evidence directory and the run's artifact directory, which is where
  the harness writes the determination record and, on the monitor's halt-class
  path, the orchestrator decision. No named root is dropped: the list is
  parsed so that every element is scanned, the last one included. The Docker
  tier's `TMP_DIR` is the staging root and does not contain the record; the
  host tier's `TMP_DIR` is the parent repository's `tmp/`, which does
  contain the artifact directory, and the host tier's gate finds the record
  without a named root.
- **R-3** — The record and the decision exist before the resume. The
  monitored post-run block writes the determination record for every
  monitored run that reaches it, appends the orchestrator decision when the
  poll log carries the `MONITOR-HALTED` marker — the classification-halt path
  and the dispatch-failure-ceiling path both write that marker — and
  attempts the cap-hit resume after both. Two checks sit in that sequence
  and can end the block before its later steps: the session-isolation check
  ends it before the record is written, and the undetermined-cycle ceiling
  check ends it before the decision is appended and before the resume is
  attempted. The ceiling's place in the sequence is the harness's own, and
  this spec does not move it. The gate's rule is the one the code implements:
  a resume is permitted when the record carries a non-undetermined
  classification — `progressing-directionally` or `off-track` — or a valid
  recorded decision — `continue-new-dispatch`, or `terminate-with-root-cause`
  carrying a root cause; a record carrying neither is refused. The cap-hit
  resume is not an exception to that rule, because the record and the
  decision the rule reads are already written when the resume is attempted.
  The resume path is monitor-gated: a run without the monitor writes no
  record and attempts no resume.
- **R-4** — The surfaces that state the path state it as the code has it.
  `tests-v2/with-test-home`'s gate comment states the gate's rule and drops
  the cap-hit explanation whose premise the ordering contradicts, so no
  surface claims an exemption the gate does not implement.
  `tests-v2/AGENTS.md` §10.7 states the gate's scan coverage, and §14 states
  the unmonitored path truthfully — an unmonitored run writes no
  determination record and attempts no cap-hit resume, so the §10.7
  resumption path hard-blocks for an unmonitored home and the §10.5 full
  re-run fallback remains its recovery.
  `skills/behavioral-testing/SKILL.md` rule 9 states the gate's rule as the
  code has it: a resume is permitted when the record carries a
  non-undetermined classification or a valid recorded decision, and a run
  whose record carries neither cannot resume through the §10.7 path.
- **R-5** — The per-turn output cap's default stays 4,000 on every surface
  that sets it, and `2646-sc-cap-resume-probe.sh` keeps its deliberate 150
  override. The observed degenerate-turn band is where these turns sit, so
  raising the cap would re-open the failure the cap exists to prevent.

## Impact

**Consumers.** Every behavioral scenario in `tests-v2/behaviors/` that runs in
the Docker tier, and every behavioral criterion judged from such a run —
including the five behavioral criteria of `.opencode#2657`, whose runs depend
on this capability to produce an artifact at all. That work states this
capability as a dependency rather than absorbing it.

**Risk — the gate's rule is untouched; what it sees is not.** The gate stops a
resume whose home carries no determination it accepts — no record at all, or
a record whose classification is neither non-undetermined nor accompanied by a
valid decision. The gate does not stop a run the monitor classified
`off-track`: its rule accepts any non-undetermined classification, and this
spec does not change that rule. The widening of the scan roots means the
gate's existing rule now reaches records it could not see — including a
record for an `off-track` run, which the rule accepts. The change does not
widen what the gate accepts, only what it can see. SC-3's negative control
keeps the gate's blocking behavior observable.

**Boundary — runs the cap-resume path does not reach.** A monitored run whose
poll log carries neither a taxonomy classification nor the `MONITOR-HALTED`
marker is recorded with `classification: none` and carries no decision, and
the gate refuses it; the cap-resume path for such a run stays unavailable. A
run whose undetermined-cycle count has reached the ceiling ends the post-run
block before the decision is appended and before the resume is attempted, so
no cap-hit resume runs for it. A run halted by the dispatch-failure ceiling
is not in either class: that path writes the marker, so a decision is
appended and the gate accepts the record. These are boundaries of the
existing rule, not defects this spec changes; they are stated so that no
reader infers that every capped run can resume.

**Blast radius.** `tests-v2/behaviors/helpers.sh`,
`tests-v2/docker/docker-harness.sh`, `tests-v2/with-test-home`,
`tests-v2/AGENTS.md` §10.7 and §14, `skills/behavioral-testing/SKILL.md`
rule 9. Nothing else in the harness: the isolation contract, the default
model, the change-control rules, and the per-turn output cap are unchanged,
and no deck rule outside `skills/behavioral-testing/` is touched.

## Success criteria

### SC-1 (structural) — the resume message is tail-derived in both paths

The cap-hit resume in `tests-v2/behaviors/helpers.sh` calls the tail-message
composer and passes its message to both the Docker and the host resume path;
the Docker resume launcher's own default in
`tests-v2/docker/docker-harness.sh` is tail-derived rather than anchorless,
so a caller that passes no message does not reintroduce the anchorless form;
the anchorless literal appears in executable code in neither file.

- **Verify:** read the two files; grep the anchorless literal in both — hits
  in comments only.

### SC-2 (structural) — the gate scans every root the launcher names

`tests-v2/with-test-home`'s `__sc8_determination_gate` scans the runner's
`TMP_DIR` plus every root named in `BEHAVIOR_DETERMINATION_SCAN_DIR`, and
scans the last element of that list as well as the others — so the Docker
tier's gate reaches the run's artifact directory, which the tier's `TMP_DIR`
staging root does not contain.

- **Verify:** drive the gate with `BEHAVIOR_DETERMINATION_SCAN_DIR` naming
  two roots and no record in either; the gate's `FATAL:` message names the
  roots it scanned, and both named roots appear in that list. The check is
  executable without dispatching inference — the gate's function extracted
  from `tests-v2/with-test-home` and invoked directly.

### SC-3 (structural) — the gate finds the record, and the gate still blocks without one

`tests-v2/with-test-home`'s `__sc8_determination_gate` finds the
determination record in the run's artifact directory when the launcher names
that directory in `BEHAVIOR_DETERMINATION_SCAN_DIR`, and permits the resume
that the preserved run's record supports — the record carries
`classification: undetermined` with a recorded `terminate-with-root-cause`
decision carrying a root cause. With no record in the scanned roots, the gate
still fails fast with its `FATAL:` message and dispatches no inference.

- **Verify:** two replays of the gate against the preserved run
  `tmp/behavioral-evidence-2657-sc1-stage-request-runs-stage-GREEN-ollama-qwen3.8-27b-256k-gguf4/`
  — the gate's function extracted from `tests-v2/with-test-home` and invoked
  directly, so that no inference is dispatched: one replay with `TMP_DIR` set
  to a scratch directory, `BEHAVIOR_DETERMINATION_SCAN_DIR` naming that run's
  artifact directory, and the target home set to the home path the preserved
  `stderr.log` names (the gate must permit — exit 0, no `FATAL:` on stderr);
  one replay with the scan directory naming an empty directory (the gate must
  emit its `FATAL:`).

### SC-4 (structural) — the record and the decision exist before the resume

In `tests-v2/behaviors/helpers.sh`'s monitored post-run block, the
determination record is written for every monitored run that reaches it, the
orchestrator decision is appended when the poll log carries the
`MONITOR-HALTED` marker — written by the classification-halt path and by the
dispatch-failure-ceiling path — and the cap-hit resume is attempted after
both; the resume path returns immediately when the monitor is off. The
session-isolation check ends the block before the record is written, and the
undetermined-cycle ceiling check ends it before the decision is appended and
before the resume is attempted. The gate's rule is the rule the code
implements: a non-undetermined classification — `progressing-directionally`
or `off-track` — or a valid recorded decision, and a record carrying neither
is refused. The cap-hit resume is not an exception to that rule.

- **Verify:** read `tests-v2/behaviors/helpers.sh` and
  `tests-v2/with-test-home`; the order of the calls, the marker's two
  writers, the two checks that can end the block, and the gate's decision
  branches are visible at their call sites.

### SC-5 (structural) — the documentation states the path as the code has it

`tests-v2/with-test-home`'s gate comment states the gate's rule and does not
claim a cap-hit exemption the gate does not implement. `tests-v2/AGENTS.md`
§10.7 states the gate's scan coverage, and §14 states the unmonitored path
truthfully: an unmonitored run writes no determination record and attempts no
cap-hit resume, so the §10.7 resumption path hard-blocks for an unmonitored
home and the §10.5 full re-run fallback remains its recovery.
`skills/behavioral-testing/SKILL.md` rule 9 states the gate's rule as the
code has it: a resume is permitted when the record carries a
non-undetermined classification or a valid recorded decision, and a run whose
record carries neither cannot resume through the §10.7 path.

- **Verify:** read the three files that document the path —
  `tests-v2/with-test-home`, `tests-v2/AGENTS.md`, and
  `skills/behavioral-testing/SKILL.md` — against the code read in SC-2 and
  SC-4; each statement above is present, and no statement in them describes
  an exemption, a rule, a record, or a recovery route the code does not have.

### SC-6 (structural) — the per-turn output cap's default is unchanged

Every surface that sets `OPENCODE_EXPERIMENTAL_OUTPUT_TOKEN_MAX` with the
default still carries the 4,000 literal, and
`2646-sc-cap-resume-probe.sh` still carries its own deliberate override.

- **Verify:** grep every cap-setting surface; the 4,000 default and the
  probe's override are both present.

## Success-criteria table

| ID | Criterion | Class | Instrument |
|----|-----------|-------|------------|
| SC-1 | Resume message tail-derived in both paths; anchorless literal in comments only | structural | read + grep the two harness files |
| SC-2 | The gate scans every root the launcher names, the last element included | structural | drive the gate with two named roots; the `FATAL:` message names both |
| SC-3 | Gate finds the record in the artifact directory and permits the preserved run's record; still fails fast with no record | structural | two replays of the gate against the preserved run |
| SC-4 | Record written, then the decision when the poll log carries the `MONITOR-HALTED` marker, then the resume; the two checks that can end the block before those steps; the gate's rule is the rule the code implements | structural | read the two harness files |
| SC-5 | The three files that document the path state it as the code has it | structural | read the three files against SC-2 and SC-4 |
| SC-6 | Cap default 4,000; the probe's deliberate override untouched | structural | grep the cap surfaces |

## Out of scope

- The per-turn output cap's default and the probe scenario's deliberate
  override (R-5 preserves them).
- The harness's isolation contract, its default model, and its
  change-control rules.
- The monitor's classification quality, the undetermined-cycle ceiling and
  its place in the post-run block's sequence, and the orchestrator's decision
  semantics. This change makes the existing semantics reachable at the
  cap-hit resume; it does not change them, and it does not add a cap-hit
  exemption to the gate.
- The deck's path-selection rules, the scenario set, and the deck cards that
  carry them — `.opencode#2657`'s subject, which states this capability as a
  dependency of its behavioral criteria.
- The `attic/` deck.

## Approach

Repair the path rather than relax the gate, and make the documentation say
what the code does. The resume message is composed from the session database
the harness already exports, so the model resumes on the recorded tail instead
of re-deriving its history. The launcher's list of roots gains the artifact
directory, and the gate's parser is corrected so that no named root is
dropped — the list the launcher builds ends with the one root the gate must
see. The gate's rule is untouched, and the record the preserved run carries —
a valid recorded decision — is the record it accepts. The post-run block's
ordering, which already places the record and the decision before the
resume, is stated as the reason the cap-hit case is not an exception to the
gate's rule. The three surfaces that described the path in other terms are
brought into line with the code — the gate comment, the unmonitored path's
row, and the rule that narrowed the gate's rule to one branch — and the
unmonitored path's real recovery, the §10.5 full re-run fallback, is
restored to the documentation that had replaced it.

The criteria are executable rather than descriptive: the gate's behavior is
verified by replaying it against the preserved run, once permitting and once
refusing, so the correspondence between this spec and the code is checked
rather than asserted.

---
*Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)*
