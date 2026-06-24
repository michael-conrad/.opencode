# Implementation Plan — [#1370](https://github.com/michael-conrad/.opencode/issues/1370) — env-loader.ts plugin export fix

**Spec: #1370**

- **Goal:** Fix `env-loader.ts` plugin export from `export default` to named export `EnvLoaderPlugin: Plugin` per opencode plugin API, fix TypeScript errors in `session-enforcement.ts`, and create `.opencode/plugins/AGENTS.md` documenting plugin development requirements.
- **Architecture:** Three-phase linear pipeline: (1) env-loader.ts export fix + context mapping + behavioral test, (2) session-enforcement.ts TS fixes (event hook discrimination, `part.synthetic` narrowing), (3) new AGENTS.md documentation file. All phases in one feature branch, one commit per item.
- **Files:**
  - `.opencode/plugins/env-loader.ts` — Phase 1 (export fix, import updates, context mapping)
  - `.opencode/plugins/session-enforcement.ts` — Phase 2 (event hook key, part.synthetic narrowing)
  - `.opencode/plugins/AGENTS.md` — Phase 3 (new file, plugin development docs)

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Phase 1 — Plugin Export Fix: env-loader.ts

**Concern:** Change `env-loader.ts` from `export default` to named export `EnvLoaderPlugin: Plugin`, update imports, map context properties, and verify with behavioral test.

**Files:** `.opencode/plugins/env-loader.ts`

**SCs:** SC-1, SC-2, SC-3, SC-4

**Dependencies:** None

**Entry condition:** Phase 1 is the root phase — no prior dependencies.

**Exit condition:** All Phase 1 items pass RED → GREEN → doublecheck → commit. VbC passes. Phase 1 checkpoint tagged.

### Pre-RED Common

> **Cost-frame reformation:** The orchestrator's context is the most expensive resource in the pipeline. Every byte held costs `byte × remaining_dispatches²`. Sub-agents are disposable context buffers — they read task files fully, analyze source, and burn context freely. Result contracts carry only routing-significant data (status, finding_summary, artifact_path, blocker_reason). Full evidence goes to disk. Professional orchestrators hold routing metadata only — sub-agents do the work.

1. **Create feature branch (**inline**).** `git checkout -b feature/1370-env-loader-export-fix` from `dev`. **→ SC-1, SC-2, SC-3, SC-4, SC-5**

2. **Read current env-loader.ts (**inline**).** Verify current state: `export default async function envLoaderPlugin(input: PluginInput)` at line 216, `import type { Hooks, PluginInput }` at line 22. **→ SC-1, SC-3**

### Per-Item RED+green Chains

#### Item 1.1 — Change export from default to named export

3. **RED (**sub-agent**).** Write structural test: `grep 'export default' .opencode/plugins/env-loader.ts` → match found (RED: default export still present). **→ SC-1, SC-3**

4. **GREEN (**sub-agent**).** Change `export default async function envLoaderPlugin(input: PluginInput): Promise<Hooks>` to `export const EnvLoaderPlugin: Plugin = async ({ project, client, $, directory, worktree }) => {`. Update function signature to destructured context object. **→ SC-1, SC-3**

5. **GREEN doublecheck (**inline**).** `grep 'export const EnvLoaderPlugin' .opencode/plugins/env-loader.ts` → match found. `grep 'export default' .opencode/plugins/env-loader.ts` → no match. **→ SC-1, SC-3**

6. **Checkpoint commit (**inline**).** `git add .opencode/plugins/env-loader.ts && git commit -m "Phase 1 Item 1.1: Change export from default to named export EnvLoaderPlugin"`. Tag: `opencode-config/checkpoint/1370/phase-1-item-1.1-opencode`. **→ SC-1, SC-3**

#### Item 1.2 — Update imports

7. **RED (**sub-agent**).** Write structural test: `grep 'PluginInput' .opencode/plugins/env-loader.ts` → match found (RED: old import still present). `grep 'Hooks' .opencode/plugins/env-loader.ts` → match found. **→ SC-1, SC-4**

