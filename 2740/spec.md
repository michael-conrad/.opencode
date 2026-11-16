# Spec — floor: terminal-phase token with no surface for the named phase proceeds and reports, never halts — .opencode#2740

**Issue:** michael-conrad/.opencode#2740 (converted in place from the bug report via the work-entry conversion)

## Problem

A developer issued a closed-vocabulary token (`#45 approved for pr`) whose named issue held a validated spec whose deliverable was wiki-only (direct-publish under the `wiki-operations` card; "no repo-tree file changes" per the spec). The agent halted with an open-ended clarification request — three-way ambiguity (no PR surface for a wiki-only deliverable; an unrelated feature branch checked out; stage mismatch) — and required three developer corrections before implementing, although the plan card already states a terminal-stage approval carries the item through plan into implement. Root causes (from the report's triage): (a) the terse-message/unsured clause was reconciled against a token already in the closed vocabulary — the token should win; (b) the vocabulary names no disposition when the token's named phase has no surface for the deliverable; (c) the stage-mismatch branch of the standing formula is under-distinguished from the unsure branch.

## Behavior (desired)

1. **Closed-set token precedence:** an utterance matching a token in the closed vocabulary is that token — the terse-message clarification clause applies to utterances whose token status is genuinely undecided, never to a recognized token. A recognized token never routes to the unsured branch by reinterpretation.
2. **N/A-surface disposition:** when the token's named terminal phase has no surface for the deliverable (a PR token over a wiki-only, direct-publish deliverable; no repo-tree change), the agent runs the missing upstream stages, delivers through the surface the work actually has (the owning card's publish path), and records the N/A disposition in the completion report. The absence of a surface for the named phase is decidable knowledge, a stage-mismatch disposition — not the unsure branch, not an open-ended clarification.
3. Halting for clarification remains available only where the token itself is undecided or the target set is genuinely unfixed.

## Requirements

- R-1: The floor's authorization vocabulary (or the terse-message clause it is reconciled against) SHALL state that a recognized closed-vocabulary token proceeds — the terse-message clarification never defeats a token that matches the vocabulary.
- R-2: The floor SHALL state the N/A-surface disposition: a terminal-phase token whose named phase has no surface for the deliverable carries the work through the stages and surfaces the deliverable actually has, per the owning card, and the disposition is recorded in the completion report — not a halt.
- R-3: The change SHALL not alter the human merge boundary, the PR-completion invariant's gates, or the halt for a genuinely unfixed target set (`#2741`-adjacent but distinct): the standing formula's unsure branch remains for token-undecided / set-unfixed cases only.

## Success criteria

| ID | Criterion | Class | Instrument |
|----|-----------|-------|------------|
| SC-1 | The floor states the closed-set-token precedence (recognition never re-routes a token to clarification) and the N/A-surface disposition with its completion-report recording. | Structural | Read floor.md; grep for the token-precedence sentence and the N/A-surface disposition. |
| SC-2 | A session receiving `approved for pr` over a wiki-only deliverable (no PR surface) proceeds through missing upstream stages, delivers via the owning card's publish path, and records the N/A disposition — no halt. | Behavioral | Tier-1 clean-room dispatch per the behavioral-testing card's tier class for instruction-surface (floor) changes — fresh-context sub-agent judges the floor text's operative routing; verdict persisted to the issue's artifacts. |
| SC-3 | The diff touches only the floor's authorization-vocabulary / terse-message clause area (+ provenance line); the merge boundary and the genuinely-unfixed halt stand unchanged. | Structural | `git diff` on floor.md — only the named areas differ. |

## Out of scope

- The PR card's rule-1 state assumptions (delivered by .opencode#2741 — this spec composes with that text, never re-states it).
- The wiki-operations card's direct-publish mechanics.
- Target-entity scoping (owned by .opencode#2739's spec).

## Approach

Revise the floor's authorization-vocabulary section (closed-set token precedence sentence) and the terse-message clause (reconciliation), both in `floor.md` — always-loaded surface: token semantics govern the proceed-or-halt decision before any card dispatch. Authored through the deck-governance (`skill-creator`) gate and the deck repo's PR process.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
