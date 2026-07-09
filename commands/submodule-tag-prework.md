# submodule-tag-prework

Tag submodules at trunk tip BEFORE feature branch creation. Uses the unified tag convention from `git-workflow/SKILL.md` §Tag Convention.

**Suffix Rule:** Tag suffix MUST be derived from submodule directory name in `.gitmodules` (e.g., `.opencode` → `-opencode`). DO NOT use issue title, phase name, or any ad-hoc string.

**Tag Format:** `<parent-repo>/<issue-number>-<submodule>` (e.g., `opencode-config/950-opencode`)

## Procedure

1. `git checkout "$DEFAULT_BRANCH" && git pull` — Sync main branch to trunk tip
2. For each submodule path in `.gitmodules`:
   a. `cd <path> && git checkout "$DEFAULT_BRANCH" && git pull` — Sync submodule to trunk tip
   b. Capture SHA: `CURRENT_SHA=$(git rev-parse HEAD)`
   c. Resolve suffix: `SUBMODULE_SUFFIX=$(basename <path>)` (e.g., `.opencode` → `-opencode`)
   d. **Idempotent check:** `git tag --points-at "$CURRENT_SHA" | grep -q "<parent-repo>/$ISSUE-"` — if match exists, skip tagging (duplicate prevention)
   e. `git tag -a "<parent-repo>/<issue-number>-<submodule>" -m "Pre-work: <path> at trunk tip for issue #<issue-number>"` — Tag BEFORE branch creation
   f. `git push origin "<parent-repo>/<issue-number>-<submodule>"`
   g. Verify: `git ls-remote --tags origin "<parent-repo>/<issue-number>-<submodule>"` shows the SHA

## Tag Naming Reference

| Component | Value | Example |
|-----------|-------|---------|
| `<parent-repo>` | Determined from parent repo name | `opencode-config` |
| `<issue-number>` | Current issue number | `950` |
| `<submodule>` | Submodule directory name from `.gitmodules` | `opencode` |
| Full tag | `<parent-repo>/<issue-number>-<submodule>` | `opencode-config/950-opencode` |

See `git-workflow/SKILL.md` §Tag Convention for the canonical definition of all tag types.

## Verification

```bash
git ls-remote --tags origin "<parent-repo>/<issue-number>-<submodule>"
# Output must show a SHA, not empty
```