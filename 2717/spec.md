# [SPEC] Port deck to the OpenCode V2 API (plugins + config + agent files + harness binary)

## Problem

The deck carries V1-era implementations in several surfaces. Under OpenCode V2
(≥ 2.2.x), the two live plugins fail to load on every server start and config
hot-reload at this deck's location:

```
timestamp=2026-11-05T23:44:23.014Z level=WARN run=ebe6eb05 message="failed to load plugin" target=/home/muksihs/git/.opencode/plugins/env-loader.ts cause="PluginModule.LoadError: Plugin must export a default definition with an id and an effect or setup function"
timestamp=2026-11-05T23:44:24.434Z level=WARN run=ebe6eb05 message="failed to load plugin" target=/home/muksihs/git/.opencode/plugins/session-enforcement.ts cause="PluginModule.LoadError: Plugin must export a default definition with an id and an effect or setup function"
```

Consequences observed today (2026-11-05, opencode v2.2.0/v2.2.5):

- `.env` file variables are not injected into any shell session in any workspace project served by the deck (env-loader inactive).
- Session-init context is not injected into any system prompt, and synthetic mode-switch messages are not stripped (session-enforcement inactive).
- The failure repeats on every server start and every plugin reload — the plugins are permanently dead under V2.

`/api/plugin?location[directory]=/home/muksihs/git` (live check, 2026-11-05) lists both
deck plugins with `status: "failed"` and the exact error above — the observed RED state.

The deck's own plugin guide is also stale: `plugins/AGENTS.md` ("Named Export
Requirement") mandates V1 named exports and states `export default` is not
supported — the exact opposite of the V2 loader contract that today's live
error text proves (`Plugin must export a default definition with an id and an
effect or setup function`). Following the guide produces plugins that cannot load.

Additional V1→V2 upgrade surfaces in this deck (verified live 2026-11-05):

- `opencode.jsonc` is wholly in the V1 shape: `"agent"` map with `prompt`,
  `"permission"` map, `"mcp"` server map with `enabled`, and `"plugin": []`.
  V2 normalizes these in memory (verified via `/api/config`), but the file
  remains dependent on legacy translation, which produces the legacy-field
  warning surface and is the shape the migration guide marks for conversion.
- File-based agents use V1 frontmatter: `agent/notebook-ops.md`,
  `agents/email-ops.md`, `agents/math-ops.md`, `agents/visual-design-agent.md`
  all carry `permission` in V1 map form (auto-translated, deprecated V1 shape,
  warned when mixed formats appear). `agent/notebook-ops.md` also uses the
  V1-preferred `agent/` directory instead of V2's `agents/`.
- The behavioral harness's host tier hard-requires
  `.tools/opencode/opencode` at the workspace root (the `with-test-home`
  copy source — the wrapper resolves `PROJECT_DIR` to the workspace root) —
  `with-test-home` exits `FATAL: standalone binary not found` when absent,
  and the binary that surface carried was the V1 1.18.3 build, which rejects
  native V2 config keys outright (observed live 2026-11-06:
  `Unrecognized keys: agents, permissions, plugins`). It is a semantic
  blocker, not just a missing convenience: the binary the harness copies
  must be a **V2** binary (≥ 2.2) or the behavioral scenarios cannot
  exercise plugin loading under V2 at all. Today the harness cannot run
  host-tier at all against converted V2 config.

## Root cause

