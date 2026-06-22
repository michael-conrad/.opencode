# Task: write

## Purpose

Write an implementation plan file to the correct repo's `.issues/` worktree and push it via `local-issues sync-file`.

## Prerequisites

- [ ] 1. Plan content has been created (by `create` task)
- [ ] 2. Spec issue number (`N`) is known
- [ ] 3. Session-init `## Repo Information` is available for repo resolution

## Operating Protocol

- [ ] 1. **Resolve target repo** — Match the spec issue's repo path against session-init `## Repo Information` entries. The issue's repo is determined by its issue number's location: if the issue is in `.opencode/.issues/{N}/`, the repo is the `.opencode` submodule entry; if in `.issues/{N}/`, the repo is the root entry. Extract `html_url`, `owner`, `repo` from the matching entry.
- [ ] 2. **Write plan file** — Write the plan content to the resolved repo's `.issues/` worktree at `{worktree.path}/.issues/{N}/plan.md`.
- [ ] 3. **Commit and push** — Run `local-issues sync-file` with the plan file path. This handles `git add`, `git commit`, and `git push` in the correct worktree.
- [ ] 4. **Generate URL** — Construct the plan file URL using the resolved repo's `html_url`, `owner`, and `repo`: `{html_url}/{owner}/{repo}/tree/issues-data/{N}/plan.md`. Verify `{html_url}` was substituted (not left as a literal placeholder). If placeholder remains, HALT with blocker.

## Entry Criteria

- Plan content is ready for file placement
- Target repo is resolved from session-init `## Repo Information`
- `local-issues sync-file` subcommand is available

## Exit Criteria

- Plan file written to correct repo's `.issues/{N}/plan.md`
- File committed and pushed via `local-issues sync-file`
- Plan file URL reported with correct repo's `html_url`, `owner`, `repo`

## Repo Resolution

The session-init `## Repo Information` section provides per-repo entries:

```yaml
- path: .
  owner: michael-conrad
  repo: opencode-config
  platform: github.com
  url: git@github.com:michael-conrad/opencode-config.git
  html_url: https://github.com
- path: .opencode
  owner: michael-conrad
  repo: .opencode
  platform: github.com
  url: git@github.com:michael-conrad/.opencode.git
  html_url: https://github.com
```

Match the issue's repo path prefix against the `path` field. Use the matching entry's `html_url`, `owner`, and `repo` for URL construction.
