---
remote_issue: 2128
remote_url: https://github.com/michael-conrad/.opencode/issues/2128
labels: [spec]
---

## Problem

`060-tool-usage.md` is ~15KB. It contains sections that are Junie-specific training wheels (Path Rules, Guidelines Lookup tool, pre-submit cleanliness check, most of §4 Command Restrictions), sections duplicated in 000 (Progressive Disclosure, Skill Call Principle), project-specific rules (`uv run python`), and tool-specific usage patterns (Todowrite Lifecycle, File Renaming).

These are Junie-specific remediations that accumulated over time.

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

### Remove (duplicated in other preloaded guidelines):

| Section | Duplicated In |
|---|---|
| §0 Progressive Disclosure (lines 9-20) | 000 (Orchestrator Context Lean) |
| §8 Skill Call Principle (lines 198-208) | 000 (DISPATCH_GATE, Canonical Dispatch String) |

### Remove (covered by other preloaded guidelines):

| Section | Covered By |
|---|---|
| §5 Verification & Audit (lines 165-175) | 065 (verification honesty) — first two rules. Third rule (no bulk sweeps) moves to `audit` skill card |

### Purge (no destination — tool-specific or unclear value):

| Section | Rationale |
|---|---|
| §6 File Renaming (line 179) | Junie-era rule about not asking for filenames; not universally applicable |
| §7 Todowrite Lifecycle (lines 181-196) | Tool-specific lifecycle rules don't belong in guidelines |

### Keep (universal, not duplicated):

- §1 Tool Priority Hierarchy (tier summary, prohibited patterns, API client mandate)
- §3 Temp Files — one-liner: "All temp files go to `{project_root}/tmp/`" + behavioral evidence exemption (2 lines)
- §4 — no destructive checkouts
- §4 — no production data edits
- §4 — no `--recursive` with git submodule
- §9 Identity Source Semantics

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
| SC-18 | Remove `uv run python` from §4 | string | grep for absence of 'uv run python' |
| SC-19 | All keep sections remain | string | grep for each section header |
| SC-20 | Remove `./.opencode/tools/guidelines` tool | structural | tool file removed |

## Implementation Plan

### Phase 1: Remove §0, §1 Guidelines Lookup, §2 Path Rules, §5, §8 from 060-tool-usage.md
### Phase 2: Remove §4 Junie-specific items (fixed sleep, one command, edit/write, stty, heredocs, repeated grep, sed-i/printf/echo, multi-line loops, sed for edits) and `uv run python` from 060-tool-usage.md
### Phase 3: Remove §6 File Renaming and §7 Todowrite Lifecycle from 060-tool-usage.md
### Phase 4: Remove `./.opencode/tools/guidelines` tool and update references
### Phase 5: Verify all keep sections remain

## Files Affected

- `.opencode/guidelines/060-tool-usage.md` — compacted
- `.opencode/tools/guidelines` — removed
- `.opencode/tools/impl/guidelines-*` — removed
- Various files referencing `tools/guidelines` — updated

## Risks

- **Cross-reference breakage**: 016-srclight-preference.md, mcp-tool-usage skill card, and audit skill card reference `tools/guidelines`. Must audit and update all 7 files (30 references).
- **Tool removal breaks scripts**: Any hook or script calling `./.opencode/tools/guidelines` will fail. Must audit before removal.

## Dependencies

- Depends on 000-critical-rules.md compaction (spec #2121) — the duplicated rules must remain in 000.

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
