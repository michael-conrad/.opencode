<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# Task: closure-verification

## Purpose

Verify merge evidence after PR merge. Ensures spec issue properly closed, success criteria verified, and all follow-up actions documented.

## Entry Criteria

- PR merged (status: `merged`)
- `audit_phase: post_merge`
- `github.owner`, `github.repo` available

## Exit Criteria

- Spec issue closed with proper resolution
- Success criteria verified via tool calls
- Follow-up issues created if needed
- PASS if verified, FAIL if evidence missing

## Procedure

### Step 1: Fetch Merged PR

```python
pr = github_pull_request_read(method="get", owner=<owner>, repo=<repo>, pullNumber=<N>)
```

Verify `pr["state"] == "merged"` before proceeding.

### Step 2: Identify Linked Spec

Extract spec issue number from PR body:

```python
import re
closing_pattern = r"(Closes|Fixes|Resolves|Implements)\s+#(\d+)"
match = re.search(closing_pattern, pr["body"])
if match:
    spec_issue = int(match.group(2))
else:
    return BLOCKED("No linked spec issue found")
```

### Step 3: Load Spec

`spec_local_dir` is REQUIRED. Auditors BLOCK if absent.
```python
spec = read(filePath=f"<spec_local_dir>/spec.md")
```

### Step 4: Verify Issue Closed

```python
if spec["state"] != "closed":
    return BLOCKED(f"Spec issue #{spec_issue} not closed after PR merge")
```

### Step 5: Build Evaluation Criteria

| Criterion ID | Description | Expected Result |
|--------------|-------------|-----------------|
| CV-1 | PR successfully merged | `merged` status |
| CV-2 | Spec issue closed | Issue state `closed` |
| CV-3 | Closing commit linked | Commit references spec issue |
| CV-4 | Success criteria verified | Tool-call evidence for each SC |
| CV-5 | Follow-up issues created | Future work documented |
| CV-6 | No open blocking issues | No open blockers |

### Step 6: Extract Success Criteria

```python
success_criteria = extract_success_criteria(spec["body"])
```

### Step 7: Verify Each Criterion

For each success criterion:

```python
verification_evidence = []
for criterion in success_criteria:
    # Parse criterion for verification method
    if "grep" in criterion or "ls" in criterion or "file exists" in criterion:
        # File system verification
        result = verify_file_criterion(criterion)
        verification_evidence.append({
            "criterion": criterion,
            "verified": result["verified"],
            "evidence": result["tool_call_reference"]
        })
    elif "test" in criterion:
        # Test verification
        result = verify_test_criterion(criterion)
        verification_evidence.append({
            "criterion": criterion,
            "verified": result["verified"],
            "evidence": result["tool_call_reference"]
        })
    else:
        # Manual verification required
        verification_evidence.append({
            "criterion": criterion,
            "verified": None,
            "evidence": None,
            "note": "Requires manual verification"
        })
```

### Step 8: Cross-Validate via task()

```python
task(
    subagent_type="general",
    prompt=f"""Use adversarial-audit skill --task cross-validate with:

spec_local_dir: {spec_local_dir}
audit_phase: post_merge
authorization_scope: {authorization_scope}
halt_at: {halt_at}
pr_strategy: {pr_strategy}
pipeline_phase: {pipeline_phase}

# NOTE: cross-validate does NOT dispatch auditors — it receives
# pre-resolved auditor_artifact_paths and reads YAMLs from disk.
auditor_artifact_paths: {auditor_artifact_paths}

worktree.path: {worktree.path}
"""
)
```

### Step 9: Check for Open Blockers

```python
# Check for blocking comments
comments = issue-operations -> read-comments (github_issue_read(method="get_comments", owner=<owner>, repo=<repo>, issue_number=spec_issue) <!-- Routes through issue-operations per SPEC #683 -->
blocking_comments = [c for c in comments if "blocked" in c["body"].lower() or "blocker" in c["body"].lower()]

if blocking_comments:
    comparison["blocking_issues"] = {
        "count": len(blocking_comments),
        "comments": blocking_comments
    }
```

### Step 10: Check Follow-up Issues

```python
# Check for follow-up issue references
follow_up_pattern = r"Follow-up:\s+#(\d+)|See:\s+#(\d+)"
follow_up_matches = re.findall(follow_up_pattern, pr["body"])
follow_up_issues = [int(m[0] or m[1]) for m in follow_up_matches]

if follow_up_issues:
    # Verify follow-up issues exist and are open
    for issue_num in follow_up_issues:
        follow_up = issue-operations -> read-issue (github_issue_read(method="get", owner=<owner>, repo=<repo>, issue_number=issue_num) <!-- Routes through issue-operations per SPEC #683 -->
        if follow_up["state"] != "open":
            comparison["follow_up_issues"] = {
                "issue": issue_num,
                "status": follow_up["state"],
                "problem": "Follow-up issue not open"
            }
```

