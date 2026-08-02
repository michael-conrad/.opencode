---
name: route
description: "Scope-aware auto-route to the next skill based on authorization scope and halt_at boundary."
provenance: AI-generated
---

# Task: route

## Purpose

Determine the next pipeline step based on the resolved authorization scope and halt_at boundary. Routes to the appropriate downstream skill (writing-plans, test-driven-development, git-workflow-pr, etc.).

## Entry Criteria

- Authorization scope is resolved (from resolve-scope task)
- halt_at boundary is known
- Pipeline phase is known

## Steps

1. Read the resolved scope and halt_at from the resolve-scope artifact
2. Determine the next skill based on the scope:
   - `for_spec` → route to `spec-creation`
   - `for_plan` → route to `writing-plans`
   - `for_implementation` → route to `test-driven-development`
   - `for_pr` → route to `writing-plans` (if no plan) or `test-driven-development` (if plan exists)
   - `for_review_prep` → route to `finishing-a-development-branch`
   - `for_analysis` → route to `research`
3. Check halt_at boundary — if pipeline_phase >= halt_at, return HALT
4. Write result contract to `{project_root}/tmp/{issue-N}/route.yaml`

## Exit Criteria

- Next skill identified and returned in result contract
- If halt_at boundary reached: return DONE with `HALT_AT_BOUNDARY`

## Result Contract

```yaml
status: DONE | BLOCKED
finding_summary: "Route to {next_skill} (scope: {scope}, halt_at: {halt_at})"
artifact_path: "{project_root}/tmp/{issue-N}/route.yaml"
blocker_reason: null | "HALT_AT_BOUNDARY: pipeline_phase {phase} >= halt_at {halt_at}"
```
