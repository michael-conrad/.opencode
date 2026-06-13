# Task: pre-flight-handoff

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

## Purpose

Verify plan structural completeness before pipeline execution begins. Runs as a pre-flight step of `implementation-pipeline/SKILL.md` before sc-coherence-gate. Produces a machine-parseable manifest documenting PASS or BLOCKED status.

## Entry Criteria

- Plan exists at `.issues/{issue-N}/spec-artifacts/plan.md`
- Spec-to-plan handoff manifest exists at `./tmp/{issue-N}/artifacts/spec-to-plan-handoff-*.yaml` with status PASS
- `sc-summary.yaml` exists at `.issues/{issue-N}/spec-artifacts/sc-summary.yaml`
- Authorization context available (authorization_scope, halt_at)

## Exit Criteria

- Handoff manifest written at `./tmp/{issue-N}/artifacts/plan-to-pipeline-handoff-*.yaml`
- Manifest contains `status: PASS` or `status: BLOCKED` with `blocked_reason`
- All validation checks completed

## Procedure

### Step 1: Validate RED Checkpoints

1. Read `.issues/{issue-N}/spec-artifacts/plan.md`
2. For each TDD task in the plan, verify it has a RED checkpoint with explicit failure condition
3. Search for patterns: `red_checkpoint`, `failure_condition`, `MISSING-CHECKPOINT`
4. Flag any TDD task missing a RED checkpoint as `MISSING-CHECKPOINT`

### Step 2: Validate SC-ID Traceability

1. Read `.issues/{issue-N}/spec-artifacts/sc-summary.yaml`
2. Read `.issues/{issue-N}/spec-artifacts/plan.md`
3. Extract all SC-IDs referenced in the plan — collect as `sc_ids_in_plan`
4. Extract all SC-IDs from `sc-summary.yaml` — collect as `sc_ids_in_summary`
5. Compare `sc_ids_in_plan` against `sc_ids_in_summary`
6. Flag SC-IDs in plan but not in summary as `SCOPE-CREEP`
7. Flag SC-IDs in summary but not in plan as `MISSING-TRACEABILITY`

### Step 3: Validate Approval Cascade

1. Read the authorization context (authorization_scope, halt_at)
2. Read the plan's approval cascade section
3. Verify the plan's approval state matches the authorization scope
4. Flag mismatch as `APPROVAL-MISMATCH`

### Step 4: Validate Verification Gate Preservation

1. Read the spec's SC table for Verification Gate column
2. Read the plan's TDD steps for verification gate references
3. Verify every SC's Verification Gate from the spec is preserved in the plan's TDD structure
4. Flag deviations as `GATE-DEVIATION`

### Step 5: Handoff Consistency Check

1. Read the latest spec-to-plan handoff manifest from `./tmp/{issue-N}/artifacts/spec-to-plan-handoff-*.yaml`
2. Read the plan-to-pipeline handoff checks from Steps 1-4
3. Compare shared variables:
   - `sc_coverage_total` from spec-to-plan manifest vs SC count in plan
   - `decomposition_classification` from spec-to-plan vs plan structure
   - `phase_count` from spec-to-plan vs plan phases
4. Flag any mismatch as `HANDOFF-INCONSISTENCY` with BLOCKED status

### Step 6: Write Handoff Manifest

Generate timestamp via `.opencode/tools/schema-version`. Store result in `$TIMESTAMP`.

Write `./tmp/{issue-N}/artifacts/plan-to-pipeline-handoff-$TIMESTAMP.yaml`:

```yaml
schema_version: "1.0"
generated_at: "$TIMESTAMP"
status: PASS | BLOCKED
blocked_reason: "<reason if BLOCKED, else null>"
checks:
  - check_id: RED_CHECKPOINTS
    result: PASS | FAIL
    detail: "..."
  - check_id: SC_ID_TRACEABILITY
    result: PASS | FAIL
    detail: "..."
  - check_id: APPROVAL_CASCADE
    result: PASS | FAIL
    detail: "..."
  - check_id: VERIFICATION_GATE_PRESERVATION
    result: PASS | FAIL
    detail: "..."
  - check_id: HANDOFF_CONSISTENCY
    result: PASS | FAIL
    detail: "..."
sc_summary:
  total_scs: <count>
  scs_in_plan: <count>
  scs_in_summary: <count>
  missing_traceability: <list>
  scope_creep: <list>
```

## Context Required

- Preceded by: spec-to-plan handoff (writing-plans entry criterion)
- Feeds into: `implementation-pipeline/SKILL.md` pre-flight step
- Related artifacts: `.issues/{issue-N}/spec-artifacts/sc-summary.yaml`, `./tmp/{issue-N}/artifacts/spec-to-plan-handoff-*.yaml`
