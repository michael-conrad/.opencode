# Implementation Plan — [#1445](https://github.com/michael-conrad/.opencode/issues/1445) — Submodule Trunk Sync Enforcement

- **Goal:** Replace hardcoded `dev` branch references with `$DEFAULT_BRANCH` resolution, add `--ff-only` enforcement, and implement autonomous divergence handling (escalate to developer only when semantic analysis determines developer intervention is needed) across all submodule trunk sync operations.
- **Architecture:** Three lifecycle points (pre-work, cleanup, mid-feature) each get the same three-layer enforcement: (1) resolve trunk branch via `$DEFAULT_BRANCH`, (2) use `--ff-only` for trunk pull, (3) on divergence, attempt autonomous resolution and only escalate to developer when semantic analysis determines intervention is needed.
- **PR Strategy:** stacked (single branch, all items in one PR)
- **Dependency:** After #1395 (uses `task(subagent_type="general")` dispatch pattern established by #1395)

## Items

### T1 — Pre-work: replace hardcoded `dev` with `$DEFAULT_BRANCH` (SC-1, behavioral)
- **Files:** `skills/git-workflow/tasks/pre-work.md` Step 3.5
- **Action:** Replace `git checkout dev` with `git checkout "$DEFAULT_BRANCH"` and `git pull origin dev` with `git pull origin "$DEFAULT_BRANCH" --ff-only`. Remove `git checkout -b main dev || true` fallback.
- **Verification:** Behavioral test: send pre-work prompt. Assert agent uses `$DEFAULT_BRANCH` (not hardcoded `dev`) for checkout and pull.

### T2 — Pre-work: `--ff-only` enforcement with autonomous divergence handling (SC-2, behavioral)
- **Files:** `skills/git-workflow/tasks/pre-work.md` Step 3.5
- **Action:** Ensure `--ff-only` is used. On `--ff-only` failure, the agent autonomously analyzes the divergence (ahead/behind counts, commit nature) and attempts resolution. Only escalate to developer if semantic analysis determines developer intervention is needed (e.g., conflicting changes, intentional divergence).
- **Verification:** Behavioral test: send pre-work prompt to a submodule with diverged history. Assert agent uses `--ff-only` and handles divergence autonomously without HALTing for developer on simple cases.

### T3 — Cleanup: replace hardcoded `dev` with `$DEFAULT_BRANCH` (SC-3, behavioral)
- **Files:** `skills/git-workflow/tasks/cleanup/branch-cleanup.md` Step 1.9
- **Action:** Replace `git checkout dev` with `git checkout "$DEFAULT_BRANCH"` and `git pull origin dev` with `git pull origin "$DEFAULT_BRANCH" --ff-only`. Remove `git checkout -b main dev || true` fallback.
- **Verification:** Behavioral test: cleanup prompt. Assert agent uses `$DEFAULT_BRANCH` (not hardcoded `dev`).

### T4 — Cleanup: `--ff-only` enforcement with autonomous divergence handling (SC-4, behavioral)
- **Files:** `skills/git-workflow/tasks/cleanup/branch-cleanup.md` Step 1.9
- **Action:** Ensure `--ff-only` is used. On divergence, agent autonomously analyzes and attempts resolution. Escalate only when semantic analysis determines developer intervention is needed.
- **Verification:** Behavioral test: cleanup prompt with diverged history. Assert `--ff-only` and autonomous divergence handling.

### T5 — Mid-feature sync: `$DEFAULT_BRANCH` and `--ff-only` (SC-5, behavioral)
- **Files:** `skills/git-workflow/tasks/submodule-sync.md`
- **Action:** Replace `git checkout dev` with `git checkout "$DEFAULT_BRANCH"` and `git pull origin dev --ff-only` with `git pull origin "$DEFAULT_BRANCH" --ff-only`. Remove hardcoded `dev` references. On divergence, agent handles autonomously.
- **Verification:** Behavioral test: mid-feature sync prompt. Assert `$DEFAULT_BRANCH` and `--ff-only`.

### T6 — Autonomous divergence handling + symbolic rules (SC-6, behavioral, depends on T1-T5)
- **Files:** All 3 task files + `skills/git-workflow/SKILL.md`
- **Action:** Extract consistent autonomous divergence handling pattern across all 3 task files. On `--ff-only` failure, agent: (a) computes ahead/behind counts, (b) analyzes commit nature, (c) attempts autonomous resolution (push local changes, reset, or rebase based on analysis), (d) only escalates to developer if semantic analysis determines intervention is needed. Add symbolic rules to SKILL.md.
- **Verification:** Behavioral test covering all 3 lifecycle points with diverged submodule history. Assert agent handles divergence autonomously and only escalates when semantic analysis determines developer intervention is needed.

### T7 — Verify no `git checkout -b main dev || true` remains (SC-7, string)
- **Files:** All 3 task files
- **Action:** Verify no `git checkout -b main dev || true` fallback remains in any of the 3 task files.
- **Verification:** `grep -rn 'git checkout -b main dev' skills/git-workflow/tasks/` returns zero.

## Execution

Each item is dispatched to the implementation-pipeline via `assemble-work` → `pipeline-executor`. The pipeline-executor runs the standard gate sequence for each item independently.

Items execute in dependency order: T1 → T2 → T3 → T4 → T5 → T6 → T7. After all items complete, global post-steps run (resolve-models → adversarial-audit ×2 → cross-validate → regression-check → review-prep → exec-summary).

## Exit Criteria
- C1: T1 implemented — pre-work submodule sync uses `$DEFAULT_BRANCH` (not hardcoded `dev`) (SC-1)
- C2: T2 implemented — pre-work uses `--ff-only` and handles divergence autonomously (SC-2)
- C3: T3 implemented — cleanup submodule trunk restore uses `$DEFAULT_BRANCH` (not hardcoded `dev`) (SC-3)
- C4: T4 implemented — cleanup uses `--ff-only` and handles divergence autonomously (SC-4)
- C5: T5 implemented — mid-feature sync uses `$DEFAULT_BRANCH` and `--ff-only` (SC-5)
- C6: T6 implemented — all divergence situations handled autonomously, escalate only when semantic analysis determines developer intervention needed (SC-6)
- C7: T7 implemented — no `git checkout -b main dev || true` fallback remains (SC-7)
- C8: All behavioral tests pass (RED → GREEN cycle complete)
- C9: All pipeline gates passed for all 7 TDD items
