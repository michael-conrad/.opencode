# Lessons Learned: #46 Spec/Plan Revision Cycle

## Context

Issue https://github.com/michael-conrad/viewport-editor/issues/46 (fastmcp switch) went through an intensive revision cycle where the spec and plan artifacts were corrected multiple times. This document captures the lessons learned for incorporation into spec-creation, writing-plans, and the adversarial-audit workflow.

---

## Lesson 1: Specs Are Forward-Looking Requirements, Not Tracking Documents

**Problem:** The spec and cards.md contained "implemented", "pending", "confirmed", "viable" status language. This treated the spec as a tracking dashboard.

**Correction:** Stripped all status badges. Cards.md now uses only What/Method/Risk. No decision log with dates.

**Rule:** Every spec is from the point of view "NEEDS TO BE IMPLEMENTED — HERE ARE THE REQUIREMENTS." Never describe what has been done; describe what must be done.

---

## Lesson 2: Plans State "What Must Be True", Not How to Achieve It

**Problem:** The plan prescribed exact line numbers (`server.py:16`), exact import strings (`from mcp.server.fastmcp`), and exact test assertion content. This treats the agent as a glorified editor.

**Correction:** RED describes the failure condition (not the assertion code). GREEN describes what must be true (not the exact code to write). The agent discovers file paths, line numbers, and implementation specifics independently.

**Rule:** RED = "what fails." GREEN = "what is true when done." Never prescribe how.

---

## Lesson 3: Every Unit Gets Its Own Pipeline Gate Table

**Problem:** The 14-step pipeline was stated once as a cross-reference at the top of the plan. Agents ignored it.

**Correction:** Every unit has its own Pipeline table with 14 gates and SC-specific exit criteria baked directly into the unit.

**Rule:** Requirements that apply per-unit must be embedded per-unit. A single shared reference at the top is invisible to agents during execution.

---

## Lesson 4: The 14 Pipeline Gates Are Explicit Mandates

The following gates are not optional — every unit must pass all 14:

1. sc-coherence-gate
2. pre-red-baseline
3. red-phase
4. red-doublecheck
5. green-phase
6. checkpoint-commit
7. structural-checks
8. green-doublecheck
9. green-vbc
10. adversarial-audit
11. cross-validate
12. regression-check
13. review-prep
14. exec-summary

These are not a cross-reference — they must be enumerated per-unit in the plan.

---

## Lesson 5: Z3 Model Must Enforce Pipeline Completion

**Problem:** The original Z3 model only tracked domain variables (DEP_SWITCH, etc.) without any pipeline gate enforcement.

**Correction:** Each unit's domain variable is `True` only after all 14 pipeline gates pass. The contract declares 14 booleans per unit (e.g., `DEP_p1..p14`) with invariants enforcing serial ordering and completion.

**Rule:** The Z3 model must reject a state where a domain variable is `True` but its pipeline gates are incomplete. Pipeline gates are not optional — they are enforced by the model.

---

## Lesson 6: Contract Preconditions Conflict with State Updates

**Problem:** The contract declared `z3.Not(DEP_SWITCH)` as a precondition, which made the model UNSAT after the first state update.

**Correction:** Removed all preconditions from the contract. Invariants and postconditions alone are sufficient to model intermediate states.

**Rule:** Preconditions belong in state.yaml initialization, not in the contract. The contract models arbitrary intermediate states — preconditions that assume the initial state block valid transitions.

---

## Lesson 8: Never Use Bare `#N` — Full URLs Always

**Problem:** Bare `#N` issue references assume a repo context that gets lost when content is copied, moved, or consumed by agents in a different repo. Because the organization has multiple cross-linked repos, content from viewport-editor ends up in `.opencode` issues, `.opencode` artifacts get referenced from viewport-editor, etc. Every time bare `#N` is used, it will eventually be read in the wrong repo context and route to the wrong issue.

This is not a theoretical concern — it happened repeatedly during this session when `.issues/` content from one repo was referenced from another.

**Correction:** Never use bare `#N` in any spec, plan, card, or artifact content. Always use the full URL: `https://github.com/{owner}/{repo}/issues/{N}`. This applies everywhere — cross-repo, same-repo, GitHub, GitBucket, all issue trackers.

**Rule:** No bare `#N` anywhere in spec or plan content. Full URLs only. Period.

---

## Summary Card

| Pattern | Problem | Fix |
|---------|---------|-----|
| Status badges in spec | Tracking language | Pure requirements; no status |
| Decision log in cards.md | Tracking language | What/Method/Risk only |
| Line numbers in plan | Micromanagement | RED/GREEN describe conditions, not code |
| Single shared pipeline ref | Ignored by agents | Pipeline table per unit |
| Domain-only Z3 model | Pipeline not enforced | 14 pipeline gates per unit |
| Preconditions in contract | UNSAT on state update | Invariants + postconditions only |
| Hardcoded file lists | Stale on file changes | Sub-folder refs for agents to glob |
| Bare `#N` refs | Routes to wrong issue when read in different repo | Full URLs only, always |