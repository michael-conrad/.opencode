---
title: '[SPEC] Durable-anchor citation rule: specs must not reference ephemeral artifacts'
remote_issue: 2327
remote_url: https://github.com/michael-conrad/.opencode/issues/2327
promoted_at: '2026-08-26T03:40:32+00:00'
---

## Problem

Specs and agent-facing documents cite ephemeral artifact paths (`tmp/**` behavioral-evidence and behavior-test dirs, test homes, lock files) that vanish by design at merge cleanup or accrete unmanaged, breaking citations. Filesystem checks cannot detect this because glob/grep are blind to gitignored paths. Three conflicting documented conventions exist for behavioral-evidence locations vs actual harness output.

## Note

Full spec body (problem statement, success criteria, approach, affected files) is being authored via the spec-creation pipeline from completed preliminary analytical artifacts; this shell exists as the issue-binding anchor and will be superseded by the formal body.

🤖 Co-authored with AI: OpenCode (opencode/x-preview-f-free)
