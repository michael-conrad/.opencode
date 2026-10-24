# Plan — .opencode#2663: the harness's cap-hit resume, the determination gate, and the goal-condition check

Spec: `.opencode/.issues/2663/spec.md` (fresh-context validation PASS, zero
findings). Branch: `feature/2663-harness-cap-hit-resume`, base `a1fb61c6`
(the `.opencode` trunk tip, verified against `origin/main` at plan time).
Repository: `michael-conrad/.opencode` (the `.opencode` submodule). The
`.opencode#2657` change is stacked on this branch and depends on it.

## Surfaces touched

| Surface | Change | SCs |
|---------|--------|-----|
| `tests-v2/behaviors/helpers.sh` | the cap-hit resume composes its message from the run's recorded tail; the resume helpers take the artifact directory optionally; the goal-condition content check matches a declared pattern as a pattern | SC-1, SC-4, SC-6 |
| `tests-v2/docker/docker-harness.sh` | the Docker resume launcher's own default is tail-derived, not anchorless; it names the run's artifact directory among the gate's scan roots | SC-1, SC-2, SC-3 |
| `tests-v2/with-test-home` | the determination gate scans every root the launcher names, the last one included; the gate's comment states the rule the code implements | SC-2, SC-3, SC-5 |
| `tests-v2/AGENTS.md` §10.7 and §14 | the surfaces that state the gate's rule and its scan coverage | SC-5 |
| `skills/behavioral-testing/SKILL.md` rule 9 | the surface that states the gate's rule for the agent running a behavioral verification | SC-5 |

Nothing else in the harness changes: the isolation contract, the default
model, the change-control rules, and the per-turn output cap are untouched,
and the cap's 4,000 default and the probe scenario's deliberate 150 override
are preserved (SC-7).

## Ordering

1. **Item 1** — the cap-hit resume carries the recorded tail (SC-1), and the
   path's order is preserved (SC-4).
2. **Item 2** — the gate scans every named root and finds the record
   (SC-2, SC-3).
3. **Item 3** — the surfaces that state the gate state the change's gate
   (SC-5).
4. **Item 4** — a goal condition's content pattern is matched as a pattern
   (SC-6).

Item 2 depends on item 1, because the artifact directory the launcher names
is the value item 1's optional argument carries; item 3 depends on item 2,
because the surfaces it changes state the gate that item 2 changes; item 4
depends on nothing. The order is acyclic, and every item is committed and
pushed before the next begins.

The gate's own instruments are executable and do not dispatch inference: the
gate's function is extracted from `tests-v2/with-test-home` and invoked
directly, with `TMP_DIR` and `BEHAVIOR_DETERMINATION_SCAN_DIR` set for the
case. That is how the RED assertions below are run.

## Item 1 — the cap-hit resume carries the recorded tail (SC-1, SC-4)

- Deliverable: `tests-v2/behaviors/helpers.sh` gains a composer that builds
  the resume message from the run's own session database — the agent's last
  recorded reasoning and the recorded in-flight tool call when there is one —
  and the cap-hit resume passes that message to both the Docker and the host
  resume path. `tests-v2/docker/docker-harness.sh`'s `__docker_launch_resume`
  default becomes the same tail-derived message, so a caller that passes none
  does not reintroduce the anchorless form. Both resume helpers take the
  run's artifact directory as an **optional** argument: a caller that does
  not know it — the `#2639` scenario's direct-resume path, which passes six
  arguments — keeps the behaviour it had, and no call site aborts on an
  unset argument. The post-run block's order is unchanged and is what the
  change preserves: the determination record is written, the orchestrator
  decision is appended when the poll log carries the `MONITOR-HALTED` marker,
  and only then is the cap-hit resume attempted.
- RED: `grep -n "Continue the task from where you left off" tests-v2/behaviors/helpers.sh
  tests-v2/docker/docker-harness.sh` → the anchorless literal is the resume
  message in `helpers.sh`'s host path and the default in
  `docker-harness.sh`; and the observed effect, which the deck's own
  correction catalogue records on the `#2639` scenario's recovery path —
  LL-3 in `.opencode/.issues/lessons-learned/session-2026-10-20/README.md`:
  the default message "gives the model no state anchor, so it reconstructs
  from a ~65k-token context every turn" and issues "ZERO tool calls". In this
  deck's own runs the three resume attempts were blocked before any inference
  was dispatched — `stderr.log` in
  `tmp/behavioral-evidence-2657-sc1-stage-request-runs-stage-GREEN-ollama-qwen3.8-27b-256k-gguf4/`
  carries three `FATAL: resume failed - no non-undetermined determination
  exists` lines, and the exported `session.yaml` holds one session and one
  capped assistant message (seq 160/161, `finish: "length"`, 4,000 output
  tokens, a reasoning part, no tool call). A second RED follows from the
  change the composer brings: with the artifact-directory argument read
  unguarded, the six-argument call in
  `tests-v2/behaviors/2639-sc8-second-directive-rides-open-pr.sh` aborts
  with `$7: unbound variable` under the harness's `set -euo pipefail`, and
  the scenario's resume never runs.
- GREEN: add the composer and wire it into both resume paths; make the
  artifact-directory argument optional in both helpers.
