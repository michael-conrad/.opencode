<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->

# [SPEC] Validation loop — revision-count trigger for decomposition re-evaluation

Resolves `.opencode#2660`.

## 1. Intent and Executive Summary

| # | Field | Description |
|---|-------|-------------|
| 1 | **Problem Statement** | The deck's spec-and-plan validation loop has an unbounded stop condition and a spin detector that keys on **repetition**, so a loop in which each round finds genuinely new but shallow defects never triggers it. The current rule, in `skills/spec/references/validation-standards.md` and `skills/plan/references/plan-validation-standards.md`, reads: *"FAIL → revise the named findings in the artifact in place → re-validate. The revise → re-validate cycle repeats until a verdict with zero findings. … Each cycle, the agent running the loop judges — never a script — whether the loop is spinning: findings recurring or reshuffling without genuine resolution relative to the remediation performed."* Two consequences: the stop condition is unbounded, and the spin detector's key is repetition — so a loop whose findings are **not** recurring never fires it, however many rounds run. The revision step's higher-level responses (*"splitting an over-fat spec, resolving a spec conflict, restructuring into atomic work units, or re-evaluating the approach"*) are reached only when a reviewer happens to judge the loop spinning, and never on a count. |
| 2 | **Root Cause / Motivation** | The measured instance is `.opencode#2658`: **eleven** validation rounds, with the requirement set stable and internally consistent for most of them while the findings migrated through the spec's evidence section and the prose describing it. The evidence section was 112 of the spec's 221 lines — 55% of the artifact was *evidence*, and it was being re-audited line by line in every round; the last six rounds' findings were a mis-cited section pointer, a mis-rendered table cell, a duplicated paragraph, a stale sentence, and a mis-cited item number. The higher-level response was the *correct* one and the loop's own detector could not find it: recomposition — moving the exhibit out of the normative spec into a cited research artifact, and moving the issue-store record repairs into a separate spec on a different repository surface — resolved the remaining findings immediately, where eleven rounds of in-place revision had not. A count-based trigger would have reached that recomposition at round five. |
| 3 | **Approach Chosen** | Add a revision-count trigger and the re-evaluation factors to the three loop locations: `skills/spec/references/validation-standards.md` §Loop, `skills/plan/references/plan-validation-standards.md` §Loop, and `skills/verify/SKILL.md` §4. The trigger is stated once in the spec card's criteria source and cross-referenced from the other two, so the criteria source remains the single bar. The trigger is a count — fact-decidable; the re-evaluation it opens is judgment, which the deck's predicate classification permits, because a *mechanism* may not be scripted where the decision is intent-decidable. |
| 4 | **Alternatives Considered & Why Discarded** | (a) **Extend the existing spin judgment to cover this case** — discarded: the judgment already covers it in principle, and the measured failure is that a judgment is required to notice a thing a count would show. (b) **Cap the number of rounds outright** (e.g. "after six rounds, escalate to the developer") — discarded: escalation without recomposition punishes the agent for a decomposition fault that is the agent's to fix; the trigger must open a re-evaluation, not a halt. (c) **Make the spin detector fact-decidable by requiring the reviewer to classify each finding's depth** — discarded: a finding's depth is intent-decidable, and the deck forbids scripting intent-decidable judgments; a round count is the one proxy that is not. (d) **Put the rule only in the spec card** — discarded: the plan's loop and the verify card's review loop are the same loop, and a rule in one place that the other two do not carry is a rule that does not bind. (e) **Change the criteria sets** — discarded: the defect classes, analysis families, verdict contract, and criteria invariance are not what failed; the stop condition was. |
| 5 | **Key Design Decisions** | (1) **The trigger is a count, not a judgment.** Four revisions is a fact the agent can check, so the rule binds without an interpretive step — and R-7 keeps it from becoming a licence to stop. (2) **The trigger opens a re-evaluation, it does not end the loop.** The artifact still has to reach a zero-finding verdict; what changes at the threshold is *how* it is revised. (3) **The re-evaluation's factors are named, not open-ended** — repo boundaries, separation of concerns, atomic work-unit decomposition, fatness, and the intent-language question — so the re-evaluation is a checklist against stated factors rather than a vague "reconsider the artifact". (4) **The outcome is recorded**, so a trigger that fires and produces no recomposition is visible rather than silent. (5) **The existing higher-level responses are retained**; the count trigger is an additional, non-judgmental way of reaching them. (6) **One bar, three locations.** The rule is stated once in the spec card's criteria source and cross-referenced, keeping the deck's single-bar discipline. (7) **Predicate classification** — the trigger is fact-decidable; the re-evaluation is intent-decidable and stays with the agent. (8) **Root-agnostic** — the rule names no repository, path, or deck file beyond the three it governs. |
| 6 | **User Intent / Original Prompt** | Session 2026-10-23: the developer observed that *the agent may be getting stuck in long performative revise/audit loops on specs and plans*, and directed that *if a spec or plan needs more than 4 revisions to address defects, it needs to be re-evaluated for proper decomposition and recomposition* — *taking into account things like repo boundaries, separation of concerns, atomic work unit decomposition and recomposition needing re-evaluation, or the spec being too fat and needing to split up into multiple inter-dependent specs among other possible issues*, and that *it may also be an indicator that the spec's intent is poorly worded or not reachable*. |

