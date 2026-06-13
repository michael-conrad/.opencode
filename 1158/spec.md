---
number: 1158
title: "[SPEC-FIX] Forbid 'pre-existing failure' rationalization — test infrastructure is the ship condition"
status: open
labels: [SPEC-FIX]
created: 2026-06-13T04:46:01+00:00
remote_issue: 1158
remote_url: "https://github.com/michael-conrad/.opencode/issues/1158"
---

## Intent and Executive Summary

- **Problem Statement:** During implementation of #1156, 26 tests failed on both `dev` and the feature branch. The agent claimed "pre-existing failure, not caused by this change" and shipped the PR anyway. This rationalization is a defect-introduction pattern: shipping with known test failures means shipping defective output, regardless of whether the failures were introduced by the change or pre-existed.
- **Root Cause/Motivation:** No existing rule forbids the "pre-existing failure" rationalization. The agent saw 26 defects in `dev` and shipped anyway — that is intentionally shipping defective output. The lesson: test infrastructure is part of the ship condition. If dev has failing tests, the agent does NOT ship until failures are resolved or the developer explicitly authorizes proceeding.
- **Approach Chosen:** Add a new critical rule under `000-critical-rules.md` §accountability-ownership as principle #8, and add an explicit step in `verification-before-completion/tasks/verify.md` forbidding the rationalization. The `using-git-worktrees/tasks/reference.md` existing table entry will be upgraded to cross-reference the new rule.

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | `000-critical-rules.md` contains new principle 8: "No pre-existing failure rationalization" | `string` |
| SC-2 | `000-critical-rules.md` contains yaml+symbolic rule critical-rules-069 | `string` |
| SC-3 | `verification-before-completion/tasks/verify.md` contains Pre-Existing Failure Prohibition section | `string` |
| SC-4 | `using-git-worktrees/tasks/reference.md` cross-references critical-rules-069 | `string` |