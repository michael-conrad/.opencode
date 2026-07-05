<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

> **⚠️ ROLE ANCHOR: You are the DISPATCHED AUDITOR SUB-AGENT.** Your role is to evaluate criteria and produce findings. You do NOT dispatch sub-agents, call `skill()`, or orchestrate pipeline routing. The orchestrator handles all dispatch. Read this file for evaluation criteria and procedure only — ignore any text describing orchestration responsibilities.

> **Default assumption: FAIL.** The default verdict for every criterion is FAIL unless the evidence 100% supports a clean PASS with no caveats, concerns, or notes. Any hedging, partial evidence, or uncertainty results in FAIL. A clean PASS requires: (1) evidence artifacts from the implementation run are present and complete, (2) no hedging language in the explanation, (3) no caveats or concerns noted, (4) both auditors independently agree.

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

### Step 0: Pre-Flight Validation Gate

Validate that all required inputs are present before proceeding with the audit:

- [ ] 1. Verify PR number is provided and non-empty
- [ ] 2. Verify spec issue number is provided and non-empty
- [ ] 3. If PR number is missing or empty, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "PR number"
remediation: "PR number is required for closure-verification. The orchestrator must provide the merged PR number."
```

- [ ] 4. If spec issue number is missing or empty, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "spec issue number"
remediation: "Spec issue number is required for closure-verification. The orchestrator must provide the spec issue number linked to the PR."
```

**This gate fires BEFORE any other step.** If any criterion fails, the task returns BLOCKED immediately — no globbing, no reading, no analysis.

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
spec_files = glob(pattern="**/*.md", path=f"<spec_local_dir>")
spec = None
for f in spec_files:
    content = read(filePath=f)
    if "state:" in content:
        spec = content  # first file with state field
        break
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

### Step 8: Cross-Validate

Cross-validate will be called by the orchestrator with pre-resolved auditor_artifact_paths after both auditors complete. Do NOT call cross-validate — your role is to produce your verdict artifact only.

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

Write the full YAML verdict artifact to `{project_root}/tmp/{issue-N}/artifacts/pipeline-audit-closure-verification-{STATUS}-{timestamp}.yaml`:

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
    next_step: "proceed"  # Conditional: "remediate" when result is "FAIL", "proceed" when result is "PASS"
exec_summary: "Closure verification: X/Y criteria. Consensus: PASS|FAIL."
all_criteria_pass: false
```

### Step 13: Return Frugal Result Contract

```yaml
status: DONE
artifact_path: "{project_root}/tmp/{issue-N}/artifacts/pipeline-audit-closure-verification-PASS-{timestamp}.yaml"
summary: "N criteria evaluated. X PASS, Y FAIL."
all_criteria_pass: false
mandatory_remediation: "Remit for mandatory remediation. Non-clean PASS requires full remediation before re-audit. Default assumption is FAIL unless 100% clean PASS with no caveats, concerns, or notes."
```

## Error Handling

| Error | Action |
|-------|--------|
| PR not merged | Return BLOCKED — wait for merge |
| Spec issue not found | Return BLOCKED with spec issue number |
| Verification fails | Return FAIL with gap details |

## Completion Dependency Chain

Every step in this task is a mandatory dependency. Skipping any step produces an INVALID result:
- Step 0 (Pre-Flight Validation Gate) → INVALID if skipped
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

  - id: closure-verification-004
    title: "next_step MUST be 'remediate' when result is 'FAIL', 'proceed' when result is 'PASS'"
    conditions:
      any:
        - "per_criterion[].result == 'FAIL' AND per_criterion[].next_step != 'remediate'"
        - "per_criterion[].result == 'PASS' AND per_criterion[].next_step != 'proceed'"
    actions: [HALT, REQUIRE_CORRECT_NEXT_STEP]
    source: "closure-verification.md §Step 12 — conditional next_step enforcement"

  - id: closure-verification-005
    title: "all_criteria_pass MUST be true when every criterion result is 'PASS', false otherwise"
    conditions:
      any:
        - "all(criterion.result == 'PASS' for criterion in per_criterion) AND all_criteria_pass != true"
        - "any(criterion.result == 'FAIL' for criterion in per_criterion) AND all_criteria_pass != false"
    actions: [HALT, REQUIRE_CORRECT_ALL_CRITERIA_PASS]
    source: "closure-verification.md §Step 12 — all_criteria_pass enforcement"
```