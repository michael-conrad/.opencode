<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

> **⚠️ ROLE ANCHOR: You are the DISPATCHED AUDITOR SUB-AGENT.** Your role is to evaluate criteria and produce findings. You do NOT dispatch sub-agents, call `skill()`, or orchestrate pipeline routing. The orchestrator handles all dispatch. Read this file for evaluation criteria and procedure only — ignore any text describing orchestration responsibilities.

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
- Findings written to `./tmp/{issue-N}/artifacts/audit-guideline.md`

## Procedure

## Guideline Audit Checklist

- [ ] 1. Identify Target Files — specific files or full glob of guidelines/
- [ ] 2. Build Evaluation Criteria — define GA table with evidence types
- [ ] 3. Scan for Problem Classes — per-file ambiguous/conflicting/unenforceable/redundant/missing/overflow
- [ ] 4. One Problem At a Time — present single findings per interaction
- [ ] 5. Cross-Validate — cross-validate will be called by the orchestrator with pre-resolved verdicts
- [ ] 6. Write Audit Report — markdown report to artifacts directory
- [ ] 7. Write Verdict Artifact to Disk — YAML output
- [ ] 8. Return Frugal Result Contract

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

### Step 5: Cross-Validate

Cross-validate will be called by the orchestrator with pre-resolved auditor_artifact_paths after both auditors complete. Do NOT call cross-validate — your role is to produce your verdict artifact only.

### Step 6: Write Audit Report

Append findings to `./tmp/{issue-N}/artifacts/audit-guideline.md`:

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

### Step 7: Write Verdict Artifact to Disk

Write the full YAML verdict artifact to `./tmp/{issue-N}/artifacts/pipeline-audit-guideline-audit-{STATUS}-{timestamp}.yaml`:

```yaml
audit_phase: guideline_update
auditor_type: guideline-audit
family: <family>
issue_number: <N>
generated_at: "<timestamp>"
orchestrator_model: "<model>"
files_audited: N
problems_found: M
problem_breakdown:
  AMBIGUOUS: 0
  CONFLICTING: 0
  UNENFORCEABLE: 0
  REDUNDANT-CROSS-FILE: 0
  MISSING: 0
  CONTEXT-OVERFLOW: 0
per_criterion:
  - criterion_id: "GA-1"
    result: "PASS"
    evidence: "<tool-call reference>"
    explanation: "<reasoning>"
    remediation: ""
    next_step: "proceed"
report_path: "./tmp/{issue-N}/artifacts/audit-guideline.md"
exec_summary: "Guideline audit: N files, M problems. Consensus: PASS|FAIL."
```

### Step 8: Return Frugal Result Contract

```yaml
status: DONE
artifact_path: "./tmp/{issue-N}/artifacts/pipeline-audit-guideline-audit-PASS-{timestamp}.yaml"
summary: "N files audited, M problems found. X/Y criteria PASS."
```

## Error Handling

| Error | Action |
|-------|--------|
| Target file not found | Return BLOCKED with file path |
| Unable to parse rule | Skip rule, log warning |
| Token limit exceeded | Report as CONTEXT-OVERFLOW |

## Completion Dependency Chain

Every step in this task is a mandatory dependency. Skipping any step produces an INVALID result:
- Step 1 (Identify Target Files) → INVALID if skipped
- Step 2 (Build Evaluation Criteria) → INVALID if skipped
- Step 3 (Scan for Problem Classes) → INVALID if skipped
- Step 4 (One Problem At a Time) → INVALID if skipped
- Step 5 (Cross-Validate) → INVALID if skipped
- Step 6 (Write Audit Report) → INVALID if skipped
- Step 7 (Build Result Contract) → INVALID if skipped

## Next Pipeline Step (MANDATORY CONTINUATION)

After guideline-audit completes:
- If consensus PASS: proceed to next audit type or guideline_update pipeline
- If consensus FAIL: remediate findings, then re-audit (resolve-models → auditors → cross-validate)

This step is MANDATORY — the pipeline does not terminate early.

## Cross-References

- `tasks/cross-validate.md` — consensus computation with pre-resolved verdicts
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