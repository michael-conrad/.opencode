---
plan_schema_version: "1.0"
issue: 2296
title: "Semantic dispatch link text as purpose-statement condensation"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 2
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

**Architecture:** Two-phase, per-SC atomic decomposition. Phase 1 rewrites/converts the 48 affected SKILL.md files (SC-1, SC-2, SC-3, SC-4) — link `[text]` becomes a purpose condensation, URL stays the path; purpose statements failing the audit are corrected; the two legacy-format skills convert to canonical checklist; the audit skill's placeholder links become semantic templates. Phase 2 (SC-5, SC-6, SC-7) locks the normative contracts: purpose-as-dispatch-anchor source in `task-card-structure-standards.md`, the locked condensation dispatch template in `skill-card-description-standards.md`, and a structural condensation-format validation gate in skill-creator. Enforcement is structural (validation gate), not behavioral — per spec Notes.

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

- **Phase 1 — Per-file rewrites/conversions:** Wide but shallow — touches all 48 SKILL.md files; each edit is a localized `[text]` swap with the URL unchanged. URL paths unchanged so routing still resolves. No enforcement test asserts path-restatement `[text]` (verified via research-card scan; condensation is not behaviorally asserted). Purpose corrections are limited to flagged task cards. playwright-cli/completion-core and audit conversions are isolated to their respective skills.
- **Phase 2 — Post-rewrite normative/enforcement:** skill-creator validation tooling only — no effect on dispatch behavior. The two reference-doc updates establish the condensation source and format contracts.

---

> **Compliance:** All SCs must pass before completion. Partial implementation is not permitted. Each item is daisy-chained — item N's commit is precondition for item N+1's RED.

> **One step at a time.** Execute exactly one step. Report progress. Wait for instruction before the next step.

> **Step status:** Report `[item N] [PASS|FAIL]` after each step. If FAIL, report blocker and halt.

> **Enforcement gate:** All SCs must pass before this plan is complete.

> **Self-Remediation Protocol:** If a step FAILs: diagnose root cause, fix the deliverable, re-verify. If the fix requires spec revision, update the spec and re-enter the plan. Escalate only after remediation failure.

---

## Pre-Implementation Steps

- [ ] 1. **Coherence gate (**inline**).** Verify the spec's SCs, the structure artifact's items, and the dependency contract are mutually consistent: every SC maps to exactly one item, every item's RED/GREEN/verify/commit steps are in the same phase, and the phase DAG is acyclic (phase_2_per_file → phase_3_post). If any inconsistency is found, HALT and report before proceeding.
- [ ] 2. **Baseline check (**inline**).** Verify the working tree is clean, the feature branch exists, and the affected files (48 SKILL.md files, playwright-cli, completion-core, audit, skill-creator, the two reference docs) are present and at their expected paths. Confirm the current dispatch link `[text]` values are path-restatements (the RED precondition). If the baseline is not met, HALT and report.

---

## Phase Table

| Phase | Concern | SCs | Depends On | Step Range | Dispatch |
|-------|---------|-----|------------|------------|----------|
| 1 — Per-file rewrites/conversions | Rewrite dispatch link `[text]` as purpose condensations; correct failing purposes; convert legacy-format skills; convert audit placeholder links | SC-1, SC-2, SC-3, SC-4 | — | 3–18 | `test-driven-development`, `verification-before-completion` |
| 2 — Post-rewrite normative/enforcement | Lock condensation source/format contracts and add structural validation gate | SC-5, SC-6, SC-7 | 1 | 19–30 | `test-driven-development`, `verification-before-completion` |

---

## Phase Details

### Phase 1 — Per-file rewrites/conversions

| Field | Value |
|-------|-------|
| Skill | `test-driven-development`, `verification-before-completion` |
| Task | `red`, `green`, `verify` |
| Target | 48 SKILL.md files, flagged task-card Purpose sections, playwright-cli/SKILL.md, completion-core/SKILL.md, audit/SKILL.md |
| SCs | SC-1, SC-2, SC-3, SC-4 |
| Depends On | — |

**Context:**
```yaml
sc_ids: [SC-1, SC-2, SC-3, SC-4]
rewrite_target: "dispatch link [text] values across 48 SKILL.md files"
condensation_source: "linked task card Purpose statement"
url_preservation: "URL stays the task path; only [text] changes"
legacy_format_skills: [playwright-cli, completion-core]
audit_placeholder_links: "4 DiMo role links (investigator/validator/evaluator/arbiter)"
```

### Phase 2 — Post-rewrite normative/enforcement

| Field | Value |
|-------|-------|
| Skill | `test-driven-development`, `verification-before-completion` |
| Task | `red`, `green`, `verify` |
| Target | skill-creator/SKILL.md, scripts/validate_skill_cards.py, tasks/validate.md, reference/task-card-structure-standards.md, reference/skill-card-description-standards.md |
| SCs | SC-5, SC-6, SC-7 |
| Depends On | 1 |

**Context:**
```yaml
sc_ids: [SC-5, SC-6, SC-7]
condensation_source_contract: "purpose statement as dispatch-anchor source (condensable, outcome-as-subject, distinctive)"
locked_template: "You are a sub-agent. Follow the instructions in [<condensation>](<path>). <context-fields>"
validation_gate: "structural condensation-format check in validate_skill_cards.py, not behavioral"
```

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

*Co-authored with AI: OpenCode (deepseek-v4-flash)*
