# Investigate SearXNG MCP as DuckDuckGo Search Alternative

## Problem

DuckDuckGo's public API (`ddg-search`) is rate-limited and subject to bot detection. When DDG fails, there is no configured fallback search mechanism in the opencode config.

## Investigation Scope

1. **SearXNG MCP server** (`searxng-mcp` — Python package, runs via `uvx`, zero pip deps)
   - Can connect to public SearXNG instances (no self-hosting required)
   - Examples: `https://search.bus-hit.me`, `https://searx.tiekoetter.com`
   - Source: [searxng-mcp on PyPI](https://pypi.org/project/searxng-mcp/)

2. **Other search MCP alternatives** for comparison:
   - tavily-mcp (Tavily API, free tier 1000/mo)
   - brave-search-mcp (Brave Search API, free tier 2000/mo)
   - serpapi-mcp (SerpAPI, free tier 100/mo)
   - kagi-search-mcp (Kagi API, paid $5/mo)

3. **Tor/Onion routing** for DDG — no known MCP server does this; SearXNG behind Tor is the viable path

## Key Questions

- What are the rate limits and reliability of public SearXNG instances?
- How do these alternatives compare on result quality, API stability, and privacy?
- Should opencode config add a fallback search strategy (e.g., try DDG → SearXNG → Brave)?
- What is the minimal config change to integrate any of these as an MCP server?

## Success Criteria

- [ ] Survey all viable search MCP servers with their rate limits and API requirements
- [ ] Test connectivity to at least 2 public SearXNG instances
- [ ] Produce a recommendation: which single server (or combo) should be added to opencode.jsonc
- [ ] Document the config change needed (env vars, command, URL references)

## Research Gaps

- No existing research card on search MCP alternatives in this repo

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->
