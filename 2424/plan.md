---
plan_schema_version: 1
issue: 2424
title: "Remediate executing-plans SKILL.md — sub-agent dispatch prefixes and validator conformance"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 4
dispatch:
  - phase-1: test-driven-development (red, green), verification-before-completion (verify), commit-inline (orchestrator)
  - phase-2: test-driven-development (red, green), verification-before-completion (verify), commit-inline (orchestrator)
  - phase-3: test-driven-development (red, green), verification-before-completion (verify), commit-inline (orchestrator)
  - phase-4: verification-before-completion (verify — behavioral gate)
---

# Implementation Plan — Remediate executing-plans SKILL.md (`.opencode#2424`)

- **Issue:** `.opencode/.issues/2424/spec.md`

## Goal / Architecture / Files / Dispatch

- **Goal:** Make `.opencode/skills/executing-plans/SKILL.md` conform to the deck standard: both dispatch prompt strings carry the `You are a sub-agent.` prefix inside the quote, the byline uses the placeholder form, `## Worktree Mode` and `## Mandatory Task Discipline` sections are added with canonical content, the Workflows section uses numbered format, dispatch link texts become purpose condensations, and the validator reports zero violations for the card.
- **Architecture:** Single-file remediation. All four phases edit disjoint regions of the same file (dispatch prompt text / byline+sections+headers / link labels / aggregate gate) so each phase's diff is revert-isolated. Phases 1-3 are mutually independent; Phase 4 is the aggregate gate depending on all prior items.
- **Files:** `.opencode/skills/executing-plans/SKILL.md` (only file modified; task files and validator untouched).
- **Dispatch:** Each item runs the per-task cycle (red → green → post-regression → verify → commit-inline) with red/green/verify dispatched as task cards and commit executed inline by the orchestrator. Phase 4 is a verify-only behavioral gate with no commit.

## Blast Radius

- Affected file: `.opencode/skills/executing-plans/SKILL.md` — the sole skill card flagged by `validate_skill_cards.py` on REQ-2, REQ-3, REQ-5, REQ-6 (live run 2026-09-19).
- Impact zones: Workflows section entries (dispatch prompt text, link labels), file byline, new sections appended per canonical deck form. No caller of the card changes behavior other than improved dispatch prompt text. Task cards (`tasks/read-plan.md`, `tasks/execute-phase.md`) and all other deck cards are untouched (constraints R-10, R-11, R-12).

> **Compliance:** All SCs must pass before completion. Partial implementation is not permitted. Each item is daisy-chained — item N's commit is precondition for item N+1's RED.

> **One step at a time.** Execute exactly one step. Report progress. Wait for instruction before the next step.

> **Step status:** Report `[item N] [PASS|FAIL]` after each step. If FAIL, report blocker and halt.

> **Enforcement gate:** All SCs must pass before this plan is complete.

## Phase Table

| Phase | Name | Concern | SCs | Depends On | Step Range | Dispatch |
|-------|------|---------|-----|------------|------------|----------|
| 1 | Dispatch prompt sub-agent prefixes | read-plan and execute-phase dispatch prompt strings gain the `You are a sub-agent.` role-identification prefix | SC-1, SC-2 | — | 5-14 | direct (1-4, 9, 14, 48-55) + task-card (5-8, 10-13) |
| 2 | Validator REQ remediation (REQ-2, REQ-3, REQ-6) | byline placeholder, Worktree Mode section, numbered Workflows format | SC-3, SC-4, SC-5 | — | 15-29 | direct (1-4, 19, 24, 29, 48-55) + task-card (15-18, 20-23, 25-28) |
| 3 | Purpose-condensation alignment and Mandatory Task Discipline section | dispatch link text condensations (standards alignment) and REQ-5 section addition | SC-6, SC-7, SC-8 | — | 30-44 | direct (1-4, 34, 39, 44, 48-55) + task-card (30-33, 35-38, 40-43) |
| 4 | Full validator conformance gate | aggregate behavioral gate — executing-plans card passes all validator checks with zero violations | SC-9 | 1, 2, 3 | 45-47 | direct (1-4, 48-55) + task-card (45-47) |

