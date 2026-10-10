# Spec — Math MCP deny-by-default + dedicated math-ops subagent

## Problem and provenance

The main-agent first-turn prompt measures ~22.0K tokens across recent sessions
(measured from `opencode.db`, 3,444 sessions 2026-03 → 2026-10), of which
~15.3K is tool schemas. The math MCP contributes ~2.0K tokens of schema to
every session while recording 6 total uses in seven months. Mined trigger
analysis shows all 6 uses were incidental arithmetic inside dispatched subagent
work (research, plan-execution, and TDD dispatches calling
`math_batch_calculate`/`math_calculate_expression`) — never the purpose of a
session. The capability is natively covered by bash/python.

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
  removal constraint; hiding, not deleting. For math, the card is therefore
  the preservation mechanism: a deny with no allow-surface would be removal by
  another name.
- "create separate specs for each plugin to be disable by default and assigned
  dedicated sub-agents for actual use" — the deliverable shape.

Design principle recorded in exploration: every global deny is paired with a
dedicated subagent card that allows the pattern — a deny with neither a card
nor a documented alternative path is a capability cut, not a token
optimization.

## Final state

1. The deck config `.opencode/opencode.jsonc` contains, in its `permission`
   block, the rule `"math_*": "deny"`. The math MCP server definition remains
   exactly as configured (no `mcp` block changes of any kind).
2. A subagent card exists at `.opencode/agent/math-ops.md` with:
   - `mode: subagent` and a description of at most 30 words that contains the
     trigger vocabulary for math work (math, calculate, statistics,
     conversion, matrix, number theory);
   - an explicit `permission` entry `"math_*": "allow"` (the MCP-tool default
     of `ask` is never relied upon);
   - a body carrying the math tool-handling instructions and the scope
     boundary: the card serves explicit math-MCP work; everyday arithmetic is
     native (bash/python) and must not be dispatched here.

## Success criteria

- **SC-1 (behavioral).** In a fresh main-agent session under the deck config,
  no tool whose name starts with `math_` is present in the session's toolset.
  Instrument: session toolset inspection via `opencode run` session evidence.
- **SC-2 (behavioral).** A session dispatched to the `math-ops` subagent has
  `math_*` tools available and completes a calculation (for example
  `math_calculate_expression`) without a permission prompt. Instrument:
  behavioral run; the transcript shows the tool call succeeding with no
  ask/permission stall.
- **SC-3 (behavioral).** Given a developer request for explicit math-tool work
  (for example "use the math MCP to compute X"), the main agent routes the
  work by dispatching to `math-ops`. Instrument: behavioral run with that
  trigger phrasing; the transcript shows a task dispatch naming math-ops.
- **SC-4 (structural).** The deck config's `permission` block contains
  `"math_*": "deny"`, and the change's diff removes no `mcp` server definition
  from any config file. Instrument: direct config inspection of the
  implementation diff.
- **SC-5 (structural).** `.opencode/agent/math-ops.md` exists with
  `mode: subagent`, an explicit `"math_*": "allow"` permission entry, and a
  description of at most 30 words containing the trigger vocabulary named
  above. Instrument: file inspection and word count.
- **SC-6 (structural).** The card body states the scope boundary: explicit
  math-MCP work is dispatched here, incidental arithmetic uses bash/python
  natively. Instrument: file inspection of the card body.
- **SC-7 (behavioral).** First-turn `tokens.input` for a standard main-agent
  session (same model, minimal first prompt) is at least 1,000 tokens lower
  than the measured ~22.0K pre-change baseline. Instrument: the documented
  `opencode.db` query protocol (first assistant message of a fresh session,
  same model profile as the baseline measurements).

## Out of scope

- ragsync — not set up yet; excluded per developer instruction.
- The `tools/jupyter*` script purge — separate deck-debt item.
- The floor external-access table rewrite — a separate governed edit covering
  all three plugin changes (gmail, math, notebook).
- Relocating or deduplicating any MCP server definition between global and
  project config.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