8. **GREEN (**sub-agent**).** Change `import type { Hooks, PluginInput } from "@opencode-ai/plugin"` to `import type { Plugin } from "@opencode-ai/plugin"`. Remove unused `Hooks` and `PluginInput` imports. **→ SC-1, SC-4**

9. **GREEN doublecheck (**inline**).** `grep 'import type { Plugin }' .opencode/plugins/env-loader.ts` → match found. `grep 'PluginInput' .opencode/plugins/env-loader.ts` → no match. **→ SC-1, SC-4**

10. **Checkpoint commit (**inline**).** `git add .opencode/plugins/env-loader.ts && git commit -m "Phase 1 Item 1.2: Update imports — Plugin type, remove PluginInput/Hooks"`. Tag: `opencode-config/checkpoint/1370/phase-1-item-1.2-opencode`. **→ SC-1, SC-4**

#### Item 1.3 — Map context object properties

11. **RED (**sub-agent**).** Write structural test: `grep 'input\\.' .opencode/plugins/env-loader.ts` → matches found (RED: old `input.` references still present). **→ SC-1, SC-2**

12. **GREEN (**sub-agent**).** Replace all `input?.directory` → `directory`, `input?.worktree` → `worktree`, `input.$.nothrow` → `$.nothrow` in the plugin function body. Preserve the `gitCmd` wrapper's `input.$.nothrow` reference (nested function, not direct context property). **→ SC-1, SC-2**

13. **GREEN doublecheck (**inline**).** `grep 'input\\.' .opencode/plugins/env-loader.ts` → only the `gitCmd` wrapper line remains (expected). Verify `directory`, `worktree`, and `$` are used directly in the main function body. **→ SC-1, SC-2**

14. **Checkpoint commit (**inline**).** `git add .opencode/plugins/env-loader.ts && git commit -m "Phase 1 Item 1.3: Map context object properties — input.X to direct destructured params"`. Tag: `opencode-config/checkpoint/1370/phase-1-item-1.3-opencode`. **→ SC-1, SC-2**

#### Item 1.4 — Behavioral test: plugin loads without error

15. **RED (**sub-agent**).** Write behavioral test: run `opencode-cli run` with plugin loaded → assert stderr contains `"Plugin export is not a function"` (RED: old export still causes load failure). **→ SC-1, SC-2**

16. **GREEN (**sub-agent**).** Re-run `opencode-cli run` with plugin loaded after Items 1.1-1.3 changes → assert stderr does NOT contain `"Plugin export is not a function"`. Assert `echo $BRANCH_NAME` produces non-empty output. **→ SC-1, SC-2**

17. **GREEN doublecheck (**inline**).** Verify stderr log: no `"Plugin export is not a function"` error present. Verify `BRANCH_NAME` env var is set. **→ SC-1, SC-2**

18. **Checkpoint commit (**inline**).** `git add .opencode/plugins/env-loader.ts && git commit -m "Phase 1 Item 1.4: Behavioral test — plugin loads without export error"`. Tag: `opencode-config/checkpoint/1370/phase-1-item-1.4-opencode`. **→ SC-1, SC-2**

### Phase 1 VbC

19. **VbC (**clean-room**).** Verify all Phase 1 SCs:
    - SC-1: `opencode-cli run` with plugin → stderr does NOT contain `"Plugin export is not a function"`
    - SC-2: `opencode-cli run` with plugin → `echo $BRANCH_NAME` produces non-empty output
    - SC-3: `grep` for `parseEnvFile`, `isEnvGitignored`, `writeDiagnostic`, `DIAGNOSTICS_PATH`, `PluginDiagnostic` in `.opencode/plugins/env-loader.ts` → all present
    - SC-4: `tsc --noEmit --project .opencode/tsconfig.json` exits 0 (Phase 1 portion — env-loader.ts only)
    **→ SC-1, SC-2, SC-3, SC-4**

**Concern transition:** Leaving Plugin export fix (env-loader.ts) → entering TypeScript fixes (session-enforcement.ts). Phase 2 depends on Phase 1 completing env-loader.ts changes so the shared `Plugin` type import pattern is established.

## Phase 2 — session-enforcement.ts TypeScript Fixes

