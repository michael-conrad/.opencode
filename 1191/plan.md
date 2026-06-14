# Plan: #1191 — dispatch table mandate for writing-plans create task

**Goal:** Mandate structured dispatch tables per phase in writing-plans `create` task, replacing the existing prose-only phase structure requirements with the Orchestrator Execution Protocol + Dispatch Table template. Standard gates are dynamically pulled from the current `implementation-pipeline/SKILL.md` §Dispatch Routing Table.

**Architecture:** Three non-overlapping phases targeting three separate task files in `skills/writing-plans/`. Each phase modifies exactly one file — no cross-file edits within a phase. Each phase runs the full 16-step implementation workflow.

**Tech Stack:** Markdown task files (`create.md`, `plan-structure.md`, `create-and-validate.md`). Validation via pymarkdownlnt for structural correctness.

## Orchestrator Execution Protocol

1. Read the dispatch tables in this plan to determine the gate sequence
2. Execute every gate in every phase in numeric order (G1, G2, G3, ...)
3. NOT skip any gate — every row is mandatory
4. NOT reorder gates — the sequence is the plan
5. For `sub-task` gates: call `task()` with the exact `Receives Context` JSON object as the prompt, using the specified `Sub-Agent Type`
6. For `inline` gates: execute the described operation directly (no sub-agent)
7. After each gate completes, verify the SCs listed in that gate's SCs column
8. Report progress via chat output only — zero GitHub Issue comments during implementation unless absolutely warranted
9. After each phase completes, run the Inter-Phase Handoff steps before advancing to the next phase
10. Do NOT modify this plan — it is a static definitional artifact. Only mutate for remediation or scope revision

---

## Phase 1: Add dispatch table template + orchestrator protocol + dynamic gate set mandate to create.md

**Concern boundary:** Plan structure requirements section only in `create.md`. No changes to procedure steps, entry/exit criteria, sub-task routing table, or operating protocol.

**Files:** `skills/writing-plans/tasks/create.md`

**SCs covered:** SC-1, SC-2

### Phase 1 — Dispatch Table

