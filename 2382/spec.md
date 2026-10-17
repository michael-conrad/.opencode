<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->

# Spec — gb pr close 404 on deleted-branch PRs: gb-cli card caveat and fallback

Bug filing `.opencode#2382`, revised to target the post-rewrite deck
(.opencode#2490). The local store is authoritative; the remote body is the
exec-summary of this document.

## Problem

On the production GitBucket instance (`tomcat-0002.newsrx.com`), closing a
pull request whose base/head branches had been deleted returned **HTTP 404**
from `gb pr close`. The flow recovered only through
`gb pr edit --state closed --web` — a recovery the deck does not mention. The
deck's only PR-state guidance, gb-cli §4, states "PRs differ
(`PATCH .../pulls/{n}` accepts `state`)" with no deleted-branch exception, so
a deck-following agent has no documented recovery path when the 404 fires.

### Verified current state (evidence, 2026-10-17)

- **Pre-rewrite deck overclaim.** `attic/skills/issue-operations/platforms/gitbucket-api/SKILL.md`
  (tag `pre-rip`) carries `| Close PR | ✅ | gb pr close <N> -R O/R |` at
  lines 58 and 229, with no condition or recovery entry in
  `attic/.../tasks/error-recovery.md`. Those cards are retired.
- **Post-rewrite deck silence.** `rg "pr close"` across `.opencode/skills/`
  and `.opencode/floor.md` returns no match. No deck flow invokes
  `gb pr close`; the exposure is agent-judgment cleanup of superseded or
  stale PRs whose branches are already deleted.
- **Fallback provenance.** `git log -S'--web'` over the parent repo's
  `AGENTS.md` history (all commits) and over `.opencode` history returns no
  committed instance of the `gb pr edit --state closed --web` fallback text —
  the only `--web` matches are unrelated (`gh release view --web`,
  gh-cli card content, issue-store mirrors of this issue). The prior
  filing's claim that the workaround was documented in root `AGENTS.md` is
  not supported by any committed file; the fallback must be documented from
  the verified CLI surface, not from a prior document.
- **CLI surface.** `gb pr close --help`: exists, no `--web` flag.
  `gb pr edit --help`: `--state <STATE>` (open|closed) and `--web`
  ("Allow GitBucket web UI fallback when REST PR edit is unavailable") both
  exist. The fallback is real surface, not an invented workaround.
- **Failure condition uncharacterized.** The single observed incident does
  not distinguish deleted-head from deleted-base from both, and does not
  confirm `--web` succeeds in each. The caveat wording must state the
  condition as pinned by reproduction, not as assumed.

## Root causes

1. PR state mutation on GitBucket fails server-side when the PR's branch
   refs no longer resolve (observed as HTTP 404); the deck's known-gaps list
   does not carry this condition.
2. The sanctioned recovery (`gb pr edit --state closed --web`) exists in the
   CLI but is documented nowhere an agent loads.

## Scope

A minimal in-place edit to `.opencode/skills/gb-cli/SKILL.md` §4 (Platform
awareness / Known gaps): add the deleted-branch failure caveat for PR state
mutation, name the `--web` fallback as the sanctioned recovery, and qualify
the existing "accepts `state`" claim so it no longer reads as unconditional.
The caveat's stated condition follows R-1's pinned reproduction. The edit
routes through the deck-governance admission gate (skill-creator card), like
any edit under `skills/`.

Not included: resurrecting attic'd platform/error-recovery cards; changes to
any other deck file or to root `AGENTS.md`; new `references/` detail cards;
mutation of production repositories for reproduction.

## Requirements

- **R-1** — The deleted-branch failure condition SHALL be pinned by
  reproduction on a non-production GitBucket (the harness's self-contained
  GitBucket container or an equivalent scratch instance; production
  repositories are never mutated for this): a PR with a deleted head branch,
  a PR with a deleted base branch, and a PR with both, recording for each
  whether `gb pr close` fails (and with what status) and whether
  `gb pr edit --state closed --web` succeeds.
  *Instrument: the reproduction transcript (commands and outputs) stored
  under `.opencode/.issues/2382/artifacts/`.*
- **R-2** — The gb-cli card's §4 known-gaps SHALL carry a caveat for PR state
  mutation stating the failure condition exactly as pinned by R-1.
  *Instrument: read the edited card; the caveat's stated condition matches
  the R-1 transcript's observed condition set.*
- **R-3** — The same card section SHALL name
  `gb pr edit <N> --state closed --web` as the sanctioned fallback for
  closing a PR under that condition.
  *Instrument: the card contains the fallback command; `gb pr edit --help`
  confirms the named flags exist.*
- **R-4** — The same edit SHALL place the deleted-branch exception adjacent
  to §4's existing "(`PATCH .../pulls/{n}` accepts `state`)" claim so a
  reader of §4 alone cannot conclude PR state mutation is unconditional.
  *Instrument: read the edited card; the exception text sits within the same
  §4 entry as the PATCH claim.*
- **R-5** — The change SHALL be confined to `.opencode/skills/gb-cli/SKILL.md`
  §4 as a single-digit-line edit; no attic'd structure is restored and no
  other file changes.
  *Instrument: the deck change's diff touches only that file within §4.*
- **R-6** — The edited card SHALL carry provenance citing `.opencode#2382`,
  per the deck-governance admission gate (skill-creator card).
  *Instrument: the changed card's provenance front-matter and SPDX
  provenance comment cite `.opencode#2382`.*

## Impact

Consumers: agents operating GitBucket PRs under the gb-cli card — the
scenario is agent-judgment cleanup of superseded or stale PRs whose branches
are already deleted; no scripted deck flow calls `gb pr close`, so there is
no automated caller to break. Blast radius: one card file, single-digit
lines, additive caveats only; existing card guidance is unchanged. Risk of
the status quo: an agent hits an unexplained 404 mid-cleanup with only
generic failure guidance ("diagnose from stderr; never retry blind") and no
recovery path.

## Traceability

| Requirement | Source |
|---|---|
| R-1 | Recommendation imported by developer revision instruction; gap: condition uncharacterized in the observed incident |
| R-2 | Observed failure (404 with no deck guidance); remediation named in the original filing |
| R-3 | Observed recovery path; verified CLI surface; original filing's remediation |
| R-4 | Same claim class as the retired unconditional ✅ overclaim, still present in gb-cli §4 |
| R-5 | Post-rewrite deck slimming doctrine; recommendation to not restore attic structure |
| R-6 | Floor deck-governance rule for edits under `skills/` |

---
🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
