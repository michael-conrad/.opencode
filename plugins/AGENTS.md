# AGENTS.md — Plugin Development Guide

## V2 Plugin Contract

OpenCode V2 plugins **default-export** a definition created by `Plugin.define`:

```typescript
import { Plugin } from "@opencode/plugin";

export default Plugin.define({
  id: "my-plugin", // stable id — storage and diagnostics are scoped by it
  async setup(ctx) {
    // register hooks, transforms, and subscriptions here
  },
});
```

The V2 plugin API intentionally replaces the V1 contract: V1 plugin
implementations — named exported functions returning a hooks object — do not
load in V2 (the loader requires `Plugin must export a default definition with
an id and an effect or setup function`). There is no V1 fallback.

`Plugin` comes from the `@opencode/plugin` module, which the OpenCode runtime
provides at plugin load time — it is not installed from npm as a dependency of
a local file plugin.

## Plugin Context

`setup(ctx)` receives the V2 plugin context — domain objects grouped by
concern, options on `ctx.options`, and a cleanup function returned by `setup`.

| Surface | Purpose |
|---------|---------|
| `ctx.location.directory` | Directory of the location the plugin loaded at |
| `ctx.location.project` | Project of that location |
| `ctx.options` | Plugin options from config |
| plugin-return / cleanup | Function returned from `setup` runs at unload (timers, subprocesses, sockets) |
| registration.dispose() | Remove a single hook/transform early |

## Available Hooks

V2 registers each hook on the domain that owns the operation; the callback
receives one mutable event instead of separate input/output objects.

| Hook | Purpose |
|------|---------|
| `ctx.shell.hook("create.before", (event) => ...)` | Inject environment variables into shell sessions (`event.env[key] = value`) |
| `ctx.event.subscribe(...)` | Subscriptions on the server event stream |
| `ctx.session.hook("context", (event) => ...)` | Agent-loop model-request context — edit `event.system` (system parts, `{ type: "text", text }`) and `event.messages` |
| `ctx.tool.hook("execute.before", ...)` / `"execute.after"` | Tool execution gates |

Keep supporting modules beside the plugin file. Local plugins are
auto-discovered from `.opencode/plugins/*.ts` files and directories;
configured paths in the `plugins` config array must name directories.

## Testing Guidance

- Use `with-test-home opencode run "test"` to verify the plugin loads without errors
- Confirm the plugin's `id` and source appear in the active plugin list — `opencode api get "/api/plugin?..."` — with `status: "active"`
- Check the server log for V2 load errors: a plugin missing the default definition fails with `Plugin must export a default definition with an id and an effect or setup function`
- Behavioral tests for plugins go in `.opencode/tests-v2/behaviors/`

---

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
