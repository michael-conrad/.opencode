> **Full spec and artifacts: [`.issues/1260/`](https://github.com/michael-conrad/.opencode/tree/issues-data/1260)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.issues/1260/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Exec Summary

Fixes a bug in `session-enforcement.ts` where sub-agent detection always returns `false` because `input.client` is unavailable in the `messages.transform` hook context. Sub-agents never receive the `### Core Principles (Sub-Agent)` block, causing them to operate without sub-agent-specific enforcement.

### Cards (dependency order)
1. **Event cache infrastructure** — Register a `session.created` event handler that captures `parentID` into an in-memory cache before `messages.transform` fires
2. **Detection rewrite** — Replace the broken `input.client.session.get()` call with event-cache lookup as primary, keeping the API call as fallback
3. **Behavioral enforcement test** — Verify sub-agents receive the Core Principles block via `opencode-cli run`

### Key Decisions
- **Event cache over API call**: The `session.created` event fires synchronously before `messages.transform` and carries `parentID` directly — no async API call, no race condition, no null client
- **Fallback retained**: `input.client.session.get()` kept as fallback for sessions where the event was missed (e.g., plugin loaded mid-session)

### Risk Callouts
- **Event ordering**: If `session.created` fires after `messages.transform` in some OpenCode versions, the cache will be empty and detection falls back to the API call (which may also fail). Mitigation: diagnostic logging surfaces which path was used.
