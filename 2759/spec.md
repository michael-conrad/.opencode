# [BUG] Hash-permanence tag naming has no no-issue fallback — release path halts on a deck-internal naming question

<!-- Status: bug report (filed 2026-11-20); remote mirror: https://github.com/michael-conrad/.opencode/issues/2759 -->

## Report

The tagged-SHA pointer discipline (`git-workflow-branch` rule 3, restored
via #2683) names the hash-permanence tag rigidly
`<parent-repo>/<issue-number>-<submodule-dir>`. Three rules compose into a
deadlock on the release path:

1. `release-promoter` Phase C-0 step 8: every promoted pointer SHA carries a
   pushed hash-permanence tag per `git-workflow-branch` rule 3 before the
   capture commit; `git-workflow-pr` §2(d-2) blocks the release PR until the
   tag is verifiably on the submodule remote.
2. `release-promoter` §1: release PR bodies carry `Closes` lines "only when a
   release issue exists" — the deck explicitly allows a release with no
   release issue.
3. `git-workflow-branch` rule 5: never create an issue merely to satisfy
   provenance.

No deck surface names a fallback tag name for the no-issue case. The only
exits are both forbidden: invent an issue number, or halt and ask the
developer. The second exit fired live on 2026-11-20; the developer's
verdict: "this must be a deck regression as you have asked me something
only you can know."

The gap never fired historically because every prior release had a release
issue (v0.3.0 → opencode-config#378 → tag `opencode-config/378-.opencode`).
The non-release path (short-path pointer captures with no issue) exposes
the same wall; the release path is the evidenced instance.

## Reproduction (2026-11-20 session, opencode-config release prep)

- Parent trunk `main` at remote tip `385a8a70d` (v0.3.0 merge; no parent
  commits since `v0.3.0`).
- Submodule `.opencode` (branch field `main`): checkout HEAD `49b8f9f602`
  == fetched `origin/main` tip → composition comparison `at-tip`;
  recorded gitlink `7e50437bb` → dirty pointer, disposition include
  (promotion `7e50437bb` → `49b8f9f602`, delivering deck PRs
  michael-conrad/.opencode#2750–#2758).
- Phase C-0 step 8 requires the tag for `49b8f9f602` before the capture
  commit; §2(d-2) blocks the PR until it exists on the submodule remote.
- No release issue exists (opencode-config#378 closed; no open issue covers
  this release); rule 5 forbids minting one for provenance.
- Agent halt: asked the developer for the issue number for the tag name.
  Developer verdict: deck regression — the question is only answerable by
  the deck.

## Scope

Deck rule text only: `git-workflow-branch` rule 3 (naming), rule 5
(no-issue provenance), `release-promoter` Phase C-0 step 8 and §1,
`git-workflow-pr` §2(d-2)/§4 — reconciled so the release path names a
lawful tag for every pointer it records, with or without a release issue,
with no developer-facing halt on deck-internal naming. No script surface,
no hooks, no clean-room gate mechanics.

## Requirements

- **R-1**: The deck SHALL name a lawful hash-permanence tag name for a
  recorded pointer whose work has no issue number — or name the provision
  that supplies a number — such that no agent halt asks the developer for
  a deck-internal naming decision.
- **R-2**: The naming rule SHALL compose with `git-workflow-branch` rule 5
  and the release path's no-release-issue allowance — the three rules
  deadlock-free.
- **R-3**: The resolution SHALL appear on every card carrying the naming
  discipline (`git-workflow-branch` rule 3, `release-promoter`,
  `git-workflow-pr` §2(d-2)/§4) so no card pair re-creates the gap.

## Impact

Every agent session preparing a release in any parent/submodule family:
the release path deadlocks whenever no release issue exists. The
opencode-config release following v0.3.0 is blocked on this defect now
(composition verified `at-tip`, pointer promotion `7e50437bb` →
`49b8f9f602` awaiting a lawful tag name). Blast radius: deck rule text
read at the pointer-capture decision moment; no code, no tooling.

## Evidence trail

- Session transcript 2026-11-20: release composition executed (fetch-compare
  outputs above), halt fired, developer verdict recorded.
- Rule texts: `.opencode/skills/git-workflow-branch/SKILL.md` (rules 3, 5),
  `.opencode/skills/release-promoter/SKILL.md` (§1, Phase C-0 step 8 via
  `references/operating-protocol.md`),
  `.opencode/skills/git-workflow-pr/SKILL.md` (§2(d-2), §4).
- Precedent naming: `git ls-remote --tags` of the deck remote lists every
  hash-permanence tag carrying an issue number
  (`opencode-config/378-.opencode` et al.) — no issue-less tag exists.

🤖 Co-authored with AI: OpenCode (ollama-cloud/glm-5.3)
