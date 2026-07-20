## Summary

**This issue is SUPERSEDED by #1632 under trunk-based development.**

Pre-push Gate 1 of the pre-push hook (merged branch topology check) referenced `origin/dev` for its merged-branch check. Under trunk-based development, there is no `dev` branch — only `origin/main` (the trunk). The entire Gate 1 logic must be redesigned.

See https://github.com/michael-conrad/.opencode/issues/1632 for the replacement spec.

## Original Problem (Historical)

Gate 1 of the pre-push hook (merged branch topology check) blocks force-pushes to branches that exist in `origin/dev`'s history, even when the branch has an open PR against `main` that needs updating. This was a false positive for release promotion branches (`release/dev-to-main-*`).

## Why This Is Moot

Under trunk-based development:
- There is no `origin/dev` to check against
- There are no release promotion branches (`release/dev-to-main-*`)
- Feature branches merge directly to `main` (the trunk)
- Gate 1 must check against `origin/main` instead

## Replacement

https://github.com/michael-conrad/.opencode/issues/1632 — [SPEC] Redesign pre-push Gate 1 for trunk-based development

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)