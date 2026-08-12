---
plan_schema_version: "1.0"
issue: 2201
title: "Create gb-cli skill for GitBucket CLI operations"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 6
dispatch:
  - test-driven-development
  - verification-before-completion
  - audit
  - finishing-a-development-branch
  - git-workflow-pr
  - completion-core
lifecycle_events:
  - timestamp: 2026-08-12T23:39:24Z
    event: plan_created
    plan_path: .opencode/.issues/2201/plan.md
    phase_count: 6
---

# Implementation Plan — #2201 — Create gb-cli skill for GitBucket CLI operations

**Issue URL:** https://github.com/michael-conrad/.opencode/issues/2201

**Goal:** Create a standalone `gb-cli` skill at `.opencode/skills/gb-cli/` providing workflow-based task cards for the full `gb` CLI command surface, adapted from the `gh-cli` reference template and validated against a local test GitBucket instance, then wire it into the existing skill deck and adapt `gitbucket-api` to delegate to it.

**Architecture:** A new routing-only skill card (`SKILL.md`) with 11 workflow-based task cards, created using the `gh-cli` skill as a reference template. Phase 1 investigates workflow applicability against a local test GitBucket instance, producing a per-workflow assessment artifact. Phases 2-3 create the skill card and task cards. Phase 4 adds cross-references to existing skills. Phase 5 adds behavioral enforcement tests. Phase 6 adapts the `gitbucket-api` sub-skill to delegate workflow-level operations to `gb-cli`.

**Files:**
- `.opencode/skills/gb-cli/` (new skill directory)
- `.opencode/skills/git-workflow/SKILL.md` (cross-reference)
- `.opencode/skills/issue-operations/SKILL.md` (cross-reference)
- `.opencode/skills/issue-operations/platforms/gitbucket-api/SKILL.md` (delegation)
- `.opencode/skills/issue-operations/platforms/gitbucket-api/tasks/` (7 task files adapted)
- `.opencode/skills/release-promoter/SKILL.md` (cross-reference)
- `.opencode/AGENTS.md` (gb CLI tool documentation)
- `.opencode/tests-v2/behaviors/` (3 new behavioral tests)
- `.opencode/.issues/2201/artifacts/gb-workflow-applicability.yaml` (investigation artifact)

**Dispatch:** `test-driven-development` (red/green per-item cycles), `verification-before-completion` (verify), `audit` (post-implementation), `finishing-a-development-branch` (structural checks), `git-workflow-pr` (review-prep, create-pr), `completion-core` (exec-summary)

---

## Blast Radius

Affected files and impact zones from the blast-radius artifact:

| Zone | Files | Impact |
|------|-------|--------|
| New skill | `.opencode/skills/gb-cli/SKILL.md`, `.opencode/skills/gb-cli/tasks/*.md` (11 task cards) | New routing-only skill; additive, no existing skill removed |
| Cross-references | `.opencode/skills/git-workflow/SKILL.md`, `.opencode/skills/issue-operations/SKILL.md`, `.opencode/skills/release-promoter/SKILL.md`, `.opencode/AGENTS.md` | Minor — gb-cli reference entries added |
| Delegation | `.opencode/skills/issue-operations/platforms/gitbucket-api/SKILL.md` + 7 task files | Duplicated gb CLI command tables removed/replaced with gb-cli cross-references; platform routing retained |
| Behavioral tests | `.opencode/tests-v2/behaviors/gb-cli-skill-discovery.sh`, `gb-cli-auth-check.sh`, `gb-cli-merge-prohibition.sh` | 3 new artifact-only generator scripts |
| Investigation artifact | `.opencode/.issues/2201/artifacts/gb-workflow-applicability.yaml` | Per-workflow applicability assessment (SC-17) |

> **Compliance:** All SCs must pass before completion. Partial implementation is not permitted. Each item is daisy-chained — item N's commit is precondition for item N+1's RED.

> **One step at a time.** Execute exactly one step. Report progress. Wait for instruction before the next step.

> **Step status:** Report `[item N] [PASS|FAIL]` after each step. If FAIL, report blocker and halt.

> **Self-Remediation Protocol:** If a step FAILs: diagnose root cause, fix the deliverable, re-verify. If the fix requires spec revision, update the spec and re-enter the plan. Escalate only after remediation failure.

> **Enforcement gate:** All SCs must pass before this plan is complete.

