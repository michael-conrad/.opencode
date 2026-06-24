# Task: create

## Purpose

Create an implementation plan from an approved spec. The orchestrator reads this task file and executes the 21-step pipeline, dispatching sub-agents for sub-task steps and running z3-check steps inline.

## Prerequisites

- [ ] 1. Approved spec (verified by approval-gate)
- [ ] 2. Spec stored in `.issues/{N}/spec.md`
- [ ] 3. Spec has explicit approval (`approved` or `go`)
- [ ] 4. (Optional) `authorization_scope` from verify-authorization — if scope >= `for_plan`, plan auto-approval triggers

## Operating Protocol — 21-Step Pipeline

Each item is tagged with dispatch scope, chain dependency, and contract paths.

- [ ] 1. [inline] Verify spec is approved (check `approved-for-*` label) — chain: `none`
- [ ] 2. [sub-task: research] `task(..., prompt: "execute research task from writing-plans")` — input: `contracts/research-input-template.yaml`, output: `contracts/research-output-template.yaml`, template: `contracts/research-input-template.yaml`, chain: `step_1`
- [ ] 3. [z3-check] `solve check` — verify research output contains evidence_artifacts — chain: `step_2`
- [ ] 4. [sub-task: readiness] `task(..., prompt: "execute readiness task from writing-plans")` — input: `contracts/readiness-input-template.yaml`, output: `contracts/readiness-output-template.yaml`, template: `contracts/readiness-input-template.yaml`, chain: `step_3`
- [ ] 5. [z3-check] `solve check` — verify readiness output has status PASS — chain: `step_4`
- [ ] 6. [sub-task: structure] `task(..., prompt: "execute structure task from writing-plans")` — input: `contracts/structure-input-template.yaml`, output: `contracts/structure-output-template.yaml`, template: `contracts/structure-input-template.yaml`, chain: `step_5`
- [ ] 7. [z3-check] `solve check` — verify structure output has phase definitions and dependency contract — chain: `step_6`
- [ ] 8. [sub-task: solve] `task(..., prompt: "execute solve task from writing-plans")` — input: `contracts/solve-input-template.yaml`, output: `contracts/solve-output-template.yaml`, template: `contracts/solve-input-template.yaml`, chain: `step_7`
- [ ] 9. [z3-check] `solve check` — verify solve output has SAT and SOLVED status — chain: `step_8`
- [ ] 10. [sub-task: write] `task(..., prompt: "execute write task from writing-plans")` — input: `contracts/write-input-template.yaml`, output: `contracts/write-output-template.yaml`, template: `contracts/write-input-template.yaml`, chain: `step_9`
- [ ] 11. [z3-check] `solve check` — verify write output has plan file path — chain: `step_10`
- [ ] 12. [sub-task: revisit] `task(..., prompt: "execute revisit task from writing-plans")` — input: `contracts/revisit-input-template.yaml`, output: `contracts/revisit-output-template.yaml`, template: `contracts/revisit-input-template.yaml`, chain: `step_11`
- [ ] 13. [z3-check] `solve check` — verify revisit output has resolution_status — chain: `step_12`
- [ ] 14. [sub-task: validate] `task(..., prompt: "execute validate task from writing-plans")` — input: `contracts/validate-input-template.yaml`, output: `contracts/validate-output-template.yaml`, template: `contracts/validate-input-template.yaml`, chain: `step_13`
- [ ] 15. [z3-check] `solve check` — verify validate output has PASS status — chain: `step_14`
- [ ] 16. [sub-task: audit-fidelity] `task(..., prompt: "execute audit-fidelity task from writing-plans")` — input: `contracts/audit-fidelity-input-template.yaml`, output: `contracts/audit-fidelity-output-template.yaml`, template: `contracts/audit-fidelity-input-template.yaml`, chain: `step_15`
- [ ] 17. [z3-check] `solve check` — verify audit-fidelity output has PASS — chain: `step_16`
- [ ] 18. [sub-task: audit-concern] `task(..., prompt: "execute audit-concern task from writing-plans")` — input: `contracts/audit-concern-input-template.yaml`, output: `contracts/audit-concern-output-template.yaml`, template: `contracts/audit-concern-input-template.yaml`, chain: `step_17`
- [ ] 19. [z3-check] `solve check` — verify audit-concern output has PASS — chain: `step_18`
- [ ] 20. [sub-task: completion] `task(..., prompt: "execute completion task from writing-plans")` — input: `contracts/completion-input-template.yaml`, output: `contracts/completion-output-template.yaml`, template: `contracts/completion-input-template.yaml`, chain: `step_19`
- [ ] 21. [z3-check] `solve check` — verify completion output has lifecycle event — chain: `step_20`

## Entry Criteria

- Spec is approved and stored in `.issues/{N}/spec.md`
- `authorization_scope` received from approval-gate (for cascade)

## Exit Criteria

- Plan stored at `.issues/{N}/plan.md`
- All validation passed
- Plan reported in chat with `.issues/{N}/plan.md` path
- Approval cascade applied (auto-approval for pipeline scope)

## Plan Format

Plan is stored at `.issues/{N}/plan.md`. Combined and separate affect which sections the plan document includes but not where it is stored.

