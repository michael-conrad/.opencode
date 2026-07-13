# Phase 7: Split `audit/tasks/coherence-extraction.md` into DiMo Chain

**SCs:** SC-8
**Files:** `skills/audit/tasks/coherence-extraction.md` (remove/reference), `skills/audit/tasks/coherence-extraction/generator.md` (new), `skills/audit/tasks/coherence-extraction/knowledge-supporter.md` (new), `skills/audit/tasks/coherence-extraction/evaluator.md` (new), `skills/audit/tasks/coherence-extraction/path-provider.md` (new), `skills/audit/SKILL.md` (update)
**Chain dependency:** `phase_6` (same pattern, different task)

## Steps

### Step 7.1: Read existing coherence-extraction.md

Read `skills/audit/tasks/coherence-extraction.md` to understand the current monolithic content. Identify the 4 DiMo roles.

**Dispatch:** `sub-agent` — reads coherence-extraction.md
**Evidence:** Summary of current content and role boundaries

### Step 7.2: Create generator.md role file

Create `skills/audit/tasks/coherence-extraction/generator.md` with generator role instructions.

**Dispatch:** `sub-agent` — creates new file
**Evidence:** File exists with correct content

### Step 7.3: Create knowledge-supporter.md role file

Create `skills/audit/tasks/coherence-extraction/knowledge-supporter.md` with knowledge-supporter role instructions.

**Dispatch:** `sub-agent` — creates new file
**Evidence:** File exists with correct content

### Step 7.4: Create evaluator.md role file

Create `skills/audit/tasks/coherence-extraction/evaluator.md` with evaluator role instructions.

**Dispatch:** `sub-agent` — creates new file
**Evidence:** File exists with correct content

### Step 7.5: Create path-provider.md role file

Create `skills/audit/tasks/coherence-extraction/path-provider.md` with path-provider role instructions.

**Dispatch:** `sub-agent` — creates new file
**Evidence:** File exists with correct content

### Step 7.6: Update audit SKILL.md Trigger Dispatch Table

Add sequential dispatch entries for the 4 roles. Remove or update the entry for the monolithic coherence-extraction.md.

**Dispatch:** `sub-agent` — edits SKILL.md
**Evidence:** Updated Trigger Dispatch Table

### Step 7.7: Convert coherence-extraction.md to reference document

Replace content with reference document pointing to the 4 role files.

**Dispatch:** `sub-agent` — edits coherence-extraction.md
**Evidence:** File now contains reference content

### Step 7.8: Verify SC-8 compliance

- **SC-8:** `ls` confirms 4 role files exist in `skills/audit/tasks/coherence-extraction/`
- **SC-8:** File read confirms monolithic task is removed or restructured

**Dispatch:** `sub-agent` — runs verification
**Evidence:** `ls` output and file read confirmation

## SC-to-Step Traceability

| SC ID | Criterion | Step(s) |
|-------|-----------|---------|
| SC-8 | `coherence-extraction.md` split into 4 role files | 7.1, 7.2, 7.3, 7.4, 7.5, 7.6, 7.7, 7.8 |

## Safety/Rollback

- **Destructive operations:** File content replacement
- **Rollback plan:** `git checkout feature/1915-sub-agent-dispatch-architecture -- skills/audit/tasks/coherence-extraction.md` and delete the 4 new role files
- **Data loss risk:** Low