> **Self-Remediation Protocol:** If a step FAILs: diagnose root cause, fix the deliverable, re-verify. If the fix requires spec revision, update the spec and re-enter the plan. Escalate only after remediation failure.

## Pre-Implementation (once per plan)

- [ ] 1. **Coherence gate** (**direct**)
  - Re-read this plan against spec `.opencode/.issues/2424/spec.md` §3: confirm all 9 SCs are covered by exactly one item each and the phase DAG (1,2,3 → 4) has no cycles.
  - Confirm the stale `sc-summary.yaml` (8 SCs) is not used as coverage authority — spec.md §3 governs.
- [ ] 2. **Baseline check** (**direct**)
  - Verify clean working tree on the feature branch; run `git status` and `git submodule status`.
  - Capture pre-change validator state: `uv run .opencode/skills/skill-creator/scripts/validate_skill_cards.py --json` and record the executing-plans violations (expected: REQ-2, REQ-3, REQ-5, REQ-6).
- [ ] 3. **Pre-regression** (**task-card**) — `task(..., prompt: "execute phase-0 task from test-driven-development")`
  - Run regression test patterns before RED phase.
  - Pre-cleanup: `rm -f {project_root}/tmp/2424/artifacts/pipeline-pre-regression-*`
- [ ] 4. **Pre-regression verify** (**task-card**) — `task(..., prompt: "execute verify task from verification-before-completion")`
  - Verify pre-regression results.
  - Pre-cleanup: `rm -f {project_root}/tmp/2424/artifacts/pipeline-pre-regression-verify-*`

## Phase 1 — Dispatch prompt sub-agent prefixes

- **Concern:** the read-plan and execute-phase dispatch prompt strings gain the `You are a sub-agent.` role-identification prefix, inside the quoted prompt string, immediately before `Follow the instructions in`.
- **Files:** `.opencode/skills/executing-plans/SKILL.md` (Workflows section dispatch prompt text only)
- **SCs:** SC-1, SC-2
- **Dependencies:** none
- **Entry:** pre-implementation steps 1-4 complete; validator baseline recorded.
- **Exit:** both dispatch prompt strings carry the prefix inside the quote; two commits exist (one per item).

### Code Path Coverage

- `.opencode/skills/executing-plans/SKILL.md` → Workflows section → `Read the plan` entry (`tasks/read-plan.md`) → dispatch prompt string composition.
- `.opencode/skills/executing-plans/SKILL.md` → Workflows section → `Execute phases in sequence` entry (`tasks/execute-phase.md`) → dispatch prompt string composition.

### Cross-Cutting SCs

- R-10 (task files unmodified), R-11 (no other card modified) apply to both items — verified per item by `git status` showing only SKILL.md changed.

### Interface Boundaries

- The dispatch prompt template shape must match the pinned conformance baseline `git show 125b423e:skills/spec-creation/SKILL.md`: `You are a sub-agent. Follow the instructions in [<condensation>](<path>). <context...>`.

### State Transitions

- Card state `non_conformant` → `partial` after both items commit (dispatch-prefix defects resolved; REQ-2/3/5/6 defects remain until Phases 2-3).

### Step-by-step

- [ ] 5. **Item 1 — RED** (**task-card**) — `task(..., prompt: "execute red task from test-driven-development")`
  - SC reference: SC-1
  - Grep the read-plan entry's dispatch prompt text; assert the `You are a sub-agent.` prefix is absent (RED condition: prefix missing today).
  - Pre-cleanup: `rm -f {project_root}/tmp/2424/artifacts/pipeline-red-*`
- [ ] 6. **Item 1 — GREEN** (**task-card**) — `task(..., prompt: "execute green task from test-driven-development")`
  - SC reference: SC-1
  - Prepend `You are a sub-agent.` to the read-plan entry's dispatch prompt string inside the quote, immediately before `Follow the instructions in`.
