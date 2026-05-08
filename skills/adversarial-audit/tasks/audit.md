# Task: audit

## Purpose

Unified orchestrator for adversarial-audit. Dispatches to specific audit task types based on `--type` parameter. All audit types follow the cleanroom dispatch pattern: Scan → Evidence → Dual Verifier → Consensus.

## Entry Criteria

- One or more `--type` parameters specified (comma-separated for multi-type)
- Audit context provided: spec issue, plan issue, or other target
- `github.owner`, `github.repo` available

## Exit Criteria

- Audit result for each type returned
- All criteria evaluated with PASS/FAIL consensus
- Bidirectional findings reported

## Procedure

### Step 1: Parse Type Parameter

Parse `--type` parameter:
- Single type: `--type spec-audit` → dispatch to spec-audit task
- Multi-type: `--type spec-audit,plan-fidelity` → dispatch to both in sequence
- Unknown type: return error with valid types list

Valid types:
- `spec-audit` — full spec audit
- `plan-fidelity` — clean-room plan comparison
- `concern-separation` — phase structure analysis
- `coherence` — guideline/skill coherence
- `guideline-audit` — guideline quality check
- `drift-detection` — spec/code reality sync
- `spec-summary` — PR/spec consistency
- `closure-verification` — merge evidence verification

### Step 2: Dispatch to Type-Specific Task

For each type in sequence:

```python
task(
    subagent_type="general",
    prompt=f"""Use adversarial-audit skill --task {type} with context:

audit_type: {type}
audit_phase: {audit_phase}
{context_from_caller}

worktree.path: {worktree.path}
github.owner: {github.owner}
github.repo: {github.repo}

Mandatory gates before returning:
1. Scan target via live tool calls
2. Collect evidence via live tool calls
3. Dispatch dual cross-family auditors
4. Collect verdicts and consensus
5. Return structured result contract

Result contract must include:
- status: DONE | BLOCKED | OVERFLOW
- findings: [{{criterion_id, result, evidence, explanation}}]
- consensus: PASS | FAIL | DISAGREE
- disagreements: [] or list when auditors diverge
"""
)
```

### Step 3: Aggregate Multi-Type Results

For multi-type invocations, aggregate results:

```json
{
  "status": "DONE",
  "types_audited": ["spec-audit", "plan-fidelity"],
  "type_results": {
    "spec-audit": { "consensus": "PASS", "findings": [...] },
    "plan-fidelity": { "consensus": "FAIL", "findings": [...] }
  },
  "overall_consensus": "FAIL",
  "disagreements": [...]
}
```

Multiple types require ALL to PASS for overall PASS.

### Step 4: Handle Bidirectional Findings

When consensus is FAIL or DISAGREE:

```json
{
  "bidirectional_findings": {
    "finding_direction": "spec_drift",
    "current_state": "Implementation diverged from spec",
    "spec_state": "Spec describes X, code implements Y",
    "revision_options": [
      {"label": "Update spec to match code", "description": "..."},
      {"label": "Revert code to match spec", "description": "..."},
      {"label": "Brainstorm alternative", "description": "..."}
    ]
  }
}
```

Present revision options to developer for decision.

### Step 5: Build Result Contract

Return structured result matching Sub-agent Result Contract:

```json
{
  "status": "DONE | DONE_WITH_CONCERNS | OVERFLOW | BLOCKED",
  "files_changed": [],
  "summary": "Adversarial audit completed for {types}. Consensus: {overall_consensus}",
  "verification_passed": "<overall_consensus == 'PASS'>",
  "compare_url": "",
  "exec_summary": "Audit of {types} yielded {overall_consensus}. {findings_count} findings."
}
```

## Type-to-Task Mapping

| Type | Task File | Audit Phase |
|------|-----------|--------------|
| spec-audit | tasks/spec-audit.md | spec_creation |
| plan-fidelity | tasks/plan-fidelity.md | plan_creation |
| concern-separation | tasks/concern-separation.md | sub_issue_creation |
| coherence | tasks/coherence-maintenance.md | coherence_gate |
| guideline-audit | tasks/guideline-audit.md | guideline_update |
| drift-detection | tasks/drift-detection.md | implementation_verification |
| spec-summary | tasks/spec-summary.md | pr_creation |
| closure-verification | tasks/closure-verification.md | post_merge |

## Error Handling

| Error | Action |
|-------|--------|
| Unknown type | Return valid types list |
| Missing context | Return BLOCKED with missing field |
| Type task fails | Log error, continue to next type |
| All types fail | Return BLOCKED with failure summary |

## Cross-References

- `adversarial-audit/SKILL.md` — skill-level operating protocol
- `tasks/cross-validate.md` — dual auditor dispatch protocol
- `tasks/resolve-models.md` — cross-family auditor selection
- `080-code-standards.md` — co-authored requirement

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-05-08T00:00:00Z"
rules:
  - id: audit-001
    title: "Type parameter required — no default audit type"
    conditions:
      all: ["audit_type == null"]
    actions: [RETURN_ERROR, LIST_VALID_TYPES]
    source: "audit.md §Step 1"

  - id: audit-002
    title: "Multi-type requires ALL to PASS for overall PASS"
    conditions:
      all: ["any_type_consensus == 'FAIL'", "overall_consensus_reported_as == 'PASS'"]
    actions: [REJECT, SET_OVERALL_FAIL]
    source: "audit.md §Step 3"

  - id: audit-003
    title: "Bidirectional findings require revision options"
    conditions:
      all: ["consensus == 'FAIL' OR consensus == 'DISAGREE'", "revision_options == null"]
    actions: [APPEND_DEFAULT_OPTIONS]
    source: "audit.md §Step 4"
```