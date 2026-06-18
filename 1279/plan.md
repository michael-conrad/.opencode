# Implementation Plan — #1279

## Goal

Define a 10-type semantic change type taxonomy for skill card and task card modifications, stored as a reference document, with cross-references from spec-creation and writing-plans, validated by Z3 solve and plan tool.

## Architecture

- **Reference document**: `.opencode/skills/reference/skill-card-change-types.md` — taxonomy table (10 types, 7 fields each)
- **Cross-reference targets**: `spec-creation/SKILL.md` and `writing-plans/SKILL.md` — add taxonomy link to Cross-References section
- **Validation**: Z3 solve contract generation + plan tool phase solvability analysis

## Tech Stack

- Markdown for reference document
- YAML for solve contracts
- `.opencode/tools/solve` (Z3 solver)
- `.opencode/tools/plan` (plan solver)

## File Structure

| Path | Responsibility |
|------|---------------|
| `.opencode/skills/reference/skill-card-change-types.md` | Taxonomy reference document (all 10 types with all fields) |
| `.opencode/skills/spec-creation/SKILL.md` | Cross-References section update |
| `.opencode/skills/writing-plans/SKILL.md` | Cross-References section update |
| `.opencode/.issues/1279/contracts/workflow-validation/` | Solve contract and plan output evidence artifacts |

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Phase 1: Create Taxonomy Reference Document

**Concern:** Create the taxonomy reference document at `.opencode/skills/reference/skill-card-change-types.md` with all 10 semantic change types and the Mandatory Workflow Validation Rule section.

**Files:** `.opencode/skills/reference/skill-card-change-types.md`

**SCs covered:** SC-1, SC-2, SC-3, SC-4, SC-5, SC-6

### Dispatch Table

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|----------------|-----------------|-----|
| G1: sc-coherence-gate | sub-task | yes (blind) | general | `{"task":"execute sc-coherence-gate from implementation-pipeline","issue_number":1279,"phase":1}` | SC-1 |
| G2: pre-red-baseline | sub-task | yes (blind) | general | `{"task":"execute pre-red-baseline from implementation-pipeline","issue_number":1279,"phase":1}` | — |
| G3: red-phase | sub-task | yes (blind) | general | `{"task":"execute red-phase from implementation-pipeline","issue_number":1279,"phase":1}` | SC-1 |
| G4: red-doublecheck | sub-task | yes (blind) | general | `{"task":"execute red-doublecheck from implementation-pipeline","issue_number":1279,"phase":1}` | SC-1 |
| G5: post-red-enforcement | sub-task | yes (blind) | general | `{"task":"execute post-red-enforcement from implementation-pipeline","issue_number":1279,"phase":1}` | — |
| G6: green-phase | sub-task | yes (blind) | general | `{"task":"execute green-phase from implementation-pipeline","issue_number":1279,"phase":1}` | SC-1 |
| G7: post-green-enforcement | sub-task | yes (blind) | general | `{"task":"execute post-green-enforcement from implementation-pipeline","issue_number":1279,"phase":1}` | — |
| G8: checkpoint-commit | inline | N/A | N/A | — | — |
| G9: structural-checks | sub-task | yes (blind) | general | `{"task":"execute structural-checks from implementation-pipeline","issue_number":1279,"phase":1}` | SC-2, SC-3, SC-4, SC-5, SC-6 |
| G10: green-doublecheck | sub-task | yes (blind) | general | `{"task":"execute green-doublecheck from implementation-pipeline","issue_number":1279,"phase":1}` | SC-2, SC-3, SC-4, SC-5, SC-6 |
| G11: green-vbc | sub-task | yes (blind) | general | `{"task":"execute green-vbc from implementation-pipeline","issue_number":1279,"phase":1}` | SC-2, SC-3, SC-4, SC-5, SC-6 |
| G12: adversarial-audit | sub-task | yes (blind) | general | `{"task":"execute adversarial-audit from implementation-pipeline","issue_number":1279,"phase":1}` | SC-2, SC-3, SC-4, SC-5, SC-6 |
| G13: cross-validate | sub-task | yes (blind) | general | `{"task":"execute cross-validate from implementation-pipeline","issue_number":1279,"phase":1}` | SC-2, SC-3, SC-4, SC-5, SC-6 |
| G14: regression-check | sub-task | yes (blind) | general | `{"task":"execute regression-check from implementation-pipeline","issue_number":1279,"phase":1}` | — |
| G15: review-prep | sub-task | yes (blind) | general | `{"task":"execute review-prep from implementation-pipeline","issue_number":1279,"phase":1}` | — |
| G16: exec-summary | sub-task | yes (blind) | general | `{"task":"execute exec-summary from implementation-pipeline","issue_number":1279,"phase":1}` | — |

