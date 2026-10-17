<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->

# Spec — gb pr close 404 caveat (gb-cli card) + issues-card local/remote routing correction

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

### Second defect — deck routing instruction (observed this session)

The issues card's mirror-repair instruction (§7) attributes correcting the
remote body's pointer to `local-issues update --github`, but that command is
local-only: it writes the `github_url` metadata field into the local store's
`issue.yaml` and never contacts any remote tracker (verified by reading
`cmd_update` in `.opencode/tools/local-issues`). Following the instruction
produced silent local/remote divergence twice in one session — both pushes
reported `updated: true` while the remote body remained unchanged; the
divergence surfaced only when a reviewer read the remote half. The deck's
operational instructions must make the local/remote boundary explicit.

### Verified current state (evidence, 2026-10-17)

- **Pre-rewrite deck overclaim.** `attic/skills/issue-operations/platforms/gitbucket-api/SKILL.md`
  (tag `pre-rip`) carries `| Close PR | ✅ | gb pr close <N> -R O/R |` at
  line 58 (capability table) and the same command at line 228
  (command-reference table), with no condition or recovery entry in
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
- **Tool surface (second defect).** `cmd_update` in
  `.opencode/tools/local-issues` writes only the local `issue.yaml` — the
  `--github` flag's value is stored as the `github_url` metadata field; no
  code path in the `update` command contacts `gh`/`gb` or any platform API.
  The issues card §1 states the correct route ("remote operations go
  through the platform CLI"), but §7 contradicts it by naming
  `update --github` as the remote-body correction mechanism.

## Root causes

1. PR state mutation on GitBucket fails server-side when the PR's branch
   refs no longer resolve (observed as HTTP 404); the deck's known-gaps list
   does not carry this condition.
2. The sanctioned recovery (`gb pr edit --state closed --web`) exists in the
   CLI but is documented nowhere an agent loads.
3. The deck's operational instructions do not state the boundary between
   local-issues (local issues-data store only) and the platform CLI (remote
   tracker API), and issues card §7 attributes a remote correction to a
   local-only command — an agent following the card as written misroutes
   the remote operation and the divergence is silent.

## Scope

Two minimal in-place deck edits, both routed through the deck-governance
admission gate (skill-creator card), like any edit under `skills/`:

1. **gb-cli caveat** — `.opencode/skills/gb-cli/SKILL.md` §4 (Platform
   awareness / Known gaps): add the deleted-branch failure caveat for PR
   state mutation, name the `--web` fallback as the sanctioned recovery, and
   qualify the existing "accepts `state`" claim so it no longer reads as
   unconditional. The caveat's stated condition follows R-1's pinned
   reproduction.
2. **Issues-card routing correction** — `.opencode/skills/issues/SKILL.md`
   §7 (mirror-repair): the sentence attributing the remote-body pointer
   correction to `update --github` is rewritten so the remote correction is
   routed through the platform CLI per the card's own §1, and the
   differentiation doctrine is stated explicitly (R-7). The
   `local-issues-cli.md` reference's `update` row carries the same explicit
   local-only statement.

Not included: resurrecting attic'd platform/error-recovery cards; changes to
any other deck file or to root `AGENTS.md`; new `references/` detail cards;
mutation of production repositories for reproduction; changes to the
`local-issues` tool script itself — the tool's local-only behavior stands;
the correction is instructional.

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
- **R-5** — The change SHALL be confined to the files named in this spec —
  `.opencode/skills/gb-cli/SKILL.md` §4 (single-digit-line edit) plus the
  issues-card correction files named in R-7; no attic'd structure is
  restored and no other file changes.
  *Instrument: the deck change's diff touches only the files named in R-5
  and R-7.*
- **R-6** — The edited cards SHALL carry provenance citing `.opencode#2382`,
  per the deck-governance admission gate (skill-creator card).
  *Instrument: each changed card's provenance front-matter and SPDX
  provenance comment cite `.opencode#2382`.*
- **R-7** — The issues card's operational instructions SHALL state the
  local/remote boundary explicitly: local-issues commands manage only the
  local issues-data store and never interact with or update any remote
  issues-system API on any platform; remote issue operations SHALL be routed
  through the platform-appropriate skill card (gh-cli / gb-cli) in addition
  to the local-issues card. §7's mirror-repair instruction SHALL cease
  attributing the remote-body pointer correction to `update --github`, and
  the `local-issues-cli.md` reference's `update` row SHALL carry the same
  explicit local-only statement.
  *Instrument: read the corrected card and reference; both state the
  doctrine explicitly, and no instruction in either file attributes a remote
  correction to a local-only command (exhaustive read — the card and
  reference are short).*

## Success criteria

- **SC-1** — An agent following the corrected deck differentiates the two
  surfaces without prompting: updating a local store record routes via
  local-issues; editing the remote tracker's issue body routes via the
  platform-appropriate card (gh-cli / gb-cli); local-issues is never used
  for the remote operation. **Class: behavioral.**
  *Instrument: fresh-context comprehension probe — hand an agent that has
  loaded only the corrected issues card two scenarios (update the local
  store record for repo#N; edit the remote tracker's issue body for
  repo#N) and record the routing it states; PASS requires local-issues for
  the first, the platform card for the second, and no local-issues attempt
  for the remote operation.*

## Impact

Consumers, first defect: agents operating GitBucket PRs under the gb-cli
card — the scenario is agent-judgment cleanup of superseded or stale PRs
whose branches are already deleted; no scripted deck flow calls
`gb pr close`, so there is no automated caller to break. Consumers, second
defect: every agent flow that spans the local store and the remote tracker —
filing, mirroring, repair, revision — is exposed to the misrouting §7
invites; the divergence is silent, so it surfaces only when someone reads
the remote half. Blast radius: three card/reference files, single-digit
lines each, corrective wording only; existing card guidance is otherwise
unchanged. Risk of the status quo, first defect: an agent hits an
unexplained 404 mid-cleanup with only generic failure guidance ("diagnose
from stderr; never retry blind") and no recovery path. Risk of the status
quo, second defect: agents follow §7 as written, believe the remote body
was corrected, and the store and tracker silently diverge.

## Traceability

| Requirement | Source |
|---|---|
| R-1 | Recommendation imported by developer revision instruction; gap: condition uncharacterized in the observed incident |
| R-2 | Observed failure (404 with no deck guidance); remediation named in the original filing |
| R-3 | Observed recovery path; verified CLI surface; original filing's remediation |
| R-4 | Same claim class as the retired unconditional ✅ overclaim, still present in gb-cli §4 |
| R-5 | Post-rewrite deck slimming doctrine; recommendation to not restore attic structure |
| R-6 | Floor deck-governance rule for edits under `skills/` |
| R-7 | Developer revision instruction (correct the operational instruction defect); observed silent local/remote divergence following §7 as written |
| SC-1 | Developer revision instruction (the agent should clearly differentiate local-only store management from remote-API operations) |

---
🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
