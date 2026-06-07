---
number: 706
title: "[SPEC] Phase-level plans with TDD as mandate (not micromanagement script)"
status: "open"
labels: [spec, writing-plans, plan-autonomy]
created: "2026-05-20T19:27:03.906716Z"
updated: "2026-05-20T19:29:34.422737Z"
github_issue: 594
author: "Michael Conrad"
github_url: "https://github.com/michael-conrad/.opencode/issues/594"
promoted_at: "2026-05-20T19:19:36Z"
remote_issue: "594"
remote_url: "https://github.com/michael-conrad/.opencode/issues/594"
---

## Objective

Shift the `writing-plans` skill from producing micromanaging per-step implementation instructions ("exact code, exact commands, exact file paths", "2-5 minutes per step") to producing phase-level outcome-focused plans. The TDD cycle per item (RED→GREEN→adversarial audit) remains a **structural mandate** — it is a non-waivable verification protocol, not a script the implementing agent must follow keystroke-by-keystroke.

## Problem

The writing-plans skill currently enforces that plans contain:

- "Exact code, exact commands, exact file paths" — `plan-structure.md` Step 5
- "Each step is one action (2-5 minutes)" — `plan-structure.md` Step 5
- Rejection of abstract-but-legitimate guidance like "Add validation", "Handle edge cases" as plan failures — `validate.md` Lines 34-38

This treats the implementing agent as a script runner that must be told exactly what to type, not as an intelligent engineer. The result: plans are over-prescriptive, fragile, and waste effort on specifying keystrokes instead of outcomes.

Meanwhile, the TDD mandate per `091-incremental-build.md` already correctly defines the principle-level requirement: RED before GREEN, decomposition, verification evidence. The problem is that writing-plans re-implements this as a rigid script.

## Approach

### Phase 1: Revise `plan-structure.md`
- Replace micromanagement requirements with phase-level item definitions
- Items define **what concern they address** and **what verification outcomes prove success**
- Per-item TDD cycle kept as verification protocol reference (not implementation recipe)
- No "exact code, exact commands, exact file paths" — the agent determines HOW to implement
- No "2-5 minutes per step" — the agent organizes its own work
- Add Plan Autonomy Gate: "Could two implementing agents produce valid but different implementations from this plan?" If no → too prescriptive.

### Phase 2: Revise `validate.md`
- Remove "Add appropriate error handling", "Add validation", "Handle edge cases" from plan-failure list
- Reclassify as advisory (plan author may choose to be more specific, but it's not a validation failure)
- Keep: placeholder detection, symbol consistency, spec reference check, testability requirement, file structure completeness, sub-issue parent check

### Phase 3: Revise `writing-plans/SKILL.md`
- Remove "Every step is one action (2-5 min)" from overview
- Change TDD reference from "each step is RED→GREEN→REFACTOR" to "TDD cycle mandatory per item"
- Change "No placeholders: exact file paths, exact function/class names, exact commands" to "No placeholders: phase concerns, deliverables, and verification outcomes must be concrete"

### Phase 4: Behavioral Enforcement Test
Create `tests/behaviors/plan-autonomy-gate.sh` — RED scenario where abstract-but-legitimate guidance passes validation.

## Success Criteria

| ID | Criterion | Verification |
|----|-----------|-------------|
| SC-1 | Plans no longer require "exact code, exact commands, exact file paths" per item | No occurrence of "exact code" or "exact commands" in writing-plans task files |
| SC-2 | Plans no longer mandate "2-5 minutes per step" granularity | No occurrence of "2-5 minutes" in writing-plans task files |
| SC-3 | Plan Autonomy Gate exists: plans that permit only one implementation path are flagged | `plan-structure.md` contains "Plan Autonomy Gate" section with autonomy question |
| SC-4 | Validate no longer rejects "Add validation", "Handle edge cases", "Add appropriate error handling" as plan failures | `validate.md` removes these from the FAIL patterns table |
| SC-5 | TDD mandate remains structurally enforced per `091-incremental-build.md` | RED before GREEN requirement still referenced; no language weakening TDD as principle |
| SC-6 | Behavioral test exists that verifies validate gate accepts abstract phase-level guidance | `tests/behaviors/plan-autonomy-gate.sh` passes with phase-level plan content |
| SC-7 | SKILL.md overview and protocol updated to remove micromanagement language | No "2-5 min" or "exact code/commands" in SKILL.md |

## Accountability Model Alignment (per #763)

This spec intersects with #763 Principle 3: "Defective spec/plan is on the agent — agent owns defects, remediates."

Under #763, when validation flags a plan as too prescriptive, the producing agent rewrites it autonomously — no developer escalation needed for a fixable defect. Over-prescriptive plans are an agent output quality problem, not a "developer should give better instructions" problem.

## Dependencies

No external dependencies — all files are in `michael-conrad/.opencode`

🤖 Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)