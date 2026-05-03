---
skill: guideline-auditor
task: audit
type: discipline-enforcing
license: MIT
---

# Task: audit

## Purpose

Scan guideline files for ambiguity, conflicts, and LLM compliance issues.

## Entry Criteria

- Guidelines directory exists at `.opencode/guidelines/`
- Skill invoked with `--task audit`

## Exit Criteria

- All guideline files scanned
- Issues identified and categorized
- Audit report created in `./tmp/audit-YYYYMMDD.md`

## Procedure

### Step 1: List Guideline Files

Identify all guideline files to audit using glob or srclight tools.

### Step 2: Scan Each File

For each guideline file:

1. Read file content
2. Check for problem classes:
   - AMBIGUOUS: Multiple interpretations
   - CONFLICTING: Contradicts other rules
   - UNENFORCEABLE: Cannot verify compliance
   - REDUNDANT-CROSS-FILE: Duplicates other files
   - MISSING: Referenced but absent
   - CONTEXT-OVERFLOW: Too long/wordy
   - REORGANIZE: Structural issues

### Step 3: One Issue at a Time

Present exactly one finding per interaction. Prompts ≤200 words. Tables ≤10 rows. Quotes ≤3 lines.

Format: `File: <path> | Rule: <1-line> | Problem: <class> | Fix? (fix/skip/stop)`.

### Step 4: Create Audit Report

Write findings to `./tmp/audit-YYYYMMDD.md`:

```markdown
# Guideline Audit Log

Date: YYYYMMDD
Auditor: guideline-auditor

## Issues Found: N

### Issue 1: [Problem Class]

**File:** path/to/file.md
**Rule:** [Quoted rule]
**Explanation:** [Why this is a problem]
**Proposed Fix:** [Minimal change]

## Summary

- CRITICAL: N
- ARCHITECTURE: N
- STYLE: N
- MINOR: N
```

### Step 5: Store Report

Write the completed audit report to the file path.

## Context Required

- Guideline file paths
- Session values: <github.owner>, <github.repo>

## Result Contract

```yaml
status: AUDIT_COMPLETE
issues_found: N
report_path: ./tmp/audit-YYYYMMDD.md
problem_classes:
  CRITICAL: N
  ARCHITECTURE: N
  STYLE: N
  MINOR: N
```

```yaml+symbolic
rules:
  - id: guideline-auditor-001
    title: "One issue at a time — no batching"
    conditions:
      all: ["multiple_issues_in_single_report == true"]
    actions: [SPLIT_INTO_SINGLE_ISSUES]
    source: "guideline-auditor/tasks/audit.md"
```

Co-authored with AI: <AgentName> (<ModelId>)
