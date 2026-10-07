# Plan: Update viewport-editor MCP plugin to v0.3.3

## Status

PLAN-APPROVED (auto-approved via spec-to-plan cascade per `for_pr` scope, 2026-06-13)

## Items

| ID | Description | Files | Status | Proof |
|----|-------------|-------|--------|-------|
| 1 | Update opencode.jsonc viewport-editor MCP command to `@v0.3.3` | `.opencode/opencode.jsonc` | COMPLETED | PR #1150, commit 90a55cd3 |
| 2 | Add viewport-editor activation stanza to AGENTS.md | `.opencode/AGENTS.md` | COMPLETED | PR #1150, commit 90a55cd3 |

## Dependency Graph

```
Item 1 (opencode.jsonc) ──→ Item 2 (AGENTS.md)  [no dependency — can be parallel]
```

## Authorization

- Authorization scope: `for_pr`
- PR strategy: `stacked`
- PR: #1150 (merged to dev 2026-06-13)