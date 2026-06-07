# [SPEC-FIX] Remove texted MCP plugin, add viewport-editor as replacement

**Status:** DRAFT

## Summary

Replace the `texted` MCP plugin in `opencode.jsonc` with the `viewport-editor` MCP server. The texted plugin duplicates functionality already available through opencode's built-in tool suite (`edit`, `write`, `read`) and its `tools/run-texted-mcp` script is unused. The `viewport-editor` plugin provides a superior windowed editing experience that opencode's built-in tools do not offer — viewports, staged buffers, diff review, and session isolation.

Also remove the `tools/run-texted-mcp` script which is no longer referenced.

## Problem

The `texted` MCP plugin in `opencode.jsonc` provides MCP tools (`texted_edit_file`, `texted_texted_doc`, `texted_texted_eval`) that duplicate functionality already available through opencode's built-in tool suite. The `tools/run-texted-mcp` script is not referenced anywhere else in the configuration.

However, there is a genuine need for an advanced editing MCP server that provides:

- **Viewport-based editing**: Focused windows into files with scoped replaces (unlike blind whole-file string matching)
- **Staged buffers**: Edit without writing to disk, review diff before save
- **Session isolation**: Multiple agent sessions editing the same file without collision
- **Delta diffs**: Compare against original file on disk, not last save

The `viewport-editor` MCP server fills this gap. It was designed precisely for complex editing workflows where the simplicity of opencode's built-in tools falls short.

## Change

Two operations:

1. **`opencode.jsonc`** — Replace the `"texted"` MCP plugin block with a `"viewport-editor"` MCP plugin block using `uvx` from the GitHub release tag.

2. **`tools/run-texted-mcp`** — Delete this file entirely (unused script).

### Current texted Block

```jsonc
"texted": {
  "type": "local",
  "command": [".opencode/tools/run-texted-mcp"],
  "enabled": true
}
```

### New viewport-editor Block

```jsonc
"viewport-editor": {
  "type": "local",
  "command": ["uvx", "--from", "git+https://github.com/michael-conrad/viewport-editor@v0.2.0", "viewport-editor"],
  "enabled": true
}
```

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | The `"texted"` block is removed from the `mcp` section of `opencode.jsonc` | `string` |
| SC-2 | A `"viewport-editor"` block exists in the `mcp` section of `opencode.jsonc` with the correct `uvx` command | `string` |
| SC-3 | The file `.opencode/tools/run-texted-mcp` does not exist after implementation | `structural` |
| SC-4 | `opencode.jsonc` remains valid JSONC syntax after the change | `string` |

## Affected Files

- `opencode.jsonc` — Replace `"texted"` MCP plugin block with `"viewport-editor"` MCP plugin block
- `.opencode/tools/run-texted-mcp` — Delete this unused script

## Relationship to Existing Tools

The `viewport-editor` complements the built-in Read/Edit/Write tools — it does not replace them. As documented in its README:

> **Built-in Read/Edit/Write**: Coexist. Use for simple whole-file operations. Use viewport-editor for complex editing.

This is consistent with the MCP tool usage hierarchy (see `mcp-tool-usage` skill): built-in tools remain Tier 1 for simple operations, while `viewport-editor` provides Tier 2+ capability for complex, windowed editing workflows.

---

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
