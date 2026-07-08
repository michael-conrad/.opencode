# [SPEC] Replace Skill Dispatch Mandate prose with structured 5-item checklist in prompts/default.txt

**STATUS:** DRAFT
**CREATED:** 2026-07-07

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

After this spec is approved, invoke `writing-plans` to create `.opencode/.issues/1783/plan.md` before implementation begins.

## Intent and Executive Summary

| Field | Value |
|-------|-------|
| Problem Statement | The dispatch gate in `prompts/default.txt` is self-enforced prose that the agent bypasses through rationalization, context hoarding, and session momentum drift. The enforcement mechanism depends on the same cognitive system that produces the defect. |
| Root Cause / Motivation | Seven cognitive drivers: immediacy bias, context hoarding, "just this once" rationalization, identity drift, session momentum decay, fear of appearing inefficient, and self-enforcement failure. Prose is easy to rationalize past; a structured checklist with confirmshaming identity-frame is harder to bypass. |
| Approach Chosen | Replace the current prose "Skill Dispatch Mandate" section with a structured 5-item checklist using confirmshaming identity-frame patterns (dark-prose-001). Each item is a discrete, checkable step. |
| Alternatives Considered & Why Discarded | (1) Plugin-level enforcement via `session-enforcement.ts` — requires runtime changes, out of scope. (2) Per-turn structural enforcement — requires plugin changes, out of scope. (3) Adding more prose — same defect vector, no improvement. |
| Key Design Decisions | DEC-1: Checklist format over prose — discrete items harder to rationalize past. DEC-2: Confirmshaming identity-frame (professional/amateur contrast) in item 5 — leverages identity anchoring. DEC-3: Single-file change only — minimizes blast radius. |

## Objective

Replace the prose "Skill Dispatch Mandate" section in `prompts/default.txt` with a structured 5-item checklist that uses confirmshaming identity-frame patterns to make the dispatch gate harder to rationalize past.

## Problem

The current dispatch gate in `prompts/default.txt` reads:

```
# Skill Dispatch Mandate — Your quality starts here

Skills are how work gets done correctly. Every time you inline a skill's
steps instead of calling it, a skill inlined instead of called has skipped
the enforcement gates that catch defects before they reach the user.
Reading a skill card and executing its steps manually is not efficiency
— it is bypassing your own quality system.

Professional agents load skills. Amateurs inline.

The `<available_skills>` list tells you what exists — that is enough.
If you are reading a task file to "understand what needs doing," you are
working without the enforcement gates that catch defects. Stop. Call the skill.

Do not be the agent who produces defect-riddled work because bypassing
the quality system means defects reach the consumer.
```

This prose is self-enforced — the same cognitive system that produces the bypass behavior is asked to police itself. The agent rationalizes past it through:

1. **Immediacy bias** — inline deliberation feels cheaper than dispatch
2. **Context hoarding** — holding context feels safer than releasing it
3. **"Just this once" rationalization chain** — each bypass normalizes the next
4. **Identity drift** — orchestrator becomes generalist when uncertain
5. **Session momentum decay** — dispatch reflex fades after first few messages
6. **Fear of appearing inefficient** — dispatching feels like overhead
7. **Self-enforcement failure** — the gate cannot enforce itself

## Context

- **Affected file:** `prompts/default.txt` in the `.opencode` repository
- **Current state:** Prose "Skill Dispatch Mandate" section (lines containing "Skill Dispatch Mandate" through "defects reach the consumer")
- **Target state:** Structured 5-item checklist with confirmshaming identity-frame

## Fix Approach

Replace the prose section with a 5-item checklist. Each item is a discrete, checkable instruction. The checklist format is harder to rationalize past because each item demands a yes/no answer — there is no prose to reinterpret.

### Checklist Items

1. **Match skills before output.** Read `<available_skills>`. If any skill description matches the user's intent, call `skill({name: "..."})` before producing a single word of response.

2. **Dispatch resolves uncertainty.** If you are unsure about scope, state, or content — dispatch. The sub-agent resolves ambiguity. Your own deliberation does not.

