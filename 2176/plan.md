---
plan_schema_version: "1.0"
issue: 2176
title: "Pipeline Ceremony Reduction"
dispatch:
  - phase: 1
    skill: implementation-pipeline
    task: TDT and state machine updates
  - phase: 2
    skill: general sub-agent
    task: Fix path references
  - phase: 3
    skill: audit + general sub-agent
    task: Sub-agent dispatch prohibition
  - phase: 4
    skill: implementation-pipeline + writing-plans
    task: Pipeline restructuring
  - phase: 5
    skill: git-workflow + general sub-agent
    task: File cleanup
---

> **Note on `git-workflow/tasks/` path references:** All references to `git-workflow/tasks/` (e.g., `git-workflow/tasks/commit-prep.md`, `git-workflow/tasks/review-prep.md`) throughout this plan reflect the **current (pre-fix) state** of the codebase. These stale paths are the exact problem that Phase 2 (SC-2) is designed to fix. The plan describes what exists now and what must change — the paths are intentionally left as-is to accurately represent the starting state. After Phase 2 executes, all such references will be updated to their correct sub-skill paths (e.g., `git-workflow-commit/tasks/commit-prep.md`, `git-workflow-pr/tasks/review-prep.md`).

> **Note on multi-concern phases:** Phases 1, 3, and 5 each cover 2 concerns (SC-1+SC-8, SC-3+SC-4, SC-6+SC-7 respectively). This is intentional per the spec design — the spec explicitly groups related success criteria into shared phases where the concerns share affected files and implementation context. Phase 1 groups TDT updates with Z3 inline check because both modify the same TDT and state machine. Phase 3 groups sub-agent dispatch prohibition with resolve-models cleanup because both audit the same set of task/SKILL.md files. Phase 5 groups checkpoint inline with legacy file removal because both modify the same pipeline TDT and state machine. This grouping is a deliberate spec-level decision, not a concern-separation defect.

> **PR gate model — each phase is a separate PR:**
> Phases have real dependency chains. Phase 1's TDT changes must be live (merged to trunk) before Phases 2-5 can use them. Phase 2's path fixes must be live before downstream consumers see correct paths. A single branch cannot provide this isolation.
>
> ```
> Phase 1 PR ──merge──▶ Phase 2+3 PRs (parallel) ──merge──▶ Phase 4 PR ──merge──▶ Phase 5 PR
> ```
>
> Each phase ends with a PR creation step. The next phase starts by branching from the updated trunk after the prior phase's PR is merged. The executor MUST verify the prior phase's PR is merged before starting the next phase.
>
> **Phase 1 uses current pipeline, Phases 2-5 use new pipeline:**
> Phase 1 creates the new 6-step TDT. The new steps do not exist when Phase 1 executes. Therefore:
> - **Phase 1 items** execute using the **current (pre-change) implementation-pipeline TDT steps** (pre-analysis, red, z3-check-red, red-doublecheck, z3-check-red-doublecheck, post-red-enforcement, z3-check-post-red, green, z3-check-green, post-green-enforcement, z3-check-post-green, checkpoint-tag-create, checkpoint-commit, verify, commit, audit DiMo, cross-validate). These are the steps that exist now and will be replaced.
> - **After Phase 1 PR is merged**, the new TDT is live on trunk. **Phases 2-5** branch from the updated trunk and execute using the **new 6-step cycle** (pre-regression, pre-regression-verify, red, green, post-regression, verify) + inline commit + DiMo audit.
> - The plan below uses the new step names for ALL items as the canonical procedure description. The executor MUST map Phase 1 items to current pipeline steps at dispatch time. This mapping is intentional — Phase 1 both describes and builds the new TDT.

---

## Pre-implementation

- [ ] **Coherence gate** — Dispatch coherence extraction to verify spec/plan coherence before any RED routing. (**sub-agent**)
  - Context: {issue_number: 2176}
  - Dispatch: `task(..., prompt: "execute coherence-extraction from audit. Read \`audit/tasks/coherence-extraction.md\` first")`
- [ ] **Baseline check** — Verify baseline state: confirm all affected files exist, current git state is clean, and no stale artifacts remain from prior runs. (**sub-agent**)
  - Context: {issue_number: 2176}
  - Dispatch: `task(..., prompt: "verify baseline state for issue 2176: check git status, confirm affected files exist, clean stale artifacts")`

---

## Phase 1: TDT and state machine updates (SC-1, SC-8)

Concern: Update implementation-pipeline TDT, state machine, and Z3 integration. Affected files: `.opencode/skills/implementation-pipeline/SKILL.md`, `.opencode/skills/implementation-pipeline/pipeline-state-machine.yaml`.

### Item 1 (SC-1): Update TDT — remove old steps, add new 6-step cycle, update state machine

- [ ] **pre-regression** — Run existing enforcement tests to establish baseline. Capture pass/fail counts. (**sub-agent**)
  - Context: {issue_number: 2176, sc: SC-1}
  - Dispatch: `task(..., prompt: "run existing enforcement tests for implementation-pipeline TDT. Capture baseline pass/fail counts and save to artifact")`
- [ ] **pre-regression-verify** — Verify pre-regression results: confirm tests ran, baseline captured. (**sub-agent**)
  - Context: {issue_number: 2176}
  - Dispatch: `task(..., prompt: "verify pre-regression results for issue 2176 item 1. Confirm baseline was captured and saved to artifact")`
- [ ] **red** — Write enforcement test: grep TDT for removed step names (cross-validate, checkpoint-commit, old per-item cycle steps) — expect 0 matches. grep for new step names (pre-regression, pre-regression-verify, red, green, post-regression, verify, commit inline, audit DiMo) — expect matches. Test MUST FAIL because old steps still exist. (**sub-agent**)
  - Context: {issue_number: 2176, sc: SC-1}
  - Dispatch: `task(..., prompt: "write enforcement test for SC-1: grep TDT for removed step names (expect 0 matches) and new step names (expect matches). Test must fail initially")`
