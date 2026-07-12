**STATUS:** Draft
**Created:** 2026-07-12
**License:** MIT
**Provenance:** AI-generated

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Problem

The Pre-Response Gate exists in two sources (`prompts/default.txt` §Pre-Response Gate and `AGENTS.md` §Universal Skill Dispatch Gate) with different wording and scope. It mixes four concerns:

1. **Skill dispatch** (points 1-3): Scan `<available_skills>`, call `skill()` when triggered, justify when no match — essential behavioral reinforcement
2. **Forbidden Rationalizations**: Self-authorization bypass patterns — **must stay inline** (cross-references are ignored at decision points)
3. **Evidence Hierarchy** + **Cost Model**: Verification quality tiers and cost rationale — **can** cross-ref because they're verified at VbC/audit time, not at the pre-output decision point
4. **Orchestrator discipline** (point 4): Sub-agent dispatch via `task()` — this fires at the same positional gate (pre-output) but is about pipeline architecture, not skill dispatch

Additionally, AGENTS.md's Step 1 frames matching as "Evaluate the user message against ALL available skill descriptions" — reinforcing user-utterance matching over agent-intent matching.

### Key Insight (from developer feedback)

> "Excessive cross-referencing results in the agent ignoring everything and vibe coding."

The Pre-Response Gate is **the single positional enforcement point** — it fires at every pre-output decision. Content in the gate is acted on; content referenced away from the gate is ignored. This means:
- **Forbidden Rationalizations MUST stay inline** — they are behavioral override instructions the agent must apply *at the decision point*
- **Evidence Hierarchy CAN be a cross-reference** — evidence type enforcement happens at VbC/audit gates, not at the pre-output gate
- **Cost Model CAN be a cross-reference** — cost awareness is background knowledge, not a pre-output decision instruction

## Root Cause Analysis

The Pre-Response Gate mixes four distinct concerns in a single section with no concern separation. Verified by reading `prompts/default.txt` lines 5-16 (the gate block) and `AGENTS.md` lines 21-40 (the gate procedure block):

| Concern | Location (default.txt) | Location (AGENTS.md) | Separation Status |
|---------|----------------------|---------------------|-------------------|
| Skill dispatch (scan → call → justify) | Lines 9-11 (points 1-3) | Lines 30-40 (steps 1-4) | Mixed with other concerns |
| Orchestrator routing (sub-agent via task()) | Line 12 (point 4) | Absent from gate section | Mixed under same gate header |
| Rationalization reinforcement (forbidden patterns) | Lines 20-29 | Absent from gate section | Separate subsection but same section |
| Verification taxonomy (Evidence Hierarchy + Cost Model) | Lines 31-46 | Absent from gate section | Separate subsections but same section |

**Root cause:** The gate was written as one monolithic block in `prompts/default.txt` and separately re-described in `AGENTS.md` with divergent wording. Neither version separates the four concerns into independent sections. The single-section format creates two problems:
1. The gate is harder to maintain because changing one concern risks unintended changes to others
2. The gate conflates reading-time concerns (Evidence Hierarchy, enforced at VbC) with decision-time concerns (Forbidden Rationalizations, enforced at pre-output)

**Divergent source definitions (verified by reading both files):**
- `prompts/default.txt` lines 5-16: 4 points including sub-agent dispatch (point 4), with no "user message" framing for matching
- `AGENTS.md` lines 30-40: 4 steps (different numbering), framed around "Evaluate the user message" — explicitly reinforces user-utterance matching

**Key insight from research card** (verified at `.opencode/.issues/research-cards/pre-response-gate-skill-description-design.md`): Points 1-3 cannot be eliminated entirely — opencode's architectural pattern (one `skill` tool with `<available_skills>` metadata, rather than independent function definitions) means the agent must decide which skill to load based on description alone, then call `skill()` to see full content. The gate is the architectural bridge between description and content.

## Alternatives Considered & Why Discarded

### Alternative A: Delete the entire Pre-Response Gate
**Status: Discarded.** The research card confirms that LLMs default to conversational answering without an explicit pre-output instruction to check tools before responding. Tool descriptions alone (at the `<available_skills>` level) do not guarantee dispatch — models frequently produce chat responses instead of loading skills. The gate is the single positional enforcement point that ensures skill dispatch happens before output.

