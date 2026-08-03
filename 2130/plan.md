---
plan_schema_version: "1.0"
issue: 2130
title: "Compact 067-context-completeness.md — deduplicate, remove teaching material, collapse tables"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 4
---

# Implementation Plan — #2130 — Compact 067-context-completeness.md

**Goal:** Eliminate structural redundancy in `067-context-completeness.md` by merging duplicate Core Principle content into Zero Tolerance, removing teaching material (Why This Matters, Examples, Relationship to Other Critical Rules), replacing the When This Applies table with a one-sentence exception, and verifying all keep sections are preserved with unchanged content, position, and heading level.

**Architecture:** Four sequential phases operating on the same file (`.opencode/guidelines/067-context-completeness.md`). Phases 1-3 modify disjoint sections and can execute in any order. Phase 4 verifies the final state after all edits. All SCs are string-evidence type (grep/diff verification) — no behavioral tests needed.

**Files:**
- `.opencode/guidelines/067-context-completeness.md`

---

## Phase Table

| Phase | Skill | Task | Target | SCs | Depends On |
|-------|-------|------|--------|-----|------------|
| 1 — Deduplication | `test-driven-development` | `red` | `.opencode/guidelines/067-context-completeness.md` — Core Principle section | SC-1 | — |
| 2 — Teaching Material Removal | `test-driven-development` | `red` | `.opencode/guidelines/067-context-completeness.md` — Why This Matters, Examples, Relationship sections | SC-2, SC-4, SC-5 | — |
| 3 — Table Compaction | `test-driven-development` | `red` | `.opencode/guidelines/067-context-completeness.md` — When This Applies section | SC-3 | — |
| 4 — Preservation Verification | `test-driven-development` | `red` | `.opencode/guidelines/067-context-completeness.md` — all keep sections | SC-6a, SC-6b, SC-6c | 1, 2, 3 |

---

## Phase Details

### Phase 1 — Deduplication

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/guidelines/067-context-completeness.md` — Core Principle section |
| SCs | SC-1 |
| Depends On | — |

**Context:**
```yaml
file: .opencode/guidelines/067-context-completeness.md
operation: merge Core Principle section into Zero Tolerance section
sc_ids: [SC-1]
verification: grep -c 'read ALL comments' returns 1
```

### Phase 2 — Teaching Material Removal

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/guidelines/067-context-completeness.md` — Why This Matters, Examples, Relationship sections |
| SCs | SC-2, SC-4, SC-5 |
| Depends On | — |

**Context:**
```yaml
file: .opencode/guidelines/067-context-completeness.md
sections_to_remove:
  - "## Why This Matters" (header + table + blank lines)
  - "### Examples" (header + table + blank lines)
  - "## Relationship to Other Critical Rules" (header + prose + blank lines)
sc_ids: [SC-2, SC-4, SC-5]
verification:
  - grep for 'Why This Matters' returns 0
  - grep for 'Resource last read' returns 0
  - grep for 'Relationship to Other Critical Rules' returns 0
```

### Phase 3 — Table Compaction

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/guidelines/067-context-completeness.md` — When This Applies section |
| SCs | SC-3 |
| Depends On | — |

**Context:**
```yaml
file: .opencode/guidelines/067-context-completeness.md
operation: replace "## When This Applies" section (header + 8-row table) with one-sentence exception
replacement_text: "Before any action on a resource, read all comments. Exception: passive reading (no subsequent action) does not require comment reading."
sc_ids: [SC-3]
verification: grep -c 'passive reading' returns 1
```

### Phase 4 — Preservation Verification

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/guidelines/067-context-completeness.md` — all keep sections |
| SCs | SC-6a, SC-6b, SC-6c |
| Depends On | 1, 2, 3 |

**Context:**
```yaml
file: .opencode/guidelines/067-context-completeness.md
keep_sections:
  - "## Zero Tolerance Rule"
  - "## Scope of Resources"
  - "## Evidence Requirement"
  - "## Staleness Rule"
  - "## Single Exchange Window"
  - "## 🚫 FORBIDDEN"
  - "## ✅ REQUIRED"
  - "## Related Guidelines"
sc_ids: [SC-6a, SC-6b, SC-6c]
verification:
  - diff each keep section against original — no content changes
  - grep for each section header — order preserved
  - grep for each section header at ## level — all at ##
```

---

## Pre-implementation Steps

- [ ] P1. **Coherence gate (**clean-room**).** Verify the spec is internally coherent: all SCs are testable, all SCs map to at least one phase, no SC is covered by multiple phases, phase DAG has no circular dependencies. **→ All SCs**
- [ ] P2. **Baseline check (**inline**).** Verify the current file state matches spec expectations: `grep -c 'read ALL comments'` returns 2 (duplicate), `grep -c 'Why This Matters'` returns 1, `grep -c 'passive reading'` returns 0, `grep -c 'Resource last read'` returns 1, `grep -c 'Relationship to Other Critical Rules'` returns 1. **→ All SCs**

---

## Post-implementation Steps

- [ ] P3. **Structural checks (**sub-agent**).** Run `ruff check`, `pymarkdownlnt scan`, `mdformat --check` on `.opencode/guidelines/067-context-completeness.md`. Fix any issues. **→ All SCs**
- [ ] P4. **Verification gate (**clean-room**).** Verify all SC verdicts: SC-1 through SC-6c all PASS. If any FAIL, block and report. **→ All SCs**
- [ ] P5. **Audit (**clean-room**).** Adversarial audit of the deliverable — verify spec fidelity, no semantic loss, all keep sections preserved. **→ All SCs**
- [ ] P6. **Cross-validate (**clean-room**).** Cross-validate audit findings against verification results. Resolve any discrepancies. **→ All SCs**
- [ ] P7. **Review prep (**sub-agent**).** Prepare PR review context — summarize changes, highlight risk areas (SC-6a preservation). **→ All SCs**
- [ ] P8. **Create PR (**sub-agent**).** Create pull request with the changes. **→ All SCs**
- [ ] P9. **Executive summary (**sub-agent**).** Generate completion executive summary. **→ All SCs**

---

## Lifecycle Events

| Timestamp | Event | Details |
|-----------|-------|---------|
| 2026-08-03T00:46:00Z | `plan_created` | Plan file: `.opencode/.issues/2130/plan.md`, Phase count: 4 |

## Exit Criteria

- [ ] C1. Plan written to `.opencode/.issues/2130/plan.md` with all 4 phase files
- [ ] C2. Plan frontmatter contains `dispatch:` array with skill+task refs per phase
- [ ] C3. Every task in every phase enumerates every step from the implementation-workflow reference card per-task cycle
- [ ] C4. All SCs are mapped to at least one phase
- [ ] C5. No circular dependencies in the phase DAG
- [ ] C6. The plan uses structured markdown: checkbox lists with dash sub-bullets
- [ ] C7. No machine-parseable cross-references, no identifier IDs, no JSON/YAML code blocks in the body
- [ ] C8. Each item references exactly one SC-ID — no item covers multiple SCs
