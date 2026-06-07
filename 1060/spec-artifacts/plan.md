# Implementation Plan — Spec Structure Expansion (#1060)

## STATUS: plan
## SCOPE: spec-structure-expansion
## AUTHORIZATION: for_plan (halt after plan_created)
## PARENT SPEC: [#1060](https://github.com/michael-conrad/.opencode/issues/1060)
## 14-PIPELINE: solve-check-before-dispatch

## Plan Model

**Single-task combined plan** — all changes target one file (`write.md`). Items are sequential per-item TDD cycles within a single implementation phase. No sub-issues.

## Item Decomposition — 5 Items, 22 SCs

| Item | SCs | Description | File | Nature |
|------|-----|-------------|------|--------|
| A | SC-1..SC-6, SC-16, SC-17 | Add 8 SC table columns to Step 3 with per-column conditions | `write.md` | Text/formatting |
| B | SC-7..SC-10, SC-18, SC-19 | Add 5 preamble section definitions (Decision Ledger, Risk Traceability, Revision Policy, Decomposition Classification, Spec Family) to Step 1 | `write.md` | Text/formatting |
| C | SC-11, SC-12, SC-15 | Add Explicit Non-Goals, Regression Invariants, Common SC designation as mandatory content areas | `write.md` | Text/formatting |
| D | SC-13, SC-14 | Add SC-to-SC coherence check and Verification-Method-to-Artifact-Path consistency check to Step 6 self-review | `write.md` | Text/formatting |
| E | SC-20, SC-21, SC-22 | Add Step 7a (exec-summary format rules), Step 7b (remote push + local mirror), pre-Step-0.8 (stub creation) | `write.md` | Text/formatting (SC-22: behavioral) |

## Dependency Order

```
Item A (SC table columns) — no dependencies
  ↓
Item B (preamble sections) — no dependencies on A (preamble is Step 1, table columns are Step 3)
  ↓
Item C (content areas) — no dependencies on A/B (Non-Goals and Regression Invariants are standalone sections)
  ↓
Item D (self-review substeps) — depends on A (coherence check references SC table columns)
  ↓
Item E (new steps) — no dependencies on A-D (new Step 7a/b, pre-Step-0.8 are standalone)
```

**Exception:** Item D depends on Item A because the SC-to-SC coherence check references metadata found in SC table columns. The other items are structurally independent (different sections of `write.md`) and can be built in any order.

## Item B-C Step 1 Insertion Boundary (Auditor Finding Remediation)

Items B and C both target Step 1 of `write.md` (lines 46-84). To prevent edit overlap:

| Item | Target Sub-Location | Insertion Mode |
|------|--------------------|----------------|
| B (preamble sections) | AFTER the existing Step 1 content area bullet list (after line 56: "Skip areas that don't apply...") | **Append** new subsection blocks after the bullet list, before the Documentation Sources section |
| C (content areas) | WITHIN the existing Step 1 content area bullet list (lines 50-56) | **Modify** existing bullet items: add Non-Goals (line 52 "Constraints and scope" area), add Regression Invariants (new bullet after Non-Goals), add Common SC designation as a preamble section marker (NOT a column annotation) |

**SC-15 cross-cutting fix:** Common SC designation (SC-15) is pinned to **preamble section marker** approach (not column annotation). This eliminates the cross-cutting risk between Items A and C. If the preamble marker approach proves insufficient during implementation, the orchestrator must halt and report to developer — no unplanned column annotation changes.

