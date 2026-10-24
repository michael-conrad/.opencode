<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->

# [SPEC] Authorization scope — a content statement is not a stage authorization

## Problem

On 2026-10-24, in `michael-conrad.com`, the developer stated a content decision in plain language — **"I said I wanted the .junie folder purged. it has no value after today."** — and the agent read it as authorization to implement. It loaded `implement` and `git-workflow-branch` and began the implementation cycle (feature branch, corpus deletion) when the only authorization given was for the spec. The developer stopped it: **"you are only authorized to fucking update the damned spec. why in the fuck are you trying to an actual implementation? what is the deck regression causing this?"**

The cause is a text regression from the #2490 rip, visible in `attic/`.

**What the pre-rip deck had, and the rip dropped:**

- `attic/guidelines/010-approval-gate.md` — "**Explicit authorization:** 'approved' or 'go' — implicit, rhetorical, or complaint-based authorization is invalid"; "**Question/ complaint ≠ authorization**" (`critical-rules-question-auth-001`); "Bug discovery ≠ bug fixing authorization" (`critical-rules-011`); "Issue creation is reporting, NOT implementation"; "Issue creation is NOT a backdoor to implementation — creating a spec issue does not authorize implementing it".
- The same file's **authorization scope model** — a mechanical scope with a hard boundary: `for_analysis` (read-only) as the default, then `for_spec`, `for_plan`, `for_implementation`, `for_pr`, each with a "HALT After" stage; "**Approved #N** (no qualifier) = `for_analysis`"; "**HARD HALT at scope boundary** … Proceeding past `halt_at` without re-authorization is a critical violation"; "**Authorization Scope Is Permission, Not a Pipeline Shortcut** … The pipeline sequence (spec → plan → implement → PR) is invariant — no authorization scope compresses it."
- `attic/skills/approval-gate/SKILL.md` — the **verb-prefix parsing table**, a deterministic function from the developer's phrase to a scope, with the pre-rip rule "Scope detection via the verb-prefix parsing table is NEVER ambiguous … no agent judgment required."
- `attic/guidelines/020-go-prohibitions.md` — "Questions are NOT authorization"; "Rhetorical and complaint questions are NOT authorization"; "'Why' questions are observation-only, never authorization"; "Interpretive questions are explanation-only, never modification authorization"; "**GO must be explicit and literal**"; "Discussion conclusions are NOT authorization"; "Never self-answer a solicitation"; "No silent halt without search+prompt".

**What the live deck has now:**

- `floor.md` — the authorization vocabulary is a prose list whose fallback is "**Anything unlisted falls to default agent judgment**", and whose bare-`approved` entry reads "`approved` (bare, mid-discussion) → authorizes the item just discussed; clarify if it implies implementation". Only the *confirmation* class survived ("Confirmation … is agreement with content — **never** authorization"). The complaint, question, feedback, and content-statement classes are absent from the always-injected surface.
- `floor.md` — the standing formula "continue while next steps are clear; when unsure, halt with an open-ended clarification request", and the pipeline paragraph "Changes go through spec → plan → implement → PR, scaled to the change's need".
- `skills/work/SKILL.md` §2 keeps one line of the dropped rule — "A question, complaint, or confirmation is not authorization" — but the card loads on demand, and in a spec-stage session its own description ("Load before any file modification, branch creation, or implementation start") does not match, so the guard is missing exactly where the mistake happened.
- `skills/work/SKILL.md` §4 compounds it: "Halt for authorization only on genuine ambiguity — never because an intermediate stage lacks its own approval"; "Missing upstream *artifacts* (no spec, plan, or branch yet) trigger the pipeline itself: run it from the earliest missing stage under the granted authorization"; "Downstream card gates … are never reasons to halt". Once one utterance has been misread as authorization, the pipeline becomes self-starting and no boundary remains to stop at.
- `skills/work/SKILL.md` §1 adds the pull: "Excess ceremony on a direct order is a defect signal, never thoroughness."

