---
plan_schema_version: "1.0"
issue: 2128
title: "Compact 060-tool-usage.md to ~8KB by removing Junie-specific, project-specific, and duplicated content"
authorization_scope: for_implementation
pr_strategy: stacked
phase_count: 9
---

# Implementation Plan — #2128 — Compact 060-tool-usage.md

**Issue:** https://github.com/michael-conrad/.opencode/issues/2128

**Goal:** Compact 060-tool-usage.md from ~16KB to ~8KB by removing 17 items (Junie-specific rules, duplicated content, tool-specific lifecycle rules) and removing the `tools/guidelines` tool.

**Architecture:** Sequential content removal from 060-tool-usage.md (Phases 1-3), then tool removal (Phase 4), cross-reference updates (Phases 5-6), and final verification (Phase 7). Each phase is a separate RED/GREEN/commit cycle on the same file, ordered by section position in the file to minimize merge conflicts.

**Same-concern rationale (Phases 1, 2, 3):** All three phases remove content from 060-tool-usage.md. They are sequential (1→2→3) rather than parallel because each phase modifies the same file and must start from the previous phase's known-good state. Phase 1 removes top-of-file sections (§0, §1, §2, §5, §8) and the pre-submit check in §3. Phase 2 removes items within §4 (the largest section, 14 lines). Phase 3 removes bottom-of-file sections (§6, §7). The dependency chain ensures each phase's RED test starts from a clean post-commit state.

**Files:**
- `.opencode/guidelines/060-tool-usage.md` — compacted (Phases 1-3)
- `.opencode/tools/guidelines` — removed (Phase 4)
- `.opencode/tools/impl/guidelines-*` — removed (Phase 4)
- `.opencode/guidelines/016-srclight-preference.md` — reference updated (Phase 5)
- `.opencode/skills/mcp-tool-usage/tasks/selection-guide.md` — reference updated (Phase 5)
- `.opencode/skills/audit/tasks/guideline-audit-investigator.md` — reference updated (Phase 5)
- `.opencode/guidelines/060-tool-usage.md` — self-reference updated (Phase 5)
- `.opencode/.issues/317/plan.md` — reference updated (Phase 5)
- `.opencode/guidelines/070-environment.md` — cross-reference updated (Phase 6)

---

## Phase Table

| Phase | Skill | Task | Target | SCs | Depends On |
|-------|-------|------|--------|-----|------------|
| 1 — Remove top sections | `implementation-pipeline` | `step-dispatch` | `060-tool-usage.md` §0, §1, §2, §3 pre-submit, §5, §8 | SC-1, SC-2, SC-3, SC-4, SC-5, SC-6 | — |
| 2 — Remove §4 items | `implementation-pipeline` | `step-dispatch` | `060-tool-usage.md` §4 (14 items) | SC-7, SC-8, SC-9, SC-10, SC-11, SC-12, SC-13, SC-14, SC-15, SC-18a | 1 |
| 3 — Remove bottom sections | `implementation-pipeline` | `step-dispatch` | `060-tool-usage.md` §6, §7 | SC-16, SC-17 | 2 |
| 4 — Remove guidelines tool | `implementation-pipeline` | `step-dispatch` | `.opencode/tools/guidelines`, `.opencode/tools/impl/guidelines-*` | SC-20 | — |
| 5 — Update references | `implementation-pipeline` | `step-dispatch` | 5 files referencing `tools/guidelines` | SC-21 | 4 |
| 6 — Update 070 cross-ref | `implementation-pipeline` | `step-dispatch` | `070-environment.md` | SC-18b | 2 |
| 7 — Verify keep sections | `implementation-pipeline` | `step-dispatch` | `060-tool-usage.md` (verification only) | SC-19 | 1, 2, 3 |

---

## Phase Details

### Phase 1 — Remove top sections

**Skill:** `implementation-pipeline` | **Task:** `step-dispatch` | **Target:** `060-tool-usage.md` — remove §0, §1, §2, §3 pre-submit, §5, §8 | **SCs:** SC-1, SC-2, SC-3, SC-4, SC-5, SC-6 | **Depends On:** —

1. - [ ] Remove §0 Progressive Disclosure from `060-tool-usage.md` (SC-1)
2. - [ ] Remove §1 Guidelines Lookup from `060-tool-usage.md` (SC-2)
3. - [ ] Remove §2 Path Rules from `060-tool-usage.md` (SC-3)
4. - [ ] Remove §3 pre-submit root cleanliness check from `060-tool-usage.md` (SC-4)
5. - [ ] Remove §5 Verification & Audit from `060-tool-usage.md` (SC-5)
6. - [ ] Remove §8 Skill Call Principle from `060-tool-usage.md` (SC-6)

### Phase 2 — Remove §4 items

**Skill:** `implementation-pipeline` | **Task:** `step-dispatch` | **Target:** `060-tool-usage.md` — remove 14 items from §4 | **SCs:** SC-7, SC-8, SC-9, SC-10, SC-11, SC-12, SC-13, SC-14, SC-15, SC-18a | **Depends On:** 1

