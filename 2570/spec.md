# Spec — Notebook MCP deny-by-default + dedicated notebook-ops subagent

## Problem and provenance

The main-agent first-turn prompt measures ~22.0K tokens across recent sessions
(measured from `opencode.db`, 3,444 sessions 2026-03 → 2026-10). The
the-notebook-mcp server has 0 tool uses in seven months and currently logs
`status=failed` ("server unavailable") on every session start; it contributes
startup latency now and ~3-5K tokens of schema whenever it loads. Its config
is also duplicated — global and project config both define it.

Developer statements this spec traces to:

- "review the default injected texts and floor. our starting token count seems
  a bit high" — the token-reduction goal.
- "the MCP enabled can be handled with permission denied by default then having
  a sub-agent card that has perms enable for said MCP plugin" — the mechanism.
- "minimal description text for auto injection into the agent to reduce token
  load as much as possible without lobotimizing or otherwise crippling the
  agent with having cards it never can match via intent when needing to use
  the cards" — the description-text requirement and the anti-lobotomy bound.
- "no plugin removals. this is not the only project that uses this deck" — the
  removal constraint; hiding, not deleting.
- "the tools/jupyter* scripts were supposed to have been purged in favor of
  the notebook plugin, it is broken right now, but that is not relevant" — the
  notebook MCP is the sole intended path for notebook work; no
  alternative-path pairing applies, and the card ships now (designed for the
  intended end-state) so the intent-match surface exists when the server is
  healthy.
- "create separate specs for each plugin to be disable by default and assigned
  dedicated sub-agents for actual use" — the deliverable shape.

Design principle recorded in exploration: every global deny is paired with a
dedicated subagent card that allows the pattern — no deny ships without its
allow-surface.

## Final state

1. The deck config `.opencode/opencode.jsonc` contains, in its `permission`
   block, the rule `"the-notebook_*": "deny"`. Both existing
   the-notebook-mcp server definitions (global and project duplicate) remain
   exactly as configured (no `mcp` block changes of any kind).
2. A subagent card exists at `.opencode/agent/notebook-ops.md` with:
   - `mode: subagent` and a description of at most 30 words that contains the
     trigger vocabulary for notebook work (notebook, jupyter, kernel, server
     start/stop);
   - an explicit `permission` entry `"the-notebook_*": "allow"` (the MCP-tool
     default of `ask` is never relied upon);
   - a body carrying the notebook tool-handling instructions (server
     start/stop on port 18888, notebook lifecycle, kernel management), a
     health-check-first instruction, and one standing rule: if the notebook
     MCP is unavailable, report that in the result — do not retry tool calls.

## Success criteria

- **SC-1 (behavioral).** When the notebook MCP server is functional, a fresh
  main-agent session under the deck config has no tool whose name starts with
  `the-notebook_` in its session toolset. Instrument: session toolset
  inspection via `opencode run` session evidence, executed with the server
  able to start.
- **SC-2 (behavioral).** A session dispatched to the `notebook-ops` subagent,
  with the server functional, has `the-notebook_*` tools available and
  completes a notebook lifecycle operation (server start followed by server
  stop) without a permission prompt. Instrument: behavioral run; the
  transcript shows both calls succeeding with no ask/permission stall.
- **SC-3 (behavioral).** With the server unavailable, a session dispatched to
  `notebook-ops` reports the unavailability in its result instead of retrying
  tool calls. Instrument: behavioral run with the server stopped or failing;
  the transcript shows the report and no repeated tool calls.
- **SC-4 (structural).** The deck config's `permission` block contains
  `"the-notebook_*": "deny"`, and the change's diff removes no `mcp` server
  definition from any config file (both the global and the project duplicate
  remain). Instrument: direct config inspection of the implementation diff.
- **SC-5 (structural).** `.opencode/agent/notebook-ops.md` exists with
  `mode: subagent`, an explicit `"the-notebook_*": "allow"` permission entry,
  and a description of at most 30 words containing the trigger vocabulary
  named above. Instrument: file inspection and word count.
- **SC-6 (structural).** The card body carries the health-check-first
  instruction and the report-don't-retry rule for server unavailability.
  Instrument: file inspection of the card body.
- **SC-7 (behavioral).** Once the notebook server is functional, first-turn
  `tokens.input` for a standard main-agent session (same model, minimal first
  prompt) does not exceed the post-change baseline measured with the server
  unavailable — the deny prevents schema regrowth. Instrument: the documented
  `opencode.db` query protocol across both server states.

## Out of scope

- ragsync — not set up yet; excluded per developer instruction.
- The `tools/jupyter*` script purge — separate deck-debt item, recorded from
  the developer's statement that these scripts were supposed to have been
  purged in favor of the notebook plugin.
- The floor external-access table rewrite — a separate governed edit covering
  all three plugin changes (gmail, math, notebook).
- Relocating, deduplicating, or fixing any MCP server definition — the server
  is denied at the permission layer regardless of its health.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
