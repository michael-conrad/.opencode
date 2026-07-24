---
remote_issue: 2108
remote_url: "https://github.com/michael-conrad/.opencode/issues/2108"
last_sync: "2026-07-24T22:52:38Z"
source: github
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

## Fix

The "requires VPN" language is false. Remove it from all specs and AGENTS.md files. Tests use mocks — they never connect to the real database. The `StagingReader(true)` constructor exists specifically to avoid DB connections in tests.

## Prevention

Add a verification gate: any spec or AGENTS.md that claims a resource is unreachable must be verified by an actual tool call before that language is included. Fabricated connectivity constraints must not propagate.