Standard gates pulled from `implementation-pipeline/SKILL.md` §Dispatch Routing Table (all 16 steps). Each gate declares its Z3 SAT variable as `P1_{step_label}`. All gates are clean-room sub-tasks except CHECKPOINT-COMMIT.

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|----------------|-----------------|-----|
| G1: sc-coherence-gate | sub-task | yes (blind) | general | `{"issue":1191,"phase":1,"task":"Read skills/writing-plans/tasks/create.md and the spec. Verify SC-1 and SC-2 are coherent for Phase 1 — dispatch table format and orchestrator protocol can be added to the same section without conflicts. No conflicting requirements exist."}` | SC-1, SC-2 |
| G2: pre-red-baseline | sub-task | yes (blind) | general | `{"issue":1191,"phase":1,"task":"Read skills/writing-plans/tasks/create.md. Verify the Plan Phase Structure Requirements section exists. Return its heading line range and current content word count."}` | SC-1, SC-2 |
| G3: red-phase | sub-task | yes (blind) | general | `{"issue":1191,"phase":1,"remediation":true,"task":"Write behavioral enforcement test at .opencode/tests/behaviors/writing-plans-dispatch-table.sh. Must assert: agent reading create.md produces dispatch table with 6 columns (Gate/Dispatch Type/Blind?/Sub-Agent Type/Receives Context/SCs), standard gate set pulled from implementation-pipeline/SKILL.md, orchestrator protocol with 10 rules. Run the test, capture output to ./tmp/1191/p1-red-output.log. Expected: non-zero exit."}` | SC-1, SC-2 |
| G4: red-doublecheck | sub-task | yes (blind) | general | `{"issue":1191,"phase":1,"task":"Read ./tmp/1191/p1-red-output.log. Confirm it shows non-zero exit (expected FAIL). Return PASS if RED evidence is valid, FAIL if evidence missing or shows exit 0."}` | SC-1, SC-2 |
| G5: post-red-enforcement | sub-task | yes (blind) | general | `{"issue":1191,"phase":1,"task":"Verify the RED test only created files under .opencode/tests/ — no src/ or skill files modified. Run 'git diff --name-only -- skills/' and confirm empty. Return PASS/FAIL."}` | SC-1, SC-2 |
| G6: green-phase | sub-task | yes (blind) | general | `{"issue":1191,"phase":1,"remediation":true,"task":"In skills/writing-plans/tasks/create.md, replace the existing Plan Phase Structure Requirements section with: Orchestrator Execution Protocol (10 rules) + Dispatch Table (6-column table with column definitions and 7 rules) + Dynamic Standard Gate Set mandate (must pull from implementation-pipeline/SKILL.md). Do NOT hardcode gate names. Keep all other sections intact. Run the behavioral test, capture to ./tmp/1191/p1-green-output.log. Expected: exit 0."}` | SC-1, SC-2 |
| G7: post-green-enforcement | sub-task | yes (blind) | general | `{"issue":1191,"phase":1,"task":"Verify the GREEN change only modified skills/writing-plans/tasks/create.md — no changes to test files or unrelated files. Run 'git diff --name-only' and confirm only the target file changed. Return PASS/FAIL."}` | SC-1, SC-2 |
| G8: checkpoint-commit | inline | N/A | N/A | — | SC-1, SC-2 |
| G9: structural-checks | sub-task | yes (blind) | general | `{"issue":1191,"phase":1,"task":"Run uvx pymarkdownlnt scan -r skills/writing-plans/tasks/create.md. Report any new lint issues introduced. Ignore pre-existing warnings. Return PASS/FAIL."}` | SC-1, SC-2 |
| G10: green-doublecheck | sub-task | yes (blind) | general | `{"issue":1191,"phase":1,"task":"Read ./tmp/1191/p1-green-output.log. Confirm exit 0 (expected PASS). Return PASS/FAIL."}` | SC-1, SC-2 |
| G11: green-vbc | sub-task | yes (blind) | general | `{"issue":1191,"phase":1,"task":"Verify SC-1 (dispatch table template with 6 columns and 7 rules) and SC-2 (orchestrator execution protocol with 10 rules) exist in skills/writing-plans/tasks/create.md. SC-1 must not include hardcoded gate names — only the dynamic-pull mandate referencing implementation-pipeline/SKILL.md. Return PASS/FAIL per SC with line references."}` | SC-1, SC-2 |
| G12: adversarial-audit | sub-task | yes (blind) | general | `{"issue":1191,"phase":1,"task":"Read skills/writing-plans/tasks/create.md. Verify the dynamic-pull mandate correctly references implementation-pipeline/SKILL.md §Dispatch Routing Table without hardcoding any gate names. Check that the inline-gates rule restricts to CHECKPOINT-COMMIT only. Return PASS/FAIL."}` | SC-1, SC-2 |
| G13: cross-validate | sub-task | yes (blind) | general | `{"issue":1191,"phase":1,"task":"Read the VBC result and adversarial-audit result. Confirm they agree on SC-1 and SC-2 status. Return consensus PASS/FAIL."}` | SC-1, SC-2 |
| G14: regression-check | sub-task | yes (blind) | general | `{"issue":1191,"phase":1,"task":"Run full markdown lint: uvx pymarkdownlnt scan -r skills/writing-plans/tasks/create.md. Run the behavioral test again. Confirm nothing regressed. Return PASS/FAIL."}` | SC-1, SC-2 |
| G15: review-prep | sub-task | yes (blind) | general | `{"issue":1191,"phase":1,"task":"Read all sub-agent result contracts from G1-G14. Produce phase completion summary: SC-1 status, SC-2 status, artifact paths for RED/GREEN evidence, byline. Return structured summary."}` | SC-1, SC-2 |
| G16: exec-summary | sub-task | yes (blind) | general | `{"issue":1191,"phase":1,"task":"Produce final phase completion report. Include: SC-1 PASS/FAIL, SC-2 PASS/FAIL, artifact paths, byline."}` | SC-1, SC-2 |