## 2. Scope

### 2.1 Affected surfaces

| Surface | Change |
|---|---|
| `skills/spec/references/validation-standards.md` §Loop | The revision-count trigger and the re-evaluation factors; the recording requirement; the retained findings-are-fixed requirement |
| `skills/plan/references/plan-validation-standards.md` §Loop | The same, cross-referenced from the spec card's criteria source |
| `skills/verify/SKILL.md` §4 | The same, in the review loop's spin condition |

### 2.2 Surfaces deliberately untouched

- **The criteria sets themselves** — defect classes, analysis families, verdict contract, and criteria invariance are unchanged. The defect was the stop condition, not the bar.
- **Content cards** — this changes how the loop decides to stop and re-evaluate, not what any card says about its domain.
- **The `verify` card's review-loop mechanics** beyond the spin condition.
- **The `skill-creator` admission gate** and every other deck-governance rule.

## 3. Requirements

- **R-1** — Each of the three loop locations SHALL carry a **revision-count trigger**: when an artifact has required more than **four** revision cycles to reach a zero-finding verdict, the in-place revision loop stops and the artifact is re-evaluated before any further in-place revision.
- **R-2** — The trigger SHALL be fact-decidable — a count of revision cycles, not an agent judgment about whether the loop is spinning — and SHALL be stated as a threshold a reader can apply without interpreting it.
- **R-3** — The re-evaluation SHALL examine, at minimum: **repo boundaries** (whether the artifact mixes work landing on different repository surfaces), **separation of concerns** (whether it mixes normative content with evidence, or record hygiene with normative change), **atomic work-unit decomposition** (whether its units are independently verifiable), and **fatness** (whether it should split into multiple interdependent artifacts).
- **R-4** — The re-evaluation SHALL also consider whether the artifact's **intent is poorly worded or not reachable**, and whether the intent statement is the thing that needs rewriting before the decomposition is.
- **R-5** — The re-evaluation's outcome SHALL be recorded: either the artifact is recomposed — split, re-scoped, or re-worded, with the recomposition noted — or the trigger is recorded as not indicating a decomposition fault, with the reason.
- **R-6** — The existing higher-level responses to a spinning loop (breaking up a composite criterion, splitting an over-fat artifact, restructuring into atomic work units, re-evaluating the approach) SHALL remain, and the count trigger SHALL be stated as an additional, non-judgmental way of reaching them.
- **R-7** — The change SHALL NOT weaken the requirement that findings are genuinely fixed rather than negotiated away, and SHALL NOT make a count of revisions a substitute for that requirement.

