## Problem
The `finishing-a-development-branch` checklist gate mandates creating GitHub sub-issues for every plan phase when the sub-issue count does not match the phase count — even when the plan is ALREADY fully implemented, verified, and audited. During the #2264/#2271 for_pr pipeline, this gate fired on completed work and produced 10 retrospective task tickets (#2273–#2282, one per plan phase) that tracked nothing — the work they described was already done. The developer had to manually close all 10. Plan-phase sub-issues are noise: they pollute the public issue tracker with tickets whose work is complete, and they create false closure obligations (PR creation collects sub-issues and auto-closes them on merge). The leak is compounded: the 10 sub-issue bodies (#2273–#2282) contained full plan phase prose — Field/Value tables, Context YAML blocks, and Procedure steps — copied verbatim from the local plan files. Plan content that belongs ONLY in the local `.issues/{N}/` spec folder was posted to the public issue tracker.

## Root Cause
`finishing-a-development-branch/tasks/checklist.md` line 110 (Sub-Issue Linkage Verification section) reads: "If the plan has multiple phases, verify that get_sub_issues count on the plan issue matches the number of phases in the plan body. If counts don't match, run issue-operations --task link-sub-issue to create missing linkages before proceeding to review-prep". This mandate is unconditional — it does not check whether the phases are already implemented. It fires at branch-finishing time (post-implementation), when creating sub-issues is pure retrospective bookkeeping. The operating protocol reinforces it (item 6 "Plan sub-issue closure verification" + exit criteria "Plan sub-issues verified"). The gate's intent (tracking phase execution) is only valid BEFORE implementation begins; at finishing time it is a false-positive FAIL that forces noise creation. The sub-issue bodies themselves were populated from the local plan files — the `link-sub-issue` flow copied plan phase prose (Field/Value tables, Context YAML blocks, Procedure steps) into the public issue bodies, violating the developer mandate that plan files and plan content live ONLY in the local spec folder and are NEVER posted to the public issue tracker.

## Success Criteria
| ID | Criterion | Evidence Type | Verification Method | Documentation Sources |
|----|-----------|---------------|---------------------|----------------------|
| SC-1 | The Sub-Issue Linkage Verification section in `finishing-a-development-branch/tasks/checklist.md` SHALL be removed or rewritten so it NEVER instructs creating sub-issues for plan phases at branch-finishing time. | string | grep checklist.md for `link-sub-issue` → absent or replaced with a no-create rule | `.opencode/skills/finishing-a-development-branch/tasks/checklist.md` (code) |
| SC-2 | `finishing-a-development-branch/tasks/operating-protocol.md` SHALL no longer require "Plan sub-issue closure verification" or "Plan sub-issues verified" as a readiness gate. | string | grep operating-protocol.md for `sub-issue` → absent or replaced | `.opencode/skills/finishing-a-development-branch/tasks/operating-protocol.md` (code) |
| SC-3 | A behavioral enforcement test SHALL verify that an agent running the branch-finishing checklist on a fully-implemented multi-phase plan does NOT create any sub-issues. | behavioral | `opencode run` via with-test-home; clean-room session.yaml evaluation confirms zero `link-sub-issue`/sub-issue creation calls | `.opencode/skills/finishing-a-development-branch/tasks/checklist.md` (code); `.opencode/tests-v2/` (test harness) |
| SC-4 | `git-workflow-pr/tasks/pr-creation/create-pr.md` SHALL NOT auto-close plan-phase sub-issues on PR merge (sub-issues that exist for other reasons must not be swept into autoclose). | string | grep create-pr.md for `autoclose_issues` → sub-issue collection removed or gated | `.opencode/skills/git-workflow-pr/tasks/pr-creation/create-pr.md` (code) |
| SC-5 | Plan content (phase tables, context YAML, procedure steps) SHALL NOT be posted to public issue bodies; plan files live only in the local `.issues/{N}/` spec folder. | string | grep public issue bodies for plan phase markers (e.g., 'Parent Plan', 'Field | Value') → absent | `.opencode/skills/issue-operations-sub-issues/tasks/link-sub-issue.md` (code) |

## Approach
1. Remove/replace the Sub-Issue Linkage Verification gate in checklist.md with a no-create rule (sub-issues are NEVER created at finishing time; if sub-issues exist they are read-only references). 2. Remove the sub-issue closure verification from operating-protocol.md readiness gates. 3. Add behavioral enforcement test asserting zero sub-issue creation during branch finishing. 4. Fix create-pr.md autoclose to not sweep plan-phase sub-issues.

## Evidence
- Incident: 10 sub-issues #2273–#2282 created retrospectively for already-implemented plans #2264 (7 phases) and #2271 (3 phases) during branch finishing; all 10 manually closed by developer.
- Plan-content leak: sub-issue bodies #2273–#2282 contained full plan phase prose (Field/Value tables, Context YAML blocks, Procedure steps) copied from the local plan files — plan content posted to the public issue tracker.
- `finishing-a-development-branch/tasks/checklist.md:110` — unconditional link-sub-issue mandate at finishing time.
- `finishing-a-development-branch/tasks/operating-protocol.md:15,24` — sub-issue closure verification + exit criteria.
- `git-workflow-pr/tasks/pr-creation/create-pr.md:123-124` — `autoclose_issues = [<parent>] + [sub["number"] for sub in sub_issues]` sweeps sub-issues into PR merge autoclose.

## Out of scope
- Removing the sub-issue API capability itself (issue-operations-sub-issues skill) — sub-issues may have legitimate pre-implementation tracking uses.
- Changing the multi-task authorization cascade model.

## Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- SC-1: Verifying the Sub-Issue Linkage Verification section is removed or rewritten costs one grep of checklist.md. Skipping means the unconditional link-sub-issue mandate persists and the next branch-finishing run floods the public tracker with retrospective tickets that must be manually closed.
- SC-2: Verifying operating-protocol.md no longer requires sub-issue closure verification costs one grep. Skipping means the readiness gate still fails on a fully-implemented multi-phase plan, blocking branch finishing with a false-positive FAIL.
- SC-3: Running the behavioral enforcement test costs minutes of execution time. Skipping means a regression that reintroduces retrospective sub-issue creation ships undetected and costs 1000× more to fix at production discovery.
- SC-4: Verifying create-pr.md no longer sweeps plan-phase sub-issues into autoclose costs one grep. Skipping means legitimate tracking sub-issues are silently closed on PR merge, erasing tracking state.
- SC-5: Verifying public issue bodies carry no plan-phase markers costs one repository grep. Skipping means plan content keeps leaking into the public tracker, exposing internal plan artifacts.

## Change Control

- 2026-08-11: Added SC-5 (plan content SHALL NOT be posted to public issue bodies; plan files live only in the local `.issues/{N}/` spec folder) per developer revision request. Updated Problem and Root Cause sections to mention the plan-content leak (sub-issue bodies #2273–#2282 contained Field/Value tables, Context YAML blocks, and Procedure steps copied from local plan files). Added the plan-content leak evidence bullet. SC-1 through SC-4 preserved unchanged.
- 2026-08-11: Format-level validation revision. Added `## Cost Frame` section with per-SC cost-frame language (action cost / skipping cost per `reference/cost-model-standards.md` §Per-SC Cost-Frame Format) — each SC carries a cost-frame statement. Added the Documentation Sources column (5th) to the SC table naming the source file(s) each SC's verification targets. All 5 SCs' content preserved unchanged. Authorized by: revision request for issue 2283.

🤖 OpenCode (ollama-cloud/deepseek-v4-flash) created