---

## Phase 2: Add dispatch table as primary phase section in plan-structure.md

**Concern boundary:** Step 4 in plan-structure.md only. No changes to pipeline gates, Z3 contracts, RED/GREEN language, item decomposition, or verification steps.

**Files:** `skills/writing-plans/tasks/create/plan-structure.md`

**SCs covered:** SC-3

### Phase 2 — Dispatch Table

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|----------------|-----------------|-----|
| G1: sc-coherence-gate | sub-task | yes (blind) | general | `{"issue":1191,"phase":2,"task":"Verify SC-3 is internally consistent: dispatch table as primary phase section in plan-structure.md does not conflict with changes made in Phase 1."}` | SC-3 |
| G2: pre-red-baseline | sub-task | yes (blind) | general | `{"issue":1191,"phase":2,"task":"Read skills/writing-plans/tasks/create/plan-structure.md. Confirm Step 4 Plan Phase Structure section exists. Return its exact line range."}` | SC-3 |
| G3: red-phase | sub-task | yes (blind) | general | `{"issue":1191,"phase":2,"remediation":true,"task":"Update .opencode/tests/behaviors/writing-plans-dispatch-table.sh to add assertion: plan-structure.md must include dispatch table as primary phase section template before concern boundaries. Run updated test — expected: non-zero exit. Capture to ./tmp/1191/p2-red-output.log."}` | SC-3 |
| G4: red-doublecheck | sub-task | yes (blind) | general | `{"issue":1191,"phase":2,"task":"Read ./tmp/1191/p2-red-output.log. Confirm non-zero exit. Return PASS/FAIL."}` | SC-3 |
| G5: post-red-enforcement | sub-task | yes (blind) | general | `{"issue":1191,"phase":2,"task":"Verify RED test only modified .opencode/tests/ — no skill files touched. Run 'git diff --name-only -- skills/' and confirm empty. Return PASS/FAIL."}` | SC-3 |
| G6: green-phase | sub-task | yes (blind) | general | `{"issue":1191,"phase":2,"remediation":true,"task":"In skills/writing-plans/tasks/create/plan-structure.md Step 4, replace existing prose with dispatch table template as primary section per spec Phase 2. Template shows dispatch table first, then concern boundary/files/SCs. Also replace Step 6 (implementation-checklist generation) with REMOVED marker. Run behavioral test — expected: exit 0. Capture to ./tmp/1191/p2-green-output.log."}` | SC-3 |
| G7: post-green-enforcement | sub-task | yes (blind) | general | `{"issue":1191,"phase":2,"task":"Verify only skills/writing-plans/tasks/create/plan-structure.md was modified. Run 'git diff --name-only'. Return PASS/FAIL."}` | SC-3 |
| G8: checkpoint-commit | inline | N/A | N/A | — | SC-3 |
| G9: structural-checks | sub-task | yes (blind) | general | `{"issue":1191,"phase":2,"task":"Run uvx pymarkdownlnt scan -r skills/writing-plans/tasks/create/plan-structure.md. Report new issues only. Return PASS/FAIL."}` | SC-3 |
| G10: green-doublecheck | sub-task | yes (blind) | general | `{"issue":1191,"phase":2,"task":"Read ./tmp/1191/p2-green-output.log. Confirm exit 0. Return PASS/FAIL."}` | SC-3 |
| G11: green-vbc | sub-task | yes (blind) | general | `{"issue":1191,"phase":2,"task":"Verify SC-3: plan-structure.md has dispatch table as primary phase section template before concern boundaries/files/SCs. Return PASS/FAIL with line references."}` | SC-3 |
| G12: adversarial-audit | sub-task | yes (blind) | general | `{"issue":1191,"phase":2,"task":"Verify the dispatch table template placement is correct — before concern boundaries, not embedded within them. Return PASS/FAIL."}` | SC-3 |
| G13: cross-validate | sub-task | yes (blind) | general | `{"issue":1191,"phase":2,"task":"Confirm VBC and audit agree on SC-3 status. Return consensus PASS/FAIL."}` | SC-3 |
| G14: regression-check | sub-task | yes (blind) | general | `{"issue":1191,"phase":2,"task":"Run full markdown lint. Run behavioral test. Return PASS/FAIL with evidence."}` | SC-3 |
| G15: review-prep | sub-task | yes (blind) | general | `{"issue":1191,"phase":2,"task":"Read all sub-agent contracts G1-G14. Produce phase completion summary: SC-3 status, artifact paths, byline."}` | SC-3 |
| G16: exec-summary | sub-task | yes (blind) | general | `{"issue":1191,"phase":2,"task":"Produce final phase completion report: SC-3 status, artifacts, byline."}` | SC-3 |

