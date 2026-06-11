# [SPEC-FIX] Issue Comment Churn Regression — restore channel-routing, fix completion-core templates, re-harden verification enforcement

## Summary

Commit `ab2350fa` ("Context window pollution reduction") removed 9,179 lines across 84 files and introduced three regressions. The primary regression is AI agents posting non-substantive status updates ("I made a PR", "Phase complete", AI byline standalone posts) to GitHub Issues as comments, causing stakeholder confusion and issue tracker churn. The secondary regressions are diluted verification enforcement structure and removed spec-audit findings leak protection.

## Root Cause

Commit `ab2350fa` (author: Michael Conrad, date: 2026-04-12). A single 84-file, 9,179-line deletion commit that restructured `000-critical-rules.md` (66% reduction), pruned `AGENTS.md` (66% reduction), restructured 25 SKILL.md files, lazy-loaded two guidelines, and added sub-agent spawning instructions. The channel-routing table from #608 was removed as "context window pollution" — but with it went the enforcement structure that prevented non-substantive issue comments.

Three skills were deleted entirely: `github-comments` (issue comment governance, absorbed by `issue-operations`), `github-sub-issues` (absorbed by `issue-operations`), and `subagent-driven-development` (absorbed elsewhere).

## Affected Systems

- `.opencode/guidelines/000-critical-rules.md` — channel-routing table removed, FORBIDDEN/REQUIRED sections collapsed, "Why This Matters" tables removed
- `.opencode/skills/completion-core/tasks/completion.md` — Step 3 mandates "post a progress comment" with Phase/Implemented/Verified/Remaining template (primary regression vector)
- `.opencode/skills/finishing-a-development-branch/tasks/completion.md` — mandatory "post status comment on issue"
- `.opencode/skills/git-workflow/tasks/completion.md` — mandatory "post status comment on issue"
- `.opencode/guidelines/020-go-prohibitions.md` — "Posting progress comments to GitHub — always permitted" listed as authorization-free
- `.opencode/guidelines/080-code-standards.md` — byline rules require `🤖` on every comment

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | Channel-routing table restored in `000-critical-rules.md` mapping Action to Channel (chat vs issue) — with yaml+symbolic rule | `behavioral` |
| SC-2 | `completion-core/tasks/completion.md` Step 3 changed from "post a progress comment" to "route through issue-operations -> comment (substantive gate)" | `string` |
| SC-3 | All 9 mandatory "post to issue" instructions in skill task files changed to route through `issue-operations -> comment` substantive gate | `string` |
| SC-4 | FORBIDDEN/REQUIRED structure and "Why This Matters" tables restored in `000-critical-rules.md` | `string` |
| SC-5 | Spec-audit findings leak prohibition restored in `000-critical-rules.md` | `string` |
| SC-6 | Behavioral enforcement test exists that sends a "phase complete" prompt and verifies the agent does NOT post it as an issue comment | `behavioral` |
| SC-7 | `020-go-prohibitions.md` "progress comments always permitted" removed or qualified to route through substantive gate | `string` |
| SC-8 | The `issue-operations/tasks/comment.md` substantive gate is evaluated by callers BEFORE the caller commits to posting, not after | `behavioral` |