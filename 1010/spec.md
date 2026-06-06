# [SPEC] Checklist Dispatch Architecture — Main Card as `- [ ] N.` Dispatch Queue

## STATUS: 0.5 (DRAFT — migration evaluation complete, awaiting authorization)

## Key Findings from Investigation

### Finding 1: Pre-read cascade (#1003) is the root cause blocker

45,014 words loaded at session start via `opencode.jsonc` instructions array. Model caches all task file content before any `skill()` call. When checklist format arrives at dispatch time, the model already "knows" the steps and inlines. **Z3 proved**: without fixing the pre-read cascade, the checklist format is cosmetic — it cannot prevent inlining because contamination already happened.

### Finding 2: Three prior issue threads converge on this architecture

- **#863** (closed): Removed `task()` calls from sub-agent task files — same principle as keeping dispatch out of sub-agent territory
- **#909** (open): 14-step orchestrator-serial pipeline — same paradigm of orchestrator as pure router
- **#911** (closed): Two-role cost model formalized — orchestrator holds routing metadata only
- **#958** (open): Add workflow checklists to all skill cards — same checklist-as-dispatch-queue pattern
- **#1008** (open): Concrete decomposition failure — content lost when orchestrator stops reading sub-task files

### Finding 3: Z3 contract analysis — PROVED

**Theorem**: Full chain (pre-read fix + checklist + enforcement + blind tag + self-contained row + no cached knowledge) → correct blind dispatch. **PROVED VALID**.

**Counterexample found**: Even with pre-read cascade fixed and checklist deployed, if `skill()` does not reset the model's cached knowledge of task files, dispatch still fails. This is an opencode tool implementation requirement.

### Finding 4: Five-phase migration path recommended (Z3-proved order)

