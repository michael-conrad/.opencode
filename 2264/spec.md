---
number: 2264
title: "[SPEC-FIX] Pre-commit hook uses parent repo's trunk branch name for submodule trunk lookup — fails when submodule trunk differs (e.g. SharedPojos uses 'main' not 'master')"
status: open
labels: []
created: 2026-08-10T21:09:36Z
updated: 2026-08-11T21:00:00Z
remote_issue: 2264
remote_url: "https://github.com/michael-conrad/.opencode/issues/2264"
promoted_at: 2026-08-11T15:20:00Z
promotion_type: retroactive_import
last_sync: 2026-08-11T21:00:00Z
author: michael-newsrx
---

## Problem

The `.opencode/hooks/pre-commit` Gate 2 stale-pointer check queries each submodule's remote using the **parent repo's** trunk branch name. When a submodule's trunk differs from the parent's trunk, the hook blocks legitimate submodule pointer commits with a false "stale pointer" error.

Concretely: `DEFAULT_BRANCH` is derived from the parent repo's `git remote show origin` output (line 36). This same value is then used at line 54: `REMOTE_SHA=$(git -C "$sp" rev-parse "origin/$DEFAULT_BRANCH" 2>/dev/null || true)` — querying the submodule's remote using the **parent's** trunk branch name. When a submodule's trunk differs (e.g. `SharedPojos` trunk is `main` while parent `Patents` trunk is `master`), the rev-parse silently fails or returns the wrong ref, `REMOTE_SHA` is empty or mismatched, and the hook blocks the commit citing "Remote trunk tip SHA: …" — even when the staged pointer IS at the submodule's actual trunk tip.

## Root Cause

The hook treats a single parent-repo `DEFAULT_BRANCH` value as if it were universally correct for every submodule. It conflates the parent repository's trunk branch with each submodule's trunk branch. Each submodule is an independent repository with its own remote `HEAD branch:` line; the shared value derived from the parent's remote is not portable across submodules.

## Approach Chosen

Change Gate 2 from a single shared `DEFAULT_BRANCH` lookup to a per-submodule trunk lookup. For each submodule, run `git -C "$sp" remote show origin` and extract the submodule's own `HEAD branch:` line. Fall back to the parent's trunk only when the submodule lookup fails.

Concretely, replace line 54 with:

```bash
SUBMODULE_TRUNK=$(git -C "$sp" remote show origin 2>/dev/null | sed -n 's/.*HEAD branch: //p')
[ -z "$SUBMODULE_TRUNK" ] && SUBMODULE_TRUNK="$DEFAULT_BRANCH"
REMOTE_SHA=$(git -C "$sp" rev-parse "origin/$SUBMODULE_TRUNK" 2>/dev/null || true)
```

Rationale: each submodule has its own remote with its own HEAD branch. The hook is checking the submodule's trunk, not the parent's. The current implementation accidentally uses the parent's trunk because both repositories happened to use the same default branch name during development/testing.

## Alternatives Considered & Why Discarded

- **Hard-code a per-submodule trunk map in the hook** — Rejected. A static map duplicates information already maintained by each submodule's remote and drifts out of date when a submodule renames its trunk. The per-submodule `HEAD branch:` lookup derives the authoritative value from the source of record at runtime.
- **Query `git ls-remote --symref` for each submodule** — Rejected. `git -C "$sp" remote show origin` is already used in the parent-repo path (line 36), so reusing the same command keeps the fix minimal and consistent with the existing code style. `ls-remote --symref` would add a network round-trip and a different parsing path for no functional gain.
- **Skip the check entirely for submodules whose trunk differs** — Rejected. This removes stale-pointer protection rather than fixing the source, weakening the guard that prevents committing stale submodule pointers.

## Key Design Decisions

