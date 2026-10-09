---
number: 1195
title: "[SPEC] re-establish agent communication discipline: no question tool, open-ended
  discussion, single-point back-and-forth, no solicitation"
state: OPEN
---

## Summary

The agent communication pattern regressed: forced-choice `question` tool usage, shotgun multi-topic messages, and work solicitation ("what should I do next?"). A 2026-10-09 review of this spec against the rewritten deck (floor.md + routing.md + skills/, `.opencode#2490`) found mandates 1–3 absorbed or superseded by live deck content, leaving one unimplemented gap: no card states the no-solicitation rule. This revision narrows the spec to that gap; original scope that is now dead or satisfied is recorded in the re-evaluation below and removed from the work.

## Root Cause

The original root cause stands: the agent's training bias toward offering choices and surfacing options produces solicitation patterns that push work back to the developer (identified during #1191/#1194 session work). The specific surviving gap: the floor's standing formula covers the unsure branch ("when unsure, halt with an open-ended clarification request") but not the done branch — nothing prohibits open-ended work solicitation once authorized work completes and is reported.

## Deck Re-evaluation (2026-10-09)

Disposition of the original four mandates against the live deck:

| Mandate | Disposition | Evidence |
|---|---|---|
| 1 — no question tool | Superseded by a later floor ruling | floor.md authorization vocabulary: the `question` tool is the canonical constrained-choice surface — prohibited for unsolicited decisions, unsure-halts, and `discuss` mode; picklists only when the developer requests options, presented in prose |
| 2 — open-ended, research-informed | Absorbed | `discuss` vocabulary entry (open-ended, no constrained choices); `explore` (research dispatches during discussion, live tool calls behind findings); `research` ("Never answer factual questions from training data without a live check") |
| 3 — single-point back-and-forth | Absorbed, scoped narrower | `discuss` ("one topic at a time"); `explore` ("one question per message, highest importance first") — scoped to discussion modes, not universal |
| 4 — no solicitation | Gap — unimplemented | Deck-wide sweep found zero solicitation patterns (compliant by absence) but also zero statements of the prohibition |

Original success criteria disposition: SC-1 targeted a section in `.opencode/AGENTS.md` — that file is now pointer-only and carries no rules, so the target is dead; the always-injected surface is `floor.md`. Original SC-3 (no question-tool solicitation patterns in active skill files) was verified satisfied on 2026-10-09 — the only `question`-tool reference in skills/ is `explore`'s citation of the floor's prohibition. Original SC-2 (mandates carry prohibitions and examples) carries forward onto the one surviving mandate below.

Deck edits route through the deck-governance card (`skill-creator`), admission gate first — the trace below supplies its inputs.

## Spec

### Phase 1: Add the no-solicitation rule to floor.md

Add to the floor's authorization-vocabulary section, adjacent to the standing formula, a rule to this effect:

> After completing authorized work: act within scope, report what was done, and wait. Never solicit the next assignment — no work-seeking, phase-seeking, or step-seeking questions ("How should I handle X?", "Should I proceed with Y?", "What would you like me to do next?", "Ready for the next step?"). When unsure, halt with an open-ended clarification request; when done, stop and wait — the developer states intent.

The rule composes with the standing formula: unsure → open-ended clarification request; done → report and wait without soliciting. Final wording is a plan/implementation decision within this constraint.

### Phase 2 [deferred]: behavioral evidence

Optional follow-up: produce behavioral evidence that the agent does not solicit after reporting — a session transcript reviewed by judgment, not a scripted check. Solicitation is intent-decidable; scripts are forbidden on it. Deferred unless the developer requests it.

## Admission-Gate Trace (skill-creator)

1. **Observed failure** — solicitation patterns identified during #1191/#1194 session work; confirmed as a live gap by this revision's 2026-10-09 deck review.
2. **Consumer** — every agent conversation turn, including turns where no card is dispatched.
3. **Mechanism/trigger** — `floor.md` always-injected surface; no dispatch needed to reach it.
4. **Predicate classification** — intent-decidable (solicitation is conversational intent); scripts forbidden; judgment decides.
5. **Domain match** — native to this domain (agent conversation discipline); nothing adopted from another domain.
6. **Root-agnostic** — no repo names or absolute paths in the rule.
7. **What it replaces** — nothing displaced; gap-fill complementing the standing formula, net one rule.
8. **Always-loaded surface discipline** — solicitation risk exists in conversational moments before or outside any card dispatch; the rule must be visible before any card dispatch, so floor placement is justified.

Deck-debt ledger: the implementation records the admission decision in the deck-debt issue (synced issue store).

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | floor.md contains an explicit no-solicitation rule: after authorized work completes, the agent reports and waits, and never solicits work, phases, steps, or assignments | `string` |
| SC-2 | The rule sits adjacent to the standing formula and composes with it — unsure → open-ended clarification request; done → report and wait without soliciting | `string` |
| SC-3 | No other deck file restates or contradicts the rule; existing citations (e.g. `explore`'s pointer to the floor's clarification ruling) remain consistent | `string` |

## Non-Goals

- Not revisiting the floor's `question`-tool ruling — it supersedes this spec's original Mandate 1
- Not adding scripted enforcement — solicitation is intent-decidable; scripts are forbidden on it (judgment-reviewed behavioral evidence remains available under Phase 2)
- Not modifying the `explore`, `discuss`, or `research` cards — Mandates 2–3 are absorbed there

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)