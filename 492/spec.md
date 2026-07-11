---
type: SPEC
status: DRAFT
version: 4.0
created: 2026-05-09
updated: 2026-07-11
labels: [SPEC, pipeline, drift-detection, pre-pr, stale-branch]
priority: medium
---

# [SPEC] Stale-branch detection before PR creation

## Problem

Feature branches can be forked from a stale `main` checkout and accumulate commits while `main` moves ahead. When the developer pushes the branch and creates a PR, the diff is against an outdated base — the PR may conflict, duplicate work already done on `main`, or miss required changes. This wastes review cycles and creates avoidable rebase work.

The `drift-detection` task file exists at `.opencode/skills/audit/tasks/drift-detection.md` but has no automated trigger. It is designed for manual spec-vs-code comparison, not for pre-PR staleness detection.

**This is NOT about post-merge drift** (spec vs codebase diverging over time). That is a separate concern. This spec addresses **pre-PR staleness**: detecting that a feature branch's base is behind `main` before the branch is pushed or a PR is created.

## SC Integrity Mandate

**No SC may be weakened, removed, deferred, or blocked.** Any attempt to bypass an SC (by changing its evidence type, removing it from the spec, deferring it to a future issue, or marking it as "blocked") is a CRITICAL VIOLATION and marks ALL SCs as FAIL. The PR must be immediately rejected and trashed as defective and unusable.

**All SCs must achieve 100% clean PASS.** A single SC failure is a total failure of the implementation. There is no partial credit, no "PASS with caveats", no "functionally equivalent" rationalization. Every SC must be verified with evidence matching its declared evidence type per the Evidence Type Enforcement Matrix in `080-code-standards.md`.

**Any attempt to skip, defer, or bypass an SC marks ALL SCs as FAIL.** No single-SC carveouts. No "deferred to follow-up" exceptions. No "blocked by external dependency" rationalizations. If an SC cannot be implemented, the entire spec fails.

## Requirements

- [ ] Integration point: add a staleness-check + auto-rebase step to `review-prep/push-and-cleanup.md` before the existing Step 1.5 rebase
- [ ] Detection method: `git rev-list --count --left-right origin/$DEFAULT_BRANCH...HEAD` — if `behind > 0`, the branch is stale
- [ ] On staleness detected: **auto-rebase** the feature branch onto `origin/$DEFAULT_BRANCH`. The agent performs the rebase autonomously — this is a mechanical operation, not a developer decision
- [ ] On rebase success (clean): proceed normally to push and PR creation
- [ ] On rebase conflict: classify per `conflict-resolution` skill's three-tier system:
  - **Tier 1-2 (trivial/textual):** auto-resolve, proceed
  - **Tier 3 (intent):** HALT and escalate to developer with conflict details
- [ ] On clean (behind == 0): proceed normally to push and PR creation

## Open Questions (Resolved)

