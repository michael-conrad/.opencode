---
question: "What MCP search servers are available as alternatives to DuckDuckGo for AI agent web search?"
findings:
  - "searxng-mcp (jason-oster, v0.2.0, MIT) — Python package wrapping SearXNG metasearch engine. Runs via uvx, zero pip deps, requires Python 3.11–<3.15. Connects to any SearXNG instance via SEARXNG_URL env var. Can use public instances (e.g., search.bus-hit.me, searx.tiekoetter.com) or self-hosted behind Tor."
  - "Tavily MCP — Python package, free tier 1000 queries/mo, clean structured results. Most popular DDG alternative."
  - "Brave Search MCP (@erikbrenninkmeijer/mcp-server-brave-search) — Node/npx, free tier 2000 queries/mo, very clean output."
  - "SerpAPI MCP — Google/Bing results via unified API, free tier 100 queries/mo."
  - "Kagi Search MCP — Kagi API, paid $5/mo, no ads, high-quality results."
  - "DDG .onion gateway does NOT work for MCP search servers — DDG's HTTP API returns a challenge page over Tor. No known MCP server routes through it. Self-hosting SearXNG behind Tor is the viable path for onion-routed search."
  - "SearXNG public instances are listed at searx.space with uptime, location, and HTTPS status."
confidence: 0.75
sources:
  - "https://pypi.org/pypi/searxng-mcp/json — package metadata (v0.2.0, Python 3.11–<3.15, zero deps)"
  - "https://searx.space — public SearXNG instance directory"
  - "https://github.com/jason-oster/searxng-mcp — source repo"
tags:
  - mcp-server
  - search-engine
  - duckduckgo-alternative
  - searxng
  - tor-onion
  - research
created: "2026-06-28"
confidence: 0.75
---
