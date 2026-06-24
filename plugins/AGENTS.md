# AGENTS.md — Plugin Development Guide

This file documents the requirements for creating and maintaining opencode plugins in `.opencode/plugins/`. All rules are derived from the official opencode plugin documentation at https://opencode.ai/docs/plugins/.

## Plugin Structure

### Export Pattern (MANDATORY)

Plugins MUST use a **named export** — never `export default`. The plugin system iterates over module exports looking for named function exports; `export default` is a `default` key on the module, not a named export, and will fail to load.

```typescript
// ✅ CORRECT — named export
import type { Plugin } from "@opencode-ai/plugin";

export const MyPlugin: Plugin = async ({ project, client, $, directory, worktree }) => {
  return {
    "shell.env": async (input, output) => {
      // hook implementation
    },
  };
};

// ❌ WRONG — default export (will not load)
export default async function myPlugin(input: PluginInput): Promise<Hooks> {
```

### Plugin Function Signature

The plugin function receives a destructured context object:

| Property | Type | Description |
|----------|------|-------------|
| `project` | `Project` | Current project information |
| `directory` | `string` | Current working directory |
| `worktree` | `string` | Git worktree path |
| `client` | SDK client | For interacting with the AI (e.g., `client.app.log()`) |
| `$` | `BunShell` | Bun's shell API for executing commands |

### Return Type

The function returns a `Hooks` object. The return type is inferred from the `Plugin` type — do not explicitly annotate the return type.

### TypeScript

Import types from `@opencode-ai/plugin`:

```typescript
import type { Plugin } from "@opencode-ai/plugin";
```

### Part Type (Union)

The `Part` type (from `@opencode-ai/sdk`) is a **discriminated union** — not a single interface. Each variant has a `type` field:

| Variant | `type` | Key Properties |
|---------|--------|----------------|
| `TextPart` | `"text"` | `text`, `synthetic?`, `ignored?` |
| `ReasoningPart` | `"reasoning"` | `reasoning`, `signature?` |
| `FilePart` | `"file"` | `source`, `attachments?` |
| `ToolPart` | `"tool"` | `tool`, `result` |
| `StepStartPart` | `"step_start"` | `step` |
| `StepFinishPart` | `"step_finish"` | `step` |
| `SnapshotPart` | `"snapshot"` | `snapshot` |
| `PatchPart` | `"patch"` | `patch` |
| `AgentPart` | `"agent"` | `agent` |
| `RetryPart` | `"retry"` | `retry` |
| `CompactionPart` | `"compaction"` | `compaction` |

**The `synthetic` property exists ONLY on `TextPart`.** Accessing `part.synthetic` on a non-`TextPart` variant causes a TypeScript error. Always narrow the type before accessing variant-specific properties:

```typescript
// ✅ CORRECT — narrow type first
if (part.type === "text") {
  if (part.synthetic) { /* ... */ }
}

// ❌ WRONG — accessing variant-specific property without narrowing
if (!part.synthetic) continue; // TS error on non-TextPart variants
```

## Available Hooks

### Shell Hooks

| Hook | Input | Output | Purpose |
|------|-------|--------|---------|
| `shell.env` | `{ cwd, sessionID?, callID? }` | `{ env: Record<string, string> }` | Inject env vars into shell sessions |

### Tool Hooks

| Hook | Input | Output | Purpose |
|------|-------|--------|---------|
| `tool.execute.before` | `{ tool, sessionID, callID }` | `{ args: any }` | Modify tool args before execution |
| `tool.execute.after` | `{ tool, sessionID, callID, args }` | `{ title, output, metadata }` | Post-process tool output |
| `tool.definition` | `{ toolID }` | `{ description, parameters }` | Modify tool definitions sent to LLM |

### Chat Hooks

| Hook | Input | Output | Purpose |
|------|-------|--------|---------|
| `chat.message` | `{ sessionID, agent?, model?, messageID?, variant? }` | `{ message, parts }` | Called when new message received |
| `chat.params` | `{ sessionID, agent, model, provider, message }` | `{ temperature, topP, topK, maxOutputTokens, options }` | Modify LLM parameters |
| `chat.headers` | `{ sessionID, agent, model, provider, message }` | `{ headers }` | Modify LLM request headers |

### System Hooks

| Hook | Input | Output | Purpose |
|------|-------|--------|---------|
| `system.transform` | — | — | Modify system prompt (deprecated — use `experimental.chat.system.transform`) |

### Experimental Hooks

