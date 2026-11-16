# Spec — floor: ambiguous-scope-word halt must not fire on a fixed target set (session-init enumeration) — .opencode#2739

**Issue:** michael-conrad/.opencode#2739 (converted in place from the bug report via the work-entry conversion)

## Problem

The ambiguous-scope-word halt (floor: "an ambiguous scope word … halts for an open-ended clarification request when the target set is not already fixed by session context") recurred on a release-pipeline request ("pull all repos to remote trunk tip and create a release PR") in a consuming repo whose session-init repo table enumerated the root repo. The agent read "all repos" as genuinely unfixed, halted before touching the enumerated root repo, and asserted "no repos" — although (a) the floor itself states session-init data (an enumerated worktree map or repo table) fixes the set, (b) the root repo is always a tracked repo, and (c) the same defect class was already fixed by #2730. The fix's mechanism does not close the class: an agent that finds no registered submodules can still read the set as unfixed.

## Behavior (desired)

1. The floor's target-entity-scoping clause, on the ambiguous-scope-word case, carries the enumerated-members floor: **session context always fixes at least the root repo** — there is never a zero-repo target set. When an ambiguous scope word ("all", "everything") arrives and session-init's repo table (or worktree map) enumerates one or more repositories, the agent acts on the enumerated members (pull, release pipeline, as named), records any residual ambiguity about non-enumerated candidates (e.g. a nested deck checkout with its own `.git`), and reports the record — it does not halt for clarification while a fixed member exists unprocessed.
2. The residual-ambiguity record is input to the developer's next statement; a halt fires only when no member of the plausible target set is fixed by session context.

## Requirements

- R-1: The floor's target-entity-scoping paragraph SHALL state that a zero-repo target set cannot arise — the root repo is always fixed by session context.
- R-2: It SHALL state that when session-init's repo table or worktree map has enumerated members, an ambiguous scope word routes to acting on the enumerated members plus recording residual ambiguity about non-enumerated candidates — never a pre-action halt while a fixed member is unprocessed.
- R-3: The change SHALL not weaken the halt itself: a genuinely unfixed set (no enumeration, no target-binding token, no session-context fix) still halts per the standing formula.

## Success criteria

| ID | Criterion | Class | Instrument |
|----|-----------|-------|------------|
| SC-1 | The floor's target-entity-scoping clause states the zero-repo-floor and the act-on-enumerated + record-residue disposition. | Structural | Read floor.md; grep the clause for the zero-repo-floor sentence and the record-residue disposition. |
| SC-2 | A session receiving an ambiguous-scope-word request where session-init enumerates the root repo proceeds on the enumerated member(s) and records residual ambiguity instead of halting pre-action. | Behavioral | Tier-1 clean-room dispatch per the behavioral-testing card's tier class for instruction-surface (floor) changes — fresh-context sub-agent judges the clause's operative routing; verdict persisted to the issue's artifacts. |
| SC-3 | The change touches only the target-entity-scoping paragraph (and the floor provenance line); the halt for a genuinely unfixed set stands verbatim in meaning. | Structural | `git diff` on floor.md — only the scoping paragraph + provenance differ. |

## Out of scope

- The authorization vocabulary's token semantics (owned by .opencode#2740's spec where they overlap).
- session-init's own repo-table format or enumeration mechanics.
- Deck-governance process changes.

## Approach

Revise the target-entity-scoping paragraph of `floor.md` (deck content, always-loaded surface: this is a proceed-or-halt decision, the definition must be visible before any card dispatch). Authored through the deck-governance (`skill-creator`) gate and the deck repo's PR process.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
