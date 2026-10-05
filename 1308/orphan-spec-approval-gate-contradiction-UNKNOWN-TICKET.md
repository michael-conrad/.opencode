# [SPEC] Clean up session-enforcement.ts — isFirstTurn heuristic, inline work detector, mode-switch handling, gate blocks

## Problem

`session-enforcement.ts` has accumulated four defects after iterative patching:

1. **isFirstTurn heuristic fragile**: `userMessages.length === 1` breaks on context reload — after compaction, the message array resets and `length === 1` fires again. Prior fix attempts (#1258/#1260) kept the same heuristic but moved detection between hooks. The heuristic itself is the root cause.

2. **Inline work detector provides no enforcement value**: Static regex scanning of LLM-formatted text for pattern `(edit|write|read|modify|create|delete|update)` near `(file|path|config|src|test)` is trivially bypassable. Produces false positives on legitimate tool-call descriptions. Addressed in discussion — agreed to remove entirely.

3. **Mode-switch handling over-engineered**: Current code detects mode-switch messages via `isModeSwitchContent()`, replaces the anchor string, and re-interpolates. Since the synthetic message is always present on mode switch and the content is always the same boilerplate, unconditional stripping suffices.

4. **Gate blocks duplicate system instructions**: Pre-Implementation Gate, Core Principles, and Tier 1 Mandate are already loaded into system context via `.opencode/opencode.jsonc` instructions array. The plugin's per-turn injection of these blocks adds no new information and wastes context window.

## Proposed Changes

### Change 1: Replace isFirstTurn with process-scoped Set

Replace `userMessages.length === 1` with a module-level `Set<string>`:

```typescript
const injectedFirstTurnSessions = new Set<string>();
```

Keyed by `sessionID` captured from the `session.created` event. On `messages.transform`, check `!injectedFirstTurnSessions.has(sessionID)` instead of `userMessages.length === 1`.

- Survives context reload: new process = empty Set = fires again correctly
- Does not depend on `userMessages.length` which resets on compaction or context reload
- Does not depend on `session.created` event timing (event fires before first transform)
- Cleans up naturally: process exit = Set garbage collected

### Change 2: Remove inline work detector

Remove the per-turn handler that scans user messages for file-edit patterns, the `isInlineWork`/`containsFileEditPattern` helper functions, and all associated regex patterns.

Rationale: Static text scanning of LLM output is bypassable by design. The `orchestrator inline work = poisoned pipeline` rule is already a critical guideline enforced by the guideline system, not by a regex in a plugin.

### Change 3: Remove mode-switch handling

Remove `isModeSwitchContent()`, `handleModeSwitchParts()`, `MODE_SWITCH_ANCHOR` constant, and the call to `handleModeSwitchParts` in the `messages.transform` handler.

Replace with unconditional stripping: detect synthetic mode-switch messages by checking if `text` contains "Your operational mode has changed from" or "# Plan Mode - System Reminder", and if so, set `text = ""`.

### Change 4: Remove gate blocks

Remove Pre-Implementation Gate, Core Principles injection, and Tier 1 Mandate Enforcement injection blocks. All three are redundant with `.opencode/opencode.jsonc` instructions array which loads the full guideline files into system context.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|---|---|---|---|
| SC-1 | Process-scoped `Set<sessionID>` replaces `userMessages.length === 1` for first-turn detection | `string` | grep for `injectedFirstTurnSessions` usage in `messages.transform` |
| SC-2 | `sessionID` is captured from `session.created` event and used as key | `string` | grep for `session.created` handler setting `sessionID` |
| SC-3 | Inline work detector code is removed (no `isInlineWork`, no `containsFileEditPattern`, no associated regex) | `string` | grep confirms helper functions absent |
| SC-4 | Mode-switch handling code is removed (`isModeSwitchContent`, `handleModeSwitchParts`, `MODE_SWITCH_ANCHOR` absent) | `string` | grep confirms identifiers absent |
| SC-5 | Synthetic mode-switch messages are stripped unconditionally by text-content check | `behavioral` | Inject mode-switch message → confirm text is set to `""` |
| SC-6 | Pre-Implementation Gate block removed | `string` | grep for gate section header absent |
| SC-7 | Core Principles injection block removed | `string` | grep for principles section absent |
| SC-8 | Tier 1 Mandate Enforcement injection block removed | `string` | grep for mandate enforcement section absent |
| SC-9 | Plugin compiles without TypeScript errors | `behavioral` | Run `npx tsc --noEmit` in `.opencode/` directory |
| SC-10 | First-turn injection still fires on first user message in a fresh session | `behavioral` | `opencode-cli run` with test prompt → verify injection appears in first turn |
| SC-11 | First-turn injection does NOT fire on subsequent turns | `behavioral` | `opencode-cli run` with multi-turn test → verify injection appears only on turn 1 |

## Files Affected

- `.opencode/plugins/session-enforcement.ts` — all four changes

## Dependencies

- Issue #1260: sub-agent detection in `messages.transform` — my approach (process-scoped Set) is compatible with whatever fix #1260 implements since they address different mechanisms (first-turn vs sub-agent detection)