- [ ] **green** — Edit `implementation-pipeline/SKILL.md` TDT: remove cross-validate, checkpoint-commit, and all old per-item cycle steps. Add new 6-step cycle: pre-regression, pre-regression-verify, red, green, post-regression, verify, commit inline, audit DiMo. Update `pipeline-state-machine.yaml` to match new TDT with new step transitions. (**sub-agent**)
  - Context: {issue_number: 2176, sc: SC-1, affected_files: [".opencode/skills/implementation-pipeline/SKILL.md", ".opencode/skills/implementation-pipeline/pipeline-state-machine.yaml"]}
  - Dispatch: `task(..., prompt: "edit implementation-pipeline/SKILL.md TDT: remove cross-validate, checkpoint-commit, old per-item cycle steps. Add pre-regression, pre-regression-verify, red, green, post-regression, verify, commit inline, audit DiMo. Update pipeline-state-machine.yaml with new step transitions")`
- [ ] **post-regression** — Re-run enforcement tests. Verify no regressions from baseline. (**sub-agent**)
  - Context: {issue_number: 2176}
  - Dispatch: `task(..., prompt: "re-run enforcement tests for implementation-pipeline TDT. Compare results against baseline — verify no regressions")`
- [ ] **verify** — Verify implementation: confirm TDT has new steps, old steps removed, state machine updated. (**sub-agent**)
  - Context: {issue_number: 2176}
  - Dispatch: `task(..., prompt: "verify SC-1 implementation: grep TDT for new steps (expect matches), grep for removed steps (expect 0 matches), confirm state machine updated")`
- [ ] **inline commit** — Commit changes. (**inline**)
  - Command: `git add .opencode/skills/implementation-pipeline/SKILL.md .opencode/skills/implementation-pipeline/pipeline-state-machine.yaml && git commit -m "Phase 1 Item 1: update implementation-pipeline TDT and state machine"`
- [ ] **DiMo audit** — Run DiMo audit on the deliverable. (**sub-agent**)
  - Context: {issue_number: 2176, sc: SC-1}
  - Dispatch: `task(..., prompt: "execute audit from audit. Read \`audit/tasks/verification-audit.md\` first")`
- [ ] **Z3 check** — Inline Z3 check on phase state after AUDIT. (**inline**)
  - Command: `.opencode/tools/solve check --state-path ./tmp/2176/state/ --contract-path .opencode/skills/implementation-pipeline/pipeline-state-machine.yaml`

### Item 8 (SC-8): Single inline Z3 check per phase after AUDIT

- [ ] **pre-regression** — Run existing enforcement tests to establish baseline. (**sub-agent**)
  - Context: {issue_number: 2176, sc: SC-8}
  - Dispatch: `task(..., prompt: "run existing enforcement tests for Z3 inline check behavior. Capture baseline pass/fail counts")`
- [ ] **pre-regression-verify** — Verify pre-regression results. (**sub-agent**)
  - Context: {issue_number: 2176}
  - Dispatch: `task(..., prompt: "verify pre-regression results for issue 2176 item 8")`
- [ ] **red** — Write enforcement test: opencode run with multi-phase scenario, assert_semantic for Z3 check after each AUDIT. Test MUST FAIL because Z3 check is not yet specified as inline after AUDIT. (**sub-agent**)
  - Context: {issue_number: 2176, sc: SC-8}
  - Dispatch: `task(..., prompt: "write behavioral enforcement test for SC-8: opencode run with multi-phase scenario, assert_semantic for Z3 check after each AUDIT. Test must fail initially")`
- [ ] **green** — Update `implementation-pipeline/SKILL.md` to specify inline Z3 check after AUDIT in the TDT and Invocation sections. Add Z3 check step after each AUDIT entry. (**sub-agent**)
  - Context: {issue_number: 2176, sc: SC-8, affected_files: [".opencode/skills/implementation-pipeline/SKILL.md"]}
  - Dispatch: `task(..., prompt: "edit implementation-pipeline/SKILL.md: add inline Z3 check step after each AUDIT in TDT and Invocation sections")`
- [ ] **post-regression** — Re-run enforcement tests. Verify no regressions. (**sub-agent**)
  - Context: {issue_number: 2176}
  - Dispatch: `task(..., prompt: "re-run enforcement tests for Z3 inline check. Compare against baseline — verify no regressions")`
- [ ] **verify** — Verify implementation: confirm Z3 check specified as inline after AUDIT in TDT. (**sub-agent**)
  - Context: {issue_number: 2176}
  - Dispatch: `task(..., prompt: "verify SC-8 implementation: grep TDT for Z3 check after AUDIT entries, confirm inline dispatch")`
- [ ] **inline commit** — Commit changes. Items 1 and 8 committed together (same affected files). (**inline**)
  - Command: `git add .opencode/skills/implementation-pipeline/SKILL.md .opencode/skills/implementation-pipeline/pipeline-state-machine.yaml && git commit -m "Phase 1 Items 1+8: update TDT, state machine, add inline Z3 check after AUDIT"`
- [ ] **DiMo audit** — Run DiMo audit on the deliverable. (**sub-agent**)
  - Context: {issue_number: 2176, sc: SC-1, sc: SC-8}
  - Dispatch: `task(..., prompt: "execute audit from audit. Read \`audit/tasks/verification-audit.md\` first")`
- [ ] **Z3 check** — Inline Z3 check on phase state after AUDIT. (**inline**)
  - Command: `.opencode/tools/solve check --state-path ./tmp/2176/state/ --contract-path .opencode/skills/implementation-pipeline/pipeline-state-machine.yaml`

### Phase 1 PR Gate

- [ ] **Create PR** — Create pull request for Phase 1. (**sub-agent**)
  - Context: {issue_number: 2176, phase: 1}
  - Dispatch: `task(..., prompt: "execute create from pr-creation-workflow. Read \`pr-creation-workflow/tasks/create.md\` first")`
- [ ] **Wait for merge** — Phase 1 PR must be merged before Phase 2 can start. The executor MUST verify the PR is merged before branching for Phase 2. (**orchestrator**)
  - Action: poll PR merge status via `gh pr view <number> --json mergedAt,state`
  - Proceed only when `mergedAt` is non-null and `state` is MERGED

---

## Phase 2: Fix path references (SC-2)

