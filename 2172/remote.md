---
remote_issue: 2172
remote_url: "https://github.com/michael-conrad/.opencode/issues/2172"
last_sync: 2026-07-28T10:35:00-04:00
source: github.com
---

**Problem:** session-init outputs developer identity, repo info, and branch state but no timestamp — the AI agent cannot distinguish session time periods.

**Success Criteria:**
- SC-1: session-init emits human-readable datetime (date, day of week, time, timezone)
- SC-2: Timestamp appears after Git branch line, before `## CLI Auth Status`
- SC-3: Natural English prose format — e.g. `"Session started: Saturday, July 25, 2026 at 19:17 EDT"`
- SC-4: Generated at runtime via Python's `datetime` module
- SC-5: Local time with local timezone abbreviation (not bare UTC)
- SC-6: Staleness warning `"This session start time indicates your training data is extremely stale and always must be re-researched..."` emitted on its own line after the timestamp

**Approach:** Add a single print line to session-init's `main()` emitting current local datetime.

**Affected Files:** `.opencode/tools/session-init`

**Evidence Types:** SC-1 behavioral, SC-2/3/5/6 string, SC-4 structural