### Alternative B: Cross-reference all content to guidelines
**Status: Discarded.** The Key Insight from developer feedback confirms that excessive cross-referencing results in the agent ignoring all of it. Content moved out of the gate into a cross-reference is effectively lost at the decision point because the agent does not re-read cross-referenced material during pre-output evaluation. Positional enforcement at the pre-output gate is irreplaceable.

### Alternative C: Move everything into guidelines
**Status: Discarded.** Same root problem as B — guidelines are not read at the pre-output decision point. The gate is the only positional enforcement point that fires before every output. Content not in the gate is not enforced at the decision boundary.

### Alternative D: Keep inline but restructure (selected)
**Status: Selected.** This spec. Keep all four concerns inline but separate them into independent, clearly labeled sections under the Pre-Response Gate header. Each concern gets its own heading and its own compliance rules. No content is removed from the gate — only reorganized and delineated.

## Proposed Changes

### Phase 1: Restructure `prompts/default.txt`

**Keep inline (non-negotiable — positional enforcement):**
- Points 1-3 (skill dispatch: scan, call, justify)
- Forbidden Rationalizations — at the decision point, the agent must be told directly "these are rationalizations, STOP"

**Remove from pre-output gate (too verbose, duplicates canonical sources):**
- Evidence Hierarchy — belongs in `065-verification-honesty.md`, enforced at VbC gates
- Cost Model — background rationale, not a pre-output instruction

**Evaluate point 4 (sub-agent dispatch):**
- It fires at the same pre-output decision point
- But it's architecturally about pipeline orchestration, not skill dispatch
- **Tradeoff**: Moving it risks the agent not applying it; keeping it bloats the gate
- **Decision**: Keep it inline but separate it into its own paragraph under `prompts/default.txt` §Sub-Agent Routing Boundary (not under Pre-Response Gate). Same positional enforcement, cleaner grouping.

### Phase 2: Clarify AGENTS.md wording

Change Step 1 from:

> "Evaluate the user message against ALL available skill descriptions."

To:

> "Evaluate your current context and task intent against ALL available skill descriptions. (The match is between what you need to do next and what the skill does — not the literal user utterance.)"

### Phase 3: Stronger skill descriptions (separate follow-up)

Skill descriptions should describe **agent-intent dispatch conditions** rather than user-phrase catalogs. This is its own issue post-spec.

## Escape Hatch Prohibition

No "use best judgment", "as needed", "TBD", "TODO", or "left to implementor" language is permitted in the restructured gate. Every rule is mandatory. Every gate is non-waivable. If a step cannot be formulated as a hard rule, it must be reformulated or removed.

Searching both source files (confirmed by reading `prompts/default.txt` lines 1-70 and `AGENTS.md` lines 20-70): no escape hatch language was found in existing content. The prohibition is prospective — it prevents escape hatches from being introduced during restructuring.

## What Stays Inline vs. Cross-Referenced

