# AGENTS.md — Plugin Development Guide

## Named Export Requirement

OpenCode plugins MUST use **named exports** — `export default` is not supported. The plugin system iterates over module exports looking for named function exports; `export default` creates a `default` key on the module, which the loader does not find.

```typescript
// ✅ CORRECT — named export
export const MyPlugin: Plugin = async ({ project, client, $, directory, worktree }) => { ... };

// ❌ WRONG — export default is not detected by the plugin loader
export default async function myPlugin(input: PluginInput) { ... }
```

## Plugin API Signature

The `Plugin` type is imported from `@opencode-ai/plugin`:

```typescript
import type { Plugin } from "@opencode-ai/plugin";
```

The plugin function receives a destructured context object:

| Field | Type | Purpose |
|-------|------|---------|
| `project` | `string` | Project name |
| `client` | `object` | API client for opencode operations |
| `$` | `object` | Shell/git utility (`$.nothrow` for non-throwing command execution) |
| `directory` | `string` | Project directory path |
| `worktree` | `string` | Worktree directory path (empty string if not in worktree) |

The function returns a `Hooks` object with hook implementations.

## Context Mapping

When migrating from `PluginInput` to the destructured context:

| Old (`PluginInput`) | New (destructured) |
|---------------------|-------------------|
| `input?.directory` | `directory` |
| `input?.worktree` | `worktree` |
| `input.$.nothrow` | `$.nothrow` |

## Available Hooks

| Hook | Purpose |
|------|---------|
| `shell.env` | Inject environment variables into shell sessions |
| `event` | Handle lifecycle events (discriminate by `event.type`) |
| `experimental.chat.system.transform` | Inject content into system prompt |
| `experimental.chat.messages.transform` | Transform user/assistant messages |

## Testing Guidance

- Run `tsc --noEmit` to verify TypeScript compilation before testing
- Use `with-test-home opencode-cli run "test"` to verify the plugin loads without errors
- Check stderr for `Plugin export is not a function` — if present, the export style is wrong
- Behavioral tests for plugins go in `.opencode/tests/behaviors/`

---

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
