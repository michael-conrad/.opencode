---
remote_issue: 2402
remote_url: "https://github.com/michael-conrad/.opencode/issues/2402"
last_sync: "2026-09-01T03:29:39Z"
source: github
---

> Full spec and plan artifacts: https://github.com/michael-conrad/.opencode/tree/issues-data/2402/

## Problem

The `finishing-a-development-branch` checklist flags missing Co-authored-by commit trailers on an agent's own unmerged feature branch as a decision-requiring blocker, surfacing a force-push authorization question to the developer. On an agent-created, unmerged, unshared branch this is an auto-fixable, agent-owned remediation — the agent should amend its own commits and force-push its own branch without soliciting a developer decision.

## Scope

- Classify missing Co-authored-by trailers on the agent's own unmerged feature branch as an auto-fixable MISSING-ELEMENT, not a developer-facing blocker.
- Add an explicit agent-owned remediation procedure: amend/squash the agent's own commits to add repo-standard trailers, then force-push with `--force-with-lease`.
- Auto-fix missing "Co-authored with AI:" footer bylines in new files via the producing agent, preserving existing bylines.
- Add a scope guard confining the auto-force-push carve-out to the agent's own unmerged, unshared branch, refusing shared/merged/trunk branches and deferring to the generic force-push authorization gate.

**Out of scope:** any change to mandatory co-author attribution requirements in `080-code-standards.md`; the generic force-push authorization gate; the PR-time squash trailer-application step; WIP implementation checkpoint commit policy.

## Approach

Reclassify missing-trailer handling at finishing from decision-requiring-blocker to agent-owned auto-remediation, scoped strictly to the agent's own unmerged, unshared feature branch. Reuse the existing sanctioned `--force-with-lease` mechanism and trailer format already established across the deck (including the precedent in `create-pr.md` "Step 7.2.3: Rebase on Stale Base"). Auto-fix missing new-file footer bylines, preserving existing ones. Add a scope guard so the carve-out never leaks to shared, merged, or trunk branches, which remain governed by the generic force-push authorization gate.

## Impact

- **Risk 1:** Auto-force-push carve-out leaks to shared/merged/trunk branches — mitigated by the scope-guard SC (SC-4/SC-5) with structural + behavioral verification.
- **Risk 2:** Trailer fix bypasses mandatory attribution — mitigated by never skipping/weakening the check; auto-fix only adds missing trailers and bylines.
- **Dependencies:** `080-code-standards.md` (mandatory attribution), `create-pr.md` force-push precedent, finishing SKILL.md agent-owned remediation mandate.
- **Call to action:** Approve the spec to proceed with plan + implementation.
