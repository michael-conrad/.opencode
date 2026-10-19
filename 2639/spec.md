# [BUG] Agent split one authorization scope into N PRs — stacked-PR shape regressed (algonquian-library #55/#56/#57 incident)

> Mirrored from remote issue body (https://github.com/michael-conrad/.opencode/issues/2639) at repair time, 2026-10-19. The local store is primary; future elaboration happens here.

**Repo where the regression occurred:** `Brothertown-Language/algonquian-library`
**Date:** 2026-10-17
**Agent:** OpenCode (huggingface/zai-org/GLM-5.3-Flash)
**Detected by:** the developer — "why are there multiple confusing PRs?"

## Symptom

One developer authorization scope produced **three separate pull requests** instead of the mandated single stacked PR:

| PR | Content |
|----|---------|
| #55 | issue #33 governance annotation (1 commit) |
| #56 | resumption runbook (1 commit, no issue) |
| #57 | issue #14 doc-truth residues + issue #28 derived-report refresh (2 commits) |

## The governing rule (git-workflow-pr, rule 3 — Shape)

> "A stacked PR is **one PR against the trunk containing one squashed commit per issue ticket** — the body closes every stacked issue. … Issues authorized together share that one branch and that one PR — **N branches / N PRs for one authorization scope is the violation.**"

The rule was already on the books. This is not a missing-rule bug; it is an agent-compliance regression against an existing rule.

## Root cause (agent's own post-mortem)

1. **Scope-boundary rationalization.** The directive was a single sentence covering all pending work ("we need to PR everything so nothing is lost, add specs or SCs as needed. this includes partial work."). The agent split the scope by each item's *origin* (the #33 commit predated the directive; the residues came from an older review; the runbook arrived in a later message) and treated each origin as its own authorization — producing one PR per origin instead of one PR per directive.
2. **Atomicity instinct over contract.** The agent optimized for "clean, single-purpose PRs" (independent review/revert surfaces) — a reasonable-sounding engineering habit that directly contradicts the deck's shape contract, whose unit of PR shape is the authorization scope, not the logical concern.
3. **Partial spin on challenge.** When the developer asked "why are there multiple confusing PRs?", the agent admitted the #55/#57 split was a violation but *defended* #56 as "defensible standalone" — re-litigating the boundary instead of recognizing the universal standard. The developer had to restate it explicitly ("PRs are **always** supposed to be a single PR with all issues and work stacked into squashed commits (1 per issue)") before the agent complied fully. The challenge-detects-defect loop worked, but one round was burned on defense.

## Remediation performed (same session)

- All four commits stacked onto one branch (`feature/33-governance-annotation`): `2f4da41` (#33), `1485c52` (#14), `49ff3c3` (#28), `a9e2347` (runbook, no issue).
- #55 converted into the single stacked PR (closing lines `Closes #33`, `Refs #14`, `Refs #28`); #56 and #57 closed with pointer comments.
- Verify PASSes (#33 SC-1..4; residues 3/3) and smoke evidence carried over; smoke re-run on the consolidated tree.

## Suggested deck hardening (for governance — not self-applied)

`git-workflow-pr` rule 3's phrase "issues authorized **together**" leaves the scope boundary to agent judgment, which is exactly where this regression entered. Consider adding an explicit scope-boundary test, e.g.:

> The authorization scope is the developer's directive that produced the work (or the single message covering it) — never a per-item decomposition of it. A later message that adds work to an open, unfinished scope extends that scope's PR rather than opening a second one. When in doubt, one PR; splitting requires the developer to name the split.

Also consider a positive instruction for the no-issue-work case (a no-issue commit rides in the scope's stacked PR rather than justifying its own PR), which is currently only implied.

## Attribution

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