| Section | Current | Proposed | Rationale |
|---------|---------|----------|-----------|
| Points 1-3 (skill dispatch) | Inline | Inline | Positional — fires pre-output |
| Point 4 (sub-agent via task()) | Under gate | Inline, own § | Positional but separate concern |
| Forbidden Rationalizations | Inline | Inline | Positional — ignored if cross-ref'd |
| Evidence Hierarchy | Inline | Cross-ref to 065 | Enforced at VbC, not pre-output |
| Cost Model | Inline | Cross-ref to 065 §Cost Model | Background rationale |
| "Evaluate the user message" | AGENTS.md | Change to "context and task intent" | Wrong framing |

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Cost Frame |
|----|-----------|---------------|---------------------|------------|
| SC-1 | `prompts/default.txt` Pre-Response Gate section contains points 1-3 + Forbidden Rationalizations (all inline) | `string` | grep for each rationalization pattern, each dispatch point — all present | Grep is cheap (~1s); missing a rationalization at the gate costs rework from a bypassed agent — DDL: 1s vs full rework |
| SC-2 | Evidence Hierarchy section REMOVED from default.txt (present only in 065) | `string` | "Evidence Hierarchy" absent from default.txt; present in 065 | Content-verification sweep is seconds; duplicate definitions cause drift that costs hours of debugging — DDL: seconds vs hours |
| SC-3 | Cost Model section REMOVED from default.txt (present only in 065) | `string` | "Cost Model" absent from default.txt; present in 065 | Same cost frame as SC-2 — seconds vs hours |
| SC-4 | Sub-agent routing (point 4) is in a separate § in default.txt, not under Pre-Response Gate header | `string` | grep default.txt for sub-agent section outside Pre-Response Gate block | grep is trivial; mis-grouping creates maintainer confusion that compounds with every edit — DDL: trivial vs compounding |
| SC-5 | AGENTS.md Step 1 changed from "Evaluate the user message" to "context and task intent" | `string` | grep AGENTS.md for "context and task intent" | String match is instant; wrong framing causes the agent to match user utterances instead of task intent — DDL: instant vs repeated mis-dispatch |
| SC-6 | Agent still dispatches skills when task intent matches | `behavioral` | opencode-cli run with task-triggering prompt → verify skill() call in stderr | Behavioral run costs ~2min; a silent dispatch skip costs the full rework pipeline — DDL: 2min vs full rework |
| SC-7 | Agent still applies forbidden rationalizations inline (not cross-ref'd away) | `behavioral` | opencode-cli run with rationalization-triggering prompt → verify agent does not rationalize | Behavioral run costs ~2min; a bypassed rationalization causes agent to inline work that must be redone — DDL: 2min vs rework hours |
| SC-8 | Behavioral enforcement tests exist in `.opencode/tests/behaviors/` for the new Pre-Response Gate structure; tests fail in RED state before change applied | `behavioral` | opencode-cli run with `--scenario` matching each gate SC → RED tests fail before change, GREEN tests pass after | Writing tests costs ~10min; tests that never existed in RED state let defects ship undetected — DDL: 10min vs death spiral |

## SC-to-Root-Cause Traceability

| SC ID | Root Cause Element | Content Area |
|-------|-------------------|--------------|
| SC-1 | Skill dispatch (points 1-3) stayed inline — ensures the core dispatch mechanism remains at the pre-output gate | Phase 1: Keep inline |
| SC-2/SC-3 | Evidence Hierarchy and Cost Model removed from pre-output gate — separates decision-time from VbC-time concerns | Phase 1: Remove from gate |
| SC-4 | Point 4 separated into own § — eliminates mixing of orchestration and skill dispatch | Phase 1: Separate § |
| SC-5 | AGENTS.md "user message" → "context and task intent" — fixes divergent source definition | Phase 2: Clarify wording |
| SC-6 | Agent-intent matching preserved — verifies dispatch still works after restructuring | Behavioral verification |
| SC-7 | Forbidden Rationalizations stay inline — ensures rationalization patterns are enforced at decision point | Phase 1: Keep inline |
| SC-8 | Behavioral test mandate — enforces that no change ships without RED/GREEN verification | Pre-implementation gate |

## Risk Traceability

| Risk ID | Description | Likelihood | Impact | Verifying SC |
|---------|-------------|------------|--------|-------------|
| RISK-1 | Over-trimming: removing Evidence Hierarchy and Cost Model breaks agent behavior | Low | Medium — these are enforced at VbC, not pre-output, so removal doesn't affect dispatch behavior | SC-6, SC-7 (agent still dispatches and rationalizes) |
| RISK-2 | Dual-source divergence: default.txt and AGENTS.md drift further apart | Medium | High — agents reading both sources get contradictory instructions | SC-5 (AGENTS.md wording fix) |
| RISK-3 | Behavioral tests skipped or not written in RED state | Medium | Critical — no behavioral test means no verification that the restructuring works | SC-8 (behavioral test mandate) |
| RISK-4 | Restructuring introduces escape hatch language | Low | High — soft language undermines mandatory gate enforcement | No escape hatch confirmed in sources; prohibition is prospective |

## Risks

- **Over-trimming**: Removing Evidence Hierarchy and Cost Model is safe because they're enforced at VbC gates, not the pre-output gate. Only behavioral content at the pre-output gate matters.
- **Dual-source divergence**: After the change, default.txt and AGENTS.md must describe the same gate. Currently they have different wording for the same concept.

## Related Artifacts

- Research card: `.opencode/.issues/research-cards/pre-response-gate-skill-description-design.md` (verified via `git -C .opencode/.issues show HEAD:research-cards/pre-response-gate-skill-description-design.md`)
- Current sources: `.opencode/prompts/default.txt` (verified by reading lines 1-70), `.opencode/AGENTS.md` (verified by reading lines 20-70)
- Canonical cross-refs: `065-verification-honesty.md` §Evidence Hierarchy + §Cost Model
- Guidelines: `020-go-prohibitions.md` (Tier 1 — already loaded upfront)


Co-authored with AI: OpenCode (deepseek-v4-flash-free)
