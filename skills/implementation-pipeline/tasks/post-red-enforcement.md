# Task: post-red-enforcement

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

## Purpose

Structural gate that verifies RED-phase sub-agents did not modify implementation files. Runs after red-doublecheck, before green-phase. Exits FAIL if any `src/` files were touched during RED-phase.

## Entry Criteria

- red-doublecheck step completed with PASS status
- RED-phase sub-agent returned DONE

## Exit Criteria

- Git diff structural gate result written to `{project_root}/tmp/{issue-N}/artifacts/pipeline-post-red-enforcement-{STATUS}-{timestamp}.yaml`
- Gate PASS: no `src/` files modified during RED-phase
- Gate FAIL: `src/` files were modified — orchestrator re-dispatches RED-phase from clean-room state

## Procedure

- [ ] 1. Run `git diff --name-only -- src/ | wc -l` to count modified implementation files
- [ ] 2. If count > 0: write FAIL artifact with list of modified files, return BLOCKED
- [ ] 3. If count == 0: write PASS artifact, return DONE

## Artifact Format

```yaml
step_label: post-red-enforcement
issue_number: {issue-N}
generated_at: "{timestamp}"
status: PASS | FAIL
summary:
  total_criteria: 1
  pass: <0|1>
  fail: <0|1>
per_criterion:
  - criterion_id: RED-SRC-GATE
    result: PASS | FAIL
    evidence: |-
      git diff --name-only -- src/ | wc -l
      Modified src/ files: <list or "none">
    next_step: proceed | re-evaluate
```

## Context Required

- Preceded by: red-doublecheck (implementation-pipeline step 4)
- Feeds into: green-phase (implementation-pipeline step 6)
- Related: `skills/test-driven-development/tasks/red.md` — RED persona enforcement

## Related Files

- `skills/implementation-pipeline/SKILL.md` — dispatch routing table
- `skills/implementation-pipeline/tasks/pipeline-executor.md` — pipeline step definitions
- `skills/test-driven-development/tasks/red.md` — RED persona enforcement block
