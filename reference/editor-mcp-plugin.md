<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->
---
trigger_on: editor MCP, editor plugin, viewport-editor, viewport, staged buffer, MCP plugin
tier: 2
load_when: sub-agent
---

# editor MCP Plugin

> Canonical home for the editor MCP plugin reference (demoted from [`.opencode/AGENTS.md`](../AGENTS.md), #2427 scope E). Reach this content through the one-line pointer retained in AGENTS.md.

## Overview

This repo uses [editor](https://github.com/michael-conrad/viewport-editor) as its editing MCP server.

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

## Recommended Agent Behavior

- Use `read_file`, `write_file`, `edit_text`, `find_text` for single-call operations
- Use `viewport` + `edit` + `file` for multi-step editing with diff review
- Always call `diff:show` before `file:save` to verify staged changes
- File paths are relative to project root (MCP resolver defaults to `os.getcwd()`)
- Conflict detection: server tracks file mtime+size externally; stale-file soft warning on reads, hard block on `file:save` (use `force: true` override if change is intentional)

---

*Co-authored with AI: OpenCode (ollama-cloud/glm-5.3-flash)*
