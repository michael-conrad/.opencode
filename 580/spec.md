# Spec: PR Creation Must Verify Branch Is Up-to-Date with Target Base

**Issue:** #580
**Status:** DRAFT
**Concern:** Single — PR creation must verify branch is up-to-date with target base before creating PR

## Problem

The `pr-creation` pipeline creates PRs without a verified gate confirming the source branch is up-to-date with the target base. Multiple rebase/staleness checks exist across the pipeline (`review-prep/push-and-cleanup.md` Step 1.25, `pr-creation/squash-push.md` Step 3.5, `pr-creation/create-pr.md` Step 4.8) but no downstream gate (`enforcement-gate`, `pre-pr-checklist`) verifies that a staleness check was performed and passed.

This results in PRs that may show as "has conflicts that need to be resolved" on GitHub, requiring manual intervention before merge.

**Root cause:** The checks exist but are unverifiable — they run, produce no evidence, and cannot be confirmed by any downstream gate. The `pre-pr-checklist` has no staleness check at all.

## Context: What Already Exists

The codebase already has rebase-based staleness detection at multiple points:

| Location | Check | Verified by Gate? |
|---|---|---|
| `review-prep/push-and-cleanup.md` Step 1.25 | `git rev-list --count --left-right origin/...HEAD` + auto-rebase | No |
| `pr-creation/squash-push.md` Step 3.5 | `git fetch origin && git rebase origin/` | No |
| `pr-creation/create-pr.md` Step 4.8 | `git fetch origin && git rebase origin/` | No |
| `pr-creation/enforcement-gate.md` Step 1.5d | Merge conflict check via GitHub API (OPEN PRs only) | No |

**The gap is not the check — it is the verification gate.** The enforcement gate and pre-pr-checklist must independently verify staleness before allowing PR creation.

## Supersession Notes

This spec replaces the original #580 proposal. Key changes from the original:

- **Approach changed:** `git merge --no-commit --no-ff` replaced with rebase-based staleness detection (`git rev-list --count --left-right` + `git rebase`), aligning with the existing codebase approach and trunk-based development (TBD) per #1540
- **Release-promotion removed:** SC-6/SC-7 from original are moot — `release-promotion.md` deleted per #1540
- **`dev`-specific assumptions removed:** Target is the trunk per TBD, not `dev`
- **No intermediate evidence artifact:** The enforcement gate verifies staleness by running the git command directly — git state IS the evidence. No JSON file, no file-path coupling, no stale-artifact risk.

## Proposed Behavior

Before creating any PR, the enforcement gate MUST independently verify the branch is up-to-date with the target base:

1. **Fetch the target branch** from origin
2. **Check staleness** via `git rev-list --count --left-right origin/...HEAD`
3. **If behind > 0:** auto-rebase via `git rebase origin/`
4. **Classify conflicts** per the three-tier system (already handled by `conflict-resolution` skill)
5. **Only then create the PR** — with live verification that the branch is current

This applies to ALL PRs (feature branches) — no separate release-promotion path.

The enforcement gate does NOT rely on a prior step's evidence artifact. It performs its own live check. Git state is the single source of truth.

## Conflict Tier Classification

Per `conflict-resolution` skill (unchanged from original):

| Tier | Pattern | Auto-resolve? | Example |
|------|---------|--------------|---------|
| 1 | Trivial (add/add, whitespace) | Yes | `.gitignore` add/add — take union |
| 2 | Textual (both sides changed same region) | Yes + note | Config file edits — combine both |
| 3 | Intent (semantic conflict) | No — HALT | Logic changes that contradict |

## Acceptance Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `pr-creation/enforcement-gate.md` fetches target branch and checks staleness via `git rev-list --count --left-right` before allowing PR creation | `behavioral` | `opencode-cli run` — verify stderr shows fetch + rev-list |
| SC-2 | When branch is behind target, enforcement gate auto-rebases before PR creation | `behavioral` | `opencode-cli run` with stale branch scenario |
| SC-3 | Tier 1/2 conflicts during rebase are auto-resolved via `conflict-resolution` skill (already exists) | `behavioral` | `opencode-cli run` with conflict scenario |
| SC-4 | Tier 3 conflicts cause HALT with clear report (already exists) | `behavioral` | `opencode-cli run` with intent-conflict scenario |
| SC-5 | `pre-pr-checklist.md` includes staleness check in its checklist | `string` | grep for staleness-check reference in pre-pr-checklist.md |
| SC-6 | Staleness check applies to ALL PRs regardless of target branch (no `dev`-specific logic) | `behavioral` | `opencode-cli run` with non-dev target |
| SC-7 | No references to `release-promotion` or `dev`-specific staleness logic remain | `string` | grep for stale references |
| SC-8 | Behavioral test: agent creates PR only after live staleness verification passes | `behavioral` | `opencode-cli run` full PR creation scenario |

