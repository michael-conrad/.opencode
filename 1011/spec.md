# [SPEC] tools/plan MCP layer — MCP server, regenerate-loop enforcement, fail-closed defaults

**STATUS: 0.1 (DRAFT — follow-on to #980)**

## Purpose

After #980 ships the working CLI `tools/plan` PEP 723 utility, add an MCP server mode, regenerate-loop enforcement, and fail-closed defaults as a separate MCP wrapper.

## Prerequisite

**#980 must ship first.** This spec builds on top of the CLI tool. The MCP server calls `tools/plan plan`, `tools/plan validate`, etc. via subprocess — it does not reimplement the planning logic.

## Scope

| Component | Spec | Status |
|-----------|------|--------|
| `tools/plan` CLI PEP 723 utility | #980 | Ships first |
| MCP server mode + regenerate-loop + fail-closed | #1011 | Follow-on |
| `tools/plan repair` subcommand | #1011 | Follow-on — auto-repair after validate FAIL |

## MCP Server

A separate wrapper script or config at `.opencode/tools/plan-mcp` that:

1. Spawns `tools/plan` CLI as subprocess for all planning operations
2. Exposes domain tools via STDIO MCP protocol
3. Wraps CLI output/errors into MCP tool responses

## Regenerate-Loop Enforcement

`validate` currently returns PASS/FAIL via exit code. The MCP layer enforces the loop at the wrapper level:

- On `validate` FAIL (exit 2): wrapper calls `repair` automatically, returns composite result
- Agent sees validated plan or unrepairable error — never sees raw FAIL without repair attempt

## Fail-Closed Default

MCP wrapper defaults to fail-closed: if subprocess times out, returns unexpected output, or engine fails → tool response says BLOCKED, not PASS.

## Files

- `.opencode/tools/plan-mcp` — MCP wrapper script (separate from #980's CLI utility)
- `.opencode/opencode.jsonc` — MCP server registration

## Relationship to #980

| Capability | #980 CLI | #1011 MCP layer |
|-----------|----------|-----------------|
| `plan plan` | ✅ Ships here | ✅ Wraps via subprocess |
| `plan validate` | ✅ Ships here | ✅ Wraps + adds enforce loop |
| `plan repair` | ❌ | ✅ New subcommand |
| `plan mcp` | ❌ | ✅ MCP server |
| Fail-closed | ❌ (CLI returns raw exit code) | ✅ Wrapper enforces |
| MCP config | ❌ | ✅ Registered in opencode.jsonc |
| Behavioral SC-13 | ❌ | ✅ Tests agent respects FAIL gate |

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)