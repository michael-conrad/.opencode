# Task: post-green-enforcement

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

## Purpose

Structural gate that verifies GREEN-phase sub-agents did not modify test files. Runs after green-phase, before checkpoint-commit. Exits FAIL if any `test/` files were touched during GREEN-phase.

## Entry Criteria

- green-phase step completed with PASS status
- GREEN-phase sub-agent returned DONE

## Exit Criteria

- Git diff structural gate result written to `./tmp/{issue-N}/artifacts/pipeline-post-green-enforcement-{STATUS}-{timestamp}.yaml`
- Gate PASS: no `test/` files modified during GREEN-phase
- Gate FAIL: `test/` files were modified — orchestrator re-dispatches GREEN-phase from clean-room state

## Procedure

- [ ] 1. Run `git diff --name-only -- test/ | wc -l` to count modified test files
- [ ] 2. If count > 0: write FAIL artifact with list of modified files, return BLOCKED
- [ ] 3. If count == 0: write PASS artifact, return DONE

## Artifact Format

```yaml
step_label: post-green-enforcement
issue_number: {issue-N}
generated_at: "{timestamp}"
status: PASS | FAIL
summary:
  total_criteria: 1
  pass: <0|1>
  fail: <0|1>
per_criterion:
  - criterion_id: GREEN-TEST-GATE
    result: PASS | FAIL
    evidence: |-
      git diff --name-only -- test/ | wc -l
      Modified test files: <list or "none">
    next_step: proceed | re-evaluate
```

## Context Required

- Preceded by: green-phase (implementation-pipeline step 7)
- Feeds into: checkpoint-commit (implementation-pipeline step 9)
- Related: `skills/test-driven-development/tasks/green.md` — GREEN persona enforcement

## Related Files

- `skills/implementation-pipeline/SKILL.md` — dispatch routing table
- `skills/implementation-pipeline/tasks/pipeline-executor.md` — pipeline step definitions
- `skills/test-driven-development/tasks/green.md` — GREEN persona enforcement block