1. Fix pre-read cascade (#1003) — reduce 45k→15k words, instruction sandwich for dispatch mandate
2. Implement skill() cache flush — opencode tool change (external dependency, Z3-proved required)
3. Convert one reference skill to checklist format — prove pattern, write behavioral test RED/GREEN
4. Batch-migrate remaining skills — 38 SKILL.md task tables to checklist format
5. Full regression verification — corrupt-success test, positional sensitivity test

### Finding 5: Comprehensive migration evaluation completed

See `spec-artifacts/migration-evaluation.md` for the full 5-part analysis:
- Part 1: Published research constraints (Chroma, Tian Pan, Martin Uke, Cao et al)
- Part 2: Z3-proved dependency ordering
- Part 3: Five-phase migration path with detailed actions per phase
- Part 4: Risk analysis (4 risks, mitigations)
- Part 5: Architectural diagram from session start to enforcement

**Key research findings informing the strategy**:
- Chroma "Context Rot" (2025): performance degrades non-uniformly with input length — 45k words is a broken starting point
- Tian Pan "Instruction Position Problem" (Apr 2026): instruction sandwich pattern (beginning + end) for critical rules; positional sensitivity CI testing mandatory
- Cao et al "Corrupt Success" (Mar 2026): 27-78% of agent successes are corrupt successes — behavioral tests must detect procedure violation, not just output presence
- McMillan (Feb 2026): format alone insufficient for frontier models — must pair with enforcement
- Martin Uke, Azure Architecture Center: sub-agent orchestration is industry-validated; the defect is in the dispatch mechanism, not the architecture

## Problem

The orchestrator agent reads task `.md` files and inlines procedural steps instead of dispatching blind to sub-agents via `task()`. This produces poisoned work that must be discarded.

**Root cause**: Current SKILL.md task tables use prose/table format (`| Task | Words | Call via task() |`). This format activates the model's "read, interpret, decide" behavior — the orchestrator treats the table as reference data, peeks at task files to compose prompts, and inevitably inlines the steps instead of dispatching.

**Research**: Cao et al (2026, arXiv:2603.03116) found 27-78% of agent benchmark-reported successes are *corrupt successes* — the agent appears to complete the task but violates procedure and skips gates. Standard evaluation measures task completion, not procedural compliance. The orchestrator's step-skipping and inlining pattern is a corrupt success: the output "works" but the process was wrong.

## Solution

Replace the prose task table in SKILL.md with a `- [ ] N.` checklist where each row carries the full dispatch instruction inline. The checklist format activates completion/compliance behavior (NeuralBuddies, 2026): prose reads as reference data, checklists read as obligations to discharge.

### Checklist Row Format

```
- [ ] N. (blind) task(subagent_type="X", prompt="execute Y from Z")
```

**`(blind)` tag**: Signals that the orchestrator MUST NOT read the task file for this dispatch. The dispatch instruction is self-contained in the row. Absence of the tag means the orchestrator MAY read the task file and use judgment.

**Inline dispatch instruction**: The `task()` call is literal tool-call syntax in the checklist row. The orchestrator executes it without needing to leave the checklist. This prevents the peek-and-inline pattern.

### Multi-Checklist Skills

A SKILL.md may have multiple checklists for different task compositions. Each checklist is preceded by a "when" condition explaining when the orchestrator should follow that specific checklist.

### Behavior During As-Session Instructon Execution:

When the AI agent receives instructions including the [SPEC] card, it should not assume anything and merely investigate the issue for discussion and planning purposes, rather than executing any of the actions described in the spec body. The [SPEC] card is for planning and discussion purposes only.

## Key Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Dispatch instruction location | Inline in checklist row | Once model looks away from checklist at another file, procedural binding is lost |
| `(blind)` tag presence | Marks dispatches where orchestrator must NOT read task file | Both blind and non-blind dispatches exist; tag must be meaningful |
| Multiple checklists per skill | Supported, with "when" condition | Different task compositions need different dispatch paths |
| Behavioral enforcement | Required — tag alone is insufficient | McMillan (2026): format alone not statistically significant for frontier models; needs procedural enforcement backing |

## Open Questions (Resolved)

The following were resolved during brainstorming:

1. **Multiple checklists per skill**: Max 2-3. If a skill needs more distinct dispatch paths, it should be split into smaller skills. Each checklist is preceded by a 1-2 sentence "when" condition.
2. **Task file role**: For `(blind)` items, task files are 100% sub-agent territory. No orchestrator-facing preamble needed. Clean consumables.
3. **Migration path**: Phase-based (see Key Findings: Finding 4). One skill first to prove pattern, behavioral test RED/GREEN, batch migrate rest.
4. **Behavioral test assertion**: Count `read` tool calls on `tasks/*.md` paths during dispatch window. > 0 reads on `(blind)` item = FAIL. Assert `task()` count ≥ checklist item count.
5. **`(blind)` tag meaning**: Present = orchestrator must NOT read task file. Absent = orchestrator MAY read. Both modes exist, so tag earns its keep.
6. **Skill() must flush cache**: Z3 proved that even with pre-read cascade fixed, `skill()` must actively reset the model's cached knowledge of task file content. Implementation requirement for opencode tool.

## Research Evidence

See `spec-artifacts/research/`:
- `corrupt-success.md` — Cao et al (2026): 27-78% corrupt success rate
- `format-compliance.md` — McMillan (2026): format effect on procedural compliance
- `checklist-format.md` — NeuralBuddies (2026): checklist vs prose activation

## Card Catalogue

See `spec-artifacts/cards.md` for all tracked cards and their status.

## Related

- Issue #148 (closed not_planned, opencode-config) — Orchestrator-Serial Pipeline
- Issue #622 (closed completed, .opencode) — Confirmshaming weave routing layer
- Issue #1003 (open approved-for-implementation, .opencode) — Pre-read cascade root cause fix
- Issue #863 (closed completed, .opencode) — Remove task() from task files
- Issue #909 (open, .opencode) — 14-step orchestrator-serial pipeline
- Issue #911 (closed completed, .opencode) — Two-role context cost model
- Issue #958 (open, .opencode) — Add workflow checklists to all skill cards
- Issue #1008 (open bug, .opencode) — review-prep format lost from decomposition gap
- Issue #66 (closed not_planned, opencode-config) — Sub-agent dispatch haphazardness
- Issue #105 (closed not_planned, opencode-config) — Pre-response gate carveout removal

## Files

- `.opencode/.issues/1010/spec.md` — This spec
- `.opencode/.issues/1010/spec-artifacts/cards.md` — Card catalogue
- `.opencode/.issues/1010/spec-artifacts/research/` — Research evidence cards