**Ordering:** Item B runs first (adds preamble section blocks after existing content area). Item C runs second (modifies existing content area bullets, now shifted by B's additions).

## Item D Dependency Rule

Item D (self-review substeps) MUST NOT be dispatched until Item A has at least passed the GREEN phase. The coherence check substep references Pipeline Step Binding and Verification Gate columns added in Item A — without those columns existing in the text, the check has nothing to reference.

## 14-Step Solve-Verified Dispatch Pipeline

**Every item goes through the 14-step pipeline.** Before EACH step dispatches, `solve check` validates that the pipeline state machine permits the transition:

### Solve-Gate Protocol (MANDATORY before every dispatch)

Before dispatching any pipeline step, the orchestrator runs:

```bash
solve check --state-path ./tmp/state/1060/pipeline/ \
  --contract-path .opencode/skills/implementation-pipeline/pipeline-state-machine.yaml
```

**If solve check FAILS:** The orchestrator reads the solver's output to determine which precondition was violated. Common causes:
- State file not initialized (run `solve state init` first at step 2)
- `previous_step` not updated from prior step
- Attempted to jump to a step not in the legal transition graph

**Remediation on solve check FAIL:** Identify the missing state variable, update it via `solve state update`, and re-run `solve check`. Do NOT proceed until solve check PASSES.

**If solve check PASSES:** The transition is proven valid. Dispatch the step.

### Per-Step Solve State Updates

After each step returns and its artifact is written, update pipeline position:

```bash
# Step N completed — record previous step
solve state update ./tmp/state/1060/pipeline/ \
  --var-name previous_step --var-value <STEP_N_LABEL> \
  --contract-path .opencode/skills/implementation-pipeline/pipeline-state-machine.yaml

# Set current step to next step
solve state update ./tmp/state/1060/pipeline/ \
  --var-name current_step --var-value <STEP_N+1_LABEL> \
  --contract-path .opencode/skills/implementation-pipeline/pipeline-state-machine.yaml

# Set pipeline state
solve state update ./tmp/state/1060/pipeline/ \
  --var-name pipeline_state --var-value running \
  --contract-path .opencode/skills/implementation-pipeline/pipeline-state-machine.yaml

# Verify transition is legal
solve check --state-path ./tmp/state/1060/pipeline/ \
  --contract-path .opencode/skills/implementation-pipeline/pipeline-state-machine.yaml
```

### State Initialization (Item A, Step 2: pre-red-baseline)

```bash
solve state init ./tmp/state/1060/pipeline/
# Creates: current_step=pre-red-baseline, pipeline_state=init, previous_step=init
```

### Full Pipeline Table (per item)

| Pipeline Step | Dispatch Target | Solve Action | Artifact Produced |
|---------------|----------------|--------------|-------------------|
| 1. sc-coherence-gate | `adversarial-audit --task coherence-extraction` | solve check before dispatch | `./tmp/artifacts/pipeline-1060-{item}-sc-coherence-gate-{STATUS}-{ts}.yaml` |
| 2. pre-red-baseline | `solve state init` + baseline capture | solve check, then init | `./tmp/state/1060/pipeline/state.yaml` |
| 3. red-phase | `test-driven-development --task red` | solve check before dispatch | `./tmp/artifacts/pipeline-1060-{item}-red-phase-{STATUS}-{ts}.yaml` |
| 4. red-doublecheck | `verification-before-completion --task verify` | solve check before dispatch | `./tmp/artifacts/pipeline-1060-{item}-red-doublecheck-{STATUS}-{ts}.yaml` |
| 5. green-phase | `test-driven-development --task green` | solve check before dispatch | `./tmp/artifacts/pipeline-1060-{item}-green-phase-{STATUS}-{ts}.yaml` |
| 6. checkpoint-commit | `git-workflow --task commit-prep` | solve check before dispatch | `./tmp/artifacts/pipeline-1060-{item}-checkpoint-commit-{STATUS}-{ts}.yaml` |
| 7. structural-checks | `finishing-a-development-branch --task checklist` | solve check before dispatch | `./tmp/artifacts/pipeline-1060-{item}-structural-checks-{STATUS}-{ts}.yaml` |
| 8. green-doublecheck | `verification-before-completion --task verify` | solve check before dispatch | `./tmp/artifacts/pipeline-1060-{item}-green-doublecheck-{STATUS}-{ts}.yaml` |
| 9. green-vbc | `verification-before-completion --task completion` | solve check before dispatch | `./tmp/artifacts/pipeline-1060-{item}-green-vbc-{STATUS}-{ts}.yaml` |
| 10. adversarial-audit | `adversarial-audit --task verification-audit` | solve check before dispatch | `./tmp/artifacts/pipeline-1060-{item}-audit-{type}-{STATUS}-{ts}.yaml` |
| 11. cross-validate | `adversarial-audit --task cross-validate` | solve check before dispatch | `./tmp/artifacts/pipeline-1060-{item}-cross-validate-{STATUS}-{ts}.yaml` |
| 12. regression-check | `test-driven-development --task patterns` (regression) | solve check before dispatch | `./tmp/artifacts/pipeline-1060-{item}-regression-check-{STATUS}-{ts}.yaml` |
| 13. review-prep | `git-workflow --task review-prep` | solve check before dispatch | review-prep status |
| 14. exec-summary | `completion-core --task completion` | solve check before dispatch | push status + commit |

### Item Transition Between Pipeline Runs

After Item A completes the full 14-step pipeline (step 14 exec-summary), the pipeline state is at `exec-summary` with `pipeline_state: complete`. Before dispatching Item B's step 2 (pre-red-baseline):

```bash
solve state update ./tmp/state/1060/pipeline/ \
  --var-name previous_step --var-value exec-summary \
  --contract-path .opencode/skills/implementation-pipeline/pipeline-state-machine.yaml

solve state update ./tmp/state/1060/pipeline/ \
  --var-name current_step --var-value pre-red-baseline \
  --contract-path .opencode/skills/implementation-pipeline/pipeline-state-machine.yaml

solve state update ./tmp/state/1060/pipeline/ \
  --var-name pipeline_state --var-value running \
  --contract-path .opencode/skills/implementation-pipeline/pipeline-state-machine.yaml

solve check ...
```

This re-uses the same state file across all 5 items — the state machine permits `exec-summary → pre-red-baseline` through the `previous_step == exec-summary` domain entry for `pre-red-baseline` (init only gates `init → pre-red-baseline` on first use; subsequent resets go through `previous_step: exec-summary → current_step: pre-red-baseline` — this is valid because `previous_step` domain includes `exec-summary` and the state is manually updated).

## Per-Item TDD Specification

### Item A — SC Table Columns (SC-1 through SC-6, SC-16, SC-17)

**Target:** `write.md` Step 3 SC table format section

**Changes:**
- Expand 4-column table template to 12 columns (4 existing + 8 new)
- Add column header definitions for each new column with per-column conditionality
- Pipeline Step Binding: mandatory all tiers
- Artifact Path: mandatory all tiers, `./tmp/{issue-N}/` convention
- Requirement Traceability: mandatory all tiers (MUST language)
- Phase Binding: multi-phase only (condition annotation)
- Verification Gate: 3 tiers (red-green, pre-commit, ci) with per-tier semantics
- Integration Mode: required when Gate=ci, optional otherwise
- Affinity Group: optional, with use-case examples
- Re-Entry Step: all tiers (MUST language)
- Add rendering note: "For multi-column tables exceeding 8 columns, split into a core table (ID + Criterion + Verification Method + Remediation) with a companion metadata table cross-referenced by SC ID."
- Add evidence type classification gate (from existing `write.md` §Evidence Type Classification Gate) as a substep after column definitions

**SC verification:**
- SC-1: grep for all 12 column headers in write.md
- SC-2: grep for Requirement Traceability + MUST language
- SC-3: grep for Phase Binding + conditional/multi-phase-only marker
- SC-4: grep for Verification Gate + 3 tiers (red-green, pre-commit, ci)
- SC-5: grep for Integration Mode + Gate=ci condition
- SC-6: grep for Re-Entry Step + all-tiers mandatory qualifier
- SC-16: grep for Affinity Group + optional marker
- SC-17: grep for Artifact Path + ./tmp/{issue-N}/ convention

**Evidence type:** All `string` (grep-based content verification)

### Item B — Preamble Sections (SC-7 through SC-10, SC-18, SC-19)

**Target:** `write.md` Step 1 preamble sections

**Changes:**
- Add Decision Ledger section definition: stable DEC-IDs with RFC 2119 requirement keys (MUST/SHOULD/MAY), example table included
- Add Risk Traceability Table: RISK-IDs with Verifying SC binding, example table included
- Add Revision Policy: artifact cascade declarations — when parent spec revised, which dependent artifacts MUST also be revised, declarative table format
- Add Decomposition Classification: single-task vs multi-phase distinguishing criteria table (number of phases, sub-issue requirements, PR strategy)
- Add Spec Family Annotation: optional (punch list), semantics and selector syntax documented
- Each section: 1-2 sentence purpose definition + example block

**SC verification:**
- SC-7: grep for all 5 section headers + purpose sentences in write.md
- SC-8: grep for DEC-ID prefix + RFC 2119 key headers
- SC-9: grep for RISK-ID prefix + Verifying SC binding column
- SC-10: grep for Revision Policy + cascade declaration pattern
- SC-18: grep for both classification values (single-task, multi-phase) + distinguishing criteria table
- SC-19: grep for optional qualifier + selector syntax

**Evidence type:** All `string`

### Item C — Mandatory Content Areas (SC-11, SC-12, SC-15)

**Target:** `write.md` Step 1 content areas

**Changes:**
- Add `## Explicit Non-Goals` as mandatory content area (not optional) with template header and bullet list of exclusions
- Add `## Regression Invariants` as mandatory subsection appearing after Non-Goals, with numbered list of things that MUST NOT change
- Add Cross-cutting/Common SC designation rules: column annotation or preamble section marker, semantics defined (shares verification budget, MUST pass once for all phases)

**SC verification:**
- SC-11: grep for `## Explicit Non-Goals` header
- SC-12: grep for `## Regression Invariants` header
- SC-15: grep for cross-cutting/common SC designation rules

**Evidence type:** All `string`

### Item D — Self-Review Substeps (SC-13, SC-14)

**Target:** `write.md` Step 6 self-review

**Changes:**
- Add SC-to-SC coherence check substep: pairwise comparison scan for contradictions, appended after existing Step 6 checkpoints
- Add Verification-Method-to-Artifact-Path consistency check: cross-column comparison, verify Artifact Path matches Verification Method tool references, appended after coherence check

**SC verification:**
- SC-13: grep for coherence check language in write.md Step 6
- SC-14: grep for consistency check language in write.md Step 6

**Evidence type:** All `string`

### Item E — New Steps (SC-20, SC-21, SC-22)

**Target:** `write.md` — insertions between existing steps

**Changes:**
- Add Step 7a (after Step 7, before Step 8): exec-summary format rules — no checkboxes, no status markers, no completion flags; cards in dependency order; Key Decisions and Risk Callouts sections; rules table with rationale
- Add Step 7b (after Step 7a): remote push + local mirror requirement — `.issues/{N}/remote-exec-summary.md` saved after each remote body update
- Add pre-Step-0.8 (after card catalogue, before requirements extraction): stub creation via `local-issues create` with minimal exec summary + platform availability check

**SC verification:**
- SC-20: grep for Step 7a with no-tracking rule language + template block
- SC-21: grep for remote-exec-summary.md reference
- SC-22: **behavioral** — dispatching a stub creation before requirements extraction (requires behavioral RED/GREEN with `opencode-cli run`)

**Evidence type:** SC-20, SC-21: `string`. SC-22: `behavioral` (requires behavioral enforcement test)

## Word Count Risk Mitigation

Per Card 7 in the card catalogue and RISK-1 in the spec:

| Item | Estimated Added Words | Cumulative |
|------|----------------------|------------|
| Current | — | ~2,700 |
| A (columns) | ~300 | ~3,000 |
| B (preamble) | ~400 | ~3,400 |
| C (content areas) | ~150 | ~3,550 |
| D (self-review) | ~200 | ~3,750 |
| E (new steps) | ~250 | ~4,000 |

If `write.md` exceeds 2,800 words during Item A or B:

1. STOP adding preamble section full definitions to `write.md`
2. Create `.opencode/skills/spec-creation/reference/preamble-sections.md` with the full Decision Ledger, Risk Traceability, Revision Policy, Decomposition Classification, and Spec Family definitions
3. In `write.md`, replace each section definition with a one-sentence include statement: "See `reference/preamble-sections.md` for the [Section Name] template and example."
4. Continue with remaining items using the reference-file pattern

**Trigger:** `wc -w .opencode/skills/spec-creation/tasks/write.md > 2800` after any item's GREEN phase.

## Cross-References

- Parent spec: [#1060](https://github.com/michael-conrad/.opencode/issues/1060)
- Card catalogue: `./spec-artifacts/cards.md`
- Pipeline state machine: `.opencode/skills/implementation-pipeline/pipeline-state-machine.yaml`
- Pipeline executor: `.opencode/skills/implementation-pipeline/tasks/pipeline-executor.md`
- Solve tool: `.opencode/tools/solve`
- Plan tool: `.opencode/tools/plan`
- PDDL domain: `./tmp/pddl/1060/domain.yaml`

<!-- Provenance: AI-generated -->
<!-- Co-authored with AI: OpenCode (deepseek-v4-flash) -->