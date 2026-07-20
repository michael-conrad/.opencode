# Task: create-remote-stub

## Purpose

Obtain a spec issue number and create a stub file. Handles both remote (GitHub/GitBucket) and local (`.issues/` worktree) platforms transparently.

## Entry Criteria

- `local-issues sync` has been run (`.issues/` worktree is current)
- Platform is known from session-init (`github.platform`)

## Procedure

- [ ] 1. **Check platform** — Read `github.platform` from session-init. If `local`, proceed with local mode. If `github.com` or `gitbucket`, proceed with remote mode.
- [ ] 2. **Remote mode:** Create a minimal issue via the platform API with title and `needs-approval` label. Save the returned issue number as `N`. Write stub to `{project_root}/{path}/.issues/{N}/remote.md` with the issue URL and number.
- [ ] 3. **Local mode:** List existing `{project_root}/{path}/.issues/` directories, find the max number, increment by 1. Create `{project_root}/{path}/.issues/{N}/remote.md` with a stub noting local-only mode.
- [ ] 4. **Return spec_number** — The spec number `N` is used by all subsequent pipeline steps for artifact paths.

## Result Contract

| Field | Value |
|-------|-------|
| `status` | `DONE` |
| `finding_summary` | `"Issue #N created via <platform>"` |
| `artifact_path` | `{project_root}/{path}/.issues/{N}/remote.md` |
| `spec_number` | `N` |
