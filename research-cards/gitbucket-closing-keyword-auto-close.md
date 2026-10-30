<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated — written by a prior session on 2026-10-23; entered the issue store in commit `fcf67465` ("auto: create #.opencode#2658"). Not part of the .opencode#2615 implementation. In-place factual corrections by the .opencode#2659 repair, 2026-10-30. -->
<!-- Co-authored with AI: OpenCode (minimax-m3.1-flash) -->

# Research Card: GitBucket closing-keyword auto-close on PR merge

## Research Question
Does GitBucket auto-close an issue when a pull request body carries a standard
GitHub closing marker (`Closes #N`), merged into the repository's default
branch? The deck's `git-workflow-pr` §4 asserts it does NOT ("GitBucket has no
closing-keyword auto-close — cleanup performs closure there"). Issue
`.opencode#2615` §4 mandated an empirical step for exactly this question, with
the disposition "if auto-close fires at merge, GitBucket is stated in the
keyword-closure class; if not, cleanup performs closure there" — the card text
was written as the opposite of the step's result, so the step was either
skipped or its result misread.

## Finding
**GitBucket DOES auto-close on default-branch merge.** The deck's claim is
false. Measured against GitBucket 4.48.0 (the release the deck's own
`tests-v2` harness provisions — `__ensure_gitbucket` resolves the latest
release WAR) on the harness's self-contained container.

### Empirical matrix (all cases: base branch = repo default branch = `main`)

| # | PR-body marker (or source) | Issue state after merge | Closes? |
|---|---|---|---|
| 1 | `Closes #N` (same repo) | closed | **yes** |
| 2 | `closes #N` (lowercase) | closed | **yes** |
| 3 | `CLOSES #N` (uppercase) | closed | **yes** |
| 4 | `Fixes #N` | closed | **yes** |
| 5 | `Resolves #N` | closed | **yes** |
| 6 | `Closes #A, #B` (comma form) | both closed | **yes** |
| 7 | `Closes #N` placed below the Summary (not at body top) | closed | **yes** — position is irrelevant |
| 8 | `fixes #N` in a **commit message** (no marker in the body) | closed | **yes** — commit messages are scanned too |
| 9 | `Closes root/test-repo#N` (owner-qualified / cross-repo form) | open | **no** |
| 10 | `Closes: #N` (colon after the keyword) | open | **no** — GitHub accepts the colon, GitBucket does not |
| 11 | bare `#N` (no keyword) | open | **no** — correctly inert |
| 12 | `Refs #N` | open | **no** — correctly inert |

Two guards bound the behavior:

- **Default branch only.** The close fires only when the PR's *base* branch is
  the repository's default branch. A PR targeting a non-default branch ignores
  the marker entirely — same as GitHub.
- **Same repository only.** The qualified form `owner/repo#N` does not close
  anything on GitBucket, though it does on GitHub.

### Source corroboration (gitbucket/gitbucket @ master)

| Location | Fact |
|---|---|
| `core/service/MergeService.scala` `mergePullRequest` | On merge: closes from each commit's full message, from the PR **title + body** (`issue.title + " " + issue.content`), and from the merge message — all inside `if (pullRequest.branch == defaultBranch)` |
| `core/service/IssuesService.scala` `closeIssuesFromMessage` | `extractCloseId(message)` → for each id, `getIssue(owner, repository, id)` — `getIssue` resolves in the pull request's own owner and repository, governing the **bare** form; a qualified `owner/repo#N` is rejected **earlier, by the parser** — the pattern requires whitespace immediately before `#`, so a keyword followed by `owner/repo#N` yields no id and never reaches this lookup (discriminating probe: `.opencode#2658` artifact §1) |
| `core/util/StringUtil.scala` `extractCloseId` | Regex `(?i)(?<!\w)(?:fix(?:e[sd])?\|resolve[sd]?\|close[sd]?)\s+#(\d+)(,\s?#(\d+))*(?!\w)` — keyword then whitespace then `#N`; **no colon tolerated** |
| `core/model/PullRequest.scala` | `branch` = the PR's **base/target** branch; `requestBranch` = the source branch — so the guard compares the base branch to the repo default |

### GitHub side (for contrast)

