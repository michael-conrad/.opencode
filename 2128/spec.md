---
remote_issue: 2128
remote_url: https://github.com/michael-conrad/.opencode/issues/2128
labels: [spec]
---

## Intent

Compact 060-tool-usage.md to approximately half its current size (~8KB from ~16KB) by removing Junie-specific, project-specific, tool-specific, and duplicated/overlapping content. Keep only universally applicable rules.

## Root Cause

060-tool-usage.md accumulated Junie-specific remediations over time — rules added to compensate for limitations in the Junie agent CLI (shell restrictions, path resolution bugs, tool preference overrides). These rules do not apply to this agent and inflate the file to ~16KB. Sections that overlap with 000-critical-rules.md (Progressive Disclosure, Skill Call Principle) were also kept as redundant copies.

## Alternatives Considered

- **Alternative A: Mark sections as deprecated without removing** — would keep file size high without improving signal. Rejected.
- **Alternative B: Move all content to individual skill cards** — would force every agent to load a skill to learn basic tool rules. Rejected; keep sections are short enough to inline.
- **Current approach: Remove or purge 17 items, keep 6 universal sections.** Selected.

## Edge Cases

- **Section already absent**: If a removal target is already gone (e.g., already deleted in a parallel change), the delete operation is a no-op — grep-based verification will confirm absence regardless.
- **Destination rules conflict**: No sections are being moved, only removed or purged. No destination conflict possible.
- **Cross-reference already updated**: If a `tools/guidelines` reference was already updated in parallel work, SC-21 verification handles it naturally (grep for absence of the old reference).

## Problem

`060-tool-usage.md` is ~16KB (16578 bytes, 255 lines). It contains sections that are Junie-specific training wheels (Path Rules, Guidelines Lookup tool, pre-submit cleanliness check, most of §4 Command Restrictions), sections that overlap with content in 000 (Progressive Disclosure overlaps with Orchestrator Context Lean / critical-rules-063; Skill Call Principle overlaps with DISPATCH_GATE / Canonical Dispatch String), project-specific rules (`uv run python`), and tool-specific usage patterns (Todowrite Lifecycle, File Renaming).

These are Junie-specific remediations that accumulated over time. ("Junie-specific" refers to rules added to compensate for limitations in the Junie agent CLI — shell restrictions, path resolution bugs, and tool preference overrides that do not apply to this agent.)

## Proposed Solution

### Remove (Junie-specific, not in any public deck):

| Section | Rationale |
|---|---|
| §1 Guidelines Lookup (lines 51-66) | Dead tool — this agent reads files directly with built-in `read` tool |
| §2 Path Rules (lines 68-127) | Junie-specific path resolution bugs. This agent's tools handle paths correctly. Worktree path table belongs in `using-git-worktrees` skill card if needed. |
| §3 Temp Files — pre-submit root cleanliness check (line 135) | References `submit` command and `.output.txt` — both Junie-specific |
| §4 — fixed sleep value `15` (line 149) | Arbitrary magic number, no universal basis |
| §4 — "one clear command per invocation" (line 150) | Junie-specific shell discipline |
| §4 — "use built-in Edit/Write tools" (line 151) | Junie-specific tool preference; this agent's tools are already the default |
| §4 — no `stty` (line 155) | Junie-specific terminal hang workaround |
| §4 — no heredocs (line 157) | Junie-specific shell limitation |
| §4 — no repeated grep/egrep/sed (line 158) | Junie-specific search discipline; this agent has `grep` tool |
| §4 — `sed -i`, `printf`, `echo` redirection forbidden (line 159) | Junie-specific file edit bypass prevention |
| §4 — no multi-line shell loops (line 161) | Junie-specific shell limitation |
| §4 — no `sed` for file edits (line 162) | Redundant with `sed -i` rule above |

### Remove (overlaps with content in 000):

| Section | Overlaps With |
|---|---|
| §0 Progressive Disclosure (lines 9-20) | 000 (critical-rules-063 Orchestrator Context Lean) — similar content, not identical |
| §8 Skill Call Principle (lines 198-208) | 000 (DISPATCH_GATE, Canonical Dispatch String) — similar content, not identical |

### Remove (covered by other preloaded guidelines):

| Section | Covered By |
|---|---|
| §5 Verification & Audit (lines 165-175) | 065 (verification honesty) — first two rules. Third rule (no bulk sweeps) is deleted — audit skill card does not contain equivalent content |

### Purge (no destination — tool-specific or unclear value):

| Section | Rationale |
|---|---|
| §6 File Renaming (line 179) | Junie-era rule about not asking for filenames; not universally applicable |
| §7 Todowrite Lifecycle (lines 181-196) | Tool-specific lifecycle rules don't belong in guidelines |

### Keep (universal, not duplicated) — 6 sections:

