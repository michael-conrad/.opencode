<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

> **⚠️ ROLE ANCHOR: You are the DISPATCHED AUDITOR SUB-AGENT.** Your role is to evaluate criteria and produce findings. You do NOT dispatch sub-agents, call `skill()`, or orchestrate pipeline routing. The orchestrator handles all dispatch. Read this file for evaluation criteria and procedure only — ignore any text describing orchestration responsibilities.

# Task: spec-summary

## Purpose

Verify PR/spec consistency before merge. Ensures PR description matches spec, all success criteria documented, and spec-linked issues properly closed.

## Dispatch Contract

- `spec_local_dir`: Local directory containing spec files
- `artifact_evidence_dir`: Directory for evidence artifacts

## Entry Criteria

- PR number provided
- Spec issue number provided (linked from PR)
- `github.owner`, `github.repo` available

## Exit Criteria

- PR description matches spec
- Success criteria documented in PR
- Spec issue properly closed
- PASS if consistent, FAIL if mismatch

## Procedure

### Step 0: Pre-clean

- [ ] 0. Pre-clean: remove artifact files for this task from `./tmp/{issue-N}/artifacts/spec-summary/`

### Step 0a: Pre-Flight Validation Gate

Validate that all required inputs are present before proceeding with the audit:

- [ ] 1. Verify PR number is provided and non-empty
- [ ] 2. Verify spec issue number is provided and non-empty
- [ ] 3. If PR number is missing or empty, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "PR number"
remediation: "PR number is required for spec-summary. The orchestrator must provide the PR number to compare against the spec."
```

- [ ] 4. If spec issue number is missing or empty, return BLOCKED:

```yaml
status: BLOCKED
error: MISSING_REQUIRED_INPUT
missing: "spec issue number"
remediation: "Spec issue number is required for spec-summary. The orchestrator must provide the spec issue number linked to the PR."
```

**This gate fires BEFORE any other step.** If any criterion fails, the task returns BLOCKED immediately — no globbing, no reading, no analysis.

### Step 1: Fetch PR and Load Spec

`spec_local_dir` is REQUIRED. Auditors BLOCK if absent.

```python
pr = github_pull_request_read(method="get", owner=<owner>, repo=<repo>, pullNumber=<N>)
spec_files = glob(pattern="**/*.md", path=f"<spec_local_dir>")
spec_content = ""
for f in spec_files:
    spec_content += read(filePath=f) + "\n"
```

### Step 2: Extract Spec Requirements

```python
requirements = {
    "problem_statement": extract_problem_statement(spec["body"]),
    "success_criteria": extract_success_criteria(spec["body"]),
    "phases": extract_phases(spec["body"]),
    "files_affected": extract_file_requirements(spec["body"])
}
```

### Step 3: Extract PR Content

```python
pr_content = {
    "title": pr["title"],
    "body": pr["body"],
    "files": github_pull_request_read(method="get_files", owner=<owner>, repo=<repo>, pullNumber=<N>),
    "commits": github_pull_request_read(method="get_commits", owner=<owner>, repo=<repo>, pullNumber=<N>)
}
```

### Step 4: Build Evaluation Criteria

| Criterion ID | Description | Expected Result |
|--------------|-------------|-----------------|
| SS-1 | PR title matches spec title | Same or equivalent title |
| SS-2 | PR body describes success criteria | All SC documented |
| SS-3 | PR files match spec requirements | All specified files present |
| SS-4 | PR scope matches spec scope | No extra/missing changes |
| SS-5 | Spec issue linked from PR | Issue reference in body |
| SS-6 | Closing keywords present | "Closes #<issue>" in commit/PR |

### Step 5: Compare PR to Spec

```python
comparison = {
    "title_match": compare_titles(pr_content["title"], requirements["title"]),
    "criteria_documented": check_criteria_documented(pr_content["body"], requirements["success_criteria"]),
    "files_match": compare_files(pr_content["files"], requirements["files_affected"]),
    "scope_match": compare_scope(pr_content, requirements),
    "link_present": check_issue_link(pr_content["body"], spec["number"]),
    "closing_keywords": check_closing_keywords(pr_content)
}
```

### Step 7: Verify Closing Keywords

Check for proper closing keywords:

```python
closing_keywords = ["Closes", "Fixes", "Resolves", "Implements"]
has_closing = any(keyword in pr_content["body"] + pr_content["commits"] for keyword in closing_keywords)

