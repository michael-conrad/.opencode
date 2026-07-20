## Problem

Step 0.6 in `git-workflow-pr/tasks/pr-creation/enforcement-gate.md` blocks ALL PR creation when the current repo is a submodule of another repo. This is wrong — submodule repos (like `.opencode/`) need PRs for their own changes. The only thing that should be blocked is a **parent repo** PR whose sole diff is a submodule pointer bump.

Step 0.5 already handles that correctly.

## Fix

Remove Step 0.6 entirely. The enforcement gate file should go from Step 0.5 directly to Step 1.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|-------------------|
| SC-1 | `enforcement-gate.md` has no Step 0.6 or submodule context detection gate | structural | Grep for `show-superproject-working-tree` in `enforcement-gate.md` returns no match |
| SC-2 | Step 0.5 (submodule-bump-only parent PR gate) is preserved | structural | Step 0.5 content remains in the file |
| SC-3 | Submodule repos can create PRs normally | behavioral | `opencode run` with prompt to create PR from within `.opencode` submodule; `assert_semantic` verifies PR creation proceeds |

## Evidence

- `.opencode#1938` was originally authored with the wrong approach (block all submodule PRs)
- The correct approach is: only block parent repo submodule-bump-only PRs (Step 0.5)
- Step 0.6 was already removed from the file and the working tree was restored to clean state