---

## Pre-Implementation Steps

- [ ] 1. **Coherence gate (**inline**).** Verify the spec is coherent: all 20 SCs map to exactly one phase, the phase DAG is acyclic, and the dependency contract is SAT (verified by `solve-output.yaml` — `solve_status: SAT`, plan length 6). If any check fails, HALT and report.
- [ ] 2. **Baseline check (**inline**).** Verify the feature branch exists, the working tree is clean, and the `.opencode` submodule is on `$DEFAULT_BRANCH` at the remote tracking tip. Verify `gb --version` reports `>= 0.6.1` and `gb auth status` succeeds. Verify no existing `gb-cli` skill directory in `.opencode/skills/`. If any check fails, HALT and report.

---

## Phase Table

| Phase | Skill | Task | Target | SCs | Depends On |
|-------|-------|------|--------|-----|------------|
| 1 — Local GitBucket investigation | `test-driven-development` | `green` | `.opencode/.issues/2201/artifacts/gb-workflow-applicability.yaml` | SC-17 | — |
| 2 — Skill directory and SKILL.md creation | `test-driven-development` | `green` | `.opencode/skills/gb-cli/SKILL.md` | SC-1, SC-2, SC-3, SC-4, SC-5 | 1 |
| 3 — Task cards creation | `test-driven-development` | `green` | `.opencode/skills/gb-cli/tasks/` | SC-6, SC-7, SC-8, SC-9, SC-11, SC-12, SC-13, SC-14, SC-15, SC-16 | 2 |
| 4 — Cross-reference integration | `test-driven-development` | `green` | 4 SKILL.md files + `.opencode/AGENTS.md` | SC-18 | 2 |
| 5 — Behavioral enforcement tests | `test-driven-development` | `red` | `.opencode/tests-v2/behaviors/` | SC-10 | 2, 3 |
| 6 — gitbucket-api adaptation | `test-driven-development` | `green` | `.opencode/skills/issue-operations/platforms/gitbucket-api/` | SC-19, SC-20 | 2, 3 |

---

## Phase Details

### Phase 1 — Local GitBucket Investigation

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `green` |
| Target | `.opencode/.issues/2201/artifacts/gb-workflow-applicability.yaml` |
| SCs | SC-17 |
| Depends On | — |

**Context:**
```yaml
investigation_target: "local test GitBucket instance"
reference_template: "gh-cli skill workflows"
expected_discard: [do-release, run-ci-cd, manage-secrets, manage-codespaces, manage-org, manage-gists, manage-keys, manage-projects, manage-aliases]
expected_add: [manage-milestones, manage-repo, api-requests]
artifact_path: ".opencode/.issues/2201/artifacts/gb-workflow-applicability.yaml"
```

### Phase 2 — Skill Directory and SKILL.md Creation

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `green` |
| Target | `.opencode/skills/gb-cli/SKILL.md` |
| SCs | SC-1, SC-2, SC-3, SC-4, SC-5 |
| Depends On | 1 |

**Context:**
```yaml
skill_dir: ".opencode/skills/gb-cli"
frontmatter:
  name: gb-cli
  description: "agent-intent format, <= 1024 chars"
  license: MIT
  compatibility: opencode
template: "routing-only (no procedure text, only Workflows section with dispatch contracts)"
headers: [SPDX-FileCopyrightText, Provenance, Co-authored with AI]
```

### Phase 3 — Task Cards Creation

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `green` |
| Target | `.opencode/skills/gb-cli/tasks/` |
| SCs | SC-6, SC-7, SC-8, SC-9, SC-11, SC-12, SC-13, SC-14, SC-15, SC-16 |
| Depends On | 2 |

**Context:**
```yaml
task_cards: [authenticate, create-pr, triage-issues, review-pr, manage-repo, manage-labels, manage-milestones, search-investigate, api-requests, completion, common-workflows]
canonical_sections: [Purpose, Task Discipline, Entry Criteria, Procedure, Exit Criteria, Result Contract]
auth_entry_criterion: "gb auth status verification in all auth-dependent task cards"
merge_prohibition: "gb pr merge CRITICAL VIOLATION block in create-pr and review-pr"
headers: [SPDX-FileCopyrightText, Provenance, Co-authored with AI]
```

