---
remote_issue: 2307
remote_url: "https://github.com/michael-conrad/.opencode/issues/2307"
last_sync: 2026-08-20T18:28:12Z
source: github.com
---

## Summary
`skills/git-workflow/enforcement/url_validation.sh` line 18 hardcodes `local base="dev"`. The default branch is `master` (trunk-based development). This produces incorrect compare/validation URLs.

## Evidence (live)
```bash
sed -n '18p' skills/git-workflow/enforcement/url_validation.sh
#     local base="dev"
```

## Expected
Resolve base via `git remote show origin | grep 'HEAD branch'` (i.e. `$DEFAULT_BRANCH`), not a hardcoded `dev`.
