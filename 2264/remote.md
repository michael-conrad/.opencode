---
remote_issue: 2264
remote_url: "https://github.com/michael-conrad/.opencode/issues/2264"
last_sync: 2026-08-11T15:20:00Z
source: github.com
---

## Spec Reference

> Full spec and plan artifacts: https://github.com/michael-conrad/.opencode/tree/issues-data/.issues/2264/

## Problem

The `.opencode/hooks/pre-commit` Gate 2 stale-pointer check queries each submodule's remote using the **parent repo's** trunk branch name. When a submodule's trunk differs from the parent's trunk, the hook blocks legitimate submodule pointer commits with a false "stale pointer" error.

Concretely: `DEFAULT_BRANCH` is derived from the parent repo's `git remote show origin` output (line 36). This same value is then used at line 54: `REMOTE_SHA=$(git -C "$sp" rev-parse "origin/$DEFAULT_BRANCH" 2>/dev/null || true)` — querying the submodule's remote using the **parent's** trunk branch name. When a submodule's trunk differs (e.g. `SharedPojos` trunk is `main` while parent `Patents` trunk is `master`), the rev-parse silently fails or returns the wrong ref, `REMOTE_SHA` is empty or mismatched, and the hook blocks the commit citing "Remote trunk tip SHA: …" — even when the staged pointer IS at the submodule's actual trunk tip.

## Reproduction

1. On the `Patents` repo (trunk=`master`), with submodules including `SharedPojos` (trunk=`main`)
2. Create a release branch: `git checkout -b chore/capture-submodule-tips`
3. In `SharedPojos`: `git checkout main && git pull` — staged pointer now points at `origin/main`
4. Stage the `SharedPojos` submodule pointer update: `git add SharedPojos`
5. Run `git commit -m "chore: capture submodule trunk tips"`
6. **Observed:** Hook blocks with `BLOCKED: Submodule 'SharedPojos' has a stale pointer. Staged SHA: <origin/main SHA>. Remote trunk tip SHA: <empty or origin/master SHA>`
7. **Expected:** Hook allows the commit because the staged pointer IS at `SharedPojos`'s actual trunk tip (`origin/main`)

## Scope

- Replace parent-repo trunk lookup with per-submodule trunk lookup in `.opencode/hooks/pre-commit` Gate 2
- Add fallback to parent trunk only when submodule trunk lookup fails (no `HEAD branch:` line, network error, etc.)
- Update any related documentation references to the trunk-detection logic
- Verify against at least 2 submodules with known-different trunks (`SharedPojos` uses `main`, `Patents` uses `master`)

**Out of scope:**

- Rewriting the entire stale-pointer check algorithm (only the trunk-branch-name source is wrong)
- Adding new override flags or escape hatches beyond existing `SKIP_STALE_POINTER_CHECK`
- Pre-push hook Gate 2 (separate hook file, separate issue if applicable)
- The `awk substr` bug from #2258 (already closed/remediated)

## Approach

Change Gate 2 from a single shared `DEFAULT_BRANCH` lookup to a per-submodule trunk lookup. For each submodule, run `git -C "$sp" remote show origin` and extract the submodule's own `HEAD branch:` line. Fall back to the parent's trunk only when the submodule lookup fails.

Concretely, replace line 54 with:

```bash
SUBMODULE_TRUNK=$(git -C "$sp" remote show origin 2>/dev/null | sed -n 's/.*HEAD branch: //p')
[ -z "$SUBMODULE_TRUNK" ] && SUBMODULE_TRUNK="$DEFAULT_BRANCH"
REMOTE_SHA=$(git -C "$sp" rev-parse "origin/$SUBMODULE_TRUNK" 2>/dev/null || true)
```

Rationale: each submodule has its own remote with its own HEAD branch. The hook is checking the submodule's trunk, not the parent's. The current implementation accidentally uses the parent's trunk because both repositories happened to use the same default branch name during development/testing.

## Impact

- **Risk:** False-positive blocks force legitimate submodule pointer commits (release captures, routine syncs) to use the `SKIP_STALE_POINTER_CHECK=1` override, which is documented as "deliberate action only". **Mitigation:** Fix the trunk lookup so the override is no longer needed for routine release work.
- **Risk:** Existing local-clone setups where submodule remotes aren't fully configured may fall back to parent trunk — same false-positive as today. **Mitigation:** Fallback only fires when submodule lookup fails; this matches today's behavior in the failure case.
- **Risk:** Submodules whose trunks are themselves being renamed may produce ambiguous results. **Mitigation:** Out of scope — trunk renaming is a separate migration; today's behavior is no better.
- **Dependencies:** None beyond the existing git/sed tooling already in the hook.
- **Call to action:** Apply the per-submodule lookup; verify against `SharedPojos` (trunk=`main`) and a submodule sharing parent's trunk (`master`); remove any `SKIP_STALE_POINTER_CHECK=1` override uses that were only needed due to this bug.

## Evidence

- `Patents` release PR #19 (`chore: capture submodule trunk tips for release`) used `SKIP_STALE_POINTER_CHECK=1` because the hook incorrectly flagged `SharedPojos` as stale — staged pointer was at `SharedPojos` `origin/main`, hook compared against `origin/master` (parent's trunk) and blocked.
- Source verified at `.opencode/hooks/pre-commit:36` (parent trunk lookup) and `.opencode/hooks/pre-commit:54` (parent-trunk-based submodule rev-parse).

🤖 OpenCode (ollama-cloud/minimax-m3) created
