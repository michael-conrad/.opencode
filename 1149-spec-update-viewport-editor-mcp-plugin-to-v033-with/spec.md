## Objective

Update the viewport-editor MCP plugin to the latest release (v0.3.3) and add the prescribed AGENTS.md activation stanza per the project's "Consuming Repo Instructions".

## Background

viewport-editor v0.3.3 was released 2026-06-12. The project's README includes a "Consuming Repo Instructions" section that prescribes exactly what a parent repo needs to do:

1. Pin the version in `opencode.jsonc`
2. Add a specific AGENTS.md stanza documenting the 11-tool surface and recommended agent behavior

Current state: pinned at `@v0.2.0` in `opencode.jsonc`, no viewport-editor references in `AGENTS.md`.

## Files Affected

| File | Change |
|------|--------|
| `opencode.jsonc` | Update `@v0.2.0` → `@v0.3.3` in viewport-editor MCP command |
| `AGENTS.md` | Add viewport-editor activation stanza per project's prescribed format |

## AGENTS.md Stanza

Per the viewport-editor README "Consuming Repo Instructions", add the following to `AGENTS.md`:

```markdown
### viewport-editor MCP Plugin

This repo uses [viewport-editor](https://github.com/michael-conrad/viewport-editor) as its editing MCP server.

**11-tool surface** (see README for full action lists):

| Tool | Purpose |
|------|---------|
| **viewport** | Open, navigate, and manage focused editing windows |
| **edit** | Stage text changes into viewport buffers (replace, insert, delete, swap, move) |
| **file** | Commit or discard staged changes to disk |
| **diff** | Show unified diffs of pending edits before saving |
| **clipboard** | Copy/cut/paste content across viewports with provenance tracking |
| **search** | Find text with substring or regex matching |
| **regex** | Test and escape regex patterns |
| **read_file** | Composite: open + scroll — preferred over built-in `read` for single-call reading |
| **write_file** | Composite: open + replace-all + save — preferred over built-in `write` for conflict-safe writing |
| **edit_text** | Composite: open + replace + save — preferred over built-in `edit` for targeted changes with conflict detection |
| **find_text** | Composite: search — preferred over built-in `grep` for structured results |

**Recommended agent behavior:**

- Use `read_file`, `write_file`, `edit_text`, `find_text` for single-call operations
- Use `viewport` + `edit` + `file` for multi-step editing with diff review
- Always call `diff:show` before `file:save` to verify staged changes
- File paths are relative to project root (MCP resolver defaults to `os.getcwd()`)
- Conflict detection: server tracks file mtime+size externally; stale-file soft warning on reads, hard block on `file:save` (use `force: true` override if change is intentional)
```

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | opencode.jsonc viewport-editor MCP command references `@v0.3.3` | `string` |
| SC-2 | AGENTS.md contains the viewport-editor activation stanza with 11-tool table | `string` |
| SC-3 | AGENTS.md contains recommended agent behavior section for viewport-editor | `string` |

## Source Material

- viewport-editor README "Consuming Repo Instructions": https://github.com/michael-conrad/viewport-editor#consuming-repo-instructions
- viewport-editor v0.3.3 release: https://github.com/michael-conrad/viewport-editor/releases/tag/v0.3.3

---

*Co-authored with AI: OpenCode (deepseek-v4-flash)*