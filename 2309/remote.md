---
remote_issue: 2309
remote_url: "https://github.com/michael-conrad/.opencode/issues/2309"
last_sync: 2026-08-20T18:26:18Z
source: github.com
---

## Summary
`tools/session-init` line 36 references `dev branch: Create from origin/dev or main/master if missing`. The SEC-Filings-Scraper repo no longer has a `dev` branch (trunk-based development on `master`).

## Evidence
`sed -n "36p" tools/session-init` → `- dev branch: Create from origin/dev or main/master if missing`

## Expected
Resolve the trunk dynamically via `$DEFAULT_BRANCH`, not a hardcoded `dev`.