# Task: pre-commit-pointer-check

## Purpose

Detect dirty submodule pointers before commit and ensure they are staged AND COMMITTED alongside non-submodule changes in the same commit. Prevents the recurring pattern of submodule pointer drift requiring separate "pin" commits.

The submodule pointer rides ALONGSIDE the next real root-repo change on a feature branch — it is staged and committed together with the real change in the same commit, is never DROPPED, and is never committed in a standalone pointer-only commit/PR.

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

## Ordering-Gate Role (Advisory — No Blocking Authority)

This task runs pre-commit — before any in-scope submodule PR merge state can be verified — and its stale-pointer gate legally proceeds under `SKIP_STALE_POINTER_CHECK=1`, so it cannot serve as a blocking check for stacked-PR ordering. Its role relative to the stacked-PR ordering gate is advisory/consistency only: it exercises **no blocking authority** over parent stacked PR creation. The sole authoritative blocking check is the ordering gate at `pr-creation/enforcement-gate` (Step 0.75).

**AUTHORITY:** Spec `.opencode/.issues/2431/spec.md` R-9 — this site carries an advisory/consistency role for the ordering gate and SHALL NOT block PR creation.

## Cross-References

- `implementation.md` — pre-commit step before `git add`
- `pr-creation.md` — pre-push pointer verification
- `hooks/pre-commit` — Gate 4 allows mixed commits
