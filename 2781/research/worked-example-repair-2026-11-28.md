# Worked-example repair evidence — 2026-11-28

The execution record grounding this spec's repair-mechanics requirements
(R-2, R-5). Executed by the discovering session on the same day the regression
was filed; all values below are first-party, taken from the session's git
verification set.

## The defect (pre-repair state)

Parent repo (`michael-conrad/opencode-config`, main worktree at
`/home/muksihs/git/opencode-config`) held a conflicted git index shadowing the
`.issues/` store mount — residue of a failed stash application
(`stash@{0}: On feature/523-issues-worktree-remotemd: stash before
feature/523 branch creation`). A failed `stash apply/pop` leaves unmerged
index entries without merge/rebase marker files, which matched the observed
state exactly.

- `UU .gitignore` (all three stages present: base `202a9084`, ours `a3c241ba`,
  theirs (stash) `82d07643`)
- `DU .issues/682/spec.md`, `DU .issues/682/state.md` (stage 1 + 3)
- `DU .issues/closed/001-submodule-aware-session-identity-plus-local-issue-tracking/comments.md`
  and `…/spec.md` (stage 1 + 3)

HEAD's tree (`385a8a70`) carried zero `.issues/` paths — the store had
converted to the worktree-only model; the stash side carried pre-conversion
content. Ours (`a3c241ba`, HEAD's expanded `.gitignore` including the
`.issues/` ignore) strictly superseded theirs (old base + `.tools/` +
`.srclight/`, no `.issues/` ignore). Intent classification: theirs stale.

## The repair (same workflow, 2026-11-28)

1. Pre-state captured: unmerged paths enumerated (above); stash entries listed
   and left intact; store integrity snapshotted (429 numeric record dirs;
   `.issues/682/spec.md` + `state.md` sha256 `a02f7cef…` / `7b86c4cb…`).
2. Non-loss documented: stash stage-3 blobs for the 682 paths were sha-identical
   to the live store worktree files — both sides preserved.
3. Resolution:
   `git checkout HEAD -- .gitignore` (restore ours/HEAD, clean of conflict
   markers), then `git rm --cached -f` on the 4 `.issues/…` paths — **cached
   only**: store worktree files never deleted or overwritten; HEAD tracked no
   `.issues/` paths, so no staged changes resulted and no commit was created.
   (Stage-entry view of the pre-state: 11 unmerged stage-entries — 3 on
   `.gitignore`, 2 on each of the 4 `.issues/…` paths.)
4. Post-repair verification (the instrument set the spec's R-5 requires):
   - `git ls-files -u` → 0 unmerged entries
   - `git status --short` → only ` M .opencode` (sanctioned pointer drift,
     unstaged) plus pre-existing untracked junk; no staged changes
   - `git diff HEAD -- .gitignore` → empty (worktree file byte-identical to
     HEAD)
   - `git check-ignore .issues` → YES (mount ignored by the parent)
   - store worktree `git -C .issues status --short` → clean; HEAD unchanged at
     the session's last store commit
   - store data byte-intact: 429 record dirs; 682 sha256 values identical
     pre/post; stash entries preserved (none dropped)

## Outcome

Root index clean; store mount properly untracked and ignored; store data
untouched; no history changed. The repair was mechanical and byte-safe at
every step — the class this spec assigns to agent-owned auto-repair.
