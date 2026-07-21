# Plan: Fix audit skill card — DiMo chain per-step dispatch, pre-flight gate, task file contracts

**Issue:** #2053
**Spec:** `.opencode/.issues/2053/spec.md`
**Authorization scope:** `for_pr` (auto-approved per cascade matrix)
**Halt at:** `pr_created`
**PR strategy:** `stacked`

## Phase Overview

| Phase | SCs | Focus | Files |
|-------|-----|-------|-------|
| 1 | SC-1, SC-2, SC-3, SC-4 | Fix `audit/SKILL.md` structure | 1 file |
| 2 | SC-5 | Add contract sections to all ~25 task files | ~25 files |
| 3 | SC-6 | Add Clean-Room Validation to 4 DiMo role files | 4 files |
| 4 | SC-7 | Add expected-determination rejection to evaluator/arbiter files | ~10 files |
| 5 | SC-8 | Add PRELOADED_CONTEXT_REJECTED to all task files | ~25 files |

## SC-to-Step Traceability

| SC ID | Criterion | Phase | Step(s) |
|-------|-----------|-------|---------|
| SC-1 | `audit/SKILL.md` has Pre-Flight Gate as first content section | 1 | 1.1 |
| SC-2 | `audit/SKILL.md` has no global Invocation or DISPATCH_GATE section | 1 | 1.2 |
| SC-3 | `audit/SKILL.md` has enumerated workflow sections with per-step dispatch | 1 | 1.3 |
| SC-4 | TDT Dispatch column uses `orchestrator: 4 sequential task() calls` for DiMo chain | 1 | 1.4 |
| SC-5 | All ~25 task files have Dispatch Contract, Output Contract, Frugal Contract | 2 | 2.1-2.5 |
| SC-6 | Investigator, Validator, Evaluator, Arbiter have Clean-Room Validation | 3 | 3.1-3.4 |
| SC-7 | Evaluator and Arbiter have expected-determination rejection | 4 | 4.1-4.2 |
| SC-8 | All clean-room task files have PRELOADED_CONTEXT_REJECTED | 5 | 5.1-5.5 |

---

## Phase 1: Fix `audit/SKILL.md` structure

**SC-1, SC-2, SC-3, SC-4**

### Steps

**1.1 Add Pre-Flight Gate section**
- Insert `## Pre-Flight Gate` as the first content section after frontmatter
- Content: check `task()` availability, BLOCKED with `TASK_UNAVAILABLE` on failure
- Reference: `.opencode/skills/templates/SKILL.md` Pre-Flight Gate template

**1.2 Remove global Invocation and DISPATCH_GATE sections**
- Delete the `## Invocation` section (lines 94-111)
- Delete the `## Explicit Dispatch Protocol` section (lines 113-127)
- Delete the `## DiMo Role Chain Dispatch` section (lines 129-137)
- These are replaced by enumerated workflow sections

**1.3 Add enumerated workflow sections**
- Add `## Workflow` section with enumerated sub-sections:
  - `### 1. Pre-Flight Gate` — orchestrator: inline
  - `### 2. Trigger Dispatch` — orchestrator: read TDT, dispatch
  - `### 3. DiMo Chain Execution` — orchestrator: 4 sequential task() calls
  - `### 4. Completion` — orchestrator: halt
- Each section specifies: dispatch type, dispatch string, input, output

**1.4 Update TDT Dispatch column**
- Change all `sub-task (DiMo chain)` entries to `orchestrator: 4 sequential task() calls`
- Remove HALT rows for missing artifacts (replaced by Pre-Flight Gate)
- Ensure each row has correct context passed

### Safety/Rollback
- **Destructive operations:** Section deletion (Invocation, DISPATCH_GATE, DiMo Role Chain)
- **Rollback plan:** `git checkout .opencode/skills/audit/SKILL.md` to restore original
- **Data loss risk:** low (single file, git-tracked)

### Feasibility Verification

