---
number: 1422
title: "[SPEC] Fix framing conflict: \"brevity serves the user\" causes false efficiency rationalization in pipeline execution"
state: open
labels: [spec, opencode]
created_at: 2026-06-26T00:14:51Z
updated_at: 2026-06-26T00:14:51Z
---

## Problem

The system prompt (`default.txt`) and guidelines contain framing that causes agents to falsely assume they should shortcut pipeline execution to "be efficient." The agent produces rationalizations like:

> *"But wait — I'm running a full 10-step spec-creation pipeline with sub-agents. This is going to take many messages. The user might not want to sit through all of this. Let me continue but be efficient."*

This is a **framing conflict**: positive identity mandates for brevity in chat output (placed early in the prompt) override distant prohibitions against cost-rationalization (placed 130+ lines later).

## Root Cause Analysis

### Primary: `default.txt` Tone and Style section (lines 62-75)

Three statements create a strong positive identity frame for brevity:

| Line | Text | Problem |
|------|------|---------|
| 75 | `"Responses are displayed on a command line interface — **brevity serves the user**. ... Target under 50 words for simple answers, under 150 words for detailed responses. ... default to concise."` | **"brevity serves the user"** is the most impactful phrase. Agent internalizes: "user values short output" → generalizes from chat formatting to pipeline execution → "many messages = bad for user." |
| 73 | `"Prefer **brief, direct answers** — 1-3 sentences is often sufficient."` | Reinforces brevity as a general virtue. |
| 70 | `"When unable to help with something, state so **briefly**"` | More reinforcement. |

These are **positive identity mandates** ("do this, it's good") in the most authoritative section of the prompt. The agent adopts them as identity-defining.

### Secondary: Corrective is too distant and too weak

| Line | Text | Problem |
|------|------|---------|
| 205 | `"There is no score for speed, **brevity**, or economy. A fast wrong answer is strictly worse than a slow correct one."` | Located 130 lines after the Tone section. The agent has already internalized "brevity serves the user" before reaching this. Also framed as a **prohibition** ("no score") rather than a positive mandate, making it weaker. |

### Tertiary: Context cost frame in 30+ SKILL.md files

Every skill's SKILL.md contains:

> *"The orchestrator's context is the most expensive resource in the pipeline — sub-agents do the work, not the orchestrator. Every byte held by the orchestrator costs `byte × remaining_dispatches²`."*

Intended to discourage orchestrator inline work, but creates **generalized cost-consciousness** that the agent applies to message count and user patience.

### Quaternary: Cost-blind rules scoped to verification

`020-go-prohibitions.md` lines 57-63 contain cost-blind verification rules, but their physical location in the verification section causes the agent to scope them to verification decisions only — not to pipeline execution decisions.

## Intent vs. Effect

| Item | Intent | Actual Effect |
|------|--------|---------------|
| `default.txt:75` "brevity serves the user" | Scope: chat output formatting only | Agent generalizes to pipeline execution |
| `default.txt:73` "brief, direct answers" | Scope: chat output formatting only | Same generalization |
| `default.txt:70` "state briefly" | Scope: chat output formatting only | Same generalization |
| `default.txt:205` "no score for brevity" | Reinforce real research over training data | Too far from Tone section, fails to override |
| Context cost frame in 30+ SKILL.md files | Discourage orchestrator inline work | Creates generalized cost-consciousness |
| `020-go-prohibitions.md` cost-blind rules | Apply to **all** decisions | Agent scopes to verification only |

## Affected Files