1. §1 Tool Priority Hierarchy (tier summary, prohibited patterns, API client mandate)
2. §3 Temp Files — one-liner: "All temp files go to `{project_root}/tmp/`" + behavioral evidence exemption (2 lines)
3. §4 — no destructive checkouts
4. §4 — no production data edits
5. §4 — no `--recursive` with git submodule
6. §9 Identity Source Semantics

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | Remove §0 Progressive Disclosure | string | grep for absence of 'Progressive Disclosure' |
| SC-2 | Remove §1 Guidelines Lookup | string | grep for absence of 'Guidelines Lookup' |
| SC-3 | Remove §2 Path Rules | string | grep for absence of 'Path Rules' |
| SC-4 | Remove pre-submit root cleanliness check | string | grep for absence of 'pre-submit root cleanliness' |
| SC-5 | Remove §5 Verification & Audit | string | grep for absence of 'Verification & Audit' |
| SC-6 | Remove §8 Skill Call Principle | string | grep for absence of 'Skill Call Principle' |
| SC-7 | Remove fixed sleep value `15` from §4 | string | grep for absence of 'Fixed sleep value' |
| SC-8 | Remove "one clear command per invocation" from §4 | string | grep for absence of 'One clear command per invocation' |
| SC-9 | Remove "use built-in Edit/Write tools" from §4 | string | grep for absence of 'Use built-in Edit/Write tools' |
| SC-10 | Remove no `stty` from §4 | string | grep for absence of 'No `stty`' |
| SC-11 | Remove no heredocs from §4 | string | grep for absence of 'No embedded scripts via heredocs' |
| SC-12 | Remove no repeated grep/egrep/sed from §4 | string | grep for absence of 'repeated.*grep' |
| SC-13 | Remove `sed -i`, `printf`, `echo` redirection from §4 | string | grep for absence of 'sed -i' |
| SC-14 | Remove no multi-line shell loops from §4 | string | grep for absence of 'Multi-line shell loops' |
| SC-15 | Remove no `sed` for file edits from §4 | string | grep for absence of 'NEVER use `sed` for file edits' |
| SC-16 | Remove §6 File Renaming | string | grep for absence of 'File Renaming' |
| SC-17 | Remove §7 Todowrite Lifecycle | string | grep for absence of 'Todowrite Lifecycle' |
| SC-18 | Remove `uv run python` from §4 and update 070-environment.md cross-reference to remove references to §4 of 060-tool-usage.md | string | grep for absence of 'uv run python' in 060; grep for absence of cross-reference to 060 for this rule in 070 |
| SC-19 | All 6 keep sections remain after compaction: §1 Tool Priority Hierarchy, §3 Temp Files one-liner + behavioral exemption, §4 no destructive checkouts, §4 no production data edits, §4 no `--recursive` with git submodule, §9 Identity Source Semantics | string | grep for each of the 6 section headers |
| SC-20 | Remove `./.opencode/tools/guidelines` tool | structural | tool file removed |
| SC-21 | Update `tools/guidelines` references in all 5 pre-existing files that reference it: 016-srclight-preference.md, mcp-tool-usage/selection-guide.md, audit/guideline-audit-investigator.md, 060-tool-usage.md, .issues/317/plan.md | string | grep for absence of 'tools/guidelines' in all 5 files after Phase 4 |

## Implementation Plan

### Phase 1: Remove §0, §1 Guidelines Lookup, §2 Path Rules, §5, §8 from 060-tool-usage.md
### Phase 2: Remove §4 Junie-specific items (fixed sleep, one command, edit/write, stty, heredocs, repeated grep, sed-i/printf/echo, multi-line loops, sed for edits) and `uv run python` from 060-tool-usage.md
### Phase 3: Remove §6 File Renaming and §7 Todowrite Lifecycle from 060-tool-usage.md
### Phase 4: Remove `./.opencode/tools/guidelines` tool, remove `.opencode/tools/impl/guidelines-*` files
### Phase 5: Update `tools/guidelines` references across all 5 pre-existing files (016-srclight-preference.md, mcp-tool-usage/selection-guide.md, audit/guideline-audit-investigator.md, 060-tool-usage.md, .issues/317/plan.md)
### Phase 6: Update 070-environment.md cross-reference to 060-tool-usage.md for `uv run python` rule
### Phase 7: Verify all 6 keep sections remain

## Files Affected

- `.opencode/guidelines/060-tool-usage.md` — compacted
- `.opencode/tools/guidelines` — removed
- `.opencode/tools/impl/guidelines-*` — removed
- Various files referencing `tools/guidelines` — updated

## Risks

- **Cross-reference breakage**: 016-srclight-preference.md, mcp-tool-usage skill card, and audit skill card reference `tools/guidelines`. Must audit and update all 5 pre-existing files (30 references total).
- **Tool removal breaks scripts**: Any hook or script calling `./.opencode/tools/guidelines` will fail. Must audit before removal.

## Documentation Sources

The following claims were verified against the codebase via tool calls (July 28, 2026):
- `grep -rl "tools/guidelines" .opencode/ --include="*.md" --include="*.yaml" --include="*.sh" --include="*.py" --include="*.ts"` — returns 7 files (5 pre-existing: 016-srclight-preference.md, mcp-tool-usage/selection-guide.md, audit/guideline-audit-investigator.md, 060-tool-usage.md, .issues/317/plan.md; plus 2 created by this spec: spec.md, remote.md)
- `.issues/317/plan.md` — verified exists (10255 bytes, contains 1 reference to `tools/guidelines`)
- 060-tool-usage.md — verified exists (16578 bytes, 255 lines)
- `.opencode/tools/guidelines` — verified exists (tool dispatcher)
- `.opencode/tools/impl/guidelines-*` — verified exists (guidelines-edit, guidelines-read, guidelines-search, guidelines-show)

## Dependencies

- Depends on 000-critical-rules.md compaction (spec #2121) — the duplicated rules must remain in 000.

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
