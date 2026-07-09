# Phase 1: Update VbC Output to Produce Structured 4-Column Table Data

## Purpose

Modify the VbC verification output format to produce a structured 4-column table (ID, Criterion, Test, Result) with test-type annotations, so that downstream PR body generation can consume it.

## Steps

### Step 1: Update `verify.md` — Add Structured VbC Table Output Format

**File:** `.opencode/skills/verification-before-completion/tasks/verify.md`

Modify the "Per-SC Evidence Table" section to add a new output format that includes a `Test` column and `Result` column with test-type annotations.

**Changes:**
- Add a new subsection "VbC Table Output Format" after the existing "Per-SC Evidence Table" section
- Define the 4-column table format: `| SC ID | Success Criterion | Test | Result |`
- The `Test` column contains the test function name (e.g., `test_creates_db_dir`)
- The `Result` column contains `✅ PASS (<annotation>)` or `❌ FAIL (<annotation>)` where annotation is auto-detected
- Add a note that this table is written to `{project_root}/tmp/{issue-N}/artifacts/vbc-table-*.md` for PR body consumption

**Dispatch:** `sub-agent` via `task()`

### Step 2: Update `collect.md` — Add Test-Type Annotation Collection

**File:** `.opencode/skills/verification-before-completion/tasks/collect.md`

Add a new evidence collection method for test-type detection during evidence collection.

**Changes:**
- Add a new section "Test-Type Annotation Detection" after the existing evidence collection methods
- Define the detection logic: inspect test infrastructure usage patterns
- Add a new evidence storage path for test-type annotations

**Dispatch:** `sub-agent` via `task()`

### Step 3: Update `behavioral-test-evaluation.md` — Add Test-Type Annotation Output

**File:** `.opencode/skills/verification-before-completion/tasks/behavioral-test-evaluation.md`

Modify the evaluation output to include test-type annotations alongside PASS/FAIL results.

**Changes:**
- Add a `test_type` field to the evaluation result contract
- Define the annotation values: `(live DB)`, `(unit)`, `(mock)`, `(integration)`
- Ensure the evaluation output includes the test function name

**Dispatch:** `sub-agent` via `task()`

### Step 4: VbC Table Artifact Writing

Add a step in the verification workflow that writes the structured VbC table to `{project_root}/tmp/{issue-N}/artifacts/vbc-table-*.md` after all SCs are verified.

**File:** `.opencode/skills/verification-before-completion/tasks/verify.md`

**Changes:**
- Add a new step after the per-SC evidence table is complete: write the 4-column table to an artifact file
- The artifact file path is `{project_root}/tmp/{issue-N}/artifacts/vbc-table-{timestamp}.md`
- The table format matches the spec's required format

**Dispatch:** `sub-agent` via `task()`

## Phase Completion Block

- [ ] All 4 steps complete
- [ ] VbC output includes structured 4-column table with test-type annotations
- [ ] VbC table artifact written to `{project_root}/tmp/{issue-N}/artifacts/vbc-table-*.md`
- [ ] Phase checkpoint tag created
