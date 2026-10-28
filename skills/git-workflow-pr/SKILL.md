---
name: git-workflow-pr
description: "Load before opening any pull request, preparing work for review, or updating an existing PR — in any repo, whenever PR-boundary authorization arrives or the work reaches the review boundary. PRs are for completed and fully tested work; partial PRs require explicit special authorization. Squash the branch's work to one reviewable commit per issue, write a PR body with summary and executed-test evidence, then HALT — humans merge, never the agent."
license: MIT
provenance: AI-authored, .opencode#2490; submodule discipline rules, .opencode#2563; PR-body contract, .opencode#2615; scope-boundary provision, .opencode#2639; agent-owned scoped branch rewrite, .opencode#2665
---

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2490; submodule discipline rules, .opencode#2563; #2509 stacked-PR definition; #2519 PR-completion invariant; release PRs are parent-repo artifacts, .opencode#2592; PR-body contract, .opencode#2615; scope-boundary provision, .opencode#2639; merge+approval boundary and completion-gate check, .opencode#2668; agent-owned scoped branch rewrite, .opencode#2665 -->

# git-workflow-pr

1. **PR-completion invariant.** PRs are only for COMPLETED and FULLY TESTED
   work. When PR-boundary authorization arrives, either (a) the issue's full
   assigned scope is implemented and verified — proceed to the checklist — or
   (b) scope is incomplete: continue implementation and open the PR only at
   full scope completion and verification. Exceptions: (1) the developer
   **explicitly** states the PR is partial — stage-gate phrases (`approved
   for pr`, `go`, `proceed`) never qualify; (2) the spec defines
   merge-boundary workflow and this PR covers exactly its spec-assigned
   scope — the invariant still applies to the final PR. Also required:
   verify pass PASS on the deliverable's SCs; structural checks
   (lint/typecheck/build) ran clean. Not ready → `verify` first, not a PR.
