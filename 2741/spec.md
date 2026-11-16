# Spec — git-workflow-pr: default-to-not-done state assumption on PR-boundary authorization

**Issue:** michael-conrad/.opencode#2741
**Source:** Developer bug report (this record, 2026-11-16): "when being approved for PR, the agent improperly assumes that all steps have been completed then checks and determines that none of the work post spec has been completed for most of the approvals."

## Problem

The `git-workflow-pr` card, on PR-boundary authorization, currently leads the agent to assume the pipeline's prior stages (implementation, verification) have already been completed and to check from that assumption. For most approvals the check then discovers the post-spec work was never done — the "completed" starting state was an assumption, not evidence. The failure is the default state the card establishes: completeness must be discovered, never presumed.

## Behavior (desired)

When PR-boundary authorization arrives, the agent's default assumption is that the work has **not** been completed yet. The authorization implies one of two operations, determined by checking actual state:

1. **Complete:** the full workflow runs from where it actually stands — the agent performs the remaining pipeline work (implementation, verification, PR prep) and then opens the PR.
2. **Resume:** the workflow resume itself — the agent re-establishes session state from the record (branch, commits, test/verify records) and continues to the PR boundary.

The state "work already completed for PR" is never an input assumption; it is a natural result of the completion checks (executed evidence: commits present, tests ran green this session, verify PASS recorded). The card's rule 1 framing is revised so branch (b) (scope incomplete → continue implementation) is the default branch and branch (a) (already complete) is entered only when the completion checks themselves — not a prior assumption — establish it.

## Requirements

- R-1: The git-workflow-pr card's PR-completion-invocation guidance SHALL state that on PR-boundary authorization the agent assumes the work is not completed and determines the actual state by checking evidence (commits, test records, verify records) before selecting the completion path.
- R-2: The revised text SHALL frame the two operations as complete-the-workflow (run remaining stages) or resume-the-workflow (re-establish state from the record and continue), with "already complete" entered only as a check outcome.
- R-3: The change SHALL not alter any other gate: full-scope completion and verification before PR, the verify-pass and structural-check requirements, and the human merge boundary stand unchanged.

## Success criteria

| ID | Criterion | Class | Instrument |
|----|-----------|-------|------------|
| SC-1 | The card at `.opencode/skills/git-workflow-pr/SKILL.md` states the not-done default and the evidence-first state determination on PR-boundary authorization. | Structural | Read the card file; grep the rule-1 section for the not-done-default statement and the complete/resume framing. |
| SC-2 | The revised rule-1 text routes an agent receiving `approved for pr` with unfinished post-spec work to performing or resuming that work before PR creation, not to opening a PR or halting on the assumption. | Behavioral | Behavioral test: dispatch a session with `approved for pr` where post-spec work is absent; the session performs the remaining workflow before reaching PR prep. |
| SC-3 | No unrelated rule in the card is altered by the change (diff touches only the rule-1 state-assumption framing and its provenance line). | Structural | `git diff` on the card file against the pre-change trunk: only rule 1 and provenance lines differ. |

## Out of scope

- Changes to other cards' authorization vocabulary (floor.md stays authoritative there).
- Any change to the merge/approval human gate or PR-body contract.
- Changes to the `work` card's stage gates.

## Approach

Revise rule 1 of `.opencode/skills/git-workflow-pr/SKILL.md` (deck content): invert the assumption — default to not-done; "already complete" is only ever a check outcome; the authorization carries the agent through performing or resuming the remaining workflow to the PR boundary. Deck edit goes through the deck-governance card (`skill-creator`) admission gate and the deck repo's PR process.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
