## Summary

Add the `web-search-mcp.py` example from the official ollama-python repository as a PEP 723 inline-script MCP server in `.opencode/tools/`. This exposes Ollama's hosted `web_search` and `web_fetch` APIs as MCP tools, giving the AI agent a secondary, Ollama-native search backend alongside the existing DuckDuckGo web search. The script pins its Python interpreter to the 3.12 series (`requires-python = "~=3.12.0"`) so `uv run` provisions and selects a 3.12.x interpreter with no shell wrapper and no `--python` flag in the MCP stanza.

## Motivation

The agent already has web search and web fetch tools via DuckDuckGo and general fetch backends. However:

1. **Search backend diversity**: Ollama's hosted search API uses a different infrastructure than DuckDuckGo — it may serve different content, provide different freshness, or be available when DuckDuckGo is not.
2. **Ollama-native integration**: The Ollama Python SDK's `web_search` and `web_fetch` methods are first-class API endpoints designed for programmatic use, giving predictable result schemas.
3. **PEP 723 zero-install**: Because the script uses PEP 723 inline metadata, `uv run .opencode/tools/web-search-mcp.py` automatically provisions dependencies (`mcp`, `rich`, `ollama`) — no manual environment setup.
4. **Rejecting training data as stale**: A secondary independent search backend strengthens the "verify live" principle — the agent has more paths to verify claims against live sources, reducing the risk of falling back to stale training data.
5. **Pinned, compatible interpreter**: a bare floor (`>=3.NN`) lets `uv run` float onto untested future interpreters between environment bumps, and a hard `==` pin breaks as the ecosystem moves on. The three-part compatible release `~=3.NN.0` pins the minor series (`>=3.12.0, ==3.12.*`), verified on uv 0.11.19: `~=3.12.0` resolves 3.12.x and does not float to 3.13.

## Proposal

### 1. Add script: `.opencode/tools/web-search-mcp.py`

Copy the upstream script from `https://raw.githubusercontent.com/ollama/ollama-python/refs/heads/main/examples/web-search-mcp.py` with appropriate SPDX/provenance/co-author headers, replacing the upstream header's `requires-python = ">=3.11"` with `requires-python = "~=3.12.0"`.

The script is a PEP 723 inline-script (`# /// script` block) that creates an MCP stdio server with two tools:

| Tool | Parameters | Description |
|------|-----------|-------------|
| `web_search` | `query: str, max_results: int = 3` | Calls `ollama.Client().web_search()` |
| `web_fetch` | `url: str` | Calls `ollama.Client().web_fetch()` |

Supports both FastMCP (high-level) and low-level stdio server (fallback) APIs.

### 2. Python version pinning

- The PEP 723 header is the single source of truth for the interpreter: `requires-python = "~=3.12.0"`. uv selects a compatible interpreter and downloads one if no 3.12.x is installed.
- No shell script wrapper and no `--python` flag in the MCP `command`. opencode's `command` is a plain argv array, so a flag could be inserted, but an explicit `--python` overrides the header with only a warning on conflict (exit 0 in both directions, verified on uv 0.11.19); omitting it keeps one source of truth.
- First-launch caveat: on a machine with no 3.12.x interpreter, uv downloads one before the server starts, which can exceed opencode's default MCP `timeout` (5000 ms) and fail tool discovery. Pre-install the interpreter (`uv python install 3.12`) or raise `timeout` in the MCP entry.

### 3. Configure in `opencode.jsonc`

Add an `mcp` entry:

```jsonc
"ollama-web-search": {
  "type": "local",
  "command": ["uv", "run", ".opencode/tools/web-search-mcp.py"],
  "enabled": true,
  "environment": {
    "OLLAMA_API_KEY": "{env:OLLAMA_API_KEY}"
  }
}
```

The `OLLAMA_API_KEY` env var is required for the tools to function — the upstream docstring marks it `(required)`, and the ollama SDK raises an error on `web_search`/`web_fetch` without it; when set, it is used as the Authorization header. The `environment` block passes it through using opencode's `{env:VAR}` substitution syntax (opencode does not expand `${VAR}`).

### 4. Register in agent instructions or tool allowlist

Optionally register the tool names in the agent's tool allowlist so the agent is aware of and prompted to use them for research tasks.

## Verification

| SC | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | Script exists at `.opencode/tools/web-search-mcp.py` with PEP 723 header intact | structural |
| SC-2 | Script runs without import errors: `timeout 15 uv run .opencode/tools/web-search-mcp.py < /dev/null` exits 0 (stdin EOF ends the stdio server; an import error exits nonzero before the server loop) | behavioral |
| SC-3 | `opencode.jsonc` contains `ollama-web-search` MCP entry | string |
| SC-4 | MCP server exposes `web_search` and `web_fetch` tools (verify via `opencode mcp list` or MCP protocol handshake) | behavioral |
| SC-5 | Agent can invoke `web_search` and `web_fetch` tools in a test prompt | behavioral |
| SC-6 | PEP 723 header pins the interpreter with `requires-python = "~=3.12.0"` (three-part compatible release — not a bare floor, not a hard minor pin) | structural |
| SC-7 | `uv run .opencode/tools/web-search-mcp.py` resolves a Python 3.12.x interpreter (uv 0.11.19 verified: `~=3.12.0` → 3.12.x; a two-part `~=3.12` would float to 3.13) | behavioral |

## Affected Files

- `.opencode/tools/web-search-mcp.py` — NEW
- `.opencode/opencode.jsonc` — MODIFY (add MCP entry)

## Reference

- Source: https://raw.githubusercontent.com/ollama/ollama-python/refs/heads/main/examples/web-search-mcp.py
- PEP 723: https://peps.python.org/pep-0723/
- OpenCode MCP config (official): https://opencode.ai/docs/mcp-servers/ — `command` is "Command and arguments to run the MCP server" (argv array)
- uv scripts guide: https://docs.astral.sh/uv/guides/scripts/ — `requires-python` handling and per-invocation `--python` override semantics

🤖 Co-authored with AI: OpenCode (opencode/deepseek-v4-flash-free)
🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