**Concern:** Fix `"session.created"` hook key to `event` hook with `event.type` discrimination, and fix `part.synthetic` access on non-`TextPart` variants by narrowing to `part.type === 'text'` first.

**Files:** `.opencode/plugins/session-enforcement.ts`

**SCs:** SC-4

**Dependencies:** Phase 1

**Entry condition:** Phase 1 VbC passed and checkpoint tagged.

**Exit condition:** All Phase 2 items pass RED → GREEN → doublecheck → commit. VbC passes. Phase 2 checkpoint tagged.

### Pre-RED Common

> **Cost-frame reformation:** The orchestrator's context is the most expensive resource in the pipeline. Every byte held costs `byte × remaining_dispatches²`. Sub-agents are disposable context buffers — they read task files fully, analyze source, and burn context freely. Result contracts carry only routing-significant data (status, finding_summary, artifact_path, blocker_reason). Full evidence goes to disk. Professional orchestrators hold routing metadata only — sub-agents do the work.

1. **Read current session-enforcement.ts (**inline**).** Verify current state: `"session.created"` hook key at line 777, `part.synthetic` access at line 951 without type guard. **→ SC-4**

### Per-Item RED+green Chains

#### Item 2.1 — Fix "session.created" hook key to event hook with event.type discrimination

2. **RED (**sub-agent**).** Write structural test: `grep '"session\\.created"' .opencode/plugins/session-enforcement.ts` → match found (RED: old hook key still present). **→ SC-4**

3. **GREEN (**sub-agent**).** Change `"session.created": async (eventInput) => {` to use the `event` hook pattern with `event.type` discrimination. The `session.created` event fires synchronously before `messages.transform` — preserve this semantic by checking `event.type === "session.created"` inside a generic `event` handler. **→ SC-4**

4. **GREEN doublecheck (**inline**).** `grep 'event\\.type' .opencode/plugins/session-enforcement.ts` → match found. `grep '"session\\.created"' .opencode/plugins/session-enforcement.ts` → no match. **→ SC-4**

5. **Checkpoint commit (**inline**).** `git add .opencode/plugins/session-enforcement.ts && git commit -m "Phase 2 Item 2.1: Fix session.created hook key to event hook with event.type discrimination"`. Tag: `opencode-config/checkpoint/1370/phase-2-item-2.1-opencode`. **→ SC-4**

#### Item 2.2 — Fix part.synthetic access on non-TextPart variants

6. **RED (**sub-agent**).** Write structural test: `grep 'part\\.synthetic' .opencode/plugins/session-enforcement.ts` → match found without preceding type guard (RED: unsafe access). **→ SC-4**

7. **GREEN (**sub-agent**).** Add `if (part.type !== 'text') continue;` guard before `part.synthetic` access at line 951. The `synthetic` property only exists on `TextPart` variants — narrowing to `part.type === 'text'` first ensures TypeScript correctly infers the type. **→ SC-4**

8. **GREEN doublecheck (**inline**).** `grep 'part\\.type ===' .opencode/plugins/session-enforcement.ts` → match found before `part.synthetic` access. Verify the guard is at the correct location (line ~951, inside the `for (const part of currentUser.parts)` loop). **→ SC-4**

9. **Checkpoint commit (**inline**).** `git add .opencode/plugins/session-enforcement.ts && git commit -m "Phase 2 Item 2.2: Fix part.synthetic access — add part.type === 'text' guard"`. Tag: `opencode-config/checkpoint/1370/phase-2-item-2.2-opencode`. **→ SC-4**

### Phase 2 VbC

10. **VbC (**clean-room**).** Verify Phase 2 SC:
    - SC-4: `tsc --noEmit --project .opencode/tsconfig.json` exits 0 (full run including both env-loader.ts and session-enforcement.ts)
    **→ SC-4**

**Concern transition:** Leaving TypeScript fixes (session-enforcement.ts) → entering AGENTS.md documentation. Phase 3 depends on Phase 1 and Phase 2 completing all code changes before documenting the plugin development requirements.

## Phase 3 — AGENTS.md Documentation

