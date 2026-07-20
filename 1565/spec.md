## Intent

Verify all contract file references across `writing-plans` task files resolve to actual files. Initial audit shows 24 contract templates exist in `contracts/`, but cross-reference is needed to confirm no stale or incorrect paths remain.

## Problem

Task files reference contract YAML files at various paths:
- `tasks/create.md` references `contracts/create-output-template.yaml` (8 Z3 check steps)
- `tasks/write.md` references `contracts/write-output-template.yaml`
- `tasks/readiness.md` references `.issues/{issue-N}/sc-pipeline-readiness.yaml` (different path pattern)
- `tasks/solve.md` references `contracts/<task>-output-template.yaml` (dynamic path)

Need to verify every reference resolves correctly.

## Fix Approach

1. List all contract files in `contracts/` directory
2. Cross-reference each task file's YAML paths against actual files on disk
3. Flag any broken references for remediation

**Note:** Initial discovery shows 24 contract templates exist. This may be a verification-only spec rather than a fix spec if all references resolve correctly.

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | Every YAML path referenced in task files resolves to an existing file on disk | `structural` |
| SC-2 | No broken or stale contract references remain | `string` |
| SC-3 | Dynamic paths (e.g., `<task>-output-template.yaml`) resolve correctly for all 10 pipeline steps | `string` |

## Dependencies

- None — self-contained verification/fix spec
