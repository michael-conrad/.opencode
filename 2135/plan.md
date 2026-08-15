---
plan_schema_version: "1.0"
issue: 2135
title: "Rewrite 130-authority-source.md — spec authoritative for intent, code authoritative for state"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 5
dispatch:
  - phase: 1
    skill: test-driven-development
    tasks: [red, green, verify]
  - phase: 2
    skill: test-driven-development
    tasks: [red, green, verify]
  - phase: 3
    skill: test-driven-development
    tasks: [red, green, verify]
  - phase: 4
    skill: test-driven-development
    tasks: [red, green, verify]
  - phase: 5
    skill: test-driven-development
    tasks: [red, green, verify]
---

# Implementation Plan — #2135 — Rewrite 130-authority-source.md

**Issue:** [Rewrite 130-authority-source.md — spec authoritative for intent, code authoritative for state](https://github.com/michael-conrad/.opencode/issues/2135)

**Goal:** Rewrite `130-authority-source.md` to establish a dual-authority model (spec authoritative for intent, code authoritative for current state) and relocate three superseded sections to their target files without content loss.

**Architecture:** The rewrite is decomposed into five sequential phases. Phase 1 writes the dual-authority principle. Phase 2 writes the six rules that build on it. Phase 3 removes the three superseded sections and relocates their content to the target files. Phase 4 verifies no mechanical compaction artifacts exist in the final guideline. Phase 5 runs a clean-room semantic-preservation audit across the relocation boundaries. Each phase is a RED/GREEN/verify/commit daisy chain per item, with verification performed by clean-room sub-agents using content checklists (semantic evidence), not grep-only.

**Files:**
- `.opencode/guidelines/130-authority-source.md` — rewritten (principle, rules, superseded sections removed)
- `.opencode/skills/spec-creation/SKILL.md` — receives Superseding Issues + Overlap Detection Checklist + Plan Audit Code Deep Dive
- `.opencode/guidelines/065-verification-honesty.md` — receives Verification First content

---

## Phase Table

| Phase | Skill | Task | Target | SCs | Depends On |
|-------|-------|------|--------|-----|------------|
| 1 — Dual-authority principle | `test-driven-development` | `red`, `green`, `verify` | `.opencode/guidelines/130-authority-source.md` | SC-1 | — |
| 2 — Six rules | `test-driven-development` | `red`, `green`, `verify` | `.opencode/guidelines/130-authority-source.md` | SC-2, SC-3, SC-4, SC-5, SC-6, SC-7 | 1 |
| 3 — Relocate superseded sections | `test-driven-development` | `red`, `green`, `verify` | `.opencode/guidelines/130-authority-source.md`, `.opencode/skills/spec-creation/SKILL.md`, `.opencode/guidelines/065-verification-honesty.md` | SC-8a, SC-8b, SC-9a, SC-9b, SC-10a, SC-10b | 2 |
| 4 — No mechanical compaction | `test-driven-development` | `red`, `green`, `verify` | `.opencode/guidelines/130-authority-source.md` | SC-12 | 3 |
| 5 — Clean-room semantic audit | `test-driven-development` | `red`, `green`, `verify` | `.opencode/skills/spec-creation/SKILL.md`, `.opencode/guidelines/065-verification-honesty.md`, `.opencode/guidelines/130-authority-source.md` | SC-11a, SC-11b, SC-11c, SC-12 | 4 |

---

## Phase Details

### Phase 1 — Dual-authority principle

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red`, `green`, `verify` |
| Target | `.opencode/guidelines/130-authority-source.md` |
| SCs | SC-1 |
| Depends On | — |

**Context:**
```yaml
file_to_modify: .opencode/guidelines/130-authority-source.md
sc_ids: [SC-1]
principle_phrase: "spec is authoritative for intent"
```

### Phase 2 — Six rules

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red`, `green`, `verify` |
| Target | `.opencode/guidelines/130-authority-source.md` |
| SCs | SC-2, SC-3, SC-4, SC-5, SC-6, SC-7 |
| Depends On | 1 |

**Context:**
```yaml
file_to_modify: .opencode/guidelines/130-authority-source.md
sc_ids: [SC-2, SC-3, SC-4, SC-5, SC-6, SC-7]
rules:
  - rule: "Spec for intent, code for state"
    sc: SC-2
  - rule: "Spec before code"
    sc: SC-3
  - rule: "Documentation Drift Protocol"
    sc: SC-4
  - rule: "Spec revision revokes plan approval"
    sc: SC-5
  - rule: "Suppression of Reactive Remediation"
    sc: SC-6
  - rule: "Verification against spec"
    sc: SC-7
```

### Phase 3 — Relocate superseded sections

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red`, `green`, `verify` |
| Target | `.opencode/guidelines/130-authority-source.md`, `.opencode/skills/spec-creation/SKILL.md`, `.opencode/guidelines/065-verification-honesty.md` |
| SCs | SC-8a, SC-8b, SC-9a, SC-9b, SC-10a, SC-10b |
| Depends On | 2 |

**Context:**
```yaml
source_file: .opencode/guidelines/130-authority-source.md
target_spec_creation: .opencode/skills/spec-creation/SKILL.md
target_065: .opencode/guidelines/065-verification-honesty.md
relocations:
  - section: "Superseding Issues + Overlap Detection Checklist"
    target: .opencode/skills/spec-creation/SKILL.md
    sc_absent: SC-8a
    sc_present: SC-8b
  - section: "Verification First"
    target: .opencode/guidelines/065-verification-honesty.md
    sc_absent: SC-9a
    sc_present: SC-9b
  - section: "Plan Audit Code Deep Dive"
    target: .opencode/skills/spec-creation/SKILL.md
    sc_absent: SC-10a
    sc_present: SC-10b
```

### Phase 4 — No mechanical compaction

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red`, `green`, `verify` |
| Target | `.opencode/guidelines/130-authority-source.md` |
| SCs | SC-12 |
| Depends On | 3 |

**Context:**
```yaml
file_to_modify: .opencode/guidelines/130-authority-source.md
sc_ids: [SC-12]
forbidden_phrases:
  - "removed for length"
  - "truncated"
  - "compacted to fit"
  - "shortened for size"
  - "abbreviated for space"
```

### Phase 5 — Clean-room semantic audit

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red`, `green`, `verify` |
| Target | `.opencode/skills/spec-creation/SKILL.md`, `.opencode/guidelines/065-verification-honesty.md`, `.opencode/guidelines/130-authority-source.md` |
| SCs | SC-11a, SC-11b, SC-11c, SC-12 |
| Depends On | 4 |

**Context:**
```yaml
source_130: .opencode/guidelines/130-authority-source.md
target_spec_creation: .opencode/skills/spec-creation/SKILL.md
target_065: .opencode/guidelines/065-verification-honesty.md
sc_ids: [SC-11a, SC-11b, SC-11c, SC-12]
```

---

## Exit Criteria

- [ ] C1. SC-1: The dual-authority principle (spec authoritative for intent, code authoritative for current state) is stated in `130-authority-source.md`.
- [ ] C2. SC-2 through SC-7: All six rules are present in `130-authority-source.md` with the required content assertions.
- [ ] C3. SC-8a through SC-10b: The three superseded sections are absent from `130-authority-source.md` and their content is present in the target files.
- [ ] C4. SC-11a through SC-11c: Clean-room semantic-preservation audit confirms no content loss across relocation boundaries.
- [ ] C5. SC-12: No mechanical compaction artifacts (forbidden phrases or content-free section headers) exist in the final guideline.