- Verify: `grep -n "Continue the task from where you left off"` over both
  files returns only comments; the composer runs against a real session
  database and returns a message naming the recorded next action; the
  six-argument call to `__resume_on_cap_hit` and to `__docker_launch_resume`
  runs without an unbound-variable error; `grep -c
  "OPENCODE_EXPERIMENTAL_OUTPUT_TOKEN_MAX=.*4000"` over the cap surfaces is
  unchanged, and the probe scenario still carries its own override (SC-7);
  and the post-run block is read at its call sites, in order: the
  session-isolation check, which ends the block before the record is
  written; the record write; the undetermined-cycle ceiling check, which
  ends the block before the decision and before the resume; the decision
  append, gated on the `MONITOR-HALTED` marker; the resume; and the resume
  helper's monitor gate, which returns immediately when the monitor is off.
  The marker's two writers — the classification-halt path and the
  dispatch-failure-ceiling path — and the gate's decision branches are read
  at their call sites (SC-4).
- Dependency: none.

## Item 2 — the gate scans every named root, and finds the record (SC-2, SC-3)

- Deliverable: `tests-v2/docker/docker-harness.sh`'s `__docker_launch_resume`
  names the run's artifact directory — the directory the harness writes the
  determination record to — alongside the run's evidence directory in
  `BEHAVIOR_DETERMINATION_SCAN_DIR`, a colon-separated list. The gate in
  `tests-v2/with-test-home` reads that list as a list: every element is
  scanned, the last one included. The gate's rule is untouched.
- RED: the observed refusal — `stderr.log` in
  `tmp/behavioral-evidence-2657-sc1-stage-request-runs-stage-GREEN-ollama-qwen3.8-27b-256k-gguf4/`
  carries three `FATAL: resume failed … determination.yaml not found in any
  scenario evidence dir … (evidence trees scanned: …/tmp/docker-staging/tmp
  …/tmp/behavior-test-20261023-144745/2657-sc1-stage-request-runs-stage)`
  lines, naming the two roots it scanned and neither of them the record's
  directory. At the base the gate has no list at all: it appends the whole
  value of `BEHAVIOR_DETERMINATION_SCAN_DIR` as one root, and the launcher
  names one — the evidence directory — so the record's directory is never
  among the roots the gate looks in.
- GREEN: the launcher's two-root list; the gate's list parsing.
- Verify: the extracted gate, driven with `BEHAVIOR_DETERMINATION_SCAN_DIR`
  naming two roots and the record present in the SECOND of them — the gate
  permits the resume (exit 0, no `FATAL:`), which is what proves the last
  element is scanned rather than merely named in the error message (SC-2);
  the extracted gate, driven with the scan list naming the preserved run's
  artifact directory and the target home the preserved `stderr.log` names —
  the gate permits the resume, because the preserved record carries a valid
  recorded decision (SC-3); and the same gate with the scan list naming an
  empty directory — it still fails fast with its `FATAL:` (SC-3's negative
  control).
- Dependency: item 1 (the resume path that carries the artifact directory).

## Item 3 — the surfaces that state the gate state the change's gate (SC-5)

- Deliverable: `tests-v2/with-test-home`'s gate comment states the gate's
  rule and its coverage; `tests-v2/AGENTS.md` §10.7 states the gate's scan
  roots, every named root including the last one, and §14 states the
  unmonitored path truthfully — an unmonitored run writes no determination
  record and attempts no cap-hit resume, so the §10.7 resumption path
  hard-blocks for an unmonitored home and the §10.5 full re-run fallback
  remains its recovery; `skills/behavioral-testing/SKILL.md` rule 9 states
  the gate's rule as the code has it.
- RED: the three surfaces against the code, at the base. No surface names
  the run's artifact directory as a root the gate scans — the base's gate
  scans the runner's `TMP_DIR` and the one root the launcher names, and
  nothing tells a reader that the record's directory is a third place the
  gate must look; and no surface states the gate's rule in full: the base's
  gate comment states the refusal conditions but not that a non-undetermined
  classification permits a resume with no recorded decision, and rule 9
  names only the unmonitored case. A reader of the three surfaces cannot tell
  either which roots the gate scans or what the gate accepts.
- GREEN: the three surfaces rewritten to the code's rule and coverage.
- Verify: read the three files against the code read in items 1 and 2 — each
  statement above is present, and no statement in them describes an
  exemption, a rule, a record, or a recovery route the code does not have.
- Dependency: item 2 (the surfaces state the gate that item 2 changes).

## Item 4 — a goal condition's content pattern is matched as a pattern (SC-6)

- Deliverable: the goal-condition content check in
  `tests-v2/behaviors/helpers.sh` matches the declared pattern with an
  option terminator, so a pattern that begins with `-` — a flag name, a
  path — matches the target's content instead of being read as a grep
  option.
- RED: `grep -q "--json" <file>` exits 2 with `grep: unrecognized option`,
  so the harness's check reads the artifact as not carrying the pattern, the
  run's artifact status is pinned to `partial` for the whole run, and the
  goal condition's completion signal can never fire.
- GREEN: the option terminator in the check.
- Verify: drive the check with a pattern that begins with `-` against a file
  that contains it — the check reports the artifact as present.
- Dependency: none.

## Rollback

Every change is a text edit to tracked files in one repository; the branch is
four commits above the verified trunk tip `a1fb61c6` — one per item, each
committed and pushed before the next begins — so
`git reset --hard a1fb61c6` restores the pre-change state of this change. The
`.opencode#2657` branch is stacked on this one, so a reset here rebases it:
its base moves, and its own commits are replayed onto the reset tip. No change touches
a credential, a deployment surface, or a remote's contents. The harness's own
artifacts live under `tmp/` and are disposable.
