<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# Research artifact — closing-keyword measurement

**Status:** evidence for `.opencode#2658`. This artifact carries the measurement, the upstream source reading, the observed instances in the family repositories, and the `gb` CLI probe results. The normative artifact is [`../spec.md`](../spec.md); this file is cited by it and audited once, not re-audited inside a validation loop.

**Method note.** Every claim here is reproducible from the named sources and from the procedures described in each section. Where a count or a set is stated, its scope is stated with it — nothing here claims corpus-wide exhaustiveness.

## §1 Platform measurement — GitBucket 4.48.0, self-contained container

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

Mechanism, read from upstream `gitbucket/gitbucket`: `src/main/scala/gitbucket/core/util/StringUtil.scala` `extractCloseId` matches `(?i)(?<!\w)(?:fix(?:e[sd])?|resolve[sd]?|close[sd]?)\s+#(\d+)(,\s?#(\d+))*(?!\w)` — a pure pattern over the message text, carrying no repository scoping of its own, and tolerating no colon. The repository scoping lives in `src/main/scala/gitbucket/core/service/IssuesService.scala` `closeIssuesFromMessage`, which runs `extractCloseId(message).flatMap { issueId => for (issue <- getIssue(owner, repository, issueId) if !issue.closed) yield … }` — the issue is looked up in the owner and repository it is handed, and `MergeService.mergePullRequest` hands it the pull request's own owner and repository, so a **bare** `#N` resolves only in the pull request's own repository. A **qualified** reference (`owner/repo#N`) never reaches that lookup at all: the pattern requires whitespace immediately before `#`, so a keyword followed by `owner/repo#N` yields no id — confirmed on GitBucket 4.48.0 by a pull request whose body carried `Closes <other-repo>#N` naming an issue that also existed in the pull request's own repository: that same-repository issue stayed open, so the qualified form is rejected by the parser, not by the lookup. `src/main/scala/gitbucket/core/service/MergeService.scala` `mergePullRequest` closes issues from the PR's title and body, the merged commits' messages, and the merge message, guarded by `if (pullRequest.branch == defaultBranch)`. `src/main/scala/gitbucket/core/controller/api/ApiPullRequestControllerBase.scala` routes `PUT /api/v3/repos/:owner/:repository/pulls/:id/merge` to the same service method as the web UI.

**The API v3 merge path is confirmed, not inferred.** Driven end-to-end with raw `curl` against the GitHub-compatible API and no CLI: `POST /api/v3/repos/root/t3/pulls` → HTTP 200, PR #2 created; `PUT /api/v3/repos/root/t3/pulls/2/merge` → HTTP 200, `{"merged":true}`, "Pull Request successfully merged"; the referenced issue then read `state: open` — the marker in that body was the colon form, which GitBucket does not accept. The `gb pr create` / `gb pr merge` CLI path was separately confirmed to reach the same endpoint and to fire the close (issue #1 closed at merge). This contradicts the research card's statement that the API v3 has no PR create or merge endpoint — see §6.

## §2 An operation that reproduces the #2615 probe's recorded outcome

`PATCH /api/v3/repos/{owner}/{repo}/pulls/{n}` with `{"state":"closed"}` → **HTTP 200**, PR `state: closed`, issue `state: open` — the outcome the #2615 record reports as *"merge via API returned 200; issue stayed `state: open`"*. This is one operation **consistent with** the record. It is not the operation the record performed: the record names no command, and a merge into a non-default branch produces the same recorded outcome. The record is therefore **indeterminate**, and an indeterminate record cannot establish a platform fact.

## §3 Observed instances of the failure

**The method.** Nine merged pull requests were examined in detail: for each, the body's closing-keyword lines were read, each referenced issue number was resolved against the pull request's own repository, and the target issue's `closed_at` was compared with the pull request's `merged_at`. A pull request is an *instance* when the marker in its body does not close its target — because the referenced number does not exist in the pull request's own repository, because the marker is the owner-less qualified form, or because the pull request merged into a branch other than the repository's default branch. **This is a sample, not a sweep**: no exhaustive enumeration of the family repositories' merged pull requests was performed, the table is what the examination of these nine found, and this spec makes no claim about how many further instances exist. The load-bearing claim is the mechanism below, which does not depend on the count.

**The auto-close signature.** GitHub closes an issue at the instant the merge lands. Four pull requests give the signature — each merged into `main`, the repository's default branch, each carrying the uniform `Closes #N` form, each with its target closing in one to two seconds:

| PR | merged | target closed | gap |
|---|---|---|---|
| `.opencode` #2621 | 2026-10-15T15:03:23Z | `#2617` at 15:03:25Z | 2 s |
| `.opencode` #2634 | 2026-10-17T13:38:32Z | `#1925` at 13:38:33Z | 1 s |
| `.opencode` #2638 | 2026-10-18T00:03:26Z | `#2635` at 00:03:27Z | 1 s |
| `.opencode` #2651 | 2026-10-21T04:39:27Z | `#2639` at 04:39:29Z | 2 s |