## 4. Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | Each of the three loop locations states the revision-count trigger, and the threshold is the same number in all three | structural | Read of `skills/spec/references/validation-standards.md` §Loop, `skills/plan/references/plan-validation-standards.md` §Loop, and `skills/verify/SKILL.md` §4; assert each carries the trigger and that the thresholds agree |
| SC-2 | The trigger is stated as a count an agent can apply without judgment, and does not depend on the repetition-based spin judgment | structural | Read of the three loop locations; assert the trigger is stated independently of the spin condition |
| SC-3 | The re-evaluation's factors include repo boundaries, separation of concerns, atomic work-unit decomposition, and fatness, and the intent-language question | structural | Read of the three loop locations; assert each factor is named |
| SC-4 | The re-evaluation's outcome is required to be recorded, either a recomposition or a recorded reason that the trigger did not indicate a decomposition fault | structural | Read of the three loop locations; assert the recording requirement |
| SC-5 | The requirement that findings are genuinely fixed is retained and is not made satisfiable by reaching a revision count | structural | Read of the three loop locations; assert the findings-are-fixed requirement and the count trigger are stated as separate obligations |

**Traceability.** SC-1↔R-1 and R-2, SC-2↔R-2, SC-3↔R-3 and R-4, SC-4↔R-5, SC-5↔R-6 and R-7 — every requirement is covered and no criterion is orphaned.

**Causal sufficiency.** R-1 and R-2 answer the unbounded stop condition and the repetition-keyed detector. R-3 and R-4 answer the absence of named re-evaluation factors, and carry the developer's stated list and the intent-language question. R-5 answers the risk of a trigger that fires and produces nothing. R-6 and R-7 answer the risk of weakening the findings-are-fixed requirement.

## 5. Out of Scope

- The criteria sets themselves — defect classes, analysis families, verdict contract, criteria invariance.
- The `verify` card's own review-loop mechanics beyond the spin condition.
- Any content card, any domain rule, and any change to the `skill-creator` card's admission gate.
- The `.opencode#2658` recomposition itself, which is the instance this rule was derived from and is tracked there.

## 6. Evidence

**The measured instance.** `.opencode#2658` — this session's spec for the deck's closing-keyword contract — went through **eleven** fresh-context validation rounds. The requirement set (twelve requirements, twelve criteria, one-to-one) was stable and internally consistent from the third round onward, and the reviewer's own "verified clean" lists grew to cover the entire platform measurement, the whole family record, and the deck sweep. Every finding from round six onward was in the evidence section or in prose describing it: a mis-cited section pointer, a mis-rendered table cell, a duplicated paragraph, a stale sentence, a mis-cited item number. The revision step's own higher-level responses — *"splitting an over-fat spec … restructuring into atomic work units, or re-evaluating the approach"* — were the correct response and were never reached, because the spin detector keys on findings *recurring or reshuffling*, and these findings were neither.

**What the recomposition did.** Moving the 112-line exhibit out of the normative spec into a cited research artifact, and moving the issue-store record repairs into a separate spec on a different repository surface, resolved the remaining findings at once. The exhibit is now audited once as evidence rather than re-audited inside every validation loop, and the store repairs are tracked where they land — the store's `issues-data` branch, not the deck's trunk.

**Why a count.** The spin judgment asks whether findings are recurring. Here they were genuinely new each round, and shallow — so the judgment's answer was "not spinning" and it would keep answering that while the rounds accumulated. A count is the one proxy for this that is not an interpretation, and it is the one that maps to the remedy: at five revisions, the question stops being "which sentence do I edit" and becomes "is this artifact the right shape".

## 7. Provenance

- Spec: `.opencode/.issues/2660/spec.md`.
- Remote issue: https://github.com/michael-conrad/.opencode/issues/2660
- The instance this rule was derived from: `.opencode#2658`, whose recomposition is recorded in its own spec and research artifact.
- The loop text being changed: `skills/spec/references/validation-standards.md` §Loop, `skills/plan/references/plan-validation-standards.md` §Loop, `skills/verify/SKILL.md` §4.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