Concern: Fix all git-workflow/tasks/ path references to correct sub-skill paths across 7 files. Can run in parallel with Phase 3. Depends on Phase 1 (shared implementation-pipeline/SKILL.md file).

### Phase 2 Pre-Flight

- [ ] **Verify Phase 1 merged** — Confirm Phase 1 PR is merged before branching. (**orchestrator**)
  - Action: `gh pr view <phase1_pr_number> --json mergedAt,state`
  - HALT if not merged — Phase 1 TDT changes must be live on trunk first

### Item 2 (SC-2): Fix git-workflow/tasks/ references across 7 files

- [ ] **pre-regression** — Run existing enforcement tests to establish baseline. (**sub-agent**)
  - Context: {issue_number: 2176, sc: SC-2}
  - Dispatch: `task(..., prompt: "run existing enforcement tests for path reference checks. Capture baseline pass/fail counts")`
- [ ] **pre-regression-verify** — Verify pre-regression results. (**sub-agent**)
  - Context: {issue_number: 2176}
  - Dispatch: `task(..., prompt: "verify pre-regression results for issue 2176 item 2")`
- [ ] **red** — Write enforcement test: grep 'git-workflow/tasks/' across .opencode/ — expect 0 matches. Test MUST FAIL because stale paths still exist. (**sub-agent**)
  - Context: {issue_number: 2176, sc: SC-2}
  - Dispatch: `task(..., prompt: "write enforcement test for SC-2: grep 'git-workflow/tasks/' across .opencode/ — expect 0 matches. Test must fail initially")`
- [ ] **green** — Edit each of the 7 affected files to replace `git-workflow/tasks/` with correct sub-skill paths. Files: `implementation-pipeline/SKILL.md`, `completion-core/SKILL.md`, `approval-gate-scope/tasks/verify-closed-issue.md`, `pr-creation-workflow/tasks/create.md`, `guidelines/065-verification-honesty.md`, `CHANGELOG.md`, `.guidelines/registry.yaml`. (**sub-agent**)
  - Context: {issue_number: 2176, sc: SC-2, affected_files: [".opencode/skills/implementation-pipeline/SKILL.md", ".opencode/skills/completion-core/SKILL.md", ".opencode/skills/approval-gate-scope/tasks/verify-closed-issue.md", ".opencode/skills/pr-creation-workflow/tasks/create.md", ".opencode/guidelines/065-verification-honesty.md", ".opencode/CHANGELOG.md", ".opencode/.guidelines/registry.yaml"]}
  - Dispatch: `task(..., prompt: "edit 7 files to replace git-workflow/tasks/ with correct sub-skill paths. Map each reference to its correct sub-skill path")`
- [ ] **post-regression** — Re-run enforcement tests. Verify no regressions. (**sub-agent**)
  - Context: {issue_number: 2176}
  - Dispatch: `task(..., prompt: "re-run enforcement tests for path references. Compare against baseline — verify no regressions")`
- [ ] **verify** — Verify implementation: grep 'git-workflow/tasks/' across .opencode/ — confirm 0 matches. (**sub-agent**)
  - Context: {issue_number: 2176}
  - Dispatch: `task(..., prompt: "verify SC-2 implementation: grep 'git-workflow/tasks/' across .opencode/ — confirm 0 matches")`
- [ ] **inline commit** — Commit changes. All 7 file changes committed together. (**inline**)
  - Command: `git add .opencode/skills/implementation-pipeline/SKILL.md .opencode/skills/completion-core/SKILL.md .opencode/skills/approval-gate-scope/tasks/verify-closed-issue.md .opencode/skills/pr-creation-workflow/tasks/create.md .opencode/guidelines/065-verification-honesty.md .opencode/CHANGELOG.md .opencode/.guidelines/registry.yaml && git commit -m "Phase 2 Item 2: fix git-workflow/tasks/ path references across 7 files"`
- [ ] **DiMo audit** — Run DiMo audit on the deliverable. (**sub-agent**)
  - Context: {issue_number: 2176, sc: SC-2}
  - Dispatch: `task(..., prompt: "execute audit from audit. Read \`audit/tasks/verification-audit.md\` first")`
- [ ] **Z3 check** — Inline Z3 check on phase state after AUDIT. (**inline**)
  - Command: `.opencode/tools/solve check --state-path ./tmp/2176/state/ --contract-path .opencode/skills/implementation-pipeline/pipeline-state-machine.yaml`

### Phase 2 PR Gate

- [ ] **Create PR** — Create pull request for Phase 2. (**sub-agent**)
  - Context: {issue_number: 2176, phase: 2}
  - Dispatch: `task(..., prompt: "execute create from pr-creation-workflow. Read \`pr-creation-workflow/tasks/create.md\` first")`
- [ ] **Wait for merge** — Phase 2 PR must be merged before Phase 4 can start. Phase 3 runs in parallel and does NOT wait for Phase 2. (**orchestrator**)
  - Action: poll PR merge status via `gh pr view <number> --json mergedAt,state`
  - Proceed only when `mergedAt` is non-null and `state` is MERGED

---

## Phase 3: Sub-agent dispatch prohibition (SC-3, SC-4)

Concern: Audit task files for imperative skill()/task() instructions and SKILL.md files for resolve-models/auditor_1/auditor_2 references. Replace with result contract instructions. Skip files in Phase 5 removal list. Can run in parallel with Phase 2. Depends on Phase 1 (TDT must be live on trunk).

### Phase 3 Pre-Flight

- [ ] **Verify Phase 1 merged** — Confirm Phase 1 PR is merged before branching. (**orchestrator**)
  - Action: `gh pr view <phase1_pr_number> --json mergedAt,state`
  - HALT if not merged — Phase 1 TDT changes must be live on trunk first

### Item 3 (SC-3): Replace imperative skill()/task() instructions in task files

- [ ] **pre-regression** — Run existing enforcement tests to establish baseline. (**sub-agent**)
  - Context: {issue_number: 2176, sc: SC-3}
  - Dispatch: `task(..., prompt: "run existing enforcement tests for skill()/task() prohibition. Capture baseline pass/fail counts")`