**What does not discriminate.** The `closed` timeline event's `source.issue` does **not** distinguish an auto-close from any other close: `.opencode#2617` — a known auto-close by the signature above — carries `source: null`, exactly as the instances below do. No inference about *who* or *how* an issue was closed may be drawn from that field. The causal test used instead is ordering, which needs no discriminator: a close that precedes its merge cannot have been caused by that merge.

**The mechanism.** A bare `#N` in a pull-request body resolves against the **pull request's own repository**. Parent-repository pull-request bodies carry bare markers naming two kinds of issue: those that exist in `michael-conrad/opencode-config` — which close correctly, because a bare marker is right when the issue is in the pull request's own repository — and those that name submodule issues, which do not exist in the parent repository and therefore resolve to nothing there. Every number named in the table below was queried against the parent repository and returned no such issue. The defect is therefore not that a bare marker is wrong in itself — it is that a bare marker is wrong **when the referenced issue lives in another repository**, which is the case the card never states.

**The observed instances.**

| PR | marker in body | merged into (default?) | target | target closed | relation to the merge |
|---|---|---|---|---|---|
| parent #358 | `Closes #2170, #2182` (bare) | `main` (yes) | `.opencode#2170` | 2026-07-29T18:26:43Z | **3 h 11 m before** the merge (21:37:36Z) |
| " | " | " | `.opencode#2182` | 2026-07-29T20:36:32Z | **1 h 01 m before** the merge |
| parent #341 | `Fixes #2085`, `Fixes #2090` (bare) | `main` (yes) | `.opencode#2085` | 2026-07-24T16:36:34Z | **6 m 53 s before** the merge (16:43:27Z) |
| " | " | " | `.opencode#2090` | 2026-07-24T16:36:35Z | **6 m 52 s before** the merge |
| parent #276 | `Fixes #1815` (bare) | `main` (yes) | `.opencode#1815` | 2026-07-09T05:07:06Z | **39 s before** the merge (05:07:45Z) |
| parent #133 | `Fixes #691`, `Fixes #816`, `Fixes #826`, `Fixes #808`, `Fixes #810`, `Fixes #831`, `Fixes #804`, `Fixes #835` (each line keyword-bearing, the issue numbers bare) | **`dev`** (no) | `.opencode#691`, `#816`, `#804` | 2026-05-22T03:08:55Z – 18:50:14Z | **before** the 2026-05-23T06:24:09Z merge |
| " | " | " | `.opencode#826`, `#808`, `#810`, `#831`, `#835` | 2026-06-07T05:06:45–50Z | 15 days after the merge |
| parent #286 | `Closes #1897`, `Closes #1709` (bare) | `main` (yes) | `.opencode#1709` | 2026-07-08T02:08:02Z | **4 days before** the 2026-07-12T03:25:09Z merge |
| " | " | " | `.opencode#1897` | 2026-07-12T03:26:27Z | 1 m 18 s after — no 1–2 s signature |
| parent #142 | `Closes #840, #842, #852, #856, #859, #860, #861` (bare) | **`dev`** (no) | `.opencode#840` | 2026-05-24T16:45:49Z | 19 m 11 s after — no 1–2 s signature |
| `.opencode` #712 | `Fixes #708` (correct same-repo form) | **`dev`** (no) | `.opencode#708` | 2026-05-19T18:05:58Z | 25 m 33 s after — no 1–2 s signature |
| parent #104 | `Fixes michael-conrad/.opencode#707` and `Fixes michael-conrad/.opencode#708` (both owner-qualified — the correct cross-repo form) | **`dev`** (no) | `.opencode#707`, `#708` | 2026-05-19T18:05:58Z | 5 h 32 m 58 s after — no 1–2 s signature |
| `.opencode` #2614 | `Resolves .opencode#2461.` (owner-less qualified) | `main` (yes) | `.opencode#2461` | 2026-10-15T02:57:46Z | 21 m 38 s after the 02:36:08Z merge — no 1–2 s signature |

