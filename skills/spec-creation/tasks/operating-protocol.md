# Spec Creation Pipeline

## Entry Criteria

- Brainstorming exploration complete
- Spec creation requested
- Issue number and spec context available

## Procedure

- [ ] 1. [inline] Pre-spec inspection per `015-pre-spec-inspection.md` — chain: `none`
- [ ] 2. [sub-task: requirements] `task(..., prompt: "execute requirements task from spec-creation")` — input: `{project_root}/tmp/{N}/contracts/requirements-input.yaml`, output: `{project_root}/tmp/{N}/contracts/requirements-output.yaml`, template: `.opencode/skills/spec-creation/contracts/requirements-input-template.yaml`, chain: `none`
- [ ] 3. [sub-task: decompose] `task(..., prompt: "execute decompose task from spec-creation")` — input: `{project_root}/tmp/{N}/contracts/decompose-input.yaml`, output: `{project_root}/tmp/{N}/contracts/decompose-output.yaml`, template: `.opencode/skills/spec-creation/contracts/requirements-input-template.yaml` (shared), chain: `step_2`
- [ ] 4. [sub-task: traceability] `task(..., prompt: "execute traceability task from spec-creation")` — input: `{project_root}/tmp/{N}/contracts/traceability-input.yaml`, output: `{project_root}/tmp/{N}/contracts/traceability-output.yaml`, template: `.opencode/skills/spec-creation/contracts/requirements-input-template.yaml` (shared), chain: `step_3`
- [ ] 4.5. [sub-task: pipeline-readiness-gate] `task(..., prompt: "execute pipeline-readiness-gate task from spec-creation")` — input: `{project_root}/tmp/{N}/contracts/pipeline-readiness-input.yaml`, output: `{project_root}/tmp/{N}/contracts/pipeline-readiness-output.yaml`, template: `.opencode/skills/spec-creation/contracts/requirements-input-template.yaml` (shared), chain: `step_4`
- [ ] 6. [sub-task: risk] `task(..., prompt: "execute risk task from spec-creation")` — input: `{project_root}/tmp/{N}/contracts/risk-input.yaml`, output: `{project_root}/tmp/{N}/contracts/risk-output.yaml`, template: `.opencode/skills/spec-creation/contracts/requirements-input-template.yaml` (shared), chain: `step_4.5`
- [ ] 7. [inline] Invoke `solve model` for dependency-ordering constraints contract — chain: `step_6`
- [ ] 8. [inline] Invoke `solve check` to verify SAT — chain: `step_7`
- [ ] 9. [inline] Invoke `plan plan` for phase solvability validation — chain: `step_8`
- [ ] 10. [sub-task: create] `task(..., prompt: "execute create task from spec-creation")` — input: `{project_root}/tmp/{N}/contracts/write-input.yaml`, output: `{project_root}/tmp/{N}/contracts/write-output.yaml`, template: `.opencode/skills/spec-creation/contracts/write-input-template.yaml`, chain: `step_6, step_9`
- [ ] 11. [sub-task: completion] `task(..., prompt: "execute completion task from spec-creation")` — input: `{project_root}/tmp/{N}/contracts/completion-input.yaml`, output: `{project_root}/tmp/{N}/contracts/completion-output.yaml`, template: `.opencode/skills/spec-creation/contracts/write-output-template.yaml` (shared), chain: `step_10`
- [ ] 12. [sub-task: spec-audit] `task(..., prompt: "execute spec-audit task from audit")` — chain: `step_10`
- [ ] 13. **Correctness over speed.** Every code path with runtime behavior requires live-wire testing against real systems. A slow correct answer is strictly better than a fast incorrect one. Static analysis alone is NOT acceptable verification — behavioral compliance requires actual execution with cross-validated PASS verdict.

## Exit Criteria

- Spec created as GitHub Issue
- Spec-audit completed
- Ready for approval-gate
