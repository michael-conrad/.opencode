# Implementation Plan — [#1993](https://github.com/michael-conrad/.opencode/issues/1993) — Refactor spec-creation skill

**Goal:** Restructure spec-creation skill to 3 workflows, remove task() calls from task cards, add frugal contract pattern, fix pipeline order.

**Architecture:** 3-phase sequential plan. Phase 1 rewrites SKILL.md (dispatch table + pipeline). Phase 2 cleans 4 task cards and creates 3 new ones. Phase 3 adds critical violation and verifies clean files.

**Files:**
- `.opencode/skills/spec-creation/SKILL.md`
- `.opencode/skills/spec-creation-operating-protocol/tasks/operating-protocol.md` (delete)
- `.opencode/skills/spec-creation-validation/tasks/create.md`
- `.opencode/skills/spec-creation-validation/tasks/completion.md`
- `.opencode/skills/spec-creation-change-control/tasks/change-control.md`
- `.opencode/skills/spec-creation-decomposition/tasks/analytical-artifacts.md`
- `.opencode/skills/spec-creation-validation/tasks/create-remote-stub.md` (create)
- `.opencode/skills/spec-creation-validation/tasks/pre-spec-inspection.md` (create)
- `.opencode/skills/spec-creation-validation/tasks/revise-remote-body.md` (create)
- `.opencode/guidelines/000-critical-rules.md`

**Dispatch:** `skill({name: "writing-plans"})` then `task(..., prompt: "execute create from writing-plans-creation")`

> **Compliance Requirement:** All steps in this document MUST be followed in order. Failure to comply with any step will result in the feature branch being discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step.

> **One-step-at-a-time protocol:** Execute exactly one step at a time. Do not read ahead, batch steps, or combine edits. After each step, verify the result before proceeding to the next. If a step fails, stop and report.

> **Step status:** Each step MUST be marked `[ ]` (pending), `[x]` (completed), or `[~]` (in progress) as work progresses.

> **Dispatch Protocol:**
> - `(**inline**)` — Orchestrator executes the step directly. No `task()` call. The step description contains the exact command or action to perform.
> - `(**sub-agent**)` — Orchestrator dispatches a sub-agent via `task()` with scoped context. The step description contains the exact `task()` call. Sub-agent receives only `{issue_number, target_file, sc_reference, action}` — no plan file references, no orchestrator reasoning.
> - `(**clean-room**)` — Orchestrator dispatches a sub-agent via `task()` with routing metadata only. The step description MUST NOT contain inline verification instructions. Sub-agent receives only `{issue_number, scs}` and independently determines what to verify from the spec.

---

## Phase 1 — SKILL.md restructure

**Concern:** Dispatch table integrity and pipeline definition
**SCs:** SC-1, SC-3, SC-7, SC-8, SC-9, SC-10

- [ ] 0. **Submodule sync (**inline**).** `git submodule update --init && git submodule foreach "git checkout main && git pull"` (skip if no `.gitmodules`)

- [ ] 1. **Coherence gate — Phase 1 (**inline**).** Verify plan items match spec SCs for Phase 1. If any SC is not covered, HALT.

- [ ] 2. **Pre-red-baseline — Phase 1 (**inline**).** `git stash` to capture clean state. Run existing tests to confirm baseline PASS.

- [ ] 3. **RED: Remove 8 fake dispatch entries from SKILL.md (**sub-agent**).** `task(..., prompt: "Write a behavioral test for SC-1: verify SKILL.md Trigger Dispatch Table has exactly 3 entries. The test must fail because 11 entries currently exist. Target file: .opencode/skills/spec-creation/SKILL.md")` **→ SC-1**

- [ ] 4. **GREEN: Remove 8 fake dispatch entries from SKILL.md (**sub-agent**).** `task(..., prompt: "Edit .opencode/skills/spec-creation/SKILL.md. Remove these 8 rows from the Trigger Dispatch Table: requirements, decompose, analytical-artifacts, holistic-self-check, pipeline-readiness-gate, risk, traceability, operating-protocol. Remove the corresponding 8 entries from the Invocation table. Keep only create and completion. SC-1")` **→ SC-1**

- [ ] 5. **GREEN doublecheck: Remove 8 fake dispatch entries from SKILL.md (**inline**).** `grep -c '| \`' .opencode/skills/spec-creation/SKILL.md` on dispatch table section — count should be 2.

- [ ] 6. **Checkpoint commit: Remove 8 fake dispatch entries from SKILL.md (**inline**).** `git commit -m "1993: remove 8 fake dispatch entries from spec-creation SKILL.md"`

- [ ] 7. **RED: Add `revise` dispatch entry to SKILL.md (**sub-agent**).** `task(..., prompt: "Write a behavioral test for SC-1: send prompt 'revise spec' and verify the agent dispatches a 'revise' task. The test must fail because no revise entry exists. Target file: .opencode/skills/spec-creation/SKILL.md")` **→ SC-1**

- [ ] 8. **GREEN: Add `revise` dispatch entry to SKILL.md (**sub-agent**).** `task(..., prompt: "Edit .opencode/skills/spec-creation/SKILL.md. Add to Trigger Dispatch Table: row with revise spec / update spec -> revise -> spec-creation-validation --task revise -> sub-task -> {issue_number}. Add to Invocation table: row with revise -> task(..., prompt: execute revise from spec-creation-validation). SC-1")` **→ SC-1**

- [ ] 9. **GREEN doublecheck: Add `revise` dispatch entry to SKILL.md (**inline**).** `grep 'revise' .opencode/skills/spec-creation/SKILL.md | grep '|'` — should find dispatch row.

- [ ] 10. **Checkpoint commit: Add `revise` dispatch entry to SKILL.md (**inline**).** `git commit -m "1993: add revise dispatch entry to spec-creation SKILL.md"`

- [ ] 11. **RED: Add Pipeline section to SKILL.md (**sub-agent**).** `task(..., prompt: "Write a behavioral test for SC-3, SC-7, SC-8, SC-9, SC-10: send prompt 'create spec' and verify the orchestrator follows a 25-step pipeline with correct order. The test must fail because no pipeline section exists. Target file: .opencode/skills/spec-creation/SKILL.md")` **→ SC-3, SC-7, SC-8, SC-9, SC-10**