- [ ] 7. **Item 1 — post-regression** (**task-card**) — `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - SC reference: SC-1
  - Run regression test patterns after GREEN phase.
  - Pre-cleanup: `rm -f {project_root}/tmp/2424/artifacts/pipeline-post-regression-*`
- [ ] 8. **Item 1 — verify** (**task-card**) — `task(..., prompt: "execute verify task from verification-before-completion")`
  - SC reference: SC-1
  - Grep for `You are a sub-agent` in the read-plan dispatch prompt; visual diff vs pinned baseline `git show 125b423e:skills/spec-creation/SKILL.md`.
  - Pre-cleanup: `rm -f {project_root}/tmp/2424/artifacts/pipeline-verify-*`
- [ ] 9. **Item 1 — commit** (**direct**)
  - SC reference: SC-1
  - Orchestrator runs `git add .opencode/skills/executing-plans/SKILL.md && git commit -m "executing-plans: add sub-agent prefix to read-plan dispatch prompt"` (no co-author trailers).
- [ ] 10. **Item 2 — RED** (**task-card**) — `task(..., prompt: "execute red task from test-driven-development")`
  - SC reference: SC-2
  - Grep the execute-phase entry's dispatch prompt text; assert the `You are a sub-agent.` prefix is absent.
  - Pre-cleanup: `rm -f {project_root}/tmp/2424/artifacts/pipeline-red-*`
- [ ] 11. **Item 2 — GREEN** (**task-card**) — `task(..., prompt: "execute green task from test-driven-development")`
  - SC reference: SC-2
  - Prepend `You are a sub-agent.` to the execute-phase entry's dispatch prompt string inside the quote, immediately before `Follow the instructions in`.
- [ ] 12. **Item 2 — post-regression** (**task-card**) — `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - SC reference: SC-2
  - Run regression test patterns after GREEN phase.
  - Pre-cleanup: `rm -f {project_root}/tmp/2424/artifacts/pipeline-post-regression-*`
- [ ] 13. **Item 2 — verify** (**task-card**) — `task(..., prompt: "execute verify task from verification-before-completion")`
  - SC reference: SC-2
  - Grep `You are a sub-agent` in the execute-phase dispatch prompt; visual diff vs pinned baseline.
  - Pre-cleanup: `rm -f {project_root}/tmp/2424/artifacts/pipeline-verify-*`
- [ ] 14. **Item 2 — commit** (**direct**)
  - SC reference: SC-2
  - Orchestrator runs `git add .opencode/skills/executing-plans/SKILL.md && git commit -m "executing-plans: add sub-agent prefix to execute-phase dispatch prompt"` (no co-author trailers).

### Phase Completion Block

- Verify SC-1 and SC-2 verdicts are PASS with string evidence; report `[item 1] [PASS]` and `[item 2] [PASS]`.
- **Cost frame:** Verifying each dispatch prompt prefix costs one grep search. Skipping means the sub-agent is dispatched without the role-identification prefix and fails to read the task card independently — a behavioral failure at the first dispatch.

### Concern Transition

- Dispatch-prompt region complete; Phase 2 shifts to the byline/section/header region of the same file.

## Phase 2 — Validator REQ remediation (REQ-2, REQ-3, REQ-6)

- **Concern:** byline placeholder (REQ-2), missing Worktree Mode section (REQ-3), numbered Workflows format (REQ-6).
- **Files:** `.opencode/skills/executing-plans/SKILL.md` (byline, section additions, Workflows step headers)
- **SCs:** SC-3, SC-4, SC-5
- **Dependencies:** none (disjoint region from Phase 1)
- **Entry:** Phase 1 complete (or executed independently — regions are disjoint).
- **Exit:** validator REQ-2, REQ-3, REQ-6 violations resolved; three commits exist (one per item).

### Code Path Coverage

- `.opencode/skills/executing-plans/SKILL.md` → file byline (`Co-authored with AI:` line).
- `.opencode/skills/executing-plans/SKILL.md` → `## Worktree Mode` section (new, inserted with canonical body per spec Appendix A).
- `.opencode/skills/executing-plans/SKILL.md` → `## Workflows` section step headers (`- [ ] N. **` → `N. **`).

### Cross-Cutting SCs

- R-12 (validator unmodified) applies — the validator is invoked read-only for RED/verify evidence in every item of this phase.

### Interface Boundaries

- SC-4 section body must be the Appendix A verbatim sentence exactly: `This skill operates in the main repo directory (direct-branch mode). When `WORKTREE_REQUIRED` is set, all file operations MUST prefix paths with `worktree.path`.` — no external diff required; the quote is the sole pass condition.
- SC-8 section content (Phase 3) must follow the conforming form in `completion-core/SKILL.md` — do not conflate the two sections.