| Hook | Input | Output | Purpose |
|------|-------|--------|---------|
| `experimental.chat.system.transform` | `{ sessionID?, model }` | `{ system: string[] }` | Modify system prompt |
| `experimental.chat.messages.transform` | `{}` | `{ messages }` | Transform message history |
| `experimental.session.compacting` | `{ sessionID }` | `{ context: string[], prompt? }` | Customize compaction context |
| `experimental.compaction.autocontinue` | `{ sessionID, agent, model, provider, message, overflow }` | `{ enabled: boolean }` | Control auto-continue after compaction |
| `experimental.text.complete` | `{ sessionID, messageID, partID }` | `{ text: string }` | Custom text completion |

### Permission Hooks

| Hook | Input | Output | Purpose |
|------|-------|--------|---------|
| `permission.ask` | `Permission` | `{ status: "ask" \| "deny" \| "allow" }` | Intercept permission prompts |

### Event Hooks

| Hook | Input | Purpose |
|------|-------|---------|
| `event` | `{ event: Event }` (single input, no output) | Subscribe to lifecycle events. Use `event.type` to discriminate (e.g., `"session.created"`, `"session.idle"`, `"session.compacted"`). The `Event` type is from `@opencode-ai/sdk`. |
| `config` | `Config` | Intercept config loading |

**Important:** The `event` hook receives a single `{ event }` input object with NO output parameter. This differs from all other hooks which use `(input, output)` pairs. The `Event` type is imported from `@opencode-ai/sdk`, not from `@opencode-ai/plugin`. To subscribe to a specific event type, discriminate on `event.type`:

```typescript
event: async ({ event }) => {
  if (event.type === "session.created") {
    const sessionID = (event as any).payload?.id;
    // handle session.created
  }
},
```

### Auth/Provider Hooks

| Hook | Purpose |
|------|---------|
| `auth` | Custom auth flows (OAuth, API key) |
| `provider` | Custom model providers |

## Local Dev Tooling

TypeScript compilation and type-checking use project-local tooling in `.opencode/.tools/` (or `.opencode/.node/`). These are system-isolated installations — never use global `node` or `tsc`.

### Type Check

```bash
PATH=.opencode/.tools/node/bin:$PATH npx tsc --noEmit --project .opencode/tsconfig.json
```

Or with the `.node/` fallback path:

```bash
PATH=.opencode/.node/bin:$PATH npx tsc --noEmit --project .opencode/tsconfig.json
```

### Tooling Rules

- Node.js and TypeScript are installed project-locally in `.opencode/.tools/` — never globally
- All invocations use PATH-prefixed commands, never bare `node` or `tsc`
- `.tools/` is in `.gitignore` — never tracked
- Cleanable with `rm -rf .opencode/.tools/`

## Dependencies

Local plugins can use external npm packages. Add a `package.json` to `.opencode/` with the dependencies:

```json
{
  "dependencies": {
    "shescape": "^2.1.0"
  }
}
```

OpenCode runs `bun install` at startup to install these. Plugins can then import them:

```typescript
import { escape } from "shescape";
```

## Load Order

Plugins are loaded in this order:

1. Global config (`~/.config/opencode/opencode.json`)
2. Project config (`opencode.json`)
3. Global plugin directory (`~/.config/opencode/plugins/`)
4. Project plugin directory (`.opencode/plugins/`)

All hooks from all plugins run in sequence.

## Custom Tools

Plugins can add custom tools using the `tool` helper:

```typescript
import { type Plugin, tool } from "@opencode-ai/plugin";

export const CustomToolsPlugin: Plugin = async (ctx) => {
  return {
    tool: {
      mytool: tool({
        description: "Description of the tool",
        args: {
          foo: tool.schema.string(),
        },
        async execute(args, context) {
          return `Result: ${args.foo}`;
        },
      }),
    },
  };
};
```

## Logging

Use `client.app.log()` for structured logging instead of `console.log`:

```typescript
await client.app.log({
  body: {
    service: "my-plugin",
    level: "info", // debug, info, warn, error
    message: "Plugin initialized",
    extra: { foo: "bar" },
  },
});
```

## Verification Checklist

Before submitting a plugin PR, verify:

- [ ] Plugin uses named export (`export const MyPlugin: Plugin = ...`) — NOT `export default`
- [ ] Plugin function signature destructures context: `{ project, client, $, directory, worktree }`
- [ ] Return type is inferred from `Plugin` type — no explicit `Promise<Hooks>` annotation
- [ ] All hook implementations match the correct input/output signatures
- [ ] No TypeScript compilation errors
- [ ] Dependencies declared in `.opencode/package.json` if external packages used
- [ ] SPDX and provenance headers present
- [ ] AI co-authored byline present if AI-generated

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->
<!-- Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash) -->