- [ ] 12. **GREEN: Add Pipeline section to SKILL.md (**sub-agent**).** `task(..., prompt: "Edit .opencode/skills/spec-creation/SKILL.md. After the Invocation table, add a ## Pipeline section. Define the 25-step create procedure and 6-step revise procedure. Each step labeled [inline] or [sub-task]. Each sub-task step specifies: what the sub-agent reads from disk, what it writes to disk, and the result contract format {status, finding_summary, artifact_path, blocker_reason}. Pipeline order: local-issues sync -> create-remote-stub -> ... -> revise-remote-body -> local-issues sync. No {project_root}/tmp/{N}/contracts/ paths. SC-3, SC-7, SC-8, SC-9, SC-10")` **→ SC-3, SC-7, SC-8, SC-9, SC-10**

- [ ] 13. **GREEN doublecheck: Add Pipeline section to SKILL.md (**inline**).** `grep '## Pipeline' .opencode/skills/spec-creation/SKILL.md` — should find header. `grep -c 'contracts/' .opencode/skills/spec-creation/SKILL.md` — should be 0.

- [ ] 14. **Checkpoint commit: Add Pipeline section to SKILL.md (**inline**).** `git commit -m "1993: add 25-step create and 6-step revise pipeline to spec-creation SKILL.md"`

- [ ] 15. **RED: Delete `operating-protocol.md` task card (**sub-agent**).** `task(..., prompt: "Write a behavioral test for SC-3: verify operating-protocol.md does not exist under spec-creation-operating-protocol/tasks/. The test must fail because the file exists. Target file: .opencode/skills/spec-creation-operating-protocol/tasks/operating-protocol.md")` **→ SC-3**

- [ ] 16. **GREEN: Delete `operating-protocol.md` task card (**sub-agent**).** `task(..., prompt: "Delete .opencode/skills/spec-creation-operating-protocol/tasks/operating-protocol.md. Then grep all spec-creation files for references to operating-protocol.md — if any remain, update them to reference the SKILL.md Pipeline section instead. SC-3")` **→ SC-3**

- [ ] 17. **GREEN doublecheck: Delete `operating-protocol.md` task card (**inline**).** `ls .opencode/skills/spec-creation-operating-protocol/tasks/operating-protocol.md 2>&1` — should return "No such file or directory".

- [ ] 18. **Checkpoint commit: Delete `operating-protocol.md` task card (**inline**).** `git commit -m "1993: delete operating-protocol.md task card, content moved to SKILL.md"`

- [ ] 19. **VbC — Phase 1 (**clean-room**).** `task(..., prompt: "Verify all Phase 1 SCs pass. SCs: SC-1 (3 dispatch entries), SC-3 (pipeline section exists), SC-7 (no contracts/ paths), SC-8 (read/write specified), SC-9 (contract format specified), SC-10 (pipeline starts/ends with sync). Issue 1993.")`

- [ ] 20. **Regression check — Phase 1 (**inline**).** `git stash pop`, re-run tests, confirm no breakage.

---

## Phase 2 — Task card cleanup

**Concern:** Task card structural correctness and frugal contract pattern
**SCs:** SC-2, SC-4, SC-11, SC-12, SC-13, SC-14, SC-15, SC-16, SC-17, SC-18, SC-19, SC-20, SC-21

- [ ] 26. **Coherence gate — Phase 2 (**inline**).** Verify plan items match spec SCs for Phase 2. If any SC is not covered, HALT.

- [ ] 27. **Pre-red-baseline — Phase 2 (**inline**).** `git stash` to capture clean state. Run existing tests to confirm baseline PASS.

- [ ] 28. **RED: Remove 4 `task()` calls from `create.md` (**sub-agent**).** `task(..., prompt: "Write a behavioral test for SC-2, SC-15: execute create.md as a sub-agent and verify no task( calls are present. The test must fail because 4 task() calls exist. Target file: .opencode/skills/spec-creation-validation/tasks/create.md")` **→ SC-2, SC-15**

- [ ] 29. **GREEN: Remove 4 `task()` calls from `create.md` (**sub-agent**).** `task(..., prompt: "Edit .opencode/skills/spec-creation-validation/tasks/create.md. Delete: Step 0 line 'invoke verification-enforcement --task verify'. Delete: Step 1 line 'Invoke issue-operations --task creation'. Delete: Step 27 line 'invoke verification-enforcement --task revisit'. Delete: Step 9 'skill({name: audit}) then task(...)'. SC-2, SC-15")` **→ SC-2, SC-15**

- [ ] 30. **GREEN doublecheck: Remove 4 `task()` calls from `create.md` (**inline**).** `grep -c 'task(' .opencode/skills/spec-creation-validation/tasks/create.md` — should be 0.

- [ ] 31. **Checkpoint commit: Remove 4 `task()` calls from `create.md` (**inline**).** `git commit -m "1993: remove 4 task() calls from create.md (D-1)"`

- [ ] 32. **RED: Replace `{project_root}/tmp/` paths in `create.md` (**sub-agent**).** `task(..., prompt: "Write a behavioral test for SC-16: verify create.md contains no {project_root}/tmp/ paths. The test must fail because 3 paths exist. Target file: .opencode/skills/spec-creation-validation/tasks/create.md")` **→ SC-16**

- [ ] 33. **GREEN: Replace `{project_root}/tmp/` paths in `create.md` (**sub-agent**).** `task(..., prompt: "Edit .opencode/skills/spec-creation-validation/tasks/create.md. Replace {project_root}/tmp/{issue-N}/lifecycle.yaml with .issues/{N}/lifecycle.yaml. Replace {project_root}/tmp/{issue-N}/artifacts/constraints-contract.yaml with .issues/{N}/artifacts/constraints-contract.yaml. Replace {project_root}/tmp/{issue-N}/artifacts/phase-plan-validated.yaml with .issues/{N}/artifacts/phase-plan-validated.yaml. SC-16")` **→ SC-16**

