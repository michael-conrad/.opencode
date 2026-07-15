# Column Validation Rules (Pre-Approval Gate Expansion)

## Entry Criteria

- Spec SC table is available for validation
- Authorization scope is known (`for_spec`, `for_implementation`, etc.)

## Procedure

The pre-approval gate validates the following columns in the spec's SC table. Each rule produces PASS or BLOCK with reason.

| Column | Validation Rule | Block On | Apply To |
|--------|----------------|----------|----------|
| Pipeline Step Binding | Every SC MUST have a valid pipeline step binding matching a step in `implementation-pipeline` dispatch table | Missing, invalid, or misspelled step name | All specs |
| Re-Entry Step | Every SC MUST declare a re-entry step. For single-task specs, may be `null`. For multi-phase, MUST reference a valid step within the bound phase | Missing for multi-phase, or references step outside phase scope | All specs |
| Verification Gate | Every SC's Verification Gate MUST be consistent with its Evidence Type per the Evidence Type Taxonomy: `behavioral` → pre-commit, `semantic` → pre-PR, `string` → CI, `structural` → none | EVIDENCE_TYPE_MISMATCH — behavioral SC with CI gate, etc. | All specs |
| Artifact Path | Every SC with a non-structural evidence type MUST declare an artifact path. Structural SCs MAY omit | Missing when evidence type is behavioral/semantic/string | All specs |
| Phase Binding | Every SC MUST declare a phase binding matching a phase in the spec's Phase section. Cross-cutting SCs use `common` | Phase name not found in spec phases, or `common` used for non-cross-cutting SC | Multi-phase specs only |

### Pre-Approval Gate Column Validation

When running the pre-approval gate for standard/complex specs, validate the following columns in the SC table:

| Column | Validation Rule | Error on Violation |
|--------|----------------|---------------------|
| Pipeline Step Binding | MUST specify which pipeline step validates this SC | BLOCK |
| Re-Entry Step | MUST specify re-entry point on verification failure | BLOCK |
| Verification Gate | MUST be one of: red-green, pre-commit, ci | BLOCK |
| Artifact Path | MUST use `{project_root}/tmp/{issue-N}/` convention | BLOCK |
| Phase Binding | MUST annotate phase for multi-phase specs | FLAG |

For `for_spec` scope, only minimal-tier requirements enforced (Pipeline Step Binding, Re-Entry Step).

## Exit Criteria

- All applicable columns validated
- PASS or BLOCK reported per column
- BLOCK reasons documented for remediation
