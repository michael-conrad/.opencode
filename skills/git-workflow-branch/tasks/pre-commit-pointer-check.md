# Task: pre-commit-pointer-check

## Purpose

Detect dirty submodule pointers before commit and ensure they are staged alongside non-submodule changes. Prevents the recurring pattern of submodule pointer drift requiring separate "pin" commits.

## Entry Criteria

- Feature branch is active
- Working tree has uncommitted changes
- `.gitmodules` exists (submodules present)

## Procedure

- [ ] 1. Check for dirty submodule pointers: `git submodule status | grep '^ '`
- [ ] 2. If dirty pointers found: `git add <submodule_path>` alongside other changes
- [ ] 3. Verify staged files include both source changes AND submodule pointer updates
- [ ] 4. If submodule pointers are dirty but not staged: warn and suggest adding them
- [ ] 5. Report result contract for orchestrator routing

## Exit Criteria

- Dirty submodule pointers are staged alongside non-submodule changes
- No `--no-verify` bypass needed — Gate 4 allows mixed commits

## Verification

| Check | Command | Expected | On Failure |
|-------|---------|----------|------------|
| Dirty pointers detected | `git submodule status \| grep '^ '` | Non-empty if dirty | No action needed |
| Pointers staged | `git diff --cached --name-only` | Submodule paths present | `git add <path>` |
| Mixed commit allowed | Gate 4 check | PASS | HALT and report |

## Cross-References

- `implementation.md` — pre-commit step before `git add`
- `pr-creation.md` — pre-push pointer verification
- `hooks/pre-commit` — Gate 4 allows mixed commits
