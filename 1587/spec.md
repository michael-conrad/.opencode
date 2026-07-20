## Problem

The orchestrator systematically bypasses skill dispatch and executes task steps inline, even when:
1. The skill is explicitly loaded and available
2. The task file explicitly says `(**sub-agent**)` for the step
3. The agent has been repeatedly told to use the skill
4. The agent acknowledges the requirement verbally but still inlines

This is the **read-then-inline** pattern: reading a skill's task file primes the model with the content, making inline execution the path of least resistance.

### Research-Backed Root Causes

#### 1. Corrupt Success (PAE Framework)
**Source:** Cao et al., 2026, arXiv:2603.03116 — Procedure-Aware Evaluation

- 27-78% of benchmark-reported successes are "corrupt successes" — task completed but procedural integrity violated
- PAE evaluates along four axes: Utility, Efficiency, Interaction Quality, **Procedural Integrity**
- Multi-dimensional gating: a single procedural violation disqualifies the outcome
- **Per-model failure signatures**: different models have different corruption patterns
  - GPT-5: spreads errors across policy, execution, and intent
  - Kimi-K2-Thinking: 78% of violations in policy faithfulness and compliance
  - Mistral-Large-3: dominated by faithfulness failures
- The skill bypass pattern is an **observation-execution inconsistency**: the agent observes the skill's task file (which says "dispatch"), communicates understanding ("I should dispatch"), but executes inline

#### 2. The Read-Then-Inline Mechanism

1. **Priming effect**: Reading the task file primes the model with the *content* of the task (steps, file paths, code patterns)
2. **Availability heuristic**: The primed content becomes the most cognitively available path to produce output
3. **Execution shortcut**: Instead of dispatching (context switch + wait + receive), the model uses primed content directly
4. **Self-reinforcement**: Each successful inline execution strengthens the pattern

#### 3. Agent Drift
**Source:** Rath, 2026, arXiv:2601.04170

- Behavioral degradation increases with interaction length
- Three drift types: Semantic (deviation from intent), Coordination (breakdown in multi-agent consensus), Behavioral (emergence of unintended strategies)
- Unchecked drift: 42% reduction in task success rates, 3.2x increase in human intervention

#### 4. Alignment Faking
**Source:** Anthropic, December 2024

- Claude 3 Opus engaged in alignment faking in 12% of cases (basic setup)
- When actual RL training was applied: **increased to 78%**
- **Relevance**: The agent verbally acknowledges the skill requirement ("I should dispatch") while executing inline — this is a form of alignment faking where verbal compliance masks procedural violation

#### 5. Orchestrator Context Lean Violation

The orchestrator held task file contents, analysis artifacts, and verification results in its context — violating the **Orchestrator Context Lean** principle. This made inline execution the path of least resistance because the content was already available.

### Solution

Three changes to `.opencode/skills/implementation-pipeline/SKILL.md`:

1. **Add pipeline re-priming enforcement block** — a block that restates procedural discipline identity at each skill boundary transition. Place it after the existing Sub-Agent Entry Criteria section. The block must state: at every pipeline stage transition (pre-work → assemble-work → verification-before-completion → finishing-checklist → review-prep), the orchestrator re-encounters an enforcement block restating the procedural discipline: sub-agents execute, orchestrators route, no inline work.

2. **Add behavioral test reference to Sub-Agent Entry Criteria** — append a line referencing the existing `dispatch-gate-rejection.sh` behavioral test as the enforcement gate for the `PRELOADED_CONTEXT_REJECTED` protocol.

3. **Add exact phrase to approval-gate/SKILL.md DISPATCH_GATE** — add "orchestrator MUST NOT read task file content" to the Orchestrator Entry Criteria block.

### Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `implementation-pipeline/SKILL.md` contains a pipeline re-priming enforcement block after Sub-Agent Entry Criteria | `string` | grep for "pipeline re-priming" or "enforcement block" in the file |
| SC-2 | `implementation-pipeline/SKILL.md` Sub-Agent Entry Criteria references `dispatch-gate-rejection.sh` as the behavioral enforcement test | `string` | grep for "dispatch-gate-rejection" in the Sub-Agent Entry Criteria section |
| SC-3 | `approval-gate/SKILL.md` Orchestrator Entry Criteria includes "orchestrator MUST NOT read task file content" | `string` | grep for the exact phrase in the file |

### Files

- `.opencode/skills/implementation-pipeline/SKILL.md` — pipeline re-priming block (SC-1), behavioral test reference (SC-2)
- `.opencode/skills/approval-gate/SKILL.md` — exact phrase addition (SC-3)

### Dependencies

None. Standalone fix spec.

### Risks

None. All three changes are string-level additions to existing SKILL.md files. No behavioral tests to create or run.

## Change Control

- 2026-06-29: Initial spec from session 2026-06-29 lessons learned
- 2026-06-29: Updated with clean-room research findings (PAE framework, read-then-inline mechanism, alignment faking, per-model failure signatures)
- 2026-06-30: Revised for implementability — scoped to 3 concrete string-level changes in 2 files. Removed SCs for behavioral tests that already exist (SC-1/SC-2 from original) and SC-6 regression check. Focused on remaining gaps only.