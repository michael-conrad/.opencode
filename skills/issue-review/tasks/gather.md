# Task: gather

## Purpose

Collect all issue data needed by downstream tasks. This is a pure data-collection step — no decisions.

## Pre-Conditions

- **Load guideline:** `.opencode/guidelines/067-context-completeness.md` before proceeding — ALL comments MUST be read before any triage decision

## Entry Criteria

- Issue number provided via `--issue N`
- GitHub MCP available for issue/comment operations

## Exit Criteria

- All issue data collected
- Standard data set extracted for triage
- Sub-issue data recursively gathered if present

## Procedure

### Step 1: Read Issue Body

```
issue-operations -> read-issue <!-- Routes through issue-operations per SPEC #683 -->
```

### Step 2: Read All Comments

```
issue-operations -> read-comments <!-- Routes through issue-operations per SPEC #683 -->
```

Record comment count for evidence. Note: per `067-context-completeness.md`, ALL comments MUST be read before any triage decision.

### Step 3: Read Labels and Authorization Status

```
issue-operations -> read-labels <!-- Routes through issue-operations per SPEC #683 -->
```

Extract:
- `needs-approval` label presence
- Any categorization labels (enhancement, bug, architecture, etc.)
- Authorization status from comments (look for "approved", "go", `#N approved` patterns)

### Step 4: Detect Sub-issues

```
issue-operations -> read-sub-issues <!-- Routes through issue-operations per SPEC #683 -->
```

If sub-issues exist, store their issue numbers for recursive gathering.

### Step 5: Recursively Gather Sub-issue Data

For each sub-issue, repeat Steps 1-4:
- Read sub-issue body
- Read sub-issue comments
- Read sub-issue labels
- Check for further nesting (unlikely but handled)

### Step 6: Extract Standard Data Set

From all gathered data, extract prose descriptions of:

- [ ] 1. **Issue type classification hints:**
   - Phases/steps present in body (e.g., "Phase 1:", "Phase 2:")
   - Success criteria section present
   - Bug report language patterns ("crash", "error", "broken", "steps to reproduce")

- [ ] 2. **Comment themes:**
   - Questions asked by commenters
   - Revisions or spec changes noted
   - Blockers reported
   - Audit findings (check local audit artifacts at `.issues/{N}/audit/*.yaml` for existing verdicts)
   - Authorization comments ("approved", "go")

- [ ] 3. **Last audit timestamp:**
   - Most recent `.yaml` file timestamp in `.issues/{N}/audit/`
   - Used by `just-review` path to assess staleness

- [ ] 4. **Authorization status:**
   - Explicit approval comments found (quote them)
   - `needs-approval` label present or absent

- [ ] 5. **Spec structure signals:**
   - Has phases? (count them)
   - Has success criteria?
   - Has edge cases?
   - Has affected files table?
   - Has risk assessment?

- [ ] 6. **Fix spec sub-issue check (for bug reports):**
   - Do any sub-issues have titles starting with `[SPEC] Fix:`?
   - Do any sub-issues have the `spec` label?
   - If bug report has existing fix spec sub-issues, note their numbers and status
   - This informs the `analyze-and-spec` task (skip creation if already exists)

### Step 7: Return Data for Downstream

Prose description of gathered data — no structured schema required. The agent carries context forward to the triage task.

## Output Format

Prose summary of all gathered data, organized by the five categories above. Include comment count and specific authorization evidence for audit trail.

## Edge Cases

| Case | Handling |
|------|----------|
| No comments | Proceed normally — comment count = 0 |
| Issue is closed | Note state; triage decides if stale or complete |
| Sub-issues present | Gather each; triage runs independently per sub-issue |
| No sub-issues | Skip recursive gathering |
| API error | Report error and HALT; do not proceed with partial data |

## Live Verification: Gathered Data Claims (MANDATORY)

**Each data claim gathered for downstream tasks MUST be verified via actual tool calls. Assertions without tool-call artifacts are VERIFICATION-GAP findings per `065-verification-honesty.md`.**

| Claim | Verification Action | Tool Call | Problem Class |
|-------|-------------------|-----------|---------------|
| "Issue has N comments" | Re-count via `get_comments` response | `issue-operations -> read-comments` → count items | VERIFICATION-GAP | <!-- Routes through issue-operations per SPEC #683 -->
| "Authorization comment exists" | Verify comment author is developer, not bot/agent | `issue-operations -> read-comments` → check `author_association` | CONFLICTING | <!-- Routes through issue-operations per SPEC #683 -->
| "Sub-issues exist" | Verify sub-issues are accessible and not 404 | `issue-operations -> read-sub-issues` → check each child exists | MISSING-TRACEABILITY | <!-- Routes through issue-operations per SPEC #683 -->
| "`needs-approval` label present/absent" | Verify label list matches claimed state | `issue-operations -> read-labels` → check label array | STRUCTURE-VIOLATION | <!-- Routes through issue-operations per SPEC #683 -->
| "Bug report has fix spec" | Verify sub-issue exists with correct prefix | `issue-operations -> read-sub-issues` + `issue-operations -> read-issue` per child | MISSING-ELEMENT | <!-- Routes through issue-operations per SPEC #683 -->
| "Last audit timestamp" | Verify comment containing audit pattern actually exists | `issue-operations -> read-comments` → search for audit patterns | VERIFICATION-GAP | <!-- Routes through issue-operations per SPEC #683 -->

**Evidence artifact:** Tool call results for each claim category.

### Finding Classification

| Finding | Problem Class | Classification | Action |
|--------|---------------|----------------|--------|
| Comment count mismatched | VERIFICATION-GAP | auto-fix | Re-count and report correct number |
| Authorization from bot/agent | CONFLICTING | flag-for-review | Reject as valid authorization |
| Sub-issue 404 | MISSING-TRACEABILITY | flag-for-review | Developer must resolve missing issue |
| Label state contradicted claim | STRUCTURE-VIOLATION | auto-fix | Report actual label state |
| Fix spec missing for bug | MISSING-ELEMENT | conditional | Proceed to `analyze-and-spec` to create one |