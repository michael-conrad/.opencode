# Task: guideline-audit

## Purpose

Audit guideline files for ambiguity, conflicts, and LLM compliance. Identifies problems one at a time with concise prompts. Uses dual-adversarial verification for each finding.

## Entry Criteria

- Target guideline file(s) specified OR full audit requested
- `audit_phase: guideline_update` OR `spec_creation`
- `github.owner`, `github.repo` available

## Exit Criteria

- All guideline files scanned
- Problems identified with LLM compliance check
- PASS/FAIL consensus for each problem class
- Findings written to `./tmp/artifacts/audit-guideline-<issue>.md`

## Procedure

### Step 1: Identify Target Files

If specific file(s) provided:
```python
target_files = [f for f in args.files if f.endswith('.md')]
```

If full audit:
```python
target_files = glob(".opencode/guidelines/*.md")
```

### Step 2: Build Evaluation Criteria

| Criterion ID | Description | Expected Result |
|--------------|-------------|-----------------|
| GA-1 | Rule conditions are unambiguous | Each condition parseable |
| GA-2 | No conflicting rules | No rule contradicts another |
| GA-3 | Actions are LLM-enforceable | Each action is executable |
| GA-4 | No redundant cross-file references | Each source appears once |
| GA-5 | Context fits in LLM window | Rule context ≤ token limit |
| GA-6 | File organization logical | Related rules grouped |

### Step 3: Scan for Problem Classes

For each file:

```python
for file in target_files:
    content = read(file)
    
    problems = []
    
    # AMBIGUOUS: Rule conditions open to interpretation
    if has_ambiguous_conditions(content):
        problems.append({
            "class": "AMBIGUOUS",
            "file": file,
            "rule_id": extract_rule_id(content),
            "problem": "Condition uses vague terms",
            "fix": "Specify concrete values"
        })
    
    # CONFLICTING: Rule contradicts another rule
    if conflicts_with_other_rule(content, all_rules):
        problems.append({
            "class": "CONFLICTING",
            "file": file,
            "rule_id": extract_rule_id(content),
            "conflicts_with": find_conflicting_rule(content),
            "fix": "Reconcile contradiction"
        })
    
    # UNENFORCEABLE: Action cannot be executed by LLM
    if has_unenforceable_actions(content):
        problems.append({
            "class": "UNENFORCEABLE",
            "file": file,
            "rule_id": extract_rule_id(content),
            "action": extract_action(content),
            "fix": "Make action executable"
        })
    
    # REDUNDANT-CROSS-FILE: Same source referenced multiple times
    if has_redundant_references(content):
        problems.append({
            "class": "REDUNDANT-CROSS-FILE",
            "file": file,
            "source": extract_redundant_source(content),
            "fix": "Consolidate references"
        })
    
    # MISSING: Gap in coverage
    if has_coverage_gap(content, expected_coverage):
        problems.append({
            "class": "MISSING",
            "file": file,
            "gap": describe_gap(content),
            "fix": "Add missing rule"
        })
    
    # CONTEXT-OVERFLOW: Rule context exceeds token limit
    if context_exceeds_limit(content):
        problems.append({
            "class": "CONTEXT-OVERFLOW",
            "file": file,
            "token_count": count_tokens(content),
            "fix": "Split or compress"
        })
```

### Step 4: One Problem At a Time

Present exactly one finding per interaction:

```
File: <path>
Rule: <1-line summary>
Problem: <class>
Fix? (fix/skip/stop)
```

Do NOT batch multiple problems in one message.

### Step 5: Cross-Validate via task()

For each problem class:

```python
task(
    subagent_type="general",
    prompt=f"""Use adversarial-audit skill --task cross-validate with:

evidence_payload:
---
FILE: {file}
CONTENT: {content}
PROBLEM_CLASS: {problem["class"]}

evaluation_criteria: <criteria_json>
audit_phase: {audit_phase}
authorization_scope: {authorization_scope}
halt_at: {halt_at}
pr_strategy: {pr_strategy}
pipeline_phase: {pipeline_phase}

worktree.path: {worktree.path}
github.owner: {github.owner}
github.repo: {github.repo}
"""
)
```

### Step 6: Write Audit Report

Append findings to `./tmp/artifacts/audit-guideline-<issue>.md`:

```markdown
# Guideline Audit Report - <YYYY-MM-DD>

## Summary

Files audited: <N>
Problems found: <M>
Consensus: PASS | FAIL

## Findings

### <file>

#### Problem: <class>

Rule: <rule_id>
Problem: <description>
Consensus: PASS | FAIL
Evidence: <tool-call reference>
Fix: <fix_action>

...
```

### Step 7: Build Result Contract

```json
{
  "status": "DONE",
  "audit_type": "guideline-audit",
  "files_audited": <N>,
  "problems_found": <M>,
  "problem_breakdown": {
    "AMBIGUOUS": <count>,
    "CONFLICTING": <count>,
    "UNENFORCEABLE": <count>,
    "REDUNDANT-CROSS-FILE": <count>,
    "MISSING": <count>,
    "CONTEXT-OVERFLOW": <count>
  },
  "cross_validation": [...],
  "overall_consensus": "PASS | FAIL",
  "report_path": "./tmp/artifacts/audit-guideline-<issue>.md",
  "exec_summary": "Guideline audit: {files} files, {problems} problems. Consensus: {overall}."
}
```

## Error Handling

| Error | Action |
|-------|--------|
| Target file not found | Return BLOCKED with file path |
| Unable to parse rule | Skip rule, log warning |
| Token limit exceeded | Report as CONTEXT-OVERFLOW |

## Cross-References

- `tasks/cross-validate.md` — dual auditor task()
- `guideline-auditor/tasks/audit.md` — original procedure
- `000-critical-rules.md` — guideline standards
- `065-verification-honesty.md` — live verification requirement

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-08T00:00:00Z"
rules:
  - id: guideline-audit-001
    title: "One problem at a time — no batching"
    conditions:
      all: ["multiple_problems_in_single_report == true"]
    actions: [SPLIT_INTO_SINGLE_PROBLEMS]
    source: "guideline-audit.md §Step 4"

  - id: guideline-audit-002
    title: "Each finding requires live verification"
    conditions:
      all: ["finding_reported == true", "tool_call_reference == null"]
    actions: [REJECT_FINDING]
    source: "guideline-audit.md §Step 5"

  - id: guideline-audit-003
    title: "Audit report must be timestamped"
    conditions:
      all: ["report_written == true", "timestamp_in_report == false"]
    actions: [ADD_TIMESTAMP]
    source: "guideline-audit.md §Step 6"
```