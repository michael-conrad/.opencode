---
remote_issue: 2308
remote_url: "https://github.com/michael-conrad/.opencode/issues/2308"
last_sync: 2026-08-20T18:27:32Z
source: github
---

## Summary

`skills/git-workflow-cleanup/tasks/cleanup.md` contains multiple hardcoded references to a `dev` branch as the integration trunk ("at dev tip", "local dev HEAD", "matches origin/dev"). The SEC-Filings-Scraper repo removed its fully-merged `dev` branch in favor of trunk-based development on `master` (issue #50). These references are stale.

## Evidence (live)

- Line 141: `Get local dev HEAD:`
- Line 166: `If hashes match → repo is at dev tip`
- Line 180: `All repos at dev tip: Report "All repos at dev tip — ready for next dev cycle"`
- Line 329: `Every repo's local dev HEAD matches origin/dev`

## Expected

References to a `dev` trunk/tip should resolve the trunk dynamically via `$DEFAULT_BRANCH` (per `git remote show origin` → HEAD branch), matching the trunk-based-development model.

## Scope

Documentation/task-card fix in this repo. No functional code change to SEC-Filings-Scraper.