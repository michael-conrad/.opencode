# Implementation Workflow Reference Card

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

## Pre-implementation

| Step Name | Owning Skill | Canonical Dispatch String | Description |
|-----------|-------------|--------------------------|-------------|
| `pre-regression` | test-driven-development | `task(..., prompt: "execute phase-0 task from test-driven-development")` | Run regression test patterns before RED phase |
| `pre-regression-verify` | verification-before-completion | `task(..., prompt: "execute verify task from verification-before-completion")` | Verify pre-regression results |

## RED-GREEN Daisy-Chain

| Step Name | Owning Skill | Canonical Dispatch String | Description |
|-----------|-------------|--------------------------|-------------|
| `red` | test-driven-development | `task(..., prompt: "execute red task from test-driven-development")` | Write a failing enforcement test for the SC |
| `green` | test-driven-development | `task(..., prompt: "execute green task from test-driven-development")` | Implement the change that makes the test pass |
| `post-regression` | test-driven-development | `task(..., prompt: "execute phase-4 task from test-driven-development")` | Run regression test patterns after GREEN phase |
| `verify` | verification-before-completion | `task(..., prompt: "execute verify task from verification-before-completion")` | Verify implementation against success criteria |
| `commit-inline` | (orchestrator) | Orchestrator runs `git add <files> && git commit -m "<message>"` directly — no sub-agent dispatch | Stage and commit changes |

## Post-implementation

| Step Name | Owning Skill | Canonical Dispatch String | Description |
|-----------|-------------|--------------------------|-------------|
| `audit` | audit | `task(..., prompt: "execute verification-audit DiMo investigator from audit. Read \`audit/tasks/verification-audit-investigator.md\` first")` — followed by validator, evaluator, arbiter in sequence | Adversarial audit of the deliverable |
| `z3-check` | (orchestrator) | Orchestrator runs `.opencode/tools/solve check --state-path ... --contract-path ...` directly — no sub-agent dispatch | Run Z3 constraint solver verification |
| `structural-checks` | finishing-a-development-branch | `task(..., prompt: "execute checklist task from finishing-a-development-branch")` | Run finishing checklist (lint, typecheck, etc.) |
| `pre-pr-gate` | verification-before-completion | `task(..., prompt: "execute verify task from verification-before-completion")` — reads all SC verdicts, BLOCKs if any FAIL | Verify all SC verdicts before PR creation |
| `regression-check` | test-driven-development | `task(..., prompt: "execute phase-4 task from test-driven-development")` | Final regression check before PR |
| `review-prep` | git-workflow-pr | `task(..., prompt: "execute review-prep from git-workflow-pr. Read \`git-workflow-pr/tasks/review-prep.md\` first")` | Prepare PR review context |
| `create-pr` | pr-creation-workflow | `task(..., prompt: "execute create task from pr-creation-workflow")` | Create the pull request |
| `exec-summary` | completion-core | `task(..., prompt: "execute completion task from completion-core")` | Generate completion executive summary |

## Per-Task Cycle

Each SC follows a RED → GREEN → COMMIT sequence:

| Phase | Action | Description |
|-------|--------|-------------|
| RED | Write failing test | Create an enforcement test that FAILS because the change doesn't exist yet. The test verifies the SC criterion. |
| GREEN | Make test pass | Implement the change that makes the RED test PASS. No scope creep — only the minimum change needed. |
| COMMIT | Commit test + change together | `git add <files> && git commit -m "<message>"`. The test and its implementation are committed as one atomic slice. |

**Rules:**
- Each SC gets its own RED/GREEN/COMMIT cycle — no batching
- RED must fail before GREEN begins
- COMMIT includes both the test and the implementation
- No co-author trailers during implementation commits — those are added during squash at PR time

## Coercion Rules

| Rule | Description | Effect |
|------|-------------|--------|
| DONE_WITH_CONCERNS → FAIL | A verification verdict of DONE_WITH_CONCERNS means all SCs pass but with documented concerns. For pipeline gate purposes, this is coerced to FAIL — any non-clean pass is treated as a hard block. | DONE_WITH_CONCERNS verdict is recorded in evidence but the pipeline gate sees FAIL |
| EVIDENCE_TYPE_MISMATCH → FAIL | When verification evidence does not match the SC's declared evidence type (e.g., structural evidence for a behavioral SC), the verdict is a hard FAIL. | FAIL with EVIDENCE_TYPE_MISMATCH classification — not a soft-pass or advisory |

## Artifact Retention

### Rule 1: Permanent Artifacts Never Cleaned

Artifacts under `.issues/{issue-N}/` (root repo) or `{project_root}/{path}/.issues/{issue-N}/` (submodule/sub-repo) are permanent — they survive pipeline restarts, branch switches, and PR merges. Never delete or clean these files. They serve as the authoritative audit trail for spec lifecycle, SC coverage, verification consistency, and revision re-entry protocols.

### Rule 2: Ephemeral Artifacts Cleaned at PR Merge

Artifacts under `{project_root}/tmp/{issue-N}/` are ephemeral — they are cleaned at PR merge cleanup (`git-workflow --task cleanup`). These include constraints contracts, decomposition validations, phase exit contracts, and phase-plan-validated files. Before PR merge, all permanent artifacts must be finalized and no unresolved references to ephemeral paths may remain in the lifecycle manifest.

### Rule 3: Step-Specific Pre-Cleanup

At the start of each pipeline step, clean previous-run artifacts for that step and subsequent steps to prevent stale state contamination:

| Step Label | Pre-Cleanup Action |
|------------|-------------------|
| `pre-regression` | `rm -f {project_root}/tmp/{issue-N}/artifacts/pipeline-pre-regression-*` |
| `pre-regression-verify` | `rm -f {project_root}/tmp/{issue-N}/artifacts/pipeline-pre-regression-verify-*` |
| `red` | `rm -f {project_root}/tmp/{issue-N}/artifacts/pipeline-red-*` |
| `green` | `rm -f {project_root}/tmp/{issue-N}/artifacts/pipeline-green-*` |
| `post-regression` | `rm -f {project_root}/tmp/{issue-N}/artifacts/pipeline-post-regression-*` |
| `verify` | `rm -f {project_root}/tmp/{issue-N}/artifacts/pipeline-verify-*` |
| `audit` | `rm -f {project_root}/tmp/{issue-N}/artifacts/pipeline-audit-*` |
| `z3-check` | `rm -f {project_root}/tmp/{issue-N}/artifacts/pipeline-z3-check-*` |
| `structural-checks` | `rm -f {project_root}/tmp/{issue-N}/artifacts/pipeline-structural-checks-*` |
| `pre-pr-gate` | `rm -f {project_root}/tmp/{issue-N}/artifacts/pipeline-pre-pr-gate-*` |
| `regression-check` | `rm -f {project_root}/tmp/{issue-N}/artifacts/pipeline-regression-check-*` |
