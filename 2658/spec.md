<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->

# [SPEC] Closing-keyword mechanics — GitBucket platform fact, cross-repo form rule, merge-vs-close verification

Resolves `.opencode#2658`.

## 1. Intent and Executive Summary

| # | Field | Description |
|---|-------|-------------|
| 1 | **Problem Statement** | Two defects in the deck's closing-keyword contract, both live. (a) **False platform claim.** `git-workflow-pr` §4 states: *"Closing keywords auto-close the remote issue at default-branch merge on platforms that support it: GitHub confirmed for both forms; **GitBucket has no closing-keyword auto-close** — cleanup performs closure there."* That is false. Measured against GitBucket 4.48.0 (release WAR, in the tests-v2 self-contained container): the same-repo form **does** close the issue when the PR is merged into the repository's default branch — confirmed for `Closes`, `Fixes`, `Resolves`, `Close`, `CLOSES`, and comma-separated lists, and for a keyword carried in the PR title, the PR body, the merged commits' messages, or the merge message. The upstream parser is `extractCloseId` in `gitbucket/core/util/StringUtil.scala`; the merge path is `mergePullRequest` in `gitbucket/core/service/MergeService.scala` ("close issue by content of pull request"), reached both from the web UI and from the GitHub-compatible `PUT /api/v3/repos/{owner}/{repo}/pulls/{id}/merge`. Two boundaries hold on GitBucket: the cross-repo form `Closes owner/repo#N` closes **nothing** (the parser resolves a bare `#N` against the PR's own repository), and a merge into a non-default base branch closes nothing — on GitBucket and on GitHub alike. (b) **Wrong form produced.** The card's prohibition names *"the deck-qualified `repo#N` form"* and says it *"closes nothing"* — but the form that closes for a cross-repo reference is `owner/repo#N`, which **contains** that banned substring. The card never states the rule that decides the form (whether the referenced issue lives in the PR's own repository). Agents therefore write bodies whose keywords do not close, and the tickets are then closed by hand. |
| 2 | **Root Cause / Motivation** | (a) The false claim was recorded by the #2615 implementation and generalized into card prose. The #2615 work record (`.issues/2615/plan.md:11-14`) states: *"disposable container (image `gitbucket/gitbucket:latest`), disposable repo/issue/PR — PR body carried `Closes #1`; **merge via API returned 200; issue stayed `state: open`.** Outcome: GitBucket has no closing-keyword auto-close → cleanup class."* The operation was **not a merge**: it was `PATCH .../pulls/{n}` with `{"state":"closed"}` — GitHub's *close-PR* semantic, which on GitHub likewise produces no auto-close. Reproduced on GitBucket 4.48.0: HTTP 200, PR `state: closed`, issue `state: open`. The probe also used `gitbucket/gitbucket:latest`, the image `tests-v2/AGENTS.md:929` records as a *"stale JDK8-base build"* that is *"never used or run"*. The probe's outcome was therefore invalid on both platforms, and it was recorded as a platform fact. (b) The form-selection rule was never stated. #2615 installed the *forms* (`Closes #N`, `Closes owner/repo#N`, `Refs #N`) and the *prohibitions* (bare `#N`, the deck-qualified `repo#N` form) but never the *decision rule* that maps a referenced issue to a form. The prohibition on the deck-qualified form — and the deck's own qualified form is `.opencode#N`, a substring of the correct `owner/.opencode#N` — pushes the agent away from the only cross-repo form that closes. |
| 3 | **Approach Chosen** | Correct the text in the three cards that own the mechanic, and correct the record that carries the false finding. No new gate, no new workflow, no new test, no change to GitBucket. (1) `git-workflow-pr` §4: replace the false class claim with the per-platform/per-form statement; add the form-selection rule; reword the prohibition so it bans the owner-less qualified form while preserving the owner-qualified form; state that the developer's merge is what fires the close. (2) `git-workflow-cleanup` item 1: distinguish a closed PR from a merged one. Item 3: name the surviving fallback case (cross-repo on GitBucket) and retain the no-double-close rule. (3) `gb-cli` §4: state the human merge gate, that `PATCH .../pulls/{n}` with `state: closed` closes without merging and produces no closing-keyword closure, and that GitBucket's issue API reports `state` but not `closed_at`. (4) `.issues/2615/plan.md`: name the operation the probe actually performed and the corrected platform finding. |
| 4 | **Alternatives Considered & Why Discarded** | (a) **Add a "discriminating probe" discipline clause to the operational cards** — discarded by the developer: the rule is process content and belongs in the process layer; the operational cards are loaded on every PR and every GitBucket contact, and the added paragraph is actionable by none of them there. The rule already exists in the process layer (`verify` §11 instrument capability; `plan-validation-standards` #5 and #12; `spec/references/validation-standards` #5), and adding a prose rule would not have caught the #2615 failure — the work record misdescribed the operation, so no reviewer could have caught it from the record. (b) **Add a post-implementation gate to `implement`** — same objection, and it is inert at that hook: the false statement was written into the *plan* artifact, so by the time a post-implementation gate runs the sentence is already baked in. (c) **Add a `tests-v2` behavioral scenario that merges for real** — discarded by the developer as a new workflow, not a correction. (d) **State GitBucket's behaviour as a generic "depends on the platform" hedge** — discarded: the platform fact is knowable and now measured; a hedge reproduces the vagueness that produced the defect, and the two boundaries (cross-repo form, non-default base branch) are the specific facts an agent needs. (e) **Leave `gb-cli` untouched** — rejected because the card documents two ways to *close* a PR and never mentions that the merge is a human gate, nor that a close is not a merge; leaving it is the omission that let a close be mistaken for a merge in the first place. (f) **Restore the pre-rip `attic/skills/git-workflow-pr/reference/closing-keywords.md`** — discarded: it is retired, GitHub-centric, and introduces the `Implements` keyword the uniform-`Closes` contract rejected. |
| 5 | **Key Design Decisions** | (1) **Correct the text; do not add a mechanism.** The change is a set of sentence replacements — net-zero in deck surface apart from a few lines in the `git-workflow-pr` §4 bullet and three sentences in `gb-cli` §4. (2) **The class is per (platform × form), not per platform.** GitBucket is in the keyword-closure class for the same-repo form and outside it for the cross-repo form; the deck's previous binary platform class cannot express that. (3) **State the decision rule, not just the forms.** "The form follows whether the referenced issue lives in the PR's own repository" is the missing sentence; without it the prohibitions leave the choice underdetermined. (4) **Prohibition wording must distinguish owner-less from owner-qualified.** `repo#N` and `owner/repo#N` share a suffix, and the deck's own qualified form is a suffix of the correct cross-repo form. (5) **The merge is the developer's.** The floor's human-merge gate and `git-workflow-pr` §6 make the merge a human action; the card states this so the agent knows the close is not its act at that moment, and its duty at cleanup is to verify and sync. (6) **Closed is not merged.** A PR can carry `state: closed` without ever having merged — GitBucket's `PATCH .../pulls/{n}` with `state: closed` does exactly that, returning HTTP 200. `git-workflow-cleanup` item 1 must read the merge state, not the open/closed flag. (7) **No merge command enters the deck.** `gh pr merge` is listed in `gh-cli` §4's capability list; no card instructs the agent to use it, and none may. (8) **Predicate classification.** Every SC is fact-decidable: a full-card read of card text, a grep across `skills/`, or a read of the work record. Nothing in this change is intent-decidable. (9) **Root-agnostic.** The corrected text names forms (`#N`, `owner/repo#N`, `repo#N`) and platforms (GitHub, GitBucket) only — no repository name, no absolute path, no root-repo-specific string. |
| 6 | **User Intent / Original Prompt** | Session 2026-10-23: the developer reported that *the deck misleads the agent into concluding that GitBucket does not accept standard GitHub close markers in PRs*, that *this is erroneous*, and asked for a fix spec. Subsequent developer directives in the same session: the change is *correcting the false premise and any incorrect wording in any of the skill cards and deck docs*; *not implementing a new workflow*; *the agent is not allowed to merge PRs*; and — after a scoping question that the evidence already answered — *why are you asking me for answers about what you are analyzing*. The developer's stated operational symptom: *the agent is not formatting the PR bodies correctly to autoclose the issue tickets that need closing because it thinks the keyword closing won't work*. |

## 2. Scope

### 2.1 Affected surfaces

| Surface | Change |
|---|---|
| `skills/git-workflow-pr/SKILL.md` §4 | Platform/form statement, form-selection rule, prohibition wording, merge ownership |
| `skills/git-workflow-cleanup/SKILL.md` item 1 | Closed-versus-merged distinction in merge verification |
| `skills/git-workflow-cleanup/SKILL.md` item 3 | Surviving closure-fallback case; retained no-double-close rule |
| `skills/gb-cli/SKILL.md` §4 | Human merge gate; close-without-merge behavior; issue-API field surface |
| `.issues/2615/plan.md` | Work-record correction (the operation performed, the corrected platform finding) |

### 2.2 Surfaces deliberately untouched

- **Reference documents** — none. `git-workflow-pr`, `git-workflow-cleanup`, and `gb-cli` are single-`SKILL.md` cards with no `references/` directory; there is no level two to push detail into, and creating one for a paragraph would be net-negative (new file, new load). `skill-creator`'s "bodies stay lean; details go one level deep in `references/`" does not bite here because the additions are a few lines in existing bullets.
- **`skills/issues/`** — its closure content (§5 Closure, §6 ticket-state hygiene) governs *when* closure is authorized and local↔remote reconciliation, not platform closing-keyword mechanics; those live in `gb-cli` §5. `issues/references/sync-mirroring.md` governs store↔tracker status drift and carries no closing-keyword content.
- **`skills/release-promoter/`, `skills/changelog-generator/`** — no platform-class claims; `release-promoter` only composes the release PR body and mentions `Closes` lines.
- **`skills/gh-cli/`** — its `gh pr create/edit/view/merge` line is a capability listing, not an instruction; no card instructs the agent to merge.
- **`floor.md`, `guidelines/`, `AGENTS.md`, `README.md`, `CHANGELOG.md`** — swept; none asserts a GitBucket closing-keyword fact. The CHANGELOG never recorded #2615, so it carries no false premise.

## 3. Requirements

- **R-1** — `git-workflow-pr` §4 SHALL state that closing keywords close the referenced issue when the PR is merged into the repository's default branch, and SHALL name which platform/form combinations close: GitHub for the same-repo and the cross-repo form, GitBucket for the same-repo form only.
- **R-2** — `git-workflow-pr` §4 SHALL state the form-selection rule: the form follows whether the referenced issue lives in the PR's own repository — same repository `Closes #N`, a different repository `Closes owner/repo#N`, always owner-qualified.
- **R-3** — `git-workflow-pr` §4 SHALL prohibit the bare `#N` form and the owner-less qualified form, and SHALL state that the owner-qualified form is a different form that does close.
- **R-4** — `git-workflow-pr` §4 SHALL state that the developer's merge is what fires the close, consistent with the human merge gate.
- **R-5** — `git-workflow-cleanup` item 1 SHALL distinguish a closed pull request from a merged one, requiring the merge state to be read rather than the PR's open/closed flag.
- **R-6** — `git-workflow-cleanup` item 3 SHALL name the cross-repo reference on GitBucket as the remaining case closed by the cleanup workflow, and SHALL retain the rule that an issue the keywords already closed is not closed again.
- **R-7** — `gb-cli` §4 SHALL state that the merge is a human gate, that `PATCH .../pulls/{n}` with `state: closed` closes without merging and produces no closing-keyword closure, and that GitBucket's issue API reports `state` but not `closed_at`.
- **R-8** — No card in the deck SHALL instruct the agent to merge a pull request.
- **R-9** — The `.issues/2615/` work record SHALL name the operation its probe actually performed and the corrected platform finding.

## 4. Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `git-workflow-pr` §4 states the form-selection rule: same repository → `Closes #N`; a different repository → `Closes owner/repo#N`, always owner-qualified | structural | Full-card read of `skills/git-workflow-pr/SKILL.md`; assert both forms and the decision predicate are present |
| SC-2 | `git-workflow-pr` §4 prohibits the bare `#N` form and the owner-less qualified form, and states that the owner-qualified form does close | structural | Full-card read of `skills/git-workflow-pr/SKILL.md`; assert both prohibitions and the owner-qualified carve-out are present |
| SC-3 | `git-workflow-pr` §4 states that GitHub closes both forms, that GitBucket closes the same-repo form only, and that the cross-repo form on GitBucket closes nothing | structural | Full-card read of `skills/git-workflow-pr/SKILL.md`; grep for both platform statements and for the cross-repo-on-GitBucket exception |
| SC-4 | `git-workflow-pr` §4 states that the developer's merge fires the close | structural | Full-card read of `skills/git-workflow-pr/SKILL.md`; assert the merge ownership is stated |
| SC-5 | `git-workflow-cleanup` item 1 distinguishes a closed pull request from a merged one and requires the merge state to be read | structural | Full-card read of `skills/git-workflow-cleanup/SKILL.md`; assert the closed-versus-merged distinction is present in item 1 |
| SC-6 | `git-workflow-cleanup` item 3 names the cross-repo-on-GitBucket case as closed by the cleanup workflow and retains the no-double-close rule | structural | Full-card read of `skills/git-workflow-cleanup/SKILL.md`; assert the case and the retained rule are both present |
| SC-7 | `gb-cli` §4 states the human merge gate, the close-without-merge behavior of `PATCH .../pulls/{n}`, and the `state`-without-`closed_at` field surface | structural | Full-card read of `skills/gb-cli/SKILL.md`; assert all three statements are present |
| SC-8 | No card instructs the agent to merge a pull request | structural | grep for merge commands across `skills/`; no result may instruct the agent to perform a merge |
| SC-9 | The `.issues/2615/` work record names the operation the probe performed and the corrected platform finding | structural | Read of `.issues/2615/plan.md`; assert the recorded operation matches the performed one and the finding is corrected |

**Traceability.** SC-1↔R-2, SC-2↔R-3, SC-3↔R-1, SC-4↔R-4, SC-5↔R-5, SC-6↔R-6, SC-7↔R-7, SC-8↔R-8, SC-9↔R-9 — one criterion per requirement, none orphaned, no requirement untested.

**Causal sufficiency.** Root cause (a), the false platform claim, is covered by SC-3 and SC-4. Root cause (b), the unstated form-selection rule, is covered by SC-1. The collision between the prohibition and the correct cross-repo form is covered by SC-2. The close-is-not-a-merge confusion is covered by SC-5 and SC-7. The false record is covered by SC-9. The merge-authority constraint is covered by SC-8.

## 5. Out of Scope

- The retired `attic/` cards and the pre-rip `attic/skills/git-workflow-pr/reference/closing-keywords.md`.
- `release-promoter` and `changelog-generator` — no platform-class claims.
- The open `.opencode#2223` — superseded by the #2615 design decisions; coordination note only.
- Any change to GitBucket itself.
- Any new gate, workflow, or test; any change to the local-issues tool, to the cleanup contract's authorization gating, or to the human merge gate.
- Changing the uniform `Closes` keyword, the body-top placement rule, the `Refs #N` semantics, or the ~30-line body size guard — all confirmed correct by measurement and left intact.

## 6. Evidence

### 6.1 Platform measurement — GitBucket 4.48.0, self-contained container

Container: `tests-v2-gitbucket:latest` (the release WAR on a digest-pinned Temurin 21 JRE base — the harness's own image; **not** `gitbucket/gitbucket:latest`, the stale JDK8 build). Measured matrix, each row a disposable issue + PR + merge:

| PR body / placement | Issue state after merge |
|---|---|
| `Closes #N` | **closed** |
| `Fixes #N` | **closed** |
| `Resolves #N` | **closed** |
| `Close #N` | **closed** |
| `CLOSES #N` | **closed** |
| `Closes #N, #M` | **both closed** |
| `Closes #N` in the PR title only | **closed** |
| `Closes #N` in a merged commit's message | **closed** |
| `Closes #N` in the merge message | **closed** |
| `Closes #N` mid-body, not at top | **closed** |
| `Refs #N` | open (correct) |
| bare `#N` | open (correct) |
| `Closes#N` (no whitespace) | open (correct) |
| `Closes .opencode#N` (owner-less qualified) | open (correct — and the form the deck must not ban ambiguously) |
| `Closes owner/repo#N` (cross-repo) | **open — does not close on GitBucket** |
| PR merged into a non-default base branch | **open — default-branch-only, matching GitHub** |

Mechanism, read from upstream `gitbucket/gitbucket`: `src/main/scala/gitbucket/core/util/StringUtil.scala` `extractCloseId` matches `(?i)(?<!\w)(?:fix(?:e[sd])?|resolve[sd]?|close[sd]?)\s+#(\d+)(,\s?#(\d+))*(?!\w)` — same-repository issue numbers only. `src/main/scala/gitbucket/core/service/MergeService.scala` `mergePullRequest` closes issues from the PR's title and body, the merged commits' messages, and the merge message, guarded by `if (pullRequest.branch == defaultBranch)`. `src/main/scala/gitbucket/core/controller/api/ApiPullRequestControllerBase.scala` routes `PUT /api/v3/repos/:owner/:repository/pulls/:id/merge` to the same service method as the web UI.

### 6.2 The #2615 probe, reproduced

`PATCH /api/v3/repos/{owner}/{repo}/pulls/{n}` with `{"state":"closed"}` → **HTTP 200**, PR `state: closed`, issue `state: open`. The #2615 record's phrase *"merge via API returned 200; issue stayed `state: open`"* describes this operation, not a merge.

### 6.3 The live failure — PR bodies that do not close

A GitHub auto-close records the closing pull request in the issue's `closed` timeline event (`source.issue`). Every case below shows `source: null` — a manual API close by the agent's account, not an auto-close.

| Issue | Closed at | Closing PR | Form used in the body | `source` |
|---|---|---|---|---|
| `.opencode#2461` | 2026-10-15T02:57:46Z | `.opencode` #2614, merged 2026-10-15T02:36:08Z | `Resolves .opencode#2461.` (owner-less qualified, wrong keyword) | `null` — 21 min after the merge |
| `.opencode#2170` | 2026-07-29 | parent #358, merged 2026-07-29 | `Closes #2170, #2182` (bare — resolves in the parent's number space, where those numbers do not exist) | `null` |
| `.opencode#2182` | 2026-07-29 | parent #358 | same | `null` |
| `.opencode#2085`, `#2090` | 2026-07-24 | parent #341, merged 2026-07-24 | `Fixes #2085`, `Fixes #2090` (bare) | `null` |
| `.opencode#1897`, `#1709` | 2026-07-12 | parent #286, merged 2026-07-12 | `Closes #1897`, `Closes #1709` (bare) | `null` |
| `.opencode#1815` | 2026-07-09 | parent #276, merged 2026-07-09 | `Fixes #1815` (bare) | `null` |
| `.opencode#840` | 2026-05-24 | parent #142, merged 2026-05-24 | `Closes #840` (bare) | `null` |

Controls, where the form was right, the auto-close fired: `.opencode#708` and `#707` closed 2026-05-19 = parent #104's merge date, via `Fixes michael-conrad/.opencode#N`; `.opencode#2617` closed 2026-10-15 = `.opencode` #2621's merge date via `Closes #2617`, and parent #377 referenced it as `Closes michael-conrad/.opencode#2617` — the correct owner-qualified cross-repo form, at body line 0.

### 6.4 Where the contract is already producing correct bodies

Since #2615 landed (2026-10-15), twelve consecutive `.opencode` PRs (#2616, #2621, #2628 ×2, #2629, #2630, #2631, #2632, #2633, #2634, #2637, #2638, #2641, #2651 ×4) carry `Closes #N` at body line 0 with the uniform keyword; every referenced issue closed. Parent #377 (2026-10-15) carries `Closes michael-conrad/.opencode#2617` at line 0. The residual failure is confined to the cross-repo (parent → submodule) direction and the owner-less qualified form — exactly the two cases this change corrects.

### 6.5 `gb-cli` claims — probed, all true, none changed

| Claim | Probe | Result |
|---|---|---|
| `PATCH .../issues/{n}` → 404 | `PATCH /issues/1 {"state":"closed"}` | HTTP 404 — true |
| `gb pr close` → 404 on GitBucket | `gb pr close 2` | HTTP 404 — true |
| `PATCH .../pulls/{n}` accepts `state` | `PATCH /pulls/61 {"state":"closed"}` | HTTP 200 — true |
| `gb pr edit` without `--web` → "REST PR edit is unavailable" | `gb pr edit 2 --state closed` | exact message — true |
| `--web` fallback prompts for the password on a terminal | `gb pr edit 2 --state closed --web` | "Prompt error: IO error: not a terminal" — true |
| §5 comments-route `?action=close` writes the system comment | `gb api -X POST .../comments?action=close` | issue `state: closed`, comment written — true |

### 6.6 GitBucket issue-API field surface

`GET /api/v3/repos/{owner}/{repo}/issues/{n}` returns `state: closed` with `closed_at` **absent** and `state_reason` **absent** — confirmed on every closed issue the probe produced. Closure verification therefore reads `state`; a reader expecting `closed_at` would see null on a closed issue.

## 7. Provenance

- Spec: `.opencode/.issues/2658/spec.md`.
- Remote issue: https://github.com/michael-conrad/.opencode/issues/2658
- Superseded finding: `.opencode/.issues/2615/plan.md` §"Empirical steps (spec §4, feed SC-2) — executed 2026-10-14 session".
- Platform source: `gitbucket/gitbucket` — `src/main/scala/gitbucket/core/util/StringUtil.scala`, `src/main/scala/gitbucket/core/service/MergeService.scala`, `src/main/scala/gitbucket/core/controller/api/ApiPullRequestControllerBase.scala`.
- Measurement container: `tests-v2-gitbucket:latest` (GitBucket 4.48.0 release WAR).

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