- [ ] **pre-regression-verify** — Verify pre-regression results. (**sub-agent**)
  - Context: {issue_number: 2176}
  - Dispatch: `task(..., prompt: "verify pre-regression results for issue 2176 item 3")`
- [ ] **red** — Write enforcement test: grep for `skill({name:` pattern in tasks/ directories — expect 0 imperative matches (documentation references permitted). Test MUST FAIL because imperative instructions still exist. (**sub-agent**)
  - Context: {issue_number: 2176, sc: SC-3}
  - Dispatch: `task(..., prompt: "write enforcement test for SC-3: grep for skill({name: pattern in tasks/ directories — expect 0 imperative matches. Documentation references permitted. Test must fail initially")`
- [ ] **green** — For each task file with imperative skill()/task() instructions: replace with result contract instructions. Skip Phase 5 removal targets. Audit all ~100+ matching files across `.opencode/skills/*/tasks/`. Classify each match as imperative (must replace) or documentation (must preserve). (**sub-agent**)
  - Context: {issue_number: 2176, sc: SC-3, skip_list: [".opencode/skills/implementation-pipeline/tasks/checkpoint-tag-create.md", ".opencode/skills/implementation-pipeline/tasks/sc-count-gate.md", ".opencode/skills/implementation-pipeline/tasks/pre-red-baseline.md", ".opencode/skills/implementation-pipeline/tasks/post-red-enforcement.md", ".opencode/skills/implementation-pipeline/tasks/post-green-enforcement.md", ".opencode/skills/implementation-pipeline/tasks/tdd-chaining-gate.md", ".opencode/skills/implementation-pipeline/tasks/pre-flight.md", ".opencode/skills/implementation-pipeline/tasks/pre-flight-handoff.md", ".opencode/skills/implementation-pipeline/tasks/sc-closeout.md", ".opencode/skills/implementation-pipeline/tasks/assemble-work.md", ".opencode/skills/implementation-pipeline/tasks/behavioral-test-remediation.md", ".opencode/skills/implementation-pipeline/tasks/pipeline-executor.md", ".opencode/skills/audit/tasks/cross-validate.md", ".opencode/skills/audit/tasks/resolve-models.md"]}
  - Dispatch: `task(..., prompt: "audit all task files under .opencode/skills/*/tasks/ for imperative skill()/task() instructions. Replace with result contract instructions. Skip files in the provided skip_list. Classify each match as imperative (replace) or documentation (preserve)")`
- [ ] **post-regression** — Re-run enforcement tests. Verify no regressions. (**sub-agent**)
  - Context: {issue_number: 2176}
  - Dispatch: `task(..., prompt: "re-run enforcement tests for skill()/task() prohibition. Compare against baseline — verify no regressions")`
- [ ] **verify** — Verify implementation: grep for `skill({name:` in tasks/ directories — confirm 0 imperative matches. (**sub-agent**)
  - Context: {issue_number: 2176}
  - Dispatch: `task(..., prompt: "verify SC-3 implementation: grep for skill({name: in tasks/ directories — confirm 0 imperative matches. Manual review remaining matches to confirm they are documentation references only")`
- [ ] **inline commit** — Commit changes. All task file changes committed together. (**inline**)
  - Command: `git add .opencode/skills/*/tasks/ && git commit -m "Phase 3 Item 3: replace imperative skill()/task() instructions with result contract instructions"`
- [ ] **DiMo audit** — Run DiMo audit on the deliverable. (**sub-agent**)
  - Context: {issue_number: 2176, sc: SC-3}
  - Dispatch: `task(..., prompt: "execute audit from audit. Read \`audit/tasks/verification-audit.md\` first")`
- [ ] **Z3 check** — Inline Z3 check on phase state after AUDIT. (**inline**)
  - Command: `.opencode/tools/solve check --state-path ./tmp/2176/state/ --contract-path .opencode/skills/implementation-pipeline/pipeline-state-machine.yaml`

### Item 4 (SC-4): Remove stale resolve-models/auditor_1/auditor_2 references from SKILL.md files

- [ ] **pre-regression** — Run existing enforcement tests to establish baseline. (**sub-agent**)
  - Context: {issue_number: 2176, sc: SC-4}
  - Dispatch: `task(..., prompt: "run existing enforcement tests for resolve-models prohibition. Capture baseline pass/fail counts")`
- [ ] **pre-regression-verify** — Verify pre-regression results. (**sub-agent**)
  - Context: {issue_number: 2176}
  - Dispatch: `task(..., prompt: "verify pre-regression results for issue 2176 item 4")`
- [ ] **red** — Write enforcement test: grep for resolve-models/auditor_1/auditor_2 in SKILL.md files — expect 0 matches. Test MUST FAIL because stale references still exist. (**sub-agent**)
  - Context: {issue_number: 2176, sc: SC-4}
  - Dispatch: `task(..., prompt: "write enforcement test for SC-4: grep for resolve-models/auditor_1/auditor_2 in SKILL.md files — expect 0 matches. Test must fail initially")`
- [ ] **green** — For each SKILL.md with stale resolve-models/auditor_1/auditor_2 references: remove the references from Sub-Agent Routing sections. Skip Phase 5 removal targets. Audit all 14 matching SKILL.md files. (**sub-agent**)
  - Context: {issue_number: 2176, sc: SC-4, skip_list: [".opencode/skills/implementation-pipeline/tasks/checkpoint-tag-create.md", ".opencode/skills/implementation-pipeline/tasks/sc-count-gate.md", ".opencode/skills/implementation-pipeline/tasks/pre-red-baseline.md", ".opencode/skills/implementation-pipeline/tasks/post-red-enforcement.md", ".opencode/skills/implementation-pipeline/tasks/post-green-enforcement.md", ".opencode/skills/implementation-pipeline/tasks/tdd-chaining-gate.md", ".opencode/skills/implementation-pipeline/tasks/pre-flight.md", ".opencode/skills/implementation-pipeline/tasks/pre-flight-handoff.md", ".opencode/skills/implementation-pipeline/tasks/sc-closeout.md", ".opencode/skills/implementation-pipeline/tasks/assemble-work.md", ".opencode/skills/implementation-pipeline/tasks/behavioral-test-remediation.md", ".opencode/skills/implementation-pipeline/tasks/pipeline-executor.md", ".opencode/skills/audit/tasks/cross-validate.md", ".opencode/skills/audit/tasks/resolve-models.md"]}
  - Dispatch: `task(..., prompt: "audit all SKILL.md files matching resolve-models/auditor_1/auditor_2. Remove stale references from Sub-Agent Routing sections. Skip files in the provided skip_list")`
