# Implementation Plan — Ollama web-search MCP server (#811)

Derived entirely from `.opencode/.issues/811/spec.md` (SC-1 … SC-7).
Implementation surface: `.opencode/tools/web-search-mcp.py` (new PEP 723
inline-script MCP server) + `.opencode/opencode.jsonc` (MCP entry). Behavioral
evidence for SC-5 is produced through the tests-v2 harness
(`.opencode/tests-v2/`, per its AGENTS.md contract).

## Item 1 — Script artifact with pinned header (SC-1, SC-6)

- **Deliverable:** `.opencode/tools/web-search-mcp.py` — the upstream
  ollama-python example with SPDX/provenance/co-author headers and the PEP 723
  header changed from `requires-python = ">=3.11"` to
  `requires-python = "~=3.12.0"`.
- **RED:** file does not exist; both header assertions fail against current
  state.
- **GREEN:** fetch the upstream source, apply the header replacement and
  provenance headers, write the file.
- **Instrument:** fact-decidable — file exists at the path; header block
  contains `requires-python = "~=3.12.0"`; provenance headers present;
  dependencies block lists `mcp`, `rich`, `ollama`.

## Item 2 — Script runs without import errors (SC-2)

- **Deliverable:** executable script state (no code beyond item 1).
- **RED:** the instrument command fails today (file absent → nonzero exit).
- **GREEN:** satisfied by item 1's artifact; no further change.
- **Instrument:** behavioral — `timeout 15 uv run .opencode/tools/web-search-mcp.py < /dev/null` exits 0 (stdin EOF ends the stdio server; an
  import error exits nonzero before the server loop). Depends: item 1.

## Item 3 — Interpreter resolution (SC-7)

- **Deliverable:** property of item 1's header (verification-only).
- **RED:** no script exists to resolve an interpreter for; assertion fails.
- **GREEN:** satisfied by item 1's `~=3.12.0` pin; no further change.
- **Instrument:** behavioral — `uv run .opencode/tools/web-search-mcp.py < /dev/null` resolves a Python 3.12.x interpreter (observe via uv's
  verbose resolution log, or a same-header probe printing
  `sys.version_info` minor == 12). Depends: item 1.

## Item 4 — MCP entry in opencode.jsonc (SC-3)

- **Deliverable:** `ollama-web-search` entry in `.opencode/opencode.jsonc`:
  `type: local`, `command: ["uv", "run", ".opencode/tools/web-search-mcp.py"]`,
  `enabled: true`, `environment.OLLAMA_API_KEY: "{env:OLLAMA_API_KEY}"`.
- **RED:** string check for `ollama-web-search` in opencode.jsonc fails today.
- **GREEN:** add the entry alongside existing `mcp` entries (placement per the
  file's current structure).
- **Instrument:** fact-decidable — file JSONC-parses; entry present with the
  four keys in the `{env:VAR}` form. Depends: item 1 (command references the
  script).

## Item 5 — Server exposes both tools (SC-4)

- **Deliverable:** integration state of items 1 + 4 (no further code).
- **RED:** `opencode mcp list` shows no `ollama-web-search` tools today.
- **GREEN:** with items 1 + 4 in place, tool discovery lists `web_search` and
  `web_fetch` under `ollama-web-search`.
- **Instrument:** behavioral — `opencode mcp list` (or MCP protocol
  handshake) shows both tools. Tool discovery does not call the Ollama API,
  so no key is needed for this item. Depends: items 1, 4.

## Item 6 — Agent invocation via tests-v2 (SC-5)

- **Deliverable:** behavioral test scenario under `.opencode/tests-v2/` in
  which an agent session, given a research prompt, invokes the
  `ollama-web-search` `web_search` and `web_fetch` tools successfully.
- **RED:** no scenario exercises these tools; the assertion has no evidence.
- **GREEN:** scenario authored and passes, producing session.yaml evidence
  per the tests-v2 AGENTS.md contract (behavior_run + clean-room evaluation).
- **Instrument:** behavioral — tests-v2 harness evidence only (verify card
  rule 8; an ad-hoc `opencode run` produces no consumable evidence). Requires
  `OLLAMA_API_KEY` for the real API calls. Depends: items 1, 4, 5.