### Concern Boundary (Phase 1 → Phase 2)

- **Leaving:** Document creation concern — writing the reference taxonomy document
- **Entering:** Cross-reference concern — updating existing skill cards to reference the new document
- **Handoff:** Phase 1 must produce `.opencode/skills/reference/skill-card-change-types.md` with all 10 types. Phase 2 reads this file to verify cross-reference target exists.

## Phase 2: Add Cross-References

**Concern:** Add cross-references from `spec-creation/SKILL.md` and `writing-plans/SKILL.md` to the taxonomy reference document.

**Files:** `.opencode/skills/spec-creation/SKILL.md`, `.opencode/skills/writing-plans/SKILL.md`

**SCs covered:** SC-7, SC-8

### Dispatch Table

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|----------------|-----------------|-----|
| G1: sc-coherence-gate | sub-task | yes (blind) | general | `{"task":"execute sc-coherence-gate from implementation-pipeline","issue_number":1279,"phase":2}` | SC-7, SC-8 |
| G2: pre-red-baseline | sub-task | yes (blind) | general | `{"task":"execute pre-red-baseline from implementation-pipeline","issue_number":1279,"phase":2}` | — |
| G3: red-phase | sub-task | yes (blind) | general | `{"task":"execute red-phase from implementation-pipeline","issue_number":1279,"phase":2}` | SC-7, SC-8 |
| G4: red-doublecheck | sub-task | yes (blind) | general | `{"task":"execute red-doublecheck from implementation-pipeline","issue_number":1279,"phase":2}` | SC-7, SC-8 |
| G5: post-red-enforcement | sub-task | yes (blind) | general | `{"task":"execute post-red-enforcement from implementation-pipeline","issue_number":1279,"phase":2}` | — |
| G6: green-phase | sub-task | yes (blind) | general | `{"task":"execute green-phase from implementation-pipeline","issue_number":1279,"phase":2}` | SC-7, SC-8 |
| G7: post-green-enforcement | sub-task | yes (blind) | general | `{"task":"execute post-green-enforcement from implementation-pipeline","issue_number":1279,"phase":2}` | — |
| G8: checkpoint-commit | inline | N/A | N/A | — | — |
| G9: structural-checks | sub-task | yes (blind) | general | `{"task":"execute structural-checks from implementation-pipeline","issue_number":1279,"phase":2}` | SC-7, SC-8 |
| G10: green-doublecheck | sub-task | yes (blind) | general | `{"task":"execute green-doublecheck from implementation-pipeline","issue_number":1279,"phase":2}` | SC-7, SC-8 |
| G11: green-vbc | sub-task | yes (blind) | general | `{"task":"execute green-vbc from implementation-pipeline","issue_number":1279,"phase":2}` | SC-7, SC-8 |
| G12: adversarial-audit | sub-task | yes (blind) | general | `{"task":"execute adversarial-audit from implementation-pipeline","issue_number":1279,"phase":2}` | SC-7, SC-8 |
| G13: cross-validate | sub-task | yes (blind) | general | `{"task":"execute cross-validate from implementation-pipeline","issue_number":1279,"phase":2}` | SC-7, SC-8 |
| G14: regression-check | sub-task | yes (blind) | general | `{"task":"execute regression-check from implementation-pipeline","issue_number":1279,"phase":2}` | — |
| G15: review-prep | sub-task | yes (blind) | general | `{"task":"execute review-prep from implementation-pipeline","issue_number":1279,"phase":2}` | — |
| G16: exec-summary | sub-task | yes (blind) | general | `{"task":"execute exec-summary from implementation-pipeline","issue_number":1279,"phase":2}` | — |

### Concern Boundary (Phase 2 → Phase 3)

- **Leaving:** Cross-reference concern — updating skill card Cross-References sections
- **Entering:** Validation concern — running Z3 solve and plan tool to validate the taxonomy structure and phase structure
- **Handoff:** Phase 2 must produce updated `.opencode/skills/spec-creation/SKILL.md` and `.opencode/skills/writing-plans/SKILL.md` with taxonomy cross-references. Phase 3 does not depend on Phase 2 output — validation is on the taxonomy document itself.

## Phase 3: Z3 SAT and Plan Tool Validation

**Concern:** Generate solve contract for taxonomy structure, run `solve check` (must return SAT), run `plan plan` (must return SOLVED_SATISFICING or SOLVED_OPTIMALLY), and store evidence artifacts.

**Files:** `.opencode/.issues/1279/contracts/workflow-validation/`

**SCs covered:** SC-9, SC-10

