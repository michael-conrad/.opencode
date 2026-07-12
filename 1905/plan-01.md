# Phase 1: Audit — Full Blast Radius Scan

**Chain:** `none` (Phase 1 is the starting phase)
**Phase dependency:** `none`
**Concern transition:** None — first phase

## Step 1: Grep all skills task files — 8 changes × pattern matrix

**Chain:** `none`
**RED:** No grep script exists yet
**Action:** For each of the 8 changes from #1902, grep across all `.opencode/skills/*/tasks/*.md` files. Use the following pattern matrix:

| # | Change | Grep Pattern |
|---|--------|-------------|
| 1 | YAML frontmatter for local spec.md | `spec.md`, `frontmatter`, `YAML` in task files outside `spec-creation/tasks/create.md` |
| 2 | Goals/Non-Goals sections | `## Goal`, `## Non-Goal`, section ordering patterns |
| 3 | AI Agent Instructions → gate-level enforcement | `AI Agent Instructions`, `pre-implementation checklist`, inline enforcement patterns |
| 4 | "Cards" → "Scope of Work" | `Cards` (case-insensitive), `Scope of Work` |
| 5 | Step 7 renumbering (7r/7a/7b/7c → 7.1/7.2/7.3/7.4) | `Step 7r`, `Step 7a`, `Step 7b`, `Step 7c`, `7.1`, `7.2`, `7.3`, `7.4` |
| 6 | Step 7r deleted | `Step 7r`, `7r` references in non-create.md files |
| 7 | Step 5 preamble wording | `Step 5`, `preamble`, `compliance blockquote`, `local-only` |
| 8 | Behavioral enforcement test pattern | Behavioral test assertions referencing old format |

**Dispatch:** Sub-agent via `task()` — one sub-agent per change pattern (8 parallel sub-agents).
**Evidence:** Results file `1905/audit-raw/grep-results-{N}.txt` per change.
**SC coverage:** SC-1, SC-2, SC-3, SC-4
**Verification:** All 8 grep result files non-empty (at least 0 matches documented).

## Step 2: Grep guidelines files — old format references

**Chain:** `step_1`
**RED:** grep fails on all guideline files
**Action:** Search all `.opencode/guidelines/*.md` files for:
- `Cards` (case-insensitive) — especially `080-code-standards.md`, `091-incremental-build.md`
- `Step 7r`, `Step 7a`, `Step 7b`, `Step 7c` patterns
- `AI Agent Instructions` references
- `section ordering` or `Problem.*Proposed Changes` (missing Goals in between)

**Dispatch:** Sub-agent via `task()` — single batch grep.
**Evidence:** `1905/audit-raw/guidelines-matches.txt`
**SC coverage:** SC-2
**Verification:** grep output logged; each match line classified as DIRECT/PATTERN-MATCH/DOMAIN-DIFFERENT/GENERIC-PROSE.

## Step 3: Grep behavioral and enforcement test files

**Chain:** `step_1`
**RED:** grep finds old-format assertions
**Action:** Search all `.opencode/tests/behaviors/*.sh` and `.opencode/tests/*.sh` for:
- Assertions on "Cards" heading
- Assertions on `Step 7r`, `Step 7a`, `7b`, `7c` step numbers
- Assertions on old section ordering (Problem → Proposed Changes without Goals)
- AI Agent Instructions inline enforcement assertions

**Dispatch:** Sub-agent via `task()` — batch grep across test directories.
**Evidence:** `1905/audit-raw/test-matches.txt`
**SC coverage:** SC-3, SC-4
**Verification:** All test assertion lines found, classified.

## Step 4: Classify every match — produce audit log

**Chain:** `steps_1-3` (depends on all grep results)
**RED:** No audit log exists
**Action:** For every match found in Steps 1–3, classify using:

| Classification | Definition | Action |
|--------------|-----------|--------|
| `DIRECT` | References the exact old heading/section/step name | Update to new |
| `PATTERN-MATCH` | Depends on old format structure (parsing, section order) | Update to new structure |
| `DOMAIN-DIFFERENT` | Different concept (skill cards, research cards, etc.) | No change, document verified-unaffected |
| `GENERIC-PROSE` | Generic English usage not tied to format | No change |

**Dispatch:** Sub-agent via `task()` — single agent with all grep results.
**Evidence:** `1905/audit-log.md` — structured classification table with:
- File path, line number, match text, change #, classification
- For DIRECT/PATTERN-MATCH: proposed new text
- For DOMAIN-DIFFERENT: justification
**SC coverage:** SC-1, SC-2, SC-3, SC-4, SC-5
**Verification:** Every match has exactly one classification; classification totals logged.

## Step 5: Audit AI Agent Instructions enforcement patterns

**Chain:** `step_4`
**RED:** grep finds pre-implementation checklist inline patterns
**Action:** Specifically audit Change #3 (AI Agent Instructions → gate-level enforcement). For each skill that references AI Agent Instructions or "pre-implementation checklist":
1. Determine if enforcement is inline (embedded in task steps) or gate-level (enforced by pipeline)
2. Note any inconsistencies between skills
3. Classify each as PATTERN-MATCH (needs gate-level uplift) or DOMAIN-DIFFERENT (correctly gate-level)

**Dispatch:** Sub-agent via `task()` — focused audit on Change #3 only.
**Evidence:** `1905/audit-raw/ai-instructions-audit.md`
**SC coverage:** SC-5
**Verification:** All AI Agent Instructions references classified; gate-level enforcement verified.
