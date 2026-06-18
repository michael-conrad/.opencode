# Plan: skildeck frontmatter validation + advisory-only linters

**Spec:** #1238
**Authorization scope:** `for_pr`
**Halt at:** `pr_created`
**PR strategy:** `stacked`

## Phase 1: skildeck frontmatter validation

**Concern:** Add `skill-frontmatter` validation to skildeck-lint so malformed SKILL.md YAML frontmatter is caught at lint time.

### Files
- `.opencode/tools/impl/skildeck/skildeck-lint` — add `lint_skill_frontmatter()` function

### TDD Steps

#### Step 1.1: Add `lint_skill_frontmatter()` function to skildeck-lint

**RED:** Write behavioral test `tests/behaviors/skildeck-frontmatter-validation.sh` that creates a temp SKILL.md with unquoted description, runs `skildeck lint`, asserts error is reported.

**GREEN:** Add `lint_skill_frontmatter()` to `skildeck-lint` that validates each SKILL.md in the skills directory:

| Check | Condition | Severity |
|-------|-----------|----------|
| `name` exists | `name` key missing | error |
| `name` matches directory | `name != dirname` | error |
| `name` regex | `name` doesn't match `^[a-z0-9]+(-[a-z0-9]+)*$` | error |
| `name` length | `len(name) < 1 or len(name) > 64` | error |
| `description` exists | `description` key missing | error |
| `description` length | `len(desc) < 1 or len(desc) > 1024` | error |
| `description` quoted | YAML string not quoted (heuristic: starts with unquoted text) | error |
| YAML parses | `yaml.safe_load()` on frontmatter fails | error |
| No unknown fields | Field not in `{name, description, license, compatibility, metadata}` | error |
| `license` SPDX | If present, not a valid SPDX identifier | warning |

Call `lint_skill_frontmatter()` from `main()` alongside existing `lint_progressive_disclosure()`.

**REFACTOR:** Run existing skildeck regression test to confirm no regressions.

## Phase 2: All linters advisory-only

**Concern:** Prevent any linter from auto-modifying files. All linters must run in read-only/report-only mode.

### Files
- `.opencode/guidelines/000-critical-rules.md` — add critical rule
- `.opencode/AGENTS.md` — update Build/Lint/Test Commands table
- `.opencode/skills/requesting-code-review/tasks/prepare.md` — `ruff check --fix` → `ruff check`
- `.opencode/skills/executing-plans/tasks/progress.md` — `ruff check --fix` → `ruff check`, `ruff format` → `ruff format --check`
- `.opencode/skills/executing-plans/tasks/verify.md` — `ruff check --fix` → `ruff check`, `ruff format` → `ruff format --check`
- `.opencode/skills/finishing-a-development-branch/tasks/prepare.md` — `ruff check --fix` → `ruff check`, `ruff format` → `ruff format --check`
- `.opencode/skills/finishing-a-development-branch/tasks/checklist.md` — `ruff format` applied → `ruff format --check` passes
- `.opencode/skills/verification-before-completion/tasks/collect.md` — `ruff check --fix` → `ruff check`, `ruff format` → `ruff format --check`
- `.opencode/skills/implementation-pipeline/tasks/pipeline-executor.md` — update structural-checks gate description to enforce advisory-only

### TDD Steps

#### Step 2.1: Add critical rule to 000-critical-rules.md

**RED:** Write behavioral test `tests/behaviors/linters-advisory-only.sh` that sends a prompt asking the agent to run linters and asserts no auto-modify flags are used.

**GREEN:** Add to `000-critical-rules.md` in the Tier 2 section:

```
### [critical-rules-linters-advisory] All linters are advisory only — no auto-modify

All linters (current and future) MUST run in read-only/report-only mode. No linter may auto-modify files.

| Linter | Forbidden | Required |
|--------|-----------|----------|
| `ruff check` | `ruff check --fix` | `ruff check` |
| `ruff format` | `ruff format` | `ruff format --check` |
| `mdformat` | `mdformat` (without `--check`) | `mdformat --check` |
| Any future linter | Auto-modify mode | Read-only/report-only mode |
```

#### Step 2.2: Update AGENTS.md Build/Lint/Test Commands

**GREEN:** Change:
- `Lint + auto-fix` row: `ruff check --fix` → `ruff check`
- `Format` row: `ruff format` → `ruff format --check`

#### Step 2.3: Update skill task files

**GREEN:** Replace `ruff check --fix` with `ruff check` and `ruff format` with `ruff format --check` in:
1. `skills/requesting-code-review/tasks/prepare.md` line 80
2. `skills/executing-plans/tasks/progress.md` lines 11-12
3. `skills/executing-plans/tasks/verify.md` lines 13-14
4. `skills/finishing-a-development-branch/tasks/prepare.md` lines 73, 76
5. `skills/finishing-a-development-branch/tasks/checklist.md` line 26 — change "`ruff format` applied" to "`ruff format --check` passes"
6. `skills/verification-before-completion/tasks/collect.md` lines 73, 76

#### Step 2.4: Update structural-checks gate in pipeline-executor.md

**GREEN:** Add note to Step 7 description in `pipeline-executor.md` that structural-checks enforces advisory-only mode for all linters.

## Phase 3: Behavioral enforcement tests

**Concern:** Verify both changes work end-to-end via behavioral tests.

### Files
- `.opencode/tests/behaviors/skildeck-frontmatter-validation.sh` — new
- `.opencode/tests/behaviors/linters-advisory-only.sh` — new

### TDD Steps

#### Step 3.1: skildeck-frontmatter-validation.sh

**RED/GREEN:** Create behavioral test that:
1. Creates a temp SKILL.md with unquoted description
2. Runs `skildeck lint` via the dispatcher
3. Asserts stderr contains error about unquoted description
4. Creates a temp SKILL.md with name not matching directory
5. Asserts stderr contains error about name/directory mismatch
6. Creates a temp SKILL.md with missing `name` field
7. Asserts stderr contains error about missing name
8. Creates a temp SKILL.md with YAML parse failure (unescaped quotes)
9. Asserts stderr contains error about YAML parse failure
10. Creates a valid SKILL.md
11. Asserts no errors reported

#### Step 3.2: linters-advisory-only.sh

**RED/GREEN:** Create behavioral test that:
1. Sends a prompt asking the agent to run linters
2. Asserts no `--fix` or auto-modify flags appear in tool calls
3. Asserts `ruff check` (without `--fix`) is used
4. Asserts `ruff format --check` is used
5. Asserts `mdformat --check` is used