### Phase 4 — Cross-Reference Integration

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `green` |
| Target | `.opencode/skills/git-workflow/SKILL.md`, `.opencode/skills/issue-operations/SKILL.md`, `.opencode/skills/issue-operations/platforms/gitbucket-api/SKILL.md`, `.opencode/skills/release-promoter/SKILL.md`, `.opencode/AGENTS.md` |
| SCs | SC-18 |
| Depends On | 2 |

**Context:**
```yaml
cross_reference_targets: [git-workflow, issue-operations, gitbucket-api, release-promoter]
agents_md_section: "gb CLI Tool — GitBucket Operations"
```

### Phase 5 — Behavioral Enforcement Tests

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/tests-v2/behaviors/gb-cli-skill-discovery.sh`, `gb-cli-auth-check.sh`, `gb-cli-merge-prohibition.sh` |
| SCs | SC-10 |
| Depends On | 2, 3 |

**Context:**
```yaml
test_scripts:
  - gb-cli-skill-discovery.sh
  - gb-cli-auth-check.sh
  - gb-cli-merge-prohibition.sh
harness: "bash .opencode/tests-v2/with-test-home opencode run '<message>'"
timeout: ">= 600s"
```

### Phase 6 — gitbucket-api Adaptation

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `green` |
| Target | `.opencode/skills/issue-operations/platforms/gitbucket-api/SKILL.md` + 7 task files |
| SCs | SC-19, SC-20 |
| Depends On | 2, 3 |

**Context:**
```yaml
delegation_target: "gb-cli task cards"
task_files: [tool-detection, mcp-operations, session-integration, issue-operations, error-recovery, label-operations, repository-operations]
retain: "platform-specific routing logic (owner/repo resolution, auth verification, error recovery)"
```

---

## Exit Criteria

- [ ] C1. `.opencode/skills/gb-cli/SKILL.md` exists with `name: gb-cli` frontmatter, agent-intent description ≤ 1024 chars, routing-only template (SC-1, SC-2, SC-3, SC-4, SC-5)
- [ ] C2. 11 task cards exist in `.opencode/skills/gb-cli/tasks/` with canonical 6-section structure, auth entry criteria, merge prohibition, and required headers (SC-6, SC-7, SC-8, SC-9, SC-11, SC-12, SC-13, SC-14, SC-15, SC-16)
- [ ] C3. `gb-cli` appears in `<available_skills>` after deployment (SC-10)
- [ ] C4. Cross-references to `gb-cli` appear in git-workflow, issue-operations, gitbucket-api, and release-promoter SKILL.md files (SC-18)
- [ ] C5. Phase 1 investigation artifact exists with per-workflow applicability assessment (SC-17)
- [ ] C6. `gitbucket-api` delegates to `gb-cli` for workflow-level operations; 7 task files have duplicated gb CLI command tables removed/replaced (SC-19, SC-20)

---

## Post-Implementation Steps

- [ ] 3. **Structural checks (**sub-agent**).** Dispatch `task(..., prompt: "execute checklist task from finishing-a-development-branch")`. Run lint, typecheck, and markdown format checks on all modified files.
- [ ] 4. **Verification (**clean-room**).** Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Verify all 20 SCs against their declared evidence types. Any FAIL blocks completion.
- [ ] 5. **Audit (**clean-room**).** Dispatch `task(..., prompt: "execute verification-audit DiMo investigator from audit. Read \`audit/tasks/verification-audit-investigator.md\` first")`, followed by validator, evaluator, arbiter in sequence. Adversarial audit of the deliverable.
- [ ] 6. **Z3 check (**inline**).** Run `.opencode/tools/solve check --state-path ... --contract-path ...` to verify phase state transitions.
- [ ] 7. **Pre-PR gate (**clean-room**).** Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Reads all SC verdicts, BLOCKs if any FAIL.
- [ ] 8. **Regression check (**sub-agent**).** Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. Final regression check before PR.
- [ ] 9. **Review-prep (**sub-agent**).** Dispatch `task(..., prompt: "execute review-prep from git-workflow-pr. Read \`git-workflow-pr/tasks/review-prep.md\` first")`. Prepare PR review context.
- [ ] 10. **Create PR (**sub-agent**).** Dispatch `task(..., prompt: "execute create task from git-workflow-pr")`. Create the pull request.
- [ ] 11. **Exec summary (**sub-agent**).** Dispatch `task(..., prompt: "execute completion task from completion-core")`. Generate completion executive summary.
