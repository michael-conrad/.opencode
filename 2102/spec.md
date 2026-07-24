> **Migrated from michael-conrad/opencode-config#301** — this issue concerns `.opencode/` submodule content and was refiled to the correct repository.

## Problem

The `session-enforcement.ts` plugin has been rewritten from scratch (now 83 lines, zero `console.log`/`console.error`/`process.stdout`). The rewrite eliminated the original 968-line mixed-concern plugin. The current plugin uses only two hooks: `system.transform` (inject session-init output via execSync) and `messages.transform` (strip synthetic mode-switch messages). It does NOT install git hooks, run a git config watchdog, load skill frontmatter, or build a skill index.

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

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-4 | Trigger warnings are injected into the first user message of primary sessions only | `behavioral` | Verify first user message of primary session contains `### Session Triggers`; verify sub-agent sessions do NOT contain it |
| SC-6 | Sub-agent sessions are detected and first-turn injections are skipped | `behavioral` | Verify sub-agent sessions do not receive first-turn trigger injections |
| SC-7 | `session-init` writes to a temp file, not stdout | `string` | Verify `session-init` has no `print()` calls for context output; verify it writes to `{project_root}/tmp/session-context.yaml` |

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
