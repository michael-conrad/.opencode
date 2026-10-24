# Spec: The behavioral harness can complete and judge a capped run

Provenance: developer directive 2026-10-24 (a spec that needed more than four
revisions is re-evaluated for decomposition, and the measurement concern is
extracted from `.opencode#2657` into this spec). Observed failures: the
anchorless cap-hit resume, recorded in the deck's correction catalogue
`.opencode/.issues/lessons-learned/session-2026-10-20/README.md` LL-3
(first observed on the `#2639` scenario's recovery path) and in this deck's own
runs — three consecutive `FATAL: resume failed — no non-undetermined
determination exists` with no inference dispatched
(`tmp/behavioral-evidence-2657-sc1-stage-request-runs-stage-GREEN-ollama-qwen3.8-27b-256k-gguf4/stderr.log`),
and the run's capped assistant message at `finish: "length"` with 4,000 output
tokens and no tool call (the same run's exported `session.yaml`).

## Problem

A behavioral run whose turn ends at the harness's per-turn output cap cannot
be resumed, cannot be judged, and never produces the artifact its criterion
asks about. Three defects sit on that path. The first two are fixed; the
third is open, and the two surfaces that describe the path both describe a
behavior the code does not have.

### Defect 1 — the resume gives the model no state anchor (fixed)

The cap-hit resume sent "Continue the task from where you left off." The
model then re-derives the session's history from a long context, spends the
whole per-turn budget re-deriving, and issues no tool call; the resume makes
no progress and the run exhausts the cap-resume ceiling with no artifact. The
deck records this in its own catalogue: the default message "gives the model
no state anchor, so it reconstructs from a ~65k-token context every turn" and
issues "ZERO tool calls". The run-level fix `.opencode#2639` applied to its
own scenario's bespoke recovery path; the generic path every scenario takes
still sent the anchorless form.

### Defect 2 — the determination gate cannot see the record (fixed)

The gate that guards a resume scans the Docker tier's staging root and the
run's behaviour-test directory. The determination record is written to the
run's artifact directory, which is neither — the Docker tier's `TMP_DIR` is
the staging root and does not contain it. The gate therefore refused every
cap-hit resume with `determination.yaml not found in any scenario evidence
dir`, before any inference was dispatched.

### Defect 3 — the gate blocks a capped run the monitor could not judge (open)

The gate permits a resume when the home's determination record carries a
non-undetermined classification, or a valid recorded orchestrator decision.
A capped run's monitor frequently classifies the attempt `undetermined`, and
the orchestrator decision is appended only on the monitor's halt-class path —
the poll log's `MONITOR-HALTED` marker. A capped attempt that was neither
judged nor halted has a record the gate finds and still blocks on. The
record exists when the resume is attempted, so the record's absence is not
the blocker; the record's content is.

The surfaces that describe the path describe a behavior the code does not
have. `tests-v2/with-test-home`'s `__sc8_determination_gate` carries a
comment stating that the gate "permits the resume when the target home's own
session record shows the last assistant turn ended with finish=length"; the
function contains no such check — the word `finish` appears in the file only
in that comment. `tests-v2/AGENTS.md` §10.7 row 6 states that an unmonitored
run's determination record "carries the run's exit code and a recorded
orchestrator decision", so the resumption path passes the gate; the record is
flag-gated — `__write_determination_record` runs only under
`BEHAVIOR_SEMANTIC_MONITOR=1` — so an unmonitored run writes no record at
all.

The consequence is that the two documented repairs do not reach the observed
failure. A run whose monitor classified the attempt `undetermined` without a
halt marker is still refused, and the refusal is reported as a missing
determination when the record is present and readable.

## Root causes

- **RC-1** — The generic cap-hit resume path carried the anchorless default
  message; the repair that fixed one scenario's bespoke recovery path was
  never applied to the path every scenario takes.
- **RC-2** — The gate's scan roots were the two directories the launcher
  named, and neither is the directory the record is written to; the gate
  could not find what it looked for.
- **RC-3** — The gate's rule is written in terms of the determination record
  alone, but the case the gate must not block — the cap-hit resume — is
  defined by the session's own last turn, which the record does not carry.
  The rule has no way to recognize the case it must permit.
- **RC-4** — The documentation of the gate and of the unmonitored path was
  written from intent rather than from the code, and the code was never
  checked against it.

## Requirements

- **R-1** — The cap-hit resume's message is composed from the run's own
  session database: the agent's last recorded reasoning, and the recorded
  in-flight tool call when there is one. Both resume paths use it — the host
  path in `tests-v2/behaviors/helpers.sh` and the Docker launcher's own
  default in `tests-v2/docker/docker-harness.sh` — so a caller that passes no
  message does not reintroduce the anchorless form. The anchorless literal
  survives in comments only.
- **R-2** — The determination gate permits the cap-hit resume. The record for
  a capped attempt is written when the attempt ends, which is after the
  resume it would have permitted, so the gate must not block that case: it
  permits the resume when the target home's own session record shows the last
  assistant turn ended with `finish=length`. The signal is the one the
  harness already reads to detect the cap hit
  (`__last_assistant_finish`). The cap-resume ceiling bounds that cycle, so
  permitting it cannot produce an unbounded loop. Every other resume the gate
  blocks today is still blocked.
- **R-3** — The gate finds the record. Its scan roots are the runner's
  `TMP_DIR` plus every root the launcher names in
  `BEHAVIOR_DETERMINATION_SCAN_DIR` — a colon-separated list carrying the
  run's evidence directory and the run's artifact directory, which is where
  the harness writes the determination record and, on the monitor's halt-class
  path, the orchestrator decision. The Docker tier's `TMP_DIR` is the staging
  root and does not contain the record.
- **R-4** — The record and the decision exist before the resume, and the
  record's existence is conditional. The monitored post-run block writes the
  determination record for every monitored run, appends the orchestrator
  decision only on the monitor's halt-class path, and runs the cap-hit
  resume after both. A record is written only under
  `BEHAVIOR_SEMANTIC_MONITOR=1`; an unmonitored run writes no record, and
  the §10.5 full re-run fallback remains its recovery.
- **R-5** — The surfaces that state the gate's behavior state it truthfully:
  `tests-v2/AGENTS.md` §10.7 and §14 and `skills/behavioral-testing/SKILL.md`
  rule 9 describe the scan roots, the cap-hit exemption, the decision the
  gate accepts, the unmonitored path's actual behavior, and the ordering that
  makes the record available before the resume. The per-turn output cap's
  default stays 4,000 on every surface that sets it, and
  `2646-sc-cap-resume-probe.sh` keeps its deliberate 150 override.

## Impact

**Consumers.** Every behavioral scenario in `tests-v2/behaviors/`, and every
behavioral criterion judged from a run — including the five behavioral
criteria of `.opencode#2657`, which depend on this capability to produce a
run at all. This spec is the prerequisite that capability's evidence rests
on, and `.opencode#2657` states the dependency rather than absorbing it.

**Risk — the gate is a safety precondition.** The gate stops a resume whose
home carries no valid determination, so that a run judged off-track does not
continue. The exemption is narrow: it applies only to a home whose last
assistant turn ended at the output cap — the case the cap-resume path exists
for — and the cap-resume ceiling bounds the cycle. SC-2's negative control
keeps the gate's blocking behavior observable.

**Risk — a wider gate is a weaker gate.** The scan roots widen to the
artifact directory, so the gate sees a record it previously could not. A
record that exists but carries an undetermined classification and no valid
decision is still blocked, so the widening does not admit a run the gate
would have refused for a reason.

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

### SC-2 (structural) — the gate permits a capped run, and still blocks an unjustified one

`tests-v2/with-test-home`'s `__sc8_determination_gate` permits a resume
whose target home's session record shows the last assistant turn ended with
`finish=length`, whether or not a determination record was found; a home
without that signal and without a record still fails fast with the gate's
FATAL message and dispatches no inference.

- **Verify:** two synthetic homes driven through
  `bash tests-v2/with-test-home --resume-home <home>` — one whose
  `.local/share/opencode/opencode.db` carries an assistant message with
  `finish=length` (the run must not emit the gate's FATAL) and one with no
  such message and no determination record (the run must emit it). Both
  checks are executable; the second is the negative control.

### SC-3 (structural) — the gate finds the record, and the record is there before the resume

The gate's scan roots are the runner's `TMP_DIR` plus every root the
launcher names in `BEHAVIOR_DETERMINATION_SCAN_DIR`, and the launcher names
the run's artifact directory — the directory the harness writes the
determination record to — alongside the run's evidence directory. In
`tests-v2/behaviors/helpers.sh`'s monitored post-run block, the determination
record is written, then the orchestrator decision is appended on the
monitor's halt-class path only, and the cap-hit resume runs after both.

- **Verify:** read the three files; the scan-root list, the launcher
  environment, and the post-run call order are visible at their call sites.

### SC-4 (structural) — the documentation states the gate truthfully

`tests-v2/AGENTS.md` §10.7 and §14 and `skills/behavioral-testing/SKILL.md`
rule 9 state the gate's scan roots, the cap-hit exemption, the decision the
gate accepts and the halt-class path that produces it, the unmonitored path's
actual behavior (no record is written, so the resumption path still blocks
and the §10.5 full re-run fallback remains the recovery), and the ordering
that makes the record available before the resume. No surface states a
behavior the code does not have.

- **Verify:** read the three surfaces; each statement in the list above is
  present and matches the code read in SC-3.

### SC-5 (structural) — the per-turn output cap's default is unchanged

Every surface that sets `OPENCODE_EXPERIMENTAL_OUTPUT_TOKEN_MAX` with the
default still carries the 4,000 literal, and
`2646-sc-cap-resume-probe.sh` still carries its own deliberate override.

- **Verify:** grep every cap-setting surface; the 4,000 default and the
  probe's override are both present.

## Success-criteria table

| ID | Criterion | Class | Instrument |
|----|-----------|-------|------------|
| SC-1 | Resume message tail-derived in both paths; anchorless literal in comments only | structural | read + grep the two harness files |
| SC-2 | Gate permits a `finish=length` cap-hit resume; still fails fast without it | structural | two synthetic homes through `with-test-home --resume-home` |
| SC-3 | Gate's scan roots include the artifact directory; record written, then decision on the halt path, then the resume | structural | read the three harness files |
| SC-4 | The three documentation surfaces state the gate's behavior as the code has it | structural | read the three surfaces against SC-3 |
| SC-5 | Cap default 4,000; the probe's deliberate override untouched | structural | grep the cap surfaces |

## Out of scope

- The per-turn output cap's default and the probe scenario's deliberate
  override. The observed degenerate-turn band is where these turns sit, so
  raising the cap would re-open the failure the cap exists to prevent.
- The harness's isolation contract, its default model, and its
  change-control rules.
- The monitor's classification quality, the undetermined-cycle ceiling, and
  the orchestrator's decision semantics. This change makes the existing
  semantics reachable at the cap-hit resume; it does not change them.
- The deck's path-selection rules, the scenario set, and the deck cards that
  carry them — `.opencode#2657`'s subject, which states this capability as a
  dependency of its behavioral criteria.
- The `attic/` deck.

## Approach

Repair the path rather than relax the gate. The resume message is composed
from the session database the harness already exports, so the model resumes on
the recorded tail instead of re-deriving its history. The gate keeps its
blocking rule and gains exactly one exemption, keyed on the `finish=length`
signal the harness already reads to detect the cap hit: a run the cap ended
is the run the resume exists for, and the record for that attempt is written
after the resume it would have permitted. The launcher names the artifact
directory among the gate's scan roots, so the record is found where it is
written. The three documentation surfaces then state what the code does —
including the unmonitored path's real behavior, which the previous text got
wrong.

The criteria are executable rather than descriptive: the exemption is
verified by driving two synthetic homes through the gate's real entry point,
one permitted and one refused, so that the correspondence between this spec
and the code is checked rather than asserted.

---
*Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)*
