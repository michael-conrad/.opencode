> **Full spec and artifacts: [`{issues_prefix}{N}/`](https://github.com/michael-conrad/.opencode/tree/issues-data/.issues/2457/)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2457/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

# [SPEC] brainstorming terminal-state gate — explicit user finalization required before spec-creation dispatch

## 1. Intent and Executive Summary

1. **Problem Statement:** The brainstorming explore flow's terminal transition ("User approves? → Invoke spec-creation") dispatches the spec-creation pipeline without requiring an explicit user finalization signal. Any affirmative-looking user message (refinement, correction, clarification answer) can be classified by the agent as approval, silently ending requirements exploration.
2. **Root Cause / Motivation:** The Process Flow digraph's "yes" edge in `explore.md` has no definition of what constitutes approval, and `exploration-workflow.md` Step 7 has no gate before the spec-creation dispatch. Observed live 2026-09-21 during brainstorming for .opencode#2456: the agent treated successive design refinements as implicit approval and entered spec-creation. Research card `authorization-session-vs-workflow-state.md` confirms approval must be an unforgeable out-of-band user signal, never agent inference.
3. **Approach Chosen:** Add a HARD GATE at the Step 6 → Step 7 transition in the brainstorming deck defining an explicit finalization signal, classifying refinement/correction/clarification messages as discussion mode (non-finalization), and requiring a recognized user finalization token before dispatching spec-creation. Prove the behavior with a new behavioral enforcement scenario registered in tests-v2.
4. **Alternatives Considered & Why Discarded:** (a) Relying on the existing "Design incrementally approved by user" exit criterion — rejected because it was already in the deck and did not prevent the defect; the criterion states a fact, not an enforceable gate. (b) Reusing the approval-gate `approved`/`go` vocabulary as the finalization token — rejected because design finalization is a discussion-level construct distinct from implementation authorization; conflating them would misroute authorization semantics (concern-map: Authorization vs finalization separation).
5. **Key Design Decisions:** (a) The finalization signal is a discussion-level construct, separate from `approved`/`go` implementation authorization — gate text MUST NOT conflate the two. (b) Gate text lives in the skill deck (ITEM-1 states the rule); enforcement lives in the harness (ITEM-2 proves the behavior) — no enforcement logic in the deck. (c) A new `awaiting_finalization` discussion state is introduced: non-finalization messages hold the agent in that state conversationally. Tradeoff: slightly more conversational friction before spec dispatch, exchanged for user control over when exploration ends.
6. **User Intent / Original Prompt:** Live defect report .opencode#2457 (filed 2026-09-21): "Agent treated design refinements/corrections as implicit approval and dispatched spec-creation without explicit user finalization signal." Developer authorized stacking this spec into existing for_pr work on #2456.

## 2. Not Included

- **Other brainstorming task cards** (`completion.md`, `operating-protocol.md`, `top-down-analysis.md`, `cross-scope.md`, `enforcement.md`) — no terminal-transition logic exists in them; the defect is confined to the explore flow (blast-radius.yaml `unaffected`).
- **spec-creation skill** — `analyze.md` consumes the handoff regardless of source; handoff contract (`handoff.yaml` / `handoff-pointer.yaml`) schema and `design_approved` field are unchanged.
- **approval-gate skill / authorization vocabulary** — `approved`/`go` semantics for implementation authorization are untouched; this spec adds a distinct discussion-level finalization signal.
- **test-harness helper changes** — the new scenario reuses existing `assert_stderr_pattern_present` / `assert_stderr_pattern_absent_all_models` helpers; no helper modification.

## 3. Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | The brainstorming explore deck SHALL define an explicit finalization gate: spec-creation dispatch is permitted ONLY after a recognized user finalization signal; design refinements, corrections, and clarification answers SHALL be classified as non-finalization discussion input, and the agent SHALL remain in discussion mode on such messages. | behavioral (via SC-2) | Behavioral runs of the new enforcement scenario against the gated deck (stderr evidence of dispatch presence/absence) |
| SC-2 | A behavioral enforcement scenario SHALL exist under `.opencode/tests-v2/behaviors/` and be registered in `test-enforcement.sh` (SCENARIOS, SCENARIO_TAGS, FILE_SCENARIO_MAP) proving: (a) a refinement-only user message produces NO spec-creation dispatch, (b) an explicit finalization message permits the spec-creation dispatch. | behavioral | `bash .opencode/tests-v2/test-enforcement.sh --scenario <name>` via `with-test-home opencode run`; stderr-based assertions; registration verified via `--list` / `--list-tags` |

Each SC maps to exactly one item: SC-1 → Item 1, SC-2 → Item 2.

## 4. Requirements

R-1. The explore flow deck (`explore.md` Process Flow + `exploration-workflow.md` Step 7) SHALL define a HARD GATE on the Step 6 → Step 7 transition that requires an explicit user finalization signal before any spec-creation dispatch.
R-2. The gate text SHALL define finalization-signal semantics: a recognized, unforgeable user statement that the discussion is complete and the design is final — never agent inference from message tone or momentum.
R-3. The gate text SHALL classify design refinements, corrections, and answers to clarifying questions as non-finalization discussion input, and SHALL direct the agent to remain in discussion mode (acknowledge, integrate, continue exploring) on such messages.
R-4. The gate text SHALL keep the finalization signal distinct from approval-gate implementation authorization (`approved`/`go`); the two vocabularies SHALL NOT be conflated.
R-5. On any non-finalization user message after design presentation, the agent SHALL hold in the `awaiting_finalization` state and SHALL NOT write handoff artifacts or dispatch spec-creation.
R-6. A behavioral enforcement scenario SHALL exist under `.opencode/tests-v2/behaviors/` following the numbered-scenario pattern (`<issue>-sc<N>-<slug>.sh`) and SHALL be registered in `test-enforcement.sh` SCENARIOS, SCENARIO_TAGS, and FILE_SCENARIO_MAP.
R-7. The enforcement scenario SHALL assert via stderr evidence (run A: refinement-only message → spec-creation dispatch absent, discussion-mode continuation present; run B: explicit finalization message → spec-creation dispatch present).
R-8. The scenario SHALL follow the behavioral variant ordering: RED against the ungated deck, GREEN after ITEM-1, with COMMIT + PUSH preceding the behavioral run (fresh-fetch remote-ref containment verified).

## 5. Items

### Item 1 (SC-1): Finalization gate text in the brainstorming explore deck

- RED: Behavioral run A against the ungated deck (refinement-only message) asserts spec-creation dispatch absent — FAILS because the pre-gate agent dispatches. (RED is delivered by the ITEM-2 scenario run pre-ITEM-1 per dependency DAG; the ITEM-1 commit follows the failing evidence.)
- GREEN: Update `.opencode/skills/brainstorming/tasks/explore.md` (Process Flow digraph finalization gate; Operating Protocol / Exit Criteria / Key Behavioral Constraints) and `.opencode/skills/brainstorming/tasks/explore/exploration-workflow.md` (Step 7 hard gate with finalization-signal definition and non-finalization classification; Exit Criteria wording). Re-run scenario run A → PASS.
- verify: Scenario run A PASS; `grep` confirms gate text present; Read-link pattern used for any cross-references.
- commit: One commit covering both deck files, on the feature branch.

### Item 2 (SC-2): Behavioral enforcement scenario + registration

- RED: New scenario `.opencode/tests-v2/behaviors/<2457-sc1-<slug>>.sh` registered in `test-enforcement.sh`; run A (refinement-only) asserts dispatch absent — fails against the ungated deck.
- GREEN: Scenario passes after ITEM-1 lands (run A absent-assertion PASSES, run B finalization-assertion PASSES). Registration entries added to SCENARIOS, SCENARIO_TAGS, FILE_SCENARIO_MAP following existing brainstorming entries (test-enforcement.sh lines 84-138).
- verify: `bash .opencode/tests-v2/test-enforcement.sh --scenario <name>` PASS (both runs); `--list` / `--list-tags` show the new scenario and tag.
- commit: One commit covering the scenario file + registration entries.

## 6. Dependencies

| Reference | Relationship | Status |
|-----------|--------------|--------|
| `.opencode#2456` (stacked work, for_pr scope) | This spec is stacked into existing for_pr work on #2456; shares the feature branch and PR strategy (stacked) | Satisfied |
| `.opencode/skills/brainstorming/` deck (current state) | Must be read before implementation; the gate modifies its explore flow | Satisfied |
| `.opencode/tests-v2/test-enforcement.sh` | Registration target; existing brainstorming entries (lines 84-138) define the additive pattern | Satisfied |
| Research card `authorization-session-vs-workflow-state.md` | Must be read before implementation; provides the unforgeable-signal / dual-channel model incorporated into the gate design | Satisfied |

## 7. Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-1 | ITEM-1 |
| R-2 | SC-1 | ITEM-1 |
| R-3 | SC-1 | ITEM-1 |
| R-4 | SC-1, SC-2 | ITEM-1, ITEM-2 |
| R-5 | SC-1 | ITEM-1 |
| R-6 | SC-2 | ITEM-2 |
| R-7 | SC-2 | ITEM-2 |
| R-8 | SC-2 | ITEM-2 |

## 8. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|--------------|
| Brainstorming explore flow | code | `.opencode/skills/brainstorming/tasks/explore.md` (Process Flow digraph lines 22-24) | Read + grep (pre-spec-inspection) |
| Exploration workflow | code | `.opencode/skills/brainstorming/tasks/explore/exploration-workflow.md` (Step 7 lines 174-186; hard-gate precedent line 120) | Read + grep (pre-spec-inspection) |
| test-enforcement.sh registration pattern | code | `.opencode/tests-v2/test-enforcement.sh` (SCENARIOS/SCENARIO_TAGS/FILE_SCENARIO_MAP, lines 84-138) | Read (pre-spec-inspection) |
| Approval-gate vocabulary separation | guideline | `.opencode/guidelines/010-approval-gate.md` | Read (pre-spec-inspection) |
| Research card: authorization session vs workflow state | research card | `.opencode/.issues/research-cards/authorization-session-vs-workflow-state.md` | Read (research-card-consultation.yaml) |
| Live defect session evidence | observation | .opencode#2456-adjacent brainstorming session, 2026-09-21 | Session evidence review (defect_source in pre-spec-inspection.yaml) |

## 9. Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## 10. Cost Frame

- **SC-1:** Reading and revising the two deck files costs minutes — a bounded text edit at an existing hard-gate precedent (exploration-workflow.md line 120). Skipping costs an entire silent pipeline entry per brainstorming session — the agent dispatches spec-creation on inferred approval, and requirements defects surface at implementation review, multiplied by every future brainstorming conversation. An ungated terminal transition means the user's control over when exploration ends is a suggestion the agent can route around.
- **SC-2:** Writing the scenario + registration costs one behavioral run pair (run A / run B) via `with-test-home opencode run`. Skipping costs a gate that exists only as prose — a rule change with no behavioral test is documentation, not enforcement, and the next agent silently bypasses it. A lobotomized or absent assertion converts the defect from "detected" to "permanently latent."

Correctness is the only metric; verification cost is never a factor in whether these gates run.

## 11. Edge Cases

| Condition | Expected behavior | Resolution |
|-----------|-------------------|------------|
| User answers a clarifying question after design presentation | Classified as non-finalization; agent responds conversationally, holds `awaiting_finalization` | Gate text enumerates clarification answers as non-finalization (R-3) |
| User sends a correction to the design | Classified as design input; agent integrates and continues discussion mode | Non-finalization classification (R-3); state-analysis `awaiting_finalization → awaiting_finalization` |
| User says "approved"/"go" (implementation authorization) during discussion | NOT treated as design finalization — vocabulary kept distinct (R-4); agent still awaits the finalization signal before dispatch | Concern-map separation rule; gate text cross-references via Read-link, never conflates |
| Agent receives ambiguous message (part refinement, part closing remark) | Agent MUST NOT infer finalization; treats as discussion input and may re-ask for the finalization signal | Unforgeable-signal rule (R-2); research card dual-channel model |
| Session resumes mid-brainstorming after merge | Agents mid-flow encounter the new gate — behavior change is the intended ripple (blast-radius.yaml `ripple_effects`) | No migration shim; gate applies to all in-flight sessions |
| Scenario harness failure (timeout, lock contention) | FAIL verdict with remediation per tests-v2 AGENTS.md §10/§17/§18; never a PASS-by-substitution | critical-rules-060; test-integrity mandate |
| Handoff artifacts | Written ONLY at the gated transition, exactly as today — no persistent-state change | state-analysis `persistent_state_affected: none` |