OpenCode V2 intentionally changed:
1. the plugin API (migration guide:
   https://opencode.ai/v2/docs/build/plugins/migrate-v1 — "V1 plugin
   implementations do not run in V2"); V2 requires a default export of
   `Plugin.define({ id, setup(ctx) })`, the V1 exported named async
   functions returning a hooks object;
2. the configuration surface (https://opencode.ai/v2/docs/migrate-v1 —
   `agent` → `agents` (`prompt` → `system`), `permission` map → `permissions`
   ordered rules, `plugin` → `plugins`, `mcp` servers grouped under
   `mcp.servers` with `enabled` → `disabled`, `snapshot` → `snapshots`,
   `attachment` → `media`);
3. agent file frontmatter (V1 fields deprecated but translated; V2 native
   shape is `permissions` list, `agents/` the preferred directory);
4. the server API and clients (breaking change — scripts calling the V1
   server API or SDK must migrate; verified: the deck currently calls none).

The plugin guide in the same directory documents the V1 contract and was
never revised when V2 landed. The harness's standalone-binary provisioning
surface was never populated with a V2 binary.

## Scope

Port the deck's V1-era surfaces to the V2 API in place:

1. `plugins/env-loader.ts` and `plugins/session-enforcement.ts` to the V2
   plugin API, preserving their V1 behaviors where V2 exposes the mechanism.
2. `plugins/AGENTS.md`'s plugin-contract guidance to the V2 shape.
3. `opencode.jsonc` to the native V2 configuration shape, preserving every
   setting's effective value.
4. The four file-based agent definitions to native V2 frontmatter and the
   preferred `agents/` location.
5. The harness's standalone binary provisioning surface gets a V2 binary at
   the workspace root's `.tools/opencode/opencode`.
   No conversion to directory form is required for the two plugins: V2
   auto-discovers `.opencode/plugins/*.ts` files (log evidence: both files
   appear as discovered plugin entrypoints with
   `entrypoint=…plugins/env-loader.ts`), and both plugins load via location
   auto-discovery, not via a `plugins` config entry — so a configured entry
   is unnecessary; `opencode.jsonc`'s `"plugin": []` becomes `"plugins": []`
   under the V2 key.

## Approach

Chosen: in-place V2 ports using the mapping the migration guides define,
verified today against the live API and logs by the vacuum-retention port in
the user config (`~/.config/opencode/plugins/vacuum-retention/`), which
loads and reports `active` after the same conversion.

### Plugin port mapping

| V1 surface (in these plugins) | V2 surface |
|---|---|
| named exported plugin function returning hooks | `export default Plugin.define({ id, async setup(ctx) {…} })` |
| `directory` / `worktree` destructured inputs | `ctx.location.directory` (V2 exposes no V1-style `worktree` input on the plugin context) |
| `shell.env` hook (`output.env[key] = value`) | `ctx.shell.hook("create.before", (event) => { event.env[key] = value })` |
| `experimental.chat.system.transform` (`output.system.push(string)`) | `ctx.session.hook("context", (event) => { event.system.push({ type: "text", text }) })` |
| `experimental.chat.messages.transform` (`output.messages`) | `ctx.session.hook("context", (event) => { event.messages … })` |
| no-op for plugin lifecycle cleanup | cleanup function returned from `setup` |

### Configuration conversion mapping

| V1 surface (in `opencode.jsonc`) | V2 native surface |
|---|---|
| `"plugin": []` | `"plugins": []` |
| `"agent": { "build": {"prompt": …}, "plan": {"prompt": …} }` | `"agents": { "build": {"system": …}, "plan": {"system": …} }` — `{file:./prompts/default.txt}` substitution keeps its V1 semantics in the native shape |
| `"permission": { "gmail_*": "deny", … }` | `"permissions": [ {"action":"gmail_*","resource":"*","effect":"deny"}, … ]` |
| `"mcp": { "<name>": { …, "enabled": true } }` | `"mcp": { "servers": { "<name>": { …, "disabled": false } } }` — `enabled: true` maps to `disabled: false`; per-server `environment` and `command` keep their shapes |

### Agent-file conversion mapping

| V1 surface (in agent files) | V2 native surface |
|---|---|
| `permission:` map frontmatter (`"gmail_*": allow`) | `permissions:` list frontmatter (`- action: gmail_*` / `resource: "*"` / `effect: allow`) |
| `agent/notebook-ops.md` location | moved to `agents/notebook-ops.md` (preferred V2 location; `agent/` still discovered, path-derived ID preserved) |
| `description:`, `mode:`, markdown body | keep their names; the body remains the system prompt |

Alternatives considered and discarded:

- Re-expressing both plugins as one combined V2 plugin: rejected — the two
  files own deliberately separate concerns ("no cross-plugin coupling" per
  their headers), the V1 file boundaries are the deck's reviewed structure,
  and merging adds review surface without fixing the stated problem.
- Keeping the files unchanged and registering them via a V2 `plugins` config
  entry: rejected — the config path is not the defect (they auto-discover
  today); the export shape is, and configured paths must be directories
  while these are files.
- Dropping session-enforcement's per-request `session-init` invocation in
  favor of a run-once cache: rejected as unrequested behavior change — V1 ran
  the transform per model request and the V2 `context` hook preserves that
  frequency; caching is a separate optimization, out of scope.
- Leaving `opencode.jsonc` and the agent files in V1 shape because "V2
  normalizes them anyway": rejected — the normalization is deprecated
  translation still carrying a warning surface, the migration guide names
  native conversion as the supported path, and the deck's own guide surfaces
  (e.g. agent file frontmatter docs that agents carry `permission` maps)
  would keep teaching the V1 shape. Conversion preserves behavior (verified:
  the in-memory normalized view already equals the native target shape).

## Requirements

- **R-1.** `env-loader.ts` and `session-enforcement.ts` SHALL export a V2
  plugin via `export default Plugin.define({ id, setup })` (imported from the
  runtime-provided `@opencode/plugin` module) with stable ids `env-loader`
  and `session-enforcement`, and no named plugin-function exports.
- **R-2.** env-loader SHALL preserve its `.env` parsing semantics exactly
  (blank/`#` lines skipped; first `=` splits key/value; empty keys skipped;
  unquoted values have ` #` inline comments stripped; quoted values are
  literal and unquoted; duplicate keys: last value wins) and SHALL inject
  every parsed key into the shell-session environment of every bash session
  at its location via the V2 shell-domain hook equivalent of V1 `shell.env`.
- **R-3.** The `WORKTREE_PATH` environment injection SHALL be removed from
  the shell-environment hook. Grounds: the V1 `worktree` plugin input has no
  V2 equivalent on the plugin context (V2 exposes `ctx.location.directory`,
  optional `workspaceID`, and project metadata — no worktree field;
  migration guide URL above), and no functional consumer exists in this
  repository. The one live non-attic reference is documentary: the
  `tools/session-init` script header's "Canonical env-loader variable names"
  list names `WORKTREE_PATH` (verified 2026-11-05 — the script reads none of
  those variable names from its inherited environment; the list documents
  the env-loader pipeline for readers). That reference SHALL be updated in
  the same change — the list drops `WORKTREE_PATH` — which is a comment-only
  edit to `tools/session-init`; no functional change to that script is
  authorized here. env-loader's own header and comment lines presenting the
  worktree input cease to present the removed input: the R-1 port rewrites
  the plugin's header, and no post-port non-attic file text may still
  document `WORKTREE_PATH` as an injected variable.
- **R-4.** session-enforcement SHALL run
  `${location.directory}/.opencode/tools/session-init` (execSync,
  cwd = location directory, 10 s timeout, `null` on any failure) and SHALL
  append its trimmed, non-empty output as a `{ type: "text" }` part to
  `event.system` via `ctx.session.hook("context", …)`, preserving V1's
  per-model-request invocation frequency in the agent loop.
- **R-5.** session-enforcement SHALL — in the same `context` hook, over
  `event.messages` — locate the last user message and, for each of its text
  parts flagged `synthetic: true` whose text contains
  `Your operational mode has changed from` or
  `# Plan Mode - System Reminder`, blank the text and clear the synthetic
  flag, preserving the V1 pattern set verbatim.
- **R-6.** `plugins/AGENTS.md` SHALL document the V2 plugin contract as its
  sole operative contract: plugins are
  `export default Plugin.define({ id, setup(ctx) })`; the context is the V2
  plugin context (`ctx.*` domains, options via `ctx.options`, cleanup via
  the function `setup` returns); the hook surface is documented with V2 hook
  names — `ctx.shell.hook("create.before", …)`, `ctx.event.subscribe(…)`,
  `ctx.session.hook("context", …)`; and the file SHALL NOT present any V1
  contract as operative: no named-export mandate, no `@opencode-ai/plugin`
  import presented as the contract source, no destructured
  `{project, client, $, directory, worktree}` signature presented as the
  current signature, no `PluginInput` mapping table, no V1 hook names as
  operative hook surface, and the string `Plugin export is not a function`
  does not appear. Testing-guidance content that carries no plugin contract
  may remain. This revision is deck-content governance and routes through
  the deck-governance card at implementation.
- **R-7.** No unrelated refactoring: the existing helper functions
  (`parseEnvFile`, `stripInlineComments`, `runSessionInit`,
  `isModeSwitchSynthetic`), the file paths, and the redaction-delegation
  note in session-enforcement's header SHALL be preserved. Header and
  comment documentation changes are limited to what R-1 (V2 port facts) and
  R-3 (the removed worktree input) require.
- **R-8.** `opencode.jsonc` SHALL be converted to the native V2
  configuration shape per the configuration-conversion mapping above, and
  every converted entry SHALL preserve its effective value: the `build` and
  `plan` agents keep the `{file:./prompts/default.txt}`-sourced system
  prompt; the three permission denials keep their actions and effects; the
  four MCP servers keep their commands, environments, and enabled states;
  and every other setting in the file (`instructions`, `$schema`) is
  untouched. The converted file may not depend on V1 normalization for any
  key it owns: no `"agent"`, `"permission"`, `"plugin"`, or `"enabled"` keys
  remain (except where a V2 native field's name coincides).
- **R-9.** The four file-based agent definitions SHALL be converted to the
  native V2 file format: frontmatter uses only V2 fields (`description`,
  `mode`, `permissions` list — `permission` map, `prompt`, `tools`,
  `disable`, and other V1 frontmatter fields do not appear); the Markdown
  body stays the system prompt with its provenance header preserved; and
  `agent/notebook-ops.md` moves to `agents/notebook-ops.md` with its
  path-derived ID (`notebook-ops`) preserved. Each file converts wholly to
  one format (no V1/V2 mixed frontmatter in one file).
- **R-10.** The harness's standalone binary SHALL be a V2 binary:
  `.tools/opencode/opencode` at the workspace root (the `with-test-home`
  copy source — the wrapper resolves `PROJECT_DIR` to the workspace root)
  SHALL exist and SHALL report version `>= 2.2` (via `--version`), so the
  harness's host-tier copy step serves a V2 binary and behavioral scenarios
  exercise V2 plugin loading. The V1 binary the surface carried is the
  instrument-level defect that makes behavioral scenarios unable to exercise
  V2 semantics the V1 runtime lacks (observed live 2026-11-05/06: the
  1.18.3 binary rejected the converted deck config with
  `Unrecognized keys: agents, permissions, plugins` while 2.2.x loads it).
  Provisioning routes through the official install channel (a vendor-provided
  release binary fetched into `.tools/opencode/` by the agent); the snapshot
  isolation mechanics (`SNAP_USER_DATA` override against a snap binary) are
  NOT relied upon — the provided binary is a standalone extraction, not a
  snap wrapper. `.tools/` is gitignored in its repos like the z3 and
  playwright vendoring precedent, so this surface is machine-local
  provisioning, not a tracked deliverable.
- **R-11.** No deck script, tool, or fixture may call the V1 server API:
  the deck's scripts/tools/tests carry no V1 server/SDK usage today
  (verified 2026-11-05 by repository scan — no `createOpencodeClient`, no
  V1 endpoint paths, no `OPENCODE_SERVER_USERNAME`), and this change
  introduces none.
- **R-12.** The behavioral harness's session-store reading SHALL understand
  the OpenCode V2 store schema: under V2 (≥ 2.2) the session record lives in
  `session_v2`/`session_message` (rich per-message JSON with `content[]`
  parts) and the V1 `event` table is empty (observed live 2026-11-06: the
  SC-2 run's store had 0 event rows while an agent turn with tool calls and
  outputs was fully recorded in `session_message`). The harness SHALL read
  the V2 store through one adapter definition (`behaviors/v2rows.py`) that
  emits the V1-shaped event stream (`session.created.1`,
  `message.part.updated.1` with `part`, `message.updated.1` with `info`) at
  every consumption surface — the `session.yaml` exporter (plus a `part`
  table for the timeline tool), the digest/monitor live readers, the
  finish-state reader, the resume-tail reader, and `poll-run.sh` — and SHALL
  pass V1 stores through unchanged. Every V1-shaped consumer keeps its
  contract; no consumer learns the V2 schema directly.

## Impact

- Blast radius: every OpenCode session whose location chain resolves to
  **this checkout** of the deck regains active env-loader and
  session-enforcement behavior on V2 — today's log already shows the
  checkout's plugin files being auto-discovered from location
  `/home/muksihs/git`, and V2 discovers location plugins by walking the
  location chain (documented discovery behavior). Today those sessions run
  with both plugins silently absent. One dependent surface stays outside
  this change's reach and is named, not silent: the deck is also embedded at
  a pinned commit (`c0e423ad…`) as a submodule in the separate
  `opencode-config` repository
  (`/home/muksihs/git/opencode-config/.opencode/plugins/…`), whose plugin
  copies auto-load at locations beneath it and fail today with the identical
  signature (opencode.log 2026-11-05T23:49:58). Sessions served through that
  checkout are NOT repaired by this spec's port — they regain the behavior
  only when that repository's submodule pointer is bumped (out of scope,
  below).
- Behavior changes shipped with the port: exactly one — `WORKTREE_PATH`
  (R-3) is no longer injected in worktree sessions. Its removal is a
  V2-forced consequence; its single deck-internal reference (the
  `tools/session-init` header's canonical-name list) is updated by R-3 in
  the same change, so no deck documentation is left asserting the dropped
  injection. External consumers, if any exist, would observe its absence and
  can derive an equivalent value from their own location.
- The config and agent-file conversions change no effective behavior: the
  in-memory normalized view `/api/config` and `/api/agent` produce today
  (verified 2026-11-05) already equals the native target shapes — conversion
  moves the on-disk files onto the supported native path the V1 translation
  was reconstructing.
- Risk of the change itself is bounded and observable: a failed port leaves
  the plugin at `status: "failed"` with the load error surfaced on the same
  API surface SC-1 checks.
- Test surface: `tests-v2/behaviors/` gains scenarios for the preserved
  behaviors (SC-2 through SC-4) and the config/agent-file upgrade checks
  (SC-6 through SC-8). The deck guide's testing guidance remains otherwise
  applicable.

## Success criteria

| ID | Criterion | Class | Instrument |
|---|---|---|---|
| SC-1 | After a V2 server start or config reload at the deck's location, the deck's `env-loader` and `session-enforcement` plugins are loaded and active. | Behavioral (runtime effect) | `opencode api get "/api/plugin?location[directory]=/home/muksihs/git"` lists `env-loader` and `session-enforcement` with `status: "active"` — the same surface that today lists them `status: "failed"` with the exact load error, so the one check observes both satisfaction and violation of the criterion, scoped to the deck's own location only. |
| SC-2 | A bash session at a location holding a `.env` file observes every declared key (verified with a sentinel key/value) in its environment. | Behavioral (runtime effect) | `tests-v2` behavioral scenario: test project with a sentinel `.env` pair; run a bash command echoing the sentinel key; assert the value appears in command output. |
| SC-3 | The session-init tool's output appears as a text part in the system context of agent-loop model requests. | Behavioral (runtime effect) | `tests-v2` behavioral scenario: session-init emits a sentinel line; assert the agent's received instructions contain it. |
| SC-4 | A synthetic mode-switch user message matching either preserved pattern is neutralized (text blanked, synthetic flag cleared) in the model-visible context of the agent loop. | Behavioral (runtime effect) | `tests-v2` behavioral scenario: inject a synthetic mode-switch message; assert its mode-switch text is not visible to the agent while other input survives. |
| SC-5 | `plugins/AGENTS.md` states the V2 plugin contract as operative guidance (`Plugin.define` default export, V2 context, V2 hook names) and presents none of the V1 contract surfaces as operative. | Structural | Content check: the file contains `Plugin.define`, `ctx.shell.hook`, `ctx.event.subscribe`, and `ctx.session.hook`; and contains none of `MUST use **named exports**`, `@opencode-ai/plugin`, `PluginInput`, `experimental.chat.system.transform`, `experimental.chat.messages.transform`, `Plugin export is not a function`, and does not present `{project, client, $, directory, worktree}` as the plugin signature. |
| SC-6 | The deck's `opencode.jsonc` is in native V2 config shape and loads under V2 with behavior preserved and no legacy-translation warnings for the deck's config keys. | Behavioral (runtime effect) + Structural | Two-part instrument: (a) content check — the file contains `agents` (with `system`), `permissions` rules list, `mcp.servers`, and `plugins`; and contains none of the V1 keys `"agent"`, `"permission"`, `"plugin"`, or the V1 `"enabled"` MCP field; (b) behavioral — a V2 server start at the deck's location shows no legacy/malformed-field warning naming the deck's config file in the server log, and `/api/config` (deck location) and `/api/agent` (deck location) show the preserved effective values: `build`/`plan` `system` contains the `{file:}`-sourced prompt content, the three denials present as ordering-equivalent V2 rules, the four MCP servers carry their commands with `disabled: false`, and `plugins` is empty. |
| SC-7 | The four file-based agent definitions are read as V2 by the loader with native frontmatter, and their permission behavior is preserved. | Behavioral (runtime effect) + Structural | Two-part instrument: (a) content check — each of `agents/notebook-ops.md`, `agents/email-ops.md`, `agents/math-ops.md`, `agents/visual-design-agent.md` uses only V2 frontmatter fields (`description`, `mode`, `permissions` list); `agent/` no longer holds agent files (it may hold non-agent content if any exists — today it holds none besides the moved file); (b) behavioral — after a V2 server start at the deck's location, `/api/agent` lists all four agents (IDs `notebook-ops`, `email-ops`, `math-ops`, `visual-design-agent`) with their bodies as `system`, and no legacy-frontmatter warning names those files in the server log. Permission behavior (subagent-side `gmail_*`/`math_*`/`the-notebook-mcp_*` allow, main-side deny) carries over by the converted rules' equality with the prior normalized rules — asserted as part of (b)'s API listing state. |
| SC-8 | The harness's standalone binary is a V2 binary and the host-tier harness runs. | Behavioral (runtime effect) + Structural | Two-part instrument: (a) structural — the workspace root's `.tools/opencode/opencode` exists, is executable, and `--version` reports `>= 2.2`; (b) behavioral — the harness's own copy path serves it: `bash .opencode/tests-v2/with-test-home --setup` completes its smoke tests (`$TEST_HOME/bin/opencode --version` reports `>= 2.2`), producing a working test home. |
| SC-9 | The harness reads a V2 session store correctly: a monitored run's export carries the run's own fresh session and full part stream, and its isolation verdict is PASS. | Behavioral (runtime effect) + Structural | Two-part instrument: (a) structural — `v2rows.py` exists and is the only V2-schema-aware reading surface (the four documented SQL event readers, the exporter, and `poll-run.sh` route through it, no `SELECT … FROM event` remains where a V2 store is read); (b) behavioral — a monitored run (the SC-2 scenario) produces `session.yaml` whose `tables.event.rows` are non-empty and contain the run's `session.created.1` and its `message.part.updated.1` parts (tool-call parts with state/input, text parts), and `session-isolation.yaml` reads `verdict: PASS`. |

Criteria notes: SC-1's instrument detects the defect class that produced this
spec (loader rejection), SC-2 through SC-4 are the preserved-behavior guards
(the unchanged behavior this change puts at risk), SC-5 closes the guide
conflict that manufactured the regression risk, and SC-6 through SC-8 close
the remaining V1→V2 upgrade surfaces enumerated in the problem and requirements
(legacy config translation dependence, V1 agent frontmatter, missing V2
standalone binary), and SC-9 closes the V2 session-store schema surface
(R-12 — the store the harness reads changed shape under V2; observed live:
the SC-2 run's `event` table empty while its session carried full part
data in `session_message`). Behavioral scenarios are authored and executed per the
behavioral-testing card's harness rules.

## Out of scope

- The `/vacuum` TUI plugin and the retention plugin in `~/.config/opencode/`
  (filed and handled outside this repository; the retention plugin's V2 port
  is already delivered and verified there).
- The user-level config `~/.config/opencode/opencode.jsonc` — a different
  repository's checkout; its configuration is already in native V2 shape
  (verified live 2026-11-05 via `/api/config`).
- The vibeguard redaction plugin referenced by session-enforcement's header
  documentation.
- Bumping the `opencode-config` repository's submodule pointer to this deck —
  a change in a different repository; until it lands, the plugin copies
  pinned there keep failing at locations under `/home/muksihs/git/opencode-config`.
- Functional changes to `.opencode/tools/session-init` (its output format,
  behavior, or guards); the R-3 docstring-list edit is the only permitted
  touch on that file.
- New plugin capabilities (options, storage, additional hooks) beyond the
  V1 behavior preserved here.
- Merging the two plugins into one package; changing V2 plugin
  auto-discovery layout to directory form.
- Terminal-client (`tui.json` → `cli.json`) configuration: the deck holds no
  `tui.json` files (verified by repository scan), so nothing in this
  repository migrates the client config.

> Full spec and plan artifacts: https://github.com/michael-conrad/.opencode/tree/issues-data/2717/
> Agent-facing artifacts pointer: `.opencode/.issues/2717/`

---

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