- [ ] **post-regression** — Re-run enforcement tests. Verify no regressions. (**sub-agent**)
  - Context: {issue_number: 2176}
  - Dispatch: `task(..., prompt: "re-run enforcement tests for resolve-models prohibition. Compare against baseline — verify no regressions")`
- [ ] **verify** — Verify implementation: grep for resolve-models/auditor_1/auditor_2 in SKILL.md files — confirm 0 matches. (**sub-agent**)
  - Context: {issue_number: 2176}
  - Dispatch: `task(..., prompt: "verify SC-4 implementation: grep for resolve-models/auditor_1/auditor_2 in SKILL.md files — confirm 0 matches")`
- [ ] **inline commit** — Commit changes. All SKILL.md changes committed together. (**inline**)
  - Command: `git add .opencode/skills/*/SKILL.md && git commit -m "Phase 3 Item 4: remove stale resolve-models/auditor_1/auditor_2 references from SKILL.md files"`
- [ ] **DiMo audit** — Run DiMo audit on the deliverable. (**sub-agent**)
  - Context: {issue_number: 2176, sc: SC-4}
  - Dispatch: `task(..., prompt: "execute audit from audit. Read \`audit/tasks/verification-audit.md\` first")`
- [ ] **Z3 check** — Inline Z3 check on phase state after AUDIT. (**inline**)
  - Command: `.opencode/tools/solve check --state-path ./tmp/2176/state/ --contract-path .opencode/skills/implementation-pipeline/pipeline-state-machine.yaml`

### Phase 3 PR Gate

- [ ] **Create PR** — Create pull request for Phase 3. (**sub-agent**)
  - Context: {issue_number: 2176, phase: 3}
  - Dispatch: `task(..., prompt: "execute create from pr-creation-workflow. Read \`pr-creation-workflow/tasks/create.md\` first")`
- [ ] **Wait for merge** — Phase 3 PR must be merged before Phase 5 can start. Phase 4 does NOT wait for Phase 3 (Phase 4 depends on Phase 1+2 only). (**orchestrator**)
  - Action: poll PR merge status via `gh pr view <number> --json mergedAt,state`
  - Proceed only when `mergedAt` is non-null and `state` is MERGED

---

## Phase 4: Pipeline restructuring (SC-5)

Concern: Collapse per-item cycle to 6 steps + inline commit. Collapse writing-plans pipeline to 4 steps. Depends on Phase 1 (TDT must be live on trunk) and Phase 2 (path references must be live on trunk).

### Phase 4 Pre-Flight

- [ ] **Verify Phase 1 merged** — Confirm Phase 1 PR is merged before branching. (**orchestrator**)
  - Action: `gh pr view <phase1_pr_number> --json mergedAt,state`
  - HALT if not merged
- [ ] **Verify Phase 2 merged** — Confirm Phase 2 PR is merged before branching. (**orchestrator**)
  - Action: `gh pr view <phase2_pr_number> --json mergedAt,state`
  - HALT if not merged — Phase 2 path fixes must be live on trunk

### Item 5 (SC-5): Collapse per-item cycle and writing-plans pipeline

- [ ] **pre-regression** — Run existing enforcement tests to establish baseline. (**sub-agent**)
  - Context: {issue_number: 2176, sc: SC-5}
  - Dispatch: `task(..., prompt: "run existing enforcement tests for pipeline step sequence. Capture baseline pass/fail counts")`
- [ ] **pre-regression-verify** — Verify pre-regression results. (**sub-agent**)
  - Context: {issue_number: 2176}
  - Dispatch: `task(..., prompt: "verify pre-regression results for issue 2176 item 5")`
- [ ] **red** — Write enforcement test: opencode run with full pipeline scenario, assert_semantic for step sequence (6 per-item steps + inline commit, 4 writing-plans steps). Test MUST FAIL because old pipeline still has more steps. (**sub-agent**)
  - Context: {issue_number: 2176, sc: SC-5}
  - Dispatch: `task(..., prompt: "write behavioral enforcement test for SC-5: opencode run with full pipeline scenario, assert_semantic for 6 per-item steps + inline commit and 4 writing-plans steps. Test must fail initially")`
- [ ] **green** — Update `implementation-pipeline/SKILL.md` TDT and Invocation for new 6-step per-item cycle (pre-regression, pre-regression-verify, red, green, post-regression, verify) + inline commit + DiMo audit. Update `writing-plans/SKILL.md` for new 4-step pipeline (analyze, research, create, validate). Update/remove `writing-plans/tasks/` (explore, structure, solve, self-review) to match new 4-step pipeline. (**sub-agent**)
  - Context: {issue_number: 2176, sc: SC-5, affected_files: [".opencode/skills/implementation-pipeline/SKILL.md", ".opencode/skills/writing-plans/SKILL.md", ".opencode/skills/writing-plans/tasks/explore.md", ".opencode/skills/writing-plans/tasks/structure.md", ".opencode/skills/writing-plans/tasks/solve.md", ".opencode/skills/writing-plans/tasks/self-review.md"]}
  - Dispatch: `task(..., prompt: "edit implementation-pipeline/SKILL.md: set per-item cycle to 6 steps (pre-regression, pre-regression-verify, red, green, post-regression, verify) + inline commit + DiMo audit. Edit writing-plans/SKILL.md: set pipeline to 4 steps (analyze, research, create, validate). Update writing-plans/tasks/ to match")`
- [ ] **post-regression** — Re-run enforcement tests. Verify no regressions. (**sub-agent**)
  - Context: {issue_number: 2176}
  - Dispatch: `task(..., prompt: "re-run enforcement tests for pipeline step sequence. Compare against baseline — verify no regressions")`
