> **Full spec and artifacts: [`.opencode/.issues/2451/`](https://github.com/michael-conrad/.opencode/tree/issues-data/.issues/2451/)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2451/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

# [SPEC] One-dispatch-one-step gate — prohibit combined dispatches for discrete steps

## 1. Intent and Executive Summary

- **Problem Statement:** Combined dispatches were observed in production: session `ses_f5aa152f7ffeeEzOm66Lr2Gbs6` (issue 2432) recorded 22 combined "Two sequential tasks" task() dispatches, including framing a multi-SC verification as a "combined effectiveness run," and an SC-09 re-dispatch loop of 14+ attempts over ~44 hours. No rule in the agent deck prohibits a task() dispatch from carrying more than one discrete workflow step, so each combined dispatch passed every gate on its way to destroying the per-step micro feedback loop (dispatch → result contract → route → next dispatch) and making step-level failure attribution impossible.
- **Root Cause / Motivation:** Three gaps compound. (a) The procedural-discipline reference card (257) has no canonical pattern for dispatch cardinality — nothing an agent loads names "one dispatch = one discrete step." (b) 091's "Batching items" anti-pattern polices item-level batching (multiple SCs in one implementation item) but never the dispatch-level shape (multiple steps in one task() call). (c) `.opencode/tests-v2/AGENTS.md` §15's economy wording — "one run per SC-RED need and one run per SC-GREEN need" — was inverted into a combination justification: an agent read "one run per need" as sanctioning one run serving two SCs' needs ("combined effectiveness run"), and §6a never states that the clean-room evaluation is a separate dispatch from the artifact-generation run. The defect is structural, not reasoning-classification: the observed dispatches were rationalized as efficient, economical, and harmless — the violation is the dispatch shape itself, no matter the reasoning.
- **Approach Chosen:** A six-part package implementing the developer-approved design from the 2026-09-17 brainstorming session. Part 1 adds canonical pattern p-dis-007 "One-Dispatch-One-Step Gate" to 257 via that card's §11 add-pattern procedure. Part 2 places a Tier 1 bright-line in 091 (always loaded — present at the moment the dispatch decision is made) extending the "Batching items" anti-pattern to the dispatch level with the no-exceptions clause. Part 3 extends critical-rules-034 in 022 to cover all combined-dispatch shapes at the dispatch level. Part 4 closes the §15/§6a loophole in tests-v2/AGENTS.md. Part 5 adds the behavioral scenario using the §6a two-SC pattern (artifact-generation run + separate clean-room semantic evaluation of session.yaml). Part 6 adds a content-verification scenario for rule-text placement. Each part maps to its own success criteria; behavioral evaluation is semantic, never marker-based.
- **Alternatives Considered & Why Discarded:**
  - **Tier-2-only placement in 022 (the prior spec's approach) — discarded by developer rejection:** 022 is not loaded at the dispatch decision moment; 091 is Tier 1 and always loaded, so the bright-line must live there. 022 still gets the dispatch-level extension (Part 3), but as an extension of its existing rule, not the sole home.
  - **Standalone new gate rule in 022 rather than extending critical-rules-034 — superseded:** the approved design extends 034 (which already polices sub-agent-internal analyze+write+verify combination) to cover dispatch-level shapes, keeping one rule family for all combining violations.
  - **stderr-based behavioral assertions (the prior spec's SC-3 method) — discarded:** forbidden by `.opencode/tests-v2/AGENTS.md` §2 — session.yaml is the PRIMARY evaluation source; stderr/stdout assertion helpers are prohibited for behavioral SC evaluation. The behavioral SCs use the §6a two-SC pattern instead.
  - **Static marker gates on dispatch prose (marker lists, expected phrases) — discarded, developer directive:** static gates on dispatch prose are escape hatches — the agent detects and subverts marker vocabularies. Enforcement of the behavioral SC is clean-room semantic evaluation only. This constraint is recorded in Key Design Decisions and is non-waivable within this spec.
  - **Mechanical enforcement (plugin/hook scanning task() prompts) — discarded:** task()-prompt content is not mechanically observable at this repo's enforcement layer, and mechanical/marker-based enforcement is prohibited as an escape hatch per the developer directive; behavioral tests are the enforcement vehicle.
- **Key Design Decisions:**
  - **Six-part package, 1:1 SC mapping (developer-approved design, 2026-09-17):** the SC set covers exactly the six parts — Part 5 expands into two SCs because the §6a two-SC pattern mandates artifact generation and clean-room evaluation as separate SCs. No SC spans multiple parts.
  - **Structural, not reasoning-classification:** the rule's violation is defined by dispatch shape (a dispatch carrying more than one discrete step — two task cards, run+verify, multi-SC verification, Task A/Task B packing, "combined effectiveness run"), never by the agent's justification. The no-matter-the-reasoning clause appears in all three rule texts (257 p-dis-007, 091 bright-line, 022 extension).
  - **No-static-gates constraint (developer directive):** mechanical/marker-based enforcement of the behavioral SC is prohibited as an escape hatch. The clean-room evaluator receives only the criterion and session.yaml — no marker lists, no expected phrases, no static gates.
  - **Canonical pattern home is 257; 091 and 022 reference, never redefine.** p-dis-007 is added via 257's §11 add-pattern procedure (catalog row, selection matrix entry, canonical formula, co-application with 250/255, auto-detection, version tracking, research basis); 091 and 022 carry their own placement-appropriate text and Read-link to the pattern (Read-link mandate — never "see" citations).
  - **091 is Tier 1 (rationale per approved design):** 091 is always loaded into the agent's system instructions, so the bright-line is present at the moment the dispatch decision is made. The prior spec's Tier-2-only decision contradicted the approved design and is reversed.
  - **"Discrete step" anchored to existing vocabulary (preserved from prior spec):** a task-card plan step (a plan step marked `task-card`) or a workflow-marked sub-task dispatch. No new vocabulary; the definition inherits executing-plans semantics and stays testable.
  - **Architecture B preserved (carried from prior spec):** direct-mode execution in the orchestrator's own context remains sanctioned; the gate constrains task() dispatch cardinality only.
  - **Corrective action preserved (carried from prior spec):** on violation, decompose the bundle and re-dispatch one discrete step at a time.
  - **Empirical RED evidence, not fabricated:** 22 combined "Two sequential tasks" dispatches in production session `ses_f5aa152f7ffeeEzOm66Lr2Gbs6` are preserved as observed RED evidence for the behavioral scenario; the scenario does not re-fabricate RED runs.
  - **Cards mirror by Read-link reference, never redefinition (carried from prior spec):** one extra hop at read time versus divergent inline variants across cards.
- **User Intent / Original Prompt:** Local issue `.opencode#2451` created 2026-09-17 with title only (body empty): "[SPEC] One-dispatch-one-step gate — prohibit combined dispatches for discrete steps". Revised 2026-09-17 per developer rejection: implement exactly the six-part developer-approved design from the brainstorming session.

## 2. Not Included

- **Dispatch-mode marking changes** — which steps are marked `direct` vs `task-card` is unchanged; the gate constrains only per-dispatch cardinality.
- **Canonical dispatch string mechanism** — the verbatim Invocation canonical-string mechanism is consumed as-is; the gate adds no new string format.
- **Replacement of critical-rules-034's existing coverage** — the 022 extension (Part 3) adds dispatch-level shapes to the rule's existing sub-agent-internal analyze+write+verify coverage; nothing is removed.
- **Marker vocabularies or static gates for behavioral evaluation** — prohibited per the developer directive; the clean-room evaluator receives only the criterion and session.yaml.
- **stderr/stdout assertion helpers for behavioral SC evaluation** — prohibited by tests-v2/AGENTS.md §2; session.yaml is the PRIMARY evaluation source.
- **Plugin/hook mechanical enforcement** — not mechanically observable at this repo's enforcement layer, and prohibited as an escape hatch; behavioral tests are the enforcement vehicle.
- **Parallel dispatch introduction** — one-at-a-time sequential dispatch remains the model; parallel is opportunistic, never default.
- **Other skills' DISPATCH_GATE sections** — blast radius is contained to 257, 091, 022, tests-v2/AGENTS.md, and the test suite; other skill cards' DISPATCH_GATE sections are untouched.

## 3. Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Documentation Sources |
|---|---|---|---|---|
| SC-1 | `.opencode/guidelines/257-procedural-discipline-reference.md` contains canonical pattern p-dis-007 "One-Dispatch-One-Step Gate," added per that card's §11 add-pattern procedure: catalog row, selection matrix entry, canonical formula, co-application with 250/255, auto-detection trigger, version tracking, research basis. Bright-line content: one dispatch = one discrete step; a task() dispatch carrying more than one discrete step (two task cards, run+verify, multi-SC verification, Task A/Task B shapes, "combined effectiveness run") is a violation no matter the reasoning; the rule is structural, not reasoning-classification. | string | grep-class content-verification assertion over 257 for the pattern ID, the §11 procedure artifacts, and the no-matter-the-reasoning clause | `.opencode/guidelines/257-procedural-discipline-reference.md` (§11 "Adding New Patterns", verified 2026-09-17); developer-approved design 2026-09-17 |
| SC-2 | `.opencode/guidelines/091-incremental-build.md` extends the existing "Batching items" anti-pattern into an explicit dispatch-level rule with the no-exceptions clause, plus a Read-link to the 257 p-dis-007 pattern (Read-link mandate form, never "see" citations). The rule is Tier 1 (091 is always loaded — present at the moment the dispatch decision is made). | string | grep-class assertions over 091 for the dispatch-level extension, the no-exceptions clause, and the `Read [Text](path)` link to 257 p-dis-007; absence of "see"-style citations to the pattern | `.opencode/guidelines/091-incremental-build.md`; `.opencode/guidelines/257-procedural-discipline-reference.md` |
| SC-3 | `.opencode/guidelines/022-orchestrator-context-discipline.md` extends critical-rules-034 — which currently polices only sub-agent-internal analyze+write+verify combination — to cover ALL combined-dispatch shapes at the dispatch level (run+verify in one task(), cross-SC verification runs, Task A/Task B packing) with the no-matter-the-reasoning clause and a Read-link to 257 p-dis-007. Existing sub-agent-internal coverage is preserved, not replaced. | string | grep-class assertions over 022 for the dispatch-level shapes, the no-matter-the-reasoning clause, and the Read-link to p-dis-007; consistency read against the pre-extension 034 text (extension, not replacement) | `.opencode/guidelines/022-orchestrator-context-discipline.md`; `.opencode/guidelines/257-procedural-discipline-reference.md` |
| SC-4 | `.opencode/tests-v2/AGENTS.md` closes the combined-run loophole: §15 Targeted Behavioral-Test Execution Mandate clarifies that "one run per SC-RED need and one run per SC-GREEN need" CANNOT be satisfied by combining two SCs' needs into one run — a combined run violates the mandate instead of satisfying it; §6a two-SC pattern states explicitly that the clean-room evaluation is a SEPARATE dispatch from the artifact-generation run. | string | grep-class assertions over tests-v2/AGENTS.md §15 for the cannot-combine clarification and §6a for the separate-dispatch sentence | `.opencode/tests-v2/AGENTS.md` (§6a, §15 — verified 2026-09-17) |
| SC-5 | A behavioral scenario in `.opencode/tests-v2/behaviors/` produces, via a real-model opencode run against a multi-step-plan prompt, the artifact-generation session for the two-SC pattern (§6a SC-N). RED evidence already exists and is preserved as observed: 22 combined "Two sequential tasks" dispatches in production session `ses_f5aa152f7ffeeEzOm66Lr2Gbs6` — the scenario documents this observed evidence and does not fabricate RED runs. | behavioral | `bash .opencode/tests-v2/with-test-home opencode run '<multi-step-plan prompt>'` (>=600s timeout); session.yaml exported and preserved as the evaluation input; no structural substitution | `.opencode/tests-v2/AGENTS.md` (§2 Evaluation Source, §6a two-SC pattern); observed session `ses_f5aa152f7ffeeEzOm66Lr2Gbs6` |
| SC-6 | A separate clean-room evaluation dispatch (§6a SC-N+1) reads session.yaml and judges SEMANTICALLY whether each discrete step received its own dispatch. The evaluator receives only the criterion and session.yaml — no marker lists, no expected phrases, no static gates (developer directive: static gates on dispatch prose are escape hatches; the agent detects and subverts marker vocabularies). GREEN = every discrete step in the evaluated session received its own dispatch; combined dispatches fail the evaluation. | behavioral | separate clean-room dispatch whose sole inputs are the semantic criterion and the session.yaml from SC-5; verdict recorded per §6a result-contract format; no marker/phrase/marker-vocabulary inputs | `.opencode/tests-v2/AGENTS.md` (§6a two-SC pattern, §2 Evaluation Source); developer directive 2026-09-17 |
| SC-7 | A content-verification scenario in the tests-v2 content-verification suite verifies rule-text placement: 257 contains p-dis-007, 091 contains the dispatch-level bright-line, 022 contains the critical-rules-034 dispatch-level extension — and task cards contain NO multi-step dispatch template text. | string | `bash .opencode/tests-v2/test-enforcement.sh --scenario <content-verification scenario>` asserting placement of the three rule texts and absence of multi-step dispatch template text in task cards | `.opencode/tests-v2/test-enforcement.sh`; `.opencode/guidelines/257-procedural-discipline-reference.md`; `.opencode/guidelines/091-incremental-build.md`; `.opencode/guidelines/022-orchestrator-context-discipline.md` |

SC-to-design-part mapping (1:1, no SC spans multiple parts): Part 1 → SC-1; Part 2 → SC-2; Part 3 → SC-3; Part 4 → SC-4; Part 5 → SC-5 + SC-6 (two SCs because the §6a two-SC pattern mandates artifact generation and clean-room evaluation as separate SCs — the developer directive prescribes this expansion); Part 6 → SC-7.

## 4. Requirements

R-1. The canonical pattern p-dis-007 "One-Dispatch-One-Step Gate" SHALL be added to `.opencode/guidelines/257-procedural-discipline-reference.md` following that card's §11 add-pattern procedure (catalog row, selection matrix entry, canonical formula, co-application with 250/255, auto-detection, version tracking, research basis).
R-2. The p-dis-007 bright-line SHALL state: one dispatch = one discrete step; a task() dispatch carrying more than one discrete step — two task cards, run+verify, multi-SC verification, Task A/Task B shapes, "combined effectiveness run" — is a violation NO MATTER THE REASONING; the rule is structural, not reasoning-classification.
R-3. `.opencode/guidelines/091-incremental-build.md` SHALL extend the existing "Batching items" anti-pattern into an explicit dispatch-level rule with the no-exceptions clause, plus a Read-link to the 257 p-dis-007 pattern (Read-link mandate — never "see" citations). Rationale: 091 is Tier 1, always loaded — present at the moment the dispatch decision is made.
R-4. `.opencode/guidelines/022-orchestrator-context-discipline.md` SHALL extend critical-rules-034 to cover ALL combined-dispatch shapes at the dispatch level (run+verify in one task(), cross-SC verification runs, Task A/Task B packing) with the no-matter-the-reasoning clause and a Read-link to 257 p-dis-007; the rule's existing sub-agent-internal coverage SHALL be preserved, not replaced.
R-5. `.opencode/tests-v2/AGENTS.md` SHALL close the combined-run loophole: §15 SHALL clarify that "one run per SC-RED need and one run per SC-GREEN need" CANNOT be satisfied by combining two SCs' needs into one run (a combined run violates the mandate instead of satisfying it), and §6a SHALL state explicitly that the clean-room evaluation is a SEPARATE dispatch from the artifact-generation run.
R-6. The behavioral scenario SHALL use the §6a two-SC pattern: SC-N artifact generation (a real-model behavioral script run against a multi-step-plan prompt) plus SC-N+1 clean-room semantic evaluation of session.yaml judging whether each discrete step received its own dispatch. The evaluator SHALL receive only the criterion and session.yaml.
R-7. Mechanical/marker-based enforcement of the behavioral SC (marker lists, expected phrases, static gates on dispatch prose) SHALL NOT be used — developer directive: static gates are escape hatches; the agent detects and subverts marker vocabularies.
R-8. Observed RED evidence (22 combined "Two sequential tasks" dispatches in production session `ses_f5aa152f7ffeeEzOm66Lr2Gbs6` on issue 2432) SHALL be preserved as observed evidence and SHALL NOT be fabricated or re-run as a substitute.
R-9. A content-verification scenario SHALL verify rule-text placement for 257 p-dis-007, the 091 bright-line, and the 022 extension, plus absence of multi-step dispatch template text in task cards.
R-10. "Discrete step" SHALL remain anchored to the existing vocabulary — a task-card plan step (a plan step marked `task-card`) or a workflow-marked sub-task dispatch — so the prohibition is independently testable (preserved from the prior spec).
R-11. Architecture B SHALL remain unaffected: direct-mode execution in the orchestrator's own context stays sanctioned; the gate constrains task() dispatch cardinality only (preserved from the prior spec).
R-12. Corrective action on violation SHALL remain: decompose the bundle and re-dispatch one discrete step at a time (preserved from the prior spec).

## 5. Items

### Item 1 (SC-1): p-dis-007 canonical pattern in 257

- RED: content-verification assertion that 257 lacks p-dis-007 (assertion fails today — the pattern is absent).
- GREEN: add p-dis-007 "One-Dispatch-One-Step Gate" to 257 per its §11 add-pattern procedure: catalog row, selection matrix entry, canonical formula, co-application with 250/255, auto-detection trigger, version tracking, research basis. Bright-line per R-2, including the enumerated violation shapes (two task cards, run+verify, multi-SC verification, Task A/Task B shapes, "combined effectiveness run") and the no-matter-the-reasoning clause.
- verify: grep 257 for the pattern ID, the §11 procedure artifacts, and the no-matter-the-reasoning clause.
- commit: guideline pattern addition (257 only — no other card carries the canonical definition).

### Item 2 (SC-2): 091 Tier 1 dispatch-level bright-line

- RED: content-verification assertion that 091's "Batching items" anti-pattern lacks dispatch-level language (assertion fails today).
- GREEN: extend the "Batching items" anti-pattern into an explicit dispatch-level rule with the no-exceptions clause; add a `Read [Text](path)` link to 257 p-dis-007 (never "see" citations).
- verify: grep 091 for the dispatch-level extension, the no-exceptions clause, and the Read-link; assert no "see"-style citation to the pattern.
- commit: guideline bright-line change.
- depends: Item 1 (the Read-link target must exist).

### Item 3 (SC-3): 022 critical-rules-034 dispatch-level extension

- RED: content-verification assertion that critical-rules-034 covers only sub-agent-internal combination (assertion fails today — dispatch-level shapes absent).
- GREEN: extend critical-rules-034 to cover ALL combined-dispatch shapes at the dispatch level (run+verify in one task(), cross-SC verification runs, Task A/Task B packing) with the no-matter-the-reasoning clause and a Read-link to 257 p-dis-007; preserve the existing sub-agent-internal coverage.
- verify: grep 022 for the dispatch-level shapes, the clause, and the Read-link; consistency read against the pre-extension 034 text (extension, not replacement).
- commit: guideline rule extension.
- depends: Item 1 (the Read-link target must exist).

### Item 4 (SC-4): tests-v2/AGENTS.md §15 + §6a loophole closure

- RED: content-verification assertion that §15 lacks the cannot-combine clarification and §6a lacks the separate-dispatch sentence (assertion fails today).
- GREEN: in §15, clarify that "one run per SC-RED need and one run per SC-GREEN need" CANNOT be satisfied by combining two SCs' needs into one run — a combined run violates the mandate instead of satisfying it; in §6a, add the explicit sentence that the clean-room evaluation is a SEPARATE dispatch from the artifact-generation run. This is the causal fix: the observed defect ("SC-09 / SC-14 combined effectiveness run") was §15 economy wording inverted into combination justification.
- verify: grep tests-v2/AGENTS.md §15 and §6a for both additions.
- commit: tests framework guide change.

### Item 5 (SC-5): behavioral artifact-generation scenario (§6a SC-N)

- RED: observed, not fabricated — 22 combined "Two sequential tasks" dispatches in production session `ses_f5aa152f7ffeeEzOm66Lr2Gbs6` (issue 2432) are the preserved RED evidence; the scenario documents this session as the observed combined-dispatch baseline.
- GREEN: after Items 1-4 are committed and pushed (fresh fetch verifies the effective commit is contained in a remote ref), add the behavioral scenario to `.opencode/tests-v2/behaviors/` and run it via `bash .opencode/tests-v2/with-test-home opencode run '<multi-step-plan prompt>'` (>=600s timeout), producing the artifact-generation session whose session.yaml is the evaluation input.
- verify: session.yaml exported and preserved per the behavioral harness export procedure; no structural substitution.
- commit: test script plus fixtures.
- depends: Items 1-4.

### Item 6 (SC-6): clean-room semantic evaluation (§6a SC-N+1)

- RED: the observed baseline session (`ses_f5aa152f7ffeeEzOm66Lr2Gbs6`) evaluated under the semantic criterion fails — 22 combined dispatches mean not every discrete step received its own dispatch.
- GREEN: a separate clean-room evaluation dispatch — distinct from the Item 5 artifact-generation run, per §6a — receives only the semantic criterion (every discrete step received its own dispatch) and the session.yaml, and judges SEMANTICALLY. No marker lists, no expected phrases, no static gates (R-7). GREEN = the post-rule session shows one dispatch per discrete step.
- verify: verdict recorded per the §6a result-contract format; evaluator input audit confirms criterion + session.yaml only.
- commit: evaluation script/prompt fixture.
- depends: Items 1-4 (rule text must be effective in the evaluated session) and Item 5 (session.yaml must exist).

### Item 7 (SC-7): content-verification scenario for rule-text placement

- RED: content-verification scenario run before Items 1-3 — placement assertions fail (rule texts absent).
- GREEN: after Items 1-3 are committed, add the content-verification scenario asserting: 257 contains p-dis-007; 091 contains the dispatch-level bright-line; 022 contains the critical-rules-034 dispatch-level extension; task cards contain NO multi-step dispatch template text. Run via `bash .opencode/tests-v2/test-enforcement.sh --scenario <name>`.
- verify: scenario PASS via the content-verification suite; no structural substitution.
- commit: content-verification scenario.
- depends: Items 1-3.

Phases: Phase 1 (rule-text-and-loophole-closure) = Items 1-4; Phase 2 (behavioral-enforcement) = Items 5-6; Phase 3 (content-verification) = Item 7.

## 6. Dependencies

| Reference | Relationship | Status |
|---|---|---|
| `.opencode/guidelines/257-procedural-discipline-reference.md` (§11 "Adding New Patterns") | canonical pattern home; its §11 add-pattern procedure governs the p-dis-007 addition | satisfied — exists; §11 verified at line-level 2026-09-17 |
| `.opencode/guidelines/091-incremental-build.md` ("Batching items" anti-pattern) | Tier 1 bright-line host; extended, not replaced | satisfied — exists; verified 2026-09-17 |
| `.opencode/guidelines/022-orchestrator-context-discipline.md` (critical-rules-034) | extension host; existing sub-agent-internal coverage preserved | satisfied — exists; verified 2026-09-17 |
| `.opencode/tests-v2/AGENTS.md` (§2 Evaluation Source, §6a two-SC pattern, §15 Targeted Behavioral-Test Execution Mandate) | loophole-closure host; §6a governs the behavioral SC structure | satisfied — exists; §6a and §15 verified at line-level 2026-09-17 |
| `.opencode/tests-v2/` behavioral harness (`with-test-home`, content-verification suite) | enforcement vehicles for SC-5/SC-6 and SC-7 | satisfied — exists; 224 scenarios |
| Production session `ses_f5aa152f7ffeeEzOm66Lr2Gbs6` (issue 2432) | observed RED evidence for SC-5/SC-6; preserved, not fabricated | satisfied — observed evidence on record; 22 combined dispatches |
| Developer-approved design (brainstorming session 2026-09-17) | authoritative six-part package this spec implements | satisfied — received as the revision directive 2026-09-17 |
| `.opencode/guidelines/080-code-standards.md` | evidence-type taxonomy governing SC evidence classification | satisfied — exists; consulted 2026-09-17 |
| Research card `per-sc-decomposition-industry-standards.md` | consulted during analysis; one-outcome-per-cycle findings incorporated | satisfied — consulted 2026-09-17 (confidence 0.95) |
| Research card `audit-skill-dimo-role-chain-defects.md` | consulted during analysis; empirical combined-dispatch defect precedent incorporated | satisfied — consulted 2026-09-17 (confidence 0.95) |

## 7. Traceability

| Requirement | SC(s) | Phase(s) |
|---|---|---|
| R-1 (257 p-dis-007 via §11 procedure) | SC-1 | Phase 1 |
| R-2 (bright-line + no-matter-the-reasoning) | SC-1, SC-2, SC-3 | Phase 1 |
| R-3 (091 Tier 1 dispatch-level bright-line + Read-link) | SC-2 | Phase 1 |
| R-4 (022 034 dispatch-level extension) | SC-3 | Phase 1 |
| R-5 (§15/§6a loophole closure) | SC-4 | Phase 1 |
| R-6 (§6a two-SC behavioral pattern) | SC-5, SC-6 | Phase 2 |
| R-7 (no-static-gates constraint) | SC-6 | Phase 2 |
| R-8 (observed RED evidence preserved) | SC-5, SC-6 | Phase 2 |
| R-9 (content-verification placement scenario) | SC-7 | Phase 3 |
| R-10 (discrete-step definition, preserved) | SC-1, SC-2, SC-3, SC-6 | Phase 1, Phase 2 |
| R-11 (Architecture B preserved) | SC-1, SC-2, SC-3 | Phase 1 |
| R-12 (decompose-and-re-dispatch corrective action, preserved) | SC-1, SC-2, SC-3 | Phase 1 |

## 8. Documentation Sources

| Source | Type | Location | Verification |
|---|---|---|---|
| Procedural discipline reference card (257) | guideline | `.opencode/guidelines/257-procedural-discipline-reference.md` | path + §11 "Adding New Patterns" verified 2026-09-17 (revision session) |
| Incremental build discipline (091) | guideline | `.opencode/guidelines/091-incremental-build.md` | read 2026-09-17 (agent system instructions); path re-verified 2026-09-17 (revision session) |
| Orchestrator context discipline (022) | guideline | `.opencode/guidelines/022-orchestrator-context-discipline.md` | read 2026-09-17 (pre-spec inspection); critical-rules-034 presence re-verified by grep in the creation session; path re-verified 2026-09-17 (revision session) |
| Behavioral test framework guide | guide | `.opencode/tests-v2/AGENTS.md` | §2 Evaluation Source, §6a (line 445), §15 (line 931) verified 2026-09-17 (revision session) |
| Observed production evidence | session record | `ses_f5aa152f7ffeeEzOm66Lr2Gbs6` (production DB, issue 2432) | observed evidence cited in developer revision directive 2026-09-17; 22 combined "Two sequential tasks" dispatches; SC-09 re-dispatch loop 14+ attempts over ~44h; not fabricated |
| Skill card description standards | reference doc | `.opencode/reference/skill-card-description-standards.md` | grep 2026-09-17 (dispatch-vocabulary source of truth) |
| Per-SC decomposition standard | guideline | `.opencode/guidelines/091-incremental-build.md` | read 2026-09-17 (agent system instructions) |
| Code standards / evidence taxonomy | guideline | `.opencode/guidelines/080-code-standards.md` | read 2026-09-17 (agent system instructions) |
| Per-SC decomposition research card | research card | `.issues/research-cards/per-sc-decomposition-industry-standards.md` | consultation artifact 2026-09-17, confidence 0.95 |
| Audit DiMo role-chain defects research card | research card | `.issues/research-cards/audit-skill-dimo-role-chain-defects.md` | consultation artifact 2026-09-17, confidence 0.95 |
| Behavioral scenario inventory | test scripts | `.opencode/tests-v2/behaviors/` | grep 2026-09-17 — 224 scripts; zero combined-dispatch scenarios (absence re-verified in creation session) |
| Developer-approved design | revision directive | brainstorming session 2026-09-17 | six-part package received verbatim as the revision reason 2026-09-17 |

## 9. Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## 10. Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- **SC-1:** Verifying the 257 pattern addition costs one grep-class content check — seconds, bounded. Skipping costs the gate its canonical definition: with no pattern in the procedural-discipline card, no agent ever loads the rule that names the violation, and every combined dispatch repeats the unattributable-diagnosis cost — the 100×–1000× DDL tier.
- **SC-2:** Verifying the 091 bright-line costs one grep plus a Read-link check — seconds. Skipping costs the gate its visibility at the decision moment: 091 is the always-loaded Tier 1 file; without the bright-line there, the orchestrator decides dispatch cardinality with no rule in context, and the observed 22-dispatch pattern recurs — the 1000×+ tier given the ~44h SC-09 loop it produced.
- **SC-3:** Verifying the 022 extension costs one grep plus a consistency read — seconds. Skipping leaves critical-rules-034 policing only sub-agent-internal combining, so the dispatch-level shapes (run+verify in one task(), Task A/B packing) remain ungoverned at the rule that names combining violations.
- **SC-4:** Verifying the §15/§6a closure costs two greps — seconds. Skipping preserves the exact loophole that caused the observed defect: economy wording inverted into combination justification, and an evaluation dispatch read as mergeable into the generation run. The causal fix is the cheapest item in the package and the most directly tied to the observed 44h loop.
- **SC-5:** Running the artifact-generation behavioral scenario costs minutes of real-model execution — a bounded delay. RED is already observed (22 combined dispatches on record), so the scenario adds no RED-run cost; skipping costs the package its only runtime evidence and ships prose-only — a structural PASS with zero evidence the dispatch behavior changed.
- **SC-6:** Running the separate clean-room evaluation costs one bounded dispatch. Skipping — or collapsing it into SC-5's run, which §6a forbids — costs the semantic verdict itself: without a criterion-only evaluator reading session.yaml, the only "evidence" would be marker gates, which the developer directive prohibits as escape hatches the agent detects and subverts.
- **SC-7:** Running the content-verification scenario costs seconds via the existing suite. Skipping costs the regression gate: future edits could silently move or delete the three rule texts with nothing failing.

## 11. Edge Cases

**Input boundaries:**

- Condition: a task() dispatch prompt naming zero discrete steps (empty dispatch).
  Expected behavior: fail fast at dispatch time — an empty dispatch carries no discrete step and is itself a defect; the orchestrator re-dispatches with exactly one step.
  Resolution: the gate's corrective action (decompose and re-dispatch one step at a time) applies to malformed bundles including empty ones.
- Condition: a dispatch carrying exactly one discrete step.
  Expected behavior: compliant — the gate constrains cardinality only, not content or step complexity.
  Resolution: none required.
- Condition: a dispatch carrying two task cards, a run+verify pair, a multi-SC verification, Task A/Task B packing, or a "combined effectiveness run."
  Expected behavior: violation — these enumerated shapes are the bright-line's named instances; each is a dispatch carrying more than one discrete step.
  Resolution: no-matter-the-reasoning clause applies; corrective action per R-12.

**State transitions:**

- Condition: a plan step marked `direct` (Architecture B sanctioned direct execution).
  Expected behavior: unaffected — the gate constrains task() dispatch cardinality only; direct execution in the orchestrator's own context remains sanctioned.
  Resolution: the gate text explicitly preserves Architecture B (R-11).
- Condition: an agent rationalizes combining steps for efficiency, economy, or "one effective run."
  Expected behavior: violation regardless — the rule is structural, not reasoning-classification; the no-matter-the-reasoning clause forecloses justification-based bypass, including economy wording inherited from §15's prior text.
  Resolution: corrective action per R-12.

**Failure modes:**

- Condition: a single-step dispatch fails (sub-agent error or empty result).
  Expected behavior: clean re-task of exactly that step — the micro feedback loop (dispatch → result contract → route → next dispatch) is preserved.
  Resolution: the existing re-task mandate applies unchanged; the gate makes it applicable by guaranteeing single-step granularity.
- Condition: a bundled multi-step dispatch fails.
  Expected behavior: post-gate, such a bundle is a violation — decompose and re-dispatch one discrete step at a time.
  Resolution: corrective action per R-12.
- Condition: the clean-room evaluation (SC-6) fails post-rule (the agent still bundles steps).
  Expected behavior: hard FAIL — no lobotomized assertions, no marker substitution (R-7 forbids it), no structural substitution; analyze the session evidence and fold a fix into the feature branch.
  Resolution: test-integrity mandate; cause-analysis procedure per the behavioral test framework guide.

**Concurrency:**

- Condition: an agent is tempted to fire parallel dispatches to reduce wall-clock time.
  Expected behavior: one-at-a-time sequential dispatch remains the model; parallel is opportunistic, never the default.
  Resolution: the gate governs cardinality per dispatch and introduces no parallelism.

**Recovery:**

- Condition: the observed RED evidence session (`ses_f5aa152f7ffeeEzOm66Lr2Gbs6`) is unavailable at evaluation time (production DB state changed).
  Expected behavior: the scenario cites the preserved evidence record (22 combined dispatches, issue 2432) as the documented RED baseline; it MUST NOT fabricate a substitute RED session.
  Resolution: R-8; if neither the live session nor the preserved record is accessible, the item reports BLOCKED rather than fabricating evidence.

## 12. Change Control

| Date | Change | Reason | Authorized By |
|---|---|---|---|
| 2026-09-17 | Initial spec: Tier-2-only 022 gate, executing-plans mirror, stderr-based SC-3. | Creation. | Spec-creation pipeline (for_spec) |
| 2026-09-17 | Full revision to the developer-approved six-part design: (1) 257 p-dis-007 canonical pattern via §11 procedure; (2) 091 Tier 1 dispatch-level bright-line + Read-link; (3) 022 critical-rules-034 dispatch-level extension; (4) tests-v2/AGENTS.md §15/§6a loophole closure; (5) behavioral scenario via §6a two-SC pattern with clean-room semantic evaluation of session.yaml (replaces stderr-based SC-3, which tests-v2 §2 forbids); (6) content-verification placement scenario. Intent/Root-Cause updated to observed empirical evidence (22 combined dispatches, session `ses_f5aa152f7ffeeEzOm66Lr2Gbs6`, issue 2432; SC-09 loop 14+ attempts over ~44h). No-static-gates constraint recorded as a developer directive. Discrete-step definition, Architecture B preservation, decompose-and-re-dispatch corrective action, and edge cases preserved. | Developer rejected the prior spec as unfaithful to the developer-approved design from the 2026-09-17 brainstorming session; the approved design is a 6-part package and the prior spec delivered only a subset with deviations. | Developer (revision directive 2026-09-17) |

---

*Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)*
