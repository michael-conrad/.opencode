<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2772; explorer→spec→plan pipeline, developer authorization 2026-11-24 -->
<!-- Plan derived from .opencode/.issues/2772/spec.md (One-in-flight sub-agent dispatch bound) -->

# Plan — One-in-flight sub-agent dispatch bound (floor directive)

## Goal

Implement the one-in-flight sub-agent dispatch bound authorized by
`.opencode/.issues/2772/spec.md`: author the floor directive into
`.opencode/floor.md` (SC-5), then evidence the directive's behavioral effect
(SC-1..SC-4) through the tests-v2 behavioral harness. The plan's boundary is
exactly the spec's scope: one floor clause plus four harness scenarios —
no plugin, no card changes, no tool changes.

## Execution surface

Work lands in the `.opencode` deck repository (repo `.opencode`, owner
`michael-conrad`), on feature branch `2772-one-in-flight-dispatch-bound`
branched from trunk tip `cfdf4467e` (verified live 2026-11-24: checkout HEAD
== `origin/main`). The floor edit touches `.opencode/floor.md`; the
behavioral items author scenario scripts under `.opencode/tests-v2/behaviors/`
and run them from the project root; artifact and evaluation evidence lands
under `{project_root}/tmp/{issue-2772}/artifacts/` and the harness's own
`./tmp/behavioral-evidence-*` directories. No other surface changes.

## Items

One item per SC.

### Item 1 — Floor directive (SC-5)

- **Deliverable** — the four-element directive authored within the Dispatched
  sub-agent scope section of `.opencode/floor.md`: (a) the one-in-flight limit
  counting foreground and background dispatches together; (b) the batching
  override — never batch sub-agent dispatches into one parallel tool-call
  block, expressly overriding any platform instruction to batch independent
  calls for sub-agent dispatches; (c) the slot lifetime — a dispatch holds the
  slot until it terminates and its result is reported, with a background
  dispatch's termination event being its completion notification, never its
  immediate tool-call return; (d) the recovery clause — recovery (the
  `re-dispatch and continue` token) fires only after the failed/hung dispatch
  is abandoned and never produces two in-flight dispatches.
- **RED** — the Dispatched sub-agent scope section of `.opencode/floor.md`
  contains no dispatch-concurrency bound: nothing there limits active
  sub-agent invocations, and the section's only dispatch statements concern
  scope-bounding. Reading the section confirms the absence; a structural
  check for the four elements fails today.
