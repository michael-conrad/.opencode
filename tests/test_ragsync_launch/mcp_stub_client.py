#!/usr/bin/env python3
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-authored, .opencode#2624 (SC-7/SC-8 pr-validation MCP stub client)

"""MCP stdio stub client for the 2624 pr-validation fixtures.

argv[1] = JSON file with the command to launch (the wrapper chain — this stub
is the MCP client, the parent of the wrapper, exactly the deployment shape).
argv[2] = seconds to stay connected-and-idle before acting (SC-7 window).
argv[3] = optional search query (SC-8 mode): after the window, call
`list_sources` and `search(query)`; print both results.

Exits 0 on success.

Run under `uv run --script --with "mcp<2"` (the mcp 1.x client the server is
built against).
"""

import asyncio
import json
import sys

from mcp import ClientSession, StdioServerParameters
from mcp.client.stdio import stdio_client


async def main() -> int:
    command = json.loads(open(sys.argv[1]).read())
    idle_window = float(sys.argv[2])
    query = sys.argv[3] if len(sys.argv) > 3 else None
    params = StdioServerParameters(command=command[0], args=command[1:])
    async with stdio_client(params) as (read, write):
        async with ClientSession(read, write) as session:
            await session.initialize()
            await asyncio.sleep(idle_window)
            result = await session.call_tool("list_sources", {})
            payload = [c.text for c in result.content if hasattr(c, "text")]
            print("LIST_SOURCES_RESULT:" + " | ".join(payload))
            if query is not None:
                result = await session.call_tool("search", {"query": query})
                payload = [c.text for c in result.content if hasattr(c, "text")]
                print("SEARCH_RESULT:" + " | ".join(payload))
            return 0


if __name__ == "__main__":
    sys.exit(asyncio.run(main()))
