---
remote_issue: 2310
remote_url: "https://github.com/michael-conrad/.opencode/issues/2310"
last_sync: 2026-08-20T18:30:00Z
source: github
---

## Summary
`scripts/session_context_triggers.py` line 70 runs `git diff --stat origin/dev..HEAD`. The SEC-Filings-Scraper repo removed its `dev` branch (trunk-based development on `master`). This command fails against `origin/dev`.

## Evidence
```
sed -n "70p" scripts/session_context_triggers.py
# diff_stat = run_git(["diff", "--stat", "origin/dev..HEAD"])
```

## Expected
Resolve the trunk dynamically via `$DEFAULT_BRANCH` (`git remote show origin` HEAD branch), not hardcoded `origin/dev`.