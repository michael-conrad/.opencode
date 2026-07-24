> **Migrated from michael-conrad/opencode-config#301** — this issue concerns `.opencode/` submodule content and was refiled to the correct repository.

## Intent and Executive Summary

### Problem Statement
The `session-enforcement.ts` plugin was rewritten from scratch but three features from the original spec were never implemented: trigger warnings injection, sub-agent session detection, and session-init output mechanism. Without these, the plugin cannot inject session context triggers, cannot distinguish primary from sub-agent sessions, and the session-init tool pollutes stdout.

### Root Cause / Motivation
The original 968-line plugin was rewritten to 83 lines (verified by reading `.opencode/plugins/session-enforcement.ts` — 83 lines, zero `console.log`/`console.error`/`process.stdout`, two hooks: `system.transform` and `messages.transform`). The rewrite focused on eliminating mixed concerns (git hooks, config watchdog, skill loading) but deferred three features. No recent commits touch the plugin file (verified via `git log --oneline .opencode/plugins/session-enforcement.ts`), confirming the state is current.

### Approach Chosen
1. Replace `session-init` `print()` calls with YAML file writes to `{project_root}/tmp/session-context.yaml`; plugin reads the file in `system.transform` hook
2. Add trigger detection to `messages.transform` hook for primary sessions
3. Add `event` hook with `session.created` to detect sub-agent sessions and skip first-turn injections

### Alternatives Considered & Why Discarded
- **YAML temp file vs env var for session-init output:** Env vars have size limits (~128KB on most systems) and cannot carry structured YAML with nested keys. A temp file has no size limit and preserves structured data.
- **Event hook vs message inspection for sub-agent detection:** The `event` hook with `session.created` is the canonical API for session lifecycle events. Message inspection (checking message content for sub-agent markers) is fragile — it depends on message format conventions that may change.
- **`messages.transform` vs `system.transform` for trigger injection:** Triggers are per-session (injected into the first user message of each session), not per-system. The `messages.transform` hook fires per-message and has access to the message context, making it the correct hook. `system.transform` fires once per system prompt and cannot distinguish message boundaries.

### Key Design Decisions
- Temp file path: `{project_root}/tmp/session-context.yaml` — consistent with existing temp file conventions
- First-run fallback: if temp file doesn't exist, plugin runs `session-init` once to generate it
- Sub-agent detection gates trigger injection: SC-6 must be implemented before SC-4

## Problem

The `session-enforcement.ts` plugin has been rewritten from scratch (now 83 lines, zero `console.log`/`console.error`/`process.stdout` — verified by reading the file at `.opencode/plugins/session-enforcement.ts`). The rewrite eliminated the original 968-line mixed-concern plugin. The current plugin uses only two hooks: `system.transform` (inject session-init output via execSync) and `messages.transform` (strip synthetic mode-switch messages). It does NOT install git hooks, run a git config watchdog, load skill frontmatter, or build a skill index.

However, three features from the original spec were never implemented:

1. **Trigger warnings injection** (SC-4) — the plugin does not inject trigger warnings into the first user message
2. **Sub-agent session detection** (SC-6) — the plugin does not detect sub-agent sessions via the `event` hook
3. **session-init output mechanism** (SC-7) — `session-init` (634 lines) still uses `print()` to stdout, relying on the plugin's execSync capture. It should write to a temp file instead.

Additionally, SC-5 (secret redaction) was delegated to the opencode-vibeguard plugin and will not be implemented here.

## Solution

Implement the three remaining features:

1. **session-init writes to a temp file** — Replace `print()` calls in `session-init` with YAML file writes to `{project_root}/tmp/session-context.yaml`. The plugin reads this file in the `system.transform` hook instead of capturing stdout via execSync.
2. **Trigger warnings injection** — Add trigger detection to the `messages.transform` hook. On the first user message of a primary session, inject trigger warnings (pair mode resume, nested opencode fatal) into the message content.
3. **Sub-agent session detection** — Add an `event` hook that detects sub-agent sessions via `session.created`. When a sub-agent session is detected, skip first-turn trigger injections.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Cost of Failure (DDL) |
|----|-----------|---------------|---------------------|-----------------------|
| SC-4 | Trigger warnings are injected into the first user message of primary sessions only | `behavioral` | Verify first user message of primary session contains `### Session Triggers`; verify sub-agent sessions do NOT contain it. **Boundary:** verify empty trigger set (no pair mode, no nested opencode fatal) produces no injection | Days — missing triggers cause agents to miss session context, producing incorrect behavior that surfaces in production |
| SC-6 | Sub-agent sessions are detected and first-turn injections are skipped | `behavioral` | Verify sub-agent sessions do not receive first-turn trigger injections. **Boundary:** verify behavior when `event` hook is unavailable (graceful degradation — no crash, no injection) | Weeks — sub-agents receiving primary-session triggers produce contaminated output; defect discovered at review time |
| SC-7 | `session-init` writes to a temp file, not stdout | `string` | Verify `session-init` has no `print()` calls for context output; verify it writes to `{project_root}/tmp/session-context.yaml`. **Boundary:** verify behavior when temp file write fails (graceful fallback to stdout) | Months — stdout pollution from session-init breaks downstream consumers; defect discovered during integration |

