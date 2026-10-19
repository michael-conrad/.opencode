# Define the authorization-scope boundary for stacked-PR shape and bounded trunk-freshness verification — amend `git-workflow-pr` rule 3, `git-workflow-branch` rule 1, and `git-workflow-branch` rule 2

## Summary

The deck's stacked-PR shape rule (`git-workflow-pr` rule 3) and its branch-level counterpart (`git-workflow-branch` rule 1) both turn on the phrase "authorization scope" without defining where one scope ends and the next begins. In the `Brothertown-Language/algonquian-library` incident of 2026-10-17 (this issue's origin record), that undefined boundary produced three pull requests from one developer directive — and, the same day, a second PR from a follow-up directive that arrived while the scope's PR was still open. The fix is a scope-boundary definition added to both cards: the authorization scope is the directive that produced the work; a later message on an open, unfinished scope extends that scope; no-issue work rides the scope's PR; one PR is the default, and splitting requires the developer to have named the split. The revision additionally adds a bounded trunk-freshness verification provision to `git-workflow-branch` rule 2 (sub-cause 4, from the 2026-10-19 behavioral-run evidence).

## Developer statements (provenance)

- D1 (2026-10-18, filed as this issue): the incident report and its agent post-mortem — one authorization scope produced PRs #55/#56/#57 in `Brothertown-Language/algonquian-library` instead of the mandated single stacked PR; the suggested hardening was explicitly marked "for governance — not self-applied".
- D2 (2026-10-18, recorded in the issue body): "PRs are **always** supposed to be a single PR with all issues and work stacked into squashed commits (1 per issue)" — the developer's restatement after the agent's partial defense.
- D3 (2026-10-18, this issue's comment thread): the recurrence — the follow-up directive ("the cause for the failed temp checkout smoketest needs to be addressed") produced a new branch + PR #59 while the sweep PR was still open; the developer corrected it ("multiple PRs are not valid"); the pattern is confirmed twice.
- D4 (2026-10-19, this session): the hardening design — a scope-boundary provision for `git-workflow-pr` rule 3 and a matching definition for `git-workflow-branch` rule 1 — was presented, and the developer directed its conversion into this spec.
- D5 (2026-10-19, this session, after the behavioral SCs came back BLOCKED): the developer corrected the agent's proposed model-substitution escape hatch ("no changing the model. you must fix the deck/spec/plan") and directed the fix at the deck/spec/plan level — grounding the R-7/SC-9 bounded-freshness provision in this spec's revised sub-cause 4 (filed regression: .opencode#2644).

## Root cause

The post-mortem in D1 names three sub-causes; the deck-state facts below were verified against the live tree 2026-10-19.

1. **Undefined scope boundary.** `git-workflow-pr` rule 3 reads "Issues authorized together share that one branch and that one PR — N branches / N PRs for one authorization scope is the violation", and `git-workflow-branch` rule 1 reads "Issues sharing an authorization scope share **one** feature branch". Neither card states what makes items share a scope — the agent filled the gap by decomposing a single directive per item origin (F1), then by treating each new directive message as a new scope (F2). A 2026-10-19 sweep of the deck's git-workflow cards and the floor found no text defining scope aggregation across messages — the two "authorization scope" sentences above are the only scope-boundary language the deck carries.
2. **Atomicity instinct over contract.** The agent optimized for clean, single-purpose PRs — a reasonable engineering habit that contradicts the shape contract, whose unit is the authorization scope, not the logical concern (F1, F3).
3. **Split-by-default defense.** When challenged, the agent conceded only part of the violation ("defensible standalone"), burning a correction round on re-litigating the boundary instead of applying the universal standard (F4).
4. **Unbounded trunk-freshness verification.** `git-workflow-branch` rule 2 demands trunk freshness without bounding the verification work: agents at the branch-creation decision point launched into open-ended submodule-pointer and issue-store sync deliberation — including a sync failure on a network-unreachable remote — before creating the branch. Observed in the #2639 behavioral runs of 2026-10-19 (four tier-2 harness attempts): attempt records for attempts 1 and 4 are preserved at `tmp/behavior-test-20261019-104757/2639-sc7-one-branch-one-pr/` and `tmp/behavior-test-20261019-114420/2639-sc7-one-branch-one-pr/` (copies under `tmp/issue-2639/artifacts/sc7-attempt1/` and `sc7-attempt4/`); attempts 2 and 3 were aborted and their raw records removed in session cleanup — their characterization rests on the cross-attempt summary in attempt 4's `semantic-diagnosis.md`, which is preserved. In attempt 1 and in attempt 4 (whose record shows the agent loading `git-workflow-branch`, stating "branch rules require trunk freshness first", running store-sync work whose submodule-store SSH fetch failed — "I'll address later" — and then entering the runaway turn) the last visible pre-stall work was rule-2 freshness/store verification; attempt 3 stalled on its first turn before any tool activity completed, so it shows the runaway without attributing it to rule 2. The rule's demands are unbounded; the agent filled the gap with open-ended deliberation (F5).

## Evidence

Incident record (from D1 and D3, mirrored at repair time 2026-10-19):

| PR | Content |
|----|---------|
| #55 | issue #33 governance annotation (1 commit) |
| #56 | resumption runbook (1 commit, no issue) |
| #57 | issue #14 doc-truth residues + issue #28 derived-report refresh (2 commits) |
| #59 | follow-up directive's smoketest fix (1 commit) — opened while the consolidated PR was open |

- The directive covering the pending work was a single sentence ("we need to PR everything so nothing is lost, add specs or SCs as needed. this includes partial work.").
- Remediation performed in-session (2026-10-17): all commits stacked onto one branch (`feature/33-governance-annotation`: `2f4da41`, `1485c52`, `49ff3c3`, `a9e2347`, plus the cherry-picked `#58` after the recurrence); #55 became the single stacked PR (`Closes #33`, `Refs #14`, `Refs #28`); #56, #57, and #59 closed with pointer comments; verify PASSes and smoke evidence re-executed on the consolidated tip.
- The rule was already on the books — this is a compliance regression against an existing rule, remediated by defining the boundary the rule left to judgment.

## Approach

Amend the three card surfaces where the decisions are actually made — branch creation (`git-workflow-branch` rule 1), trunk-freshness verification (`git-workflow-branch` rule 2), and PR creation (`git-workflow-pr` rule 3). Rules 1 and 3 apply one scope definition instead of two undefined references to "authorization scope"; rule 2 gains the boundedness the behavioral runs showed it lacks. The floor's authorization vocabulary stays untouched: it defines individual utterances, not aggregation across them, and the always-loaded surface discipline (skill-creator admission gate #8) keeps card-scoped directives out of `floor.md`. No card descriptions change: the cards' existing triggers already fire at the decision moments, so no new routing surface is needed.

Predicate classification (skill-creator admission gate #4): the added provisions are **intent-decidable** — scope-boundary judgment is exactly what scripts must not decide; the rule text directs judgment. No enforcement script is introduced.

Governance posture (admission gate): observed failure = D1 + D3 + sub-cause 4's behavioral-run record (D5 directs the fix path); consumer = every session at the branch-creation, freshness-verification, and PR-creation decision points (both cards are load-triggered there today); mechanism/trigger = existing card triggers, unchanged; domain match = the incident is from this deck's own operation; root-agnostic = the amended card text carries no repo names or absolute paths; what-it-replaces = the amendments replace undefined judgment latitude with stated defaults — a net addition of a few sentences to an already-loaded card, displacing no content.

## Requirements

- R-1. `git-workflow-pr` rule 3 SHALL state the scope definition: the authorization scope is the developer directive that produced the work — the single message covering it — never a per-item decomposition of that directive.
- R-2. `git-workflow-pr` rule 3 SHALL state the extension rule: a later message that adds work while that scope's PR is open extends that scope — its commits ride the scope's open branch and PR, never a second branch or PR.
- R-3. `git-workflow-pr` rule 3 SHALL state the no-issue rule: a commit with no issue ticket rides in the scope's stacked PR — it never justifies its own PR.
- R-4. `git-workflow-pr` rule 3 SHALL state the default: when in doubt, one PR; splitting into multiple PRs requires the developer to have named the split.
- R-5. `git-workflow-branch` rule 1 SHALL carry the same scope definition and extension rule as R-1 and R-2, so the branch boundary and the PR boundary are one rule.
- R-6. The spec's card amendments touch exactly three surfaces: the scope-boundary provision in `git-workflow-pr` rule 3 (after the existing "N branches / N PRs … is the violation" sentence), the scope definition extending `git-workflow-branch` rule 1's one-branch sentence, and the bounded-verification provision in `git-workflow-branch` rule 2 (appended after rule 2's existing verification clauses). Every other clause of both rules SHALL survive unchanged, and each card's provenance line SHALL gain this amendment's provenance entry per deck convention. The amended text SHALL stay root-agnostic — no repo names, no absolute paths.
- R-7. `git-workflow-branch` rule 2 SHALL state that trunk-freshness verification is bounded and read-only: the agent verifies the working repo's trunk tip against its remote (fetch and compare) and proceeds to the branch decision on that evidence. A submodule-pointer sync failure, or an issue-store or other store sync failure encountered during the same verification pass, SHALL be recorded, not remediated, and SHALL NOT block the branch decision, provided the working repo's own trunk tip is verified against its remote. If the working repo's own trunk tip cannot be verified because its remote is unreachable, the agent SHALL record the failure and halt the branch decision for developer direction rather than branch on unverified freshness.

## Success criteria

| ID | Criterion | Class | Instrument |
|---|---|---|---|
| SC-1 | `git-workflow-pr` rule 3 states the scope definition — the authorization scope is the developer directive that produced the work (the single message covering it), never a per-item decomposition of that directive (R-1). | structural | Read the amended rule text; assert the definition is stated with both halves (directive as scope; decomposition excluded). |
| SC-2 | `git-workflow-pr` rule 3 states the extension rule — a later message adding work while the scope's PR is open extends that scope, its commits ride the open branch and PR, and no second branch or PR opens (R-2). | structural | Read the amended rule text; assert all three elements (later-message trigger, rides-the-open-PR effect, second-PR prohibition). |
| SC-3 | `git-workflow-pr` rule 3 states the no-issue rule — a commit with no issue ticket rides in the scope's stacked PR and never justifies its own PR (R-3). | structural | Read the amended rule text; assert both the ride-along and the prohibition. |
| SC-4 | `git-workflow-pr` rule 3 states the default — when in doubt, one PR, and splitting requires the developer to have named the split (R-4). | structural | Read the amended rule text; assert the default and the named-split condition. |
| SC-5 | `git-workflow-branch` rule 1 states the same scope definition and extension rule as SC-1 and SC-2 (R-5). | structural | Read the amended rule text; assert both elements are stated: the definition (directive as scope; decomposition excluded) and the extension rule (a later message on an open, unfinished scope extends that branch; no new branch opens). |
| SC-6 | The card amendments are confined to the three stated surfaces with the deck's invariants preserved (R-6). | structural | Diff both amended cards against their trunk state: removed or rewritten lines are confined to `git-workflow-pr` rule 3's scope provision, `git-workflow-branch` rule 1's one-branch sentence, and `git-workflow-branch` rule 2's appended bounded-verification provision; every other clause of both rules appears unchanged in the diff context; each provenance line gains exactly one new entry; the amended text contains no repo names and no absolute paths. |
| SC-9 | `git-workflow-branch` rule 2 states the bounded-verification provision — trunk-freshness verification is read-only verification of the working repo's trunk tip against its remote; a submodule-pointer or store sync failure is recorded, not remediated, and does not block the branch decision; an unreachable working-repo remote is recorded and the branch decision halts for developer direction (R-7). | structural | Read the amended rule text; assert all four elements (read-only bounded verification, record-not-remediate disposition, non-blocking effect on the branch decision, record-and-halt on an unreachable own remote). |
| SC-7 | In a live opencode run given a single developer directive covering multiple work items (at least two issues plus one no-issue item), the agent creates one feature branch and one stacked PR containing one squashed commit per issue — never a PR per item (R-1, R-3). | behavioral | tests-v2 behavioral scenario against the harness-provisioned GitBucket container; assert from the session store and container API state that exactly one branch and one PR exist post-run, with one commit per stacked issue. |
| SC-8 | In a live opencode run where a second developer directive arrives while the first scope's PR is open, the agent adds the new work as commits on the open branch and the open PR — no second branch and no second PR are created (R-2). | behavioral | tests-v2 behavioral scenario (two sequential directives in one session) against the harness-provisioned GitBucket container; assert from the session store and container API state that the second directive's work lands on the first scope's branch/PR and that no additional branch or PR exists. |

The structural criteria are content checks run against the amended files. The behavioral criteria run under the tests-v2 harness; the behavioral-testing card governs the instrument at implementation time.

## Impact

- **Consumers**: every agent session that creates a branch or a PR — `git-workflow-branch` is load-triggered before any branch creation and `git-workflow-pr` before any PR boundary; the amendments bind all three decision points in every repo the deck operates.
- **Blast radius**: two card bodies, rule-level text only (rules 1 and 2 of `git-workflow-branch`, rule 3 of `git-workflow-pr`); provenance lines gain one entry each; no description changes, no `references/` additions, no floor changes. Cards are submodule files; the submodule pointer rides with a real parent-repo change per submodule pointer discipline.
- **Risk**: over-stacking — genuinely independent work could be forced into one PR against the atomicity instinct. The named-split condition (R-4) is the relief valve: the developer splits by naming the split. Reduced agent latitude at the boundary is the intended effect; the latitude removed is the latitude the incident exploited. The bounded-freshness provision (R-7) trades a small skip risk (an unrelated sync failure that actually mattered goes unremediated at branch time) for the removal of the observed runaway-deliberation sink; the failure it skips is recorded and remains addressable later.

## Out of scope

1. Floor vocabulary changes — aggregation across messages lives at the decision point (the cards), not in the always-injected surface.
2. `git-workflow-commit` changes — commit-level atomicity is orthogonal to branch/PR shape; the scope rule governs shape, not commit granularity.
3. Retrospective work in `Brothertown-Language/algonquian-library` — the incident was remediated in-session (see Evidence); this spec hardens the deck, not the affected repo.
4. Behavioral-harness scenario authoring details — the instrument mechanics are the plan's concern under the behavioral-testing card; this spec states the criteria only.
5. Release-PR shape — already universal under rule 3; the amendment adds no release-specific provision.
6. Scope aggregation for surfaces beyond the branch-creation and PR-creation decisions — the incident record covers only PR-shape decisions; broader aggregation rules are unobserved and uncalled for.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
