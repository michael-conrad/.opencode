## Summary

Two defects in the release-promoter verification gate (`skills/release-promoter/SKILL.md` + `references/operating-protocol.md`), observed live during the v0.6.1 release of SEC-Filings-Scraper on 2026-10-13.

### 1. Gate ordering — the shallow clone and build verification run post-merge, but they are supposed to happen BEFORE the PR is created

The operating protocol declares entry criteria "Release PR has been merged" and sequences: merge (human gate) → clean-room gate → tag → release. This is inverted. **The shallow clone is supposed to happen before the PR is created**: release PRs are feature branches, and the clean-room clone and build/test verification run after the branch for the PR has been pushed but before the PR itself is filed (the branch exists on the remote, not yet marked for PR) — against the release branch's head, so the PR is created only for a state already proven from a clean room. The post-merge run currently validates trunk *after* trunk has already been trusted to the merge — a true merge commit whose tree diverges from the PR head is first clean-room-proven only after the merge, with nothing blocking the broken state from landing on trunk.

### 2. Clone transport — the gate permits a local path, which poisons relative submodule URLs

The protocol allows `git clone --depth 1 <repo-url-or-path>`. Using the local working-tree path was attempted and it broke: with relative submodule URLs (`../Module.git`), the temp clone's submodule URLs resolve against the parent's origin. A local-path parent origin — the git `file` protocol, which covers both local paths and `file://` URLs — resolves every submodule to file-protocol URLs, which git's default security policy (`protocol.file.allow`, tightened in git 2.38.1 — 2022-10-18, CVE-2022-39253, backported to 2.30.6 and later maintenance lines) refuses for configured URLs — the submodule clones fail (observed: `fatal: transport 'file' not allowed`) before any assertion runs.

**The shallow clone SHALL use the same parent URL as the root project repo** — the identical remote URL the project itself is cloned from — so relative submodule URLs resolve to their true remote endpoints exactly as in a real checkout. Local-path cloning is only safe with absolute pinned submodule URLs; the gate must not allow the path variant.

### Mandated sequence

The gate shall be performed along the lines of:

```
git clone --depth 1 --branch <branch> <remote-url> <shallow-clone>
cd <shallow-clone>
git submodule update --init --depth 1
<build verification commands>
```

The clone flags are normative: `--depth 1` makes the clone shallow, and `--branch <branch>` selects and checks out the release branch's head in the clone itself — a shallow clone fetches only the named branch's tip, never full history. The shallow clone shall **NOT** be recursive (`--recursive` is already forbidden elsewhere in the card and stays forbidden; submodule resolution goes through `git submodule update --init --depth 1` at the gitlink-pinned SHAs — no `--remote`, no recursion). Build verification commands are the manifest's canonical build/test commands, as today.

## Observed incident (2026-10-13, v0.6.1)

1. Gate ran post-merge per current protocol: trunk merge `9f4f5d6a`.
2. Gate clone used the local path (sanctioned by `<repo-url-or-path>`); submodule clones failed with `transport 'file' not allowed` (local-path origin — the git `file` protocol, which covers both local paths and `file://` URLs — plus relative `.gitmodules` URLs).
3. Gate halted with no in-place remediation; root cause diagnosed as environmental (transport policy), not release-tree defect; second gate run from the ssh remote (`CHECKOUT_OK`, 18/18 `DRIFT_OK`, `BUILD SUCCESSFUL` from scratch) completed promotion.
4. Cost: one blocked gate run, one halt-to-developer round trip — both would not have occurred had this fix been in place.

## Remediation direction

- Move the shallow-clone + drift + build-verification gate to after the release branch has been pushed and before the PR itself is filed (release branch head, tree identical to the eventual merge candidate); post-merge, reduce the pre-tag step to the submodule drift assertion against the merged commit plus a fast re-check that the tree is content-identical to the verified branch head — a mismatch (`TREE_MISMATCH`) blocks promotion with no tag, because the merged tree was never clean-room-verified, and the release stops for developer direction.
- Change `repo-url-or-path` to: same parent URL as the root project repo; remote transport only.
- Rewrite the protocol steps to the mandated sequence above; keep `--remote`/`--recursive` forbidden and keep the once-per-release no-retry rule scoped to assertion failures — drift (`DRIFT_FAIL`), manifest discovery (`MANIFEST_FAIL`), and build/test (`BUILD_FAIL`) — not environment/transport setup defects, with a stated expectation that transport/environment failures are diagnosed and the gate re-run, not treated as release-blockers.


