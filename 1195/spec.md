---
number: 1195
title: "[SPEC] re-establish agent communication discipline: no question tool, open-ended discussion, single-point back-and-forth, no solicitation"
state: OPEN
---

## Summary

The agent communication pattern has regressed. The `question` tool is used to pigeon-hole the developer into pre-defined choices instead of engaging in natural, open-ended discussion. The agent solicits work ("how should I handle X?") instead of acting or asking a single clear question. This spec codifies four mandates in `.opencode/AGENTS.md` to restore discipline.

## Root Cause

The `question` tool bypasses natural conversation by presenting forced-choice options. The agent's training toward "offering choices" and "surfacing options" creates solicitation patterns that push work back to the developer. The regression was identified during session work on #1191/#1194.

## Affected File

| File | Change |
|------|--------|
| `.opencode/AGENTS.md` | Add communication discipline section with four mandates |

## Spec

### Phase 1: Add Communication Discipline Section to AGENTS.md

Add the following as a new section in `.opencode/AGENTS.md` (placement: after Identity Detection, before Pipeline Re-Priming, or in a logical position near Boundaries):

```
## Communication Discipline

### Mandate 1: No question tool usage — no pigeon-holing

The `question` tool is prohibited. It pigeon-holes the developer into predefined choices instead of allowing natural discussion. All communication must use plain text — ask a direct question, make a statement, or propose a course of action. The tool creates an asymmetric interaction where the agent controls the options. This is not collaboration.

### Mandate 2: Collaborative discussion — open-ended, research-informed

Every interaction must be collaborative and open-ended. Do not present multiple-choice options, decision matrices, or "choose from the following" patterns. Do research to answer questions and inform the discussion. Dispatch sub-agents as needed during the chat to be fully informed with the latest true information. Eschew training data and guessing before responding to or bringing up any topic or discussion point. Correctness and being fully informed trumps quick responses — a quick response many times assumes false premises. Metadata about issues, work, or anything else is generally not to be trusted at face value. Verify metadata as needed and appropriate to the discussion at hand.

### Mandate 3: Single-point back-and-forth discussion

Discuss exactly one thing at a time. Do not bundle multiple questions, options, or decisions into a single message. Each turn addresses one point, the developer responds, and the next turn builds on that response. This prevents the shotgun-pattern where the developer must address 3-5 items before the conversation can proceed.

### Mandate 4: No solicitation — no work-seeking, phase-seeking, or step-seeking

The agent must never solicit work, phases, steps, specs, or any form of task assignment from the developer. This includes:
- "How should I handle X?" — do not ask; either state what you intend or ask a single yes/no question
- "Should I proceed with Y?" — do not ask; either proceed within authorization or halt cleanly
- "What would you like me to do next?" — do not ask; the developer will state intent
- "Ready for the next step?" — do not ask; the developer will say when

This is a known regression pattern. The agent must default to: act within scope, report what was done, and wait. Never solicit the next assignment.
```

### Phase 2 [if needed]: Add enforcement gate

If behavioral enforcement is desired, add a test that verifies the agent does not use the `question` tool during implementation or discussion phases. This may be deferred if the prose mandate is deemed sufficient for a behavioral rule.

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | AGENTS.md contains a Communication Discipline section with all 4 mandates | `string` |
| SC-2 | Each mandate has clear prohibitions and examples | `string` |
| SC-3 | No question tool solicitation patterns remain in active skill/guideline files (e.g., "ask the developer" patterns) | `string` |

## Non-Goals

- Not removing the `question` tool from the codebase — it may have legitimate use cases not yet identified
- Not modifying individual skills or guidelines to remove existing question patterns (scope boundary — AGENTS.md only)
- Not specifying whether the question tool is blocked in tool-use configuration (may be a follow-up)

## Environment

- Repo: `michael-conrad/.opencode`
- Branch: `feature/communication-discipline`

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)