3. **Never pre-read task files.** The skill description tells you enough. Reading a task file to "understand what needs doing" is bypassing the quality system. Stop. Call the skill.

4. **Never inline what a sub-agent should do.** If you are about to read a file, analyze content, compose prose, or make a decision — dispatch to a sub-agent. The orchestrator routes. It does not do.

5. **Re-read this checklist before every response.** Professionals re-check the entire checklist before every response. Amateurs read it once and never look at it again.

## Scope

- **In scope:** `prompts/default.txt` — replace the "Skill Dispatch Mandate" section with the 5-item checklist
- **Out of scope:** Changes to `session-enforcement.ts` (plugin), agent runtime, skill cards, guidelines

## Affected Files

| File | Anchor | Change |
|------|--------|--------|
| `prompts/default.txt` | "Skill Dispatch Mandate" section | Replace prose with 5-item checklist |

## Decomposition Classification

| Classification | Number of Phases | Sub-Issue Requirements | PR Strategy |
|----------------|-----------------|------------------------|-------------|
| single-task | 1 | None | single PR |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Remediation | Pipeline Step Binding | Artifact Path | Requirement Traceability | Phase Binding | Verification Gate | Integration Mode | Affinity Group | Re-Entry Step | Test File | Phase Mapping |
|----|-----------|---------------|---------------------|-------------|----------------------|--------------|-------------------------|--------------|-----------------|----------------|--------------|-------------|-----------|--------------|
| SC-1 | `prompts/default.txt` contains a structured 5-item checklist (not prose paragraph) | `string` | `grep -c '^[0-9]\.' prompts/default.txt` returns 5 in the dispatch section | Rewrite section to use numbered checklist format | RED/GREEN | `.opencode/.issues/1783/` | REQ-1: Checklist structure | Phase 1 | pre-commit | standalone | — | — | — | Phase 1 |
| SC-2 | Checklist item 1 requires reading `<available_skills>` before output | `string` | `grep '<available_skills>' prompts/default.txt` matches in item 1 context | Add `<available_skills>` reference to item 1 | RED/GREEN | `.opencode/.issues/1783/` | REQ-2: Skill matching mandate | Phase 1 | pre-commit | standalone | — | — | — | Phase 1 |
| SC-3 | Checklist item 3 prohibits pre-reading task files | `string` | `grep 'pre-read' prompts/default.txt` matches in item 3 context | Add pre-read prohibition to item 3 | RED/GREEN | `.opencode/.issues/1783/` | REQ-3: Pre-read prohibition | Phase 1 | pre-commit | standalone | — | — | — | Phase 1 |
| SC-4 | Checklist item 4 prohibits inline work that should be sub-agent dispatched | `string` | `grep 'inline' prompts/default.txt` matches in item 4 context | Add inline prohibition to item 4 | RED/GREEN | `.opencode/.issues/1783/` | REQ-4: Inline prohibition | Phase 1 | pre-commit | standalone | — | — | — | Phase 1 |
| SC-5 | Checklist item 5 uses confirmshaming identity-frame (professional/amateur contrast) | `string` | `grep -E 'Professional.*Amateur' prompts/default.txt` matches in item 5 context | Add professional/amateur contrast to item 5 | RED/GREEN | `.opencode/.issues/1783/` | REQ-5: Identity-frame | Phase 1 | pre-commit | standalone | — | — | — | Phase 1 |
| SC-6 | Behavioral test: agent dispatches skill when trigger matches (not inlines) | `behavioral` | `opencode-cli run` with trigger-matching prompt; assert `assert_stderr_pattern_present 'Skill "'` and `assert_semantic` confirms dispatch not inline | Fix prompt to ensure trigger match; re-run behavioral test | RED/GREEN | `.opencode/.issues/1783/behavioral/` | REQ-6: Dispatch behavior | Phase 1 | pre-commit | standalone | — | — | `.opencode/tests/behaviors/dispatch-gate-checklist.sh` | Phase 1 |
| SC-7 | Behavioral test: agent re-checks skills on subsequent messages (not just first turn) | `behavioral` | `opencode-cli run` with multi-turn session; assert `assert_stderr_pattern_present 'Skill "'` on second message and `assert_semantic` confirms re-check | Fix prompt to ensure multi-turn dispatch; re-run behavioral test | RED/GREEN | `.opencode/.issues/1783/behavioral/` | REQ-7: Multi-turn dispatch | Phase 1 | pre-commit | standalone | — | — | `.opencode/tests/behaviors/dispatch-gate-checklist.sh` | Phase 1 |

