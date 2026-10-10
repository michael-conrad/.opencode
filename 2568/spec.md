# Spec — Gmail MCP deny-by-default + dedicated email-ops subagent

## Problem and provenance

The main-agent first-turn prompt measures ~22.0K tokens across recent sessions
(measured from `opencode.db`, 3,444 sessions 2026-03 → 2026-10), of which
~15.3K is tool schemas. The gmail MCP contributes ~2.5K tokens of schema to
every session while recording 19 total uses in seven months — one direct probe
plus a handful of genuine email flows, several occurring inside dispatched card
workflows rather than as email-session requests.

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
- "create separate specs for each plugin to be disable by default and assigned
  dedicated sub-agents for actual use" — the deliverable shape.

Design principle recorded in exploration: every global deny is paired with a
dedicated subagent card that allows the pattern — a deny with neither a card
nor a documented alternative path is a capability cut, not a token
optimization.

## Final state

1. The deck config `.opencode/opencode.jsonc` contains, in its `permission`
   block, the rule `"gmail_*": "deny"`. The gmail MCP server definition remains
   exactly as configured (no `mcp` block changes of any kind).
2. A subagent card exists at `.opencode/agent/email-ops.md` with:
   - `mode: subagent` and a description of at most 30 words that contains the
     trigger vocabulary for email work (email, gmail, inbox, draft, send);
   - an explicit `permission` entry `"gmail_*": "allow"` (the MCP-tool default
     of `ask` is never relied upon);
   - a body carrying the gmail tool-handling instructions and the email rules
     inherited from the email-management card: drafts default to a dry run,
     and every outward-facing send requires explicit developer instruction in
     the session.
3. The `email-management` skill description no longer describes direct gmail
   tool handling; it states email-intent recognition, dispatch to the
   email-ops subagent, and the outward-send authorization gate. The detailed
   tool workflows it previously carried live in the card body.
4. Deck task cards whose workflows send email mid-task (issue and spec flows
   were observed doing so in session history) carry a line routing email
   actions through the email-ops dispatch.

## Success criteria

- **SC-1 (behavioral).** In a fresh main-agent session under the deck config,
  no tool whose name starts with `gmail_` is present in the session's toolset.
  Instrument: session toolset inspection via `opencode run` session evidence.
- **SC-2 (behavioral).** A session dispatched to the `email-ops` subagent has
  `gmail_*` tools available and completes a mailbox read (for example
  `gmail_list_mailboxes`) without a permission prompt. Instrument: behavioral
  run; the transcript shows the tool call succeeding with no ask/permission
  stall.
- **SC-3 (behavioral).** Given a developer request that involves email (for
  example "check my inbox for X"), the main agent routes the work by
  dispatching to `email-ops`. Instrument: behavioral run with that trigger
  phrasing; the transcript shows a task dispatch naming email-ops.
- **SC-4 (structural).** The deck config's `permission` block contains
  `"gmail_*": "deny"`, and the change's diff removes no `mcp` server
  definition from any config file. Instrument: direct config inspection of the
  implementation diff.
- **SC-5 (structural).** `.opencode/agent/email-ops.md` exists with
  `mode: subagent`, an explicit `"gmail_*": "allow"` permission entry, and a
  description of at most 30 words containing the trigger vocabulary named
  above. Instrument: file inspection and word count.
- **SC-6 (structural).** The `email-management` skill frontmatter description
  states recognition, email-ops dispatch, and the authorization gate, and no
  longer carries direct gmail tool-workflow text. Instrument: file inspection
  of the skill frontmatter.
- **SC-7 (behavioral).** First-turn `tokens.input` for a standard main-agent
  session (same model, minimal first prompt) is at least 1,500 tokens lower
  than the measured ~22.0K pre-change baseline. Instrument: the documented
  `opencode.db` query protocol (first assistant message of a fresh session,
  same model profile as the baseline measurements).

Items 3 and 4 touch governed deck surfaces (`skills/` content); the
deck-governance admission gate applies to those edits at implementation time
and is recorded here as a process obligation of the change, not as a success
criterion.

## Out of scope

- ragsync — not set up yet; excluded per developer instruction.
- The `tools/jupyter*` script purge — separate deck-debt item.
- The floor external-access table rewrite — a separate governed edit covering
  all three plugin changes (gmail, math, notebook).
- Relocating or deduplicating any MCP server definition between global and
  project config.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