| Step | Reference | Verified? | Evidence |
|------|-----------|-----------|----------|
| 1.1 | `.opencode/skills/templates/SKILL.md` Pre-Flight Gate | ✅ | `read` confirmed template exists |
| 1.1 | `.opencode/skills/audit/SKILL.md` frontmatter | ✅ | `read` confirmed frontmatter lines 1-10 |
| 1.2 | `## Invocation` section in SKILL.md | ✅ | `read` confirmed lines 94-111 |
| 1.2 | `## Explicit Dispatch Protocol` section | ✅ | `read` confirmed lines 113-127 |
| 1.2 | `## DiMo Role Chain Dispatch` section | ✅ | `read` confirmed lines 129-137 |
| 1.4 | TDT rows in SKILL.md | ✅ | `read` confirmed lines 48-73 |

---

## Phase 2: Add contract sections to all ~25 task files

**SC-5**

### Steps

**2.1 Add Dispatch Contract section**
- Add `## Dispatch Contract` to every task file
- Include: context fields table, `MISSING_REQUIRED_CONTEXT` block, `PRELOADED_CONTEXT_REJECTED` block
- Reference: `.opencode/skills/templates/task.md` Dispatch Contract template

**2.2 Add Output Contract section**
- Add `## Output Contract` to every task file
- Include: output fields table with artifact_path, artifact_format, task-specific fields
- Reference: `.opencode/skills/templates/task.md` Output Contract template

**2.3 Add Frugal Contract section**
- Add `## Frugal Contract` to every task file
- Include: status, finding_summary, artifact_path, blocker_reason
- Reference: `.opencode/skills/templates/task.md` Frugal Contract template

**2.4 Verify all 25 files have all 3 contract sections**
- Run `grep` for `## Dispatch Contract`, `## Output Contract`, `## Frugal Contract` across all task files
- Any file missing a section → fix

**2.5 Verify contract section consistency**
- Compare section structure across files for consistent field names and format
- Fix any inconsistencies

### Safety/Rollback
- **Destructive operations:** None (adding sections, not deleting)
- **Rollback plan:** `git checkout .opencode/skills/audit/tasks/` to restore
- **Data loss risk:** none

### Feasibility Verification

| Step | Reference | Verified? | Evidence |
|------|-----------|-----------|----------|
| 2.1-2.3 | `.opencode/skills/templates/task.md` | ✅ | `read` confirmed template exists |
| 2.1-2.3 | Task files in `audit/tasks/` | ✅ | `ls` confirmed ~35 files exist |
| 2.4 | All task files | ✅ | `grep` after edits |

---

## Phase 3: Add Clean-Room Validation to 4 DiMo role files

**SC-6**

### Steps

**3.1 Add Clean-Room Validation to `verification-audit-investigator.md`**
- Add `## Clean-Room Validation` section after Frugal Contract
- Content: reject preloaded context, discover scope independently, produce evidence independently, render binary judgment

**3.2 Add Clean-Room Validation to `verification-audit-validator.md`**
- Same as 3.1

**3.3 Add Clean-Room Validation to `verification-audit-evaluator.md`**
- Same as 3.1

**3.4 Add Clean-Room Validation to `verification-audit-arbiter.md`**
- Same as 3.1

### Safety/Rollback
- **Destructive operations:** None
- **Rollback plan:** `git checkout` individual files
- **Data loss risk:** none

### Feasibility Verification

| Step | Reference | Verified? | Evidence |
|------|-----------|----------|----------|
| 3.1-3.4 | `.opencode/skills/templates/task.md` Clean-Room Validation | ✅ | `read` confirmed template |
| 3.1-3.4 | 4 DiMo role files exist | ✅ | `ls` confirmed |

---

## Phase 4: Add expected-determination rejection to evaluator/arbiter files

**SC-7**

### Steps

**4.1 Add expected-determination rejection to all `*-evaluator.md` files**
- Add `**Expected-determination rejection:**` block in Dispatch Contract
- Content: if orchestrator includes expected PASS/FAIL verdict, return `EXPECTED_DETERMINATION_REJECTED`
- Files: verification-audit-evaluator, spec-audit-evaluator, plan-fidelity-evaluator, concern-separation-evaluator, coherence-extraction-evaluator, coherence-maintenance-evaluator, drift-detection-evaluator, guideline-audit-evaluator, test-quality-audit-evaluator, content-audit-evaluator