- [ ] 34. **GREEN doublecheck: Replace `{project_root}/tmp/` paths in `create.md` (**inline**).** `grep -c 'project_root}/tmp/' .opencode/skills/spec-creation-validation/tasks/create.md` — should be 0.

- [ ] 35. **Checkpoint commit: Replace `{project_root}/tmp/` paths in `create.md` (**inline**).** `git commit -m "1993: replace {project_root}/tmp/ paths with .issues/{N}/ in create.md (D-3)"`

- [ ] 36. **RED: Add result contract section to `create.md` (**sub-agent**).** `task(..., prompt: "Write a behavioral test for SC-17: verify create.md contains a ## Result Contract section. The test must fail because no result contract exists. Target file: .opencode/skills/spec-creation-validation/tasks/create.md")` **→ SC-17**

- [ ] 37. **GREEN: Add result contract section to `create.md` (**sub-agent**).** `task(..., prompt: "Edit .opencode/skills/spec-creation-validation/tasks/create.md. Append a ## Result Contract section with: status: DONE | BLOCKED, finding_summary: Spec #N written with M SCs, artifact_path: .issues/{N}/spec.md, blocker_reason: <why if BLOCKED>. SC-17")` **→ SC-17**

- [ ] 38. **GREEN doublecheck: Add result contract section to `create.md` (**inline**).** Read create.md — confirm `## Result Contract` section present with status, finding_summary, artifact_path, blocker_reason.

- [ ] 39. **Checkpoint commit: Add result contract section to `create.md` (**inline**).** `git commit -m "1993: add result contract section to create.md (D-4)"`

- [ ] 40. **RED: Add read-from-disk specification to `create.md` (**sub-agent**).** `task(..., prompt: "Write a behavioral test for SC-18: verify create.md contains an ## Input Artifacts section. The test must fail because no such section exists. Target file: .opencode/skills/spec-creation-validation/tasks/create.md")` **→ SC-18**

- [ ] 41. **GREEN: Add read-from-disk specification to `create.md` (**sub-agent**).** `task(..., prompt: "Edit .opencode/skills/spec-creation-validation/tasks/create.md. Add an ## Input Artifacts section listing all 13 artifact paths from .issues/{N}/artifacts/. SC-18")` **→ SC-18**

- [ ] 42. **GREEN doublecheck: Add read-from-disk specification to `create.md` (**inline**).** Read create.md — confirm `## Input Artifacts` section present listing artifact paths.

- [ ] 43. **Checkpoint commit: Add read-from-disk specification to `create.md` (**inline**).** `git commit -m "1993: add read-from-disk specification to create.md (D-5)"`

- [ ] 44. **RED: Renumber steps sequentially in `create.md` (**sub-agent**).** `task(..., prompt: "Write a behavioral test for SC-19: verify create.md has monotonically increasing step numbers. The test must fail because steps are numbered 0, 1, 2, 3, 1, 1a, 1.1, etc. Target file: .opencode/skills/spec-creation-validation/tasks/create.md")` **→ SC-19**

- [ ] 45. **GREEN: Renumber steps sequentially in `create.md` (**sub-agent**).** `task(..., prompt: "Edit .opencode/skills/spec-creation-validation/tasks/create.md. Replace all step numbers with flat sequential numbering 1 through N. Remove all sub-step numbering: 0, 1a, 1.1, 1.2, 1.3, 1.35, 1.4, 1d, 1d.5 through 1d.11, 1e, 1f, 2a, 2b, 5.5, 5.6, 6.2, 6.5, 6.8, 7.1, 7.2, 7.3, 7.4. Each step gets a single integer. SC-19")` **→ SC-19**

- [ ] 46. **GREEN doublecheck: Renumber steps sequentially in `create.md` (**inline**).** Grep step numbers in create.md — verify monotonic sequence, no duplicates.

- [ ] 47. **Checkpoint commit: Renumber steps sequentially in `create.md` (**inline**).** `git commit -m "1993: renumber steps sequentially in create.md (D-6)"`

- [ ] 48. **RED: Replace remote API reads with local file reads in `create.md` (**sub-agent**).** `task(..., prompt: "Write a behavioral test for SC-20: verify create.md self-review reads from local .issues/{N}/spec.md, not from remote API. The test must fail because Step 6.5 references issue-operations -> read-issue. Target file: .opencode/skills/spec-creation-validation/tasks/create.md")` **→ SC-20**

- [ ] 49. **GREEN: Replace remote API reads with local file reads in `create.md` (**sub-agent**).** `task(..., prompt: "Edit .opencode/skills/spec-creation-validation/tasks/create.md. In the self-review section, replace all issue-operations -> read-issue references with read(filePath=.issues/{N}/spec.md). SC-20")` **→ SC-20**

- [ ] 50. **GREEN doublecheck: Replace remote API reads with local file reads in `create.md` (**inline**).** `grep -c 'read-issue' .opencode/skills/spec-creation-validation/tasks/create.md` — should be 0.

- [ ] 51. **Checkpoint commit: Replace remote API reads with local file reads in `create.md` (**inline**).** `git commit -m "1993: replace remote API reads with local file reads in create.md (D-7)"`

- [ ] 52. **RED: Remove forward reference to non-existent pre-PR gate (**sub-agent**).** `task(..., prompt: "Write a behavioral test for SC-21: verify create.md does not reference pre-PR gate. The test must fail because Step 7.3 references it. Target file: .opencode/skills/spec-creation-validation/tasks/create.md")` **→ SC-21**

- [ ] 53. **GREEN: Remove forward reference to non-existent pre-PR gate (**sub-agent**).** `task(..., prompt: "Edit .opencode/skills/spec-creation-validation/tasks/create.md. Delete the section titled Step 7.3: Pre-PR Gate (Enforcement Constraint) at approximately line 724. SC-21")` **→ SC-21**

- [ ] 54. **GREEN doublecheck: Remove forward reference to non-existent pre-PR gate (**inline**).** `grep -c 'pre-PR gate' .opencode/skills/spec-creation-validation/tasks/create.md` — should be 0.

