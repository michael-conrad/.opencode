# Task: retroactive

## Purpose

Create a plan for an existing spec that does not yet have one.

## Procedure

- [ ] 1. **Query existing spec:**

    - Get spec from GitHub Issue
    - Search for existing plan files at `*/.issues/{N}/plan.md` that reference the spec

- [ ] 2. **If no plan exists:**

    - Create local plan file at `*/.issues/{N}/plan.md`
    - Include spec reference as prose in body (e.g., `Spec: #N`)
    - Plan content uses hybrid approach (phases + TDD steps)
    - Include header, file structure, self-review
    - HALT and wait for plan approval

- [ ] 3. **If plan exists:**

    - Validate plan (check for placeholders, TDD structure)
    - If invalid → Report issues
    - If valid → Proceed to implementation

## Live Verification: Retroactive Plan Evidence (MANDATORY)

**Each factual claim about existing specs and plans MUST be verified via tool call. Assertions without tool-call artifacts are VERIFICATION-GAP findings per `065-verification-honesty.md`.**

| Claim | Verification Action | Tool Call | Problem Class |
|-------|-------------------|-----------|---------------|
| "Spec #N exists" | Verify issue exists and has spec label | `issue-operations -> read-issue (github_issue_read(method="get", issue_number=N)` | MISSING-ELEMENT | <!-- Routes through issue-operations per SPEC #683 -->
| "No plan exists for spec #N" | Check for local plan file | `ls */.issues/{N}/plan.md 2>/dev/null` | VERIFICATION-GAP |
| "Plan is valid" | Run `validate` task checks | `validate` task inline | VERIFICATION-GAP |
| "Plan has sub-issues" | Check sub-issue state | `issue-operations -> read-sub-issues (github_issue_read(method="get_sub_issues", issue_number=plan_number)` | MISSING-ELEMENT | <!-- Routes through issue-operations per SPEC #683 -->

**Evidence artifact:** Tool call results confirming spec exists, plan state, and validation outcome.

### Finding Classification

| Finding | Problem Class | Classification | Action |
|--------|---------------|----------------|--------|
| Spec not found | MISSING-ELEMENT | flag-for-review | HALT — cannot create plan for missing spec |
| Plan actually exists (missed) | VERIFICATION-GAP | auto-fix | Use existing plan instead of creating duplicate |
| Plan invalid | VERIFICATION-GAP | flag-for-review | Report issues, do not proceed to implementation |
| Spec not approved | CONFLICTING | flag-for-review | HALT — plan requires approved spec |
