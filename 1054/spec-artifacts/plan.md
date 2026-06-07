# Plan: [#1054](https://github.com/michael-conrad/.opencode/issues/1054) — Remove `memory` tool

## Overview

Single-phase deletion: remove 5 tool files (`.opencode/tools/memory` + 4 impl scripts), delete `.opencode/memory.md` data artifact, and update `mcp-tool-usage/SKILL.md` to remove `memory` from tool table.

## Changes

| # | Action | Target | Details |
|---|--------|--------|---------|
| 1 | Delete | `.opencode/tools/memory` | Main entry point script |
| 2 | Delete | `.opencode/tools/impl/memory-read` | Read implementation |
| 3 | Delete | `.opencode/tools/impl/memory-write` | Write implementation |
| 4 | Delete | `.opencode/tools/impl/memory-update` | Update implementation |
| 5 | Delete | `.opencode/tools/impl/memory-clear` | Clear implementation |
| 6 | Delete | `.opencode/memory.md` | Data artifact |
| 7 | Edit | `.opencode/skills/mcp-tool-usage/SKILL.md` | Remove `memory` from TIER 3 heading line and tool table |

## Pipeline Gates (Phase 1 — single phase)

| # | Gate | Exit Criterion |
|---|------|----------------|
| 1 | sc-coherence-gate | Deletion scope matches SC-1 through SC-5; update scope matches SC-4 |
| 2 | pre-red-baseline | All 6 files exist; mcp-tool-usage references `memory` at lines 93 and 126 |
| 3 | red-phase | Behavioral test: agent prompted to read memory → stderr shows memory tool call |
| 4 | red-doublecheck | Failure is missing fix, not harness |
| 5 | green-phase | All 6 files deleted by `git rm`; mcp-tool-usage edits applied |
| 6 | checkpoint-commit | Deletions + edits committed |
| 7 | structural-checks | `ls` on each deleted path returns error; grep on mcp-tool-usage tool table has no `memory` |
| 8 | green-doublecheck | RED test now PASSES — no memory tool call in stderr |
| 9 | green-vbc | SC-1 through SC-5 verified (structural/string) |
| 10 | adversarial-audit | No missed references to memory tool outside the known set |
| 11 | cross-validate | Both auditors agree |
| 12 | regression-check | Full grep of `.opencode/` for `tools/memory ` produces only false positives (agent_memory, GPU memory) |
| 13 | review-prep | PR body drafted: 6 file deletions + 1 edit summary |
| 14 | exec-summary | Phase complete |

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | `.opencode/tools/memory` deleted | `structural` |
| SC-2 | All 4 memory-* impl scripts deleted | `structural` |
| SC-3 | `.opencode/memory.md` deleted | `structural` |
| SC-4 | `mcp-tool-usage` no longer references `memory` in tool table | `string` |
| SC-5 | No dangling references to memory tool | `string/grep` |

## Dispatch Markers

| Phase | Marker |
|-------|--------|
| 1 | `remove-memory-tool` |