- **Per-submodule `HEAD branch:` extraction via `git -C "$sp" remote show origin`.** Tradeoff: reuses the existing parsing idiom already present at line 36, keeping the change minimal, at the cost of one extra `git remote show` invocation per submodule (a cheap, local operation).
- **Parent-trunk fallback only on lookup failure.** Tradeoff: preserves today's behavior for local-clone setups where submodule remotes aren't fully configured, while fixing the common case. If the submodule lookup produces no `HEAD branch:` line, the parent trunk is used as a best-effort default.
- **No new override flags or escape hatches.** Tradeoff: keeps the guard's surface minimal and avoids introducing an additional way to bypass the stale-pointer check; existing `SKIP_STALE_POINTER_CHECK` remains the sole override.

## User Intent / Original Prompt

Bug report #2264: "Pre-commit hook uses parent repo's trunk branch name for submodule trunk lookup — fails when submodule trunk differs (e.g. SharedPojos uses 'main' not 'master')." The reporter observed a false-positive stale-pointer block on a `Patents` release PR (trunk=`master`) for the `SharedPojos` submodule (trunk=`main`) whose staged pointer was at `origin/main`.

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
- Add fallback to parent trunk only when submodule trunk lookup fails (no `HEAD branch:` line, network error, empty lookup result, or git command unavailable)
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

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Documentation Sources |
|----|-----------|---------------|---------------------|----------------------|
| SC-1 | `.opencode/hooks/pre-commit` Gate 2 uses a per-submodule trunk lookup (each submodule's own `HEAD branch:` from `git -C "$sp" remote show origin`) instead of the parent repo's `DEFAULT_BRANCH` for the submodule `REMOTE_SHA` rev-parse. | string | grep `.opencode/hooks/pre-commit`: assert line 54 uses `SUBMODULE_TRUNK` derived from the submodule's own `HEAD branch:` line, not the parent's `DEFAULT_BRANCH`. | `.opencode/hooks/pre-commit` (code) |
| SC-2 | The hook falls back to the parent's trunk (`DEFAULT_BRANCH`) only when the submodule trunk lookup fails, where "lookup fails" is defined exhaustively as: (a) `git -C "$sp" remote show origin` produces no `HEAD branch:` line, (b) the command returns a non-zero exit status, (c) `SUBMODULE_TRUNK` is empty after extraction, or (d) the sed extraction matches zero lines. | string | grep `.opencode/hooks/pre-commit`: assert the fallback `[ -z "$SUBMODULE_TRUNK" ] && SUBMODULE_TRUNK="$DEFAULT_BRANCH"` is present and fires only when `SUBMODULE_TRUNK` is empty after the extraction in condition (a) or (c). | `.opencode/hooks/pre-commit` (code) |
| SC-3 | A submodule whose trunk differs from the parent's trunk (e.g. `SharedPojos` trunk=`main`, parent trunk=`master`) is no longer falsely flagged as stale when its staged pointer is at its own trunk tip. | behavioral | Run the pre-commit Gate 2 stale-pointer check against a submodule with a known-different trunk; assert the hook allows the commit when the staged pointer is at the submodule's actual trunk tip. | `.opencode/hooks/pre-commit` (code) |
| SC-4 | A submodule sharing the parent's trunk (e.g. `master`) continues to pass the stale-pointer check without regression. | behavioral | Run the pre-commit Gate 2 stale-pointer check against a submodule sharing the parent's trunk; assert the hook allows the commit when the staged pointer is at the shared trunk tip. | `.opencode/hooks/pre-commit` (code) |
| SC-5 | Any related documentation references to the trunk-detection logic are updated to reflect the per-submodule trunk lookup. | string | grep documentation referencing the trunk-detection logic: assert references describe the per-submodule lookup and the parent-trunk fallback. | `.opencode/commands/submodule-tag-prework.md` (doc) |
| SC-6 | The stale-pointer check is verified against at least 2 submodules with known-different trunks (`SharedPojos` uses `main`, `Patents` uses `master`). | behavioral | Run the pre-commit Gate 2 stale-pointer check against both `SharedPojos` (trunk=`main`) and a submodule sharing the parent's trunk (`master`); assert both pass without false positives. | `.opencode/hooks/pre-commit` (code) |
| SC-7 | Every `SKIP_STALE_POINTER_CHECK=1` invocation in the `.opencode` repository is either (a) absent from all files, or (b) if present, accompanied in the same file by a comment that names a non-bug rationale (release capture of an un-merged branch tip or deliberate override) and does not reference the false-positive bug described in this spec's Problem section. | string | grep -r for `SKIP_STALE_POINTER_CHECK=1` across the `.opencode` repository: assert no invocation is attributable solely to this bug, where attribution is determined by checking each occurrence's adjacent comment for a reference to the false-positive trunk-mismatch bug. | `.opencode/` repository search (code) |

## Requirements

- R-1. `.opencode/hooks/pre-commit` Gate 2 SHALL query each submodule's remote using the submodule's own trunk branch name, not the parent repo's `DEFAULT_BRANCH`.
- R-2. The hook SHALL fall back to the parent's trunk only when the submodule trunk lookup fails.
- R-3. The stale-pointer check SHALL NOT be rewritten beyond the trunk-branch-name source fix.
- R-4. No new override flags or escape hatches SHALL be added beyond the existing `SKIP_STALE_POINTER_CHECK`.
- R-5. The pre-push hook Gate 2 SHALL remain unchanged (separate hook file, separate issue if applicable).
- R-6. The `awk substr` bug from #2258 SHALL remain out of scope (already closed/remediated).
- R-7. The fix SHALL be verified against at least 2 submodules with known-different trunks.
- R-8. Any documentation references to the trunk-detection logic SHALL be updated to reflect the per-submodule trunk lookup.

## Items

### Item 1 (SC-1): Per-submodule trunk lookup

- RED: Enforcement test asserts `.opencode/hooks/pre-commit` line 54 currently derives `REMOTE_SHA` from the parent's `DEFAULT_BRANCH` (fails — change doesn't exist yet).
- GREEN: Replace line 54 with the per-submodule `SUBMODULE_TRUNK` extraction from `git -C "$sp" remote show origin`.
- verify: grep `.opencode/hooks/pre-commit` for `SUBMODULE_TRUNK` and assert line 54 does not use `origin/$DEFAULT_BRANCH`.
- commit: `.opencode/hooks/pre-commit` per-submodule trunk lookup change.

