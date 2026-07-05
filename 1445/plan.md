# Implementation Plan — [#1445](https://github.com/michael-conrad/.opencode/issues/1445) — Submodule Trunk Sync Enforcement

- **Goal:** Add `--ff-only` enforcement, `main` branch creation fallback, and actionable HALT-on-divergence behavior to all submodule trunk sync operations across pre-work, cleanup, and mid-feature sync.
- **Architecture:** Three lifecycle points (pre-work, cleanup, mid-feature) each get the same three-layer enforcement: (1) create `main` branch from default branch if missing, (2) use `--ff-only` for trunk pull, (3) HALT with actionable information on divergence. Enforcement is encoded in task files and SKILL.md symbolic rules.
- **PR Strategy:** stacked (single branch, all items in one PR)
- **Dependency:** After #1395 (uses `task(subagent_type="general")` dispatch pattern established by #1395)

## Items

### T1 — Pre-work main branch creation (SC-1, behavioral)
- **Files:** `skills/git-workflow/tasks/pre-work.md` Step 3.5
- **Action:** After `git checkout dev`, add `git checkout -b main dev || true` fallback (create `main` from `dev` if missing)
- **Verification:** Behavioral test: send pre-work prompt to a submodule setup where `main` branch is missing. Assert the agent creates `main` from the default branch.

### T2 — Pre-work `--ff-only` enforcement (SC-2, behavioral)
- **Files:** `skills/git-workflow/tasks/pre-work.md` Step 3.5
- **Action:** Change `git pull origin dev` to `git pull origin dev --ff-only`. Add HALT-on-failure with actionable message.
- **Verification:** Behavioral test: send pre-work prompt to a submodule with diverged history. Assert the agent uses `--ff-only` and HALTs on non-fast-forward.

### T3 — Cleanup main branch creation (SC-3, behavioral)
- **Files:** `skills/git-workflow/tasks/cleanup/branch-cleanup.md` Step 1.9
- **Action:** Add `git checkout -b main dev || true` fallback
- **Verification:** Behavioral test: cleanup prompt with missing `main` branch. Assert agent creates it.

### T4 — Cleanup `--ff-only` enforcement (SC-4, behavioral)
- **Files:** `skills/git-workflow/tasks/cleanup/branch-cleanup.md` Step 1.9
- **Action:** Change `git pull origin dev` to `git pull origin dev --ff-only`. Add HALT-on-failure with actionable message.
- **Verification:** Behavioral test: cleanup prompt with diverged history. Assert `--ff-only` and HALT.

### T5 — Mid-feature sync `--ff-only` (SC-5, behavioral)
- **Files:** `skills/git-workflow/tasks/submodule-sync.md`
- **Action:** Add `--ff-only` flag, add `main` branch creation fallback, add divergence reporting
- **Verification:** Behavioral test: mid-feature sync prompt with diverged history. Assert `--ff-only` and divergence report.

### T6 — Actionable divergence reporting and symbolic rules (SC-6, behavioral, depends on T1-T5)
- **Files:** All 3 task files + `skills/git-workflow/SKILL.md`
- **Action:** Extract consistent divergence reporting pattern across all 3 task files. Each HALT-on-divergence must include: submodule path, ahead/behind commit counts, suggested resolution, and HALT for developer consultation. Add symbolic rules to SKILL.md.
- **Verification:** Behavioral test covering all 3 lifecycle points with diverged submodule history. Assert agent reports: (a) which submodule diverged, (b) ahead/behind commits, (c) suggested resolution, (d) HALTs.

## Execution

Each item is dispatched to the implementation-pipeline via `assemble-work` → `pipeline-executor`. The pipeline-executor runs the standard gate sequence for each item independently.

Items execute in dependency order: T1 → T2 → T3 → T4 → T5 → T6. After all items complete, global post-steps run (resolve-models → adversarial-audit ×2 → cross-validate → regression-check → review-prep → exec-summary).

## Exit Criteria
- C1: T1 implemented — pre-work creates `main` branch in submodules from default branch if missing (SC-1)
- C2: T2 implemented — pre-work uses `--ff-only` for submodule trunk pull and HALTs on non-fast-forward (SC-2)
- C3: T3 implemented — cleanup submodule trunk restore creates `main` branch if missing (SC-3)
- C4: T4 implemented — cleanup submodule trunk restore uses `--ff-only` and HALTs on non-fast-forward (SC-4)
- C5: T5 implemented — mid-feature submodule sync uses `--ff-only` and reports divergence (SC-5)
- C6: T6 implemented — all divergence/conflict situations report actionable information and HALT for developer consultation (SC-6)
- C7: All 6 behavioral tests pass (RED → GREEN cycle complete)
- C8: All pipeline gates passed for all 6 TDD items
