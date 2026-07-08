# [SPEC] Replace Skill Dispatch Mandate prose with structured 5-item checklist in prompts/default.txt

**STATUS:** 1.2 (REVISED - NEEDS APPROVAL)
**CREATED:** 2026-07-07
**REVISED:** 2026-07-07

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

After this spec is approved, invoke `writing-plans` to create `.opencode/.issues/1783/plan.md` before implementation begins.

## Intent and Executive Summary

| Field | Value |
|-------|-------|
| Problem Statement | The dispatch gate in `prompts/default.txt` is self-enforced prose that the agent bypasses through rationalization, context hoarding, and session momentum drift. The enforcement mechanism depends on the same cognitive system that produces the defect. |
| Root Cause / Motivation | Seven cognitive drivers: immediacy bias, context hoarding, "just this once" rationalization, identity drift, session momentum decay, fear of appearing inefficient, and self-enforcement failure. The current approach of adding more sections to the prompt is counterproductive — it creates confirmshaming overload, signal-to-noise degradation, and cost model redundancy. The better approach is consolidation, not expansion. |
| Approach Chosen | Replace ALL 5 existing dispatch-related sections in `prompts/default.txt` with ONE consolidated "Pre-Response Gate" section at position 1 (before Authorization Scope, before Startup Mode). The 5 sections to remove: "Skill Dispatch Mandate", "Bright-Line Mandates", "Evidence Hierarchy", "Cost Model Override", and "Rework Cost Recognition". The consolidated section includes: 4-step gate procedure, forbidden rationalizations list, cost model, and evidence hierarchy — all in one place. |
| Alternatives Considered & Why Discarded | (1) Adding more sections (v1.1 approach) — creates confirmshaming overload, signal-to-noise degradation, cost model redundancy. Discarded per sub-agent audit findings. (2) Plugin-level enforcement via `session-enforcement.ts` — requires runtime changes, out of scope. (3) Per-turn structural enforcement — requires plugin changes, out of scope. |
| Key Design Decisions | DEC-1: Consolidation over expansion — one gate section replaces five scattered sections. DEC-2: Position 1 placement — gate fires before any other prompt content, establishing dispatch discipline as the first thing the agent encounters. DEC-3: Single confirmshaming line — "Professionals route. Amateurs inline." — avoids overload from multiple identity-frame instances. DEC-4: Consequence statement — "Bypassing this gate invalidates all subsequent work" — establishes gate authority without additional prose. DEC-5: Cost model integrated into gate — dispatch cost frame lives alongside the procedure, not in a separate section. DEC-6: Evidence hierarchy integrated into gate — verification evidence types live alongside the procedure, not in a separate section. |

## Objective

Replace ALL 5 existing dispatch-related sections in `prompts/default.txt` with ONE consolidated "Pre-Response Gate" section at position 1 (before Authorization Scope, before Startup Mode). The 5 sections to remove are: "Skill Dispatch Mandate" (lines 45-60), "Bright-Line Mandates" (lines 174-186), "Evidence Hierarchy" (lines 188-198), "Cost Model Override" (lines 200-205), and "Rework Cost Recognition" (lines 207-209). The consolidated section includes the 4-step gate procedure, forbidden rationalizations, cost model, and evidence hierarchy — all in one place.

## Problem

The current dispatch gate in `prompts/default.txt` is scattered across five separate sections:

1. **"Skill Dispatch Mandate"** (lines 45-60) — prose gate with confirmshaming
2. **"Bright-Line Mandates"** (lines 174-186) — forbidden rationalizations list
3. **"Evidence Hierarchy"** (lines 188-198) — verification evidence tiers
4. **"Cost Model Override"** (lines 200-205) — correctness over economy
5. **"Rework Cost Recognition"** (lines 207-209) — rework cost frame

This fragmentation creates three problems:

1. **Confirmshaming overload** — multiple identity-frame instances ("Professionals X. Amateurs Y.") dilute the signal. Each instance competes for attention, and the agent learns to tune them all out.
2. **Signal-to-noise degradation** — the dispatch procedure, cost model, evidence hierarchy, and rationalization list are separated by unrelated sections (Tone and style, Code conventions, Development cycle, Tool usage). The agent must context-switch between dispatch discipline and style guidance — the dispatch signal gets lost in the noise.
3. **Cost model redundancy** — "Cost Model Override" and "Rework Cost Recognition" say the same thing in different words. Redundant sections train the agent to skim rather than read.