- [ ] **verify** — Verify implementation: confirm per-item cycle has exactly 6 steps + inline commit, writing-plans has exactly 4 steps. (**sub-agent**)
  - Context: {issue_number: 2176}
  - Dispatch: `task(..., prompt: "verify SC-5 implementation: confirm per-item cycle has 6 steps + inline commit, writing-plans has 4 steps. Check TDT and Invocation sections")`
- [ ] **inline commit** — Commit changes. All pipeline restructuring changes committed together. (**inline**)
  - Command: `git add .opencode/skills/implementation-pipeline/SKILL.md .opencode/skills/writing-plans/SKILL.md .opencode/skills/writing-plans/tasks/ && git commit -m "Phase 4 Item 5: collapse per-item cycle to 6 steps + inline commit, writing-plans to 4 steps"`
- [ ] **DiMo audit** — Run DiMo audit on the deliverable. (**sub-agent**)
  - Context: {issue_number: 2176, sc: SC-5}
  - Dispatch: `task(..., prompt: "execute audit from audit. Read \`audit/tasks/verification-audit.md\` first")`
- [ ] **Z3 check** — Inline Z3 check on phase state after AUDIT. (**inline**)
  - Command: `.opencode/tools/solve check --state-path ./tmp/2176/state/ --contract-path .opencode/skills/implementation-pipeline/pipeline-state-machine.yaml`

### Phase 4 PR Gate

- [ ] **Create PR** — Create pull request for Phase 4. (**sub-agent**)
  - Context: {issue_number: 2176, phase: 4}
  - Dispatch: `task(..., prompt: "execute create from pr-creation-workflow. Read \`pr-creation-workflow/tasks/create.md\` first")`
- [ ] **Wait for merge** — Phase 4 PR must be merged before Phase 5 can start. (**orchestrator**)
  - Action: poll PR merge status via `gh pr view <number> --json mergedAt,state`
  - Proceed only when `mergedAt` is non-null and `state` is MERGED

---

## Phase 5: File cleanup (SC-6, SC-7)

Concern: Make checkpoint tags inline, remove legacy task files, audit cross-references. Depends on all prior phases (1, 2, 3, 4) — all must be live on trunk.

### Phase 5 Pre-Flight

- [ ] **Verify Phase 1 merged** — Confirm Phase 1 PR is merged before branching. (**orchestrator**)
  - Action: `gh pr view <phase1_pr_number> --json mergedAt,state`
  - HALT if not merged
- [ ] **Verify Phase 2 merged** — Confirm Phase 2 PR is merged before branching. (**orchestrator**)
  - Action: `gh pr view <phase2_pr_number> --json mergedAt,state`
  - HALT if not merged
- [ ] **Verify Phase 3 merged** — Confirm Phase 3 PR is merged before branching. (**orchestrator**)
  - Action: `gh pr view <phase3_pr_number> --json mergedAt,state`
  - HALT if not merged
- [ ] **Verify Phase 4 merged** — Confirm Phase 4 PR is merged before branching. (**orchestrator**)
  - Action: `gh pr view <phase4_pr_number> --json mergedAt,state`
  - HALT if not merged

### Item 6 (SC-6): Make checkpoint tag creation inline, remove checkpoint-commit step

- [ ] **pre-regression** — Run existing enforcement tests to establish baseline. (**sub-agent**)
  - Context: {issue_number: 2176, sc: SC-6}
  - Dispatch: `task(..., prompt: "run existing enforcement tests for checkpoint behavior. Capture baseline pass/fail counts")`
- [ ] **pre-regression-verify** — Verify pre-regression results. (**sub-agent**)
  - Context: {issue_number: 2176}
  - Dispatch: `task(..., prompt: "verify pre-regression results for issue 2176 item 6")`
- [ ] **red** — Write enforcement test: opencode run with checkpoint scenario, assert_stderr_pattern for inline git tag (no sub-agent dispatch). Test MUST FAIL because checkpoint tag creation still uses sub-agent dispatch. (**sub-agent**)
  - Context: {issue_number: 2176, sc: SC-6}
  - Dispatch: `task(..., prompt: "write behavioral enforcement test for SC-6: opencode run with checkpoint scenario, assert_stderr_pattern for inline git tag (no sub-agent dispatch). Test must fail initially")`
- [ ] **green** — Update `implementation-pipeline/SKILL.md` TDT to mark checkpoint-tag-create as inline (orchestrator runs git commands directly). Remove checkpoint-commit step from TDT. Update `pipeline-state-machine.yaml` to remove checkpoint-commit transitions. (**sub-agent**)
  - Context: {issue_number: 2176, sc: SC-6, affected_files: [".opencode/skills/implementation-pipeline/SKILL.md", ".opencode/skills/implementation-pipeline/pipeline-state-machine.yaml"]}
  - Dispatch: `task(..., prompt: "edit implementation-pipeline/SKILL.md: mark checkpoint-tag-create as inline dispatch. Remove checkpoint-commit step from TDT. Update pipeline-state-machine.yaml to remove checkpoint-commit transitions")`
- [ ] **post-regression** — Re-run enforcement tests. Verify no regressions. (**sub-agent**)
  - Context: {issue_number: 2176}
  - Dispatch: `task(..., prompt: "re-run enforcement tests for checkpoint behavior. Compare against baseline — verify no regressions")`
- [ ] **verify** — Verify implementation: confirm checkpoint-tag-create is inline, checkpoint-commit removed from TDT and state machine. (**sub-agent**)
  - Context: {issue_number: 2176}
  - Dispatch: `task(..., prompt: "verify SC-6 implementation: confirm checkpoint-tag-create is inline dispatch, checkpoint-commit step removed from TDT and state machine")`
- [ ] **inline commit** — Commit changes. Items 6 and 7 committed together (same affected files). (**inline**)
  - Command: `git add .opencode/skills/implementation-pipeline/SKILL.md .opencode/skills/implementation-pipeline/pipeline-state-machine.yaml && git commit -m "Phase 5 Items 6+7: inline checkpoint tags, remove checkpoint-commit, remove legacy task files"`
