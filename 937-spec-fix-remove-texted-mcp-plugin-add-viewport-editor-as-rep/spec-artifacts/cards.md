# Card Catalogue — #937 Replace texted with viewport-editor MCP plugin

## Phase 1: Spec Revision (DRAFT — complete)

| Card | Status | Notes |
|------|--------|-------|
| C-1: Investigate texted MCP plugin status | DONE | Confirmed: `"texted"` block in `opencode.jsonc`, `tools/run-texted-mcp` exists |
| C-2: Investigate viewport-editor capabilities | DONE | README reviewed: 6-tool surface, uvx install from v0.2.0, coexists with built-in tools |
| C-3: Write revised spec | DONE | spec.md written with SC-1 through SC-4 |
| C-4: Setup card catalogue | DONE | This file |

## Phase 2: Implementation

| Card | Status | Notes |
|------|--------|-------|
| C-5: Edit opencode.jsonc — remove texted block | PENDING | |
| C-6: Edit opencode.jsonc — add viewport-editor block | PENDING | |
| C-7: Delete tools/run-texted-mcp | PENDING | |
| C-8: Validate JSONC syntax | PENDING | |
| C-9: Update remote GitHub issue body | PENDING | |

## Phase 3: Verification

| Card | Status | Notes |
|------|--------|-------|
| C-10: Verify SC-1 (texted removed) | PENDING | `grep 'texted' opencode.jsonc` |
| C-11: Verify SC-2 (viewport-editor added) | PENDING | `grep 'viewport-editor' opencode.jsonc` |
| C-12: Verify SC-3 (run-texted-mcp deleted) | PENDING | `ls tools/run-texted-mcp` returns not found |
| C-13: Verify SC-4 (valid JSONC) | PENDING | Parse check |
| C-14: Post-implementation behavioral test | PENDING | Confirm agent can discover viewport-editor via `skill("mcp-tool-usage")` |

## Decision Log

| Date | Decision | Rationale |
|------|----------|-----------|
| 2026-06-07 | Replace texted with viewport-editor, not just remove | texted duplicates built-in tools. viewport-editor provides windowed editing that built-in tools and texted do not offer. |
| 2026-06-07 | Use `uvx` from GitHub release tag `v0.2.0` | No PyPI publish needed, matches MCP server pattern used by `the-notebook-mcp` and `srclight`. |

## Dependency Graph

```
C-5 ──> C-8 ──> C-10
C-6 ──> C-8 ──> C-11
C-7 ────────> C-12
C-9 ───────────> (independent)
C-10 & C-11 & C-12 & C-13 ──> C-14
```
