# Phase 5: Split `audit/tasks/closure-verification.md` into DiMo Chain

**SCs:** SC-6
**Files:** `skills/audit/tasks/closure-verification.md` (remove/reference), `skills/audit/tasks/closure-verification/generator.md` (new), `skills/audit/tasks/closure-verification/knowledge-supporter.md` (new), `skills/audit/tasks/closure-verification/evaluator.md` (new), `skills/audit/tasks/closure-verification/path-provider.md` (new), `skills/audit/SKILL.md` (update)
**Chain dependency:** `phase_4` (independent from Defect 1 phases)

## Steps

### Step 5.1: Read existing closure-verification.md

Read `skills/audit/tasks/closure-verification.md` to understand the current monolithic content. Identify the 4 DiMo roles that need to be separated.

**Dispatch:** `sub-agent` — reads closure-verification.md
**Evidence:** Summary of current content and role boundaries

### Step 5.2: Create generator.md role file

Create `skills/audit/tasks/closure-verification/generator.md` with the generator role instructions extracted from the monolithic task. The generator produces initial analysis/artifacts.

**Dispatch:** `sub-agent` — creates new file
**Evidence:** File exists with correct content

### Step 5.3: Create knowledge-supporter.md role file

Create `skills/audit/tasks/closure-verification/knowledge-supporter.md` with the knowledge-supporter role instructions. This role provides domain knowledge and context.

**Dispatch:** `sub-agent` — creates new file
**Evidence:** File exists with correct content

### Step 5.4: Create evaluator.md role file

Create `skills/audit/tasks/closure-verification/evaluator.md` with the evaluator role instructions. This role evaluates the generator's output against criteria.

**Dispatch:** `sub-agent` — creates new file
**Evidence:** File exists with correct content

### Step 5.5: Create path-provider.md role file

Create `skills/audit/tasks/closure-verification/path-provider.md` with the path-provider role instructions. This role provides resolution paths and recommendations.

**Dispatch:** `sub-agent` — creates new file
**Evidence:** File exists with correct content

### Step 5.6: Update audit SKILL.md Trigger Dispatch Table

Add sequential dispatch entries for the 4 roles (generator → knowledge-supporter → evaluator → path-provider). Remove or update the entry for the monolithic closure-verification.md.

**Dispatch:** `sub-agent` — edits SKILL.md
**Evidence:** Updated Trigger Dispatch Table with sequential dispatch

### Step 5.7: Convert closure-verification.md to reference document

Replace the content of `skills/audit/tasks/closure-verification.md` with a reference document that points to the 4 role files and explains the DiMo chain flow.

**Dispatch:** `sub-agent` — edits closure-verification.md
**Evidence:** File now contains reference content, not monolithic instructions

### Step 5.8: Verify SC-6 compliance

- **SC-6:** `ls` confirms 4 role files exist in `skills/audit/tasks/closure-verification/`
- **SC-6:** File read confirms monolithic task is removed or restructured

**Dispatch:** `sub-agent` — runs verification
**Evidence:** `ls` output and file read confirmation

## SC-to-Step Traceability

| SC ID | Criterion | Step(s) |
|-------|-----------|---------|
| SC-6 | `closure-verification.md` split into 4 role files | 5.1, 5.2, 5.3, 5.4, 5.5, 5.6, 5.7, 5.8 |

## Safety/Rollback

- **Destructive operations:** File deletion of monolithic content (replaced with reference)
- **Rollback plan:** `git checkout feature/1915-sub-agent-dispatch-architecture -- skills/audit/tasks/closure-verification.md` and delete the 4 new role files
- **Data loss risk:** Low — original content preserved in git history