### SC Enforcement Gate

All SCs must pass before the implementation is considered complete. A single FAIL blocks the entire implementation.

### Implementation Ordering

SC-6 (sub-agent detection) MUST be implemented before SC-4 (trigger injection). The sub-agent detection gate determines whether trigger injection fires at all — implementing SC-4 first would inject triggers into sub-agent sessions until SC-6 is in place. SC-7 (session-init output) is independent and can be implemented in any order.

## Edge Cases

| Edge Case | Expected Behavior | SC Coverage |
|-----------|------------------|-------------|
| Temp file write fails (disk full, permission denied) | `session-init` falls back to stdout; plugin continues to work via execSync capture | SC-7 |
| `session.created` event hook is not available | Sub-agent detection degrades gracefully — all sessions treated as primary; triggers injected for all sessions (conservative behavior) | SC-6 |
| Both primary and sub-agent sessions created simultaneously | Each session independently evaluates its type; no cross-session interference | SC-4, SC-6 |
| First run — temp file doesn't exist | Plugin runs `session-init` once to generate the temp file; subsequent reads use the file | SC-7 |
| Empty trigger set (no pair mode, no nested opencode fatal) | No trigger warnings injected; first user message passes through unmodified | SC-4 |

## Alternatives Considered

### YAML temp file vs env var for session-init output
Env vars have size limits (~128KB on most systems) and cannot carry structured YAML with nested keys. A temp file has no size limit and preserves structured data. **Chosen: YAML temp file.**

### Event hook vs message inspection for sub-agent detection
The `event` hook with `session.created` is the canonical API for session lifecycle events. Message inspection (checking message content for sub-agent markers) is fragile — it depends on message format conventions that may change. **Chosen: event hook.**

### `messages.transform` vs `system.transform` for trigger injection
Triggers are per-session (injected into the first user message of each session), not per-system. The `messages.transform` hook fires per-message and has access to the message context, making it the correct hook. `system.transform` fires once per system prompt and cannot distinguish message boundaries. **Chosen: `messages.transform`.**

## Documentation Sources

- **Plugin source file:** `.opencode/plugins/session-enforcement.ts` — current state verified by reading the file (83 lines, 2 hooks, zero console output)
- **Session-init tool:** `.opencode/tools/session-init` — 634 lines, currently uses `print()` for context output
- **No recent commits** touching the plugin file were found (`git log --oneline .opencode/plugins/session-enforcement.ts`), confirming the state described is current

## Affected Files

- `.opencode/plugins/session-enforcement.ts` — add trigger injection and sub-agent detection
- `.opencode/tools/session-init` — change output mechanism from `print()` to file write

## Non-Goals

- Do NOT implement secret redaction (SC-5) — delegated to opencode-vibeguard plugin
- Do NOT modify `env-loader.ts` — that plugin is a separate concern
- Do NOT modify any skill files, guideline files, or test files
- Do NOT modify hook scripts in `.opencode/hooks/`
- Do NOT re-add git hook installation, git config watchdog, skill frontmatter loading, or skill index building to the plugin

## Implementation Notes

The `session-init` tool's `print()` calls should be replaced with YAML file writes to `{project_root}/tmp/session-context.yaml`. The plugin reads the YAML file in the `system.transform` hook. If the file doesn't exist (first run), the plugin should run `session-init` once to generate it. This eliminates all terminal output from the session-init pipeline.

Trigger injection should detect pair mode resume and nested opencode fatal states. Sub-agent detection uses the `event` hook with `session.created` to identify sub-agent sessions and skip first-turn injections.

**Implementation order:** SC-6 (sub-agent detection) → SC-4 (trigger injection) → SC-7 (session-init output). SC-6 gates SC-4; SC-7 is independent.
