# Session Lessons: 2026-06-07 — Instructional Language in Professional Deliverables

## Summary

The PR body for PR #1051 contained "Wait for human to merge." as a mandated footer. User described this as "beyond lame" and "unprofessional." The source task files (`git-workflow/tasks/pr-creation/create-pr.md` and `pr-creation.md`) had this as a required format element. Fixed by removing the pattern from all mandated formats and replacing with silent halt discipline.

## Correction Catalog

### 1. "Wait for human to merge" — Instructional Language in PR Bodies

| Field | Detail |
|-------|--------|
| **What happened** | PR #1051 body contained `Wait for human to merge.` as a required footer line. User described this as "beyond lame" in PR bodies, issue tickets, and chat messages. |
| **Correction given** | User said "using text like 'wait for human to merge' in messaging, issue tickets, pr bodies, chat messages is beyond lame. add this to the lessons learned and fix the pr body to be professional." Replaced with silent HALT — no instruction language in the body. |
| **Root Cause** | The task file `create-pr.md` Step 7.5 mandated this as a required format element: `MUST include "Wait for human to merge"`. The task file treated the PR body as an instruction channel to the developer rather than a professional deliverable. |
| **Systemic?** | Yes — present in both `create-pr.md` (mandated format + format requirements list) and `pr-creation.md` (Operating Protocol step 4 + Exit Criteria). Also reflects a broader pattern of instructional language in agent-generated artifacts. |
| **Remediation target** | `skills/git-workflow/tasks/pr-creation/create-pr.md` Step 7.5 — removed "Wait for human to merge" from mandated format example and format requirements. `skills/git-workflow/tasks/pr-creation.md` — Operating Protocol step 4: "Wait for human to merge" → "No prompting for next steps". Exit Criteria: "Agent HALTs waiting for human merge" → "Agent reports PR URL and HALTs — no prompting for next steps". **Status: COMPLETED** — committed to `.opencode` submodule as `72577aba`, pushed to `feature/1046-1047-1048-1049`. |

## Systemic vs. One-Off Classification

| # | Issue | Systemic? | Action Required |
|---|-------|-----------|-----------------|
| 1 | "Wait for human to merge" instruction language in PR bodies | ✅ Systemic | Removed from create-pr.md and pr-creation.md mandated formats. See lesson #1 above. |

## Broader Principle

No instructional or prompting language in any professional deliverable. Professional deliverables are artifacts of record:

- **PR bodies** describe what was done and provide verification evidence
- **Issue comments** communicate status, findings, or blockers
- **Spec bodies** state requirements from a forward-looking stance
- **Plan documents** define RED/GREEN conditions and dependency order

None of these contain instructions to the reader about what to do next. A halt produces a status message describing what was completed — it does not contain instructions, suggestions, or forward-looking guidance. Instructional language ("Wait for", "Please", "Let me know when", "Ready for") is reserved for chat conversation context only, never for deliverable content.

Related: `000-critical-rules.md` §Silent Agent Termination — "a halt without output leaves the developer blind" — this is about producing STATUS OUTPUT, not instructions. The HALT rules already cover silent termination; this lesson clarifies that status output must not contain instructional language.