### Step 11: Classify Verification Gaps

| Gap Type | Severity | Classification |
|---------|----------|----------------|
| ISSUE_NOT_CLOSED | HIGH | Spec issue still open |
| CRITERIA_UNVERIFIED | MEDIUM | Success criteria missing evidence |
| MISSING_CLOSING_COMMIT | LOW | Commit doesn't reference spec |
| OPEN_BLOCKERS | HIGH | Blocking issues remain |
| FOLLOW_UP_NOT_OPEN | MEDIUM | Follow-up issue closed |

### Step 12: Write Verdict Artifact to Disk

Write the full YAML verdict artifact to `./tmp/artifacts/pipeline-{issue_number}-audit-closure-verification-{STATUS}-{timestamp}.yaml`:

```yaml
audit_phase: post_merge
auditor_type: closure-verification
family: <family>
issue_number: <N>
generated_at: "<timestamp>"
orchestrator_model: "<model>"
merge_status:
  pr_merged: true
  spec_closed: true
  closing_commit: "<sha>"
success_criteria_verification:
  - criterion: "CV-1"
    verified: true
    evidence: "<tool-call reference>"
    manual_required: false
follow_up_issues: []
blocking_issues: []
per_criterion:
  - criterion_id: "CV-1"
    result: "PASS"
    evidence: "<tool-call reference>"
    explanation: "<reasoning>"
    remediation: ""
    next_step: "proceed"
exec_summary: "Closure verification: X/Y criteria. Consensus: PASS|FAIL."
```

### Step 13: Return Frugal Result Contract

```yaml
status: DONE
artifact_path: "./tmp/artifacts/pipeline-{issue_number}-audit-closure-verification-PASS-{timestamp}.yaml"
summary: "N criteria evaluated. X PASS, Y FAIL."
```

## Error Handling

| Error | Action |
|-------|--------|
| PR not merged | Return BLOCKED — wait for merge |
| Spec issue not found | Return BLOCKED with spec issue number |
| Verification fails | Return FAIL with gap details |

## Dispatch Mandate (CRITICAL — per critical-rules-048)

This task is a **reference document** that defines evaluation criteria and result contracts. The orchestrator is responsible for:
1. Dispatching a sub-agent for `resolve-models` to obtain auditor pair
2. Dispatching auditor sub-agents in parallel
3. Dispatching a sub-agent for `cross-validate` with pre-resolved `auditor_artifact_paths`

This task MUST NOT be read and executed inline. Reading this file and performing the described steps via raw tool calls is a CRITICAL VIOLATION per critical-rules-048.

## Completion Dependency Chain

Every step in this task is a mandatory dependency. Skipping any step produces an INVALID result:
- Step 1 (Fetch Merged PR) → INVALID if skipped
- Step 2 (Identify Linked Spec) → INVALID if skipped
- Step 3 (Fetch Spec Issue) → INVALID if skipped
- Step 4 (Verify Issue Closed) → INVALID if skipped
- Step 5 (Build Evaluation Criteria) → INVALID if skipped
- Step 6 (Extract Success Criteria) → INVALID if skipped
- Step 7 (Verify Each Criterion) → INVALID if skipped
- Step 8 (Cross-Validate) → INVALID if skipped
- Step 9 (Check for Open Blockers) → INVALID if skipped
- Step 10 (Check Follow-up Issues) → INVALID if skipped
- Step 11 (Classify Verification Gaps) → INVALID if skipped
- Step 12 (Build Result Contract) → INVALID if skipped

## Next Pipeline Step (MANDATORY CONTINUATION)

After closure-verification completes:
- If consensus PASS: proceed to post-merge verification or pipeline end
- If consensus FAIL: remediate findings, then re-audit (resolve-models → auditors → cross-validate)

This step is MANDATORY — the pipeline does not terminate early.

## Cross-References

- `tasks/cross-validate.md` — consensus computation with pre-resolved verdicts
- `git-workflow` skill — merge completion
- `verification-before-completion` skill — verification gate
- `000-critical-rules.md` — merge evidence requirements

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-08T00:00:00Z"
rules:
  - id: closure-verification-001
    title: "Spec issue must be closed after PR merge"
    conditions:
      all: ["pr_merged == true", "spec_issue_state != 'closed'"]
    actions: [BLOCK, REQUIRE_MANUAL_CLOSE]
    source: "closure-verification.md §Step 4"

  - id: closure-verification-002
    title: "Success criteria require tool-call evidence"
    conditions:
      all: ["criterion_verified == false", "tool_call_reference == null"]
    actions: [REQUIRE_EVIDENCE]
    source: "closure-verification.md §Step 7"

  - id: closure-verification-003
    title: "Open blockers prevent closure verification"
    conditions:
      all: ["blocking_comments_count > 0"]
    actions: [REPORT_BLOCKERS]
    source: "closure-verification.md §Step 9"
```