### State Transitions

- Card state `partial` → `partial` (REQ-2/3/6 resolved; REQ-5 and condensation remain until Phase 3).

### Step-by-step

- [ ] 15. **Item 3 — RED** (**task-card**) — `task(..., prompt: "execute red task from test-driven-development")`
  - SC reference: SC-3
  - Run `uv run .opencode/skills/skill-creator/scripts/validate_skill_cards.py --json`; assert the REQ-2 byline placeholder violation is present for executing-plans.
  - Pre-cleanup: `rm -f {project_root}/tmp/2424/artifacts/pipeline-red-*`
- [ ] 16. **Item 3 — GREEN** (**task-card**) — `task(..., prompt: "execute green task from test-driven-development")`
  - SC reference: SC-3
  - Replace `OpenCode (deepseek-v4-flash)` with `<AgentName> (<ModelId>)` in the byline.
- [ ] 17. **Item 3 — post-regression** (**task-card**) — `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - SC reference: SC-3
  - Run regression test patterns after GREEN phase.
  - Pre-cleanup: `rm -f {project_root}/tmp/2424/artifacts/pipeline-post-regression-*`
- [ ] 18. **Item 3 — verify** (**task-card**) — `task(..., prompt: "execute verify task from verification-before-completion")`
  - SC reference: SC-3
  - Grep the byline for `<AgentName> (<ModelId>)`; assert the hardcoded `OpenCode (deepseek-v4-flash)` is absent.
  - Pre-cleanup: `rm -f {project_root}/tmp/2424/artifacts/pipeline-verify-*`
- [ ] 19. **Item 3 — commit** (**direct**)
  - SC reference: SC-3
  - Orchestrator runs `git add .opencode/skills/executing-plans/SKILL.md && git commit -m "executing-plans: use byline placeholder form (REQ-2)"` (no co-author trailers).
- [ ] 20. **Item 4 — RED** (**task-card**) — `task(..., prompt: "execute red task from test-driven-development")`
  - SC reference: SC-4
  - Run the validator; assert the REQ-3 worktree-mode violation is present for executing-plans.
  - Pre-cleanup: `rm -f {project_root}/tmp/2424/artifacts/pipeline-red-*`
- [ ] 21. **Item 4 — GREEN** (**task-card**) — `task(..., prompt: "execute green task from test-driven-development")`
  - SC reference: SC-4
  - Insert the `## Worktree Mode` section with exactly the Appendix A verbatim text from the spec.
- [ ] 22. **Item 4 — post-regression** (**task-card**) — `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - SC reference: SC-4
  - Run regression test patterns after GREEN phase.
  - Pre-cleanup: `rm -f {project_root}/tmp/2424/artifacts/pipeline-post-regression-*`
- [ ] 23. **Item 4 — verify** (**task-card**) — `task(..., prompt: "execute verify task from verification-before-completion")`
  - SC reference: SC-4
  - Grep for the `## Worktree Mode` heading; grep the section body for the Appendix A canonical sentence.
  - Pre-cleanup: `rm -f {project_root}/tmp/2424/artifacts/pipeline-verify-*`
- [ ] 24. **Item 4 — commit** (**direct**)
  - SC reference: SC-4
  - Orchestrator runs `git add .opencode/skills/executing-plans/SKILL.md && git commit -m "executing-plans: add Worktree Mode section (REQ-3)"` (no co-author trailers).
- [ ] 25. **Item 5 — RED** (**task-card**) — `task(..., prompt: "execute red task from test-driven-development")`
  - SC reference: SC-5
  - Run the validator; assert the REQ-6 workflows-steps violation is present for executing-plans.
  - Pre-cleanup: `rm -f {project_root}/tmp/2424/artifacts/pipeline-red-*`
- [ ] 26. **Item 5 — GREEN** (**task-card**) — `task(..., prompt: "execute green task from test-driven-development")`
  - SC reference: SC-5
  - Convert `- [ ] N. **` checkbox headers to `N. **` numbered format, preserving sub-bullets.
