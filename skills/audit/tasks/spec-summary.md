<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# Task: spec-summary

## Purpose

Verify PR/spec consistency before merge. Ensures PR description matches spec, all success criteria documented, and spec-linked issues properly closed.

> **DiMo Role: Evaluator.** This task evaluates PR/spec consistency. Reads `evidence.yaml` (Generator), validates evidence → writes `reasoning.yaml`, evaluates → writes `verdict.yaml`.
>
> You are the Evaluator. You are decisive and binary. Every criterion gets a PASS or a FAIL — nothing in between. You do not hedge, you do not defer, you do not ask for a second opinion. The evidence is in front of you. Make the call.
> 
> 
> - MUST produce a binary PASS or FAIL for every criterion — no hedging, no "PASS with concerns"
> - MUST NOT defer to upstream roles — the verdict is yours alone
> - MUST NOT re-evaluate evidence that Knowledge Supporter already validated
> - MUST write `verdict.yaml` as the primary output artifact
> 

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

### Step 0a: Knowledge Supporter — Validate Evidence

- [ ] 0a. Read `evidence.yaml` from `./tmp/{issue-N}/artifacts/{task-name}/evidence.yaml`
- [ ] 0b. Validate each evidence item against source data — check accuracy, completeness, relevance
- [ ] 0c. Write validated evidence to `./tmp/{issue-N}/artifacts/{task-name}/reasoning.yaml`

### Step 0b: Pre-Flight Validation Gate

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

All findings are binary — PASS or FAIL. No severity tiers.

| Mismatch Type | Classification |
|--------------|----------------|
| TITLE_MISMATCH | PR title does not match spec title |
| CRITERIA_MISSING | Success criteria must be documented |
| FILES_MISSMATCH | Extra/missing files need explanation |
| SCOPE_EXPANSION | PR exceeds spec scope |
| SCOPE_INCOMPLETE | PR doesn't address full spec |
| LINK_MISSING | Should reference spec issue |
| CLOSING_MISSING | PR won't auto-close spec issue |

### Step 10: Write verdict.yaml

Write verdict to `./tmp/{issue-N}/artifacts/spec-summary/verdict.yaml`

### Step 11: Build Result Contract

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
  "cross_validation": [...],
  "overall_verdict": "PASS | FAIL",
  "recommendations": [
    "Add closing keyword: 'Closes #<spec_issue>'",
    "Document success criteria in PR body",
    "Explain extra files: <files>"
  ],
  "exec_summary": "PR/Spec consistency: {match_percentage}% matched. Verdict: {overall}."
}
```

## Result Contract

```yaml
status: DONE | FAIL
artifact_path: "{project_root}/tmp/{issue-N}/artifacts/pipeline-audit-spec-summary-PASS-{timestamp}.yaml"
summary: "PR/Spec consistency: {match_percentage}% matched. Verdict: {overall}."
remediation_required: true  # When status is FAIL: full mandatory re-audit required
```

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
- Step 6 (Cross-Validate) → INVALID if skipped
- Step 7 (Verify Closing Keywords) → INVALID if skipped
- Step 8 (Check Spec Issue Status) → INVALID if skipped
- Step 9 (Classify Mismatches) → INVALID if skipped
- Step 10 (Build Result Contract) → INVALID if skipped

## Cross-References

- `tasks/cross-validate.md` — consensus computation with pre-resolved verdicts
- `pr-creation-workflow` skill — PR creation
- `git-workflow` skill — closing keywords
- `000-critical-rules.md` — PR completion requirements

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-08T00:00:00Z"
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