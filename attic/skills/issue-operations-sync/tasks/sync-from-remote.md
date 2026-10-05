## Task: sync-from-remote

**Trigger:** After `local-issues sync` — reconcile remote issues against local `.issues/`.

### Purpose

Ensure local `.issues/` mirrors all open remote issues. Detect staleness in both directions.

### Procedure

- [ ] 1. Call `local-issues sync` (ensure git state is current across all repos)
- [ ] 2. For each repo in cascade (current repo + child repos):
   a. List open issues from remote via platform dispatcher
   b. Call `local-issues list` and parse issue numbers
   c. Diff: for each remote issue not in local → call `import-remote` task
   d. For issues in both: compare `updated_at` on remote vs local
      - remote newer → call `sync-pull-to-local` (update `remote.md`)
      - local newer → flag: `local_ahead: "issue {qualifier}#{N} is ahead of remote"`
- [ ] 3. Report structured YAML:
   ```yaml
   sync-from-remote:
     repos:
       - qualifier: opencode-config
         imported: [N, N, N]
         stale_remote_ahead: [{number: N, title: "..."}]
         stale_local_ahead: [{number: N, title: "..."}]
   ```

### Dispatch Context

- `worktree.path`
- `github.owner`
- `github.repo`
- `github.platform`

### Output

Always output YAML. If no remote is configured (platform == local), report `no_remote: true` and skip.

### Authorization

Authorization-free — reconciling local state against remote is read-only metadata sync per `.issues/AGENTS.md`. No `"approved"` or `"go"` needed.