- [ ] 27. **Item 5 — post-regression** (**task-card**) — `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - SC reference: SC-5
  - Run regression test patterns after GREEN phase.
  - Pre-cleanup: `rm -f {project_root}/tmp/2424/artifacts/pipeline-post-regression-*`
- [ ] 28. **Item 5 — verify** (**task-card**) — `task(..., prompt: "execute verify task from verification-before-completion")`
  - SC reference: SC-5
  - Grep the Workflows section for the `- [ ] N. **` checkbox prefix; assert it is absent.
  - Pre-cleanup: `rm -f {project_root}/tmp/2424/artifacts/pipeline-verify-*`
- [ ] 29. **Item 5 — commit** (**direct**)
  - SC reference: SC-5
  - Orchestrator runs `git add .opencode/skills/executing-plans/SKILL.md && git commit -m "executing-plans: numbered Workflows step format (REQ-6)"` (no co-author trailers).

### Phase Completion Block

- Verify SC-3, SC-4, SC-5 verdicts are PASS with string evidence; report `[item 3] [PASS]`, `[item 4] [PASS]`, `[item 5] [PASS]`.
- **Cost frame:** Verifying the byline placeholder, Worktree Mode section, and Workflows format each cost one grep search. Skipping means the REQ-2/3/6 violations are only caught at the next validator run — a death-spiral start where a string PASS masks conformance defects.

### Concern Transition

- Byline/section/header region complete; Phase 3 shifts to the dispatch link labels and the Mandatory Task Discipline section.

## Phase 3 — Purpose-condensation alignment and Mandatory Task Discipline section

- **Concern:** dispatch link text condensations for read-plan/execute-phase (SC-6/SC-7, standards alignment with the purpose-condensation rule) and REQ-5 Mandatory Task Discipline section addition (SC-8).
- **Files:** `.opencode/skills/executing-plans/SKILL.md` (Workflows link labels; new `## Mandatory Task Discipline` section)
- **SCs:** SC-6, SC-7, SC-8
- **Dependencies:** none (disjoint regions from Phases 1-2)
- **Entry:** Phases 1-2 complete (or executed independently — regions are disjoint).
- **Exit:** link texts are purpose condensations; REQ-5 resolved; three commits exist (one per item).

### Code Path Coverage

- `.opencode/skills/executing-plans/SKILL.md` → Workflows section → `Read the plan` entry link label (`tasks/read-plan.md` href unchanged).
- `.opencode/skills/executing-plans/SKILL.md` → Workflows section → `Execute phases in sequence` entry link label (`tasks/execute-phase.md` href unchanged).
- `.opencode/skills/executing-plans/SKILL.md` → `## Mandatory Task Discipline` section (new, canonical four-item checklist).

### Cross-Cutting SCs