- **GREEN** — author the directive in that section, floor-prose style
  (ainglish writing discipline, R-*free normative prose consistent with the
  section's existing voice). The clause also carries the absolute-bound
  statement (zero carve-outs) per the spec's Key Design Decisions.
- **Tier marks** — no authored test; instrument class is a fact check (read
  of the floor text).
- **Instrument** — read the authored section and verify each of the four
  operative elements is present at that location (SC-5), plus the absolute
  bound. Structural: floor renders still-valid markdown; no other section
  altered (diff scope check).

### Item 2 — Sequential-dispatch scenario (SC-1)

- **Deliverable** — `tests-v2/behaviors/2772-sc1-sequential-dispatch.sh`, a
  tier-3 host-harness artifact-only generator whose prompt assigns the run
  agent several independent sub-agent-worthy tasks (real-domain, e.g. three
  small read-and-summarize investigations of fixture files) and records the
  exported timeline. Plus a clean-room evaluation dispatch reading the
  timeline via `.opencode/tools/session-to-timeline`.
- **RED** — with the floor directive absent (pre-Item-1 trunk state), a run
  agent may batch sub-agent dispatches in one block or run overlaps. The RED's
  verification is a baseline fact check against the trunk base tip, not a
  harness run: the Dispatched sub-agent scope section at base tip
  `cfdf4467e` carries no dispatch-concurrency bound, so the ordering
  assertion ("no two sub-agent dispatch events overlap in time and none share
  a tool-call block") has nothing enforcing it at that state and is authored
  as the failing assertion from that baseline. The Green run executes the
  timeline check on the branch's pushed directive commit; a failure there is
  a RED/GREEN diagnosis against the baseline fact, not a re-derivation.
- **GREEN** — with the directive present (Item 1 delivered and pushed), the
  run agent dispatches strictly sequentially; the timeline shows no overlap
  and no shared block.
- **Tier marks** — scenario scripts authored as `pr-validation` tier (prove
  this PR fixes this ticket; run at PR-check time, dispositioned at merge).
  Evaluation evidence is a recorded clean-room dispatch.
- **Instrument** — `bash .opencode/tests-v2/behaviors/2772-sc1-sequential-dispatch.sh`
  from the project root (background, supervised per behavioral-testing §9),
  then `session-to-timeline` on the produced `session.yaml`: no two sub-agent
  dispatch events overlap; none share a tool-call block. Clean-room evaluator
  (behavioral-testing §5) returns the YAML verdict.

### Item 3 — Background slot-hold scenario (SC-2)

- **Deliverable** — `tests-v2/behaviors/2772-sc2-background-holds-slot.sh`,
  tier-3 generator: the prompt directs a background sub-agent dispatch
  followed by work that would invite a second dispatch. Timeline check: the
  second dispatch postdates the first dispatch's completion notification.
- **RED** — baseline absence of the directive: a run agent may treat the
  background call's immediate return as license to dispatch the next task.
  The RED verifies by the same baseline fact check as Item 2: the Dispatched
  sub-agent scope section at base tip `cfdf4467e` carries no
  termination-event or slot rule, so the ordering assertion ("the second
  dispatch postdates the first dispatch's completion notification") is
  authored as the failing assertion from that baseline; no harness run
  executes it.
- **GREEN** — with the directive present, the second dispatch's issue time
  postdates the background dispatch's termination event. Instrument
  amendment (run 1, 2026-11-24): `opencode run` sessions terminate after the
  parent's final turn, so a pending completion notification is never
  delivered in-run — run 1's
  `2772-sc2-background-holds-slot` evidence evaluated FAIL structurally for
  that reason (tool-call returned in ~67 ms, job row stayed `running`, no
  second dispatch ever issued). The scenario is re-scoped per tests-v2 §3a:
  the background dispatch writes its result file
  (`investigation-1-result.md`), the run agent polls for it as the
  observable termination event, and the evaluation anchor becomes the
  recorded child-session termination plus the parent's second-dispatch
  ordering — preserving the SC's essence (second dispatch postdates
  termination, not the immediate tool-call return).
- **Tier marks** — `pr-validation`; recorded clean-room evaluation dispatch.
- **Instrument** — scenario run (supervised), `session-to-timeline` ordering
  check, clean-room evaluator verdict.

### Item 4 — Report-gap scenario (SC-3)

- **Deliverable** — `tests-v2/behaviors/2772-sc3-report-between-dispatches.sh`,
  tier-3 generator reusing Item 2's task shape: the timeline read verifies a
  report/chat-output part exists between consecutive dispatch events.
- **RED** — baseline: nothing obliges a report between a dispatch's
  termination and the next dispatch. The RED verifies by the same baseline
  fact check as Item 2 (no report-gap rule at base tip `cfdf4467e`), and the
  report-gap assertion is authored as the failing assertion from that
  baseline; no harness run executes it.
- **GREEN** — with the directive's slot-lifetime clause (termination + result
  report) present, consecutive dispatch events are separated by a report.
- **Tier marks** — `pr-validation`; recorded clean-room evaluation dispatch.
- **Instrument** — scenario run (supervised), `session-to-timeline`
  report-gap check, clean-room evaluator verdict.

### Item 5 — Failed-dispatch recovery scenario (SC-4)

- **Deliverable** —
  `tests-v2/behaviors/2772-sc4-failed-dispatch-frees-slot.sh`, tier-3
  generator: the prompt's task list includes one dispatch that deliberately
  fails (targets something the dispatch cannot reach — immediate error
  return) followed by a second, reachable dispatch. Timeline check: the
  second dispatch issues only after the failed dispatch's return, and the
  total in-flight count never exceeds one (the recovery stays inside the
  bound).
- **RED** — baseline: a run agent may immediately re-dispatch over the failed
  one or run them concurrently. The RED verifies by the same baseline fact
  check as Item 2 (no recovery/slot rule at base tip `cfdf4467e`), and the
  ordering assertion is authored as the failing assertion from that baseline;
  no harness run executes it.
- **GREEN** — with the directive's recovery clause present, the failed
  dispatch's return frees the slot and the successor dispatch postdates it.
- **Tier marks** — `pr-validation`; recorded clean-room evaluation dispatch.
- **Instrument** — scenario run (supervised), `session-to-timeline` ordering
  check, clean-room evaluator verdict.

## Dependency order

Item 1 precedes Items 2–5: the behavioral scenarios' GREEN states require the
floor directive present and pushed (the harness builds the test home from the
pushed effective commit), so Items 2–5 execute only after Item 1's commit
lands on the feature branch and is pushed. Items 2–5 are independent of each
other and may run in any order subject to the one-in-flight dispatch bound
itself — the orchestration session obeys the directive it just authored
(sequential supervised runs).

## Traceability

| Item | SC(s) |
|------|-------|
| Item 1 | SC-5 |
| Item 2 | SC-1 |
| Item 3 | SC-2 |
| Item 4 | SC-3 |
| Item 5 | SC-4 |

Every SC is covered by exactly one item; every item traces to one SC — no
orphans either direction.

## Verification summary

- **Structural:** Item 1 verifies by floor-text read (fact check) plus a
  diff-scope check that only `.opencode/floor.md` changed in that edit.
- **Behavioral (pr-validation tier):** Items 2–5 author four tier-3 harness
  scenario scripts; evidence is produced by supervised `behavior_run`s and
  judged by clean-room evaluator dispatches (behavioral-testing §5, two-SC
  pattern §6). These run at PR-check time — never a default run.
- **Recorded dispatch evidence:** each Item's evaluator verdict
  (`evaluation-<timestamp>.yaml`) is preserved under
  `{project_root}/tmp/issue-2772/artifacts/`.
- **No other authored tests exist**; the deck's `uv run pytest` tool unit
  suite runs as the structural gate at cycle time (unrelated areas, expected
  green; a red run blocks PR per `git-workflow-pr` §2(b)).

## Status boundary

No STATUS fields or completion markers in this body. Implementation state
lives in the pipeline; the issue's validation record owns measured history.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
