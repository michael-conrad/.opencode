# Plan: [#1049](https://github.com/michael-conrad/.opencode/issues/1049) push-artifacts Task

## Z3 Plan (solve tool — generated via plan tool)

**Phase Z3 chain**: Phase 0 (spec → contract → verify → plan → validate) → Phase 1 (task file) → Phase 2-3 (skill registrations) → Phase 4-5 (callers) → push artifacts → update issue body

## Generated Plan (10 steps, validated via plan tool)

| Step | Action | Domain Effect | What It Produces |
|------|--------|---------------|------------------|
| 1 | `create_spec` | `spec_created` | GitHub Issue body with SC table, Z3 ref, dispatch markers |
| 2 | `create_contract` | `contract_created` | `.issues/1049/spec-artifacts/phase-contract.yaml` (84 vars, 6 phases) |
| 3 | `verify_contract` | `verified_sat` | `solve check --state-path initial → SAT/UNSAT` proven |
| 4 | `generate_plan` | `plan_generated` | `plan tool` output — 10-step plan from Tamer |
| 5 | `validate_plan` | `plan_validated` | `plan validate` confirms plan achieves goals |
| 6 | `write_task_file` | `task_file_written` | New file: `platforms/local/tasks/push-artifacts.md` |
| 7 | `update_local_skill` | `local_skill_updated` | `platforms/local/SKILL.md` task table |
| 8 | `update_io_skill` | `io_skill_updated` | `issue-operations/SKILL.md` routing table |
| 9 | `push_artifacts_local` | `artifacts_pushed` | `git commit + push origin issues-data + git ls-tree verify` |
| 10 | `update_issue_body` | `issue_body_updated` | Issue body blockquote URL updated from verified `github.html_url` |

## Pipeline Gates per Phase

### Phase 0: Spec + Contract + Plan

| # | Gate | Exit Criterion |
|---|------|----------------|
| 1 | sc-coherence-gate | push-artifacts pattern is consistent with DRY, pure-git, single-concern invariants |
| 2 | pre-red-baseline | No push-artifacts task exists; callers embed URLs ad-hoc |
| 3 | red-phase | Behavioral test: agent asked to push artifacts for an issue → stderr MUST NOT show git ls-tree verify (RED = no task exists) |
| 4 | red-doublecheck | Failure is task-not-found, not broken harness |
| 5 | green-phase | Spec created, contract written, plan validated |
| 6 | checkpoint-commit | State after spec+contract written |
| 7 | structural-checks | YAML valid, plan validated, SAT confirmed |
| 8 | green-doublecheck | RED test still fails (task not implemented yet) |
| 9 | green-vbc | SC table complete, Z3 model proven |
| 10 | adversarial-audit | Spec forward-looking, no tracking language, per-unit gates |
| 11 | cross-validate | Both auditors agree on spec |
| 12 | regression-check | Spec consistent with #1048 lessons |
| 13 | review-prep | Entry/exit criteria for all 6 phases |
| 14 | exec-summary | Phase complete |

### Phase 1: push-artifacts Task File

| # | Gate | Exit Criterion |
|---|------|----------------|
| 1 | sc-coherence-gate | Task fits in platform-specific (git ops are local-platform), single concern: push+verify+URL |
| 2 | pre-red-baseline | Task file does not exist |
| 3 | red-phase | Behavioral test: agent prompted to push artifacts → stderr no git ls-tree (RED) |
| 4 | red-doublecheck | Failure is missing task |
| 5 | green-phase | Task file written with: git add → commit → push → fetch → ls-tree → URL construct using github.html_url only |
| 6 | checkpoint-commit | Task file committed |
| 7 | structural-checks | Task file follows local-platform task template |
| 8 | green-doublecheck | RED test PASSES — stderr shows git ls-tree verify |
| 9 | green-vbc | SC-1, SC-2, SC-7 verified |
| 10 | adversarial-audit | CRITICAL: verify ZERO curl, ZERO GitHub API calls, ZERO secrets in task file |
| 11 | cross-validate | Both auditors agree |
| 12 | regression-check | Existing local-platform tasks not affected |
| 13 | review-prep | Task entry/exit criteria complete |
| 14 | exec-summary | Phase complete |

### Phase 2: local SKILL.md Registration

**RED**: SKILL.md does not list push-artifacts
**GREEN**: SKILL.md tasks table includes push-artifacts

### Phase 3: issue-operations SKILL.md Registration

**RED**: SKILL.md does not list push-artifacts
**GREEN**: SKILL.md tasks table + routing includes push-artifacts

### Phase 4: spec-creation Completion

**RED**: spec-creation completion does not call push-artifacts
**GREEN**: spec-creation completion Step: `task({prompt: "execute push-artifacts from issue-operations"})` → embed artifact_url in issue body blockquote

### Phase 5: writing-plans Completion

**RED**: writing-plans completion does not call push-artifacts
**GREEN**: Same pattern as Phase 4

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | `platforms/local/tasks/push-artifacts.md` exists | `structural` |
| SC-2 | Task uses pure git only (no curl, no API calls, no secrets) | `behavioral` |
| SC-3 | Task returns `artifact_url` in result contract | `behavioral` |
| SC-4 | spec-creation completion embeds URL blockquote | `behavioral` |
| SC-5 | writing-plans completion embeds URL blockquote | `behavioral` |
| SC-6 | Z3 contract SAT initial, UNSAT defective, SAT complete | `behavioral` |
| SC-7 | URL construction uses `github.html_url` + literals only | `structural` |

## Dispatch Markers

| Phase | Marker |
|-------|--------|
| 0 | `push-artifacts-spec-contract-plan` |
| 1 | `push-artifacts-task-file` |
| 2 | `push-artifacts-local-skill` |
| 3 | `push-artifacts-io-skill` |
| 4 | `push-artifacts-spec-completion` |
| 5 | `push-artifacts-plans-completion` |