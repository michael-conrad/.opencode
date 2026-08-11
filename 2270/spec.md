> Full spec and plan artifacts: https://github.com/michael-conrad/.opencode/tree/issues-data/N/

## Problem

During implementation of a single `for_pr` authorization covering issues #2249 and #2264, the agent created TWO separate feature branches (`feature/2249-generic-di-mandate`, `feature/2264-submodule-trunk-lookup`) and created/opened-toward two concurrent PRs instead of ONE stacked PR. The required discipline is: one PR for the authorization scope, whose branch carries one commit per issue ticket at PR creation time. Multiple concurrent PRs cause merge conflicts (each rebase/squash breaks the sibling), hidden defects (the #2264 verification falsely flagged #2249 commits as contamination), and loss of proper human reviewability (reviewers cannot review one coherent change-set).

## Root Cause

The stacked-PR rule (`critical-rules-PR-ORG` "Stacked PR Is the Only Valid Organization") is declared in `.opencode/skills/git-workflow-pr/SKILL.md` line 89 and cross-referenced (line 74) as living in `.opencode/guidelines/000-critical-rules.md`, but it does NOT actually exist in `000-critical-rules.md` (grep count = 0). Additionally, the rule is enforced only by prose in the skill card — the behavioral enforcement test `stacked-pr-organization.sh` required by fixture spec `tests-v2/behaviors/fixtures/issues/100-stacked-branch-for-pr/spec.md` SC-4 does NOT exist as a scenario script. Without a critical-rule entry and without a behavioral test, the agent has no enforced gate preventing N-branch/N-PR creation for a single scope.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `critical-rules-PR-ORG` (or equivalent) SHALL be present in `.opencode/guidelines/000-critical-rules.md` with the "Stacked PR Is the Only Valid Organization" bright-line text (one branch, N commits, one PR per authorization scope; N branches for N issues is a critical violation). | string | grep `000-critical-rules.md` for `critical-rules-PR-ORG` |
| SC-2 | A behavioral enforcement test `stacked-pr-organization.sh` SHALL be added under `.opencode/tests-v2/behaviors/` that dispatches a real-domain prompt via `opencode run` requiring the agent to implement multiple issues under a single `for_pr` authorization, and verifies the agent creates exactly ONE feature branch and ONE PR (stacked commits, one per issue). | behavioral | Run the scenario via `with-test-home`; clean-room sub-agent reads `session.yaml` and confirms single-branch/single-PR creation. |
| SC-3 | `.opencode/skills/git-workflow-pr/SKILL.md` line 74 cross-reference SHALL resolve to the actual rule location (the rule MUST exist where the reference points). | string | grep confirms the referenced rule exists at the referenced path. |

## Approach

1. Add the `critical-rules-PR-ORG` rule to `000-critical-rules.md` (the text already exists in the SKILL.md — move/promote it to the canonical critical-rules location). 2. Write the behavioral enforcement test `stacked-pr-organization.sh` that forces the single-scope/multi-issue scenario and asserts one branch + one PR. 3. Fix the cross-reference so it points to the real location.

## Evidence

- `grep -c "PR-ORG" .opencode/guidelines/000-critical-rules.md` → `0` (rule missing from canonical location)
- `git-workflow-pr/SKILL.md:74` reads `Read [critical-rules-PR-ORG](guidelines/000-critical-rules.md)` but the target does not exist
- `git-workflow-pr/SKILL.md:89` contains the rule text but only in the skill card
- `find tests-v2 -name "stacked-pr-organization.sh"` → not found (behavioral test missing)
- Fixture `tests-v2/behaviors/fixtures/issues/100-stacked-branch-for-pr/spec.md` SC-4 requires `stacked-pr-organization.sh` but no scenario script exists
- Session regression: during #2249/#2264 `for_pr` implementation, two branches + two PRs were created

## Scope

- Enforce the EXISTING stacked-PR rule by promoting it to the canonical critical-rules location and adding a behavioral enforcement test.

**Out of scope:**
- Rewriting the entire PR-organization model (#828, #1007 already cover strategy/scope-model)
- Authorization scope model changes (#1007)
- This is scoped to enforcing the EXISTING stacked-PR rule (canonical location + behavioral test)

## Impact

- **Risk 1:** Rule promotion to critical-rules may conflict with existing PR-org text in other skills — mitigation: grep all skills for `PR-ORG` before editing.
- **Risk 2:** Behavioral test may be flaky under model variance — mitigation: assert on stderr tool-call evidence (branch/PR creation), not prose.
- **Risk 3:** Cross-reference fix may point to wrong section — mitigation: verify rule exists at target path before updating reference.
- **Dependencies:** None.
- **Call to action:** Approve to enforce the stacked-PR discipline that prevents concurrent-PR regressions.

🤖 OpenCode (ollama-cloud/deepseek-v4-flash) created
