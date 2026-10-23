<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->

# [SPEC] Closing-keyword mechanics — GitBucket platform fact, cross-repo form rule, merge-vs-close verification

Resolves `.opencode#2658`.

## 1. Intent and Executive Summary

| # | Field | Description |
|---|-------|-------------|
| 1 | **Problem Statement** | Two defects in the deck's closing-keyword contract, both live. (a) **False platform claim.** `git-workflow-pr` §4 states: *"Closing keywords auto-close the remote issue at default-branch merge on platforms that support it: GitHub confirmed for both forms; **GitBucket has no closing-keyword auto-close** — cleanup performs closure there."* That is false. Measured against GitBucket 4.48.0 (release WAR, in the tests-v2 self-contained container): the same-repo form **does** close the issue when the PR is merged into the repository's default branch — confirmed for `Closes`, `Fixes`, `Resolves`, `Close`, `CLOSES`, and comma-separated lists, and for a keyword carried in the PR title, the PR body, the merged commits' messages, or the merge message. The upstream parser is `extractCloseId` in `gitbucket/core/util/StringUtil.scala`; the merge path is `mergePullRequest` in `gitbucket/core/service/MergeService.scala` ("close issue by content of pull request"), reached both from the web UI and from the GitHub-compatible `PUT /api/v3/repos/{owner}/{repo}/pulls/{id}/merge`. Two boundaries hold on GitBucket: the cross-repo form `Closes owner/repo#N` closes **nothing** (the parser resolves a bare `#N` against the PR's own repository), and a merge into a non-default base branch closes nothing — on GitBucket and on GitHub alike. (b) **Wrong form produced.** The card's prohibition names *"the deck-qualified `repo#N` form"* and says it *"closes nothing"* — but the form that closes a cross-repo reference on GitHub is `owner/repo#N`, which **contains** that banned substring (on GitBucket no cross-repo form closes — §6.1). The card never states the rule that decides the form (whether the referenced issue lives in the PR's own repository). Agents therefore write bodies whose keywords do not close: in six of the nine measured family failure cases the target issue was already closed before the referencing PR merged, so no merge closed it and the ticket had to be closed by another route. |
| 2 | **Root Cause / Motivation** | (a) The false claim was recorded by the #2615 implementation and generalized into card prose. The #2615 work record (`.issues/2615/plan.md:11-14`) states: *"disposable container (image `gitbucket/gitbucket:latest`), disposable repo/issue/PR — PR body carried `Closes #1`; **merge via API returned 200; issue stayed `state: open`.** Outcome: GitBucket has no closing-keyword auto-close → cleanup class."* The operation was **not a merge**: it was `PATCH .../pulls/{n}` with `{"state":"closed"}` — GitHub's *close-PR* semantic, which on GitHub likewise produces no auto-close. Reproduced on GitBucket 4.48.0: HTTP 200, PR `state: closed`, issue `state: open`. The probe also used `gitbucket/gitbucket:latest`, the image `tests-v2/AGENTS.md:929` records as a *"stale JDK8-base build"* that is *"never used or run"*. The probe's outcome was therefore invalid on both platforms, and it was recorded as a platform fact. (b) The form-selection rule was never stated. #2615 installed the *forms* (`Closes #N`, `Closes owner/repo#N`, `Refs #N`) and the *prohibitions* (bare `#N`, the deck-qualified `repo#N` form) but never the *decision rule* that maps a referenced issue to a form. The prohibition on the deck-qualified form — and the deck's own qualified form is `.opencode#N`, a substring of the correct `owner/.opencode#N` — pushes the agent away from the only cross-repo form that closes. (c) **The finding was known and unapplied.** A prior session's research card — `.issues/research-cards/gitbucket-closing-keyword-auto-close.md`, written 2026-10-23 09:52 and left uncommitted in the issues worktree — reached the same conclusion (GitBucket does auto-close; the cross-repo form and the non-default base branch are the two exceptions) from a 12-case matrix with source corroboration, and it was never committed, never carried into a card edit, and never turned into a requirement. The finding existed; the deck did not carry it. |
| 3 | **Approach Chosen** | Correct the text in the three cards that own the mechanic, and correct the record that carries the false finding. No new gate, no new workflow, no new test, no change to GitBucket. (1) `git-workflow-pr` §4: replace the false class claim with the per-platform/per-form statement; add the form-selection rule; reword the prohibition so it bans the owner-less qualified form while preserving the owner-qualified form; state that the developer's merge is what fires the close. (2) `git-workflow-cleanup` item 1: distinguish a closed PR from a merged one. Item 3: name the cases the keywords leave open (a cross-repo reference on GitBucket; a merge into a non-default base branch) and which of them the workflow closes, and replace the item's vestigial binary-class wording with a pointer to the per-(platform × form) statement in `git-workflow-pr` §4. (3) `gb-cli` §4: state the human merge gate, that `PATCH .../pulls/{n}` with `state: closed` closes without merging and produces no closing-keyword closure, and that GitBucket's issue API reports `state` but not `closed_at`. (4) `.issues/2615/plan.md`: name the operation the probe actually performed and the corrected platform finding. (5) `.issues/research-cards/gitbucket-closing-keyword-auto-close.md`: correct two statements in it — the GitBucket API v3 *does* expose pull-request create and merge endpoints (both verified), and the harness test repository's default branch is `main`, not `master`. Its finding, matrix, and source corroboration are retained unchanged. |
| 4 | **Alternatives Considered & Why Discarded** | (a) **Add a "discriminating probe" discipline clause to the operational cards** — discarded by the developer: the rule is process content and belongs in the process layer; the operational cards are loaded on every PR and every GitBucket contact, and the added paragraph is actionable by none of them there. The rule already exists in the process layer (`verify` §11 instrument capability; `plan-validation-standards` #5 and #12; `spec/references/validation-standards` #5), and adding a prose rule would not have caught the #2615 failure — the work record misdescribed the operation, so no reviewer could have caught it from the record. (b) **Add a post-implementation gate to `implement`** — same objection, and it is inert at that hook: the false statement was written into the *plan* artifact, so by the time a post-implementation gate runs the sentence is already baked in. (c) **Add a `tests-v2` behavioral scenario that merges for real** — discarded by the developer as a new workflow, not a correction. (d) **State GitBucket's behaviour as a generic "depends on the platform" hedge** — discarded: the platform fact is knowable and now measured; a hedge reproduces the vagueness that produced the defect, and the two boundaries (cross-repo form, non-default base branch) are the specific facts an agent needs. (e) **Leave `gb-cli` untouched** — rejected because the card documents two ways to *close* a PR and never mentions that the merge is a human gate, nor that a close is not a merge; leaving it is the omission that let a close be mistaken for a merge in the first place. (f) **Restore the pre-rip `attic/skills/git-workflow-pr/reference/closing-keywords.md`** — discarded: it is retired, GitHub-centric, and introduces the `Implements` keyword the uniform-`Closes` contract rejected. |
| 5 | **Key Design Decisions** | (1) **Correct the text; do not add a mechanism.** The change is a set of sentence replacements — net-zero in deck surface apart from a few lines in the `git-workflow-pr` §4 bullet and three sentences in `gb-cli` §4. (2) **The class is per (platform × form), not per platform.** GitBucket is in the keyword-closure class for the same-repo form and outside it for the cross-repo form; the deck's previous binary platform class cannot express that. (3) **State the decision rule, not just the forms.** "The form follows whether the referenced issue lives in the PR's own repository" is the missing sentence; without it the prohibitions leave the choice underdetermined. (4) **Prohibition wording must distinguish owner-less from owner-qualified.** `repo#N` and `owner/repo#N` share a suffix, and the deck's own qualified form is a suffix of the correct cross-repo form. (5) **The merge is the developer's.** The floor's human-merge gate and `git-workflow-pr` §6 make the merge a human action; the card states this so the agent knows the close is not its act at that moment, and its duty at cleanup is to verify and sync. (6) **Closed is not merged.** A PR can carry `state: closed` without ever having merged — GitBucket's `PATCH .../pulls/{n}` with `state: closed` does exactly that, returning HTTP 200. `git-workflow-cleanup` item 1 must read the merge state, not the open/closed flag. (7) **No merge command enters the deck.** `gh pr merge` is listed in `gh-cli` §4's capability list; no card instructs the agent to use it, and none may. (8) **Predicate classification.** Every SC is fact-decidable: a full-card read of card text, a grep across `skills/`, or a read of the work record. Nothing in this change is intent-decidable. (9) **Root-agnostic.** The corrected text names forms (`#N`, `owner/repo#N`, `repo#N`) and platforms (GitHub, GitBucket) only — no repository name, no absolute path, no root-repo-specific string. |
| 6 | **User Intent / Original Prompt** | Session 2026-10-23: the developer reported that *the deck misleads the agent into concluding that GitBucket does not accept standard GitHub close markers in PRs*, that *this is erroneous*, and asked for a fix spec. Subsequent developer directives in the same session: the change is *correcting the false premise and any incorrect wording in any of the skill cards and deck docs*; *not implementing a new workflow*; *the agent is not allowed to merge PRs*; and — after a scoping question that the evidence already answered — *why are you asking me for answers about what you are analyzing*. The developer's stated operational symptom: *the agent is not formatting the PR bodies correctly to autoclose the issue tickets that need closing because it thinks the keyword closing won't work*. |

## 2. Scope

### 2.1 Affected surfaces

| Surface | Change |
|---|---|
| `skills/git-workflow-pr/SKILL.md` §4 | Platform/form statement, form-selection rule, prohibition wording, merge ownership |
| `skills/git-workflow-cleanup/SKILL.md` item 1 | Closed-versus-merged distinction in merge verification |
| `skills/git-workflow-cleanup/SKILL.md` item 3 | Surviving closure-fallback cases and their remit; removal of the vestigial binary-class wording |
| `skills/gb-cli/SKILL.md` §4 | Human merge gate; close-without-merge behavior; issue-API field surface |
| `.issues/2615/plan.md` | Work-record correction (the operation performed, the corrected platform finding) |
| `.issues/research-cards/gitbucket-closing-keyword-auto-close.md` | Correction of the API-v3 endpoint claim and the default-branch name; the finding retained |

### 2.2 Surfaces deliberately untouched

- **Reference documents** — none. `git-workflow-pr`, `git-workflow-cleanup`, and `gb-cli` are single-`SKILL.md` cards with no `references/` directory; there is no level two to push detail into, and creating one for a paragraph would be net-negative (new file, new load). `skill-creator`'s "bodies stay lean; details go one level deep in `references/`" does not bite here because the additions are a few lines in existing bullets.
- **`skills/issues/`** — its closure content (§5 Closure, §6 ticket-state hygiene) governs *when* closure is authorized and local↔remote reconciliation, not platform closing-keyword mechanics; those live in `gb-cli` §5. `issues/references/sync-mirroring.md` governs store↔tracker status drift and carries no closing-keyword content.
- **`skills/release-promoter/`, `skills/changelog-generator/`** — no platform-class claims; `release-promoter` only composes the release PR body and mentions `Closes` lines.
- **`skills/gh-cli/`** — its `gh pr create/edit/view/merge` line is a capability listing, not an instruction; no card instructs the agent to merge.
- **`floor.md`, `guidelines/`, `AGENTS.md`, `README.md`, `CHANGELOG.md`** — swept; none asserts a GitBucket closing-keyword fact. The CHANGELOG never recorded #2615, so it carries no false premise.

### 2.3 Impact

Consumers: every agent that opens a pull request (the `git-workflow-pr` card loads on the PR boundary) and every agent that runs post-merge cleanup (the `git-workflow-cleanup` card).

The current text causes PR bodies that do not close their issues: in six of the nine measured family failure cases the target issue was already closed before the referencing PR merged, so the merge closed nothing and the ticket had to be closed by another route — a manual close is a destructive action on the tracker that the closing-keyword path would have made unnecessary, and that the cleanup workflow's authorization gate does not otherwise cover. The compensating close is not merely redundant on GitBucket: `gb issue close` falls back to the web UI and **hard-fails** in any non-interactive context (exit 1, "not a terminal"), so an agent that trusts the false claim spends a failing action on a ticket the merge already closed.

Blast radius: three cards, two issue-store records, no code, no test surface, no behavior change to any tool.

## 3. Requirements

- **R-1** — `git-workflow-pr` §4 SHALL state that closing keywords close the referenced issue when the PR is merged into the repository's default branch, and SHALL name which platform/form combinations close: GitHub for the same-repo and the cross-repo form, GitBucket for the same-repo form only.
- **R-2** — `git-workflow-pr` §4 SHALL state the form-selection rule: the form follows whether the referenced issue lives in the PR's own repository — same repository `Closes #N`, a different repository `Closes owner/repo#N`, always owner-qualified.
- **R-3** — `git-workflow-pr` §4 SHALL prohibit a `#N` reference carrying no closing keyword and the owner-less qualified form `repo#N`, and SHALL state that the owner-qualified form `owner/repo#N` is a different form that closes on GitHub, while cross-referencing R-6 for the platforms and cases on which a cross-repo reference cannot be closed by keyword.
- **R-4** — `git-workflow-pr` §4 SHALL state that the developer's merge is what fires the close, consistent with the human merge gate.
- **R-5** — `git-workflow-cleanup` item 1 SHALL distinguish a closed pull request from a merged one, requiring the merge state to be read rather than the PR's open/closed flag.
- **R-6** — `git-workflow-cleanup` item 3 SHALL name the cases the closing keywords leave open — a cross-repo reference on GitBucket, where no cross-repo form closes, and a merge into a non-default base branch — SHALL say that the cleanup workflow closes the first and that the second is outside its remit because the work has not landed on the default branch, and SHALL retain the rule that an issue the keywords already closed is not closed again.
- **R-7** — `gb-cli` §4 SHALL state that the merge is a human gate, that `PATCH .../pulls/{n}` with `state: closed` closes without merging and produces no closing-keyword closure, and that GitBucket's issue API reports `state` but not `closed_at`.
- **R-8** — The change SHALL introduce no instruction to merge a pull request, and the deck's existing human-merge-gate statements (`git-workflow-pr` §6, `release-promoter`) SHALL remain in force and unmodified.
- **R-9** — The `.issues/2615/` work record SHALL name the operation its probe actually performed and the corrected platform finding.
- **R-10** — The `.issues/research-cards/gitbucket-closing-keyword-auto-close.md` research card SHALL retain its finding, matrix, and source corroboration, and SHALL be corrected where it states that the GitBucket API v3 has no pull-request create or merge endpoint (it has both) and names `master` as the harness test repository's default branch (it is `main`).
- **R-11** — `git-workflow-cleanup` item 3 SHALL replace its vestigial binary-class wording — "on platforms without closing-keyword support" and the parenthetical naming which platforms fall in which class — with a pointer to the per-(platform × form) statement in `git-workflow-pr` §4, since the change removes the binary class that wording describes.

## 4. Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `git-workflow-pr` §4 states the form-selection rule: same repository → `Closes #N`; a different repository → `Closes owner/repo#N`, always owner-qualified | structural | Full-card read of `skills/git-workflow-pr/SKILL.md`; assert both forms and the decision predicate are present, and that the uniform `Closes` keyword, the `Refs #N` semantics, and the body-top placement rule are unchanged |
| SC-2 | `git-workflow-pr` §4 prohibits a `#N` reference carrying no closing keyword and the owner-less qualified form `repo#N`, and states that the owner-qualified form `owner/repo#N` is a distinct form that closes on GitHub while pointing at the cases a cross-repo reference cannot close by keyword | structural | Full-card read of `skills/git-workflow-pr/SKILL.md`; assert both prohibitions, the GitHub qualification, and the pointer are present |
| SC-3 | `git-workflow-pr` §4 states that GitHub closes both forms, that GitBucket closes the same-repo form only, and that the cross-repo form on GitBucket closes nothing | structural | Full-card read of `skills/git-workflow-pr/SKILL.md`; grep for both platform statements and for the cross-repo-on-GitBucket exception |
| SC-4 | `git-workflow-pr` §4 states that the developer's merge fires the close | structural | Full-card read of `skills/git-workflow-pr/SKILL.md`; assert the merge ownership is stated |
| SC-5 | `git-workflow-cleanup` item 1 distinguishes a closed pull request from a merged one and requires the merge state to be read | structural | Full-card read of `skills/git-workflow-cleanup/SKILL.md`; assert the closed-versus-merged distinction is present in item 1 |
| SC-6 | `git-workflow-cleanup` item 3 names both cases the keywords leave open — a cross-repo reference on GitBucket and a merge into a non-default base branch — says which the cleanup workflow closes and which is outside its remit, and retains the no-double-close rule | structural | Full-card read of `skills/git-workflow-cleanup/SKILL.md`; assert both cases, the remit statement, and the retained rule are present |
| SC-7 | `gb-cli` §4 states the human merge gate, the close-without-merge behavior of `PATCH .../pulls/{n}`, and the `state`-without-`closed_at` field surface | structural | Full-card read of `skills/gb-cli/SKILL.md`; assert all three statements are present |
| SC-8 | The change introduces no instruction to merge a pull request, and the deck's human-merge-gate statements remain in force | structural | Full-card read of the three edited cards; assert none contains a merge instruction. Grep `skills/` for the human-merge-gate statement; assert it is present in `git-workflow-pr` §6 and `release-promoter` |
| SC-9 | The `.issues/2615/` work record names the operation the probe performed and the corrected platform finding | structural | Read of `.issues/2615/plan.md`; assert the recorded operation matches the performed one and the finding is corrected |
| SC-10 | The research card retains its finding, matrix, and source corroboration, and no longer states that the GitBucket API v3 lacks PR create or merge endpoints, nor that the harness test repository's default branch is `master` | structural | Read of `.issues/research-cards/gitbucket-closing-keyword-auto-close.md`; assert the finding and matrix are present, and that the API-v3 claim and the default-branch name are corrected |
| SC-11 | `git-workflow-cleanup` item 3 no longer carries the vestigial binary-class wording and instead points at the per-(platform × form) statement in `git-workflow-pr` §4 | structural | Full-card read of `skills/git-workflow-cleanup/SKILL.md`; assert the phrases "on platforms without closing-keyword support" and "which platforms fall in which class" are absent and the pointer is present |

**Traceability.** SC-1↔R-2, SC-2↔R-3, SC-3↔R-1, SC-4↔R-4, SC-5↔R-5, SC-6↔R-6, SC-7↔R-7, SC-8↔R-8, SC-9↔R-9, SC-10↔R-10, SC-11↔R-11 — one criterion per requirement, none orphaned, no requirement untested.

**Causal sufficiency.** Root cause (a), the false platform claim, is covered by SC-3 and SC-4. Root cause (b), the unstated form-selection rule, is covered by SC-1. The collision between the prohibition and the correct cross-repo form is covered by SC-2. The close-is-not-a-merge confusion is covered by SC-5 and SC-7. The false record is covered by SC-9. The merge-authority constraint is covered by SC-8. Root cause (c), the known-but-unapplied finding, is covered by SC-10 (the store's research card corrected) and by SC-3 and SC-9 (the card and the work record corrected). R-6 is the workflow counterpart of R-1 — a class statement is only actionable if the workflow says which cases it leaves open — and is covered by SC-6. R-11 removes the card's own vestigial statement of the class model the change replaces, and is covered by SC-11.

## 5. Out of Scope

- The retired `attic/` cards and the pre-rip `attic/skills/git-workflow-pr/reference/closing-keywords.md`.
- `release-promoter` and `changelog-generator` — no platform-class claims.
- The open `.opencode#2223` — superseded by the #2615 design decisions; coordination note only.
- Any change to GitBucket itself.
- Any new gate, workflow, or test; any change to the local-issues tool, to the cleanup contract's authorization gating, or to the human merge gate.
- Changing the uniform `Closes` keyword, the body-top placement rule, the `Refs #N` semantics, or the ~30-line body size guard — all confirmed correct by measurement and left intact.

## 6. Evidence

### 6.1 Platform measurement — GitBucket 4.48.0, self-contained container

Container: `tests-v2-gitbucket:latest` (the release WAR on a digest-pinned Temurin 21 JRE base — the harness's own image; **not** `gitbucket/gitbucket:latest`, the stale JDK8 build). The image was built 2026-10-13 from the latest release WAR; the latest release is 4.48.0 (published 2026-09-20), so the measured instance is GitBucket 4.48.0. Measured matrix, each row a disposable issue + PR + merge:

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
| `Closes: #N` (colon after the keyword) | open — GitHub accepts the colon, GitBucket does not (the regex tolerates no colon) |
| `Closes .opencode#N` (owner-less qualified) | open (correct — and the form the deck must not ban ambiguously) |
| `Closes owner/repo#N` (cross-repo) | **open — does not close on GitBucket** |
| PR merged into a non-default base branch | **open — default-branch-only, matching GitHub** |

Mechanism, read from upstream `gitbucket/gitbucket`: `src/main/scala/gitbucket/core/util/StringUtil.scala` `extractCloseId` matches `(?i)(?<!\w)(?:fix(?:e[sd])?|resolve[sd]?|close[sd]?)\s+#(\d+)(,\s?#(\d+))*(?!\w)` — same-repository issue numbers only, and no colon tolerated. `src/main/scala/gitbucket/core/service/MergeService.scala` `mergePullRequest` closes issues from the PR's title and body, the merged commits' messages, and the merge message, guarded by `if (pullRequest.branch == defaultBranch)`. `src/main/scala/gitbucket/core/controller/api/ApiPullRequestControllerBase.scala` routes `PUT /api/v3/repos/:owner/:repository/pulls/:id/merge` to the same service method as the web UI.

**The API v3 merge path is confirmed, not inferred.** Driven end-to-end with raw `curl` against the GitHub-compatible API and no CLI: `POST /api/v3/repos/root/t3/pulls` → HTTP 200, PR #2 created; `PUT /api/v3/repos/root/t3/pulls/2/merge` → HTTP 200, `{"merged":true}`, "Pull Request successfully merged"; the referenced issue then read `state: open` — the marker in that body was the colon form, which GitBucket does not accept. The `gb pr create` / `gb pr merge` CLI path was separately confirmed to reach the same endpoint and to fire the close (issue #1 closed at merge). This contradicts the research card's statement that the API v3 has no PR create or merge endpoint — see §6.7.

### 6.2 The #2615 probe, reproduced

`PATCH /api/v3/repos/{owner}/{repo}/pulls/{n}` with `{"state":"closed"}` → **HTTP 200**, PR `state: closed`, issue `state: open`. The #2615 record's phrase *"merge via API returned 200; issue stayed `state: open`"* describes this operation, not a merge.

### 6.3 The live failure — PR bodies that do not close

**The auto-close signature.** GitHub closes an issue at the instant the merge lands. Four family PRs give the signature — each merged into `main`, the repository's default branch, each carrying the uniform `Closes #N` form, each with its target closing in one to two seconds:

| PR | merged | target closed | gap |
|---|---|---|---|
| `.opencode` #2621 | 2026-10-15T15:03:23Z | `#2617` at 15:03:25Z | 2 s |
| `.opencode` #2634 | 2026-10-17T13:38:32Z | `#1925` at 13:38:33Z | 1 s |
| `.opencode` #2638 | 2026-10-18T00:03:26Z | `#2635` at 00:03:27Z | 1 s |
| `.opencode` #2651 | 2026-10-21T04:39:27Z | `#2639` at 04:39:29Z | 2 s |

**What does not discriminate.** The `closed` timeline event's `source.issue` does **not** distinguish an auto-close from any other close: `.opencode#2617` — a known auto-close by the signature above — carries `source: null`, exactly as the failure cases do. No inference about *who* or *how* an issue was closed may be drawn from that field.

**The mechanism.** A bare `#N` in a pull-request body resolves against the **pull request's own repository**. Every issue number that a parent-repository PR carried as a bare marker was queried against `michael-conrad/opencode-config`: #2170, #2182, #2085, #2090, #1897, #1709, #1815, #840, #691, #816, #826, #808, #810, #831, #804, #835 — **none of them exists** in that repository. A bare marker naming a number that does not exist closes nothing.

**The failure cases, with a causal test that needs no discriminator.** For these, the target's closure *precedes* the merge of the PR whose body carried the marker. A close that precedes its merge cannot have been caused by that merge:

| PR (marker) | merged into | target | target closed | relation |
|---|---|---|---|---|
| parent #358 — `Closes #2170, #2182` (bare) | `main` | `.opencode#2170` | 2026-07-29T18:26:43Z | closed **3 h 11 m before** the merge (21:37:36Z) |
| parent #358 (same body) | `main` | `.opencode#2182` | 2026-07-29T20:36:32Z | closed **1 h 01 m before** the merge |
| parent #341 — `Fixes #2085`, `Fixes #2090` (bare) | `main` | `.opencode#2085` | 2026-07-24T16:36:34Z | closed **6 m 53 s before** the merge (16:43:27Z) |
| parent #341 (same body) | `main` | `.opencode#2090` | 2026-07-24T16:36:35Z | closed **6 m 52 s before** the merge |
| parent #276 — `Fixes #1815` (bare) | `main` | `.opencode#1815` | 2026-07-09T05:07:06Z | closed **39 s before** the merge (05:07:45Z) |
| parent #133 — `Fixes #691` (bare) | **`dev`** | `.opencode#691` | 2026-05-22T18:50:14Z | closed **the day before** the merge (2026-05-23T06:24:09Z) |

**A second, independent failure cause: the base branch.** Two PRs carried a *correct* marker and still did not auto-close — both merged into `dev` rather than the default branch `main`:

| PR | merged into | default? | marker | target | gap |
|---|---|---|---|---|---|
| `.opencode` #712 | **`dev`** | no | `Fixes #708` (correct same-repo form) | `.opencode#708` | 25 m 33 s |
| parent #104 | **`dev`** | no | `Fixes michael-conrad/.opencode#707`, `#708` (correct cross-repo form) | `.opencode#707`, `#708` | 5 h 33 m |

**One further case.** `.opencode` #2614 merged into `main` (the default) at 2026-10-15T02:36:08Z carrying `Resolves .opencode#2461.` — the owner-less qualified form, which does not close; `.opencode#2461` closed 21 m 38 s later, with no 1–2 s signature. `.opencode#1709` closed 2026-07-08T02:08:02Z, four days **before** parent #286 merged (2026-07-12T03:25:09Z), so it is not attributable to that merge at all.

**What the family record does not show.** No family PR has been observed to close a cross-repo issue by keyword. The one parent PR carrying the owner-qualified cross-repo form (#104) merged into `dev`, not the default branch, so it does not test that form; the other (#377) named an already-closed issue. The card's GitHub cross-repo claim therefore rests on GitHub's documented behaviour, not on a family observation — the same standing `.opencode#2615` §4 recorded.

**Two failure causes, therefore, both visible in the family record:** the wrong form (bare for a cross-repo target; owner-less qualified) and the wrong base branch. The first is the one the card's form guidance produces; the second is the boundary the card's "at default-branch merge" phrase already states.

### 6.4 Where the contract is already producing correct bodies

Since #2615 landed (2026-10-15), thirteen consecutive `.opencode` PRs (#2616, #2621, #2628, #2629, #2630, #2631, #2632, #2633, #2634, #2637, #2638, #2641, #2651) carry `Closes #N` at body line 0 with the uniform keyword; every referenced issue closed. Parent #377 (2026-10-15) carries `Closes michael-conrad/.opencode#2617` at line 0. The residual failure is confined to the cross-repo (parent → submodule) direction, the owner-less qualified form, and merges into a non-default base branch — the cases this change corrects.

### 6.5 `gb-cli` claims — probed, all true, none changed

| Claim | Probe | Result |
|---|---|---|
| `PATCH .../issues/{n}` → 404 | `PATCH /issues/1 {"state":"closed"}` | HTTP 404 — true |
| `gb pr close` → 404 on GitBucket | `gb pr close 2` | HTTP 404 — true |
| `PATCH .../pulls/{n}` accepts `state` | `PATCH /pulls/61 {"state":"closed"}` | HTTP 200 — true |
| `gb pr edit` without `--web` → "REST PR edit is unavailable" | `gb pr edit 2 --state closed` | exact message — true |
| `--web` fallback prompts for the password on a terminal | `gb pr edit 2 --state closed --web` | "Prompt error: IO error: not a terminal" — true |
| §5 comments-route `?action=close` writes the system comment | `gb api -X POST .../comments?action=close` | issue `state: closed`, comment written — true |

### 6.6 Reconciliation with the prior research card

`.issues/research-cards/gitbucket-closing-keyword-auto-close.md` — written 2026-10-23 09:52 by a prior session, left uncommitted in the issues worktree, and swept into this issue's creation commit by the tool's auto-commit. Its **finding is correct and independently corroborates this spec**: GitBucket does auto-close on default-branch merge, and the cross-repo form and the non-default base branch are the two exceptions. Its 12-case matrix, its source corroboration, its colon-form boundary, its cross-repo-no-empirical-record note, and its `gb issue close` hard-failure consequence are all retained.

Two statements in it are not correct:

| Statement | Measured result |
|---|---|
| "the merge must go through the GitBucket **web form** (the API v3 has no PR create/merge endpoint)" | **False.** `POST /api/v3/repos/{owner}/{repo}/pulls` → HTTP 200, PR created; `PUT /api/v3/repos/{owner}/{repo}/pulls/{n}/merge` → HTTP 200, `{"merged":true}`. Both endpoints exist and work; the `gb pr create` / `gb pr merge` CLI path uses them. |
| "base branch = repo default branch = `master`" | The harness test repository's default branch is `main` (`"default_branch":"main"` from the repo API); `master` is not the default anywhere in the measured instance. |

An agent following the card's reproduce section drives GitBucket's web-form endpoints over plain HTTP — the path that produced the card's own matrix, and a path that works without a terminal. The defect is therefore not that the procedure fails; it is that the card steers a reader to it on a premise the API contradicts, when the API v3 path is both available and the one the rest of the deck's tooling uses. R-10 and SC-10 correct the two false statements and leave the finding intact; the withdrawal of the failure claim is this spec's own correction.

### 6.7 GitBucket issue-API field surface

`GET /api/v3/repos/{owner}/{repo}/issues/{n}` returns `state: closed` with `closed_at` **absent** and `state_reason` **absent** — confirmed on every closed issue the probe produced. Closure verification therefore reads `state`; a reader expecting `closed_at` would see null on a closed issue.

## 7. Provenance

- Spec: `.opencode/.issues/2658/spec.md`.
- Remote issue: https://github.com/michael-conrad/.opencode/issues/2658
- Superseded finding: `.opencode/.issues/2615/plan.md` §"Empirical steps (spec §4, feed SC-2) — executed 2026-10-14 session".
- Corroborating prior research: `.opencode/.issues/research-cards/gitbucket-closing-keyword-auto-close.md` (written 2026-10-23 09:52, uncommitted until this issue's creation commit swept it in; finding retained, two statements corrected per R-10).
- Platform source: `gitbucket/gitbucket` — `src/main/scala/gitbucket/core/util/StringUtil.scala`, `src/main/scala/gitbucket/core/service/MergeService.scala`, `src/main/scala/gitbucket/core/controller/api/ApiPullRequestControllerBase.scala`.
- Measurement container: `tests-v2-gitbucket:latest` (GitBucket 4.48.0 release WAR; image built 2026-10-13).

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
