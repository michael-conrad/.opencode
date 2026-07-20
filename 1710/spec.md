## Problem

AI agents routinely bypass the git-workflow pre-work task when performing submodule sync operations during release PR creation. Root causes:

1. **No mandatory dispatch check**: The pre-work task exists in git-workflow SKILL.md but there is no enforcement mechanism that requires agents to dispatch to it before performing submodule operations. Agents inline `git submodule foreach` and bare `git pull` instead.

2. **Ambiguous submodule sync path**: git-workflow has both `pre-work` (setup) and `submodule-sync` (mid-feature) tasks. Agents performing a release sync have no clear routing rule about which task to use.

3. **No remote-trunk verification gate**: Tasks that update submodule pointers have no mandatory step to verify local vs remote HEAD SHA before committing the pointer. Agents commit stale SHAs without detection.

4. **No release-specific workflow**: There is no dedicated release-PR workflow that mandates: verify all submodules at remote trunk tip -> commit pointers -> create PR. The existing pr-creation and review-prep workflows assume feature branches, not releases.

## Scope

- Add a pre-commit enforcement hook that blocks parent-repo commits containing submodule pointer changes unless the SHA matches the remote trunk tip
- Add a release-pr task to git-workflow with submodule trunk-tip verification
- Add routing rules to git-workflow SKILL.md for release PRs

## Affected Files

- `.opencode/skills/git-workflow/SKILL.md` — add release PR trigger dispatch entry, add release-pr task
- `.opencode/skills/git-workflow/tasks/pr-creation/create-pr.md` — add --release mode with submodule SHA verification
- `.opencode/guidelines/` — add enforcement rule for submodule pointer commits
- `.opencode/hooks/` — add pre-commit gate for stale submodule pointers

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | Pre-commit hook blocks submodule-pointer commits where local SHA != remote master SHA | behavioral | bash test creating stale pointer, attempting commit, verifying block |
| SC-2 | git-workflow SKILL.md has a release-pr trigger dispatch entry in the Trigger Dispatch Table | string | grep for release-pr in SKILL.md |
| SC-3 | create-pr task has a --release mode section with submodule SHA verification step | string | grep for --release or release mode in create-pr.md |
| SC-4 | Agent tasked with release PR dispatches pre-work before any submodule operations | behavioral | opencode-cli run with release PR prompt, verify pre-work dispatch in stderr |

## Out of Scope

- Changing how existing hooks work for non-submodule commits
- Adding CI workflows (no CI infrastructure exists)