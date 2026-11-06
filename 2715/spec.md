# [SPEC] git-workflow-branch rule 2: attach a remote-tip freshness instrument to the submodule sync step

## Problem

`git-workflow-branch` rule 2's trunk-freshness step can be (and was) satisfied
without ever comparing any registered submodule's checkout to its remote trunk
tip. Rule 2(b) mandates the sync ("sync each submodule's pointer to that
submodule's remote trunk tip — the tracked-branch tip per `.gitmodules`,
fetched from the remote, **not** the recorded pointer"), but the card
prescribes no executed instrument for that step and no check that distinguishes
"submodule at remote tip" from "submodule at recorded pointer". The instrument
agents actually run — `git submodule status` — compares the checkout only
against the parent's recorded gitlink, so a `+`-less listing means
checkout == recorded gitlink and says nothing about the remote tip.

Observed failure (dated session evidence, CrossrefAbstracts workspace — parent
with 27 registered submodules, 2026-11-05): during branch-prep trunk-freshness
the agent ran `git fetch origin master` + `rev-parse` (parent tip verified) and
`git submodule status` — zero `+` rows — on whose basis submodules were
reported current. A subsequent manual `git submodule foreach git pull` (run by
the developer) advanced 11 of 27 submodules to newer remote trunk tips
(ButterShared, DailiesShared, DaoCore2, NewsRxUI, SHARED-DAO, SHARED-JSON,
SHARED-POJOS, SHARED-STRIPE, SharedInterfaces, SharedPojos, xBaseJ): the tree
sat a full fetch behind its remotes when the agent declared it synced.
Consequence: parent work proceeds on stale submodule content under a fresh
belief, and upstream changes surface later as surprise divergence.

## Root cause

1. Rule 2(b) mandates syncing each registered submodule to its tracked-branch
   remote tip but prescribes no executed instrument for the sync step itself and
   no check that distinguishes "submodule at remote tip" from "submodule at
   recorded pointer".
2. The Bounded verification paragraph prescribes the pass's only executed
   instrument for the parent trunk tip ("verify the working repo's trunk tip
   against its remote (fetch and compare)") and speaks of submodule sync only as
   a failure mode that is "recorded, not remediated" — its wording scopes
   comparison away from submodules.
3. `git submodule status` output is structurally pointer-state only (checkout vs
   recorded gitlink): a behind-tip submodule produces a clean, `+`-less listing
   (probe 2026-11-06, git 2.53.0, scratch clone pair). It is the only submodule
   enumeration the cards name (`git-workflow-pr` §2(d)'s dirty-pointer gate uses
   it for pointer-vs-HEAD — the correct fact there), so its clean listing is
   readable as remote-tip currency.

## Scope

Edit `skills/git-workflow-branch/SKILL.md` rule 2: attach the executed
per-submodule remote-tip comparison instrument to the sync step (2(b)), amend
the Bounded verification paragraph so its recorded-not-remediated clause
references the comparison's run outcome, and state the pointer-only nature of
`git submodule status` output. The recorded-not-remediated, non-blocking
branch-decision disposition is preserved unchanged: the remedy lives in the
instrument, keeping the branch decision non-blocking as designed.

## Approach

Attach the instrument to rule 2(b) as card text (the deck's convention: cards
name their instruments inline), amend the Bounded verification paragraph, and
add the pointer-state caveat. Alternatives considered:

- Git built-in remote-tip shortcuts (`git submodule status --remote`,
  `git submodule update --remote --dry-run`): rejected — neither exists in this
  environment's git (probe 2026-11-06, git 2.53.0: both reject with usage
  errors); prescribing them would create an unexecutable instrument.
- Making a behind or no-remote-tip outcome block the branch decision: rejected —
  unrequested behavior change; the report's expected behavior keeps the sync
  disposition non-blocking ("the sync failure is recorded, not blocking"), and
  the remedy lives in the instrument.
- A helper script implementing the comparison: rejected — the card's instrument
  surface is two git operations per submodule; a tracked script artifact adds
  review surface without adding detection the inline text cannot state.

## Requirements

- **R-1.** Rule 2(b)'s sync step SHALL carry the executed instrument: per
  registered submodule, (a) fetch the submodule's origin; (b) resolve the
  tracked branch in order — the `submodule.<name>.branch` field of the parent's
  `.gitmodules` (read from the parent repo; reading a branch key inside the
  submodule via `git config --get branch` is a recorded failure mode — probe
  2026-11-06 reproduces it: `error: key does not contain a section: branch`),
  then the submodule's current checked-out branch when HEAD is symbolic, then
  the submodule remote's default branch (`refs/remotes/origin/HEAD`) when the
  checkout is detached (probe 2026-11-06: `git submodule update --remote`
  detaches the checkout when no branch field exists); (c) compare the checkout's
  HEAD SHA against the fetched remote-tracking tip of the resolved branch,
  guarding ref existence; and (d) record one of three outcomes: `at-tip`,
  `behind`, `no-remote-tip`.
- **R-2.** The Bounded verification paragraph SHALL reference the comparison's
  run outcome: its "recorded, not remediated, non-blocking" clause applies to
  the executed comparison's result — a `behind` or `no-remote-tip` outcome, or
  an execution failure such as an unreachable submodule remote — and the
  paragraph states the comparison runs as part of the same pass, with the
  per-submodule outcomes recorded in the work record (rule 5). The paragraph's
  parent-side semantics are unchanged: the working repo's trunk-tip
  verification (fetch and compare) stays as written, and a parent remote
  unreachable still halts the branch decision for developer direction.
- **R-3.** Rule 2 SHALL state that `git submodule status` output is
  pointer-state only — checkout vs recorded gitlink — and is never evidence that
  a submodule equals its tracked-branch remote tip; rule 2's freshness language
  names the executed comparison (R-1) as the evidence.
- **R-4.** No unrelated changes: rule 2's other content, rules 1 and 3–6, the
  card's frontmatter, and every other card — including `git-workflow-pr` §2(d)'s
  dirty-pointer gate, where pointer-vs-HEAD is the correct fact — are untouched
  except what R-1, R-2, and R-3 require. This revision is deck-content
  governance and routes through the deck-governance card at implementation.

## Impact

- Blast radius: every consumer of this card in a repository with registered
  submodules — the freshness step gains one fetch and one or two rev-parses per
  submodule. Read-only and bounded; the observed 27-submodule workspace pays 27
  fetches per branch-prep pass.
- Agent behavior change: declaring rule 2(b) complete requires executed
  per-submodule comparison evidence; a pointer-only declaration no longer
  satisfies the verification wording. The branch decision's non-blocking design
  is unchanged: a `behind` or `no-remote-tip` outcome, or an execution failure,
  is recorded and does not block.
- No runtime code: the deliverable is card prose; the only executed surface is
  the git operations agents already run during freshness.

## Success criteria

| ID | Criterion | Class | Instrument |
|---|---|---|---|
| SC-1 | Rule 2(b)'s sync step prescribes the executed per-submodule remote-tip instrument with the three outcomes. | Structural (content of the deliverable) | Content check on `skills/git-workflow-branch/SKILL.md`: the sync step names per-submodule fetch, tracked-branch resolution (branch per `.gitmodules`, current-branch fallback, remote-default fallback on detached HEAD), HEAD-vs-remote-tip comparison, and the outcomes `at-tip` / `behind` / `no-remote-tip`. |
| SC-2 | The Bounded verification paragraph treats the submodule comparison as a run outcome: the recorded-not-remediated clause references the executed comparison's result, the branch decision stays non-blocking, and the parent-side semantics are unchanged. | Structural (content of the deliverable) | Content check: the paragraph references the executed comparison's outcome for the recorded-not-remediated disposition, retains the non-blocking branch-decision sentence, and retains the parent-unreachable halt sentence unchanged. |
| SC-3 | Rule 2 states `git submodule status` output is pointer-state only and is never evidence of remote-tip currency. | Structural (content of the deliverable) | Content check: the statement exists in rule 2, and no sentence of rule 2 presents the listing as freshness evidence. |
| SC-4 | The instrument the card prescribes discriminates the three outcomes when executed. | Structural (content of the deliverable) + Behavioral (executed discrimination) | Executed check in a scratch clone pair (super + registered submodule, file-based remote): a submodule checkout behind its tracked-branch remote tip reports `behind`; the same checkout at the tip reports `at-tip`; a checkout with no resolvable tracked branch reports `no-remote-tip`; and a detached-HEAD checkout (the state `update --remote` produces with no branch field) resolves through the fallback chain without error. |

Criteria notes: SC-1 through SC-3 close the three text surfaces the defect
lives in (the uninstrumented mandate, the narrowed verification paragraph, the
misreadable listing); SC-4 verifies the prescribed instrument is operative —
capable of producing the evidence the mandate now demands — which is the defect
class this spec fixes (a mandate whose satisfaction was asserted from an
instrument that could not detect violation). Probe grounds (2026-11-06,
git 2.53.0, scratch clone pair): pointer-only listing blind to a behind-tip
state; `git config --get branch` inside `foreach` errors; explicit
fetch-and-compare discriminated `behind` / `at-tip` / `no-remote-tip`; the
detached-HEAD fallback is required for the chain to resolve.

## Out of scope

- `git-workflow-pr` §2(d)'s dirty-pointer gate and every other card — no edits
  outside this card's rule 2 (plus its Bounded verification paragraph).
- Converting the recorded-not-remediated disposition into a blocking gate or a
  remediation mandate.
- Automatic remediation of behind-tip submodules beyond the sync step rule 2
  already mandates.
- Changes to how `.gitmodules` branch fields are managed or populated.
- Git version support beyond this environment's documented instrument semantics
  (the instrument names git operations, not version-gated flags).

> Full spec and plan artifacts: https://github.com/michael-conrad/.opencode/tree/issues-data/2715/
> Agent-facing artifacts pointer: `.opencode/.issues/2715/`

---

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
