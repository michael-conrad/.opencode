---
plan_schema_version: 1
issue: 2570
title: "Notebook MCP deny-by-default + dedicated notebook-ops subagent"
dispatch: [implement, behavioral-testing, verify, git-workflow-pr]
---

# Plan: Notebook MCP deny-by-default + dedicated notebook-ops subagent

**Issue:** `.opencode#2570`
**Spec:** `.opencode/.issues/2570/spec.md`

## Goal / Architecture / Files

**Goal:** Deny `the-notebook_*` MCP tools to the main agent by default and pair
the deny with a dedicated `notebook-ops` subagent card that carries the allow
rule — the deny/allow pairing principle — reducing first-turn token load
without plugin removal.

**Architecture:** Permission-layer deny in `.opencode/opencode.jsonc`
(`permission` block only — no `mcp` changes of any kind), plus a subagent card
at `.opencode/agent/notebook-ops.md` following the `email-ops` pattern
(frontmatter allow rule + tool-handling body).

**Files:**
- `.opencode/opencode.jsonc` — modify: add `"the-notebook_*": "deny"` to `permission` (SC-4)
- `.opencode/agent/notebook-ops.md` — create (SC-5, SC-6)

## Environment constraint — updated

Original plan-time constraint: the notebook MCP could not start (upstream
`the-notebook-mcp` import failure — `jupyter_kernel_client` ≥1.0 no longer
exports `KernelClient`). Developer directive 2026-10-10, in-session, brought
the pin work into scope ("the notebook|mcp version and python version running
need to be properly pinned in the config file as a part of this work so the
plugin works again"). Spec revised: SC-8 added (runtime pins + executed
server-start probe); SC-1, SC-2, and SC-7's functional half are UNBLOCKED
once the pin commit is pushed and the server starts under the pinned config.

## Items (one per SC)

### Item 1 — SC-4 (structural): deny rule in permission block
- **RED:** no `the-notebook*` deny in opencode.jsonc permission.
- **GREEN:** Add `"the-notebook-mcp_*": "deny"` to the `permission` block.
  (Revision: the spec's original `"the-notebook_*"` pattern never matched the
  server-prefixed MCP tool names; the SC-1 run proved `notebook_create`
  completed under it. Corrected per spec revision note.)
- **Verify:** grep matches; `git diff` shows the only change is the added permission line — no `mcp` block modification (both server definitions remain).

### Item 2 — SC-5/SC-6 (structural): notebook-ops subagent card
- **RED:** `.opencode/agent/notebook-ops.md` does not exist.
- **GREEN:** Create the card with frontmatter: `mode: subagent`, `permission: {"the-notebook_*": allow}` (explicit allow, never relying on the `ask` default), and a description ≤30 words containing notebook, jupyter, kernel, server start/stop. Body: notebook tool-handling instructions (server start/stop on port 18888, notebook lifecycle, kernel management), health-check-first instruction, and the standing rule: if the notebook MCP is unavailable, report that in the result — do not retry tool calls.
- **Verify:** file inspection + description word count ≤30; SC-6 clauses present in body.

### Item 3 — SC-3 (behavioral): unavailable-server report, no retry
- **Instrument:** `tests-v2` behavioral harness (§AGENTS.md) — artifact-only generator + clean-room evaluation; server is unavailable (its natural state here).
- **Run:** one targeted scenario dispatching to the `notebook-ops` subagent with a notebook task; `session.yaml` must show the unavailability reported in the result and no repeated `the-notebook_*` tool calls.
- **Ordered precondition cycle:** commit → push → fetch/verify → run (harness gate).

### Item 4 — SC-7 (behavioral): token baseline, both server states
- **Instrument:** the documented `opencode.db` query protocol across both server states — functional (post-pin) and unavailable.
- **Functional half:** runnable after the pin commit is pushed (server starts).

### Item 5 — SC-2 (behavioral): subagent allow-surface, MCP notebook lifecycle
- **Rescoped per developer directive 2026-10-10 ("rescope into reality"):**
  the notebook MCP 0.9.0 exposes no server start/stop tools (verified from
  package source), so the criterion is now: dispatched `notebook-ops`
  subagent has the `the-notebook-mcp_*` tools available and completes
  notebook create + add-cell through them without a permission prompt;
  server lifecycle stays with the legacy scripts.
- **Evidence:** tests-v2 harness run + clean-room evaluation.

### Item 6 — SC-8 (structural): runtime pins + server-start probe
- **GREEN (done):** `the-notebook-mcp` command pins `--python 3.13`,
  `fastmcp==2.3.3`, `jupyter_kernel_client==0.9.0`; executed probe shows the
  `Server running` banner under stdio.

## Suite / gates

- Baseline and post-change: `tests-v2/test-enforcement.sh` (content-verification — no model runs) plus `./.opencode/tools/reference-integrity --scan` for the new card.
- No lint/typecheck surface for JSONC/markdown beyond JSON validity: validate `opencode.jsonc` parses (JSONC — strip comments or use a JSONC-aware parse).
- verify pass: single fresh-context reviewer per `verify` card before any PR claim.

> **Enforcement gate:** all runnable SCs must pass before completion; BLOCKED SCs are reported with root cause, never fabricated as PASS.
