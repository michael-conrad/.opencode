## Problem
The `finishing-a-development-branch` checklist gate mandates creating GitHub sub-issues for every plan phase when the sub-issue count does not match the phase count — even when the plan is ALREADY fully implemented, verified, and audited. During the #2264/#2271 for_pr pipeline, this gate fired on completed work and produced 10 retrospective task tickets (#2273–#2282, one per plan phase) that tracked nothing — the work they described was already done. The developer had to manually close all 10. Plan-phase sub-issues are noise: they pollute the public issue tracker with tickets whose work is complete, and they create false closure obligations (PR creation collects sub-issues and auto-closes them on merge).

## Root Cause
`finishing-a-development-branch/tasks/checklist.md` line 110 (Sub-Issue Linkage Verification section) reads: "If the plan has multiple phases, verify that get_sub_issues count on the plan issue matches the number of phases in the plan body. If counts don't match, run issue-operations --task link-sub-issue to create missing linkages before proceeding to review-prep". This mandate is unconditional — it does not check whether the phases are already implemented. It fires at branch-finishing time (post-implementation), when creating sub-issues is pure retrospective bookkeeping. The operating protocol reinforces it (item 6 "Plan sub-issue closure verification" + exit criteria "Plan sub-issues verified"). The gate's intent (tracking phase execution) is only valid BEFORE implementation begins; at finishing time it is a false-positive FAIL that forces noise creation.

## Success Criteria
| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | The Sub-Issue Linkage Verification section in `finishing-a-development-branch/tasks/checklist.md` SHALL be removed or rewritten so it NEVER instructs creating sub-issues for plan phases at branch-finishing time. | string | grep checklist.md for `link-sub-issue` → absent or replaced with a no-create rule |
| SC-2 | `finishing-a-development-branch/tasks/operating-protocol.md` SHALL no longer require "Plan sub-issue closure verification" or "Plan sub-issues verified" as a readiness gate. | string | grep operating-protocol.md for `sub-issue` → absent or replaced |
| SC-3 | A behavioral enforcement test SHALL verify that an agent running the branch-finishing checklist on a fully-implemented multi-phase plan does NOT create any sub-issues. | behavioral | `opencode run` via with-test-home; clean-room session.yaml evaluation confirms zero `link-sub-issue`/sub-issue creation calls |
| SC-4 | `git-workflow-pr/tasks/pr-creation/create-pr.md` SHALL NOT auto-close plan-phase sub-issues on PR merge (sub-issues that exist for other reasons must not be swept into autoclose). | string | grep create-pr.md for `autoclose_issues` → sub-issue collection removed or gated |

## Approach
1. Remove/replace the Sub-Issue Linkage Verification gate in checklist.md with a no-create rule (sub-issues are NEVER created at finishing time; if sub-issues exist they are read-only references). 2. Remove the sub-issue closure verification from operating-protocol.md readiness gates. 3. Add behavioral enforcement test asserting zero sub-issue creation during branch finishing. 4. Fix create-pr.md autoclose to not sweep plan-phase sub-issues.

## Evidence
- Incident: 10 sub-issues #2273–#2282 created retrospectively for already-implemented plans #2264 (7 phases) and #2271 (3 phases) during branch finishing; all 10 manually closed by developer.
- `finishing-a-development-branch/tasks/checklist.md:110` — unconditional link-sub-issue mandate at finishing time.
- `finishing-a-development-branch/tasks/operating-protocol.md:15,24` — sub-issue closure verification + exit criteria.
- `git-workflow-pr/tasks/pr-creation/create-pr.md:123-124` — `autoclose_issues = [<parent>] + [sub["number"] for sub in sub_issues]` sweeps sub-issues into PR merge autoclose.

## Out of scope
- Removing the sub-issue API capability itself (issue-operations-sub-issues skill) — sub-issues may have legitimate pre-implementation tracking uses.
- Changing the multi-task authorization cascade model.

🤖 OpenCode (ollama-cloud/deepseek-v4-flash) created
