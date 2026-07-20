## Problem

The "unified pipeline path — no single-task exemption" rule is vestigial. With the implementation-pipeline SKILL.md Trigger Dispatch Table as the single source of truth and all steps mandatory, there is only one pipeline path. Nothing to "unify" and nothing to be "exempt" from.

The concept originated from a hypothetical shortcut where single-phase plans could skip some gates. That path never existed in practice, and the current model makes it structurally impossible. The rule is now a no-op that adds noise.

## Files to Clean

| File | Line(s) | Content |
|------|---------|---------|
| `guidelines/000-critical-rules.md` | 870-871 | Tier 3 rule `critical-rules-018` + "Single issue = work-of-1" |
| `guidelines/010-approval-gate.md` | 413 | `approval-gate-012` symbolic rule |
| `skills/executing-plans/SKILL.md` | 61 | Mandatory Task Discipline item 4 |
| `skills/approval-gate/tasks/verify-authorization/sub-issue-verification.md` | 17, 23 | "All plans follow unified dispatch path" |
| `skills/pr-creation-workflow/tasks/sub-issue-collection.md` | 27 | "All specs follow the unified pipeline path" |
| `skills/approval-gate/tasks/verify-sub-issues.md` | 18 | "exemption confirmed (work-of-1)" |
| `skills/approval-gate/tasks/screen/screen-issue-gate2.md` | 130 | "If no sub-issues (work-of-1)" |
| `tools/impl/skildeck/skill-registry-v2-guidelines.json` | 830 | Registry entry |
| `tools/impl/skildeck/skill-registry.yaml` | 211 | Registry entry |

## Action

Remove or update each reference. The concept is dead — don't preserve it as a "note" or "historical context."