- R-10/R-11 (task files and other cards unmodified) apply to the link-text items — hrefs stay identical so sub-agent discovery still resolves.
- Note: SC-6/SC-7 are standards-alignment items, not validator-finding remediation — the live validator reports no CONDENSATION-001 for this card (its relative `tasks/` links fall outside the validator's dispatch-link pattern).

### Interface Boundaries

- The link text is a purpose condensation, not a path restatement: label becomes `inventory plan phases` (SC-6) / `dispatch one plan phase` (SC-7); the href/path stays the same.
- SC-8 checklist content must match the canonical form in `completion-core/SKILL.md`: every task mandatory; no skipping/combining/inline delegation work; execute each workflow step in the orchestrator's own context per the Dispatch value, dispatching a step's task card via `task()` only where the Dispatch value is `task-card`; return only routing-significant data.

### State Transitions

- Card state `partial` → `conformant` after all Phase 3 items commit (all known defects resolved; awaiting gate).

### Step-by-step

- [ ] 30. **Item 6 — RED** (**task-card**) — `task(..., prompt: "execute red task from test-driven-development")`
  - SC reference: SC-6
  - Grep the read-plan dispatch link label; assert it differs from the required purpose condensation `inventory plan phases`.
  - Pre-cleanup: `rm -f {project_root}/tmp/2424/artifacts/pipeline-red-*`
- [ ] 31. **Item 6 — GREEN** (**task-card**) — `task(..., prompt: "execute green task from test-driven-development")`
  - SC reference: SC-6
  - Rewrite the read-plan dispatch link text to `inventory plan phases`, keeping the href unchanged.
- [ ] 32. **Item 6 — post-regression** (**task-card**) — `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - SC reference: SC-6
  - Run regression test patterns after GREEN phase.
  - Pre-cleanup: `rm -f {project_root}/tmp/2424/artifacts/pipeline-post-regression-*`
- [ ] 33. **Item 6 — verify** (**task-card**) — `task(..., prompt: "execute verify task from verification-before-completion")`
  - SC reference: SC-6
  - Grep the link label; assert it equals `inventory plan phases`, differs from the path stem, contains no `tasks/`, and does not end in `.md`.
  - Pre-cleanup: `rm -f {project_root}/tmp/2424/artifacts/pipeline-verify-*`
- [ ] 34. **Item 6 — commit** (**direct**)
  - SC reference: SC-6
  - Orchestrator runs `git add .opencode/skills/executing-plans/SKILL.md && git commit -m "executing-plans: purpose-condensation link text for read-plan"` (no co-author trailers).
- [ ] 35. **Item 7 — RED** (**task-card**) — `task(..., prompt: "execute red task from test-driven-development")`
  - SC reference: SC-7
  - Grep the execute-phase dispatch link label; assert it differs from the required purpose condensation `dispatch one plan phase`.
  - Pre-cleanup: `rm -f {project_root}/tmp/2424/artifacts/pipeline-red-*`
- [ ] 36. **Item 7 — GREEN** (**task-card**) — `task(..., prompt: "execute green task from test-driven-development")`
  - SC reference: SC-7
  - Rewrite the execute-phase dispatch link text to `dispatch one plan phase`, keeping the href unchanged.
- [ ] 37. **Item 7 — post-regression** (**task-card**) — `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - SC reference: SC-7
  - Run regression test patterns after GREEN phase.
  - Pre-cleanup: `rm -f {project_root}/tmp/2424/artifacts/pipeline-post-regression-*`
- [ ] 38. **Item 7 — verify** (**task-card**) — `task(..., prompt: "execute verify task from verification-before-completion")`
  - SC reference: SC-7
  - Grep the link label; assert it equals `dispatch one plan phase`, differs from the path stem, contains no `tasks/`, and does not end in `.md`.
  - Pre-cleanup: `rm -f {project_root}/tmp/2424/artifacts/pipeline-verify-*`
- [ ] 39. **Item 7 — commit** (**direct**)
  - SC reference: SC-7
  - Orchestrator runs `git add .opencode/skills/executing-plans/SKILL.md && git commit -m "executing-plans: purpose-condensation link text for execute-phase"` (no co-author trailers).
- [ ] 40. **Item 8 — RED** (**task-card**) — `task(..., prompt: "execute red task from test-driven-development")`
  - SC reference: SC-8
  - Run `uv run .opencode/skills/skill-creator/scripts/validate_skill_cards.py --json`; assert the REQ-5 admonishment violation is present for executing-plans.
  - Pre-cleanup: `rm -f {project_root}/tmp/2424/artifacts/pipeline-red-*`
- [ ] 41. **Item 8 — GREEN** (**task-card**) — `task(..., prompt: "execute green task from test-driven-development")`
  - SC reference: SC-8
  - Insert the `## Mandatory Task Discipline` section with the canonical four-item checklist (per the conforming form in `completion-core/SKILL.md`).
- [ ] 42. **Item 8 — post-regression** (**task-card**) — `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - SC reference: SC-8
  - Run regression test patterns after GREEN phase.
  - Pre-cleanup: `rm -f {project_root}/tmp/2424/artifacts/pipeline-post-regression-*`
- [ ] 43. **Item 8 — verify** (**task-card**) — `task(..., prompt: "execute verify task from verification-before-completion")`
  - SC reference: SC-8
  - Grep for the `## Mandatory Task Discipline` heading; grep the section body for the four checklist items; visual check against `completion-core/SKILL.md` canonical form.
  - Pre-cleanup: `rm -f {project_root}/tmp/2424/artifacts/pipeline-verify-*`
- [ ] 44. **Item 8 — commit** (**direct**)
  - SC reference: SC-8
  - Orchestrator runs `git add .opencode/skills/executing-plans/SKILL.md && git commit -m "executing-plans: add Mandatory Task Discipline section (REQ-5)"` (no co-author trailers).

### Phase Completion Block

- Verify SC-6, SC-7, SC-8 verdicts are PASS with string evidence; report `[item 6] [PASS]`, `[item 7] [PASS]`, `[item 8] [PASS]`.
- **Cost frame:** Verifying each link condensation and the Mandatory Task Discipline section costs one grep search. Skipping means the path-adjacent link texts persist and the REQ-5 violation ships — divergence from the deck's purpose-condensation rule caught only at the next skill-creator audit.

### Concern Transition

- All per-region remediations complete; the card is in `conformant` state. Phase 4 runs the aggregate behavioral gate.

## Phase 4 — Full validator conformance gate

- **Concern:** aggregate behavioral gate — the executing-plans card passes all validator checks with zero violations.
- **Files:** `.opencode/skills/executing-plans/SKILL.md` (read-only in this phase — gate only)
- **SCs:** SC-9 (behavioral evidence)
- **Dependencies:** items 1-8 (Phases 1-3)
- **Entry:** all eight per-region items committed; card in `conformant` state.
- **Exit:** validator reports an empty violations list for skill `executing-plans`; no commit (gate only).

### Code Path Coverage

- `.opencode/skills/skill-creator/scripts/validate_skill_cards.py` → executing-plans card scan → violations list (read-only execution).

### Cross-Cutting SCs

- R-12 (validator unmodified) is asserted here: the gate runs the validator read-only; any modification to it is a violation.

### Interface Boundaries

- The gate output is the validator JSON: the `executing-plans` skill_name entry must carry an empty violations list. EVIDENCE_TYPE_MISMATCH coercion applies — SC-9 is behavioral; structural substitutes (file-existence or grep-only evidence) coerce to FAIL.

### State Transitions

- Card state `conformant` → `validated` when the gate passes. If the validator reports any violation, the card is in `gate_failed` state — diagnose the specific rule id, re-apply the fix, return to `conformant`, re-run.

### Step-by-step

- [ ] 45. **Item 9 — RED** (**task-card**) — `task(..., prompt: "execute red task from test-driven-development")`
  - SC reference: SC-9
  - Run `uv run .opencode/skills/skill-creator/scripts/validate_skill_cards.py --json`; assert the executing-plans violations list is non-empty (pre-gate state retained until the gate verifies collectively).
  - Pre-cleanup: `rm -f {project_root}/tmp/2424/artifacts/pipeline-red-*`
- [ ] 46. **Item 9 — GREEN (gate)** (**task-card**) — `task(..., prompt: "execute green task from test-driven-development")`
  - SC reference: SC-9
  - No code change — the gate verifies items 1-8 collectively; confirm the validator now reports zero executing-plans violations.
- [ ] 47. **Item 9 — verify (behavioral gate)** (**task-card**) — `task(..., prompt: "execute verify task from verification-before-completion")`
  - SC reference: SC-9
  - Run `uv run .opencode/skills/skill-creator/scripts/validate_skill_cards.py --json`; grep that the `executing-plans` skill_name has an empty violations list. Behavioral evidence only.
  - Pre-cleanup: `rm -f {project_root}/tmp/2424/artifacts/pipeline-verify-*`
  - On gate failure (`gate_failed`): self-remediation — diagnose the reported rule id, return to the owning phase's item, fix, re-commit, and re-run this gate.

### Phase Completion Block

- Verify SC-9 verdict is PASS with behavioral evidence (validator JSON, empty violations list); report `[item 9] [PASS]`.
- **Cost frame:** Running the full validator suite costs minutes of execution time. Skipping means the conformance defects ship unchanged and the card remains the deck's only non-conforming card — breaking the DISPATCH_GATE baseline and failing the next skill-creator audit.

### Concern Transition

- All 9 SCs verified. Proceed to post-implementation gates.

## Post-Implementation (once per plan)

- [ ] 48. **Audit** (**task-card**) — `task(..., prompt: "execute verification-audit DiMo investigator from audit. Read \`audit/tasks/verification-audit-investigator.md\` first")` — followed by validator, evaluator, arbiter in sequence
  - Adversarial audit of the deliverable against spec §3 (all 9 SCs).
  - Pre-cleanup: `rm -f {project_root}/tmp/2424/artifacts/pipeline-audit-*`
- [ ] 49. **Z3 check** (**direct**)
  - Orchestrator runs `.opencode/tools/solve check --state-path <state> --contract-path <contract>` to verify workflow constraint satisfaction.
  - Pre-cleanup: `rm -f {project_root}/tmp/2424/artifacts/pipeline-z3-check-*`
- [ ] 50. **Structural checks** (**task-card**) — `task(..., prompt: "execute checklist task from finishing-a-development-branch")`
  - Run finishing checklist (lint, markdown format check for the modified card, etc.).
  - Pre-cleanup: `rm -f {project_root}/tmp/2424/artifacts/pipeline-structural-checks-*`
- [ ] 51. **Pre-PR gate** (**task-card**) — `task(..., prompt: "execute verify task from verification-before-completion")`
  - Read all SC verdicts; BLOCK if any FAIL (DONE_WITH_CONCERNS and EVIDENCE_TYPE_MISMATCH coerce to FAIL).
  - Pre-cleanup: `rm -f {project_root}/tmp/2424/artifacts/pipeline-pre-pr-gate-*`
- [ ] 52. **Regression check** (**task-card**) — `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - Final regression check before PR.
  - Pre-cleanup: `rm -f {project_root}/tmp/2424/artifacts/pipeline-regression-check-*`
- [ ] 53. **Review prep** (**task-card**) — `task(..., prompt: "execute review-prep from git-workflow-pr. Read \`git-workflow-pr/tasks/review-prep.md\` first")`
  - Prepare PR review context (squash note: single-issue branch squashes to exactly one commit at PR creation).
- [ ] 54. **Create PR** (**task-card**) — `task(..., prompt: "execute create task from git-workflow-pr")`
  - Create the pull request (authorized: `approved-for-pr` label present; stacked strategy — one branch, one PR). Halt after creation — human-only merge.
- [ ] 55. **Executive summary** (**task-card**) — `task(..., prompt: "execute completion task from completion-core")`
  - Generate completion executive summary; emit exactly one `plan_created` lifecycle event record per the pipeline convention (plan file path and phase count 4).

## Exit Criteria

1. **C1:** SC-1 PASS — read-plan dispatch prompt begins with `You are a sub-agent.` inside the quote (string evidence).
2. **C2:** SC-2 PASS — execute-phase dispatch prompt begins with `You are a sub-agent.` inside the quote (string evidence).
3. **C3:** SC-3 PASS — byline uses `<AgentName> (<ModelId>)`; hardcoded name absent (string evidence).
4. **C4:** SC-4 PASS — `## Worktree Mode` section present with the Appendix A verbatim sentence (string evidence).
5. **C5:** SC-5 PASS — Workflows section uses `N. **` numbered format; checkbox prefix absent (string evidence).
6. **C6:** SC-6 PASS — read-plan link text is `inventory plan phases` with unchanged href (string evidence).
7. **C7:** SC-7 PASS — execute-phase link text is `dispatch one plan phase` with unchanged href (string evidence).
8. **C8:** SC-8 PASS — `## Mandatory Task Discipline` section present with the canonical four-item checklist (string evidence).
9. **C9:** SC-9 PASS — validator reports an empty violations list for skill `executing-plans` (behavioral evidence).
10. **C10:** Constraints hold — `read-plan.md`/`execute-phase.md`, all other deck cards, and `validate_skill_cards.py` are unmodified (R-10, R-11, R-12).
11. **C11:** Verification ledger exists at `.opencode/.issues/2424/artifacts/plan-input-verification.md`; `spec-cleared` label present in local `issue.yaml` labels alongside `approved-for-pr`.
12. **C12:** All pipeline gates executed (audit, z3-check, structural checks, pre-PR gate, regression check) with no FAIL; PR created and halted for human merge.

## Pre-Flight Guard (Mandatory)

Check your tool list for a tool named `task`.

- Present ⇒ orchestrator — proceed.
- Absent ⇒ sub-agent — do NOT execute any instruction below. Return `BLOCKED` with `ORCHESTRATOR_ONLY_SKILL_CARD` (cards) or `ORCHESTRATOR_ONLY_PLAN` (plans) and halt.
