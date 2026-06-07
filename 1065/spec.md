# [SPEC] local-issues tool: AI-consumable output format and cross-repo operations

## Intent and Executive Summary

- **Problem Statement**: The `local-issues` tool outputs bare issue numbers (`#7 [open] Title`) and only operates within a single repo. AI agents consuming the output must infer which `.issues/` directory the issue belongs to — impossible when multiple repos are active. Mutation commands accept bare numbers with no repo qualification, risking cross-repo modification errors.
- **Root Cause / Motivation**: The tool was designed for single-repo use (line 24: "Manages a local .issues/ directory"). With multi-repo support added by #1059, the output format and command interface must evolve to support cross-repo disambiguation.
- **Approach Chosen**: Qualified `{repo}#{N}` notation for all user-facing output and mutation commands. Read operations accept both qualified and bare numbers. List output adds `spec_path` column. Search defaults to cross-repo. Mutation commands require qualified form.
- **Alternatives Considered & Why Discarded**: (1) `--repo` flag on every command — discarded because it adds friction to every invocation when the qualified form is self-documenting. (2) Auto-scan + numeric match for mutations — discarded because ambiguous matches on mutation could corrupt the wrong repo.
- **Key Design Decisions**: Mutations require qualified form (never bare numbers). Reads accept both — safe to be lenient. Cross-repo is the only mode (no `--single-repo` flag).

## Objective

Update `local-issues` tool output format and command interface to support cross-repo disambiguation using qualified `{repo}#{N}` notation. All 11 skill task cards referencing `local-issues` output are updated to document the new format.

## Context

Issue #1059 adds submodule auto-discovery for worktree creation (WORKTREE_BRANCH fix, recursive `_ensure_worktree()`). That spec handles the infrastructure side — getting `.issues/` worktrees into child repos. This spec handles the consumer side — making the tool output AI-consumable for multi-repo environments.

The `.opencode/` submodule has a manually-created `.issues/` on `issues-data` branch. After #1059, `local-issues` will auto-maintain both `./.issues/` and `./.opencode/.issues/` — but the output format won't distinguish between them without this spec.

## Affected Files

