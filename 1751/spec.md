> **Full spec and artifacts: `.opencode/.issues/1011/`**

## Exec Summary

After #980 ships the working CLI `tools/plan` PEP 723 utility, add an MCP server mode, regenerate-loop enforcement, and fail-closed defaults as a separate MCP wrapper. The MCP server calls `tools/plan plan`, `tools/plan validate`, etc. via subprocess — it does not reimplement the planning logic. On validate FAIL (exit 2), the wrapper calls repair automatically and returns a composite result.

### Cards (dependency order)
1. **MCP server wrapper** — spawns CLI as subprocess, exposes STDIO MCP protocol
2. **Regenerate-loop enforcement** — auto-repair on validate FAIL, agent never sees raw FAIL
3. **Fail-closed defaults** — timeout/unexpected output → BLOCKED, not PASS

### Key Decisions
- **Separate wrapper, not reimplementation** — MCP layer wraps #980's CLI via subprocess
- **Fail-closed default** — safer than fail-open for constraint validation

### Risk Callouts
- **#980 must ship first** — hard prerequisite, this spec builds on top of the CLI tool
- **repair subcommand is new** — not part of #980, added in this follow-on spec

## AI Agent Instructions

This issue is an executive summary for human stakeholders.
The authoritative spec and plan artifacts are at `.opencode/.issues/1011/`.
After creation, `local-issues sync 1011` MUST be run and the result committed to create the local `.issues/1011/` entry.
The implementation plan will be created in `.issues/1011/plan.md` after approval.
AI agents MUST read the local spec/plan files for implementation
and MUST NOT base implementation on this summary.

---
*Migrated from local tracking. Original local directory: `.opencode/.issues/1011/`*