- [ ] 55. **Checkpoint commit: Remove forward reference to non-existent pre-PR gate (**inline**).** `git commit -m "1993: remove forward reference to non-existent pre-PR gate (D-10)"`

- [ ] 56. **RED: Remove remote issue creation from `create.md` (**sub-agent**).** `task(..., prompt: "Write a behavioral test for SC-2, SC-11: verify create.md does NOT create the remote issue. The test must fail because Step 7.2 handles remote issue creation. Target file: .opencode/skills/spec-creation-validation/tasks/create.md")` **→ SC-2, SC-11**

- [ ] 57. **GREEN: Remove remote issue creation from `create.md` (**sub-agent**).** `task(..., prompt: "Edit .opencode/skills/spec-creation-validation/tasks/create.md. Delete the section titled Step 7.2: Remote Issue Body (Exec Summary) at approximately lines 646-722. This content moves to create-remote-stub.md and revise-remote-body.md. SC-2, SC-11")` **→ SC-2, SC-11**

- [ ] 58. **GREEN doublecheck: Remove remote issue creation from `create.md` (**inline**).** Read create.md — confirm no remote issue creation instructions remain.

- [ ] 59. **Checkpoint commit: Remove remote issue creation from `create.md` (**inline**).** `git commit -m "1993: remove remote issue creation from create.md (D-2)"`

- [ ] 60. **RED: Remove `skill()` call from `create.md` (**sub-agent**).** `task(..., prompt: "Write a behavioral test for SC-2, SC-15: verify create.md contains no skill({name: calls. The test must fail because Step 5.6 references skill({name: plan}). Target file: .opencode/skills/spec-creation-validation/tasks/create.md")` **→ SC-2, SC-15**

- [ ] 61. **GREEN: Remove `skill()` call from `create.md` (**sub-agent**).** `task(..., prompt: "Edit .opencode/skills/spec-creation-validation/tasks/create.md. Find Step 5.6 at approximately line 539: skill({name: plan}). Replace with: The SKILL.md pipeline handles plan plan as an inline orchestrator step — this sub-agent does not call it. SC-2, SC-15")` **→ SC-2, SC-15**

- [ ] 62. **GREEN doublecheck: Remove `skill()` call from `create.md` (**inline**).** `grep -c 'skill({name:' .opencode/skills/spec-creation-validation/tasks/create.md` — should be 0.

- [ ] 63. **Checkpoint commit: Remove `skill()` call from `create.md` (**inline**).** `git commit -m "1993: remove skill() call from create.md (D-8)"`

- [ ] 64. **RED: Move lifecycle manifest to `.issues/{N}/lifecycle.yaml` (**sub-agent**).** `task(..., prompt: "Write a behavioral test for SC-16: verify create.md references .issues/{N}/lifecycle.yaml instead of {project_root}/tmp/{N}/lifecycle.yaml. The test must fail because phantom path is used. Target file: .opencode/skills/spec-creation-validation/tasks/create.md")` **→ SC-16**

- [ ] 65. **GREEN: Move lifecycle manifest to `.issues/{N}/lifecycle.yaml` (**sub-agent**).** `task(..., prompt: "Edit .opencode/skills/spec-creation-validation/tasks/create.md. Find the lifecycle manifest step. Change path from {project_root}/tmp/{issue-N}/lifecycle.yaml to .issues/{N}/lifecycle.yaml. Document append-only semantics: if .issues/{N}/lifecycle.yaml exists, append the new event; if not, create it. SC-16")` **→ SC-16**

- [ ] 66. **GREEN doublecheck: Move lifecycle manifest to `.issues/{N}/lifecycle.yaml` (**inline**).** `grep 'lifecycle.yaml' .opencode/skills/spec-creation-validation/tasks/create.md` — should reference `.issues/{N}/lifecycle.yaml`.

- [ ] 67. **Checkpoint commit: Move lifecycle manifest to `.issues/{N}/lifecycle.yaml` (**inline**).** `git commit -m "1993: move lifecycle manifest to .issues/{N}/lifecycle.yaml (D-9)"`

- [ ] 68. **RED: Fix `analytical-artifacts.md` category error (**sub-agent**).** `task(..., prompt: "Write a behavioral test for SC-4: verify analytical-artifacts.md contains no orchestrator-level instructions. The test must fail because file contains orchestrator dispatches and (*orchestrator*) labels. Target file: .opencode/skills/spec-creation-decomposition/tasks/analytical-artifacts.md")` **→ SC-4**

- [ ] 69. **GREEN: Fix `analytical-artifacts.md` category error (**sub-agent**).** `task(..., prompt: "Edit .opencode/skills/spec-creation-decomposition/tasks/analytical-artifacts.md. Remove all orchestrator dispatches via SKILL.md Trigger Dispatch Table language. Remove all (*orchestrator*) labels. Rewrite procedure: sub-agent reads .issues/{N}/spec.md, writes 7 YAML files to .issues/{N}/artifacts/. Add result contract section. Add read-from-disk specification. SC-4")` **→ SC-4**

- [ ] 70. **GREEN doublecheck: Fix `analytical-artifacts.md` category error (**inline**).** `grep -c 'orchestrator' .opencode/skills/spec-creation-decomposition/tasks/analytical-artifacts.md` — should be 0.

- [ ] 71. **Checkpoint commit: Fix `analytical-artifacts.md` category error (**inline**).** `git commit -m "1993: fix analytical-artifacts.md category error — convert to sub-agent procedure"`

- [ ] 72. **RED: Clean `completion.md` (**sub-agent**).** `task(..., prompt: "Write a behavioral test for SC-2: verify completion.md contains no task( calls. The test must fail because 2 calls exist. Target file: .opencode/skills/spec-creation-validation/tasks/completion.md")` **→ SC-2**

- [ ] 73. **GREEN: Clean `completion.md` (**sub-agent**).** `task(..., prompt: "Edit .opencode/skills/spec-creation-validation/tasks/completion.md. Remove the 2 Dispatch task(...) lines (holistic-self-check and push-artifacts). Convert to pure sub-agent procedure: check state, return result contract. SC-2")` **→ SC-2**