### SC Integrity Mandate

**No Lobotomizing Tests:** Removing or weakening a behavioral test assertion to work around a timeout, failure, or infrastructure issue is a CRITICAL VIOLATION. All behavioral SCs (SC-1, SC-2, SC-3, SC-4, SC-6, SC-8) MUST be verified via `assert_semantic` with clean-room semantic inspector. No substitution with grep/string/structural evidence.

**100% Clean Pass Required:** All SCs MUST pass with 100% clean PASS. Any SC that fails, is skipped, deferred, or bypassed marks ALL SCs as FAIL. A PR created with any unverified or bypassed SC MUST be immediately rejected and trashed as defective and unusable.

**SC Lobotomy Prohibition:** No SC may be removed, weakened, deferred, or blocked to evade implementation. If an SC is structurally valid and cannot be implemented, report BLOCKED with root cause and HALT. Do NOT modify the spec to remove or weaken the SC.

## Affected Files

| File | Change |
|------|--------|
| `skills/git-workflow/tasks/pr-creation/enforcement-gate.md` | Add staleness check step: fetch target, `git rev-list --count --left-right`, auto-rebase if behind, route conflicts to `conflict-resolution` |
| `skills/pr-creation-workflow/tasks/pre-pr-checklist.md` | Add staleness check to checklist |
| `tests/behaviors/staleness-gate.sh` | New behavioral test |

## Non-Goals

- Does NOT change the rebase mechanism (already correct: `git rev-list --count --left-right` + `git rebase`)
- Does NOT add a new merge-check (`git merge --no-commit --no-ff` is not the right approach)
- Does NOT re-introduce `release-promotion` or `dev`-specific logic
- Does NOT change the `conflict-resolution` skill (already handles three-tier classification)
- Does NOT add intermediate evidence artifacts or file-based state passing between pipeline stages
- Does NOT change submodule handling (already handled by `submodule-liveness-check` sub-agent)

## Risks

| Risk | Likelihood | Mitigation |
|------|-----------|------------|
| Staleness check at enforcement-gate duplicates review-prep Step 1.25 | Low | Belt-and-suspenders — review-prep rebase is for compare URL accuracy; enforcement-gate rebase is for PR creation accuracy. Target may have advanced between stages. |
| Behavioral test requires real remote for staleness detection | Medium | Use test submodule repos per #1617 pattern |

## Interdependencies

| Issue | Relationship | Action Required |
|-------|-------------|-----------------|
| #492 | Complementary — same `git rev-list --count --left-right` staleness mechanism for stale-branch detection | Mark as related in both issues |
| #682 | HIGH — Re-architects git-workflow skill; pr-creation task files may be relocated | Sequence #580 after #682 or coordinate changes |
| #1222 | MEDIUM — Enforcement-Gated Contract Schema; standardized hand-off contracts | Align enforcement gate with contract schema if adopted |
| #1350 | MEDIUM — Platform-agnostic PR operations; PR creation routed through dispatcher | Hook enforcement gate into dispatcher if adopted |
| #1441 | MEDIUM — Hard-gate dependency ordering for cleanup tasks | Ensure new gate is non-skippable per #1441 |
| #1540 | COMPLETED — Trunk-based development; removed dev/release-promotion assumptions | No action needed (already completed) |
| #1617 | Test fixture repos for behavioral tests | Use test fixture repos for staleness behavioral test |
| #1644 | LOW — Branch-Verification Mandate for audit pre-flight; same `git rev-list` mechanism | Could share utility code |
| #1666 | LOW — SC-to-plan coverage gate after plan creation | Different pipeline stage; no direct conflict |
| #1676 | COMPLETED — Mechanical dev→$DEFAULT_BRANCH replacement | No action needed (already completed) |

**No circular dependencies detected.** All dependencies are one-directional (this spec depends on or is related to other issues; no other issue depends on this spec).

## Change Control

- **Status:** DRAFT
- **Supersedes:** Original #580 (approach changed: merge-check → rebase-check at enforcement gate)
- **Superseded by:** None
- **Blocking Issues:** None

---

### Lifecycle

- **2026-05-14:** Issue created
- **2026-07-02:** Plan created — `.opencode/.issues/580/plan.md` (1 phase)
- **2026-07-11:** Spec revised — added SC Integrity Mandate, interdependency table, created local spec.md

> **Full spec and artifacts: [`.opencode/.issues/580/`](https://github.com/michael-conrad/.opencode/tree/issues-data/580)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/580/` — implementation plan, dependency contracts, audit findings

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