### Dispatch Table

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|----------------|-----------------|-----|
| G1: sc-coherence-gate | sub-task | yes (blind) | general | `{"task":"execute sc-coherence-gate from implementation-pipeline","issue_number":1279,"phase":3}` | SC-9, SC-10 |
| G2: pre-red-baseline | sub-task | yes (blind) | general | `{"task":"execute pre-red-baseline from implementation-pipeline","issue_number":1279,"phase":3}` | — |
| G3: red-phase | sub-task | yes (blind) | general | `{"task":"execute red-phase from implementation-pipeline","issue_number":1279,"phase":3}` | SC-9, SC-10 |
| G4: red-doublecheck | sub-task | yes (blind) | general | `{"task":"execute red-doublecheck from implementation-pipeline","issue_number":1279,"phase":3}` | SC-9, SC-10 |
| G5: post-red-enforcement | sub-task | yes (blind) | general | `{"task":"execute post-red-enforcement from implementation-pipeline","issue_number":1279,"phase":3}` | — |
| G6: green-phase | sub-task | yes (blind) | general | `{"task":"execute green-phase from implementation-pipeline","issue_number":1279,"phase":3}` | SC-9, SC-10 |
| G7: post-green-enforcement | sub-task | yes (blind) | general | `{"task":"execute post-green-enforcement from implementation-pipeline","issue_number":1279,"phase":3}` | — |
| G8: checkpoint-commit | inline | N/A | N/A | — | — |
| G9: structural-checks | sub-task | yes (blind) | general | `{"task":"execute structural-checks from implementation-pipeline","issue_number":1279,"phase":3}` | SC-9, SC-10 |
| G10: green-doublecheck | sub-task | yes (blind) | general | `{"task":"execute green-doublecheck from implementation-pipeline","issue_number":1279,"phase":3}` | SC-9, SC-10 |
| G11: green-vbc | sub-task | yes (blind) | general | `{"task":"execute green-vbc from implementation-pipeline","issue_number":1279,"phase":3}` | SC-9, SC-10 |
| G12: adversarial-audit | sub-task | yes (blind) | general | `{"task":"execute adversarial-audit from implementation-pipeline","issue_number":1279,"phase":3}` | SC-9, SC-10 |
| G13: cross-validate | sub-task | yes (blind) | general | `{"task":"execute cross-validate from implementation-pipeline","issue_number":1279,"phase":3}` | SC-9, SC-10 |
| G14: regression-check | sub-task | yes (blind) | general | `{"task":"execute regression-check from implementation-pipeline","issue_number":1279,"phase":3}` | — |
| G15: review-prep | sub-task | yes (blind) | general | `{"task":"execute review-prep from implementation-pipeline","issue_number":1279,"phase":3}` | — |
| G16: exec-summary | sub-task | yes (blind) | general | `{"task":"execute exec-summary from implementation-pipeline","issue_number":1279,"phase":3}` | — |

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

---

## Spec-to-Plan SC Coverage

| SC ID | Criterion | Phase | Verification Method |
|-------|-----------|-------|---------------------|
| SC-1 | Taxonomy document exists at `.opencode/skills/reference/skill-card-change-types.md` | Phase 1 | `test -f` |
| SC-2 | Document defines all 10 types with Name, Description, Blast Radius, Remediation Guidance, Validation, Workflow Validation | Phase 1 | `grep -c "^### Type" == 10` |
| SC-3 | Each type has Blast Radius | Phase 1 | `grep -c "Blast Radius" == 10` |
| SC-4 | Each type has Remediation Guidance | Phase 1 | `grep -c "Remediation Guidance" == 10` |
| SC-5 | Each type has Workflow Validation | Phase 1 | `grep -c "Workflow Validation" == 10` |
| SC-6 | Document includes Mandatory Workflow Validation Rule section | Phase 1 | `grep -q "Mandatory Workflow Validation Rule"` |
| SC-7 | spec-creation/SKILL.md Cross-References references taxonomy | Phase 2 | `grep -q "skill-card-change-types"` |
| SC-8 | writing-plans/SKILL.md Cross-References references taxonomy | Phase 2 | `grep -q "skill-card-change-types"` |
| SC-9 | `solve check` returns SAT for taxonomy structure contract | Phase 3 | `./.opencode/tools/solve check --contract-path` returns SAT |
| SC-10 | `plan plan` validates phase structure | Phase 3 | `./.opencode/tools/plan plan --problem` returns SOLVED_SATISFICING or SOLVED_OPTIMALLY |

## Approval Cascade

| Scope | Plan Approval | Notes |
|-------|--------------|-------|
| `for_pr` | Auto-approved | Plan is local artifact — no separate authorization needed |

Created plan at `.opencode/.issues/1279/plan.md` for [michael-conrad/.opencode#1279](https://github.com/michael-conrad/.opencode/issues/1279) (Define semantic change type taxonomy for skill card and task card modifications). 3 phases across 10 SCs.

🤖 OpenCode (deepseek-v4-flash)