---
remote_issue: 2223
remote_url: "https://github.com/michael-conrad/.opencode/issues/2223"
last_sync: 2026-08-02T02:04:17Z
source: github.com
---

## Problem

The PR body template in `create-pr.md` still references "Dual-Auditor Cross-Validation" and "Auditor 1 / Auditor 2" columns. The audit pipeline was replaced with the DiMo 4-role chain (Investigator → Validator → Evaluator → Arbiter), but the PR body template was never updated. The attestation line in generated PR bodies claims "Dual independent auditors from different model families" — a fabrication.

Stale references also exist in guidelines 250, 255, 257, and 000-critical-rules.md.

## Scope

- Remove Dual-Auditor Cross-Validation table from `create-pr.md` PR body template
- Replace with DiMo chain attestation (Arbiter consensus)
- Update attestation line to reference DiMo, not dual auditors
- Clean up stale "dual-auditor" references in guidelines (250, 255, 257, 000)

## Affected Files

- `.opencode/skills/git-workflow-pr/tasks/pr-creation/create-pr.md`
- `.opencode/guidelines/250-dark-prose-reference.md`
- `.opencode/guidelines/255-distribution-shifting-reference.md`
- `.opencode/guidelines/257-procedural-discipline-reference.md`
- `.opencode/guidelines/000-critical-rules.md`
- `.opencode/skills/git-workflow-cleanup/tasks/cleanup/branch-cleanup.md`
