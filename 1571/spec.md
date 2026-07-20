## Problem

The Guideline Content Verification section of `test-enforcement.sh` reports 20+ MISSING results across guideline files, skill files, and task files. These are static grep-based checks that verify required text patterns exist in files.

## Root Cause

The content-verification checks were written against an older version of the files. When files were refactored (sections renamed, content moved, patterns changed), the corresponding checks in `test-enforcement.sh` were not updated. This creates a maintenance gap where the test script checks for patterns that no longer exist in the current files.

## Affected Checks

### Incremental Build Discipline (091-incremental-build.md)
- `Section 'Top-Down Decomposition'` — MISSING
- `Section 'Bottom-Up Design'` — MISSING
- `Cross-reference to 091-incremental-build.md` — MISSING (in various files)
- `Step 4.5 item decomposition` — MISSING
- `verify-authorization cross-ref to 091` — MISSING
- `writing-plans bottom-up design` — MISSING
- `executing-plans TDD cycle` — MISSING
- `divide-and-conquer tdd_phase` — MISSING

### Scope and Authorization
- `000-critical-rules.md scope FORBIDDEN examples` — MISSING
- `verify-authorization Step 0.5 scope auto-resolve` — MISSING
- `verify-authorization Step 4.6` — MISSING
- `spec-creation/write narrowed exemption` — MISSING

### Spec and Plan Creation
- `writing-plans/create semantic intent` — MISSING
- `brainstorming/explore verification-mechanics` — MISSING
- `spec-auditor SC Precision Audit` — MISSING

### Identity and Session
- `000-critical-rules.md Identity Echo Validation` — MISSING

### Adversarial Audit
- `adversarial-audit SKILL.md must_receive` — MISSING
- `adversarial-audit SKILL.md must_not_receive` — MISSING
- `adversarial-audit SKILL.md task context` — MISSING
- `auditor-glm-5.1.md CONTEXT_TAINTED with SC_CONFLICT` — MISSING
- `cross-validate.md task context` — MISSING

## Evidence

All checks report "MISSING" with exit code 0 from grep (pattern not found in expected file).

## Classification

Pre-existing — these failures were present before any Phase 5 changes.

## Suggested Fix

Audit each MISSING check against the current file content:
1. For each check, read the target file and determine if the pattern should exist
2. If the pattern should exist but was removed during refactoring: add it back
3. If the pattern is obsolete (section was intentionally removed): remove the check from `test-enforcement.sh`
4. If the pattern moved to a different file: update the check's target file path

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)