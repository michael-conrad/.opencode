---
plan_schema_version: "1.0"
issue: 2296
title: "Semantic dispatch link text as purpose-statement condensation"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 7
dispatch:
  - test-driven-development
  - verification-before-completion
  - audit
  - finishing-a-development-branch
  - git-workflow-pr
  - completion-core
---

# Implementation Plan — #2296 — Semantic Dispatch Link Text as Purpose-Statement Condensation

**Issue:** [https://github.com/michael-conrad/.opencode/issues/2296](https://github.com/michael-conrad/.opencode/issues/2296)

**Goal:** Replace every dead-weight dispatch link `[text]` (path restatement) across the skill deck with a semantic condensation of the linked task card's Purpose statement, and lock the condensation source/format contracts plus a structural validation gate so future cards inherit the correct pattern.

**Architecture:** Seven-phase, one-concern-per-phase decomposition, one SC per phase. Phases 1–4 rewrite/convert the 48 affected SKILL.md files (SC-1 dispatch anchor semantics, SC-2 purpose quality, SC-3 legacy-format conversion, SC-4 audit placeholder templating). Phases 5–6 lock the normative contracts (SC-6 purpose-as-dispatch-anchor source in `task-card-structure-standards.md`, SC-7 locked condensation dispatch template in `skill-card-description-standards.md`). Phase 7 (SC-5) adds the structural condensation-format validation gate in skill-creator, sequenced after its dependencies (SC-1 format, SC-6/SC-7 normative source). Enforcement is structural (validation gate), not behavioral — per spec Notes.

**Files:**
- `.opencode/skills/*/SKILL.md` (48 files — dispatch link `[text]` values)
- `.opencode/skills/*/tasks/*.md` (Purpose sections of flagged task cards)
- `.opencode/skills/playwright-cli/SKILL.md`
- `.opencode/skills/completion-core/SKILL.md`
- `.opencode/skills/audit/SKILL.md`
- `.opencode/skills/skill-creator/SKILL.md`
- `.opencode/skills/skill-creator/scripts/validate_skill_cards.py`
- `.opencode/skills/skill-creator/tasks/validate.md`
- `.opencode/reference/task-card-structure-standards.md`
- `.opencode/reference/skill-card-description-standards.md`

**Dispatch:** `test-driven-development`, `verification-before-completion`, `audit`, `finishing-a-development-branch`, `git-workflow-pr`, `completion-core`

---

## Blast Radius

- **Phase 1 — Dispatch anchor semantics (SC-1):** Wide but shallow — touches all 48 SKILL.md files; each edit is a localized `[text]` swap with the URL unchanged. URL paths unchanged so routing still resolves. No enforcement test asserts path-restatement `[text]` (verified via research-card scan; condensation is not behaviorally asserted).
- **Phase 2 — Purpose statement quality (SC-2):** Limited to flagged task-card Purpose sections; corrections preserve task semantics.
- **Phase 3 — Dispatch format structure (SC-3):** Isolated to playwright-cli and completion-core; internal skill-card structure conversion, dispatch contracts preserved.
- **Phase 4 — Placeholder template semantics (SC-4):** Isolated to the audit skill's 4 placeholder dispatch links.
- **Phase 5 — Purpose-as-dispatch-anchor source (SC-6):** Documentation only — `task-card-structure-standards.md` §4.
- **Phase 6 — Locked condensation dispatch template (SC-7):** Documentation only — `skill-card-description-standards.md`.
- **Phase 7 — Condensation-format validation gate (SC-5):** skill-creator validation tooling only — no effect on dispatch behavior.

---

> **Compliance:** All SCs must pass before completion. Partial implementation is not permitted. Each item is daisy-chained — item N's commit is precondition for item N+1's RED.

> **One step at a time.** Execute exactly one step. Report progress. Wait for instruction before the next step.

> **Step status:** Report `[item N] [PASS|FAIL]` after each step. If FAIL, report blocker and halt.

> **Enforcement gate:** All SCs must pass before this plan is complete.

> **Self-Remediation Protocol:** If a step FAILs: diagnose root cause, fix the deliverable, re-verify. If the fix requires spec revision, update the spec and re-enter the plan. Escalate only after remediation failure.

---

## Pre-Implementation Steps

- [ ] 1. **Coherence gate (**inline**).** Verify the spec's SCs, the structure artifact's items, and the dependency contract are mutually consistent: every SC maps to exactly one item, every item's RED/GREEN/verify/commit steps are in the same phase, and the phase DAG is acyclic (phase_1 → phase_2 → phase_3 → phase_4 → phase_5 → phase_6 → phase_7, with phase_7 additionally depending on phase_1). If any inconsistency is found, HALT and report before proceeding.
- [ ] 2. **Baseline check (**inline**).** Verify the working tree is clean, the feature branch exists, and the affected files (48 SKILL.md files, playwright-cli, completion-core, audit, skill-creator, the two reference docs) are present and at their expected paths. Confirm the current dispatch link `[text]` values are path-restatements (the RED precondition). If the baseline is not met, HALT and report.

---

## Phase Table

| Phase | Skill | Task | Target | SCs | Depends On |
|-------|-------|------|--------|-----|------------|
| 1 — Dispatch anchor semantics | `test-driven-development`, `verification-before-completion` | `red`, `green`, `verify` | 48 SKILL.md files dispatch link `[text]` | SC-1 | — |
| 2 — Purpose statement quality | `test-driven-development`, `verification-before-completion` | `red`, `green`, `verify` | flagged task-card Purpose sections | SC-2 | 1 |
| 3 — Dispatch format structure | `test-driven-development`, `verification-before-completion` | `red`, `green`, `verify` | playwright-cli/SKILL.md, completion-core/SKILL.md | SC-3 | — |
| 4 — Placeholder template semantics | `test-driven-development`, `verification-before-completion` | `red`, `green`, `verify` | audit/SKILL.md | SC-4 | — |
| 5 — Purpose-as-dispatch-anchor source | `test-driven-development`, `verification-before-completion` | `red`, `green`, `verify` | reference/task-card-structure-standards.md §4 | SC-6 | — |
| 6 — Locked condensation dispatch template | `test-driven-development`, `verification-before-completion` | `red`, `green`, `verify` | reference/skill-card-description-standards.md | SC-7 | — |
| 7 — Condensation-format validation gate | `test-driven-development`, `verification-before-completion` | `red`, `green`, `verify` | skill-creator/SKILL.md, scripts/validate_skill_cards.py, tasks/validate.md | SC-5 | 1, 5, 6 |

---

## Phase Details

### Phase 1 — Dispatch anchor semantics

| Field | Value |
|-------|-------|
| Skill | `test-driven-development`, `verification-before-completion` |
| Task | `red`, `green`, `verify` |
| Target | 48 SKILL.md files dispatch link `[text]` |
| SCs | SC-1 |
| Depends On | — |

**Context:**
```yaml
sc_ids: [SC-1]
rewrite_target: "dispatch link [text] values across 48 SKILL.md files"
condensation_source: "linked task card Purpose statement"
url_preservation: "URL stays the task path; only [text] changes"
```

**Procedure (SC-1 — dispatch link `[text]` condensation):**
- [ ] 3. **RED (**sub-agent**).** Write a failing structural condensation-format check asserting that dispatch link `[text]` values across the 48 SKILL.md files are path-restatements (not condensations). **→ SC-1**
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`
  - Context: SC-1, 48 SKILL.md files, current `[text]` = path-restatement
- [ ] 4. **GREEN (**sub-agent**).** Rewrite every dispatch link `[text]` across the 48 affected SKILL.md files as a condensation of the linked task card's Purpose statement; the URL remains the path. **→ SC-1**
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`
  - Context: SC-1, condensation source = task card Purpose, URL preserved
- [ ] 5. **post-regression (**sub-agent**).** Run regression test patterns after the GREEN phase to confirm no dispatch behavior regressed. **→ SC-1**
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - Context: SC-1, post-GREEN regression
- [ ] 6. **verify (**sub-agent**).** Run the structural condensation-format check against the purpose source; review the manifest diff to confirm every `[text]` is a condensation and the URL is unchanged. **→ SC-1**
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - Context: SC-1, condensation-format check, manifest diff review
- [ ] 7. **commit-inline (**inline**).** Stage and commit the 48 SKILL.md files with rewritten dispatch link `[text]` values. **→ SC-1**
  - Command: `git add <48 SKILL.md files> && git commit -m "<message>"`

**Phase 1 VbC:**
- [ ] 8. **VbC (**clean-room**).** Verify SC-1 passes its structural check: all 255 `[text]` values are purpose condensations with URL unchanged. **→ SC-1**

### Phase 2 — Purpose statement quality

| Field | Value |
|-------|-------|
| Skill | `test-driven-development`, `verification-before-completion` |
| Task | `red`, `green`, `verify` |
| Target | flagged task-card Purpose sections |
| SCs | SC-2 |
| Depends On | 1 |

**Context:**
```yaml
sc_ids: [SC-2]
audit_criteria: "condensable, outcome-as-subject, distinctive from siblings"
flagged_purposes: "purposes flagged by SC-1 rewrite as non-condensable"
```

**Procedure (SC-2 — purpose-statement correction):**
- [ ] 9. **RED (**sub-agent**).** Write a failing structural audit asserting that purpose statements failing the audit criteria (not condensable, not outcome-as-subject, not distinctive from siblings) are identified. **→ SC-2**
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`
  - Context: SC-2, audit criteria, flagged purposes from SC-1 rewrite
- [ ] 10. **GREEN (**sub-agent**).** Correct the flagged purpose statements in the affected task cards so they are condensable, outcome-as-subject, and distinctive from siblings. **→ SC-2**
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`
  - Context: SC-2, corrected purposes, intent preservation
- [ ] 11. **post-regression (**sub-agent**).** Run regression test patterns after the GREEN phase to confirm purpose corrections did not alter task semantics. **→ SC-2**
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - Context: SC-2, post-GREEN regression
- [ ] 12. **verify (**sub-agent**).** Run the structural audit of corrected purpose statements; re-run the SC-1 condensation check on corrected purposes. **→ SC-2**
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - Context: SC-2, condensability/outcome-subject/distinctiveness audit, SC-1 re-check
- [ ] 13. **commit-inline (**inline**).** Stage and commit the corrected Purpose sections in the affected task cards. **→ SC-2**
  - Command: `git add <task cards> && git commit -m "<message>"`

**Phase 2 VbC:**
- [ ] 14. **VbC (**clean-room**).** Verify SC-2 passes its structural audit: corrected purposes are condensable, outcome-as-subject, and distinctive from siblings. **→ SC-2**

### Phase 3 — Dispatch format structure

| Field | Value |
|-------|-------|
| Skill | `test-driven-development`, `verification-before-completion` |
| Task | `red`, `green`, `verify` |
| Target | playwright-cli/SKILL.md, completion-core/SKILL.md |
| SCs | SC-3 |
| Depends On | — |

**Context:**
```yaml
sc_ids: [SC-3]
legacy_format_skills: [playwright-cli, completion-core]
canonical_format: "numbered-checkbox list with sub-bullet dispatch contracts (Prompt, Context, Returns, Execution mode)"
```

**Procedure (SC-3 — legacy-format conversion):**
- [ ] 15. **RED (**sub-agent**).** Write a failing structural format check asserting that playwright-cli and completion-core use the legacy table dispatch format. **→ SC-3**
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`
  - Context: SC-3, playwright-cli, completion-core, legacy table format
- [ ] 16. **GREEN (**sub-agent**).** Convert both skills to the canonical numbered-checkbox list with sub-bullet dispatch contracts (Prompt, Context, Returns, Execution mode). **→ SC-3**
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`
  - Context: SC-3, canonical checklist format, dispatch contracts preserved
- [ ] 17. **post-regression (**sub-agent**).** Run regression test patterns after the GREEN phase to confirm the conversion preserved dispatch contracts. **→ SC-3**
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - Context: SC-3, post-GREEN regression
- [ ] 18. **verify (**sub-agent**).** Run the structural format check against the canonical Workflows template; confirm no legacy Trigger Dispatch Table / Invocation sections remain. **→ SC-3**
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - Context: SC-3, canonical format check
- [ ] 19. **commit-inline (**inline**).** Stage and commit playwright-cli/SKILL.md and completion-core/SKILL.md converted to canonical format. **→ SC-3**
  - Command: `git add playwright-cli/SKILL.md completion-core/SKILL.md && git commit -m "<message>"`

**Phase 3 VbC:**
- [ ] 20. **VbC (**clean-room**).** Verify SC-3 passes its structural format check: playwright-cli and completion-core use the canonical checklist, no legacy Trigger Dispatch Table / Invocation sections remain. **→ SC-3**

### Phase 4 — Placeholder template semantics

| Field | Value |
|-------|-------|
| Skill | `test-driven-development`, `verification-before-completion` |
| Task | `red`, `green`, `verify` |
| Target | audit/SKILL.md |
| SCs | SC-4 |
| Depends On | — |

**Context:**
```yaml
sc_ids: [SC-4]
audit_placeholder_links: "4 DiMo role links (investigator/validator/evaluator/arbiter)"
semantic_template: "[<audit-type>] semantic template, URL path template unchanged"
```

**Procedure (SC-4 — audit placeholder-link templating):**
- [ ] 21. **RED (**sub-agent**).** Write a failing structural check asserting that the audit skill's 4 placeholder dispatch links use path templates in `[text]`. **→ SC-4**
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`
  - Context: SC-4, audit skill, 4 placeholder links, path templates
- [ ] 22. **GREEN (**sub-agent**).** Rewrite the 4 audit/SKILL.md placeholder dispatch links from path templates to semantic templates (e.g., `[investigate <audit-type>]`); the URL path template is unchanged. **→ SC-4**
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`
  - Context: SC-4, semantic templates, DiMo role distinctiveness, URL path template unchanged
- [ ] 23. **post-regression (**sub-agent**).** Run regression test patterns after the GREEN phase to confirm the audit dispatch links still resolve. **→ SC-4**
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - Context: SC-4, post-GREEN regression
- [ ] 24. **verify (**sub-agent**).** Run the structural check that `[text]` no longer restates the path and the 4 DiMo roles remain distinguishable. **→ SC-4**
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - Context: SC-4, semantic-template check, role distinctiveness
- [ ] 25. **commit-inline (**inline**).** Stage and commit audit/SKILL.md with semantic-template dispatch links. **→ SC-4**
  - Command: `git add audit/SKILL.md && git commit -m "<message>"`

**Phase 4 VbC:**
- [ ] 26. **VbC (**clean-room**).** Verify SC-4 passes its structural check: the 4 audit placeholder links use semantic templates and the DiMo roles remain distinguishable. **→ SC-4**

### Phase 5 — Purpose-as-dispatch-anchor source

| Field | Value |
|-------|-------|
| Skill | `test-driven-development`, `verification-before-completion` |
| Task | `red`, `green`, `verify` |
| Target | reference/task-card-structure-standards.md §4 |
| SCs | SC-6 |
| Depends On | — |

**Context:**
```yaml
sc_ids: [SC-6]
condensation_source_contract: "purpose statement as dispatch-anchor source (condensable, outcome-as-subject, distinctive)"
target_section: "reference/task-card-structure-standards.md §4"
```

**Procedure (SC-6 — purpose-as-dispatch-anchor source):**
- [ ] 27. **RED (**sub-agent**).** Write a failing structural doc review asserting that `reference/task-card-structure-standards.md` §4 lacks purpose-as-dispatch-anchor-source normative language. **→ SC-6**
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`
  - Context: SC-6, task-card-structure-standards.md §4, no purpose-source spec
- [ ] 28. **GREEN (**sub-agent**).** Add to `reference/task-card-structure-standards.md` §4 the normative spec that the purpose statement is the dispatch-anchor source (condensable, outcome-as-subject, distinctive). **→ SC-6**
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`
  - Context: SC-6, purpose-as-dispatch-anchor-source, condensable/outcome-subject/distinctive
- [ ] 29. **post-regression (**sub-agent**).** Run regression test patterns after the GREEN phase to confirm the §4 update is internally consistent. **→ SC-6**
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - Context: SC-6, post-GREEN regression
- [ ] 30. **verify (**sub-agent**).** Run the structural doc review; cross-reference check with the SC-7 template for consistency. **→ SC-6**
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - Context: SC-6, §4 purpose-source spec, SC-7 template consistency
- [ ] 31. **commit-inline (**inline**).** Stage and commit `reference/task-card-structure-standards.md`. **→ SC-6**
  - Command: `git add reference/task-card-structure-standards.md && git commit -m "<message>"`

**Phase 5 VbC:**
- [ ] 32. **VbC (**clean-room**).** Verify SC-6 passes its structural doc review: §4 specifies the purpose statement as the dispatch-anchor source, consistent with the SC-7 template. **→ SC-6**

### Phase 6 — Locked condensation dispatch template

| Field | Value |
|-------|-------|
| Skill | `test-driven-development`, `verification-before-completion` |
| Task | `red`, `green`, `verify` |
| Target | reference/skill-card-description-standards.md |
| SCs | SC-7 |
| Depends On | — |

**Context:**
```yaml
sc_ids: [SC-7]
locked_template: "You are a sub-agent. Follow the instructions in [<condensation>](<path>). <context-fields>"
target_doc: "reference/skill-card-description-standards.md"
```

**Procedure (SC-7 — locked condensation dispatch template):**
- [ ] 33. **RED (**sub-agent**).** Write a failing structural doc review asserting that the base prompt format in `reference/skill-card-description-standards.md` lacks the locked condensation dispatch template. **→ SC-7**
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`
  - Context: SC-7, skill-card-description-standards.md, no locked template
- [ ] 34. **GREEN (**sub-agent**).** Add to `reference/skill-card-description-standards.md` the locked dispatch template: `You are a sub-agent. Follow the instructions in [<condensation>](<path>). <context-fields>`. **→ SC-7**
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`
  - Context: SC-7, locked condensation dispatch template
- [ ] 35. **post-regression (**sub-agent**).** Run regression test patterns after the GREEN phase to confirm the template update is internally consistent. **→ SC-7**
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - Context: SC-7, post-GREEN regression
- [ ] 36. **verify (**sub-agent**).** Run the structural doc review; cross-reference check with the SC-6 purpose-source spec for consistency. **→ SC-7**
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - Context: SC-7, locked template present, SC-6 consistency
- [ ] 37. **commit-inline (**inline**).** Stage and commit `reference/skill-card-description-standards.md`. **→ SC-7**
  - Command: `git add reference/skill-card-description-standards.md && git commit -m "<message>"`

**Phase 6 VbC:**
- [ ] 38. **VbC (**clean-room**).** Verify SC-7 passes its structural doc review: the locked condensation dispatch template is present and consistent with the SC-6 purpose-source spec. **→ SC-7**

### Phase 7 — Condensation-format validation gate

| Field | Value |
|-------|-------|
| Skill | `test-driven-development`, `verification-before-completion` |
| Task | `red`, `green`, `verify` |
| Target | skill-creator/SKILL.md, scripts/validate_skill_cards.py, tasks/validate.md |
| SCs | SC-5 |
| Depends On | 1, 5, 6 |

**Context:**
```yaml
sc_ids: [SC-5]
condensation_source_contract: "purpose statement as dispatch-anchor source (condensable, outcome-as-subject, distinctive)"
locked_template: "You are a sub-agent. Follow the instructions in [<condensation>](<path>). <context-fields>"
validation_gate: "structural condensation-format check in validate_skill_cards.py, not behavioral"
```

**Procedure (SC-5 — condensation-format validation gate):**
- [ ] 39. **RED (**sub-agent**).** Write a failing unit test asserting that no condensation-format check exists in validate_skill_cards.py. **→ SC-5**
  - Dispatch: `task(..., prompt: "execute red task from test-driven-development")`
  - Context: SC-5, validate_skill_cards.py, no condensation check present
- [ ] 40. **GREEN (**sub-agent**).** Add the normative condensation-anchor rule to skill-creator and a structural condensation-format validation check in validate_skill_cards.py and/or the validate.md workflow. **→ SC-5**
  - Dispatch: `task(..., prompt: "execute green task from test-driven-development")`
  - Context: SC-5, normative rule, structural condensation-format check, gate on card create/edit
- [ ] 41. **post-regression (**sub-agent**).** Run regression test patterns after the GREEN phase to confirm the new gate does not break existing validation output. **→ SC-5**
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - Context: SC-5, post-GREEN regression
- [ ] 42. **verify (**sub-agent**).** Run validate_skill_cards.py against a sample of rewritten cards; gate PASS on compliant cards, FAIL on path-restatement. **→ SC-5**
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - Context: SC-5, positive case (condensation passes), negative case (path-restatement FAILs)
- [ ] 43. **commit-inline (**inline**).** Stage and commit skill-creator/SKILL.md, scripts/validate_skill_cards.py, and tasks/validate.md. **→ SC-5**
  - Command: `git add skill-creator/SKILL.md scripts/validate_skill_cards.py tasks/validate.md && git commit -m "<message>"`

**Phase 7 VbC:**
- [ ] 44. **VbC (**clean-room**).** Verify SC-5 passes its structural check: the condensation-format gate is active and unit-tested (positive/negative). **→ SC-5**

**Post-Implementation Steps:**
- [ ] 45. **audit (**sub-agent**).** Run the adversarial audit of the deliverable via the DiMo 4-role chain (investigator, validator, evaluator, arbiter). **→ all SCs**
  - Dispatch: `task(..., prompt: "execute verification-audit DiMo investigator from audit. Read \`audit/tasks/verification-audit-investigator.md\` first")` — followed by validator, evaluator, arbiter in sequence
  - Context: all SC verdicts, evidence artifacts
- [ ] 46. **z3-check (**inline**).** Run the Z3 constraint solver verification against the dependency contract. **→ all SCs**
  - Command: `.opencode/tools/solve check --state-path ... --contract-path ...`
  - Context: dependency contract, phase DAG
- [ ] 47. **structural-checks (**sub-agent**).** Run the finishing checklist (lint, typecheck, etc.). **→ all SCs**
  - Dispatch: `task(..., prompt: "execute checklist task from finishing-a-development-branch")`
  - Context: all modified files
- [ ] 48. **pre-pr-gate (**sub-agent**).** Verify all SC verdicts; BLOCK if any FAIL. **→ all SCs**
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - Context: all SC verdicts
- [ ] 49. **regression-check (**sub-agent**).** Run the final regression check before PR. **→ all SCs**
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - Context: all SCs, final regression
- [ ] 50. **review-prep (**sub-agent**).** Prepare the PR review context. **→ all SCs**
  - Dispatch: `task(..., prompt: "execute review-prep from git-workflow-pr. Read \`git-workflow-pr/tasks/review-prep.md\` first")`
  - Context: all SCs, PR scope
- [ ] 51. **create-pr (**sub-agent**).** Create the pull request. **→ all SCs**
  - Dispatch: `task(..., prompt: "execute create task from git-workflow-pr")`
  - Context: all SCs, PR scope
- [ ] 52. **exec-summary (**sub-agent**).** Generate the completion executive summary. **→ all SCs**
  - Dispatch: `task(..., prompt: "execute completion task from completion-core")`
  - Context: all SCs, PR status

---

## Exit Criteria

- [ ] C1. All 255 dispatch link `[text]` values across the 48 affected SKILL.md files are purpose-statement condensations; the URL remains the path (SC-1).
- [ ] C2. Purpose statements failing the audit criteria are corrected, each as a separate atomic work unit (SC-2).
- [ ] C3. playwright-cli and completion-core use the canonical numbered-checkbox sub-bullets format, no legacy Trigger Dispatch Table / Invocation sections (SC-3).
- [ ] C4. The audit skill's 4 placeholder dispatch links use semantic templates; URL path template unchanged (SC-4).
- [ ] C5. skill-creator carries the normative condensation-anchor rule and a structural condensation-format validation gate on card create/edit (SC-5).
- [ ] C6. `reference/task-card-structure-standards.md` §4 specifies the purpose statement as the dispatch-anchor source (SC-6).
- [ ] C7. `reference/skill-card-description-standards.md` specifies the locked condensation dispatch template, consistent with SC-6 (SC-7).
- [ ] C8. All SCs pass the verification gate; the plan is complete with no partial implementation.

---

## Lifecycle Events

| Timestamp | Event | Details |
|-----------|-------|---------|
| 2026-08-18T14:54:22Z | `plan_created` | Plan file: `.opencode/.issues/2296/plan.md`, phase count: 7 |

---

*Co-authored with AI: OpenCode (deepseek-v4-flash)*