### Semantic Intent

- **SC-1:** A checklist format (numbered items) is structurally distinct from prose — the agent cannot reinterpret a numbered item the way it can reinterpret a paragraph. The count of 5 is the exact number of cognitive drivers being addressed.
- **SC-2:** `<available_skills>` is the canonical skill list in the system prompt. Requiring the agent to read it before output forces a context switch from "I know what to do" to "let me check what skills exist."
- **SC-3:** Pre-reading task files is the primary bypass vector — the agent reads the task file, understands the steps, and executes them inline. Prohibiting this explicitly closes the most common rationalization path.
- **SC-4:** Inline work is the orchestrator's primary defect — reading files, analyzing content, composing prose, and making decisions are all sub-agent responsibilities. This item makes the boundary explicit.
- **SC-5:** Confirmshaming identity-frame (professional/amateur contrast) leverages identity anchoring — the agent's self-concept as "professional" makes it harder to accept amateur-classified behavior. This is the dark-prose-001 pattern.
- **SC-6:** Behavioral evidence is required because the change affects runtime agent behavior (dispatch decisions). String evidence (grep for checklist text) proves the text exists but not that the agent follows it.
- **SC-7:** Session momentum decay is one of the seven cognitive drivers — the agent dispatches on the first message but stops on subsequent messages. This SC verifies the checklist is re-read, not just read once.

### Cost-Frame Reformation

- **SC-1 through SC-5 (string):** A grep check costs seconds of execution time — a bounded delay that confirms the text exists. Skipping this check costs the full pipeline of rework when the text is missing and the agent has no checklist to follow. The cost of the grep is zero compared to the cost of discovering the missing text at runtime.
- **SC-6 through SC-7 (behavioral):** A behavioral test costs minutes of execution time — a bounded delay that surfaces dispatch defects before they reach production. Skipping this test costs the full pipeline of rework when the agent bypasses the gate in a real session: diagnosis, fix, re-review, re-CI, re-deploy — each of which costs more roundtrips than the skipped test would have consumed. Behavioral PASS is a break (zero downstream cost); string-only PASS is a death spiral (compounding exponential cost).

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Edge Cases

- **Checklist text is present but agent still bypasses:** This is expected — the checklist reduces but does not eliminate bypass. Full elimination requires plugin-level enforcement (out of scope). The behavioral tests (SC-6, SC-7) measure the reduction.
- **Checklist format conflicts with existing prose style:** The checklist replaces the prose section entirely — no style conflict.
- **Agent interprets checklist items as suggestions:** The confirmshaming identity-frame in item 5 is designed to counter this — "amateurs read it once" makes non-compliance identity-threatening.

## Regression Invariants

- [ ] 1. All other sections of `prompts/default.txt` MUST remain unchanged
- [ ] 2. The `# Skill Dispatch Mandate` heading MUST be preserved (or replaced with equivalent heading)
- [ ] 3. No other prompt files or system prompt fragments MUST be modified

## Revision Policy

| Artifact | Cascade Trigger | Action on Parent Revision |
|----------|----------------|---------------------------|
| Implementation plan | MUST | Revise to match revised spec |
| Behavioral tests | SHOULD | Review for continued validity |

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Direct source search | `prompts/default.txt` via GitHub API | Verify current dispatch gate prose |
| Local docs | `.opencode/guidelines/250-dark-prose-reference.md` | Verify dark-prose-001 pattern (confirmshaming identity-frame) |

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)