- [ ] **DiMo audit** — Run DiMo audit on the deliverable. (**sub-agent**)
  - Context: {issue_number: 2176, sc: SC-6}
  - Dispatch: `task(..., prompt: "execute audit from audit. Read \`audit/tasks/verification-audit.md\` first")`
- [ ] **Z3 check** — Inline Z3 check on phase state after AUDIT. (**inline**)
  - Command: `.opencode/tools/solve check --state-path ./tmp/2176/state/ --contract-path .opencode/skills/implementation-pipeline/pipeline-state-machine.yaml`

### Item 7 (SC-7): Remove 14 legacy task files, audit cross-references

- [ ] **pre-regression** — Run existing enforcement tests to establish baseline. (**sub-agent**)
  - Context: {issue_number: 2176, sc: SC-7}
  - Dispatch: `task(..., prompt: "run existing enforcement tests for legacy file checks. Capture baseline pass/fail counts")`
- [ ] **pre-regression-verify** — Verify pre-regression results. (**sub-agent**)
  - Context: {issue_number: 2176}
  - Dispatch: `task(..., prompt: "verify pre-regression results for issue 2176 item 7")`
- [ ] **red** — Write enforcement test: ls for each removed file — expect "No such file". grep for each removed file path across .opencode/ — expect 0 matches. Test MUST FAIL because legacy files still exist. (**sub-agent**)
  - Context: {issue_number: 2176, sc: SC-7}
  - Dispatch: `task(..., prompt: "write enforcement test for SC-7: ls for each removed file (expect No such file), grep for each removed file path across .opencode/ (expect 0 matches). Test must fail initially")`
- [ ] **green** — Remove 14 legacy task files: `checkpoint-tag-create.md`, `sc-count-gate.md`, `pre-red-baseline.md`, `post-red-enforcement.md`, `post-green-enforcement.md`, `tdd-chaining-gate.md`, `pre-flight.md`, `pre-flight-handoff.md`, `sc-closeout.md`, `assemble-work.md`, `behavioral-test-remediation.md`, `pipeline-executor.md`, `cross-validate.md`, `resolve-models.md`. Audit cross-references across `.opencode/` for any remaining references to removed file paths. Fix any found. (**sub-agent**)
  - Context: {issue_number: 2176, sc: SC-7, removal_list: [".opencode/skills/implementation-pipeline/tasks/checkpoint-tag-create.md", ".opencode/skills/implementation-pipeline/tasks/sc-count-gate.md", ".opencode/skills/implementation-pipeline/tasks/pre-red-baseline.md", ".opencode/skills/implementation-pipeline/tasks/post-red-enforcement.md", ".opencode/skills/implementation-pipeline/tasks/post-green-enforcement.md", ".opencode/skills/implementation-pipeline/tasks/tdd-chaining-gate.md", ".opencode/skills/implementation-pipeline/tasks/pre-flight.md", ".opencode/skills/implementation-pipeline/tasks/pre-flight-handoff.md", ".opencode/skills/implementation-pipeline/tasks/sc-closeout.md", ".opencode/skills/implementation-pipeline/tasks/assemble-work.md", ".opencode/skills/implementation-pipeline/tasks/behavioral-test-remediation.md", ".opencode/skills/implementation-pipeline/tasks/pipeline-executor.md", ".opencode/skills/audit/tasks/cross-validate.md", ".opencode/skills/audit/tasks/resolve-models.md"]}
  - Dispatch: `task(..., prompt: "remove 14 legacy task files from the provided removal_list. Audit cross-references across .opencode/ for any remaining references to removed file paths. Fix any found by updating or removing the reference")`
- [ ] **post-regression** — Re-run enforcement tests. Verify no regressions. (**sub-agent**)
  - Context: {issue_number: 2176}
  - Dispatch: `task(..., prompt: "re-run enforcement tests for legacy file checks. Compare against baseline — verify no regressions")`
- [ ] **verify** — Verify implementation: ls for each removed file — confirm "No such file". grep for each removed file path across .opencode/ — confirm 0 matches. (**sub-agent**)
  - Context: {issue_number: 2176}
  - Dispatch: `task(..., prompt: "verify SC-7 implementation: ls for each removed file (confirm No such file), grep for each removed file path across .opencode/ (confirm 0 matches)")`
- [ ] **inline commit** — Commit changes. Items 6 and 7 committed together. (**inline**)
  - Command: `git rm .opencode/skills/implementation-pipeline/tasks/checkpoint-tag-create.md .opencode/skills/implementation-pipeline/tasks/sc-count-gate.md .opencode/skills/implementation-pipeline/tasks/pre-red-baseline.md .opencode/skills/implementation-pipeline/tasks/post-red-enforcement.md .opencode/skills/implementation-pipeline/tasks/post-green-enforcement.md .opencode/skills/implementation-pipeline/tasks/tdd-chaining-gate.md .opencode/skills/implementation-pipeline/tasks/pre-flight.md .opencode/skills/implementation-pipeline/tasks/pre-flight-handoff.md .opencode/skills/implementation-pipeline/tasks/sc-closeout.md .opencode/skills/implementation-pipeline/tasks/assemble-work.md .opencode/skills/implementation-pipeline/tasks/behavioral-test-remediation.md .opencode/skills/implementation-pipeline/tasks/pipeline-executor.md .opencode/skills/audit/tasks/cross-validate.md .opencode/skills/audit/tasks/resolve-models.md && git commit -m "Phase 5 Item 7: remove 14 legacy task files"`
- [ ] **DiMo audit** — Run DiMo audit on the deliverable. (**sub-agent**)
  - Context: {issue_number: 2176, sc: SC-7}
  - Dispatch: `task(..., prompt: "execute audit from audit. Read \`audit/tasks/verification-audit.md\` first")`
- [ ] **Z3 check** — Inline Z3 check on phase state after AUDIT. (**inline**)
  - Command: `.opencode/tools/solve check --state-path ./tmp/2176/state/ --contract-path .opencode/skills/implementation-pipeline/pipeline-state-machine.yaml`

### Phase 5 PR Gate

