# Implementation Workflow Reference Card

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

> **Purpose:** This is a static reference card containing ALL content from the former `skills/implementation-pipeline/SKILL.md` and its enforcement directory. Plan-writer tasks (`create.md`, `research.md`, `validate.md`) read this card instead of loading the live skill. The orchestrator reads the plan (which contains baked-in dispatch strings) at execution time — no `skill()` call needed at plan-writing or execution time.

## Pipeline Step Catalog

| Step Name | Description | What It Produces |
|-----------|-------------|------------------|
| `pre-regression` | Run regression test patterns before RED phase | Test pattern evidence, baseline pass/fail |
| `pre-regression-verify` | Verify pre-regression results | Verification verdict (PASS/FAIL) |
| `red` | Write a failing enforcement test for the SC | Failing test file, RED evidence |
| `green` | Implement the change that makes the test pass | Implementation code, GREEN evidence |
| `post-regression` | Run regression test patterns after GREEN phase | Regression pass/fail evidence |
| `verify` | Verify implementation against success criteria | SC verdicts, evidence artifacts |
| `commit-inline` | Stage and commit changes | Git commit |
| `audit` | Adversarial audit of the deliverable | Audit verdict, findings report |
| `z3-check` | Run Z3 constraint solver verification | Solver pass/fail, constraint evidence |
| `structural-checks` | Run finishing checklist (lint, typecheck, etc.) | Structural check results |
| `pre-pr-gate` | Verify all SC verdicts before PR creation | Gate verdict (BLOCK if any FAIL) |
| `regression-check` | Final regression check before PR | Regression pass/fail |
| `review-prep` | Prepare PR review context | Review summary, compare URL |
| `create-pr` | Create the pull request | PR URL |
| `exec-summary` | Generate completion executive summary | Lifecycle event, summary report |

## Trigger Dispatch Table

| Step Name | Owning Skill | Canonical Dispatch String |
|-----------|-------------|--------------------------|
| `pre-regression` | test-driven-development | `task(..., prompt: "execute patterns from test-driven-development. Read \`test-driven-development/tasks/patterns.md\` first")` |
| `pre-regression-verify` | verification-before-completion | `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")` |
| `red` | test-driven-development | `task(..., prompt: "execute red from test-driven-development. Read \`test-driven-development/tasks/red.md\` first")` |
| `green` | test-driven-development | `task(..., prompt: "execute green from test-driven-development. Read \`test-driven-development/tasks/green.md\` first")` |
| `post-regression` | test-driven-development | `task(..., prompt: "execute patterns from test-driven-development. Read \`test-driven-development/tasks/patterns.md\` first")` |
| `verify` | verification-before-completion | `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")` |
| `commit-inline` | (orchestrator) | Orchestrator runs `git add <files> && git commit -m "<message>"` directly — no sub-agent dispatch |
| `audit` | audit | `task(..., prompt: "execute verification-audit DiMo investigator from audit. Read \`audit/tasks/verification-audit-investigator.md\` first")` — followed by validator, evaluator, arbiter in sequence |
| `z3-check` | (orchestrator) | Orchestrator runs `.opencode/tools/solve check --state-path ... --contract-path ...` directly — no sub-agent dispatch |
| `structural-checks` | finishing-a-development-branch | `task(..., prompt: "execute checklist from finishing-a-development-branch. Read \`finishing-a-development-branch/tasks/checklist.md\` first")` |
| `pre-pr-gate` | verification-before-completion | `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")` — reads all SC verdicts, BLOCKs if any FAIL |
| `regression-check` | test-driven-development | `task(..., prompt: "execute patterns from test-driven-development. Read \`test-driven-development/tasks/patterns.md\` first")` |
| `review-prep` | git-workflow-pr | `task(..., prompt: "execute review-prep from git-workflow-pr. Read \`git-workflow-pr/tasks/review-prep.md\` first")` |
| `create-pr` | pr-creation-workflow | `task(..., prompt: "execute create from pr-creation-workflow. Read \`pr-creation-workflow/tasks/create.md\` first")` |
| `exec-summary` | completion-core | `task(..., prompt: "execute completion from completion-core. Read \`completion-core/tasks/completion.md\` first")` |

**Audit sequence exception:** The audit is a multi-step sequence, not a single dispatch:
1. Dispatch audit task (sub-agent) — dispatch the appropriate audit task via `task(subagent_type="general")`
2. `remediate` (inline) — if non-clean-pass, remediate and restart from step 1
3. `z3-check` (inline) — orchestrator runs Z3 check after AUDIT per phase

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

## Gate Sequence

Mandatory gate order for a phase:

1. `pre-regression` — Run regression test patterns before any changes
2. `red` — Write failing enforcement test
3. `green` — Implement the change
4. `post-regression` — Run regression test patterns after changes
5. `verify` — Verify implementation against success criteria
6. `commit` — Stage and commit changes
7. `audit` — Adversarial audit of the deliverable
8. `z3-check` — Z3 constraint solver verification
9. `structural-checks` — Lint, typecheck, finishing checklist

**Rules:**
- Gates are sequential — no skipping
- Each gate must PASS before the next gate begins
- FAIL at any gate blocks the phase — remediate and restart from the failed gate
- "Continue" does NOT waive any gate

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

At the start of each pipeline step, clean previous-run artifacts for that step to prevent stale state contamination:

| Step Label | Pre-Cleanup Action |
|------------|-------------------|
| `pre-regression` | `rm -f {project_root}/tmp/{issue-N}/artifacts/pipeline-pre-regression-*` |
| `pre-regression-verify` | `rm -f {project_root}/tmp/{issue-N}/artifacts/pipeline-pre-regression-verify-*` |
| `red` | `rm -f {project_root}/tmp/{issue-N}/artifacts/pipeline-red-*` |
| `green` | `rm -f {project_root}/tmp/{issue-N}/artifacts/pipeline-green-*` |
| `post-regression` | `rm -f {project_root}/tmp/{issue-N}/artifacts/pipeline-post-regression-*` |
| `verify` | `rm -f {project_root}/tmp/{issue-N}/artifacts/pipeline-verify-*` |
| `commit-inline` | `rm -f {project_root}/tmp/{issue-N}/artifacts/pipeline-commit-inline-*` |
| `audit` | `rm -f {project_root}/tmp/{issue-N}/artifacts/pipeline-audit-*` |
| `z3-check` | `rm -f {project_root}/tmp/{issue-N}/artifacts/pipeline-z3-check-*` |
| `structural-checks` | `rm -f {project_root}/tmp/{issue-N}/artifacts/pipeline-structural-checks-*` |
| `pre-pr-gate` | `rm -f {project_root}/tmp/{issue-N}/artifacts/pipeline-pre-pr-gate-*` |
| `regression-check` | `rm -f {project_root}/tmp/{issue-N}/artifacts/pipeline-regression-check-*` |