| Question | Resolution |
|----------|-----------|
| Trigger mechanism? | `git-workflow --task review-prep` — the pre-PR gate. Not a webhook, not scheduled. |
| Merge scope? | Every PR creation. Not limited to spec-linked PRs — any stale branch is a problem. |
| On staleness: halt or auto-fix? | **Auto-rebase.** Agent rebases onto `origin/$DEFAULT_BRANCH`. Only escalate to developer on Tier 3 (intent) conflicts. |
| Who owns implementation? | `git-workflow` skill — add a staleness-check + auto-rebase sub-step to `review-prep/push-and-cleanup.md`. The `drift-detection` task file is NOT the right mechanism for this; this is a git-level check, not an adversarial audit. |
| Target branch? | `$DEFAULT_BRANCH` (resolved at runtime via `git remote show origin`). Per trunk-based development (#1657), the canonical target is `main`. |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `review-prep/push-and-cleanup.md` includes a staleness-check step before push | `behavioral` | Clean-room sub-agent evaluates agent output: agent runs staleness check (`git rev-list --count --left-right`) before push |
| SC-2 | Staleness detected → agent auto-rebases onto `origin/$DEFAULT_BRANCH` | `behavioral` | Clean-room sub-agent evaluates agent output: agent runs rebase on behind > 0, does not halt |
| SC-3 | Rebase succeeds → proceeds to push and PR creation | `behavioral` | Clean-room sub-agent evaluates agent output: agent pushes and creates PR after successful rebase |
| SC-4 | Tier 3 conflict during rebase → HALT and escalate to developer | `behavioral` | Clean-room sub-agent evaluates agent output: agent halts on intent conflict, reports conflict details |
| SC-5 | Clean branch (behind == 0) → proceeds normally | `behavioral` | Clean-room sub-agent evaluates agent output: agent proceeds through push and PR creation |
| SC-6 | Behavioral enforcement test file exists for stale-branch auto-rebase | `string` | File existence check: `tests/behaviors/492-stale-branch-auto-rebase.sh` exists |
| SC-7 | Behavioral enforcement test passes (GREEN) — agent auto-rebases on staleness | `behavioral` | Run `bash .opencode/tests/behaviors/492-stale-branch-auto-rebase.sh` — exits 0 with all assertions passing |

## Files Affected

| File | Change |
|------|--------|
| `.opencode/skills/git-workflow/tasks/review-prep/push-and-cleanup.md` | Add staleness-check + auto-rebase step before existing Step 1.5 |
| `.opencode/tests/behaviors/492-stale-branch-auto-rebase.sh` | New behavioral test for stale-branch auto-rebase |

## Test Fixture Repos

Behavioral tests for this spec require a real remote to execute `git fetch`/`git rebase` against `origin/$DEFAULT_BRANCH`. Two blank fixture repos are available for this purpose — no fixed roles, no pre-seeded content:

| Repository | URL |
|------------|-----|
| test-submodule-1 | `https://github.com/michael-conrad/test-submodule-1` |
| test-submodule-2 | `https://github.com/michael-conrad/test-submodule-2` |

The test script pushes content to the repo at runtime (main branch, feature branch, ahead commits). Either repo can be used as the remote origin.

## Constraints

- Staleness check is `git rev-list --count --left-right`, not a full drift-detection audit
- On staleness: auto-rebase onto `origin/$DEFAULT_BRANCH` — agent performs rebase autonomously
- On Tier 1-2 conflict: auto-resolve per `conflict-resolution` skill
- On Tier 3 conflict: HALT, escalate to developer with conflict details
- On clean (behind == 0): proceed normally
- This is a git-level check, not an adversarial-audit invocation — the `drift-detection` task file is for spec-vs-code comparison, not for branch staleness
- Target branch is `$DEFAULT_BRANCH` (resolved at runtime), per trunk-based development (#1657)

## Dependencies

- **`.opencode#1832` — Test environment must replicate production** (CLOSED — completed). This spec's behavioral test scripts depend on the test harness fixes from #1832. Since #1832 is now merged, this dependency is resolved.

## Interdependencies

| Issue | Concern | Action |
|-------|---------|--------|
| **`.opencode#1645` — Baseline generation for audit** | Both carry the `drift-detection` label. Different scope (branch staleness vs. audit claim drift) but share the drift-detection concern area. | No direct coupling — monitor for scope overlap during implementation. |
| **`.opencode#1644` — Branch-Verification Mandate for audit** | Both deal with branch state verification. #1644 verifies the correct branch is checked out before audit; #492 detects staleness before PR creation. Shared concern area: branch integrity. | No direct coupling — #1644's branch check is orthogonal to #492's staleness check. Monitor for scope overlap during implementation. |
| **`.opencode#1657` — Trunk-based development** | #1657 removed the dev branch. All branch comparison logic must reference `$DEFAULT_BRANCH` (main), not `dev`. | This spec already uses `$DEFAULT_BRANCH`. No further action needed. |

## Change Control

### v4.0 — Trunk-based development alignment, SC integrity mandate, dependency updates

**2026-07-11:**
- Changed all `origin/dev` references to `origin/$DEFAULT_BRANCH` per trunk-based development (#1657)
- Corrected `adversarial-audit/tasks/drift-detection.md` path to `audit/tasks/drift-detection.md`
- Added SC Integrity Mandate section with zero-tolerance SC failure policy
- Split SC-6 into SC-6 (file existence, string) and SC-7 (behavioral test pass, behavioral)
- Updated dependency: #1832 is CLOSED — dependency resolved
- Added interdependency with #1644 (branch verification)
- Added interdependency with #1657 (trunk-based development)
- Updated version to 4.0

### v3.2 — Add interdependency marker for #1645

**2026-07-09:** Added reciprocal interdependency marker referencing `.opencode#1645` for shared drift-detection concern area.

### v3.1 — Add test fixture repos

**2026-07-01:** Added Test Fixture Repos section documenting `test-submodule-1` and `test-submodule-2` as available real remotes for behavioral tests. These replace the local bare repo approach that caused all 6 SCs to FAIL in the adversarial audit.

### v3.0 — Pinned integration point

**2026-07-01:** Pinned integration point to `review-prep/push-and-cleanup.md`. Fixed `git rev-list` syntax. Removed baseline comparison requirement. Updated verification methods.

### v2.1 — Auto-rebase, not halt

**2026-07-01:** Changed staleness response from "HALT, require developer to rebase" to "auto-rebase, only escalate on Tier 3 intent conflicts."

### v2.0 — Complete rewrite

**2026-07-01:** Rewrote from "post-merge drift-detection trigger" to "pre-PR stale-branch detection."

---

🤖 OpenCode (deepseek-v4-flash)