- [ ] 74. **GREEN doublecheck: Clean `completion.md` (**inline**).** `grep -c 'task(' .opencode/skills/spec-creation-validation/tasks/completion.md` — should be 0.

- [ ] 75. **Checkpoint commit: Clean `completion.md` (**inline**).** `git commit -m "1993: remove task() calls from completion.md"`

- [ ] 76. **RED: Clean `change-control.md` (**sub-agent**).** `task(..., prompt: "Write a behavioral test for SC-2: verify change-control.md contains no task( calls. The test must fail because 1 call exists. Target file: .opencode/skills/spec-creation-change-control/tasks/change-control.md")` **→ SC-2**

- [ ] 77. **GREEN: Clean `change-control.md` (**sub-agent**).** `task(..., prompt: "Edit .opencode/skills/spec-creation-change-control/tasks/change-control.md. Remove the Dispatch audit --task spec-audit line (Step 3.5). Convert to pure sub-agent procedure: document changes, version spec, return result contract. SC-2")` **→ SC-2**

- [ ] 78. **GREEN doublecheck: Clean `change-control.md` (**inline**).** `grep -c 'task(' .opencode/skills/spec-creation-change-control/tasks/change-control.md` — should be 0.

- [ ] 79. **Checkpoint commit: Clean `change-control.md` (**inline**).** `git commit -m "1993: remove task() calls from change-control.md"`

- [ ] 80. **RED: Create `create-remote-stub.md` (**sub-agent**).** `task(..., prompt: "Write a behavioral test for SC-12: verify create-remote-stub.md exists. The test must fail because file doesn't exist. Target path: .opencode/skills/spec-creation-validation/tasks/create-remote-stub.md")` **→ SC-12**

- [ ] 81. **GREEN: Create `create-remote-stub.md` (**sub-agent**).** `task(..., prompt: "Create .opencode/skills/spec-creation-validation/tasks/create-remote-stub.md. Purpose: obtain spec issue number, create stub file. Procedure: check platform, if remote create issue via API and save as .issues/{N}/remote.md, if local list .issues/ dirs max+1 and create stub. Result contract: {status: DONE, finding_summary, artifact_path: .issues/{N}/remote.md, spec_number: N}. SC-12")` **→ SC-12**

- [ ] 82. **GREEN doublecheck: Create `create-remote-stub.md` (**inline**).** `ls .opencode/skills/spec-creation-validation/tasks/create-remote-stub.md` — should exist.

- [ ] 83. **Checkpoint commit: Create `create-remote-stub.md` (**inline**).** `git commit -m "1993: create create-remote-stub.md task card"`

- [ ] 84. **RED: Create `pre-spec-inspection.md` (**sub-agent**).** `task(..., prompt: "Write a behavioral test for SC-13: verify pre-spec-inspection.md exists. The test must fail because file doesn't exist. Target path: .opencode/skills/spec-creation-validation/tasks/pre-spec-inspection.md")` **→ SC-13**

- [ ] 85. **GREEN: Create `pre-spec-inspection.md` (**sub-agent**).** `task(..., prompt: "Create .opencode/skills/spec-creation-validation/tasks/pre-spec-inspection.md. Purpose: check for superseding issues. Procedure: search GitHub Issues for open [SPEC] issues, check merged PRs, read codebase state, classify findings, write to .issues/{N}/artifacts/pre-spec-inspection.yaml. Return BLOCKED if CONFLICT-RISK or FULL-SUPERSESSION found. SC-13")` **→ SC-13**

- [ ] 86. **GREEN doublecheck: Create `pre-spec-inspection.md` (**inline**).** `ls .opencode/skills/spec-creation-validation/tasks/pre-spec-inspection.md` — should exist.

- [ ] 87. **Checkpoint commit: Create `pre-spec-inspection.md` (**inline**).** `git commit -m "1993: create pre-spec-inspection.md task card"`

- [ ] 88. **RED: Create `revise-remote-body.md` (**sub-agent**).** `task(..., prompt: "Write a behavioral test for SC-14: verify revise-remote-body.md exists. The test must fail because file doesn't exist. Target path: .opencode/skills/spec-creation-validation/tasks/revise-remote-body.md")` **→ SC-14**

- [ ] 89. **GREEN: Create `revise-remote-body.md` (**sub-agent**).** `task(..., prompt: "Create .opencode/skills/spec-creation-validation/tasks/revise-remote-body.md. Purpose: update remote issue body with correct folder links. Procedure: check platform, if local return SKIPPED, read .issues/{N}/spec.md, construct folder URL from session-init, update remote issue body via platform API. Result contract: {status: DONE | SKIPPED}. SC-14")` **→ SC-14**

- [ ] 90. **GREEN doublecheck: Create `revise-remote-body.md` (**inline**).** `ls .opencode/skills/spec-creation-validation/tasks/revise-remote-body.md` — should exist.

- [ ] 91. **Checkpoint commit: Create `revise-remote-body.md` (**inline**).** `git commit -m "1993: create revise-remote-body.md task card"`

- [ ] 92. **RED: Verify all spec-creation task cards are clean (**sub-agent**).** `task(..., prompt: "Write a behavioral test for SC-2: verify no task card under any spec-creation sub-skill contains task(. The test must fail because some task cards still have calls. Search path: .opencode/skills/spec-creation*/tasks/")` **→ SC-2**

- [ ] 93. **GREEN: Verify all spec-creation task cards are clean (**sub-agent**).** `task(..., prompt: "Run grep -rn 'task(' .opencode/skills/spec-creation*/tasks/ --include='*.md'. If any matches found, identify the file and revert the change that introduced it. SC-2")` **→ SC-2**

- [ ] 94. **GREEN doublecheck: Verify all spec-creation task cards are clean (**inline**).** `grep -rn 'task(' .opencode/skills/spec-creation*/tasks/ --include='*.md'` — should be 0 matches.

