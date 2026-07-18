# Task: verify-blockers

## Purpose

Check for blocking issues or dependencies that prevent implementation.

## Entry Criteria

- Authorization verified
- Sub-issues verified
- Codebase verified

## Exit Criteria

- Authorization confirmed in work state file (`{project_root}/tmp/{N}/work.md`)
- No blocking issues superseding spec
- No unresolved dependencies

## Procedure

### Step 1: Check Authorization via Work State File

```python
work_state = read_work_state(f"{project_root}/tmp/{N}/work.md")  # reads from ## verify-authorization section
auth_info = work_state.get("authorization", {})

if auth_info.get("authorized") == True:
    # Authorization confirmed via work state — proceed
    pass
else:
    HALT(f"Authorization not confirmed in work state for #{N}")
```

### Step 2: Check for Superseding Issues

```python
# Query for issues that may supersede current spec
issues = issue-operations -> list-issues (github_list_issues(owner=<github.owner>, repo=<github.repo>, state="open") <!-- Routes through issue-operations per SPEC #683 -->
for issue in issues:
    if issue_supersedes_current(issue, current_spec):
        HALT("Superseding issue: #{}".format(issue["number"]))
```

### Step 3: Check Dependencies

For each dependency listed in spec:
- Verify availability
- Check for dependency conflicts
- Document any issues

## Blockers

| Blocker | Action |
|---------|--------|
| No authorization in work state | HALT and report |
| Superseding issue | HALT and report |
| Conflicting spec | HALT and identify conflict |
| Missing dependency | HALT and ask about alternatives |

## Adversarial Verification: Blocker State

Adversarial verification model (evidence format, binary PASS/FAIL classification): Load [adversarial-verification](enforcement/adversarial-verification.md)

### Verify Blocker Issues Exist and Are Actually Blocking

```
For each identified blocker issue:
  blocker = issue-operations -> read-issue (github_issue_read(method="get", issue_number=blocker_number) <!-- Routes through issue-operations per SPEC #683 -->
  
  - Verify issue exists (404 → MISSING-TRACEABILITY: blocker reference is stale)
  - Verify issue state matches claimed state:
    - If claimed "open" but actually "closed" → VERIFICATION-GAP (FAIL: blocker resolved)
    - If claimed "closed" but actually "open" → CONFLICTING (blocker still active)
  - Verify issue is genuinely blocking:
    - If blocker has a merged PR that resolves it → blocker is resolved
    - If blocker title/content doesn't relate to current issue → VERIFICATION-GAP
```

**Evidence artifact:** `issue-operations -> read-issue (github_issue_read(method=get)` for each blocker showing actual state, title, and labels. <!-- Routes through issue-operations per SPEC #683 -->

### Verify Superseding Issues Against Actual State

```
For each potential superseding issue:
  issue = issue-operations -> read-issue (github_issue_read(method="get", issue_number=N) <!-- Routes through issue-operations per SPEC #683 -->
  comments = issue-operations -> read-comments (github_issue_read(method="get_comments", issue_number=N) <!-- Routes through issue-operations per SPEC #683 -->
  
  - Verify issue is still open and active (closed → not superseding)
  - Verify issue scope actually covers current spec (read body, compare scope)
  - Do NOT trust "supercedes" label or claim without body verification
  - If claimed superseding but scope is narrower than current spec → CONFLICTING
```

**Evidence artifact:** Issue body comparison between claimed superseder and current spec.

### Verify Dependency Availability

```
For each dependency listed in spec:
  - If dependency is a package/library → verify with srclight or import check
  - If dependency is another issue → verify via issue-operations -> read-issue (github_issue_read(method=get) <!-- Routes through issue-operations per SPEC #683 -->
    - Is it open? Closed? Does it have a merged PR?
  - If dependency is a code symbol → verify with srclight_get_signature
    - Does the symbol exist? Is it in the expected module?
```

**Evidence artifact:** Tool call results confirming dependency existence and availability.

### Verify Authorization State Against Work State File

```
work_state = read_work_state(f"{project_root}/tmp/{N}/work.md")
auth_info = work_state.get("authorization", {})

has_auth = auth_info.get("authorized") == True
has_scope = auth_info.get("authorization_scope") is not None

- has_auth AND has_scope → Correct state, proceed with implementation
- has_auth AND no scope → STRUCTURE-VIOLATION (auto-fix: write default scope `for_analysis`)
- no auth AND has scope → VERIFICATION-GAP (authorization not recorded despite scope)
- no auth AND no scope → Correct state, proceed to HALT
```

**Evidence artifact:** Work state file content showing `authorization.authorized` and `authorization.authorization_scope` values.

Labels are advisory visibility markers only — they do NOT gate execution. If the `needs-approval` label is present but work state confirms authorization, the label is stale and should be cleaned up asynchronously.

### Task-Specific Findings

Load [adversarial-verification](enforcement/adversarial-verification.md) for the binary PASS/FAIL classification model (auto-fix as remediation action only) and evidence artifact format.

## Context Required

- Related tasks: `verify-authorization`, `verify-open-questions`
- Authorization state: `{project_root}/tmp/{N}/work.md` is the canonical source. Labels are advisory visibility markers only — they do NOT gate execution.

## Enforcement References

- Evidence format + finding classification: Load [adversarial-verification](enforcement/adversarial-verification.md)
- Scope parsing: Load [scope-parsing](enforcement/scope-parsing.md)
