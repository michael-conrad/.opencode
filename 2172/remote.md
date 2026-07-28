---
remote_issue: 2172
remote_url: "https://github.com/michael-conrad/.opencode/issues/2172"
last_sync: 2026-07-28T10:35:00-04:00
source: github.com
---

## Problem

The session-init script outputs developer identity, repo information, and branch state, but does not include a timestamp. The AI agent has no awareness of what time period it is operating in — it cannot distinguish between a session started at 09:00 and one started at 17:00, or between a session on Monday and one on Friday.

## Success Criteria

- SC-1: session-init emits a human-readable datetime stamp including date, day of week, time, and timezone
- SC-2: The timestamp appears after the Git branch line and before the ## CLI Auth Status section
- SC-3: The format is natural English prose, not structured key:value — e.g. "Session started: Saturday, July 25, 2026 at 19:17 EDT"
- SC-4: The timestamp is generated at runtime (not hardcoded) using Python's datetime module
- SC-5: The timezone is local time with explicit UTC offset (e.g. UTC+5:30, UTC-4, UTC+0) — not bare UTC

## Approach

Add a single print line to the session-init script's main() function that emits the current local datetime in human-readable format with the local timezone abbreviation.

## Affected Files

- .opencode/tools/session-init

## Evidence Types

| ID | Evidence Type | Verification Method |
|----|--------------|-------------------|
| SC-1 | behavioral | Run session-init, verify output contains human-readable datetime with all required components |
| SC-2 | string | grep for the line position relative to Git branch and CLI Auth Status |
| SC-3 | string | grep for the exact format pattern |
| SC-4 | structural | Inspect source code for datetime.now() or equivalent call |
| SC-5 | string | grep for timezone abbreviation (not UTC offset) in the output

---

*Migrated from michael-conrad/opencode-config#352 — filed against wrong repo.*