**The regression in one line:** the rip replaced a deterministic authorization classifier (closed verb-prefix table → scope → hard `halt_at` boundary, defaulting to read-only) with a prose vocabulary that ends in "default agent judgment", removed the explicit non-authorization classes from the always-injected surface, and made the pipeline self-starting under a single misjudged utterance.

## Scope

Deck surfaces in the `.opencode` repository:

- `floor.md` — the authorization vocabulary gains the non-authorization classes, the default read-only scope, the closed token set, the content-statement rule, and a qualified standing formula.
- `skills/work/SKILL.md` §1 and §4 — the pipeline-start and ceremony clauses are reconciled with the restored scope model.
- `tests-v2/` — one scenario reproducing the observed failure and one companion scenario proving the guard does not over-halt.

Untouched: the `spec`, `plan`, `implement`, `verify`, `git-workflow-*`, `issues`, and `behavioral-testing` cards' own mechanics; the `local-issues` tool; the `skill-creator` admission gate; the criteria sets; `attic/`.

Note on `floor.md`: a substantive write to the floor triggers the ainglish whole-card-on-touch conversion of the floor's normative prose (`guidelines/ainglish-writing-discipline.md`, "Adoption rules"). The authorization vocabulary lives in the floor, so the cost is accepted and the conversion is done in the same change.

## Requirements

- **R-1** — `floor.md`'s authorization vocabulary SHALL name the classes that are never authorization: a complaint, a question, a confirmation, feedback, and a developer's statement of a desired end state or content preference.
- **R-2** — `floor.md` SHALL state a default authorization scope for a session carrying no scope-bearing token, and that default SHALL be read-only: no branch creation, no file modification, no PR creation, no issue closure — reading, searching, and reporting only.
- **R-3** — `floor.md` SHALL state that an utterance matching no token in the vocabulary carries no authorization and routes to the default scope; the token set is closed.
- **R-4** — `floor.md` SHALL state that a developer's statement naming a desired end state is input to the current stage's artifact: the agent revises the artifact in place and reports; it does not advance the stage.
- **R-5** — `floor.md`'s standing formula SHALL be qualified so that "continue while next steps are clear" governs work inside the current stage and does not authorize crossing a stage boundary; crossing a stage boundary requires a token that names the stage.
- **R-6** — `skills/work/SKILL.md` §4 SHALL be reconciled with R-1..R-5: the pipeline-start clause SHALL be scoped to an existing scope-bearing authorization and SHALL NOT itself authorize a stage; the "genuine ambiguity" clause SHALL state that a stage boundary reached without a scope-bearing token is a halt, not an ambiguity.
- **R-7** — `skills/work/SKILL.md` §1's "excess ceremony" clause SHALL be scoped to within-stage ceremony and SHALL NOT apply to the authorization boundary.
- **R-8** — The behavioral harness (`tests-v2/`) SHALL carry a scenario reproducing the observed failure — a developer's plain-language content decision mid-spec — and SHALL require all of: the current artifact revised in place, no branch created, no tracked file modified, no PR opened, and a status report ending the turn.
- **R-9** — The harness SHALL carry the companion scenario: the same position with a scope-bearing token ("approved for implementation") DOES advance the stage — the restored guard SHALL NOT over-halt.
- **R-10** — The change SHALL add no tool command, no wrapper, no enforcement hook, and no threshold.

## Success criteria

