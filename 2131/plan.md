---
plan_schema_version: "1.0"
issue: 2131
title: "Compact 080-code-standards.md — generalize, move, remove"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 4
---

# Implementation Plan — [#2131](https://github.com/michael-conrad/.opencode/issues/2131) — Compact 080-code-standards.md

**Goal:** Reorganize `080-code-standards.md` by generalizing project-specific references, moving the Enforcement Test Mandate to the `test-driven-development` skill card, removing the Behavioral RED/GREEN section (content preserved in the moved section), and verifying all keep sections remain intact.

**Architecture:** Four sequential phases with dependency chain. Each phase modifies `.opencode/guidelines/080-code-standards.md` and/or `.opencode/skills/test-driven-development/SKILL.md`. All moves/removals are gated by semantic analysis verifying no constraint loss. Phase 3 includes a lobotomization gate running behavioral enforcement tests.

**Files:**
- `.opencode/guidelines/080-code-standards.md`
- `.opencode/skills/test-driven-development/SKILL.md`

---

## Phase Table

| Phase | Skill | Task | Target | SCs | Depends On |
|-------|-------|------|--------|-----|------------|
| 1 — Generalize | `test-driven-development` | `red` | `080-code-standards.md` Parsing Logic Changes + Libraries & Packages | SC-1, SC-2, SC-7 | — |
| 2 — Move | `test-driven-development` | `green` | `080-code-standards.md` → `test-driven-development/SKILL.md` | SC-3, SC-8 | 1 |
| 3 — Remove | `test-driven-development` | `red` | `080-code-standards.md` Behavioral RED/GREEN section | SC-4, SC-5, SC-9 | 2 |
| 4 — Verify | `test-driven-development` | `green` | `080-code-standards.md` keep sections | SC-6 | 3 |

---

## Phase Details

### Phase 1 — Generalize

| Field | Value |
|-------|-------|
| File | `plan-01-generalize.md` |
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `080-code-standards.md` Parsing Logic Changes + Libraries & Packages |
| SCs | SC-1, SC-2, SC-7 |
| Depends On | — |

**Procedure:** See `plan-01-generalize.md` for numbered steps.

**Context:**
```yaml
files_to_modify:
  - .opencode/guidelines/080-code-standards.md
generalize_targets:
  - section: "Parsing Logic Changes"
    replace_project_specific:
      - "src/commons/parsing/"
      - "0100_ingest_xml.ipynb"
    with_universal: "Changes to data processing pipelines that affect extracted metadata require a full pipeline rerun"
  - section: "Libraries & Packages"
    replace_project_specific:
      - "NLTK"
      - "ConfigurationManager"
      - "project-config.ini"
      - "210-scripting.md"
    with_universal: "Use domain-appropriate libraries for specialized tasks. Use project-provided abstractions for data file paths."
sc_ids: [SC-1, SC-2, SC-7]
```

### Phase 2 — Move

| Field | Value |
|-------|-------|
| File | `plan-02-move.md` |
| Skill | `test-driven-development` |
| Task | `green` |
| Target | `080-code-standards.md` → `test-driven-development/SKILL.md` |
| SCs | SC-3, SC-8 |
| Depends On | 1 |

**Procedure:** See `plan-02-move.md` for numbered steps.

**Context:**
```yaml
source_file: .opencode/guidelines/080-code-standards.md
source_section: "Enforcement Test Mandate"
destination_file: .opencode/skills/test-driven-development/SKILL.md
sc_ids: [SC-3, SC-8]
```

### Phase 3 — Remove

| Field | Value |
|-------|-------|
| File | `plan-03-remove.md` |
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `080-code-standards.md` Behavioral RED/GREEN section |
| SCs | SC-4, SC-5, SC-9 |
| Depends On | 2 |

**Procedure:** See `plan-03-remove.md` for numbered steps.

**Context:**
```yaml
files_to_modify:
  - .opencode/guidelines/080-code-standards.md
remove_section: "Behavioral RED/GREEN as Primary Enforcement Gate"
keep_section: "Test Integrity Mandate"
lobotomization_gate: true
sc_ids: [SC-4, SC-5, SC-9]
```

### Phase 4 — Verify

| Field | Value |
|-------|-------|
| File | `plan-04-verify.md` |
| Skill | `test-driven-development` |
| Task | `green` |
| Target | `080-code-standards.md` keep sections |
| SCs | SC-6 |
| Depends On | 3 |

**Procedure:** See `plan-04-verify.md` for numbered steps.

**Context:**
```yaml
files_to_verify:
  - .opencode/guidelines/080-code-standards.md
keep_sections:
  - Scope
  - Typing
  - Design Principles
  - Modern Python
  - Print Statements
  - Linting & Tool Selection
  - Numbering
  - AI Co-Authored Attribution
  - Provenance Headers
  - Cross-Reference Standards
  - YAML Standard
  - Triple Co-Application
  - Parameter Naming Convention
  - Test Integrity Mandate
sc_ids: [SC-6]
```

---

## Exit Criteria

- [ ] C1. Parsing Logic Changes section has no project-specific paths (SC-1)
- [ ] C2. Libraries & Packages section has no project-specific names (SC-2)
- [ ] C3. Enforcement Test Mandate exists in test-driven-development/SKILL.md (SC-3)
- [ ] C4. Behavioral RED/GREEN section removed from 080 (SC-4)
- [ ] C5. Test Integrity Mandate remains in 080 with content intact (SC-5)
- [ ] C6. All keep sections remain in 080 with content intact (SC-6)
- [ ] C7. Generalized Parsing Logic Changes preserve pipeline-rerun constraint (SC-7)
- [ ] C8. Moved Enforcement Test Mandate preserves all normative rules (SC-8)
- [ ] C9. Removed section's normative content exists in moved Enforcement Test Mandate (SC-9)
- [ ] C10. Behavioral enforcement tests pass (lobotomization gate)
- [ ] C11. All 9 SCs PASS — all-or-nothing gate per spec

## Lifecycle Events

| Event | Timestamp | Details |
|-------|-----------|---------|
| `plan_created` | 2026-08-03T01:25:00Z | Plan file at `.opencode/.issues/2131/plan.md`, 4 phases, sequential dependency chain |