---

## Phase 3: Update create-and-validate.md (validation, checklist removal, plan-reference sync)

**Concern boundary:** Validation section (Step 9), checklist generation section (Step 6 replacement), and post-approval section (after Step 13) in create-and-validate.md.

**Files:** `skills/writing-plans/tasks/create/create-and-validate.md`

**SCs covered:** SC-4, SC-5, SC-6

### Phase 3 — Dispatch Table

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|----------------|-----------------|-----|
| G1: sc-coherence-gate | sub-task | yes (blind) | general | `{"issue":1191,"phase":3,"task":"Verify SC-4, SC-5, SC-6 are coherent for Phase 3: validation rules, checklist removal, and plan-ref sync are independent changes to different sections of the same file."}` | SC-4, SC-5, SC-6 |
| G2: pre-red-baseline | sub-task | yes (blind) | general | `{"issue":1191,"phase":3,"task":"Read skills/writing-plans/tasks/create/create-and-validate.md. Identify Step 9 validation section, Step 6 checklist generation reference, and area after Step 13. Return line ranges."}` | SC-4, SC-5, SC-6 |
| G3: red-phase | sub-task | yes (blind) | general | `{"issue":1191,"phase":3,"remediation":true,"task":"Update behavioral test: add assertions for SC-4 (dispatch table validation with 8 rules — inline=CHECKPOINT-COMMIT only, standard gate set check against implementation-pipeline), SC-5 (no implementation-checklist.md), SC-6 (plan-reference sync with github_issue_write). Run — expected: non-zero exit. Capture to ./tmp/1191/p3-red-output.log."}` | SC-4, SC-5, SC-6 |
| G4: red-doublecheck | sub-task | yes (blind) | general | `{"issue":1191,"phase":3,"task":"Read ./tmp/1191/p3-red-output.log. Confirm non-zero exit. Return PASS/FAIL."}` | SC-4, SC-5, SC-6 |
| G5: post-red-enforcement | sub-task | yes (blind) | general | `{"issue":1191,"phase":3,"task":"Verify RED test only modified .opencode/tests/. Run 'git diff --name-only -- skills/'. Return PASS/FAIL."}` | SC-4, SC-5, SC-6 |
| G6: green-phase | sub-task | yes (blind) | general | `{"issue":1191,"phase":3,"remediation":true,"task":"In skills/writing-plans/tasks/create/create-and-validate.md: (1) add dispatch table validation subsection to Step 9 with 8 rules, (2) remove implementation-checklist.md generation, (3) add plan-reference sync step after Step 13. Run behavioral test — expected: exit 0. Capture to ./tmp/1191/p3-green-output.log."}` | SC-4, SC-5, SC-6 |
| G7: post-green-enforcement | sub-task | yes (blind) | general | `{"issue":1191,"phase":3,"task":"Verify only create-and-validate.md was modified. Run 'git diff --name-only'. Return PASS/FAIL."}` | SC-4, SC-5, SC-6 |
| G8: checkpoint-commit | inline | N/A | N/A | — | SC-4, SC-5, SC-6 |
| G9: structural-checks | sub-task | yes (blind) | general | `{"issue":1191,"phase":3,"task":"Run uvx pymarkdownlnt scan -r skills/writing-plans/tasks/create/create-and-validate.md. Report new issues only. Return PASS/FAIL."}` | SC-4, SC-5, SC-6 |
| G10: green-doublecheck | sub-task | yes (blind) | general | `{"issue":1191,"phase":3,"task":"Read ./tmp/1191/p3-green-output.log. Confirm exit 0. Return PASS/FAIL."}` | SC-4, SC-5, SC-6 |
| G11: green-vbc | sub-task | yes (blind) | general | `{"issue":1191,"phase":3,"task":"Verify SC-4 (dispatch table validation with 8 rules — inline=CHECKPOINT-COMMIT only, standard gate set check against implementation-pipeline/SKILL.md §Dispatch Routing Table), SC-5 (no implementation-checklist.md generation), SC-6 (plan-reference sync step referencing github_issue_write). Return PASS/FAIL per SC with line references."}` | SC-4, SC-5, SC-6 |
| G12: adversarial-audit | sub-task | yes (blind) | general | `{"issue":1191,"phase":3,"task":"Verify the validation rule correctly references implementation-pipeline/SKILL.md for the standard gate set check, not a hardcoded list. Verify plan-reference sync step correctly uses github_issue_write(method='update') and preserves existing body content. Return PASS/FAIL."}` | SC-4, SC-5, SC-6 |
| G13: cross-validate | sub-task | yes (blind) | general | `{"issue":1191,"phase":3,"task":"Confirm VBC and audit agree on SC-4, SC-5, SC-6 statuses. Return consensus PASS/FAIL per SC."}` | SC-4, SC-5, SC-6 |
| G14: regression-check | sub-task | yes (blind) | general | `{"issue":1191,"phase":3,"task":"Run full markdown lint. Run behavioral test. Confirm nothing regressed. Return PASS/FAIL."}` | SC-4, SC-5, SC-6 |
| G15: review-prep | sub-task | yes (blind) | general | `{"issue":1191,"phase":3,"task":"Read all sub-agent contracts G1-G14. Produce phase completion summary: SC-4/SC-5/SC-6 statuses, artifact paths, byline."}` | SC-4, SC-5, SC-6 |
| G16: exec-summary | sub-task | yes (blind) | general | `{"issue":1191,"phase":3,"task":"Produce final phase completion report: SC-4, SC-5, SC-6 statuses, artifact paths, byline."}` | SC-4, SC-5, SC-6 |

---

## Post-All-Phases Sweep

- FINISHING CHECKLIST — verify all 3 phases complete, lint passes, all 6 SCs verified PASS
- PR CREATION — push submodule feature branch, create PR targeting dev

## SC-ID Traceability

| SC | Phase | Gates |
|----|-------|-------|
| SC-1: create.md has dispatch table template section with column definitions and rules | Phase 1 | G3, G6, G11 |
| SC-2: create.md has orchestrator execution protocol section with all 10 rules | Phase 1 | G3, G6, G11 |
| SC-3: plan-structure.md includes dispatch table as mandatory primary phase section | Phase 2 | G3, G6, G11 |
| SC-4: create-and-validate.md has dispatch table validation step checking all 8 rules | Phase 3 | G3, G6, G11 |
| SC-5: create-and-validate.md no longer generates implementation-checklist.md | Phase 3 | G3, G6, G11 |
| SC-6: create-and-validate.md has plan-reference sync step | Phase 3 | G3, G6, G11 |

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)