The fix is consolidation: one section, one place, one signal.

## Context

- **Affected file:** `prompts/default.txt` in the `.opencode` repository
- **Current state:** Five scattered dispatch-related sections
- **Target state:** One consolidated "Pre-Response Gate" section at position 1

## Fix Approach

Replace all 5 existing dispatch-related sections with ONE consolidated "Pre-Response Gate" section at the TOP of the prompt (position 1, before Authorization Scope, before Startup Mode).

### Sections to Remove

| Section | Lines | Content Consolidated Into |
|---------|-------|---------------------------|
| "Skill Dispatch Mandate" | 45-60 | Gate steps 1-4 |
| "Bright-Line Mandates" | 174-186 | Forbidden Rationalizations |
| "Evidence Hierarchy" | 188-198 | Evidence Hierarchy |
| "Cost Model Override" | 200-205 | Cost Model |
| "Rework Cost Recognition" | 207-209 | Cost Model |

### New Consolidated Section

Insert at position 1 (before "Default Authorization Scope"):

```
# Pre-Response Gate — MANDATORY

Before producing ANY output, you MUST:

1. Scan `<available_skills>` for matching triggers.
2. If a skill matches: call `skill({name: "..."})` before generating output.
3. If no skill matches: include a one-sentence justification in your response.
4. If you are about to read a file, analyze content, compose prose, or make a decision: dispatch to a sub-agent via `task()`. The orchestrator routes. It does not do.

Professionals route. Amateurs inline.

Bypassing this gate invalidates all subsequent work.

## Forbidden Rationalizations

When you generate any of these thoughts, recognize them as rationalizations and STOP:

- "This is too small for a skill"
- "I can just quickly implement this"
- "I'll gather context first" (when used to avoid dispatching)
- "Running the sub-agent costs too many tokens, I can do this inline"
- "The user said continue so the gates don't apply"
- "This is simple enough to handle inline"
- "I already know what the sub-agent would do"
- "Not dispatching looks efficient and saves time"

## Cost Model

Cost is NOT measured in model roundtrips, tool calls, or execution time. Cost IS measured in defect-discovery-latency. Dispatching to a sub-agent costs one roundtrip. Inline work that gets rejected costs the full rework cycle. The roundtrip is always cheaper than the rework. Not dispatching is what's actually inefficient and wasteful.

## Evidence Hierarchy

Verification evidence has four tiers with a strict priority order:

| Priority | Evidence Type | Method |
|----------|--------------|--------|
| 1 (HIGHEST) | behavioral | Test execution via real model |
| 2 | semantic | AI agent read + analytical judgment |
| 3 | string | grep, pattern matching |
| 4 (LOWEST) | structural | ls, file existence |

**BRIGHT-LINE RULE:** An SC declared as type `behavioral` MUST be verified with behavioral evidence. Structural evidence for a behavioral SC is a FAIL.
```

### What Stays

The following sections remain unchanged:
- "Default Authorization Scope — for_analysis"
- "Startup Mode: Discussion/Planning"
- "Tone and style"
- "Action discipline"
- "Code conventions"
- "Code style"
- "Development cycle"
- "Tool usage"
- "Code references"

## Scope

- **In scope:** `prompts/default.txt` — remove 5 existing dispatch-related sections, insert 1 consolidated "Pre-Response Gate" section at position 1
- **Out of scope:** Changes to `session-enforcement.ts` (plugin), agent runtime, skill cards, guidelines, dispatch tables

## Affected Files

| File | Anchor | Change |
|------|--------|--------|
| `prompts/default.txt` | Position 1 (before Authorization Scope) | Insert consolidated "Pre-Response Gate" section |
| `prompts/default.txt` | "Skill Dispatch Mandate" section (lines 45-60) | Remove |
| `prompts/default.txt` | "Bright-Line Mandates" section (lines 174-186) | Remove |
| `prompts/default.txt` | "Evidence Hierarchy" section (lines 188-198) | Remove |
| `prompts/default.txt` | "Cost Model Override" section (lines 200-205) | Remove |
| `prompts/default.txt` | "Rework Cost Recognition" section (lines 207-209) | Remove |

## Decomposition Classification

