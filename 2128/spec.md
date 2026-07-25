---
remote_issue: 2128
remote_url: https://github.com/michael-conrad/.opencode/issues/2128
labels: [spec]
---

## Problem

`060-tool-usage.md` is ~15KB. It contains sections that are Junie-specific training wheels (Path Rules, Guidelines Lookup tool, pre-submit cleanliness check), sections duplicated in 000 (Progressive Disclosure, Skill Call Principle), and tool-specific usage patterns that belong in skill cards (Todowrite Lifecycle, behavioral evidence exemption).

Research of public agent config decks (karma-works/everything-opencode, eddiemessiah/config-claude-code, survivorforge/cursor-rules) confirms: no public deck includes path resolution rules, temp file discipline, or command restrictions at this level of detail. These are Junie-specific remediations.

## Proposed Solution

### Remove (Junie-specific, not in any public deck):

| Section | Rationale |
|---|---|
| §1 Guidelines Lookup (lines 51-66) | Dead tool — this agent reads files directly with built-in `read` tool |
| §2 Path Rules (lines 68-127) | Junie-specific path resolution bugs. This agent's tools handle paths correctly. Worktree path table belongs in `using-git-worktrees` skill card if needed. |
| §3 Temp Files — pre-submit root cleanliness check (line 135) | References `submit` command and `.output.txt` — both Junie-specific |

### Remove (duplicated in other preloaded guidelines):

| Section | Duplicated In |
|---|---|
| §0 Progressive Disclosure (lines 9-20) | 000 (Orchestrator Context Lean) |
| §8 Skill Call Principle (lines 198-208) | 000 (DISPATCH_GATE, Canonical Dispatch String) |

### Remove (covered by other preloaded guidelines):

| Section | Covered By |
|---|---|
| §5 Verification & Audit (lines 165-175) | 065 (verification honesty) — first two rules. Third rule (no bulk sweeps) moves to `audit` skill card |

### Move to skill/task cards:

| Section | Destination |
|---|---|
| §3 Temp Files — behavioral evidence exemption (lines 137, 142) | `verification-before-completion` skill card |
| §7 Todowrite Lifecycle (lines 181-196) | `mcp-tool-usage` skill card |

### Keep (universal, not duplicated):

- §1 Tool Priority Hierarchy (tier summary, prohibited patterns, API client mandate)
- §3 Temp Files — one-liner: "All temp files go to `{project_root}/tmp/`"
- §4 Command Restrictions (no sed -i, no heredocs, no --recursive, etc.)
- §6 File Renaming
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
| SC-7 | Move behavioral evidence exemption to verification-before-completion skill card | string | grep for exemption in verification-before-completion/SKILL.md |
| SC-8 | Move Todowrite Lifecycle to mcp-tool-usage skill card | string | grep for todowrite lifecycle in mcp-tool-usage/SKILL.md |
| SC-9 | All keep sections remain | string | grep for each section header |
| SC-10 | Remove `./.opencode/tools/guidelines` tool | structural | tool file removed |

## Implementation Plan

### Phase 1: Remove §0, §1 Guidelines Lookup, §2 Path Rules, §5, §8
### Phase 2: Move behavioral evidence exemption to verification-before-completion
### Phase 3: Move Todowrite Lifecycle to mcp-tool-usage
### Phase 4: Remove `./.opencode/tools/guidelines` tool and update references
### Phase 5: Verify all keep sections remain

## Files Affected

- `.opencode/guidelines/060-tool-usage.md` — compacted
- `.opencode/skills/verification-before-completion/SKILL.md` — receives behavioral evidence exemption
- `.opencode/skills/mcp-tool-usage/SKILL.md` — receives Todowrite Lifecycle
- `.opencode/tools/guidelines` — removed
- `.opencode/tools/impl/guidelines-*` — removed
- Various files referencing `tools/guidelines` — updated

## Risks

- **Cross-reference breakage**: 016-srclight-preference.md and mcp-tool-usage skill card reference `tools/guidelines`. Must audit and update all 47 references.
- **Tool removal breaks scripts**: Any hook or script calling `./.opencode/tools/guidelines` will fail. Must audit before removal.

## Dependencies

- Depends on 000-critical-rules.md compaction (spec #2121) — the duplicated rules must remain in 000.

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
