---
name: git-workflow-pr
description: "Load before opening any pull request, preparing work for review, or updating an existing PR — in any repo, whenever PR-boundary authorization arrives or the work reaches the review boundary. PRs are for completed and fully tested work; partial PRs require explicit special authorization. Squash the branch's work to one reviewable commit per issue, write a PR body with summary and executed-test evidence, then HALT — humans merge, never the agent."
license: MIT
provenance: AI-authored, .opencode#2490
---

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2490; #2509 stacked-PR definition; #2519 PR-completion invariant -->

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
   authorization has an implementation commit or an explicit N/A; (b) the
   full test suite ran this session with captured output; (c) fresh-context
   `verify` PASS recorded against the issue's spec. Any failure → halt and
   report the gap — never create the PR anyway.
3. **Shape.** A stacked PR is **one PR against the trunk containing one
   squashed commit per issue ticket** — the body closes every stacked issue.
   Squash WIP to one commit per issue at PR creation; a stacked branch chain
   rides in that one PR, never as one PR per stacked layer. **Hazard guard:**
   the single PR for an issue exists only at that PR's assigned-scope
   completion — a partial-scope PR that merges closes the linked issue as
   completed (exception (2) merge-boundary workflow above applies).
4. **Body.** Executive summary of what changed and why; the executed-test
   evidence (real output, not assertions); linked issue; provenance pointers.
5. **Create via the platform CLI** (`gh pr create` / `gb` equivalent) —
   authenticated tooling, never raw API calls.
6. **HALT after creation.** PR merge is a human gate. Notify and stop; update
   the PR only on review feedback.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