2. **Pre-create checklist — every item before `gh pr create` / `gb` create.**
(a) every item assigned to this PR by the spec or by recorded special
authorization has an implementation commit or an explicit N/A; (b) the full
test suite ran **green** this session with captured output — red output
blocks PR creation until every failure is remediated or dispositioned via a
filed fix issue; "the failures pre-existed" is a defect to file, never a
   pass-through (#2553); (c) fresh-context
   `verify` PASS recorded against the issue's spec. Any failure → halt and
   report the gap — never create the PR anyway.
   (d) **Submodule pointer inclusion:** a parent-repo PR includes pending
   submodule pointer bumps — a bump exists when the submodule's checked-out
   HEAD differs from the recorded gitlink.
   (e) **No pointer-only parent PRs:** a parent-repo PR consisting only of
   pointer bumps is forbidden; release PRs are exempt because their
   changelog, version, and tag-prep content is the real content.
   (f) **Submodule-PR ordering gate:** parent-repo PR creation is blocked
   while any submodule PR is pending (filed and unmerged on the submodule's
   tracker) — this applies to every parent PR, including unrelated changes.
   After the submodule PRs merge, the parent PR carries the pointer to the
   merged submodule trunk tip, re-synced with the parent's verification
   re-run against the composed state before creation.
3. **Shape.** A stacked PR is **one PR against the trunk containing one
   squashed commit per issue ticket** — the body closes every stacked issue.
   Squash WIP to one commit per issue at PR creation; a stacked branch chain
   rides in that one PR, never as one PR per stacked layer.
   **Agent-owned per-issue squash on a published branch.** The producing agent —
   holding the authorization to prepare a PR from its own feature branch —
   produces the per-issue squash itself and pushes the rewritten branch with
   `git push --force-with-lease origin <branch>`; the agent performs the squash
   and the push itself and does not solicit a developer's force-push decision;
   the PR body states that the branch was rewritten (the squash of the branch's
   per-issue commits to one commit per issue). **Scoped branch rewrite.** This
   authorization binds to the producing agent's own feature branch, and before
   the push the agent establishes each of three conditions: (1) the branch was
   created by this agent for the work in hand — not created by another party;
   (2) the branch has not been merged into the trunk; (3) no other party holds
   the branch — another party holds it when that party created it, commits to
   it, or works from it, and the producing agent's own push of the branch to
   the origin remote to carry the PR is not a hold by another party. A branch
   failing any one of the three conditions falls under the floor's general
   gate — the developer's explicit naming of the action and its target. The
   agent-owned authorization covers `git push --force-with-lease` only: an
   unleased `git push --force` proceeds only under the floor's general gate. Issues authorized
   together share that one branch and that one PR — N branches / N PRs for one
   authorization scope is the violation. **Scope boundary.** The
   authorization scope is the developer directive that produced the work —
   the single message covering it — never a per-item decomposition of that
   directive. A later message that adds work while that scope's PR is open
   extends that scope: its commits ride the scope's open branch and PR,
   never a second branch or PR. A commit with no issue ticket rides in the
   scope's stacked PR — it never justifies its own PR. When in doubt, one
   PR; splitting into multiple PRs requires the developer to have named the
   split. The mandate is universal: it applies
   to all PRs, including release PRs. **Hazard guard:**
   the single PR for an issue exists only at that PR's assigned-scope
   completion — a partial-scope PR that merges closes the linked issue as
   completed (exception (2) merge-boundary workflow above applies).
   **Release PRs are parent-repo artifacts only.** In a parent/submodule
   repository family, a submodule repository never hosts its own release PR,
   changelog release section, version bump, or tag — its content ships via
   the parent's pointer capture, and the release PR's verification runs in
   the parent's composed checkout: the clean-room gate clones the parent
   repository and resolves every submodule through the parent's recorded
   pointers (the release-promoter card owns the gate mechanics).
4. **Body.** A fixed contract — closing lines at the top, then the sections
   below; no other sections are added (release PR bodies follow the release
   composition the `release-promoter` card states).
   - **Closing lines (body top).** Uniform keyword `Closes` — same-repo
     `Closes #N`, cross-repo `Closes owner/repo#N`. `Refs #N` for references
     that must not auto-close. Prohibited: a bare `#N` with no keyword, and
     the deck-qualified `repo#N` form in a closing-keyword position —
     neither closes anything. Closing keywords auto-close the remote issue
     at default-branch merge on platforms that support it: GitHub confirmed
     for both forms; GitBucket has no closing-keyword auto-close — cleanup
     performs closure there. Cleanup verifies and syncs from the closure
     state the keywords produced.
   - `## Summary` (required) — 2–4 sentences, executive voice, sourced from
     the authorizing spec/issue intent; implementation-detail narration is
     the defect form.
   - `## Changes` (optional) — short bullets; omitted for single-purpose PRs.
   - `## Evidence` (required) — real executed output: test results with
     actual numbers, the fresh-context verify verdict, structural gate
     results. Assertions in place of output are not accepted.
   - `## Submodule bump` — required exactly when the PR carries pointer
     bumps, omitted otherwise. Per bump: the old→new SHA, the submodule
     PRs/issues it delivers (one line each), and the effect on the project.
   - `## Provenance` — spec path, verify record; byline footer.
   - **Anti-bloat:** no attestation boilerplate, no evidence-taxonomy
     tables, no artifact-chain output. A normal body fits ~30 lines;
     longer requires justification (release PRs exempt as
     changelog-bearing).
5. **Create via the platform CLI** (`gh pr create` / `gb` equivalent) —
   authenticated tooling, never raw API calls.
6. **HALT after creation — merge and approval actions withheld.** PR merge
    is a human gate: no `gh pr merge`, `gb pr merge`, merge API submission,
    or auto-merge enablement, ever. The gate extends to merge approvals: no
    approving review is submitted (`gh pr review --approve` and
    equivalents), no approving review is created in pending form — a pending
    approving review discovered is deleted, not submitted. Comment-only and
    request-changes reviews remain permitted. These are structural
    boundaries: no authorization reaches them. Notify and stop; update
    the PR only on review feedback.
7. **Completion-gate check.** At work completion — before the PR-prep step —
    audit the session record: the work's own record shows no performed merge,
    no submitted approving review, and no pending approving review left
    standing (a discovered pending approving review is deleted). Any hit is a
    boundary violation: report it, and do not proceed to PR prep until the
    record is clean.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
