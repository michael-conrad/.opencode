Both `import-remote` and `sync-pull-to-local` write the remote API issue body to `spec.md`. The remote body is a condensed exec summary — belongs in `remote.md` alongside `spec.md`.

## Changes

1. import-remote Step 4: write remote body to `remote.md` instead of `spec.md`
2. sync-pull-to-local Step 3: write remote body to `remote.md` instead of `spec.md`
3. Update frontmatter references to use `remote.md` consistently for `remote_issue`, `remote_url`, `last_sync`

## Success Criteria

SC-1: import-remote writes remote body to remote.md
SC-2: sync-pull-to-local writes remote body to remote.md
SC-3: spec.md is never overwritten by remote body content