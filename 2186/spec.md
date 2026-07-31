> **Full spec and artifacts: [`.opencode/.issues/2186/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2186)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2186/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

### Objective
Create a new standalone skill `implementation-verification` that performs a DiMo chain (Investigator → Validator → Evaluator → Arbiter) SC-by-SC implementation audit against the codebase when a spec is approved, then routes 3-way: ALL PASS (close issue), PARTIAL (remediate failing SCs), ALL FAIL (normal pipeline).

### Background
The current `verify-already-implemented` gate in `approval-gate-scope` has three defects:
1. **Utterance-triggered, not auto-dispatched** — fires only when user says "verify already implemented"
2. **Inline verification, no DiMo chain** — single task card does SC-by-SC check without clean-room role separation
3. **Binary routing only** — all PASS → close, any FAIL → proceed. No PARTIAL branch for specs where some SCs are already satisfied.

The fix creates a dedicated `implementation-verification` skill with proper DiMo chain and 3-way routing.

### Fix

The following changes address the label mapping defects in the current audit chain, where label application was split across Validator and Evaluator instead of being centralized in the Arbiter:

1. **Validator (`spec-audit-validator.md`)**: Remove Step 0.1 label application (`spec-passed-review` / `spec-under-review`). The Validator validates evidence — it does not determine audit outcome, so it should not apply outcome labels.

2. **Evaluator (`spec-audit-evaluator.md`)**: Remove the label application from Step 4 (holistic PASS branch). Keep the `spec-under-review` application in Step 0.1 (marks start of audit). The Evaluator produces verdicts but the final label decision belongs to the Arbiter.

3. **Arbiter (`spec-audit-arbiter.md`)**: Add label application based on final judgment:
   - If `final_judgment.status == "PASS"`: apply `spec-passed-review`, remove all other `spec-*` labels
   - If `final_judgment.status == "DRAFT"`: apply `spec-under-review`, remove all other `spec-*` labels
   - If `final_judgment.status == "FAIL"`: apply `spec-remediation-required`, remove all other `spec-*` labels

### Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `skills/implementation-verification/SKILL.md` exists with valid frontmatter (name, description, license, provenance) | `structural` | File exists, frontmatter validates |
| SC-2 | SKILL.md has Workflows section describing 5 sequential task() dispatches: 4 DiMo roles + 1 routing | `string` | grep for "Workflows" section with 5 task() calls |
| SC-3 | SKILL.md has Trigger Dispatch Table with `implementation-verification` entry | `string` | grep for implementation-verification in TDT |
| SC-4 | SKILL.md has Invocation section with canonical dispatch strings for all 5 tasks | `string` | grep for Invocation section with 5 entries |
| SC-5 | `tasks/verify-implementation-investigator.md` exists with DiMo Investigator procedure | `structural` | File exists |
| SC-6 | `tasks/verify-implementation-validator.md` exists with DiMo Validator procedure | `structural` | File exists |
| SC-7 | `tasks/verify-implementation-evaluator.md` exists with DiMo Evaluator procedure | `structural` | File exists |
| SC-8 | `tasks/verify-implementation-arbiter.md` exists with DiMo Arbiter procedure | `structural` | File exists |
| SC-9 | `tasks/route-verdict.md` exists with 3-way routing logic (ALL PASS → close, PARTIAL → remediate, ALL FAIL → normal pipeline) | `structural` | File exists |
| SC-10 | `approval-gate/SKILL.md` TDT has entry auto-dispatching to `implementation-verification --task verify-implementation` on approval | `string` | grep for implementation-verification in approval-gate/SKILL.md TDT |
| SC-11 | `approval-gate-scope/SKILL.md` full-path workflow Step 13 dispatches to `implementation-verification` instead of inline `verify-already-implemented` | `string` | grep for implementation-verification in approval-gate-scope/SKILL.md Step 13 |
| SC-12 | `auto-dispatch.md` routing table handles 3-way verdict (ALL PASS, PARTIAL, ALL FAIL) from implementation-verification | `string` | grep for PARTIAL in auto-dispatch.md routing table |
| SC-13 | Arbiter applies labels based on final judgment: PASS → `spec-passed-review`, DRAFT → `spec-under-review`, FAIL → `spec-remediation-required` | `string` | grep for label application in spec-audit-arbiter.md Step 8.5 |
| SC-14 | Validator does NOT apply outcome labels (Step 0.1 removed) | `string` | grep confirms no `spec-passed-review` label application in spec-audit-validator.md |
| SC-15 | Evaluator does NOT apply outcome labels in Step 4 (only Step 0.1 `spec-under-review` remains) | `string` | grep confirms no `spec-passed-review` label application in spec-audit-evaluator.md Step 4 |

### Requirements
1. The `implementation-verification` skill SHALL have a SKILL.md with frontmatter, Overview, Persona, Workflows, TDT, Invocation, and Cross-References sections
2. The Workflows section SHALL describe 5 sequential task() dispatches: investigator → validator → evaluator → arbiter → route-verdict
3. Each DiMo role task card SHALL follow the same pattern as audit skill task cards: YAML frontmatter, Purpose, Dispatch Contract, Entry Criteria, Exit Criteria, Procedure, Result Contract, Error Handling, Cross-References
4. The investigator SHALL read the spec's SCs and scan the codebase, writing evidence.yaml with raw SC-vs-codebase mapping
5. The validator SHALL read evidence.yaml and validate each SC mapping against live code, writing reasoning.yaml
6. The evaluator SHALL read evidence.yaml + reasoning.yaml and produce per-SC PASS/FAIL verdicts, writing verdict.yaml
7. The arbiter SHALL read all 3 upstream artifacts and write judgment.yaml with aggregate verdict and next_step
8. The route-verdict task SHALL read judgment.yaml and return 3-way routing decision
9. The approval-gate/SKILL.md TDT SHALL auto-dispatch to implementation-verification on approval
10. The approval-gate-scope full-path workflow Step 13 SHALL route to implementation-verification
11. The auto-dispatch routing table SHALL handle 3-way verdict from implementation-verification
12. The old verify-already-implemented task files SHALL remain on disk (deprecated, not dispatched)
13. The Arbiter SHALL apply labels based on final judgment: PASS → `spec-passed-review`, DRAFT → `spec-under-review`, FAIL → `spec-remediation-required`, removing all other `spec-*` labels in each case
14. The Validator SHALL NOT apply outcome labels (Step 0.1 removed)
15. The Evaluator SHALL NOT apply outcome labels in Step 4; only Step 0.1 `spec-under-review` SHALL remain

### Items

| Item | SCs | Description |
|------|-----|-------------|
| 1 | SC-1, SC-2, SC-3, SC-4 | Create `skills/implementation-verification/SKILL.md` with frontmatter, Workflows, TDT, Invocation |
| 2 | SC-5 | Create `tasks/verify-implementation-investigator.md` |
| 3 | SC-6 | Create `tasks/verify-implementation-validator.md` |
| 4 | SC-7 | Create `tasks/verify-implementation-evaluator.md` |
| 5 | SC-8 | Create `tasks/verify-implementation-arbiter.md` |
| 6 | SC-9 | Create `tasks/route-verdict.md` |
| 7 | SC-10 | Update `approval-gate/SKILL.md` TDT + Invocation |
| 8 | SC-11 | Update `approval-gate-scope/SKILL.md` Step 13 |
| 9 | SC-12 | Update `auto-dispatch.md` routing table |
| 10 | SC-13, SC-14, SC-15 | Update label mapping: Arbiter Step 8.5, remove from Validator Step 0.1, remove from Evaluator Step 4 |

### Dependencies
- `audit` skill — DiMo chain pattern reference (task card structure, artifact format)
- `approval-gate` skill — TDT update for auto-dispatch
- `approval-gate-scope` skill — workflow Step 13 update, auto-dispatch routing update
- `reference/skill-card-schema.md` — SKILL.md frontmatter constraints
- `reference/skill-card-description-standards.md` — description format
- `reference/task-card-structure-standards.md` — task card format

### Traceability

| Requirement | SCs | Phase |
|-------------|-----|-------|
| R1, R2 | SC-1, SC-2, SC-3, SC-4 | 1 |
| R3, R4 | SC-5 | 1 |
| R3, R5 | SC-6 | 1 |
| R3, R6 | SC-7 | 1 |
| R3, R7 | SC-8 | 1 |
| R3, R8 | SC-9 | 1 |
| R9 | SC-10 | 2 |
| R10 | SC-11 | 2 |
| R11 | SC-12 | 2 |
| R12 | — | — |
| R13 | SC-13 | 3 |
| R14 | SC-14 | 3 |
| R15 | SC-15 | 3 |

### Phases

**Phase 1: Create implementation-verification skill (Items 1-6)**
- Create `skills/implementation-verification/SKILL.md`
- Create 5 task cards (4 DiMo roles + 1 routing)
- Files: `skills/implementation-verification/SKILL.md`, `skills/implementation-verification/tasks/*.md`

**Phase 2: Update routing to new skill (Items 7-9)**
- Update `approval-gate/SKILL.md` TDT + Invocation
- Update `approval-gate-scope/SKILL.md` Step 13
- Update `auto-dispatch.md` routing table
- Files: `approval-gate/SKILL.md`, `approval-gate-scope/SKILL.md`, `approval-gate-scope/tasks/verify-authorization/auto-dispatch.md`

**Phase 3: Centralize label mapping in Arbiter (Item 10)**
- Add Step 8.5 to `spec-audit-arbiter.md` with 3-way label mapping
- Remove Step 0.1 label application from `spec-audit-validator.md`
- Remove Step 4 label application from `spec-audit-evaluator.md` (keep Step 0.1)
- Files: `skills/audit/tasks/spec-audit-arbiter.md`, `skills/audit/tasks/spec-audit-validator.md`, `skills/audit/tasks/spec-audit-evaluator.md`

### Not Included
- Behavioral enforcement tests (scoped to separate implementation phase)
- Changes to the audit skill's DiMo pattern
- Changes to writing-plans, executing-plans, or any other skill
- Deletion of old verify-already-implemented task files (kept on disk, deprecated)
- Changes to the parent repo

### Change Control

| Date | Change | Reason | Authorized By |
|------|--------|--------|---------------|
| 2026-07-31 | Added Fix section with label mapping changes; added SC-13, SC-14, SC-15; added R13, R14, R15; added Item 10; added Phase 3; added Step 8.5 to Arbiter; removed Step 0.1 from Validator; removed Step 4 label application from Evaluator | Centralize label mapping in Arbiter to handle all 3 verdicts (PASS, DRAFT, FAIL) with distinct labels | Michael Conrad |
