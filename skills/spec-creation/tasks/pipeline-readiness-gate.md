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
- PR-5 (three-tier structure): PASS — multi-phase specs have three-tier phase structure (SC-31)
- Artifact `.issues/{issue-N}/sc-pipeline-readiness.yaml` written with status PASS/FAIL

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

- [ ] 1. Collect all SC-ID → `depends_on: [SC-IDs]` mappings
- [ ] 1. Verify every referenced SC-ID in `depends_on` is defined in the SC table
- [ ] 1. Generate a Z3 ordering contract at `.issues/{issue-N}/sc-dependency-contract.yaml`

   Contract schema (SC DAG ordering):

   ```yaml
   variables:
     SC-1_DONE: {type: bool, nullable: false}
     SC-2_DONE: {type: bool, nullable: false}
     ...
   invariants:
     # Each SC's truth implies all its dependencies are true
     - "z3.Implies(SC-2_DONE == True, SC-1_DONE == True)"
     - "z3.Implies(SC-3_DONE == True, z3.And(SC-1_DONE == True, SC-2_DONE == True))"
     # Theorem: all SCs can be satisfied without violating dependency order
     - "sc_dag_is_valid"
   ```

   The theorem `sc_dag_is_valid` is a Z3 assertion that the conjunction of all implication invariants is SAT (the dependency graph has no contradictions). If Z3 returns UNSAT, the dependency graph is invalid.

- [ ] 1. Run `solve prove --contract-path .issues/{issue-N}/sc-dependency-contract.yaml --theorem "sc_dag_is_valid"` to validate the DAG
- [ ] 1. If any cycle or missing dependency is found: PR-2 = FAIL

### Step 3: Validate Single Concern (PR-3)

For each SC, verify it targets exactly one file category and one verification domain:

- **File categories:** task file, SKILL.md, guideline, test, config, template
- **Verification domains:** behavioral, semantic, string, structural

An SC that spans multiple file categories or multiple verification domains is a single-concern violation.

### Step 4: Validate Phase Dependency Declarations (PR-4)

Extract the phase dependency graph:

- [ ] 1. Collect all phase → `depends_on: [phase-names]` mappings
- [ ] 1. Generate a Z3 ordering contract at `.issues/{issue-N}/dependency-ordering-verification/ordering.yaml`

   Contract schema (phase DAG ordering) — same structure as Step 2:

   ```yaml
   variables:
     PHASE-1_DONE: {type: bool, nullable: false}
     PHASE-2_DONE: {type: bool, nullable: false}
     ...
   invariants:
     - "z3.Implies(PHASE-2_DONE == True, PHASE-1_DONE == True)"
     - "z3.Implies(PHASE-3_DONE == True, PHASE-1_DONE == True)"
     # Theorem: all phases can be satisfied without violating ordering
     - "phase_dag_is_acyclic"
   ```

- [ ] 1. Run `solve prove --contract-path .issues/{issue-N}/dependency-ordering-verification/ordering.yaml --theorem "phase_dag_is_acyclic"` to validate
- [ ] 1. If any cycle is found: PR-4 = FAIL

### Step 4.5: Validate Three-Tier Phase Structure (PR-5 — SC-31)

For multi-phase specs (2+ phases), validate that the phase structure follows the three-tier pattern:

| Check | Pass Condition | Fail Condition |
|-------|---------------|----------------|
| PR-5a: Pre-phase exists | First phase is a global pre-phase (setup, pre-flight, coherence) | No pre-phase, or pre-phase contains per-file implementation steps |
| PR-5b: Per-file phases exist | Middle phases each target a specific file or concern | A phase targets multiple unrelated files, or a phase has no file/concern target |
| PR-5c: Post-phase exists | Last phase is a global post-phase (audit, cross-validate, review) | No post-phase, or post-phase contains per-file implementation steps |
| PR-5d: No step duplication | Global pre/post steps are NOT duplicated in per-file phases | Pre-flight, coherence, audit, or review steps appear in per-file phases |
| PR-5e: Phase count matches | Phase count = (number of per-file phases) + 2 | Phase count does not account for pre and post phases |

- [ ] 1. If the spec is single-task (1 phase): PR-5 = SKIP (three-tier not required)
- [ ] 1. If the spec is multi-phase: run all 5 checks
- [ ] 1. If any check fails: PR-5 = FAIL — the spec's phase structure must be revised before this gate passes

**Single-task exemption:** Specs with exactly one phase are exempt from PR-5. The three-tier structure is only required for multi-phase specs where the plan writer needs to organize per-file RED/GREEN cycles.

### Step 5: Write Artifact

Generate timestamp via `.opencode/tools/schema-version`. Store result in `$TIMESTAMP`.

Write `.issues/{issue-N}/sc-pipeline-readiness.yaml`:

```yaml
schema_version: "1.0"
generated_at: "$(./.opencode/tools/schema-version)"
status: PASS | FAIL
checks:
  - check_id: PR-1
    result: PASS | FAIL
    detail: "..."
  - check_id: PR-2
    result: PASS | FAIL
    solve_contract_path: ".issues/{issue-N}/sc-dependency-contract.yaml"
    prove_results:
      - theorem: "sc_dag_is_valid"
        result: VALID | INVALID
  - check_id: PR-3
    result: PASS | FAIL
    detail: "..."
  - check_id: PR-4
    result: PASS | FAIL
    solve_contract_path: ".issues/{issue-N}/dependency-ordering-verification/ordering.yaml"
    prove_results:
      - theorem: "phase_dag_is_acyclic"
        result: VALID | INVALID
  - check_id: PR-5
    result: PASS | FAIL | SKIP
    detail: "..."
    sub_checks:
      - check_id: PR-5a
        result: PASS | FAIL
      - check_id: PR-5b
        result: PASS | FAIL
      - check_id: PR-5c
        result: PASS | FAIL
      - check_id: PR-5d
        result: PASS | FAIL
      - check_id: PR-5e
        result: PASS | FAIL
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