**Concern:** Create `.opencode/plugins/AGENTS.md` documenting plugin development requirements per official opencode plugin docs.

**Files:** `.opencode/plugins/AGENTS.md` (new file)

**SCs:** SC-5

**Dependencies:** Phase 1, Phase 2

**Entry condition:** Phase 2 VbC passed and checkpoint tagged.

**Exit condition:** All Phase 3 items pass RED → GREEN → doublecheck → commit. VbC passes.

### Pre-RED Common

> **Cost-frame reformation:** The orchestrator's context is the most expensive resource in the pipeline. Every byte held costs `byte × remaining_dispatches²`. Sub-agents are disposable context buffers — they read task files fully, analyze source, and burn context freely. Result contracts carry only routing-significant data (status, finding_summary, artifact_path, blocker_reason). Full evidence goes to disk. Professional orchestrators hold routing metadata only — sub-agents do the work.

1. **Read official opencode plugin docs (**sub-agent**).** Fetch plugin development documentation from `https://opencode.ai/docs/plugins/` to verify the correct plugin API patterns, hook names, and export conventions. **→ SC-5**

### Per-Item RED+green Chains

#### Item 3.1 — Create .opencode/plugins/AGENTS.md

2. **RED (**inline**).** `ls .opencode/plugins/AGENTS.md` → file does not exist (RED: documentation missing). **→ SC-5**

3. **GREEN (**sub-agent**).** Create `.opencode/plugins/AGENTS.md` documenting:
    - Plugin export requirement: named export (`export const MyPlugin: Plugin = async (...) =>`) — NOT `export default`
    - Plugin type import: `import type { Plugin } from "@opencode-ai/plugin"`
    - Available hooks: `shell.env`, `system.transform`, `chat.messages.transform`, `event`
    - Context object properties: `project`, `client`, `$`, `directory`, `worktree`
    - Diagnostic pattern: `writeDiagnostic()` for structured error/warning reporting
    - Secret handling: use `redactSecrets()` from session-enforcement pattern
    - TypeScript compilation: all plugins must pass `tsc --noEmit` before deployment
    - Reference to official docs: `https://opencode.ai/docs/plugins/`
    **→ SC-5**

4. **GREEN doublecheck (**inline**).** `ls .opencode/plugins/AGENTS.md` → file exists. Verify content covers all required topics. **→ SC-5**

5. **Checkpoint commit (**inline**).** `git add .opencode/plugins/AGENTS.md && git commit -m "Phase 3 Item 3.1: Create .opencode/plugins/AGENTS.md with plugin development requirements"`. Tag: `opencode-config/checkpoint/1370/phase-3-item-3.1-opencode`. **→ SC-5**

### Phase 3 VbC

6. **VbC (**clean-room**).** Verify Phase 3 SC:
    - SC-5: `ls .opencode/plugins/AGENTS.md` → file exists. Verify content includes plugin export pattern, hook documentation, and reference to official docs.
    **→ SC-5**

**Concern transition:** All phases complete. No further phases.

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Exit Criteria

- [ ] C1: Phase 1 complete — env-loader.ts uses named export `EnvLoaderPlugin: Plugin`, imports `Plugin` type, maps context properties, passes behavioral test (no "Plugin export is not a function" error)
- [ ] C2: Phase 2 complete — session-enforcement.ts uses `event` hook with `event.type` discrimination, `part.synthetic` access guarded by `part.type === 'text'` check
- [ ] C3: Phase 3 complete — `.opencode/plugins/AGENTS.md` created documenting plugin development requirements
- [ ] C4: SC-1 verified — plugin loads without "Plugin export is not a function" error (behavioral)
- [ ] C5: SC-2 verified — `shell.env` hook injects all env vars (behavioral)
- [ ] C6: SC-3 verified — named exports preserved (structural: grep)
- [ ] C7: SC-4 verified — `tsc --noEmit --project .opencode/tsconfig.json` exits 0 (structural)
- [ ] C8: SC-5 verified — `.opencode/plugins/AGENTS.md` exists (structural: ls)
- [ ] C9: All checkpoint tags created and pushed
- [ ] C10: Feature branch pushed to remote