- **SC-1 (structural)** — The floor names every non-authorization class. *Instrument:* `grep -q` in `floor.md` for each of: complaint, question, feedback, confirmation, and the content-statement class; all five must match.
- **SC-2 (structural)** — The floor states the default scope and its read-only blocklist. *Instrument:* `grep -q` for the default-scope statement and for each blocked action (branch creation, file modification, PR creation, issue closure) in `floor.md`.
- **SC-3 (structural)** — The floor states the closed token set. *Instrument:* `grep -q` for the statement that an utterance matching no token carries no authorization; and the sentence "Anything unlisted falls to default agent judgment" is either absent from `floor.md` or no longer governs the authorization decision.
- **SC-4 (structural)** — The floor states the content-statement rule. *Instrument:* `grep -q` for the rule that a stated desired end state is input to the current stage's artifact and does not advance the stage.
- **SC-5 (structural)** — The standing formula is qualified. *Instrument:* `grep -q` for the stage-boundary qualification in `floor.md`'s standing-formula paragraph.
- **SC-6 (structural)** — The `work` card carries the reconciled clauses. *Instrument:* `grep -q` in `skills/work/SKILL.md` for the scope-bearing precondition in §4 and for the within-stage scope of §1's ceremony clause.
- **SC-7 (behavioral)** — The reproduced-failure scenario passes. *Instrument:* a real harness run of the scenario under `tests-v2/` (the `opencode run` instrument, per the `behavioral-testing` card — no grep or static-analysis substitute), with clean-room evaluation against the five requirements in R-8; evidence is the run transcript and its verdict.
- **SC-8 (behavioral)** — The companion scenario passes. *Instrument:* the same harness, evaluating the R-9 requirement: the scope-bearing token advances the stage.
- **SC-9 (structural)** — The change adds no tool command, wrapper, enforcement hook, or threshold. *Instrument:* the change's file list against its base tip contains no added or modified file under `tools/`, `hooks/`, or `plugins/`; the amended text contains no numeric threshold on content size.

## Out of scope

- The `spec` card's artifact discipline, the `plan` card, and the `implement` card's own work-cycle rules — their mechanics are unchanged.
- The `local-issues` tool's implementation, and the store's numbering, label, and closure mechanics.
- The `skill-creator` admission gate and every other deck-governance rule.
- Any new tool command, wrapper, hook, or scenario harness beyond the two scenarios named in R-8 and R-9.
- A sweep of existing deck issues for comments or specs that the restored rules would classify differently — a developer-side cleanup, not a deck change.
- `michael-conrad.com#4` and the `.junie` corpus purge — separate work in a separate repository.

## Approach

Restore the pre-rip authorization model in the live deck, in the surface that is always injected, and prove it behaviorally.

1. **`floor.md`** — extend the authorization vocabulary with the five non-authorization classes (R-1); add the default read-only scope and its blocklist (R-2); close the token set so a non-matching utterance routes to the default scope rather than to agent judgment (R-3); state the content-statement rule (R-4); qualify the standing formula so it governs within-stage work only (R-5).
2. **`skills/work/SKILL.md`** — reconcile §4's pipeline-start clause and its "genuine ambiguity" clause with the restored model (R-6); scope §1's "excess ceremony" clause to within-stage ceremony (R-7).
3. **`tests-v2/`** — add the reproduced-failure scenario (R-8) and the companion no-over-halt scenario (R-9), both executed by the real harness.

No mechanism, no script, no threshold (R-10): the agent in the reported situation was not blocked by a missing rule but by a rule that had been dropped, so the deliverable is rule text that is true on its default path plus harness evidence that it holds.

The alternative — a hook or a wrapper that blocks implementation commands without a scope-bearing token — is discarded on the developer's standing ruling that scripted deck surfaces are the decks that get trashed and replaced, and because an agent that has misread an utterance will route around an interlock. The restored rule is a rule the agent reads before it acts, at the moment it decides what the developer authorized.

## Impact

- **Consumers:** every agent session in every repository the deck serves; the developer, whose authorization boundary stopped being mechanically decidable.
- **Risk:** over-halt — a legitimate "go" or scope-bearing token refused. Bounded by R-9's companion scenario and by the token list remaining a positive whitelist; a token-bearing session continues to advance.
- **Second risk:** friction — the default read-only scope requires an explicit token to move a stage, where the rip allowed judgment. Bounded by the vocabulary's positive whitelist: the developer's existing phrasings ("approved", "go", "approved for implementation", "continue") are enumerated and keep working.
- **Blast radius:** `floor.md`, `skills/work/SKILL.md`, and the `tests-v2/` scenario set. No tool, hook, script, or other card changes.
- **Recovery:** the change is a text change; the pre-rip wording it restores is preserved in `attic/` for reference.

> Full spec and plan artifacts: https://github.com/michael-conrad/.opencode/tree/issues-data/2664/

Artifacts for agents: `.opencode/.issues/2664/`.