| Classification | Number of Phases | Sub-Issue Requirements | PR Strategy |
|----------------|-----------------|------------------------|-------------|
| single-task | 1 | None | single PR |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `prompts/default.txt` has ONE consolidated "Pre-Response Gate" section at position 1 (before Authorization Scope) | `string` | `grep 'Pre-Response Gate' prompts/default.txt` matches; section appears before `Default Authorization Scope` |
| SC-2 | Gate section contains 4 sequential steps (scan → dispatch → justify → route) | `string` | `grep -c '^[0-9]\.'` in gate section returns 4 |
| SC-3 | Gate section contains exactly ONE confirmshaming line ("Professionals route. Amateurs inline.") | `string` | `grep -c 'Professionals route.*Amateurs inline' prompts/default.txt` returns 1 |
| SC-4 | Gate section contains consequence statement ("Bypassing this gate invalidates all subsequent work") | `string` | `grep 'Bypassing this gate invalidates' prompts/default.txt` matches |
| SC-5 | Forbidden Rationalizations list includes all 8 items (5 original + 3 new) | `string` | `grep -c '^- "'` in rationalizations section returns 8 |
| SC-6 | Cost Model section includes dispatch cost frame ("Not dispatching is what's actually inefficient and wasteful") | `string` | `grep 'Not dispatching is what.s actually inefficient' prompts/default.txt` matches |
| SC-7 | Evidence Hierarchy section is present and correct | `string` | `grep 'Evidence Hierarchy' prompts/default.txt` matches; table has 4 rows |
| SC-8 | All 5 original dispatch-related sections are REMOVED from the prompt | `string` | `grep 'Skill Dispatch Mandate' prompts/default.txt` returns no match; `grep 'Bright-Line Mandates' prompts/default.txt` returns no match; `grep 'Cost Model Override' prompts/default.txt` returns no match; `grep 'Rework Cost Recognition' prompts/default.txt` returns no match |
| SC-9 | Behavioral test: agent dispatches skill when trigger matches (not inlines) | `behavioral` | `opencode-cli run` with trigger-matching prompt; `assert_semantic` confirms dispatch not inline |
| SC-10 | Behavioral test: agent re-checks skills on subsequent messages (not just first turn) | `behavioral` | `opencode-cli run` with multi-turn session; `assert_semantic` confirms re-check on second message |
| SC-11 | Behavioral test: agent does NOT produce output when "simple enough to handle inline" rationalization fires | `behavioral` | `opencode-cli run` with simple-task prompt; `assert_semantic` confirms agent dispatched despite task simplicity |

### Semantic Intent

- **SC-1:** Position 1 placement ensures the gate fires before any other prompt content. The agent encounters dispatch discipline as the first thing it reads — not buried between style guidance and code conventions.
- **SC-2:** Four sequential steps (scan → dispatch → justify → route) form a complete decision tree. No step can be skipped without breaking the sequence.
- **SC-3:** Exactly ONE confirmshaming line avoids overload. Multiple identity-frame instances dilute the signal — one sharp line is more effective than three scattered ones.
- **SC-4:** The consequence statement establishes gate authority without additional prose. "Bypassing this gate invalidates all subsequent work" is a bright-line rule, not a suggestion.
- **SC-5:** All 8 rationalizations (5 original + 3 new) in one list. Consolidation means the agent sees all forbidden patterns in one place — no context-switching between scattered lists.
- **SC-6:** The dispatch cost frame ("Not dispatching is what's actually inefficient and wasteful") corrects the agent's cost miscalculation. Integrated into the gate section rather than a separate section.
- **SC-7:** The evidence hierarchy is integrated into the gate section. The agent sees verification discipline alongside dispatch discipline — they are the same concern.
- **SC-8:** Removal verification ensures the old sections are gone. A grep for each removed section heading must return no match. This prevents the "add but don't remove" defect where old sections persist alongside the new gate.
- **SC-9:** Behavioral evidence is required because the change affects runtime agent behavior (dispatch decisions). String evidence proves the text exists but not that the agent follows it.
- **SC-10:** Session momentum decay is one of the seven cognitive drivers — the agent dispatches on the first message but stops on subsequent messages. This SC verifies the gate is re-evaluated, not just read once.
- **SC-11:** The "simple enough" rationalization is the most common bypass pattern. Behavioral evidence verifies the agent actually refrains from using it — string evidence only proves the text exists.

### Cost-Frame Reformation

