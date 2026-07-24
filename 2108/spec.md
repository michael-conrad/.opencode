---
number: 2108
title: "[BUG] Fabricated 'requires VPN' language keeps getting added back to specs"
state: OPEN
approved: for_pr
---

## Summary

Specs and AGENTS.md files in this repo keep getting "requires VPN or office network" language added to them for database connections that are always available without a VPN. This is fabricated information that gets parroted from stale spec text without verification.

## Root Cause

1. An initial spec or AGENTS.md includes "requires VPN" as a caveat
2. Downstream agents copy that language verbatim into new specs without checking whether the DB is actually reachable
3. The language propagates through the codebase as cargo-cult boilerplate

## Evidence

- `WeekliesXmlExport/AGENTS.md` line 22: "requires VPN or office network"
- `WeekliesXmlExport/.issues/188/spec.md` line 107: "All tests connect to test_butter at mysql.newsrx.com (requires VPN/office network)"
- The existing tests in `WeekliesXmlExport/src/test/` all use `MockStagingReader` (extends `StagingReader(true)` — test-only constructor, no DB connection needed). No test actually requires a VPN.

## Affected Files

| File | Change |
|------|--------|
| `WeekliesXmlExport/AGENTS.md` | Remove "requires VPN or office network" from line 22 |
| `WeekliesXmlExport/.issues/188/spec.md` | Remove "requires VPN/office network" from line 107 |
| `.opencode/AGENTS.md` | Add verification gate for connectivity claims |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | "requires VPN or office network" removed from `WeekliesXmlExport/AGENTS.md` line 22 | `string` | `grep` for "VPN" in file — must return no match |
| SC-2 | "requires VPN/office network" removed from `WeekliesXmlExport/.issues/188/spec.md` line 107 | `string` | `grep` for "VPN" in file — must return no match |
| SC-3 | `.opencode/AGENTS.md` contains a verification gate requiring tool-call evidence before any connectivity constraint claim is included in agent-facing text | `string` | `grep` for connectivity verification language in `.opencode/AGENTS.md` |
| SC-4 | Behavioral enforcement test exists that sends a prompt asking about database connectivity and verifies the agent does NOT fabricate VPN/network constraints without a tool call | `behavioral` | `opencode run` with `with-test-home` wrapper; assert agent does not include unverified connectivity claims in output |

## Prevention

Add a verification gate to `.opencode/AGENTS.md`: any spec or AGENTS.md that claims a resource is unreachable must be verified by an actual tool call before that language is included. Fabricated connectivity constraints must not propagate.

## Change Control

| Date | Change | Reason | Authorized By |
|------|--------|--------|---------------|
| 2026-07-24 | Added success criteria table with evidence types, affected files section, and SC-4 behavioral enforcement test requirement | Bug report was narrative-only with no SCs; research completed on AI agent fabrication of connectivity constraints | `for_pr` scope authorization |
