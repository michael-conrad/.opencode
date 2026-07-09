# GitHub MCP - spec.md Mirror

## Entry Criteria

- `github_issue_read(method="get")` was called successfully
- Issue number is known
- Repo path prefix is known (root repo or submodule)

## Procedure

Every `github_issue_read(method="get")` call MUST mirror the spec body to `.issues/<issue_number>/spec.md` (root repo) or `{project_root}/{path}/.issues/<issue_number>/spec.md` (submodule/sub-repo):

### Mirror Sync Procedure (MANDATORY)

After every `github_issue_read(method="get")` success:

1. Create directory: `mkdir -p .issues/<issue_number>/` (root repo) or `mkdir -p {project_root}/{path}/.issues/<issue_number>/` (submodule/sub-repo)
2. Write `spec.md`:
```
# Synced from GitHub Issue #<N> at <ISO8601-timestamp>

<issue body>
```
3. Report to chat: `"spec.md mirror updated for #<N> at <timestamp>"`

### Fallback Procedure (MANDATORY)

When `github_issue_read(method="get")` fails with a network error, rate limit, or auth failure:

1. Check if `.issues/<issue_number>/spec.md` (root repo) or `{project_root}/{path}/.issues/<issue_number>/spec.md` (submodule/sub-repo) exists
2. If exists: read from disk, note in chat: `"GitHub API unreachable. Reading spec.md (last synced at <timestamp>, may be stale)."`
3. If NOT exists and API is unreachable: report `"Cannot read spec #<N> — API unreachable and no local spec.md mirror exists."`
4. Proceed with stale/absent data noting the risk

### Staleness Detection

`spec.md` is stale when:
1. The sync timestamp in the header is more than 24 hours old
2. The GitHub Issue was modified (comments added, labels changed) since the last sync

Agent MUST report staleness when detected and should attempt to refresh. If API still unreachable, proceed with stale copy noting the risk.

### Three-File Layout

| File | Role | Format | Edited by agent? | Synced to remote? |
|------|------|-------|-------------------|--------------------|
| `spec.md` | Canonical full spec | YAML frontmatter + markdown body | Yes — when spec detail changes | Never |
| `state.md` | Workflow phase tracking and sync timestamps | YAML frontmatter + phase fields | Yes — on phase transitions and sync events | Never |
| `remote.md` | Exact GitHub/GitBucket issue body | Pure markdown — no YAML frontmatter | Yes — via `body-edit` task only | Yes — sync push after verification |

### Mirror Protocol

The agent edits `remote.md` for remote body changes; `spec.md` is the canonical full spec. `remote.md` is the exact GitHub/GitBucket issue body, read verbatim for sync push. Every edit to `remote.md` MUST go through the `body-edit` task (fetch → transform → verify → post).

**Mirror flow:** local edit to `remote.md` → verify structural integrity → sync push to GitHub/GitBucket.

## Exit Criteria

- spec.md mirror written or updated
- Staleness reported if applicable
- Fallback data used if API unreachable