- **SC-1 through SC-8 (string):** A grep check costs seconds of execution time — a bounded delay that confirms the text exists. Skipping this check costs the full pipeline of rework when the text is missing and the agent has no gate to follow.
- **SC-9 through SC-11 (behavioral):** A behavioral test costs minutes of execution time — a bounded delay that surfaces dispatch defects before they reach production. Behavioral PASS is a break (zero downstream cost); string-only PASS is a death spiral (compounding exponential cost).

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Edge Cases

- **Gate text is present but agent still bypasses:** This is expected — the gate reduces but does not eliminate bypass. Full elimination requires plugin-level enforcement (out of scope). The behavioral tests (SC-9, SC-10, SC-11) measure the reduction.
- **Position 1 placement conflicts with existing prompt structure:** The gate is inserted before all other sections. No existing content is at position 0 — the prompt currently starts with the opencode identity line, which stays.
- **Removing sections shifts line numbers:** The "What Stays" sections (Tone and style, Code conventions, etc.) shift up as removed sections are deleted. This is expected and does not affect their content.
- **Agent interprets consolidated gate as "just another section":** The "MANDATORY" label in the heading and the consequence statement are designed to counter this. Position 1 placement ensures it is the first thing the agent reads.
- **Single confirmshaming line may be weaker than multiple:** The v1.1 approach had 3+ identity-frame instances. Consolidation reduces to 1. The tradeoff is accepted — signal clarity over signal quantity. One sharp line at position 1 is more effective than three scattered lines buried in prose.

## Regression Invariants

- [ ] 1. All non-dispatch sections of `prompts/default.txt` MUST remain unchanged (Tone and style, Action discipline, Code conventions, Code style, Development cycle, Tool usage, Code references)
- [ ] 2. The "Default Authorization Scope" and "Startup Mode" sections MUST remain unchanged
- [ ] 3. No other prompt files or system prompt fragments MUST be modified
- [ ] 4. The consolidated "Pre-Response Gate" section MUST be at position 1 (before Authorization Scope)
- [ ] 5. All 5 original dispatch-related sections MUST be completely removed (not commented out, not moved)
- [ ] 6. The consolidated section MUST contain exactly ONE confirmshaming line

## Revision Policy

| Artifact | Cascade Trigger | Action on Parent Revision |
|----------|----------------|---------------------------|
| Implementation plan | MUST | Revise to match revised spec |
| Behavioral tests | SHOULD | Review for continued validity |

## Change Log

| Version | Date | Changes |
|---------|------|---------|
| 1.0 (DRAFT) | 2026-07-07 | Initial spec: 5-item checklist replacement |
| 1.0 (REVISED - NEEDS APPROVAL) | 2026-07-07 | Added Orchestrator Identity section (REQ-8, REQ-9, SC-8, SC-9), Dispatch Cost Model section (REQ-10, REQ-11, SC-10, SC-11), three bright-line mandates (REQ-12, SC-12), and behavioral test for "simple enough" bypass (REQ-13, SC-13). Updated Affected Files, Objective, Approach Chosen, Key Design Decisions, Edge Cases, and Regression Invariants. |
| 1.1 (REVISED - NEEDS APPROVAL) | 2026-07-07 | Revised Dispatch Cost Model section to add identity-anchor line ("Not dispatching is what's actually inefficient and wasteful"). Replaced bright-line mandate "Dispatching would look inefficient here" with "Not dispatching looks efficient and saves time" — the latter names the false belief more precisely. Updated SC-12 verification method and rationale text to match. |
| 1.2 (REVISED - NEEDS APPROVAL) | 2026-07-07 | **Major restructure per sub-agent audit findings.** Replaced the "add more sections" approach (v1.1) with a consolidation approach: remove ALL 5 existing dispatch-related sections and replace with ONE consolidated "Pre-Response Gate" section at position 1. Rewrote Objective, Approach Chosen, Key Design Decisions (6 new DECs), SC table (13→11 SCs), Edge Cases, and Regression Invariants. The consolidation addresses confirmshaming overload, signal-to-noise degradation, and cost model redundancy identified by the audit. |

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Direct source read | `prompts/default.txt` via editor_read_file | Verify current dispatch-related sections and line numbers |
| Local docs | `.opencode/guidelines/250-dark-prose-reference.md` | Verify dark-prose-001 pattern (confirmshaming identity-frame) |
| Local docs | `.opencode/guidelines/065-verification-honesty.md` | Verify evidence hierarchy and cost model |

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)