**The counts, scoped to the table above.** Of the nine pull requests in the table, **five** merged into the default branch carrying a marker that does not close (#358, #341, #276, #286, #2614) and **four** merged into a non-default branch (#133, #142, #712, #104). **Five** had a target closed *before* the merge (#358, #341, #276, #133, #286) — the closure demonstrably did not come from that merge. **None of the nine** shows the 1–2 second auto-close signature.

**What the table does not show.** No pull request in this measurement closes a cross-repo issue by keyword. The one parent pull request carrying the owner-qualified cross-repo form (#104) merged into `dev`, not the default branch, so it does not test that form; the other (#377) named an already-closed issue. The card's GitHub cross-repo claim therefore rests on GitHub's documented behaviour, not on an observation here — the same standing `.opencode#2615` §4 recorded.

**Two failure causes are present in the table:** the wrong form (bare for a cross-repo target; owner-less qualified) and the wrong base branch.

**Their dating, and what that dating permits this spec to claim.** The card text this change corrects — the two forms, the two prohibitions, the false platform claim, and the "at default-branch merge" phrase — entered `skills/git-workflow-pr/SKILL.md` in one commit, `7df0f45c`, at 2026-10-15T03:29:47Z. Before it, §4 read in full: *"Executive summary of what changed and why; the executed-test evidence (real output, not assertions); linked issue; provenance pointers."* — no forms, no prohibitions, no default-branch phrase, and no decision rule. **All nine instances in the table merged before that instant**, the latest being `.opencode` #2614 at 2026-10-15T02:36:08Z, fifty-three minutes earlier.

Two consequences, and this spec holds both:

1. The instances evidence what the **absence** of keyword guidance produces. They are the substance of #2615's own problem statement — *"No card states the keyword mechanics, so every PR body improvises them"* — and they are why stating the decision rule is required.
2. They are **not** evidence that the current card text produces a wrong form, and this spec makes no such claim. The current text's defects are established by reading the card: the decision rule is absent from it, and the prohibition's wording collides with the owner-qualified form. Since #2615 landed, thirteen consecutive `.opencode` pull requests and parent #377 all carry the correct form at body line 0 (§4) — the current wording has not been observed producing a wrong form.

## §4 Where the contract is already producing correct bodies

Since #2615 landed (2026-10-15), thirteen consecutive `.opencode` PRs (#2616, #2621, #2628, #2629, #2630, #2631, #2632, #2633, #2634, #2637, #2638, #2641, #2651) carry `Closes #N` at body line 0 with the uniform keyword; every referenced issue closed. Parent #377 (2026-10-15) carries `Closes michael-conrad/.opencode#2617` at line 0. The residual failure is confined to the cross-repo (parent → submodule) direction, the owner-less qualified form, and merges into a non-default base branch — the cases this change corrects.

## §5 `gb-cli` claims — probed, all true, none changed

| Claim | Probe | Result |
|---|---|---|
| `PATCH .../issues/{n}` → 404 | `PATCH /issues/1 {"state":"closed"}` | HTTP 404 — true |
| `gb pr close` → 404 on GitBucket | `gb pr close 2` | HTTP 404 — true |
| `PATCH .../pulls/{n}` accepts `state` | `PATCH /pulls/61 {"state":"closed"}` | HTTP 200 — true |
| `gb pr edit` without `--web` → "REST PR edit is unavailable" | `gb pr edit 2 --state closed` | exact message — true |
| `--web` fallback prompts for the password on a terminal | `gb pr edit 2 --state closed --web` | "Prompt error: IO error: not a terminal" — true |
| §5 comments-route `?action=close` writes the system comment | `gb api -X POST .../comments?action=close` | issue `state: closed`, comment written — true |

## §6 Reconciliation with the prior research card

`.issues/research-cards/gitbucket-closing-keyword-auto-close.md` — written 2026-10-23 09:52 by a prior session, left uncommitted in the issues worktree, and swept into this issue's creation commit by the tool's auto-commit. Its **finding is correct and independently corroborates this spec**: GitBucket does auto-close on default-branch merge, and the cross-repo form and the non-default base branch are the two exceptions. Its 12-case matrix, its colon-form boundary, its cross-repo-no-empirical-record note, and its `gb issue close` hard-failure consequence are all retained. Its source-corroboration **row** is not retained unchanged: it attributes the cross-repo form's non-closure to the repository-scoping lookup, which governs the bare form, whereas a qualified reference is rejected earlier by the parser (§1) — the conclusion is right and the stated mechanism is not.

Two statements in it are not correct:

| Statement | Measured result |
|---|---|
| "the merge must go through the GitBucket **web form** (the API v3 has no PR create/merge endpoint)" | **False.** `POST /api/v3/repos/{owner}/{repo}/pulls` → HTTP 200, PR created; `PUT /api/v3/repos/{owner}/{repo}/pulls/{n}/merge` → HTTP 200, `{"merged":true}`. Both endpoints exist and work; the `gb pr create` / `gb pr merge` CLI path uses them. |
| "base branch = repo default branch = `master`" | The harness test repository's default branch is `main` (`"default_branch":"main"` from the repo API); `master` is not the default anywhere in the measured instance. |

An agent following the card's reproduce section drives GitBucket's web-form endpoints over plain HTTP — the path that produced the card's own matrix, and a path that works without a terminal. The defect is therefore not that the procedure fails; it is that the card steers a reader to it on a premise the API contradicts, when the API v3 path is both available and the one the rest of the deck's tooling uses. R-10 and SC-10 correct the two false statements and leave the finding intact; the withdrawal of the failure claim is this spec's own correction.

## §7 GitBucket issue-API field surface

`GET /api/v3/repos/{owner}/{repo}/issues/{n}` returns `state: closed` with `closed_at` **absent** and `state_reason` **absent** — confirmed on every closed issue the probe produced. Closure verification therefore reads `state`; a reader expecting `closed_at` would see null on a closed issue.