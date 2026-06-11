<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->

<!-- SPDX-License-Identifier: MIT -->

<!-- Provenance: AI-generated -->

# Task: pipeline-readiness-gate

## Purpose

Validate that spec success criteria are structurally fit for the implementation pipeline. Each SC must be atomic, dependency-ordered, single-concern, and the phase DAG must be acyclic. This gate runs after traceability and before risk analysis.

## Entry Criteria

- Spec success criteria table populated with IDs, evidence types, and dependency declarations
- At least one SC defined
- Phase table populated with dependency declarations

## Exit Criteria

- PR-1 (atomicity): PASS — every SC maps to one RED→GREEN→COMMIT cycle
- PR-2 (dependency ordering): PASS — `solve prove` confirms SC dependency DAG is valid
- PR-3 (single concern): PASS — every SC targets one file category and one verification domain
- PR-4 (phase dependency): PASS — `solve prove` confirms phase dependency graph is acyclic
- Artifact `.issues/{issue-N}/spec-artifacts/sc-pipeline-readiness.yaml` written with status PASS/FAIL

## Procedure

### Step 1: Validate SC Atomicity (PR-1)

For each SC, verify it maps to exactly one RED→GREEN→COMMIT cycle:

| Pass Condition                                        | Fail Condition                                                                      |
| ----------------------------------------------------- | ----------------------------------------------------------------------------------- |
| SC asserts exactly one independently testable claim   | SC bundles multiple assertions (e.g., "X is correct AND Y is correct AND Z passes") |
| PASS/FAIL of the SC cannot be split across two claims | SC references multiple files or verification domains in the same criterion          |

Record each SC as `atomic: true | false`.

### Step 2: Validate SC Dependency Ordering (PR-2)

Extract the SC dependency graph from `depends_on` fields:

1. Collect all SC-ID → `depends_on: [SC-IDs]` mappings
1. Verify every referenced SC-ID in `depends_on` is defined in the SC table
1. Generate a Z3 ordering contract at `.issues/{N}/spec-artifacts/sc-dependency-contract.yaml`
1. Run `solve prove --contract-path ... --ordering-assertion` to validate the DAG
1. If any cycle or missing dependency is found: PR-2 = FAIL

### Step 3: Validate Single Concern (PR-3)

For each SC, verify it targets exactly one file category and one verification domain:

- **File categories:** task file, SKILL.md, guideline, test, config, template
- **Verification domains:** behavioral, semantic, string, structural

An SC that spans multiple file categories or multiple verification domains is a single-concern violation.

### Step 4: Validate Phase Dependency Declarations (PR-4)

Extract the phase dependency graph:

1. Collect all phase → `depends_on: [phase-names]` mappings
1. Generate a Z3 ordering contract at `.issues/{N}/spec-artifacts/dependency-ordering-verification/ordering.yaml`
1. Run `solve prove --contract-path ... --theorem "phase_dag_is_acyclic"` to validate
1. If any cycle is found: PR-4 = FAIL

### Step 5: Write Artifact

Write `.issues/{issue-N}/spec-artifacts/sc-pipeline-readiness.yaml`:

```yaml
schema_version: "1.0"
generated_at: "<timestamp>"
status: PASS | FAIL
checks:
  - check_id: PR-1
    result: PASS | FAIL
    detail: "..."
  - check_id: PR-2
    result: PASS | FAIL
    solve_contract_path: ".issues/{N}/spec-artifacts/sc-dependency-contract.yaml"
    prove_results:
      - theorem: "sc_dag_is_valid"
        result: VALID | INVALID
  - check_id: PR-3
    result: PASS | FAIL
    detail: "..."
  - check_id: PR-4
    result: PASS | FAIL
    solve_contract_path: ".issues/{N}/spec-artifacts/dependency-ordering-verification/ordering.yaml"
    prove_results:
      - theorem: "phase_dag_is_acyclic"
        result: VALID | INVALID
sc_summary:
  total_scs: <count>
  atomic: <count>
  with_dependencies: <count>
  single_concern: <count>
```

On FAIL for any check, the spec must be revised before this gate passes. The gate is re-runnable.

## Context Required

- Preceded by: `traceability`
- Feeds into: `risk`
- Note: This is a gate, not an analysis phase. FAIL halts spec progression until the spec is revised.

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