### Item 2 (SC-2): Parent-trunk fallback on lookup failure

- RED: Enforcement test asserts the fallback `[ -z "$SUBMODULE_TRUNK" ] && SUBMODULE_TRUNK="$DEFAULT_BRANCH"` is absent (fails — change doesn't exist yet).
- GREEN: Add the fallback assignment so an empty `SUBMODULE_TRUNK` resolves to `DEFAULT_BRANCH`.
- verify: grep `.opencode/hooks/pre-commit` for the exact fallback line and assert it fires only on empty `SUBMODULE_TRUNK`.
- commit: `.opencode/hooks/pre-commit` fallback change.

### Item 3 (SC-3): Different-trunk submodule no longer falsely flagged

- RED: Behavioral test runs the stale-pointer check against a submodule with trunk=`main` while parent trunk=`master`; assert the hook currently blocks (fails — bug present).
- GREEN: Apply the per-submodule lookup so the staged `origin/main` pointer matches the submodule's own trunk tip.
- verify: Re-run the behavioral test against the different-trunk submodule; assert the hook allows the commit.
- commit: The behavioral test and the per-submodule lookup change.

### Item 4 (SC-4): Shared-trunk submodule no regression

- RED: Behavioral test runs the stale-pointer check against a submodule sharing the parent trunk; assert the hook currently allows the commit (passes before change — establishes baseline).
- GREEN: Apply the per-submodule lookup and confirm the shared-trunk submodule still passes.
- verify: Re-run the behavioral test against the shared-trunk submodule; assert no regression.
- commit: The shared-trunk regression test.

### Item 5 (SC-5): Documentation references updated

- RED: Enforcement test greps documentation referencing trunk detection; assert current docs do not describe the per-submodule lookup (fails — change doesn't exist yet).
- GREEN: Update `.opencode/commands/submodule-tag-prework.md` and any other trunk-detection references to describe the per-submodule lookup and parent-trunk fallback.
- verify: grep the documentation for the per-submodule lookup description and fallback reference.
- commit: The documentation update.

### Item 6 (SC-6): Verify against two different-trunk submodules

- RED: Behavioral test runs the stale-pointer check against both `SharedPojos` (trunk=`main`) and a shared-trunk submodule (`master`); assert current behavior blocks `SharedPojos` (fails — bug present).
- GREEN: Apply the per-submodule lookup so both submodules pass without false positives.
- verify: Re-run the two-submodule behavioral test; assert both pass.
- commit: The two-submodule verification test.

### Item 7 (SC-7): Bug-only override uses removed

- RED: Enforcement test greps for `SKIP_STALE_POINTER_CHECK=1` invocations whose adjacent comment references the false-positive trunk-mismatch bug; assert at least one such use exists or the enumeration is not yet verified (fails — change doesn't exist yet).
- GREEN: Remove any `SKIP_STALE_POINTER_CHECK=1` use attributable solely to this bug, or add a comment naming a non-bug rationale where the use is legitimate.
- verify: Re-grep the `.opencode` repository and assert no invocation remains attributable solely to this bug.
- commit: The override-use remediation.

## Dependencies

- **Reference:** `.opencode/hooks/pre-commit` (existing file)
  - **Relationship:** The fix modifies Gate 2 of this file in place; must be read before implementation.
  - **Status:** Satisfied (file exists at verified location).
- **Reference:** Issue #2258 (awk substr bug)
  - **Relationship:** Explicitly out of scope; must not be reintroduced or reworked by this change.
  - **Status:** Satisfied (already closed/remediated).
- **Reference:** git CLI + sed tooling
  - **Relationship:** The per-submodule lookup uses `git -C "$sp" remote show origin` and `sed -n 's/.*HEAD branch: //p'`; both must be available in the hook's environment.
  - **Status:** Satisfied (already used elsewhere in the hook).
- **Reference:** `SharedPojos` and `Patents` repositories
  - **Relationship:** Required for the behavioral verification of different-trunk submodules (SC-3, SC-6).
  - **Status:** Pending (must be accessible at verification time).

## Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-1, SC-3, SC-4, SC-6 | Phase 1 |
| R-2 | SC-2 | Phase 1 |
| R-3 | SC-1, SC-3, SC-4 | Phase 1 |
| R-4 | SC-2, SC-7 | Phase 1 |
| R-5 | SC-4 | Phase 1 |
| R-6 | SC-1, SC-3, SC-4 | Phase 1 |
| R-7 | SC-6 | Phase 1 |
| R-8 | SC-5 | Phase 1 |

## Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|-------------|
| Pre-commit hook | code | `.opencode/hooks/pre-commit` | Read file; verify line 36 and line 54 |
| Submodule tag prework command | doc | `.opencode/commands/submodule-tag-prework.md` | Read file; verify trunk-detection references |
| Patents release PR #19 | doc | External repository (Patents) | Cited in Evidence section as observed reproduction |

## Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- SC-1: Verifying the per-submodule lookup costs one grep of the hook file. Skipping means the hook still derives the submodule SHA from the parent's trunk, and the false-positive block persists into release work.
- SC-2: Verifying the fallback costs one grep of the fallback line. Skipping means a submodule with an unconfigured remote silently blocks again, reproducing the original false positive at the next release.
- SC-3: Running the different-trunk behavioral test costs minutes of execution time. Skipping means the exact reported bug ships unfixed and the release override remains necessary.
- SC-4: Running the shared-trunk behavioral test costs minutes of execution time. Skipping means a regression in the common shared-trunk case goes undetected and routine commits are blocked.
- SC-5: Verifying the documentation costs one grep of the trunk-detection references. Skipping means docs still describe the parent-trunk lookup, misleading the next maintainer.
- SC-6: Running the two-submodule behavioral test costs minutes of execution time. Skipping means the fix is verified against only one configuration and a different-trunk combination can regress undetected.
- SC-7: Verifying override uses costs one repository grep. Skipping means a stale bug-workaround override remains, masking future false positives and eroding confidence in the guard.

## Edge Cases

- **Input boundary — empty `SUBMODULE_TRUNK`:** When `git -C "$sp" remote show origin` produces no `HEAD branch:` line, `SUBMODULE_TRUNK` is empty and the fallback assigns `DEFAULT_BRANCH`.
  - **Condition:** Submodule remote lacks a HEAD branch declaration or the command output is empty.
  - **Expected behavior:** The hook falls back to the parent's trunk and proceeds with today's behavior.
  - **Resolution:** Fallback assignment `[ -z "$SUBMODULE_TRUNK" ] && SUBMODULE_TRUNK="$DEFAULT_BRANCH"`.
- **Failure mode — submodule not a git repository or missing:** When `$sp` is not a directory or not a git repo, `git -C "$sp"` fails and `SUBMODULE_TRUNK` stays empty.
  - **Condition:** Submodule path absent or invalid; `git -C "$sp"` non-zero exit.
  - **Expected behavior:** Fallback to `DEFAULT_BRANCH`; `REMOTE_SHA` derivation continues with the fallback value.
  - **Resolution:** The existing directory guard `[ -n "$sp" ] && [ -d "$sp" ]` skips non-directory paths; the fallback handles the remainder.
- **State transition — submodule trunk renamed:** If a submodule renames its trunk, the per-submodule `HEAD branch:` line reflects the new name.
  - **Condition:** Submodule trunk renamed between runs.
  - **Expected behavior:** The lookup returns the new name and compares against the correct tip.
  - **Resolution:** Derived from the source of record at runtime; no static map to go stale.
- **Concurrency — simultaneous commits across submodules:** The hook loops over `SUBMODULE_PATHS` sequentially; each submodule lookup is independent.
  - **Condition:** Multiple submodules staged in one commit.
  - **Expected behavior:** Each submodule's own trunk is used; no cross-submodule state is shared beyond the parent fallback.
  - **Resolution:** Per-submodule `SUBMODULE_TRUNK` is scoped inside the loop.
- **Recovery — stale pointer legitimately at an un-merged tip:** A release capture may deliberately point at a branch tip not yet merged to trunk.
  - **Condition:** Staged pointer differs from the submodule's trunk tip by design.
  - **Expected behavior:** The hook blocks; the `SKIP_STALE_POINTER_CHECK` override remains the documented deliberate-action path.
  - **Resolution:** No change to override semantics; SC-7 ensures overrides carry a non-bug rationale comment.

## Change Control

- **2026-08-11** — Added Success Criteria (SC) table and Requirements section to the retroactively-imported spec. The spec was frontmatter-only; the body content (Problem, Scope, Approach, Impact, Evidence) was preserved from `remote.md` and the SC table was derived from that content so the writing-plans analyze gate (previously BLOCKED with `NO_SUCCESS_CRITERIA`) can proceed. Authorized by: revision request for issue 2264.
- **2026-08-11** — Structural validation revision. Removed the `etc.` escape-hatch from SC-2 (replaced with an exhaustive four-condition enumeration of lookup failure); added required sections (Alternatives Considered & Why Discarded, Key Design Decisions, User Intent / Original Prompt, Items, Dependencies, Traceability, Documentation Sources, Enforcement Gate, Edge Cases); added a Cost Frame section with per-SC dark-prose-007 cost-frame language; added the Documentation Sources column (5th) to the SC table; reworked SC-7 to a deterministic, non-judgment criterion enumerating the check and the legitimate-rationale condition. All prior substantive content preserved verbatim. Authorized by: revision request for issue 2264.
- **2026-08-11** — Traceability revision. Added requirement R-8 ("Any documentation references to the trunk-detection logic SHALL be updated to reflect the per-submodule trunk lookup") and mapped SC-5 to R-8 in the Traceability table, resolving the orphan-SC traceability gap flagged by spec validation. No existing requirement or SC was weakened or removed; all prior substantive content preserved verbatim. Authorized by: revision request for issue 2264.