GitHub's official docs confirm the same-repo form, the `KEYWORD OWNER/REPO#N`
cross-repo form, the keyword set (`close/closes/closed`, `fix/fixes/fixed`,
`resolve/resolves/resolved`), the default-branch requirement, the
comma-separated multi-issue form, an optional trailing colon, and the
commit-message vector. **GitHub and GitBucket diverge on exactly two cells:**
the cross-repo form (GitHub yes, GitBucket no) and the optional colon
(GitHub yes, GitBucket no). The deck's uniform `Closes #N` form is valid on
both.

### Cross-repo form on this family — no empirical closure record

`Closes owner/repo#N` appears in exactly one real family PR body:
`opencode-config#377` (`Closes michael-conrad/.opencode#2617`). Its target
issue was **already closed** — `.opencode#2621` (same-repo `Closes #2617`)
merged at 2026-10-15T15:03:23Z and the issue closed at 15:03:25Z; parent PR
#377 merged at 15:23:11Z. The cross-repo marker was a no-op on an
already-closed issue. This matches `.opencode#2615` §4, which recorded the
cross-repo form as "GitHub-documented but carries no empirical record on this
family". **No family PR has been observed to close a cross-repo issue via the
keyword.**

## Consequences observed

- **The cleanup path breaks on GitBucket.** An agent that trusts the deck's
  claim ("no auto-close — cleanup performs closure there") issues a redundant
  close against an already-auto-closed issue. `gb issue close <N>` exits **1**
  with `REST issue state update is unavailable on this GitBucket instance;
  using web fallback. Error: Prompt error: IO error: not a terminal` — a hard
  failure in any non-interactive context. The documented comments-route
  fallback (`?action=close`) succeeds but writes a redundant close comment.
- **The deck's commit convention is safe.** `fix(#2647): ...` does **not**
  match GitBucket's close regex (no whitespace before `#`), so the deck's
  commit-message style does not accidentally close issues on either platform.
  A future convention of `fix #2647` **would** match and silently close.

## Reproduce

The deck's own harness provisions the instance; the merge goes through the
GitHub-compatible **API v3** — both the create and merge endpoints exist and
work (measured 2026-10-30: `POST /api/v3/repos/{owner}/{repo}/pulls` → HTTP
200, PR created; `PUT /api/v3/repos/{owner}/{repo}/pulls/{n}/merge` → HTTP
200, `{"merged":true}`; the `gb pr create` / `gb pr merge` CLI path uses them)
— and the PR's base branch must be the repository's default branch:

```bash
PARENT_REPO_DIR=<repo> TESTS_V2_DOCKER_DIR=<repo>/.opencode/tests-v2/docker \
  source <repo>/.opencode/tests-v2/docker/docker-harness.sh
__ensure_gitbucket          # or __reset_gitbucket for a clean instance
# then: create issue -> push branch
#       -> create PR via POST /api/v3/repos/root/test-repo/pulls
#       -> merge via PUT /api/v3/repos/root/test-repo/pulls/<n>/merge
#       -> read issue state
```

## References
- Deck claim: `.opencode/skills/git-workflow-pr/SKILL.md` §4 ("GitBucket has
  no closing-keyword auto-close — cleanup performs closure there")
- Originating spec: `.opencode/.issues/2615/spec.md` §4 (the mandated
  empirical step and its two dispositions)
- GitHub docs: https://docs.github.com/en/issues/tracking-your-work-with-issues/using-issues/linking-a-pull-request-to-an-issue
- GitBucket source: https://github.com/gitbucket/gitbucket — `MergeService.scala`,
  `IssuesService.scala`, `StringUtil.scala`, `model/PullRequest.scala`
- Deck harness: `.opencode/tests-v2/docker/docker-harness.sh` §12 of
  `.opencode/tests-v2/AGENTS.md`

## Confidence
- Confidence: 0.95 — empirically reproduced across 12 cases on GitBucket
  4.48.0 and corroborated against the upstream source. Residual uncertainty:
  the harness pins "latest release", so a future GitBucket release could
  change the qualified-form or colon behavior.
- Tags: gitbucket, gb-cli, git-workflow-pr, closing-keywords, auto-close,
  2615, cross-repo
