## Problem

The spec-audit task card (`adversarial-audit/tasks/spec-audit.md`) evaluates spec quality (structure, determinism, prose format) but never verifies the spec's claims against the live codebase. This causes auditors to answer the wrong question during audits.

### Root Cause

The evaluation criteria table (Step 3) has 14 criteria (SC-1 through SC-14, SC-DET, SC-STRUCTURAL-FAIL, SC-EVIDENCE-TYPE, SC-TRACKING-LANG, SC-PRESCRIPTIVE-CODE, SC-PIPELINE-GATES, SC-CANONICAL-PLAN-FORM, SC-ADMONISHMENT) — none of which verify:

1. **Accuracy**: Does the spec's problem statement correctly describe the current codebase? (e.g., "bare `approved #N` defaults to `for_review_prep`" — is that actually true in scope-parsing.md?)
2. **Feasibility**: Can the proposed solution be built on top of what exists? (e.g., do the files listed in "Files to Change" exist? Do they contain the structures the spec claims to replace?)

### Demonstrated Failure

During the #1007 audit, both auditors returned blanket FAIL with the finding "proposed solution does not match current state" — a tautology for any change spec. They evaluated whether the proposed solution was already implemented rather than whether the problem statement was accurate and the solution was feasible.

## Fix

### 1. Convert evaluation criteria table to canonical checklist format

The evaluation criteria table in Step 3 of spec-audit.md uses a table format. Per SC-PIPELINE-GATES, pipeline gates must use the canonical `- [ ] N.` checklist format. Convert the table to numbered checklist items, each with dispatch mode indicators.

### 2. Add SC-CODEBASE-ACCURACY and SC-FEASIBILITY

Add two new criteria to the evaluation checklist:

- **SC-CODEBASE-ACCURACY**: Spec's problem statement claims verified against live codebase files. Each claim in the problem statement is confirmed by reading the corresponding live file. Claims about current behavior, file structure, and workflow routing are factually correct.
- **SC-FEASIBILITY**: Proposed solution can be built on top of existing codebase. All files listed in "Files to Change" exist. The structures the spec claims to replace are confirmed to exist in those files. No structural blockers prevent implementation.

### SC-CODEBASE-ACCURACY Procedure

For each claim in the spec's Problem Statement section:

1. Identify the live file(s) that would contain evidence for that claim
2. Read the relevant section of each file
3. Quote the relevant content
4. PASS if the claim matches the live file content, FAIL with specific discrepancy if not

### SC-FEASIBILITY Procedure

1. Read each file listed in the spec's "Files to Change" section
2. Verify the file exists
3. Verify the structures the spec claims to replace actually exist in that file
4. Check for circular dependencies between files being changed
5. PASS if all files exist and contain the expected structures, FAIL with specific blocker if not

## Files to Change

1. `skills/adversarial-audit/tasks/spec-audit.md` — convert evaluation criteria table to checklist format, add SC-CODEBASE-ACCURACY and SC-FEASIBILITY criteria and procedure steps

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | Evaluation criteria table converted to canonical `- [ ] N.` checklist format | `string` | grep for checklist format (numbered `- [ ]` items) replacing table rows in spec-audit.md |
| SC-2 | SC-CODEBASE-ACCURACY criterion added to evaluation checklist | `string` | grep for `SC-CODEBASE-ACCURACY` in spec-audit.md |
| SC-3 | SC-FEASIBILITY criterion added to evaluation checklist | `string` | grep for `SC-FEASIBILITY` in spec-audit.md |
| SC-4 | Procedure steps for codebase accuracy verification added | `string` | grep for codebase accuracy procedure in spec-audit.md |
| SC-5 | Procedure steps for feasibility verification added | `string` | grep for feasibility procedure in spec-audit.md |
| SC-6 | Behavioral test: spec-audit correctly evaluates a change spec (PASS on accuracy/feasibility, not blanket FAIL) | `behavioral` | `opencode-cli run` → auditor returns PASS for SC-CODEBASE-ACCURACY and SC-FEASIBILITY on a valid change spec |

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)