**Combined (single-task):**
- Write to `.issues/{N}/plan.md`, reference spec content inline
- Retain `[SPEC]` title prefix on spec

**Separate (multi-task):**
- Write to `.issues/{N}/plan.md` with separate phase sections
- Phases are sections in the local plan file — no sub-issues

## Plan Format Requirements

Every plan document MUST follow this structure. Plans that deviate from this format are invalid and MUST be rejected.

### Required Sections (in order)

1. **Title** — `# Implementation Plan — [<issue-ref>](<issue-url>) — <short-description>`
2. **Goal/Architecture/Files** — Bullet list with `**Goal:**`, `**Architecture:**`, `**Files:**` entries
3. **Admonishment** — Verbatim compliance requirement blockquote:
   ```
   > **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.
   ```
4. **Phase sections** — One `## Phase N — <name>` per phase, each with:
   - Phase metadata (Concern, Files, SCs, Dependencies, Entry/Exit conditions)
   - Sequential numbered steps with dispatch indicators
   - Sub-steps indented under parent steps
   - RED+green item chains with interleaved ordering
   - SC annotations on each step
   - Phase completion block
   - Concern transition to next phase
5. **Bottom admonishment** — Verbatim compliance requirement blockquote
6. **Exit Criteria** — Numbered checklist `C1` through `C{N}`

### Dispatch Indicators

Every step MUST use one of three dispatch indicators:

| Indicator | Meaning | Example |
|-----------|---------|---------|
| `(**sub-agent**)` | Orchestrator dispatches a clean-room sub-agent via `task()` | `3. **RED (**sub-agent**).**` |
| `(**clean-room**)` | Orchestrator dispatches a clean-room sub-agent (same as sub-agent) | `1. **Coherence gate (**clean-room**).**` |
| `(**inline**)` | Orchestrator executes directly (no sub-agent) | `6. **Checkpoint commit (**inline**).**` |

### Prohibited Patterns

- **No dispatch tables** — do not include implementation-pipeline dispatch tables in plan files. The plan defines WHAT to do; the orchestrator determines HOW to dispatch.
- **No hardcoded gate sequences** — do not copy gate labels from implementation-pipeline. Reference them by name only.
- **No TBD/TODO** — all file paths, function names, and commands must be exact.
- **No shared cross-references** — each phase is self-contained. Do not reference steps from other phases.
- **No zero-indexed numbering** — phases start at 1, steps start at 1.
- **No line number references** — use stable anchors (function names, section headers).

### Validation Rules

1. Title matches issue number and description
2. Goal/Architecture/Files present and non-empty
3. Admonishment present verbatim at top and bottom
4. At least one phase section
5. Each phase has Concern, Files, SCs, Dependencies metadata
6. Each phase has sequential numbered steps
7. Each step has a dispatch indicator
8. RED+green items have interleaved ordering (RED → GREEN → doublecheck → commit)
9. SC annotations reference valid SC IDs from the spec
10. Phase completion block present after last step
11. Concern transition present between phases
12. Exit criteria present and numbered C1-C{N}

### RED+green Item Chain Specification

Each implementation item follows the chain: RED → GREEN → GREEN doublecheck → Checkpoint commit. Steps are interleaved — all 4 sub-steps for one item complete before the next item begins.

### Phase Completion Block

After the last step of each phase, include a completion block:
```
#### Phase N VbC

- [ ] {N}. **VbC (**clean-room**).** <verification assertions> **→ SC-{ids}**
```

### Concern Transition

Between phases, include a concern transition line:
```
**Concern transition:** Leaving <prior concern> → entering <new concern>. Phase N+1 depends on Phase N <deliverable>.
```

### Exit Criteria

Numbered checklist C1 through C{N} at the end of the plan, after the bottom admonishment.

## Approval Cascade Matrix

| Scope | Plan Approval | Implementation |
| -- | -- | -- |
| `for_review_prep` | Separate approval required | Separate approval required |
| `for_spec` | N/A | N/A |
| `for_analysis` | N/A (analysis-only) | N/A |
| `for_plan` | Auto-approved | Separate approval required |
| `for_implementation` | Auto-approved | Auto-approved |
| `for_pr` | Auto-approved | Auto-approved |
| `for_pr_only` | N/A (skip) | N/A |

## Authorization Context

```
authorization_scope: <for_analysis|for_spec|for_plan|for_implementation|for_review_prep|for_pr|for_pr_only|for_review_only>
halt_at: <analysis_complete|spec_created|plan_created|verification_complete|review_prep|pr_created>
pr_strategy: <none|stacked>
pipeline_phase: <current_phase_name>
authorization_source: "User approved #N on YYYY-MM-DD"
```

### Task() Rules
- Missing `authorization_scope` in task context → return `status: BLOCKED`
- Instructed to exceed `halt_at` → return `status: BLOCKED`

## Context Required

- Related skills: `verification-enforcement`, `issue-operations`, `spec-creation`, `adversarial-audit`, `solve`, `plan`
- Related tasks: `research`, `readiness`, `structure`, `solve`, `write`, `revisit`, `validate`, `audit-fidelity`, `audit-concern`, `completion`