1. - [ ] Remove "fixed sleep value 15" item from §4 (SC-7)
2. - [ ] Remove "one clear command per invocation" item from §4 (SC-8)
3. - [ ] Remove "use built-in Edit/Write tools" item from §4 (SC-9)
4. - [ ] Remove "no stty" item from §4 (SC-10)
5. - [ ] Remove "no heredocs" item from §4 (SC-11)
6. - [ ] Remove "no repeated grep/egrep/sed" item from §4 (SC-12)
7. - [ ] Remove "sed -i, printf, echo redirection" item from §4 (SC-13)
8. - [ ] Remove "no multi-line shell loops" item from §4 (SC-14)
9. - [ ] Remove "no sed for file edits" item from §4 (SC-15)
10. - [ ] Remove "uv run python" item from §4 (SC-18a)

### Phase 3 — Remove bottom sections

**Skill:** `implementation-pipeline` | **Task:** `step-dispatch` | **Target:** `060-tool-usage.md` — remove §6, §7 | **SCs:** SC-16, SC-17 | **Depends On:** 2

1. - [ ] Remove §6 File Renaming from `060-tool-usage.md` (SC-16)
2. - [ ] Remove §7 Todowrite Lifecycle from `060-tool-usage.md` (SC-17)

### Phase 4 — Remove guidelines tool

**Skill:** `implementation-pipeline` | **Task:** `step-dispatch` | **Target:** `.opencode/tools/guidelines`, `.opencode/tools/impl/guidelines-*` | **SCs:** SC-20 | **Depends On:** —

1. - [ ] Remove `.opencode/tools/guidelines` file (SC-20)
2. - [ ] Remove `.opencode/tools/impl/guidelines-edit` file (SC-20)
3. - [ ] Remove `.opencode/tools/impl/guidelines-read` file (SC-20)
4. - [ ] Remove `.opencode/tools/impl/guidelines-search` file (SC-20)
5. - [ ] Remove `.opencode/tools/impl/guidelines-show` file (SC-20)

### Phase 5 — Update references

**Skill:** `implementation-pipeline` | **Task:** `step-dispatch` | **Target:** 5 files referencing `tools/guidelines` | **SCs:** SC-21 | **Depends On:** 4

1. - [ ] Update `tools/guidelines` reference in `.opencode/guidelines/016-srclight-preference.md` (SC-21)
2. - [ ] Update `tools/guidelines` reference in `.opencode/skills/mcp-tool-usage/tasks/selection-guide.md` (SC-21)
3. - [ ] Update `tools/guidelines` reference in `.opencode/skills/audit/tasks/guideline-audit-investigator.md` (SC-21)
4. - [ ] Update `tools/guidelines` self-reference in `.opencode/guidelines/060-tool-usage.md` (SC-21)
5. - [ ] Update `tools/guidelines` reference in `.opencode/.issues/317/plan.md` (SC-21)

### Phase 6 — Update 070 cross-reference

**Skill:** `implementation-pipeline` | **Task:** `step-dispatch` | **Target:** `070-environment.md` | **SCs:** SC-18b | **Depends On:** 2

1. - [ ] Remove or update cross-reference to `060-tool-usage.md` for `uv run python` rule in `.opencode/guidelines/070-environment.md` (SC-18b)

### Phase 7 — Verify keep sections

**Skill:** `implementation-pipeline` | **Task:** `step-dispatch` | **Target:** `060-tool-usage.md` — verification only | **SCs:** SC-19 | **Depends On:** 1, 2, 3

1. - [ ] Verify §1 Tool Priority Hierarchy remains in `060-tool-usage.md` (SC-19)
2. - [ ] Verify §3 Temp Files one-liner + behavioral exemption remains in `060-tool-usage.md` (SC-19)
3. - [ ] Verify §4 "no destructive checkouts" item remains in `060-tool-usage.md` (SC-19)
4. - [ ] Verify §4 "no production data edits" item remains in `060-tool-usage.md` (SC-19)
5. - [ ] Verify §4 "no --recursive with git submodule" item remains in `060-tool-usage.md` (SC-19)
6. - [ ] Verify §9 Identity Source Semantics remains in `060-tool-usage.md` (SC-19)

---

---

## Lifecycle Events

| Timestamp | Event | Details |
|-----------|-------|---------|
| 2026-07-28T01:45:00Z | `plan_created` | Plan file at `.opencode/.issues/2128/plan.md`, 7 phases, dispatch via `implementation-pipeline` → `step-dispatch` |

## Exit Criteria

- [ ] C1. All 6 removed sections (§0, §1, §2, §5, §8, §3 pre-submit) are absent from 060-tool-usage.md
- [ ] C2. All 10 removed §4 items are absent from 060-tool-usage.md
- [ ] C3. §6 File Renaming and §7 Todowrite Lifecycle are absent from 060-tool-usage.md
- [ ] C4. `.opencode/tools/guidelines` and `.opencode/tools/impl/guidelines-*` files are removed
- [ ] C5. All 5 pre-existing files have `tools/guidelines` references updated to appropriate alternatives
- [ ] C6. 070-environment.md cross-reference to 060-tool-usage.md for `uv run python` is removed or updated
- [ ] C7. All 6 keep sections remain in 060-tool-usage.md after compaction
- [ ] C8. 060-tool-usage.md is approximately 8KB (within 20% of target)
