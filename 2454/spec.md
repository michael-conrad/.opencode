> **Full spec and artifacts: [`.opencode/.issues/2454/`](https://github.com/michael-conrad/.opencode/tree/issues-data/.issues/2454/)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.

# Spec — .opencode#2454: Orchestrator-direct plan execution — task() only at plan-marked dispatch points

## 1. Intent and Executive Summary

| # | Field | Content |
|---|-------|---------|
| 1 | **Problem Statement** | Plan execution under `executing-plans` is described as orchestrator-direct, but the deck does not verifiably enforce that direct plan steps are executed by the orchestrator with its own tool calls, and that `task()` dispatch happens only at steps the plan explicitly marks for dispatch. Unverified description permits wholesale delegation of plan steps to sub-agents. |
| 2 | **Root Cause / Motivation** | The dispatch vocabulary was retired repo-wide (`inline` → `direct`; `sub-agent`/`clean-room` → `task-card`), and the executing-plans deck already states the intended behavior — but no spec or verification pins that behavior as enforced rather than merely described. Wholesale delegation also violates allocation-by-context-cost and breaks the pre-flight guard's reason-code contract. |
| 3 | **Approach Chosen** | Formalize the mandate across the executing-plans skill deck (SKILL.md, execute-phase.md, read-plan.md) and verify the pre-flight guard backstop, using behavioral evidence (`opencode run` via `with-test-home`) rather than structural substitutes. |
| 4 | **Alternatives Considered & Why Discarded** | (a) Treat the deck as already correct and close the issue without verification — discarded: description without verified enforcement is decoration; behavior is runtime-behavioral and demands behavioral evidence. (b) Extend the producer side (writing-plans plan-artifact-format dispatch indicator grammar) — discarded: the producer interface is already defined and stable; changing it would be breaking with no identified defect. |
| 5 | **Key Design Decisions** | Executor-side-only scope (executor vs producer vs guard are distinct concerns per the concern map). Behavioral evidence type for all SCs — the change affects what the agent DOES at runtime, so structural/string evidence is EVIDENCE_TYPE_MISMATCH. Existing dispatch indicator grammar (`(**direct**)` / `(**task-card**)`, default `direct`) is consumed as-is. |
| 6 | **User Intent / Original Prompt** | Issue title: "Orchestrator-direct plan execution — task() only at plan-marked dispatch points" (.opencode#2454, body empty at intake). |

## 2. Not Included

- **Producer-side plan format changes** — the dispatch indicator grammar in the plan artifact format reference already defines the consumer contract; no producer defect was identified.
- **Pre-flight guard semantics changes** — the guard's return codes (`ORCHESTRATOR_ONLY_PLAN` / `ORCHESTRATOR_ONLY_SKILL_CARD`) are only verified, not redesigned.
- **Other skills' dispatch routing** — the retired dispatch vocabulary is already retired repo-wide; only the executing-plans deck is in scope.

## 3. Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | The executing-plans skill deck SHALL mandate that direct plan steps are executed by the orchestrator with its own tool calls. | behavioral | `opencode run` via `with-test-home` on a plan-execution scenario; assert via stderr agent actions that the orchestrator performs own tool calls on direct steps. |
| SC-2 | The executing-plans skill deck SHALL prohibit wholesale delegation of plan steps: forwarding plan body or whole-phase content into a `task()` prompt SHALL NOT occur during plan execution. | behavioral | `opencode run` via `with-test-home` on a plan-execution scenario; assert via stderr agent actions the absence of whole-plan/whole-phase forwarding. |
| SC-3 | The executing-plans skill deck SHALL restrict `task()` dispatch to exactly the plan steps that mark dispatch (`task-card` mode); unmarked or `(**direct**)` steps SHALL NOT be dispatched to sub-agents. | behavioral | `opencode run` via `with-test-home` on a mixed direct/task-card plan scenario; assert dispatch occurs only at `task-card`-marked steps. |
| SC-4 | A sub-agent that receives plan content or skill-card content SHALL return BLOCKED with `ORCHESTRATOR_ONLY_PLAN` / `ORCHESTRATOR_ONLY_SKILL_CARD` respectively (pre-flight guard backstop verified end-to-end). | behavioral | `opencode run` via `with-test-home` guard scenario; assert BLOCKED reason codes in sub-agent output. |

**SC-4 dual reason-code justification:** `ORCHESTRATOR_ONLY_PLAN` and `ORCHESTRATOR_ONLY_SKILL_CARD` are retained in a single SC because both are emitted by one mechanism (the pre-flight guard backstop) verified end-to-end by one behavioral scenario; they are output variants of the same guard contract, not independent success criteria.

## 4. Requirements

R-1. The executing-plans skill deck SHALL state that plan execution is orchestrator-direct: the orchestrator executes plan steps in its own context, and dispatches a step's task card via `task()` only where the step marks dispatch.

R-2. The executing-plans task cards (read-plan, execute-phase) SHALL instruct per-step dispatch-mode execution: `(**direct**)` and unmarked steps are executed by the orchestrator; only `(**task-card**)`-marked steps are dispatched.

R-3. The skill deck and task cards SHALL prohibit forwarding plan body, whole-phase, or whole-workflow content in `task()` prompts.

R-4. The pre-flight guard backstop SHALL be verified to return `ORCHESTRATOR_ONLY_PLAN` when plan content reaches a sub-agent and `ORCHESTRATOR_ONLY_SKILL_CARD` when skill-card content reaches a sub-agent.

R-5. SC verification SHALL use runtime-behavioral evidence (`opencode run` via `with-test-home`, stderr agent actions); structural or string substitutes SHALL NOT be accepted.

## 5. Items

### Item 1 (SC-1): Orchestrator own-tool-call execution on direct steps

- RED: Behavioral scenario run via `opencode run` (with-test-home) where an agent executes a direct-step plan; assert the orchestrator reads the plan itself and executes direct steps with own tool calls — assertion fails against the current unverified state.
- GREEN: Tighten SKILL.md / execute-phase.md wording so the positive own-tool-call execution mandate is explicit; no structural rewrite (deck already states the behavior).
- verify: Re-run the behavioral scenario; assert own-tool-call execution on direct steps.
- commit: One commit covering SKILL.md + task-card wording changes and the behavioral scenario.

### Item 2 (SC-2): Forwarding prohibition (no wholesale delegation)

- RED: Behavioral scenario run via `opencode run` (with-test-home) where an agent executes a plan; assert the absence of whole-plan/whole-phase forwarding into `task()` prompts — assertion fails against the current unverified state.
- GREEN: Tighten SKILL.md / execute-phase.md wording so the forwarding prohibition (no wholesale delegation of plan steps) is explicit; no structural rewrite.
- verify: Re-run the behavioral scenario; assert absence of whole-plan/whole-phase forwarding.
- commit: One commit covering SKILL.md + task-card wording changes and the behavioral scenario.

### Item 3 (SC-3): Dispatch restricted to plan-marked (`task-card`) steps

- RED: Behavioral scenario on a mixed `(**direct**)` / `(**task-card**)` plan; assert dispatch only at marked steps — fails against current state.
- GREEN: Make per-step dispatch-mode language in execute-phase.md unambiguous (direct default; task-card only at marked steps).
- verify: Re-run scenario; assert zero dispatches on direct steps, dispatch on task-card steps only.
- commit: One commit covering execute-phase.md wording + scenario.

### Item 4 (SC-4): Pre-flight guard backstop verified end-to-end

- RED: Behavioral guard scenario where plan/skill-card content reaches a sub-agent; assert BLOCKED with reason code — fails if guard path is unverified.
- GREEN: No guard semantics change; verify and align SKILL.md references to the guard reason codes (guideline 023 canonical definition).
- verify: Re-run guard scenario; assert `ORCHESTRATOR_ONLY_PLAN` / `ORCHESTRATOR_ONLY_SKILL_CARD` in sub-agent output.
- commit: One commit covering guard-verification scenario + any wording alignment.

## 6. Dependencies

| Reference | Relationship | Status |
|-----------|--------------|--------|
| writing-plans/reference/plan-artifact-format.md | Defines the dispatch indicator grammar the executor consumes; must be read before implementation | Satisfied (exists, stable) |
| guideline 023 (pre-flight guard canonical reference) | Guard reason codes verified by SC-4 derive from this definition | Satisfied |
| `.opencode/tests-v2/with-test-home` | Required harness for all behavioral verification | Satisfied |

## 7. Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-1 | Item 1 |
| R-2 | SC-3 | Item 3 |
| R-3 | SC-2, SC-3 | Item 2, Item 3 |
| R-4 | SC-4 | Item 4 |
| R-5 | SC-1, SC-2, SC-3, SC-4 | Item 1, Item 2, Item 3, Item 4 |

## 8. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|--------------|
| executing-plans SKILL.md | code | `.opencode/skills/executing-plans/SKILL.md` | Read (pre-spec inspection, 2026-09-20) |
| execute-phase task card | code | `.opencode/skills/executing-plans/tasks/execute-phase.md` | Read (pre-spec inspection) |
| read-plan task card | code | `.opencode/skills/executing-plans/tasks/read-plan.md` | Read (pre-spec inspection) |
| plan artifact format reference | doc | `.opencode/skills/writing-plans/reference/plan-artifact-format.md` | Read (pre-spec inspection) |
| Pre-flight guard canonical reference | doc | `.opencode/guidelines/023-pre-flight-guard.md` | Read (index) |

## 9. Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## 10. Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- **SC-1:** Running the plan-execution behavioral scenario costs minutes — a bounded delay that catches wholesale-delegation defects at the earliest gate. Skipping costs the full pipeline of rework when mis-dispatched plan execution surfaces downstream — hours to days of diagnosis and re-review, compounded by every plan executed under the unenforced deck.
- **SC-2:** Verifying the forwarding-prohibition behavioral scenario costs minutes — it pins the no-wholesale-delegation boundary at the same gate as SC-1. Skipping costs the same downstream rework when plan bodies are silently forwarded into sub-agent contexts.
- **SC-3:** Running the mixed-dispatch scenario costs minutes — it pins the direct/task-card boundary before any consumer depends on it. Skipping costs hours-to-days of downstream rework when direct steps get silently dispatched and context isolation breaks.
- **SC-4:** Running the guard-backstop scenario costs minutes — it verifies the reason-code contract end-to-end. Skipping costs the loss of the only mechanical backstop against skill-card/plan forwarding, whose failure surfaces only after sub-agent context contamination has already propagated — a 100×+ escalation by the tiered cost table.

## 11. Edge Cases

- **Condition:** A plan step is unmarked (no dispatch indicator). **Expected behavior:** It is treated as `direct` (default per plan artifact format) and executed by the orchestrator. **Resolution:** Grammar default; no ambiguity.
- **Condition:** A plan contains zero dispatch-marked steps. **Expected behavior:** The entire plan executes orchestrator-direct with zero `task()` calls. **Resolution:** Valid state; not an error.
- **Condition:** The behavioral harness (`with-test-home`) fails or times out. **Expected behavior:** The SC verdict is FAIL with diagnosis (R-18 cause analysis); structural substitutes are prohibited. **Resolution:** Remediate harness, re-run.
- **Condition:** Plan content reaches a sub-agent despite the deck's prohibition. **Expected behavior:** Pre-flight guard returns BLOCKED `ORCHESTRATOR_ONLY_PLAN`. **Resolution:** Guard backstop is the defense in depth verified by SC-4.
- **State boundaries:** Transitions `plan_not_read → plan_read → executing_phase → phase_complete` are unchanged by this spec; the mandate constrains behavior only within `executing_phase`.

## 12. Change Control

| Date | Change | Reason | Authorized By |
|------|--------|--------|---------------|
| 2026-09-20 | Initial spec | — | Spec-creation pipeline (spec-creation-validation) |
| 2026-09-20 | Revision: (1) decomposed compound SC-1 into atomic SC-1 (positive own-tool-call execution) and SC-2 (negative forwarding prohibition); renumbered prior SC-2→SC-3 and SC-3→SC-4 across SC table, items, traceability, cost frame, edge cases. (2) Normalized `MUST NOT` → `SHALL NOT` per spec-structure-standards (R-2, R-3, R-5, SC-3). (3) Stripped discretion hedges: "where applicable" (Item 1 RED) and "if needed" (Item 3 GREEN). (4) Kept SC-4 (guard) as one SC with dual reason codes — single mechanism justification added to §3. Updated sc-summary.yaml (sc_count 3→4) and item mappings consistently. | Validation findings from spec-creation-validation | Developer-issued revise dispatch (validation_findings) |
| 2026-09-20 | Revision: (1) split §5 Item 1 (which covered both SC-1 and SC-2) into two items — Item 1 (SC-1, own-tool-call execution) and Item 2 (SC-2, forwarding prohibition) — each with its own RED/GREEN/verify/commit cycle; renumbered downstream items (SC-3→Item 3, SC-4→Item 4). Updated sc-summary.yaml plan_item mappings (SC-1→1, SC-2→2, SC-3→3, SC-4→4), traceability Phase column, and cost frame consistently. (2) Restored the 10 analytical artifacts from `tmp/2454/artifacts/` to `.opencode/.issues/2454/artifacts/` (directory was absent). (3) Fixed cosmetic traceability Phase column (item numbers, not P1 phase labels). | Validation findings (HARD FAIL: 1 SC per item; WARNING: missing artifacts directory) | Developer-issued revise dispatch (validation_findings) |
