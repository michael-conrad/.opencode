---
plan_schema_version: "1.0"
issue: 2309
title: "Correct stale 'Guard checks' docstring in tools/session-init"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 1
lifecycle_events:
  - timestamp: 2026-08-21T05:27:28Z
    event: plan_created
    plan_path: .opencode/.issues/2309/plan.md
    phase_count: 1
dispatch:
  - phase: 1
    skill: test-driven-development
    task: red
  - phase: 1
    skill: test-driven-development
    task: green
  - phase: 1
    skill: verification-before-completion
    task: verify
---

# Implementation Plan — #2309 — Correct Stale 'Guard checks' Docstring

**Issue URL:** https://github.com/michael-conrad/.opencode/issues/2309

**Goal:** Correct the stale "Guard checks" docstring in `tools/session-init` so it no longer references the removed `dev branch` and `.worktrees/main/` guard checks while preserving the still-current `.env gitignore` guard check.

**Architecture:** Documentation-only correction to a single docstring block in `tools/session-init` (lines 35-38). No runtime behavior, function signatures, or output format change. The docstring currently enumerates three guard checks; the first two reference behavior removed in commits bb2851f0 (#1657) and 77459166 (#1659). The edit removes the two stale lines and keeps the `.env gitignore` line intact. No code logic is changed, and no `$DEFAULT_BRANCH`-based branch-creation guard check is re-introduced.

**Files:**
- `.opencode/tools/session-init` — the "Guard checks" docstring block (lines 35-38)

---

## Phase Table

| Phase | Skill | Task | Target | SCs | Depends On |
|-------|-------|------|--------|-----|------------|
| 1 — Correct stale docstring | `test-driven-development` | `red` / `green` | `.opencode/tools/session-init` docstring (lines 35-38) | SC-1, SC-2, SC-3 | — |

---

## Phase Details

### Phase 1 — Correct stale docstring

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` / `green` |
| Target | `.opencode/tools/session-init` "Guard checks" docstring (lines 35-38) |
| SCs | SC-1, SC-2, SC-3 |
| Depends On | — |

**Context:**
```yaml
files_to_modify:
  - .opencode/tools/session-init
docstring_lines: 35-38
stale_lines_to_remove:
  - "- dev branch: Create from origin/dev or main/master if missing"
  - "- .worktrees/main/: Bootstrap worktree layout if not set up"
preserve_line:
  - "- .env gitignore: Warn if .env exists but is not in .gitignore"
sc_ids: [SC-1, SC-2, SC-3]
```

---

## Pre-Implementation Steps

- [ ] 1. **Coherence gate (**inline**).** Verify the spec, structure artifact, and dependency contract are internally consistent for issue #2309. Confirm all three SCs (SC-1, SC-2, SC-3) map to Phase 1, the phase DAG has no edges, and the dependency contract (`phase_1_complete` precondition for `pr_created`) is satisfied. **→ all SCs**
- [ ] 2. **Baseline check (**inline**).** Verify the current repo state: the working tree is clean on the trunk at remote tracking tip, the feature branch exists, and the submodule pointer is consistent. Confirm the "Guard checks" docstring in `tools/session-init` currently contains the stale `dev branch`, `.worktrees/main/`, and `.env gitignore` lines via `grep`. **→ all SCs**

---

## Phase 1 — Correct stale docstring

**Concern:** docstring-accuracy

**Files:**
- `.opencode/tools/session-init` (lines 35-38)

**SCs:** SC-1, SC-2, SC-3

**Dependencies:** None

**Entry Conditions:**
- Spec #2309 is approved (`approved-for-pr` authorization scope)
- Feature branch exists
- Pre-implementation steps (coherence gate, baseline check) completed
- The stale `dev branch` and `.worktrees/main/` lines are confirmed present in the docstring

**Exit Conditions:**
- The docstring no longer references `dev branch` or `origin/dev` (SC-1)
- The docstring no longer references `.worktrees/main/` (SC-2)
- The docstring still references `.env gitignore` (SC-3)

---

### Item 1 (SC-1) — Remove the stale `dev branch` line

- [ ] 3. **RED (**sub-agent**).** Dispatch `test-driven-development` → `task(..., prompt: "execute red task from test-driven-development")`. Write a structural assertion that the "Guard checks" docstring in `tools/session-init` still contains `dev branch` or `origin/dev`. Confirm the assertion FAILS (the stale line is currently present). **→ SC-1**
- [ ] 4. **GREEN (**sub-agent**).** Dispatch `test-driven-development` → `task(..., prompt: "execute green task from test-driven-development")`. Edit the docstring in `tools/session-init` to remove the stale `- dev branch: Create from origin/dev or main/master if missing` line (line 36). **→ SC-1**
- [ ] 5. **Post-regression (**sub-agent**).** Dispatch `test-driven-development` → `task(..., prompt: "execute phase-4 task from test-driven-development")`. Run regression test patterns after the GREEN change. **→ SC-1**
- [ ] 6. **Verify (**sub-agent**).** Dispatch `verification-before-completion` → `task(..., prompt: "execute verify task from verification-before-completion")`. Verify against SC-1: `grep -n 'dev branch\|origin/dev' .opencode/tools/session-init` returns no match in the docstring. **→ SC-1**
- [ ] 7. **Commit (**inline**).** Orchestrator runs `git add .opencode/tools/session-init && git commit -m "Correct stale 'dev branch' docstring line in tools/session-init"`. Commit the change as one atomic slice. **→ SC-1**

### Item 2 (SC-2) — Remove the stale `.worktrees/main/` line

- [ ] 8. **RED (**sub-agent**).** Dispatch `test-driven-development` → `task(..., prompt: "execute red task from test-driven-development")`. Write a structural assertion that the "Guard checks" docstring in `tools/session-init` still contains `.worktrees/main/`. Confirm the assertion FAILS (the stale line is currently present). **→ SC-2**
- [ ] 9. **GREEN (**sub-agent**).** Dispatch `test-driven-development` → `task(..., prompt: "execute green task from test-driven-development")`. Edit the docstring in `tools/session-init` to remove the stale `- .worktrees/main/: Bootstrap worktree layout if not set up` line (line 37). **→ SC-2**
- [ ] 10. **Post-regression (**sub-agent**).** Dispatch `test-driven-development` → `task(..., prompt: "execute phase-4 task from test-driven-development")`. Run regression test patterns after the GREEN change. **→ SC-2**
- [ ] 11. **Verify (**sub-agent**).** Dispatch `verification-before-completion` → `task(..., prompt: "execute verify task from verification-before-completion")`. Verify against SC-2: `grep -n 'worktrees/main' .opencode/tools/session-init` returns no match in the docstring. **→ SC-2**
- [ ] 12. **Commit (**inline**).** Orchestrator runs `git add .opencode/tools/session-init && git commit -m "Correct stale '.worktrees/main/' docstring line in tools/session-init"`. Commit the change as one atomic slice. **→ SC-2**

### Item 3 (SC-3) — Preserve the `.env gitignore` line

- [ ] 13. **RED (**sub-agent**).** Dispatch `test-driven-development` → `task(..., prompt: "execute red task from test-driven-development")`. Write a structural assertion that the "Guard checks" docstring in `tools/session-init` still contains `.env gitignore`. Confirm the assertion PASSES (the line is present and must be preserved). **→ SC-3**
- [ ] 14. **GREEN (**sub-agent**).** Dispatch `test-driven-development` → `task(..., prompt: "execute green task from test-driven-development")`. Ensure the `.env gitignore` line (`- .env gitignore: Warn if .env exists but is not in .gitignore`, line 38) remains in the docstring while the stale lines are removed. **→ SC-3**
- [ ] 15. **Post-regression (**sub-agent**).** Dispatch `test-driven-development` → `task(..., prompt: "execute phase-4 task from test-driven-development")`. Run regression test patterns after the GREEN change. **→ SC-3**
- [ ] 16. **Verify (**sub-agent**).** Dispatch `verification-before-completion` → `task(..., prompt: "execute verify task from verification-before-completion")`. Verify against SC-3: `grep -n '.env gitignore' .opencode/tools/session-init` still matches. **→ SC-3**
- [ ] 17. **Commit (**inline**).** Orchestrator runs `git add .opencode/tools/session-init && git commit -m "Preserve '.env gitignore' docstring line in tools/session-init"`. Commit the change as one atomic slice. **→ SC-3**

---

#### Phase 1 VbC

- [ ] 18. **VbC (**clean-room**).** Verify all three SC verdicts: SC-1 (`grep -n 'dev branch\|origin/dev'` no match), SC-2 (`grep -n 'worktrees/main'` no match), SC-3 (`grep -n '.env gitignore'` match), and run `uv run pytest .opencode/tests/` for regression. **→ SC-1, SC-2, SC-3**

**Concern transition:** Leaving docstring correction. This is the only phase — no downstream phase depends on it.

---

## Post-Implementation Steps

- [ ] 19. **Structural checks (**sub-agent**).** Dispatch `finishing-a-development-branch` → `task(..., prompt: "execute checklist task from finishing-a-development-branch")`. Run the finishing checklist (lint, typecheck, etc.). **→ all SCs**
- [ ] 20. **Verification audit (**sub-agent**).** Dispatch `audit` → `task(..., prompt: "execute verification-audit DiMo investigator from audit. Read \`audit/tasks/verification-audit-investigator.md\` first")`, followed by validator, evaluator, and arbiter in sequence. Adversarially audit the deliverable against the SCs. **→ all SCs**
- [ ] 21. **Cross-validate (**clean-room**).** Independently re-verify the deliverable and any audit-modified content against SC-1, SC-2, and SC-3 using the documented grep checks. **→ all SCs**
- [ ] 22. **Z3 check (**inline**).** Orchestrator runs `.opencode/tools/solve check --state-path .opencode/.issues/2309/artifacts/state-analysis.yaml --contract-path .opencode/.issues/2309/dependency-contract.yaml` to confirm the dependency contract is satisfied. **→ all SCs**
- [ ] 23. **Pre-PR gate (**sub-agent**).** Dispatch `verification-before-completion` → `task(..., prompt: "execute verify task from verification-before-completion")`. Reads all SC verdicts; BLOCKs if any FAIL. **→ all SCs**
- [ ] 24. **Regression check (**sub-agent**).** Dispatch `test-driven-development` → `task(..., prompt: "execute phase-4 task from test-driven-development")`. Run the final regression check before PR. **→ all SCs**
- [ ] 25. **Review prep (**sub-agent**).** Dispatch `git-workflow-pr` → `task(..., prompt: "execute review-prep from git-workflow-pr. Read \`git-workflow-pr/tasks/review-prep.md\` first")`. Prepare PR review context. **→ all SCs**
- [ ] 26. **Create PR (**sub-agent**).** Dispatch `git-workflow-pr` → `task(..., prompt: "execute create task from git-workflow-pr")`. Create the pull request (stacked strategy, single branch). **→ all SCs**
- [ ] 27. **Exec summary (**sub-agent**).** Dispatch `completion-core` → `task(..., prompt: "execute completion task from completion-core")`. Generate the completion executive summary and append the lifecycle event. **→ all SCs**

---

## Exit Criteria

- [ ] C1. The "Guard checks" docstring in `tools/session-init` no longer references a `dev branch` guard check or any `origin/dev` branch-creation behavior (SC-1).
- [ ] C2. The "Guard checks" docstring in `tools/session-init` no longer references the `.worktrees/main/` worktree bootstrap (SC-2).
- [ ] C3. The "Guard checks" docstring in `tools/session-init` still references the `.env gitignore` guard check (SC-3).
- [ ] C4. The fix is limited to `tools/session-init`; `scripts/validate-submodule-refs.sh` and `scripts/session_context_triggers.py` are unmodified (R-4).
- [ ] C5. No `$DEFAULT_BRANCH`-based branch-creation guard check is re-introduced (R-5).
- [ ] C6. All three SCs have a clean PASS verdict from the pre-PR gate; the dependency contract is SAT; the PR is created.