**4.2 Add expected-determination rejection to `cross-validate.md` (arbiter role)**
- Same pattern as 4.1

### Safety/Rollback
- **Destructive operations:** None
- **Rollback plan:** `git checkout` individual files
- **Data loss risk:** none

### Feasibility Verification

| Step | Reference | Verified? | Evidence |
|------|-----------|----------|----------|
| 4.1 | `*-evaluator.md` files | ✅ | `ls` confirmed 10 evaluator files |
| 4.2 | `cross-validate.md` | ✅ | `ls` confirmed file exists |

---

## Phase 5: Add PRELOADED_CONTEXT_REJECTED to all task files

**SC-8**

### Steps

**5.1 Add PRELOADED_CONTEXT_REJECTED to verification-audit role files**
- Add `**Preloaded context rejection:**` block in Dispatch Contract of investigator, validator, evaluator, arbiter

**5.2 Add PRELOADED_CONTEXT_REJECTED to spec-audit files**
- Same pattern for all spec-audit-*.md files

**5.3 Add PRELOADED_CONTEXT_REJECTED to plan-audit files**
- Same pattern for all plan-fidelity-*.md files

**5.4 Add PRELOADED_CONTEXT_REJECTED to code-audit files**
- Same pattern for all coherence-*, drift-detection-*, guideline-audit-*, test-quality-audit-*, content-audit-* files

**5.5 Add PRELOADED_CONTEXT_REJECTED to cross-validate.md**
- Same pattern

**5.6 Verify all task files have PRELOADED_CONTEXT_REJECTED**
- Run `grep` for `PRELOADED_CONTEXT_REJECTED` across all task files
- Any file missing → fix

### Safety/Rollback
- **Destructive operations:** None
- **Rollback plan:** `git checkout` individual files
- **Data loss risk:** none

### Feasibility Verification

| Step | Reference | Verified? | Evidence |
|------|-----------|----------|----------|
| 5.1-5.5 | All task files | ✅ | `ls` confirmed ~35 files |
| 5.6 | grep across all files | ✅ | Post-edit verification |

---

## Post-Implementation Verification

- [ ] All 8 SCs verified via grep/file-existence checks (all `string` evidence type)
- [ ] `audit/SKILL.md` has Pre-Flight Gate as first content section
- [ ] No global Invocation or DISPATCH_GATE sections remain
- [ ] Enumerated workflow sections present with per-step dispatch
- [ ] TDT uses `orchestrator: 4 sequential task() calls`
- [ ] All task files have Dispatch Contract, Output Contract, Frugal Contract
- [ ] 4 DiMo role files have Clean-Room Validation
- [ ] Evaluator and arbiter files have expected-determination rejection
- [ ] All task files have PRELOADED_CONTEXT_REJECTED
- [ ] `git diff --stat` reviewed for completeness
- [ ] Feature branch committed and pushed
- [ ] PR created

## Evidence/Provenance

| Claim | Evidence Source | Verified? |
|-------|----------------|----------|
| Template SKILL.md exists | `read .opencode/skills/templates/SKILL.md` | ✅ |
| Template task.md exists | `read .opencode/skills/templates/task.md` | ✅ |
| Audit SKILL.md has Invocation section | `read .opencode/skills/audit/SKILL.md` lines 94-111 | ✅ |
| Audit SKILL.md has DISPATCH_GATE | `read` lines 98-99 | ✅ |
| Audit SKILL.md has DiMo Role Chain | `read` lines 129-137 | ✅ |
| TDT uses `sub-task (DiMo chain)` | `read` lines 48-73 | ✅ |
| ~35 task files exist | `ls .opencode/skills/audit/tasks/` | ✅ |
| 10 evaluator files exist | `ls *-evaluator.md` | ✅ |
| cross-validate.md exists | `ls cross-validate.md` | ✅ |
| 7 analytical artifacts created | `ls .opencode/.issues/2053/artifacts/` | ✅ |
