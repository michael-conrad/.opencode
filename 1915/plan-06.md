# Phase 6: Split `audit/tasks/spec-summary.md` into DiMo Chain

**SCs:** SC-7
**Files:** `skills/audit/tasks/spec-summary.md` (remove/reference), `skills/audit/tasks/spec-summary/generator.md` (new), `skills/audit/tasks/spec-summary/knowledge-supporter.md` (new), `skills/audit/tasks/spec-summary/evaluator.md` (new), `skills/audit/tasks/spec-summary/path-provider.md` (new), `skills/audit/SKILL.md` (update)
**Chain dependency:** `phase_5` (same pattern, different task)

## Steps

### Step 6.1: Read existing spec-summary.md

Read `skills/audit/tasks/spec-summary.md` to understand the current monolithic content. Identify the 4 DiMo roles.

**Dispatch:** `sub-agent` — reads spec-summary.md
**Evidence:** Summary of current content and role boundaries

### Step 6.2: Create generator.md role file

Create `skills/audit/tasks/spec-summary/generator.md` with generator role instructions.

**Dispatch:** `sub-agent` — creates new file
**Evidence:** File exists with correct content

### Step 6.3: Create knowledge-supporter.md role file

Create `skills/audit/tasks/spec-summary/knowledge-supporter.md` with knowledge-supporter role instructions.

**Dispatch:** `sub-agent` — creates new file
**Evidence:** File exists with correct content

### Step 6.4: Create evaluator.md role file

Create `skills/audit/tasks/spec-summary/evaluator.md` with evaluator role instructions.

**Dispatch:** `sub-agent` — creates new file
**Evidence:** File exists with correct content

### Step 6.5: Create path-provider.md role file

Create `skills/audit/tasks/spec-summary/path-provider.md` with path-provider role instructions.

**Dispatch:** `sub-agent` — creates new file
**Evidence:** File exists with correct content

### Step 6.6: Update audit SKILL.md Trigger Dispatch Table

Add sequential dispatch entries for the 4 roles. Remove or update the entry for the monolithic spec-summary.md.

**Dispatch:** `sub-agent` — edits SKILL.md
**Evidence:** Updated Trigger Dispatch Table

### Step 6.7: Convert spec-summary.md to reference document

Replace content with reference document pointing to the 4 role files.

**Dispatch:** `sub-agent` — edits spec-summary.md
**Evidence:** File now contains reference content

### Step 6.8: Verify SC-7 compliance

- **SC-7:** `ls` confirms 4 role files exist in `skills/audit/tasks/spec-summary/`
- **SC-7:** File read confirms monolithic task is removed or restructured

**Dispatch:** `sub-agent` — runs verification
**Evidence:** `ls` output and file read confirmation

## SC-to-Step Traceability

| SC ID | Criterion | Step(s) |
|-------|-----------|---------|
| SC-7 | `spec-summary.md` split into 4 role files | 6.1, 6.2, 6.3, 6.4, 6.5, 6.6, 6.7, 6.8 |

## Safety/Rollback

- **Destructive operations:** File content replacement
- **Rollback plan:** `git checkout feature/1915-sub-agent-dispatch-architecture -- skills/audit/tasks/spec-summary.md` and delete the 4 new role files
- **Data loss risk:** Low