- [ ] 95. **Checkpoint commit: Verify all spec-creation task cards are clean (**inline**).** `git commit -m "1993: verify all spec-creation task cards clean of task() calls"`

- [ ] 96. **VbC — Phase 2 (**clean-room**).** `task(..., prompt: "Verify all Phase 2 SCs pass. SCs: SC-2 (no task() calls), SC-4 (no orchestrator instructions), SC-11 (no remote issue creation), SC-12 (create-remote-stub exists), SC-13 (pre-spec-inspection exists), SC-14 (revise-remote-body exists), SC-15 (no task/skill calls), SC-16 (no tmp paths), SC-17 (result contract), SC-18 (read-from-disk), SC-19 (sequential steps), SC-20 (local reads), SC-21 (no pre-PR gate). Issue 1993.")`

- [ ] 97. **Regression check — Phase 2 (**inline**).** `git stash pop`, re-run tests, confirm no breakage.

---

## Phase 3 — Critical violation + verification

**Concern:** Enforcement and regression prevention
**SCs:** SC-5, SC-6

- [ ] 103. **Coherence gate — Phase 3 (**inline**).** Verify plan items match spec SCs for Phase 3. If any SC is not covered, HALT.

- [ ] 104. **Pre-red-baseline — Phase 3 (**inline**).** `git stash` to capture clean state. Run existing tests to confirm baseline PASS.

- [ ] 105. **RED: Add critical violation to `000-critical-rules.md` (**sub-agent**).** `task(..., prompt: "Write a behavioral test for SC-5: send prompt with a task card containing task() and verify the agent declines to execute it. The test must fail because no prohibition exists. Target file: .opencode/guidelines/000-critical-rules.md")` **→ SC-5**

- [ ] 106. **GREEN: Add critical violation to `000-critical-rules.md` (**sub-agent**).** `task(..., prompt: "Edit .opencode/guidelines/000-critical-rules.md. Find the Tier 2 (process-integrity) section. Append: ### [critical-rules-XXX] CRITICAL VIOLATION — Sub-agent task cards MUST NOT contain task() or skill() calls. Only orchestrator-level SKILL.md files may contain dispatch instructions. A task card that contains a task() or skill() call is structurally defective — the sub-agent cannot execute it. This applies to ALL task cards across ALL skills. Violation: HALT with blocker report. SC-5")` **→ SC-5**

- [ ] 107. **GREEN doublecheck: Add critical violation to `000-critical-rules.md` (**inline**).** `grep -c 'task cards MUST NOT contain task()' .opencode/guidelines/000-critical-rules.md` — should be 1.

- [ ] 108. **Checkpoint commit: Add critical violation to `000-critical-rules.md` (**inline**).** `git commit -m "1993: add critical violation for sub-agent task() calls in task cards"`

- [ ] 109. **RED: Verify 13 clean task cards unmodified (**sub-agent**).** `task(..., prompt: "Write a behavioral test for SC-6: verify git diff shows zero changes to the 13 clean task cards. The test must fail if any changes detected. Target files: 13 task cards under .opencode/skills/spec-creation-*/tasks/")` **→ SC-6**

- [ ] 110. **GREEN: Verify 13 clean task cards unmodified (**sub-agent**).** `task(..., prompt: "Run git diff against these 13 files: .opencode/skills/spec-creation-requirements/tasks/requirements.md .opencode/skills/spec-creation-decomposition/tasks/decompose.md .opencode/skills/spec-creation-decomposition/tasks/blast-radius.md .opencode/skills/spec-creation-decomposition/tasks/code-path-analysis.md .opencode/skills/spec-creation-decomposition/tasks/concern-analysis.md .opencode/skills/spec-creation-decomposition/tasks/cross-cutting.md .opencode/skills/spec-creation-decomposition/tasks/state-analysis.md .opencode/skills/spec-creation-decomposition/tasks/testability-assessment.md .opencode/skills/spec-creation-decomposition/tasks/interface-compatibility.md .opencode/skills/spec-creation-validation/tasks/holistic-self-check.md .opencode/skills/spec-creation-validation/tasks/pipeline-readiness-gate.md .opencode/skills/spec-creation-validation/tasks/risk.md .opencode/skills/spec-creation-validation/tasks/traceability.md. If any changes detected, revert them with git checkout. SC-6")` **→ SC-6**

- [ ] 111. **GREEN doublecheck: Verify 13 clean task cards unmodified (**inline**).** `git diff -- .opencode/skills/spec-creation-requirements/tasks/requirements.md .opencode/skills/spec-creation-decomposition/tasks/decompose.md .opencode/skills/spec-creation-decomposition/tasks/blast-radius.md .opencode/skills/spec-creation-decomposition/tasks/code-path-analysis.md .opencode/skills/spec-creation-decomposition/tasks/concern-analysis.md .opencode/skills/spec-creation-decomposition/tasks/cross-cutting.md .opencode/skills/spec-creation-decomposition/tasks/state-analysis.md .opencode/skills/spec-creation-decomposition/tasks/testability-assessment.md .opencode/skills/spec-creation-decomposition/tasks/interface-compatibility.md .opencode/skills/spec-creation-validation/tasks/holistic-self-check.md .opencode/skills/spec-creation-validation/tasks/pipeline-readiness-gate.md .opencode/skills/spec-creation-validation/tasks/risk.md .opencode/skills/spec-creation-validation/tasks/traceability.md` — should show zero changes.

- [ ] 112. **Checkpoint commit: Verify 13 clean task cards unmodified (**inline**).** `git commit -m "1993: verify 13 clean task cards unmodified"` (only if changes were reverted)

- [ ] 113. **VbC — Phase 3 (**clean-room**).** `task(..., prompt: "Verify all Phase 3 SCs pass. SCs: SC-5 (critical violation entry exists), SC-6 (13 clean task cards unmodified). Issue 1993.")`

- [ ] 114. **Regression check — Phase 3 (**inline**).** `git stash pop`, re-run tests, confirm no breakage.

---

## Phase 4 — Fix file references to `Load [Text](path)` pattern

