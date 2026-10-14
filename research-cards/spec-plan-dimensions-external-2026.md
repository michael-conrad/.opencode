---
research_question: "What do current (2026) external sources recommend for spec and plan dimensions for AI coding agents, and how do those recommendations compare to the deck's restored validation criteria (.opencode#2601)?"
confidence: 0.8
status: active
tags: [spec-writing, plan-writing, validation-criteria, SDD, task-decomposition]
created: 2026-10-14
last_updated: 2026-10-14
sources:
  - url: https://www.thebcms.com/blog/spec-driven-development/
    verified: 2026-10-14
  - url: https://agentengineering.org/articles/planning-and-task-decomposition/
    verified: 2026-10-14
  - url: https://nimbalyst.com/blog/coding-with-ai-agents-best-practices-2026/
    verified: 2026-10-14
  - url: https://arxiv.org/html/2602.00180v1
    verified: 2026-10-14
  - url: https://github.com/github/spec-kit
    verified: 2026-10-14
related_cards:
  - spec-writing-ai-agents-opencode-skill-architecture.md
---

# Spec & Plan Dimensions for AI Agents — 2026 External Landscape vs #2601 Restored Criteria

## Summary

The 2026 external consensus (GitHub Spec Kit, AWS Kiro, EARS notation, agentic-engineering writeups) converges on Specify → Plan → Tasks → Implement with human checkpoints at each boundary — the same shape the deck's pipeline already has. Per-task/per-criterion expectations match the deck's restored #2601 criteria almost point-for-point. Corroboration is strong; genuinely new candidate dimensions are few and small.

## Corroborated (external source ↔ deck criterion)

| External recommendation | Source | Deck criterion (post-#2601) |
|---|---|---|
| Atomic, independently shippable tasks; one objective each | thebcms (SDD Phase 3), agentengineering (execution grain) | plan-card item format; item-atomicity gap already identified in the #2601 scope expansion |
| Every task carries an acceptance check; verify before proceeding | thebcms Phase 4 | instrument reality (plan reference); RED/GREEN per item |
| Tests-first inversion; implement until green | nimbalyst | RED→GREEN chain, confirmed RED |
| Iterate bounded by the spec, not free-running | thebcms Phase 4 | SC fidelity (both directions), reverse drift |
| Human review at every phase boundary | thebcms | approval gates, human-only merge |
| Prohibitions are as important as requirements (SHALL NOT) | deliberate.codes (prior card), EARS unwanted-behavior pattern | gap analysis (untested boundaries) — partial |
| Not-Included section bounds the agent | augmentcode 7-section template | spec format §2 Not Included |
| Alternatives Considered prevents re-debating | Google design-doc pattern (prior card) | research adequacy family |
| Vague quality attributes are the top anti-pattern | Level Up (prior card) | ambiguous-criterion + untestable classes |
| EARS / RFC 2119 as a notation | thebcms, deliberate.codes | declined as format ceremony — judgment-phrased classes carry the substance (deck's founding defect class is keyword/trigger machinery) |

## New candidate dimensions surfaced (small)

1. **Meaningful grain** — a subtask so small it is bookkeeping, or so large it hides decisions, is a defect (agentengineering's "preserves meaningful progress"). The restored plan reference sizes items by SC but names no grain failure mode.
2. **Revisability** — plan items structured so a failed item can be adjusted without rewriting the plan from scratch (agentengineering). Weak candidate; the implement card's mid-cycle-change gate already stops the cycle instead of silently replanning.
3. **Explicit prohibitions as criteria** — "what SHALL NOT happen" as first-class SCs (deliberate.codes). Could fold into gap analysis as "prohibitions the stated problem implies but no criterion states."
4. **Spec-level decomposition** — a monolithic spec spanning unrelated concerns should split into focused specs (Level Up). Weak candidate; deck routing already scopes specs per issue.
5. **Clarify step** — the agent asks targeted ambiguity questions before finalizing the spec (Spec Kit /clarify). The deck's explore card covers pre-spec discussion; an in-specification ambiguity interview is not encoded. Weak candidate — risks duplicating explore.

## Verdict

No external 2026 source names a dimension the deck's restored criteria miss that outweighs ceremony risk. The six gaps found in the attic-vs-deck re-analysis (solution sufficiency, problem fit, item atomicity, instrument-nature match, approach fidelity, surface coverage) remain the load-bearing expansion; external sources corroborate four of the six. Candidates 1 and 3 above are the only externally-sourced additions worth considering; 2, 4, 5 are declined (duplication or lifecycle ceremony).

*Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)*