if not has_closing:
    comparison["closing_keywords"] = {
        "match": False,
        "reason": "No closing keyword found. PR may not auto-close spec issue."
    }
```

### Step 8: Check Spec Issue Status

```python
if has_closing:
    # Verify spec issue will be auto-closed
    expected_state = "closed"
else:
    # Spec issue should remain open or be manually closed
    expected_state = "open"
```

### Step 9: Classify Mismatches

| Mismatch Type | Severity | Classification |
|--------------|----------|----------------|
| TITLE_MISMATCH | LOW | May be cosmetic |
| CRITERIA_MISSING | HIGH | Success criteria must be documented |
| FILES_MISSMATCH | MEDIUM | Extra/missing files need explanation |
| SCOPE_EXPANSION | HIGH | PR exceeds spec scope |
| SCOPE_INCOMPLETE | HIGH | PR doesn't address full spec |
| LINK_MISSING | MEDIUM | Should reference spec issue |
| CLOSING_MISSING | MEDIUM | PR won't auto-close spec issue |

### Step 10: Write verdict.yaml

Write verdict to `./tmp/{issue-N}/artifacts/spec-summary/verdict.yaml`

### Step 11: If FAIL: remediate, restart from step 0

### Step 12: Build Result Contract

```yaml
{
  "status": "DONE",
  "audit_type": "spec-summary",
  "pr_number": <N>,
  "spec_issue": <M>,
  "comparison": {
    "title_match": true | false,
    "criteria_documented": <count>/<total>,
    "files_match": {
      "matched": [...],
      "extra_in_pr": [...],
      "missing_from_pr": [...]
    },
    "scope_match": true | false,
    "link_present": true | false,
    "closing_keywords": true | false
  },
  "overall_verdict": "PASS | FAIL",
  "recommendations": [
    "Add closing keyword: 'Closes #<spec_issue>'",
    "Document success criteria in PR body",
    "Explain extra files: <files>"
  ],
  "exec_summary": "PR/Spec consistency: {match_percentage}% matched. Verdict: {overall}."
}
```

## Remediation

If any step FAILs, restart from step 0 (pre-clean).

## Error Handling

| Error | Action |
|-------|--------|
| PR not found | Return BLOCKED with PR number |
| Spec issue not found | Return BLOCKED with issue number |
| Spec not linked from PR | Report as LINK_MISSING, continue |

## Completion Dependency Chain

Every step in this task is a mandatory dependency. Skipping any step produces an INVALID result:
- Step 0 (Pre-Flight Validation Gate) → INVALID if skipped
- Step 1 (Fetch PR and Spec) → INVALID if skipped
- Step 2 (Extract Spec Requirements) → INVALID if skipped
- Step 3 (Extract PR Content) → INVALID if skipped
- Step 4 (Build Evaluation Criteria) → INVALID if skipped
- Step 5 (Compare PR to Spec) → INVALID if skipped
- Step 6 (Verify Closing Keywords) → INVALID if skipped
- Step 7 (Check Spec Issue Status) → INVALID if skipped
- Step 8 (Classify Mismatches) → INVALID if skipped
- Step 9 (Build Result Contract) → INVALID if skipped

## Next Pipeline Step (MANDATORY CONTINUATION)

After spec-summary completes:
- If verdict PASS: proceed to closure-verification or pr_creation
- If verdict FAIL: remediate findings, then re-audit

This step is MANDATORY — the pipeline does not terminate early.

## Cross-References

- `pr-creation-workflow` skill — PR creation
- `git-workflow` skill — closing keywords
- `000-critical-rules.md` — PR completion requirements

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-07-07T00:00:00Z"
rules:
  - id: spec-summary-001
    title: "Success criteria must be documented in PR body"
    conditions:
      all: ["criteria_documented == false"]
    actions: [REQUIRE_CRITERIA_DOCUMENTATION]
    source: "spec-summary.md §Step 5"

  - id: spec-summary-002
    title: "Closing keyword required for auto-close"
    conditions:
      all: ["closing_keyword_present == false"]
    actions: [SUGGEST_CLOSING_KEYWORD]
    source: "spec-summary.md §Step 7"

  - id: spec-summary-003
    title: "Scope expansion requires explanation"
    conditions:
      all: ["scope_expansion == true", "explanation_missing == true"]
    actions: [REQUIRE_SCOPE_EXPLANATION]
    source: "spec-summary.md §Step 9"
```
