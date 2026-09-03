# Preliminary State Analysis — Dispatch Discipline Remediation

## Persistent state touched by this change

### 1. `.opencode/` submodule git state
- All directive/deck edits commit to the `.opencode` submodule (michael-conrad/.opencode)
- Parent repo submodule pointer updates ride alongside next real parent-repo change (per AGENTS.md discipline — pointer-only pushes blocked by pre-push hooks)

### 2. Session-level state (no migration needed)
- `authorization_scope`, `halt_at`, `pipeline_phase` — carried in prompts, not persisted
- No DB or session schema changes required

### 3. Work state files (tmp/, per-issue)
- Dispatch behavior logged in work state files during pipelines
- No format change required; new dispatch modes are loggable as-is

### 4. Issue tracking state
- Open specs #1208, #1210 in `.opencode/.issues/` — overlap must be resolved as part of spec work
- Local issue YAML frontmatter unaffected

### 5. Test harness state
- `tests-v2/behaviors/*` scenario scripts assert dispatch behavior — state as expectations, updated with changes
- `tmp/.behavior-run.lock` lifecycle unaffected

### 6. Derived/validation state
- skildeck index/lint cache — validators may need re-run after deck changes; no persistent schema
- `skill-index` artifacts rebuilt by skildeck after card edits

## State invariants to preserve

- Submodule discipline: `.opencode` changes flow through the submodule repo, never the parent's `.issues/` worktree rules
- All 51 pre-flight guards remain present after any card edit (validator-verified)
- No `.opencode/.opencode/` nested directory creation (Tier 1 rule)
- Markdown lint/format gates continue to pass on edited guideline files

## No migration risks identified
No database, no user data, no serialized formats — state impact is limited to git content and test expectations.