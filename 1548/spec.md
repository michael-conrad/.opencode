## Intent

Fix references to non-existent contract/template YAML files across `writing-plans` skill task files.

## Problem

Multiple task files reference contract and output-template YAML files that do not exist in the skill's directory structure:

| File | References | Missing file(s) |
|------|-----------|-----------------|
| `tasks/readiness.md:20` | `sc-pipeline-readiness.yaml` | `.opencode/skills/writing-plans/contracts/sc-pipeline-readiveness.yaml` (does not exist) |
| `tasks/write.md:18,47` | `contracts/write-output-template.yaml` | `.opencode/skills/writing-plans/contracts/write-output-template.yaml` (does not exist) |
| `tasks/create.md:125,109` | `contracts/create-output-template.yaml` | Referenced but file location unclear — may exist at root or be missing |

**Affected files:** `.opencode/skills/writing-plans/tasks/readiness.md`, `.opencode/skills/writing-plans/tasks/write.md`, `.opencode/skills/writing-plans/tasks/create.md`

## Fix Approach

1. Verify which contract files actually exist in the skill's `contracts/` directory
2. For each missing reference: either (a) create the referenced file, or (b) update the task to reference a real file
3. If creating new contracts: follow existing contract patterns (YAML with `status`, `artifact_path`, `blocker_reason`)

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | Every contract file referenced in task files exists on disk | `structural` |
| SC-2 | No task references a non-existent YAML path | `string` |
| SC-3 | Each existing contract has valid schema (status, artifact_path fields) | `string` |

## Dependencies

- None — self-contained fix
