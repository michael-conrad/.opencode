# Implementation Plan — [#1537](https://github.com/michael-conrad/.opencode/issues/1537) — Include Dirty Submodule Pointers in Parent Repo Commits

- **Goal:** Ensure dirty submodule pointers are included in parent repo commits by adding pre-commit pointer checks, updating Gate 4 to allow mixed commits, and creating a dedicated sub-agent task.
- **Architecture:** Two phases. Phase 1 creates the task file and updates workflow steps (documentation concern, string evidence). Phase 2 modifies the pre-commit hook (runtime behavior concern, behavioral evidence, HIGH risk). Phase 2 depends on Phase 1.
- **PR Strategy:** stacked (single branch, all items in one PR)
- **Dependency:** After #1445 (uses the `--ff-only` and divergence reporting patterns established by #1445)

## Items

### Item 1 — Create pre-commit-pointer-check.md task file (SC-4, string)
- **Files:** `skills/git-workflow/tasks/pre-commit-pointer-check.md` (new)
- **Action:** Create task file with Purpose, Procedure, and Verification sections. The task checks `git submodule status` for dirty pointers, verifies they are staged, and warns if not.
- **Verification:** File exists and is non-empty

### Item 2 — Update implementation.md with pre-commit-pointer-check step (SC-1, string)
- **Files:** `skills/git-workflow/tasks/implementation.md`
- **Action:** Insert a step before `git add` that runs pre-commit-pointer-check to detect and stage dirty submodule pointers
- **Verification:** `grep -c 'Pre-Commit Submodule Pointer Check' implementation.md` >= 1

### Item 3 — Update pr-creation.md with submodule pointer verification step (SC-2, string)
- **Files:** `skills/git-workflow/tasks/pr-creation.md`
- **Action:** Insert a step in the squash-push procedure that verifies dirty submodule pointers are included in staged changes before squash
- **Verification:** `grep -c 'submodule pointer' pr-creation.md` >= 1

### Item 4 — Update SKILL.md to register new task (SC-5, behavioral)
- **Files:** `skills/git-workflow/SKILL.md`
- **Action:** Add `pre-commit-pointer-check` to Tasks list, Trigger Dispatch Table, and Invocation section
- **Verification:** Behavioral test: send a real-domain prompt simulating a commit with dirty submodule pointers. Assert the agent includes dirty submodule pointers without `--no-verify`.

### Item 5 — Update pre-commit Gate 4 to allow mixed commits (SC-3, behavioral, HIGH risk, depends on Items 1-4)
- **Files:** `hooks/pre-commit`
- **Action:** Change the `ALL_SUBMODULE_POINTERS=1` check so that if any staged file is NOT a submodule pointer, set `ALL_SUBMODULE_POINTERS=0` (allowing the commit)
- **Verification:** Behavioral test: commit with submodule pointer + non-submodule changes. Assert Gate 4 allows it.

## Execution

Each item is dispatched to the implementation-pipeline via `assemble-work` → `pipeline-executor`. The pipeline-executor runs the standard gate sequence for each item independently.

Items execute in dependency order: Item 1 → Item 2 → Item 3 → Item 4 → Item 5. After all items complete, global post-steps run (resolve-models → adversarial-audit ×2 → cross-validate → regression-check → review-prep → exec-summary).

## Exit Criteria
- C1: `pre-commit-pointer-check.md` exists with purpose, procedure, and verification table (SC-4)
- C2: `implementation.md` has a pre-commit-pointer-check step before `git add` (SC-1)
- C3: `pr-creation.md` has a submodule pointer verification step in squash-push (SC-2)
- C4: Pre-commit Gate 4 allows submodule pointers when non-submodule changes are also staged (SC-3)
- C5: `SKILL.md` lists `pre-commit-pointer-check` in tasks, dispatch table, and invocation section (SC-5)
- C6: All pipeline gates passed for all 5 items
