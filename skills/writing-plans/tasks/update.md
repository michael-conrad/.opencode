# Task: update — Plan Update for Non-Substantive Spec Revisions

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

## Purpose

Update an existing implementation plan to reflect a non-substantive spec revision (changes to evidence types, verification methods, artifact paths, or SC wording that do NOT alter implementation intent, scope, or success criteria semantics). Preserves existing approval state — does NOT clear approval markers.

## Entry Criteria

- Spec has been revised (non-substantive revision only)
- Existing plan file exists at `.issues/{N}/plan.md` or `*/.issues/{N}/plan.md`
- Plan was previously approved (has approval markers)

## Exit Criteria

- Plan file updated with revised SC verification methods, evidence types, and artifact paths
- Approval state preserved (approval markers NOT cleared)
- Result contract returned with `status: DONE` and `finding_summary`

## Procedure

### Step 1: Read Revised Spec

Read the revised spec from the issue body via `github_issue_read(method=get, issue_number=<spec_issue_number>)`. Extract the SC table and identify which SCs have changed (evidence types, verification methods, artifact paths).

### Step 2: Read Existing Plan

Read the existing plan file at `.issues/{N}/plan.md` (or `*/.issues/{N}/plan.md`). Locate the SC sections that correspond to the revised spec SCs.

### Step 3: Diff SCs

Compare the revised spec SCs against the plan's SCs. Identify only the sections that need updating:

- SC verification methods
- SC evidence types
- SC artifact paths
- SC wording (non-substantive only — does not alter intent)

Do NOT update:
- Phase definitions or concern boundaries
- Implementation steps or approach
- Dependency ordering
- Approval markers or state

### Step 4: Update Plan

Edit the plan file to reflect the revised SC metadata. Only modify the specific sections identified in Step 3. Preserve all existing approval state markers.

### Step 5: Verify

Confirm the plan file is valid YAML/markdown and that approval markers remain intact.

### Step 6: Return Result Contract

```yaml
status: DONE
artifact_path: "<path to updated plan file>"
summary: "Updated plan for spec #{spec_issue_number}: revised {N} SC verification methods/evidence types. Approval state preserved."
```
