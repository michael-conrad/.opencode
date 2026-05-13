# Task: spec-audit

## Purpose

Audit a spec for quality, structure, and completeness using dual-adversarial cross-validation. Each criterion is independently verified by two cross-family auditors with clean-room context.

## Entry Criteria

- Spec issue number provided OR spec content provided
- `github.owner`, `github.repo` available
- Audit phase context: `audit_phase: spec_creation`

## Exit Criteria

- All subtask criteria evaluated with PASS/FAIL consensus
- Bidirectional findings reported
- Executive summary generated

## Procedure

### Step 1: Load Spec Content

Fetch spec via GitHub MCP if issue number provided:
```bash
github_issue_read(method="get", owner=<owner>, repo=<repo>, issue_number=<N>)
```

Extract spec body and metadata.

### Step 2: Build Evaluation Criteria

Define audit criteria based on spec-auditor task structure:

| Criterion ID | Description | Expected Result |
|--------------|-------------|-----------------|
| SC-1 | Problem statement present | Non-empty problem statement section |
| SC-2 | Success criteria measurable | Each criterion has verification method |
| SC-3 | Phases well-structured | Clear phase boundaries |
| SC-4 | Steps actionable | Each step has file path or task |
| SC-5 | Dependencies identified | Phase dependencies documented |
| SC-6 | Concerns separated | Single concern per phase |
| SC-7 | Fidelity maintained | Plan matches spec |
| SC-8 | Operational clarity | Edge cases and error recovery defined |
| SC-9 | Determinism achieved | Repeatable execution path |
| SC-10 | Prose structure valid | Headers, lists, tables properly formatted |
| SC-11 | Documentation Sources present and populated | Non-empty Documentation Sources section with live-source verification evidence |

### Step 3: Dispatch Cross-Validate

Invoke `cross-validate` task:

```python
task(
    subagent_type="general",
    prompt="""Use adversarial-audit skill --task cross-validate with:

evidence_payload: <spec_body>
evaluation_criteria: <criteria_json>
audit_phase: spec_creation
authorization_scope: <authorization_scope>
halt_at: <halt_at>
pr_strategy: <pr_strategy>
pipeline_phase: <pipeline_phase>

worktree.path: <worktree.path>
github.owner: <github.owner>
github.repo: <github.repo>

Mandatory: dispatch two cross-family auditors, collect independent verdicts, cross-reference for consensus.
"""
)
```

### Step 4: Process Verdicts

For each criterion:
- Both auditors PASS → criterion consensus PASS
- Either auditor FAIL → criterion consensus FAIL
- Auditors disagree → mark as DISAGREE, present bidirectional finding

### Step 5: Generate Bidirectional Findings

For FAIL/DISAGREE criteria:

| Finding Type | Direction | Description |
|-------------|-----------|-------------|
| SPEC_INCOMPLETE | spec→code | Spec missing required element |
| SPEC_AMBIGUOUS | spec↔code | Spec open to interpretation |
| SPEC_OUTDATED | code→spec | Implementation diverged from spec |
| SPEC_OVERSPECIFIED | spec→code | Spec constrains implementation unnecessarily |

Present revision options for developer decision.

### Step 6: Build Result Contract

```json
{
  "status": "DONE",
  "audit_type": "spec-audit",
  "auditor_1": { "type": "auditor-<model>", "family": "<family>" },
  "auditor_2": { "type": "auditor-<model>", "family": "<family>" },
  "cross_validation": [
    {
      "criterion_id": "SC-1",
      "description": "Problem statement present",
      "auditor_1_result": "PASS",
      "auditor_2_result": "PASS",
      "consensus": "PASS",
      "evidence": "<tool-call reference>"
    }
  ],
  "overall_consensus": "PASS | FAIL",
  "disagreements": [],
  "bidirectional_findings": [],
  "exec_summary": "Spec audit: {pass_count}/{total} criteria passed. Consensus: {overall}."
}
```

## Error Handling

| Error | Action |
|-------|--------|
| Spec issue not found | Return BLOCKED with issue number |
| Spec body empty | Return FAIL for SC-1, continue remaining |
| Cross-validate fails | Return OVERFLOW, log error |
| Auditor unavailable | Use fallback chain per multimodal-dispatch |

## Cross-References

- `tasks/cross-validate.md` — dual auditor dispatch
- `tasks/resolve-models.md` — cross-family selection
- `spec-auditor/SKILL.md` — original task breakdown
- `spec-auditor/tasks/fidelity.md` — plan fidelity check
- `000-critical-rules.md` — co-authored requirement

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-08T00:00:00Z"
rules:
  - id: spec-audit-001
    title: "Dual auditors required — no single-auditor evaluation"
    conditions:
      all: ["auditor_count < 2"]
    actions: [HALT, RESOLVE_SECOND_AUDITOR]
    source: "spec-audit.md §Step 3"

  - id: spec-audit-002
    title: "Clean-room dispatch — no orchestrator reasoning leaked to auditors"
    conditions:
      all: ["auditor_context contains 'expected' OR 'should' OR 'correct'"]
    actions: [HALT, STRIP_BIASED_CONTEXT]
    source: "spec-audit.md §Step 3"

  - id: spec-audit-003
    title: "Disagreement requires bidirectional finding"
    conditions:
      all: ["auditor_1_result != auditor_2_result", "bidirectional_finding == null"]
    actions: [APPEND_BIDIRECTIONAL_FINDING]
    source: "spec-audit.md §Step 5"

  - id: spec-audit-004
    title: "Documentation Sources section required and populated"
    conditions:
      all: ["doc_sources_missing_or_empty == true"]
    actions: [FAIL_CRITERION(SC-11)]
    source: "spec-audit.md §Step 2"
```