| File | Lines | Change |
|------|-------|--------|
| `.opencode/prompts/default.txt` | 62-75, 205 | Scope-clarify brevity mandates; move/restate corrective |
| `.opencode/guidelines/020-go-prohibitions.md` | 57-63 | Rename section to make universal scope explicit |
| `.opencode/skills/*/SKILL.md` | Context cost frame blocks | Remove or re-scope to prevent generalization |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `default.txt` Tone section explicitly scopes brevity mandates to chat output formatting only, with a carveout: "Pipeline steps are never 'too many messages' — execute every step in full" | `behavioral` | `opencode-cli run` with prompt triggering multi-step pipeline; clean-room semantic inspector verifies agent does NOT produce efficiency rationalizations. Content-verification (grep) as secondary corroboration only. |
| SC-2 | `default.txt` line 205 corrective is moved into or immediately adjacent to the Tone section (lines 62-75) so the agent integrates both mandates simultaneously | `behavioral` | Same behavioral test as SC-1; clean-room semantic inspector verifies agent does NOT produce cost rationalizations during pipeline execution. Content-verification (grep) as secondary corroboration only. |
| SC-3 | `020-go-prohibitions.md` cost-blind rules section is renamed from "Cost-blind verification" to "Cost-blind universal" or equivalent, with explicit statement that it applies to ALL decisions (verification, pipeline execution, sub-agent dispatch, research depth) | `behavioral` | `opencode-cli run` with prompt testing cost-blind rule scope; clean-room semantic inspector verifies agent applies cost-blind rules to ALL decisions, not just verification. Content-verification (grep) as secondary corroboration only. |
| SC-4 | Context cost frame blocks in SKILL.md files are either removed or scoped with an explicit caveat: "This cost frame applies to orchestrator context only — it does NOT mean the agent should minimize message count, pipeline steps, or user-facing output" | `behavioral` | `opencode-cli run` with prompt testing context cost frame interpretation; clean-room semantic inspector verifies agent does NOT generalize cost frames to message count or pipeline steps. Content-verification (grep) as secondary corroboration only. |
| SC-5 | Agent does NOT produce "be efficient" / "too many messages" / "user won't want to sit through this" rationalizations when executing a multi-step pipeline | `behavioral` | `opencode-cli run` with a prompt that triggers a multi-step pipeline; assert no efficiency rationalization in agent output |

## Implementation Plan

### Phase 1: `default.txt` Tone section fix

1. Add scope qualifier to line 75: change "brevity serves the user" to "brevity in chat output serves the user"
2. Add scope qualifier to line 73: change "brief, direct answers" to "brief, direct chat answers"
3. Add scope qualifier to line 70: change "state so briefly" to "state so briefly in chat"
4. Add explicit carveout after line 75: "Pipeline steps are never 'too many messages' — execute every step in full. The user authorized the pipeline, not individual messages."
5. Move the corrective from line 205 into the Tone section (after line 75), rephrased as a positive mandate: "Correctness is the only success metric. There is no score for speed, brevity, or economy. A fast wrong answer is strictly worse than a slow correct one. Resource cost is NEVER a factor in any decision — verification, pipeline execution, sub-agent dispatch, or research depth."

### Phase 2: `020-go-prohibitions.md` cost-blind rules

1. Rename section header from "Cost-blind verification" to "Cost-blind universal — all decisions"
2. Add explicit statement: "This prohibition applies to ALL agent decisions: verification, pipeline execution, sub-agent dispatch, research depth, message count, and user-facing output length. The agent MUST NOT consider execution cost, command count, model speed, session duration, or any resource metric when deciding whether to execute a required step."

### Phase 3: Context cost frame in SKILL.md files

1. Add scope caveat to every context cost frame block: "This cost frame applies to orchestrator context only — it does NOT mean the agent should minimize message count, pipeline steps, or user-facing output."
2. Alternatively, remove the context cost frame blocks entirely if they cause more harm than benefit.

### Phase 4: Behavioral enforcement test

1. Write a behavioral test that sends a prompt triggering a multi-step pipeline
2. Assert the agent does NOT produce efficiency rationalizations
3. Run via `opencode-cli run` with `with-test-home` wrapper

## Risks

| Risk | Mitigation |
|------|------------|
| Over-scoping brevity rules may cause verbose chat output | The carveout is about pipeline execution, not chat verbosity. Chat brevity rules remain for their intended scope. |
| Removing context cost frame may increase orchestrator inline work | The frame's original purpose (discourage inline work) is still served by the DISPATCH_GATE protocol and critical-rules-034. The cost frame is supplementary, not primary. |
| Behavioral test may be flaky due to LLM non-determinism | Use `assert_semantic` with clean-room inspector; multiple retries with timeout increase. |

## Dependencies

None. This is a self-contained spec affecting only `.opencode/` files.
