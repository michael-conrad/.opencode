# Spec Creation Pipeline

## Entry Criteria

- Brainstorming exploration complete
- Spec creation requested
- Issue number and spec context available

## Procedure

- [ ] 1. [inline] Pre-spec inspection per `015-pre-spec-inspection.md` — chain: `none`
- [ ] 2. [sub-task: research-card-consultation] `task(..., prompt: "execute research-card-consultation task from spec-creation")` — Before requirements extraction, consult `.opencode/.issues/research-cards/` for existing findings on the spec topic. If a matching card exists with `confidence >= 0.7`, incorporate its findings. If no matching card, proceed without. Chain: `step_1`
- [ ] 3. [sub-task: requirements] `task(..., prompt: "execute requirements task from spec-creation")` — input: `{project_root}/tmp/{N}/contracts/requirements-input.yaml`, output: `{project_root}/tmp/{N}/contracts/requirements-output.yaml`, template: `.opencode/skills/spec-creation/contracts/requirements-input-template.yaml`, chain: `none`
- [ ] 4. [sub-task: concern-analysis] `task(..., prompt: "execute concern-analysis task from spec-creation")` — input: `{project_root}/tmp/{N}/contracts/concern-analysis-input.yaml`, output: `{project_root}/tmp/{N}/contracts/concern-analysis-output.yaml`, template: `.opencode/skills/spec-creation/contracts/requirements-input-template.yaml` (shared), chain: `step_3`
- [ ] 5. [sub-task: decompose] `task(..., prompt: "execute decompose task from spec-creation")` — input: `{project_root}/tmp/{N}/contracts/decompose-input.yaml`, output: `{project_root}/tmp/{N}/contracts/decompose-output.yaml`, template: `.opencode/skills/spec-creation/contracts/requirements-input-template.yaml` (shared), chain: `step_4`
- [ ] 6. [sub-task: blast-radius] `task(..., prompt: "execute blast-radius task from spec-creation")` — input: `{project_root}/tmp/{N}/contracts/blast-radius-input.yaml`, output: `{project_root}/tmp/{N}/contracts/blast-radius-output.yaml`, template: `.opencode/skills/spec-creation/contracts/requirements-input-template.yaml` (shared), chain: `step_5`
- [ ] 7. [sub-task: cross-cutting] `task(..., prompt: "execute cross-cutting task from spec-creation")` — input: `{project_root}/tmp/{N}/contracts/cross-cutting-input.yaml`, output: `{project_root}/tmp/{N}/contracts/cross-cutting-output.yaml`, template: `.opencode/skills/spec-creation/contracts/requirements-input-template.yaml` (shared), chain: `step_5`
- [ ] 8. [sub-task: traceability] `task(..., prompt: "execute traceability task from spec-creation")` — input: `{project_root}/tmp/{N}/contracts/traceability-input.yaml`, output: `{project_root}/tmp/{N}/contracts/traceability-output.yaml`, template: `.opencode/skills/spec-creation/contracts/requirements-input-template.yaml` (shared), chain: `step_5`
- [ ] 9. [sub-task: code-path-analysis] `task(..., prompt: "execute code-path-analysis task from spec-creation")` — input: `{project_root}/tmp/{N}/contracts/code-path-analysis-input.yaml`, output: `{project_root}/tmp/{N}/contracts/code-path-analysis-output.yaml`, template: `.opencode/skills/spec-creation/contracts/requirements-input-template.yaml` (shared), chain: `step_8`
- [ ] 10. [sub-task: interface-compatibility] `task(..., prompt: "execute interface-compatibility task from spec-creation")` — input: `{project_root}/tmp/{N}/contracts/interface-compatibility-input.yaml`, output: `{project_root}/tmp/{N}/contracts/interface-compatibility-output.yaml`, template: `.opencode/skills/spec-creation/contracts/requirements-input-template.yaml` (shared), chain: `step_8`
- [ ] 11. [sub-task: state-analysis] `task(..., prompt: "execute state-analysis task from spec-creation")` — input: `{project_root}/tmp/{N}/contracts/state-analysis-input.yaml`, output: `{project_root}/tmp/{N}/contracts/state-analysis-output.yaml`, template: `.opencode/skills/spec-creation/contracts/requirements-input-template.yaml` (shared), chain: `step_8`
- [ ] 12. [sub-task: pipeline-readiness-gate] `task(..., prompt: "execute pipeline-readiness-gate task from spec-creation")` — input: `{project_root}/tmp/{N}/contracts/pipeline-readiness-input.yaml`, output: `{project_root}/tmp/{N}/contracts/pipeline-readiness-output.yaml`, template: `.opencode/skills/spec-creation/contracts/requirements-input-template.yaml` (shared), chain: `step_8`
- [ ] 13. [sub-task: testability-assessment] `task(..., prompt: "execute testability-assessment task from spec-creation")` — input: `{project_root}/tmp/{N}/contracts/testability-assessment-input.yaml`, output: `{project_root}/tmp/{N}/contracts/testability-assessment-output.yaml`, template: `.opencode/skills/spec-creation/contracts/requirements-input-template.yaml` (shared), chain: `step_12`
- [ ] 14. [sub-task: risk] `task(..., prompt: "execute risk task from spec-creation")` — input: `{project_root}/tmp/{N}/contracts/risk-input.yaml`, output: `{project_root}/tmp/{N}/contracts/risk-output.yaml`, template: `.opencode/skills/spec-creation/contracts/requirements-input-template.yaml` (shared), chain: `step_13`
- [ ] 15. [inline] Invoke `solve model` for dependency-ordering constraints contract — chain: `step_14`
- [ ] 16. [inline] Invoke `solve check` to verify SAT — chain: `step_15`
- [ ] 17. [inline] Invoke `plan plan` for phase solvability validation — chain: `step_16`
- [ ] 18. [sub-task: interdependency-check] `task(..., prompt: "execute interdependency-check task from spec-creation")` — Before creating the spec, check for overlapping/conflicting open specs. Use `github_list_issues` to find open `[SPEC]` issues. Compare file paths, symbols, and concern boundaries. Classify each as FULL-SUPERSESSION, PARTIAL-OVERLAP, CONFLICT-RISK, or INDEPENDENT. If CONFLICT-RISK or FULL-SUPERSESSION found, HALT with blocker report. Chain: `step_17`
- [ ] 19. [sub-task: create] `task(..., prompt: "execute create task from spec-creation")` — input: `{project_root}/tmp/{N}/contracts/create-input.yaml`, output: `{project_root}/tmp/{N}/contracts/create-output.yaml`, template: `.opencode/skills/spec-creation/contracts/create-input-template.yaml`, chain: `step_14, step_18`
- [ ] 20. [sub-task: completion] `task(..., prompt: "execute completion task from spec-creation")` — input: `{project_root}/tmp/{N}/contracts/completion-input.yaml`, output: `{project_root}/tmp/{N}/contracts/completion-output.yaml`, template: `.opencode/skills/spec-creation/contracts/create-output-template.yaml` (shared), chain: `step_19`
- [ ] 21. [sub-task: spec-audit] `task(..., prompt: "execute spec-audit task from audit")` — chain: `step_19`
- [ ] 22. **Correctness over speed.** Every code path with runtime behavior requires live-wire testing against real systems. A slow correct answer is strictly better than a fast incorrect one. Static analysis alone is NOT acceptable verification — behavioral compliance requires actual execution with cross-validated PASS verdict.

## Exit Criteria

- Spec created as GitHub Issue
- Spec-audit completed
- Ready for approval-gate
