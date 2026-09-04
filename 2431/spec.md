## Problem

The stacked-PR workflow has no ordering gate requiring a parent-repo stacked PR to wait for its in-scope submodule PRs to merge first. The pipeline therefore creates parent PRs whose only commit predates the submodule merges and carries stale submodule pointers — producing an open, structurally incomplete PR whose tree resolves pre-fix submodule SHAs and is unmergeable as-is, defeating the PR's purpose. This fired for real during Butter #304 and slipped through every existing pipeline gate.

## Verified Instance

During Butter repo issue #304 (Flyway unification spanning DaoCore2, SHARED-DAO, ClinicalTrialsAactDb, ButterApi submodules), the post-implementation stage (executing-plans post-implementation → git-workflow-pr pr-creation) batch-created 5 PRs: 4 submodule PRs + 1 parent stacked PR (NewSRX-Tech-LLC/Butter #308) while ALL 4 submodule PRs were open/unmerged. The parent branch's only commit predated the submodule merges and carried stale submodule pointers (the commit had legitimately used the hook-documented SKIP_STALE_POINTER_CHECK=1 because pointer bumps to unmerged feature-branch SHAs were illegal at commit time). Result: an open parent PR with a tree resolving pre-fix submodule SHAs — unmergeable as-is, defeating the PR's purpose.

## Masking Factors

Two factors let this pass the pipeline's existing checks:

1. **Pre-PR composite build ran green** because the local checkout had submodules checked out on their feature branches — the working tree was correct while the recorded pointers were stale. A local build proves nothing about what the PR tree resolves to.
2. **Mergeability checks used `git merge-base --is-ancestor` against master** — this verifies ancestry, not pointer freshness.

## Root Cause

The stacked-PR procedure (git-workflow-pr/tasks/pr-creation.md + executing-plans post-implementation stage + writing-plans completion execution-strategy guidance) has NO ordering gate requiring parent stacked PR creation to wait for submodule PR merges, and no pre-PR assertion that `git submodule status` shows no `+` prefixes AND each recorded pointer SHA is merged on the submodule's remote master. The reachability gates added by #2313 do not cover this: they check that committed pointers are reachable from the remote trunk, but the #304 parent branch was created BEFORE the submodule merges existed anywhere to point to — and nothing forced the parent PR to be created after them.

## Scope

**In scope:**

- Add a mandatory ordering gate to the stacked-PR flow: parent stacked PR SHALL be created only after every in-scope submodule PR is verified merged via live platform API
- Require submodule pointer bumps to be committed on the parent feature branch after the merges land (pointers-ride-alongside rule), so the parent PR commit carries fresh pointers
- Add a pre-PR gate asserting clean `git submodule status` (no `+` prefix) and that each recorded pointer SHA is an ancestor of the submodule's remote master
- Evaluate enforcement placement across: pr-creation task card entry criteria, git-workflow-branch pre-commit-pointer-check task, executing-plans post-implementation stage steps, and a behavioral enforcement test in tests-v2

**Out of scope:**

- Automatic submodule PR creation or cleanup
- Changes to submodule pointer commit mechanics themselves (SKIP_STALE_POINTER_CHECK semantics at commit time remain as documented)
- Human merge behavior — merging remains human-only
- Changes to non-stacked (single-repo) PR flows

## Approach

Introduce a three-condition ordering gate into the stacked-PR procedure, evaluated immediately before parent stacked PR creation. Condition 1: every in-scope submodule PR is verified merged via a live platform API call (never inferred from local state or ancestry). Condition 2: submodule pointer bumps are committed on the parent feature branch per the pointers-ride-alongside rule. Condition 3: a pre-PR assertion confirms `git submodule status` shows no `+` prefixes and each recorded pointer SHA is an ancestor of the submodule's remote master. Placement of the gate is to be evaluated in the spec across four candidate enforcement sites: pr-creation entry criteria, git-workflow-branch pre-commit-pointer-check, executing-plans post-implementation steps, and a behavioral enforcement test in tests-v2. The spec must also define what the parent branch does while waiting (the existing branch may sit idle; the gate simply blocks PR creation until the submodule PRs land).

## Impact

| Risk | Mitigation |
|------|-----------|
| Live-API merge verification can false-block when platform checks lag behind an actual merge | Gate verifies via live API read with a bounded retry/report path; on inconclusive state it blocks with a clear reason rather than guessing |
| Ordering gate adds latency to multi-submodule releases (parent PR cannot open until last submodule merge) | Latency is the cost of a mergeable parent PR; gate reports exactly which submodule PR is pending so the developer can prioritize merges |
| Gate placement across four candidate sites could produce redundant or conflicting checks | Spec evaluates all four sites and assigns exactly one authoritative blocking check, with the others as advisory/consistency checks |

**Dependencies:** None external. Touches task cards in git-workflow-pr, git-workflow-branch, executing-plans, and the tests-v2 behavioral suite.

**Call to action:** Review and approve this spec to add the submodule-merge ordering gate to the stacked-PR workflow.

## Provenance

Surfaced by developer Q&A during Butter #304 cleanup — developer: "why are the pointers stale for the root repo PR?" then "why did you create a PR for a root repo with submodules with pending merges that you didn't have the hashes for?"

---

🤖 OpenCode (ollama-cloud/glm-5.3-flash) created