- [ ] **Create PR** — Create pull request for Phase 5 (final phase). (**sub-agent**)
  - Context: {issue_number: 2176, phase: 5}
  - Dispatch: `task(..., prompt: "execute create from pr-creation-workflow. Read \`pr-creation-workflow/tasks/create.md\` first")`
- [ ] **Wait for merge** — Phase 5 PR must be merged before post-implementation checks. (**orchestrator**)
  - Action: poll PR merge status via `gh pr view <number> --json mergedAt,state`
  - Proceed only when `mergedAt` is non-null and `state` is MERGED

---

## Post-implementation (runs after Phase 5 PR is merged)

- [ ] **Structural checks** — Run lint/typecheck across all modified files. (**sub-agent**)
  - Context: {issue_number: 2176}
  - Dispatch: `task(..., prompt: "execute checklist from finishing-a-development-branch. Read \`finishing-a-development-branch/tasks/checklist.md\` first")`
- [ ] **Verification before completion (VbC)** — Run VbC gate across all SCs. Verify each SC has a PASS verdict with appropriate evidence. (**sub-agent**)
  - Context: {issue_number: 2176}
  - Dispatch: `task(..., prompt: "execute completion from verification-before-completion. Read \`verification-before-completion/tasks/completion.md\` first")`
- [ ] **Pre-PR gate** — Verify no SC has FAIL verdict. All SCs must have PASS. (**sub-agent**)
  - Context: {issue_number: 2176}
  - Dispatch: `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`
- [ ] **Rationalization check** — Check for rationalization patterns in implementation. (**sub-agent**)
  - Context: {issue_number: 2176}
  - Dispatch: `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`
- [ ] **Audit** — Dispatch audit task for post-implementation verification. (**orchestrator**)
  - Dispatch: `task(subagent_type="general")` with {spec_local_dir: ".opencode/.issues/2176/", artifact_evidence_dir: ".opencode/.issues/2176/artifacts/"}
  - If non-clean-pass (FAIL or DONE_WITH_CONCERNS): remediate root cause, restart audit
  - On clean PASS: proceed to regression check
- [ ] **Z3 check** — Inline Z3 check on phase state after AUDIT. (**inline**)
  - Command: `.opencode/tools/solve check --state-path ./tmp/2176/state/ --contract-path .opencode/skills/implementation-pipeline/pipeline-state-machine.yaml`
- [ ] **Regression check** — Run regression tests across all modified areas. (**sub-agent**)
  - Context: {issue_number: 2176}
  - Dispatch: `task(..., prompt: "execute patterns from test-driven-development. Read \`test-driven-development/tasks/patterns.md\` first")`
- [ ] **Exec summary** — Report completion summary. (**sub-agent**)
  - Context: {issue_number: 2176}
  - Dispatch: `task(..., prompt: "execute completion from completion-core. Read \`completion-core/tasks/completion.md\` first")`

---

## Exit Criteria

The plan is considered complete when all of the following conditions are met. Each phase has its own PR gate — the next phase cannot start until the prior phase's PR is merged to trunk.

### Phase 1 Exit (SC-1, SC-8) + PR Gate

- **SC-1**: TDT updated — cross-validate, checkpoint-commit, and old per-item cycle steps removed from `implementation-pipeline/SKILL.md` TDT. New 6-step cycle (pre-regression, pre-regression-verify, red, green, post-regression, verify) + commit inline + audit DiMo present. Pipeline state machine updated to match new step transitions.
- **SC-8**: Single inline Z3 check per phase after AUDIT — `implementation-pipeline/SKILL.md` specifies inline Z3 check after AUDIT in TDT and Invocation sections. No sub-agent dispatch for Z3 checks.
- **PR Gate**: Phase 1 PR created and merged to trunk. Verified via `gh pr view <number> --json mergedAt,state`.

### Phase 2 Exit (SC-2) + PR Gate

- **SC-2**: Zero matches for `git-workflow/tasks/` across `.opencode/`. All 7 affected files updated to correct sub-skill paths.
- **PR Gate**: Phase 2 PR created and merged to trunk. Phase 4 depends on this being live.

### Phase 3 Exit (SC-3, SC-4) + PR Gate

- **SC-3**: No imperative `skill()`/`task()` instructions in task files under `.opencode/skills/*/tasks/`. All replaced with result contract instructions. Phase 5 removal targets excluded. Documentation references (e.g., "Invoked by: `skill({name: 'foo'})` → `task()`" in task file headers) preserved.
- **SC-4**: No `resolve-models`, `auditor_1`, or `auditor_2` references in SKILL.md Sub-Agent Routing sections. Phase 5 removal targets excluded.
- **PR Gate**: Phase 3 PR created and merged to trunk. Phase 5 depends on this being live.

### Phase 4 Exit (SC-5) + PR Gate

- **SC-5**: Per-item cycle collapsed to 6 steps (pre-regression, pre-regression-verify, red, green, post-regression, verify) + inline commit + DiMo audit. Writing-plans pipeline collapsed to 4 steps (analyze, research, create, validate). Legacy writing-plans task files (explore, structure, solve, self-review) updated or removed to match new pipeline.
- **PR Gate**: Phase 4 PR created and merged to trunk. Phase 5 depends on this being live.

### Phase 5 Exit (SC-6, SC-7) + PR Gate

- **SC-6**: Checkpoint tag creation is inline (orchestrator runs git commands directly, no sub-agent dispatch). Checkpoint-commit step removed from TDT and state machine.
- **SC-7**: All 14 legacy task files removed. Zero stale cross-references to removed file paths across `.opencode/`.
- **PR Gate**: Phase 5 PR created and merged to trunk. Post-implementation checks run after this merge.

### Post-implementation Gate Exit

- All post-implementation checks pass: structural checks, VbC (all SCs PASS), pre-PR gate (no FAIL verdicts), rationalization check (no rationalization detected), audit (clean PASS), regression check (no regressions), exec summary reported.

---

## Lifecycle Events

- **2026-07-30T00:13:00Z** — `plan_created` — Plan created at `.opencode/.issues/2176/plan.md` with 5 phases (8 SCs). Validation: PASS. Authorization scope: `for_plan`. Halt at: `plan_created`.