**Concern:** All 48 defective file references across 18 spec-creation files must use the `Load [Text](path)` pattern per AGENTS.md Load-Link Cross-Reference Rule.
**SCs:** SC-22, SC-23, SC-24, SC-25

- [ ] 115. **Coherence gate — Phase 4 (**inline**).** Verify plan items match spec SCs for Phase 4. If any SC is not covered, HALT.

- [ ] 116. **Pre-red-baseline — Phase 4 (**inline**).** `git stash` to capture clean state. Run existing tests to confirm baseline PASS.

- [ ] 117. **RED: Fix file references in SKILL.md (**sub-agent**).** `task(..., prompt: "Write a behavioral test for SC-23: verify SKILL.md has no bare path or backtick ref file references outside code fences. The test must fail because 5 bare path references exist. Target file: .opencode/skills/spec-creation/SKILL.md")` **→ SC-23**

- [ ] 118. **GREEN: Fix file references in SKILL.md (**sub-agent**).** `task(..., prompt: "Edit .opencode/skills/spec-creation/SKILL.md. Convert all bare path references to Load [Text](path) pattern. Specifically: convert 'spec-creation-requirements', 'spec-creation-decomposition', 'spec-creation-validation', 'spec-creation-change-control', 'spec-creation-operating-protocol' in the Cross-References section to Load [Text](path). Convert 'brainstorming', 'writing-plans', 'audit', 'approval-gate' to Load [Text](path). SC-23")` **→ SC-23**

- [ ] 119. **GREEN doublecheck: Fix file references in SKILL.md (**inline**).** `grep -E '(skills/|guidelines/|\.md|\.yaml)' .opencode/skills/spec-creation/SKILL.md | grep -v 'Load \[' | grep -v '```'` — should be 0 matches.

- [ ] 120. **Checkpoint commit: Fix file references in SKILL.md (**inline**).** `git commit -m "1993: convert file references to Load [Text](path) in SKILL.md"`

- [ ] 121. **RED: Fix file references in create.md (**sub-agent**).** `task(..., prompt: "Write a behavioral test for SC-22: verify create.md has no bare path or see ref file references. The test must fail because 6 bare path/see ref references exist. Target file: .opencode/skills/spec-creation-validation/tasks/create.md")` **→ SC-22**

- [ ] 122. **GREEN: Fix file references in create.md (**sub-agent**).** `task(..., prompt: "Edit .opencode/skills/spec-creation-validation/tasks/create.md. Convert all bare path and see ref references to Load [Text](path) pattern. Specifically: line 3 'see cross-reference table in that file' -> Load [Text](reference/holistic-dimensions.yaml). Line 312 'implementation-pipeline/tasks/pre-flight-handoff.md' -> Load [Text](implementation-pipeline/tasks/pre-flight-handoff.md). Line 567 '140-planning-spec-creation.md' -> Load [Text](guidelines/140-planning-spec-creation.md). Line 631 '.issues/AGENTS.md' -> Load [Text](.issues/AGENTS.md). Line 661 '.opencode/tools/local-issues sync' -> Load [Text](.opencode/tools/local-issues). SC-22")` **→ SC-22**

- [ ] 123. **GREEN doublecheck: Fix file references in create.md (**inline**).** `grep -E '(skills/|guidelines/|\.md|\.yaml)' .opencode/skills/spec-creation-validation/tasks/create.md | grep -v 'Load \[' | grep -v '```'` — should be 0 matches.

- [ ] 124. **Checkpoint commit: Fix file references in create.md (**inline**).** `git commit -m "1993: convert file references to Load [Text](path) in create.md"`

- [ ] 125. **RED: Fix file references in completion.md (**sub-agent**).** `task(..., prompt: "Write a behavioral test for SC-24: verify completion.md has no bare path or see ref references. The test must fail because 5 references exist. Target file: .opencode/skills/spec-creation-validation/tasks/completion.md")` **→ SC-24**

- [ ] 126. **GREEN: Fix file references in completion.md (**sub-agent**).** `task(..., prompt: "Edit .opencode/skills/spec-creation-validation/tasks/completion.md. Convert all bare path and see ref references to Load [Text](path). Specifically: line 3 'see cross-reference table in that file' -> Load [Text](reference/holistic-dimensions.yaml). Line 14 '.opencode/reference/holistic-dimensions.yaml' -> Load [Text](reference/holistic-dimensions.yaml). SC-24")` **→ SC-24**

- [ ] 127. **GREEN doublecheck: Fix file references in completion.md (**inline**).** `grep -E '(skills/|guidelines/|\.md|\.yaml)' .opencode/skills/spec-creation-validation/tasks/completion.md | grep -v 'Load \[' | grep -v '```'` — should be 0 matches.

- [ ] 128. **Checkpoint commit: Fix file references in completion.md (**inline**).** `git commit -m "1993: convert file references to Load [Text](path) in completion.md"`

- [ ] 129. **RED: Fix file references in change-control.md (**sub-agent**).** `task(..., prompt: "Write a behavioral test for SC-25: verify change-control.md has no bare path references. The test must fail because 4 references exist. Target file: .opencode/skills/spec-creation-change-control/tasks/change-control.md")` **→ SC-25**

- [ ] 130. **GREEN: Fix file references in change-control.md (**sub-agent**).** `task(..., prompt: "Edit .opencode/skills/spec-creation-change-control/tasks/change-control.md. Convert all bare path references to Load [Text](path). SC-25")` **→ SC-25**

- [ ] 131. **GREEN doublecheck: Fix file references in change-control.md (**inline**).** `grep -E '(skills/|guidelines/|\.md|\.yaml)' .opencode/skills/spec-creation-change-control/tasks/change-control.md | grep -v 'Load \[' | grep -v '```'` — should be 0 matches.

- [ ] 132. **Checkpoint commit: Fix file references in change-control.md (**inline**).** `git commit -m "1993: convert file references to Load [Text](path) in change-control.md"`

- [ ] 133. **RED: Fix file references in analytical-artifacts.md (**sub-agent**).** `task(..., prompt: "Write a behavioral test for SC-22: verify analytical-artifacts.md has no bare path references. The test must fail because 5 references exist. Target file: .opencode/skills/spec-creation-decomposition/tasks/analytical-artifacts.md")` **→ SC-22**