| File | Nature of Change |
|------|-----------------|
| `.opencode/tools/local-issues` | `list` output format (qualified repo#N + spec_path); `read` cross-repo lookup; `search` cross-repo default; mutation commands reject bare numbers |
| `platforms/local/tasks/list.md` | Update documented YAML output format to include `repo`, `spec_path` fields |
| `platforms/local/tasks/search.md` | Update scope from single-repo to cross-repo default |
| `platforms/local/tasks/read.md` | Add note about cross-repo lookup behavior and qualified-form output |
| `platforms/local/tasks/update.md` | Update command examples to use qualified `{repo}#{N}` form |
| `platforms/local/tasks/close.md` | Same |
| `platforms/local/tasks/delete.md` | Same |
| `platforms/local/tasks/promote.md` | Same |
| `platforms/local/tasks/push-body.md` | Same |
| `platforms/local/tasks/pull-body.md` | Same |
| `platforms/local/tasks/body-edit.md` | Same |

## Explicit Non-Goals

- Submodule worktree creation (covered by #1059)
- `WORKTREE_BRANCH` name fix (covered by #1059)
- Orphan branch push logic (covered by #1059)
- Remote platform API changes (local tool only)

## Success Criteria

| ID | Criterion | Evidence Type | Verification Gate | Verification Method |
|----|-----------|---------------|-------------------|---------------------|
| SC-1 | `local-issues list` outputs qualified `{repo}#{N}` as the primary identifier column. Format: `opencode-config#1060 ./.issues/1060/ spec Title`. Sorting: main repo first, submodules alphabetical, then by issue number descending per repo | `string` | pipeline-auto | grep for `repo#N` pattern in tool output |
| SC-2 | `local-issues list` includes a `spec_path` column — the relative path to the issue directory (e.g., `./.issues/1060/` or `./.opencode/.issues/10/`). This is the spec root folder, not individual files | `string` | pipeline-auto | grep for `./.issues/` in list output |
| SC-3 | `local-issues list` scans all immediate child repos by default — main + submodules + sub-repos. No `--single-repo` flag exists | `behavioral` | pipeline-semantic | behavioral: `list` from root with 2+ repos produces entries from each |
| SC-4 | `local-issues read N` with a bare number scans all repos and returns ALL matches with qualified `{repo}#{N}` prefix. If only one match exists, the qualified prefix is still included for consistency | `string` | pipeline-auto | Read output contains `repo` field alongside `number`, `spec_path` |
| SC-5 | `local-issues read opencode-config#10` (qualified form) targets a specific repo directly — no scan needed | `string` | pipeline-auto | Qualified form accepted and route to correct repo |
| SC-6 | Mutation commands (`update`, `close`, `delete`, `promote`, `push-body`, `pull-body`) require qualified `{repo}#{N}` form. Bare numbers are rejected with: "Use qualified form `{repo}#{N}`" | `behavioral` | pipeline-semantic | behavioral: try mutation with bare number → error; try with qualified → success |
| SC-7 | `local-issues search` scans all repos by default. Output includes `repo` and `spec_path` per result. No `--repo` flag | `behavioral` | pipeline-semantic | behavioral: search with cross-repo results includes repo field |
| SC-8 | `local-issues create` with `--number N` checks for collision across ALL repos — if `{repo}#{N}` exists in any repo, creation is blocked with disambiguation | `behavioral` | pipeline-semantic | behavioral: create with existing number in sibling repo → blocked |
| SC-9 | `local-issues/list.md` task card documents the new output format (qualified repo#N, spec_path, sorting) with updated YAML example | `string` | pipeline-auto | grep for `repo#N` and `spec_path` in list.md |
| SC-10 | `local-issues/read.md` task card documents cross-repo lookup behavior and qualified-form output | `string` | pipeline-auto | grep for cross-repo language in read.md |
| SC-11 | `local-issues/search.md` task card documents cross-repo default scope | `string` | pipeline-auto | grep for cross-repo scope in search.md |
| SC-12 | Mutation task cards (update.md, close.md, delete.md, promote.md, push-body.md, pull-body.md, body-edit.md, sync-pull-to-local.md) use qualified `{repo}#{N}` form in all command examples | `string` | pipeline-auto | grep each file for `{repo}#{N}` or qualified-form examples |
| SC-13 | `local-issues read N` cross-repo scan scans main repo first, then immediate child repos in alphabetical order. First match is returned as primary; secondary matches listed in disambiguation section | `string` | pipeline-auto | Verified by code review of scan order |

## Edge Cases

| Edge Case | Handling |
|-----------|----------|
| No child repos exist (single-repo setup) | `{repo}#{N}` format still applies — main repo name resolves to `.` (project root dir name) |
| Child repo has no `.issues/` yet | Silently skip — no scan output for repos without issues |
| `{repo}#{N}` contains special chars | Repo names are filesystem directory names — safe for `#` delimiter. No escaping needed |
| Agent passes `{repo}#{N}` to upstream GitHub API | Agent must strip the `{repo}#` prefix before passing to `github_issue_write`. The `local-issues` tool is local-only; remote API calls use bare numbers |
| Submodule not initialized | `git submodule status` check before scanning — skip uninitialized submodules |

## Dependencies

| Dependency | Type | Impact |
|------------|------|--------|
| [#1059](https://github.com/michael-conrad/.opencode/issues/1059) | Infrastructure | Worktree auto-discovery must exist before cross-repo output matters |
| [#1060](https://github.com/michael-conrad/.opencode/issues/1060) | Parent | Coordinated under same spec-output umbrella |

## Risk

| RISK-ID | Description | Likelihood | Impact | Verifying SC | Mitigation |
|---------|-------------|------------|--------|--------------|------------|
| RISK-1 | Qualified-form requirement breaks existing agents that use bare numbers for mutations | High | Medium | SC-6 | Error message is self-documenting ("Use qualified form `{repo}#{N}`"). Agent retries with qualified form. No silent failure |
| RISK-2 | Cross-repo scan adds latency to `read`/`search` | Low | Low | SC-4, SC-7 | Scan is directory-walk — sub-100ms for typical issue counts |
| RISK-3 | `{repo}#{N}` leaked into GitHub API calls | Low | Medium | (self-documenting) | Agent guideline: strip `{repo}#` before API calls. Error caught at API call time (invalid number format) |

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|-----------------|-------------------|---------|
| Direct source search | `.opencode/tools/local-issues` | Current output format, command interface, REPO awareness |
| Skill task cards | `platforms/local/tasks/*.md` | Current documented patterns for mutation commands |
| Issue #1059 | GitHub | Submodule worktree auto-discovery scope boundary |
| Brainstorming session | Current discussion | Qualified-form design, mutation vs read leniency, output format |

<!-- Provenance: AI-generated -->
<!-- Co-authored with AI: OpenCode (deepseek-v4-flash) -->