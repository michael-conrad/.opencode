# Spec: Sub-agent detection broken — input.client unavailable in messages.transform hook

STATUS: 1.1
CREATED: 2026-06-17

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Intent and Executive Summary

**Problem Statement:** Sub-agent detection in `session-enforcement.ts` always returns `false` because `input.client` is `null`/`undefined` in the `messages.transform` hook context. Sub-agents never receive the `### Core Principles (Sub-Agent)` enforcement block, causing them to operate without sub-agent-specific enforcement rules (inline work detection, evidence gate, etc.).

**Root Cause / Motivation:** The `#1257` fix moved sub-agent detection from `system.transform` (where `input.client` was available) to `messages.transform` (where it is not). The `PluginInput.client` property is populated asynchronously and is not guaranteed to be available when `messages.transform` fires. The catch block at line 960 silently swallows the error, setting `isSubAgent = false` for every session.

**Approach Chosen:** Use `session.created` event cache as primary detection, with `input.client.session.get()` as fallback. The `session.created` event fires synchronously before `messages.transform` and carries `parentID` directly in its payload.

**Alternatives Considered & Why Discarded:**
- Using `input.client` directly (the outer PluginInput parameter) — works but requires a per-turn API call on every session's first message. Event cache eliminates the API call entirely.
- Using `firstUser.info.agent` to detect sub-agents (agent=general vs agent=build) — fragile, depends on agent naming conventions, doesn't work for custom sub-agents.

**Key Design Decisions:**
- Event cache over API call: The `session.created` event fires synchronously before `messages.transform` and carries `parentID` directly — no async API call, no race condition, no null client.
- Fallback retained: `input.client.session.get()` kept as fallback for sessions where the event was missed (e.g., plugin loaded mid-session).
- Graceful degradation preserved: If both paths fail, assume primary session (existing behavior).

---

## Phase 1: Detection Rewrite (Gated)

### Steps
1. ☐ Add `session.created` event handler that populates `sessionParentCache` Map
2. ☐ Rewrite `messages.transform` detection to check cache first, fall back to API call
3. ☐ Update diagnostic output to report detection source (`event-cache` / `api-fallback` / `none`)
4. ☐ Write behavioral enforcement test (RED), implement fix (GREEN)

### Content

**File:** `.opencode/plugins/session-enforcement.ts`

**Changes:**
1. Add module-level `sessionParentCache = new Map<string, string>()`
2. Register `session.created` event handler: on event, if `payload.parentID` is set, store `map.set(payload.id, payload.parentID)`
3. In `messages.transform`: check `sessionParentCache.has(sessionID)` first. If cache hit, set `isSubAgent = true`. If cache miss, fall back to `input.client.session.get()`. If both fail, graceful degradation to `isSubAgent = false`.
4. Add `detectionSource` field to diagnostic output

**Behavioral test:** `.opencode/tests/behaviors/sub-agent-principles-injection.sh` — artifact-only generator that dispatches a sub-agent and captures stderr diagnostic output.

### Success Criteria

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `session.created` event handler captures `parentID` into in-memory cache before `messages.transform` fires | `behavioral` | `opencode-cli run` with sub-agent task → verify diagnostic stderr shows `isSubAgent: true` and `detectionSource: "event-cache"` |
| SC-2 | `isSubAgent` detection uses event cache as primary source, with `input.client.session.get()` as fallback on cache miss | `behavioral` | `opencode-cli run` with sub-agent task → verify diagnostic stderr shows correct detection path |
| SC-3 | Sub-agents receive `### Core Principles (Sub-Agent)` block on first turn | `behavioral` | `opencode-cli run` with sub-agent task → semantic inspector verifies sub-agent enforcement block present in system prompt |
| SC-4 | Behavioral enforcement test in `.opencode/tests/behaviors/` verifies sub-agent receives Core Principles block (RED before GREEN) | `behavioral` | `bash .opencode/tests/behaviors/sub-agent-principles-injection.sh` → PASS after fix |

### Edge Cases

| Case | Behavior |
|------|----------|
| `session.created` fires after `messages.transform` | Cache miss → fallback to API call → if API also fails, assume primary (graceful degradation) |
| Plugin loaded mid-session (no `session.created` event) | Cache empty → fallback to API call |
| `input.client` becomes available in future OpenCode version | Fallback path works; event cache still preferred (no async dependency) |
| Multiple sub-agents with same sessionID | Map ensures latest `parentID` wins; diagnostic logs overwrite |

### Regression Invariants

- [ ] Primary sessions MUST still receive full first-turn injections (Pre-Implementation Gate, Core Principles, Tier 1 Enforcement)
- [ ] Diagnostic output (`[session-enforcement-diag]`) MUST continue to function
- [ ] Graceful degradation on API failure MUST be preserved (assume primary session)

### Non-Goals

- Changing what the Core Principles (Sub-Agent) block contains — out of scope; this fix only ensures it is delivered
- Adding new enforcement rules for sub-agents — out of scope; delivery mechanism only

---

**Documentation Sources:**
| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Direct source search | `read .opencode/plugins/session-enforcement.ts:930-1009` | Verify bug location, current detection code, and diagnostic output |
| Direct source search | `grep session.created / parentID / isSubAgent` across `.opencode/plugins/` | Confirm no existing event-cache infrastructure |
| Git history | `git -C .opencode log --oneline -5` | Trace #1257 fix history and confirm current state |

🤖 OpenCode (ollama-cloud/deepseek-v4-pro) created
