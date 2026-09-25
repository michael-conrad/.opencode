# Task: explore

## Purpose

Full conversational exploration workflow for requirements gathering before spec creation.

## Process Flow

```dot
digraph brainstorming {
    "Pre-spec code inspection" -> "Cross-Spec Scope Search";
    "Cross-Spec Scope Search" -> "Explore project context" [label="no supersession"];
    "Explore project context" -> "Scope check";
    "Scope check" -> "Decompose project" [label="multi-subsystem"];
    "Scope check" -> "Visual questions ahead?" [label="single scope"];
    "Decompose project" -> "Visual questions ahead?";
    "Visual questions ahead?" -> "Offer Visual Companion" [label="yes"];
    "Visual questions ahead?" -> "Ask clarifying questions" [label="no"];
    "Offer Visual Companion" -> "Ask clarifying questions";
    "Ask clarifying questions" -> "Propose 2-3 approaches";
    "Propose 2-3 approaches" -> "Present design incrementally";
    "Present design incrementally" -> "User approves?";
    "User approves?" -> "Invoke spec-creation" [label="yes"];
    "User approves?" -> "Present design incrementally" [label="no, revise"];
}

**Finalization hard gate at the terminal transition:** The
`"User approves?" -> "Invoke spec-creation"` edge passes through the
finalization gate. Dispatch to `spec-creation` is REQUIRED to be preceded
by an explicit finalization signal from the user — a recognized,
unforgeable user statement that the design is final. It is NEVER agent
inference. Read
[the Step 7 gate definition](brainstorming/tasks/explore/exploration-workflow.md)
for full finalization-signal semantics and non-finalization classification.
The design is NOT "design incrementally approved" into spec-creation —
incremental design approval alone never triggers the terminal dispatch;
the session holds in the `awaiting_finalization` state until the user's
explicit finalization signal arrives.
```

## Operating Protocol

- [ ] 1. **Mandatory inspection first:** Run pre-spec code inspection before project context exploration
- [ ] 2. **Cross-spec scope search:** Check for overlapping specs/plans before proceeding
- [ ] 3. **One question at a time:** NEVER ask multiple questions in one message
- [ ] 4. **Autonomous scope decisions:** Agent determines single vs multi-task, NOT asks user
- [ ] 5. **Terminal step is spec-creation:** Exploration output feeds into spec-creation, never outputs spec directly
- [ ] 6. **Finalization signal required:** Hold `awaiting_finalization` until the user's explicit, unforgeable finalization statement — never agent inference (Step 7 finalization gate)

## Entry Criteria

- User wants to brainstorm/ideate/explore before spec creation
- Implementation request with existing code context

## Exit Criteria

- User has issued an explicit finalization signal: an unforgeable statement that the design is final (never agent inference) — NOT "design incrementally approved"; incremental design agreement alone does NOT finalize
- Finalization hard gate (Step 7) satisfied: `awaiting_finalization` cleared by the recognized finalization signal
- `spec-creation` skill invoked (terminal state)

## Procedure

### Step 0: Pre-Spec Code Inspection

**Route to:** `explore/pre-spec-inspection`

Mandatory checklist covering all six inspection items with tool-call evidence. Generates verification classification table.

### Step 0.5: Cross-Spec Scope Search

**Included in:** `explore/pre-spec-inspection`

Searches GitHub Issues for open specs/plans that may overlap with the proposed work. Reports FULL-SUPERSESSION, PARTIAL-OVERLAP, or CONFLICT-RISK if found.

### Steps 1-7: Project Context, Scope, Q&A, Design

**Route to:** `explore/exploration-workflow`

Explores project context, assesses scope (decomposing if multi-subsystem), conducts interactive Q&A with minimum turn threshold, proposes approaches for significant decisions, and presents design incrementally.

## Sub-Task Files

| Sub-Task | Purpose | Words |
| -- | -- | -- |
| `explore/pre-spec-inspection` | Mandatory code inspection with evidence artifacts | ≈850 |
| `explore/exploration-workflow` | Context exploration, scope assessment, interactive Q&A, design | ≈950 |

## Key Behavioral Constraints

| Constraint | Enforcement |
| -- | -- |
| One question per message | STRICT — never multiple questions |
| Minimum interactive turns | 2 turns minimum with substantial responses |
| Autonomous structural classification | Agent decides single vs multi-task |
| Confirmation per finding | Each major finding confirmed individually |
| Hard gate: spec-creation is terminal | Never output spec in chat |
| Finalization hard gate | Explicit user finalization signal REQUIRED before spec-creation dispatch — hold `awaiting_finalization` otherwise; never agent inference |

## Context Required

- Related skill: `spec-creation` (terminal step)
- Related guidelines: `015-pre-spec-inspection.md`, `065-verification-honesty.md`, `091-incremental-build.md`

---

*Co-authored with AI: OpenCode (ollama-cloud/glm-5.3-flash)*