# Task: handoffs/spec-to-plan

## Purpose

Verify spec structural completeness before plan creation begins. Runs as an entry criterion of `writing-plans/tasks/create.md`. Produces a machine-parseable manifest documenting PASS or BLOCKED status.

## Entry Criteria

- Spec is approved (verified by approval-gate)
- `.issues/{issue-N}/spec.md` exists
- `.issues/{issue-N}/spec-artifacts/` directory exists
- `.issues/{issue-N}/spec-artifacts/sc-summary.yaml` exists and is valid YAML

## Exit Criteria

- Handoff manifest written at `./tmp/{issue-N}/artifacts/spec-to-plan-handoff-*.yaml`
- Manifest contains `status: PASS` or `status: BLOCKED` with `blocked_reason`
- All preconditions validated

## Procedure

### Step 1: Validate Preconditions

1. Verify spec is approved — check for `approved-for-*` label on the issue or authorization context from approval-gate
2. Verify `.issues/{issue-N}/spec-artifacts/` directory exists
3. Read and parse `.issues/{issue-N}/spec-artifacts/sc-summary.yaml`
4. If any precondition fails: write BLOCKED manifest and return

### Step 2: Enumerate Expected Artifacts

1. Read `.issues/{issue-N}/spec-artifacts/sc-summary.yaml`
2. Extract `sc_coverage.total`, `sc_coverage.evidence_types`, `sc_coverage.phases`
3. Verify `sc-summary.yaml` contains all required fields: `sc_coverage.total`, `sc_coverage.phases[].sc_ids`
4. Flag missing or malformed fields

### Step 3: Validate SC Summary YAML

1. Parse `sc-summary.yaml` as valid YAML
2. Verify `sc_coverage.total` matches the count of SC-IDs across all phases
3. Verify every SC-ID in `sc_coverage.phases[].sc_ids` is unique (no duplicates)
4. Report parse errors or structural issues

### Step 4: Validate Risk Traceability Cross-References

1. Read the spec's Risk Traceability table
2. For each RISK-ID with a Verifying SC, verify the SC-ID exists in `sc-summary.yaml`
3. Flag orphan RISK references (Verifying SC not in sc-summary)

### Step 5: Validate Decision Ledger Contradictions

1. Read the spec's Decision Ledger
2. Check for detected contradictions (from spec-auditor findings)
3. If contradictions detected: write BLOCKED manifest with `DECISION_CONTRADICTION`

### Step 6: Validate Decomposition Consistency

1. Read the spec's decomposition classification (single-task or multi-phase)
2. Read `sc-summary.yaml` phase bindings
3. For single-task: verify all SCs are in one phase or `cross_cutting: null`
4. For multi-phase: verify SCs are distributed across phases with no orphan SCs
5. Flag inconsistency between decomposition classification and SC-to-phase bindings

### Step 7: Write Handoff Manifest

Generate timestamp via `.opencode/tools/schema-version`. Store result in `$TIMESTAMP`.

Write `./tmp/{issue-N}/artifacts/spec-to-plan-handoff-$TIMESTAMP.yaml`:

```yaml
schema_version: "1.0"
generated_at: "$TIMESTAMP"
status: PASS | BLOCKED
blocked_reason: "<reason if BLOCKED, else null>"
checks:
  - check_id: PRECONDITIONS
    result: PASS | FAIL
    detail: "..."
  - check_id: ARTIFACT_ENUMERATION
    result: PASS | FAIL
    detail: "..."
  - check_id: YAML_VALIDATION
    result: PASS | FAIL
    detail: "..."
  - check_id: RISK_CROSS_REFS
    result: PASS | FAIL
    detail: "..."
  - check_id: DECISION_CONTRADICTIONS
    result: PASS | FAIL
    detail: "..."
  - check_id: DECOMPOSITION_CONSISTENCY
    result: PASS | FAIL
    detail: "..."
sc_summary:
  total_scs: <from sc-summary.yaml>
  phases: <from sc-summary.yaml>
```

## Context Required

- Preceded by: spec approval (approval-gate)
- Feeds into: `writing-plans/tasks/create.md` entry criteria
- Related artifacts: `.issues/{issue-N}/spec-artifacts/sc-summary.yaml`