- [ ] 134. **GREEN: Fix file references in analytical-artifacts.md (**sub-agent**).** `task(..., prompt: "Edit .opencode/skills/spec-creation-decomposition/tasks/analytical-artifacts.md. Convert all bare path references to Load [Text](path). SC-22")` **→ SC-22**

- [ ] 135. **GREEN doublecheck: Fix file references in analytical-artifacts.md (**inline**).** `grep -E '(skills/|guidelines/|\.md|\.yaml)' .opencode/skills/spec-creation-decomposition/tasks/analytical-artifacts.md | grep -v 'Load \[' | grep -v '```'` — should be 0 matches.

- [ ] 136. **Checkpoint commit: Fix file references in analytical-artifacts.md (**inline**).** `git commit -m "1993: convert file references to Load [Text](path) in analytical-artifacts.md"`

- [ ] 137. **RED: Fix file references in remaining 13 task cards (**sub-agent**).** `task(..., prompt: "Write a behavioral test for SC-22: verify all 13 remaining spec-creation task cards have no bare path references. The test must fail because 28 references exist across 13 files. Search path: .opencode/skills/spec-creation-*/tasks/")` **→ SC-22**

- [ ] 138. **GREEN: Fix file references in remaining 13 task cards (**sub-agent**).** `task(..., prompt: "Edit all 13 remaining spec-creation task cards to convert bare path references to Load [Text](path) pattern. Files: requirements.md, decompose.md, blast-radius.md, code-path-analysis.md, concern-analysis.md, cross-cutting.md, state-analysis.md, testability-assessment.md, interface-compatibility.md, holistic-self-check.md, pipeline-readiness-gate.md, risk.md, traceability.md. Each file's Context Required section (preceded by/feeds into) and comment blocks are the primary targets. SC-22")` **→ SC-22**

- [ ] 139. **GREEN doublecheck: Fix file references in remaining 13 task cards (**inline**).** `grep -rnE '(skills/|guidelines/|\.md|\.yaml)' .opencode/skills/spec-creation-*/tasks/ --include='*.md' | grep -v 'Load \[' | grep -v '```'` — should be 0 matches.

- [ ] 140. **Checkpoint commit: Fix file references in remaining 13 task cards (**inline**).** `git commit -m "1993: convert file references to Load [Text](path) in remaining 13 task cards"`

- [ ] 141. **VbC — Phase 4 (**clean-room**).** `task(..., prompt: "Verify all Phase 4 SCs pass. SCs: SC-22 (no bare path references in any spec-creation file), SC-23 (SKILL.md clean), SC-24 (completion.md clean), SC-25 (change-control.md clean). Issue 1993.")`

- [ ] 142. **Regression check — Phase 4 (**inline**).** `git stash pop`, re-run tests, confirm no breakage.

---

## Final Gates (once, after all 4 phases)

- [ ] 115. **Spec audit — full (**inline**).** `skill({name: "audit"})` then dispatch DiMo chain: `task(..., prompt: "execute spec-audit investigator from audit. Read audit/tasks/spec-audit-investigator.md first")` → `task(..., prompt: "execute spec-audit validator from audit. Read audit/tasks/spec-audit-validator.md first")` → `task(..., prompt: "execute spec-audit evaluator from audit. Read audit/tasks/spec-audit-evaluator.md first")`

- [ ] 116. **Cross-validate (**inline**).** Verify audit PASS, no regressions.

- [ ] 117. **Finishing checklist (**inline**).** `skill({name: "finishing-a-development-branch"})` then `task(..., prompt: "execute checklist task from finishing-a-development-branch")`

- [ ] 118. **Review-prep (**inline**).** `skill({name: "git-workflow"})` then `task(..., prompt: "execute review-prep task from git-workflow")`

- [ ] 119. **Cleanup (**inline**).** `skill({name: "git-workflow"})` then `task(..., prompt: "execute cleanup task from git-workflow")`

---

## Exit Criteria

- [ ] C1. SKILL.md Trigger Dispatch Table has exactly 3 entries (SC-1)
- [ ] C2. `revise` dispatch entry exists in SKILL.md (SC-1)
- [ ] C3. Pipeline section exists in SKILL.md with read/write/contract for each sub-task step (SC-3, SC-8, SC-9)
- [ ] C4. No `{project_root}/tmp/{N}/contracts/` paths in SKILL.md pipeline (SC-7)
- [ ] C5. Create pipeline starts with `local-issues sync`, ends with `local-issues sync` (SC-10)
- [ ] C6. `operating-protocol.md` deleted (SC-3)
- [ ] C7. `create.md` contains no `task(` or `skill({name:` calls (SC-15)
- [ ] C8. `create.md` contains no `{project_root}/tmp/` paths (SC-16)
- [ ] C9. `create.md` contains result contract section (SC-17)
- [ ] C10. `create.md` contains read-from-disk specification (SC-18)
- [ ] C11. `create.md` has sequentially numbered steps (SC-19)
- [ ] C12. `create.md` self-review reads from local `.issues/{N}/spec.md` (SC-20)
- [ ] C13. `create.md` does not reference "pre-PR gate" (SC-21)
- [ ] C14. `create.md` does NOT create the remote issue (SC-11)
- [ ] C15. `completion.md` has no `task(` calls (SC-2)
- [ ] C16. `change-control.md` has no `task(` calls (SC-2)
- [ ] C17. `analytical-artifacts.md` has no orchestrator-level instructions (SC-4)
- [ ] C18. `create-remote-stub.md` exists (SC-12)
- [ ] C19. `pre-spec-inspection.md` exists (SC-13)
- [ ] C20. `revise-remote-body.md` exists (SC-14)
- [ ] C21. No task card under any spec-creation sub-skill contains `task(...)` (SC-2)
- [ ] C22. `000-critical-rules.md` contains sub-agent task() prohibition (SC-5)
- [ ] C23. All 13 clean task cards have zero changes in git diff (SC-6)
