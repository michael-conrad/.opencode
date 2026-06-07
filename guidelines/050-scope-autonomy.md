---
trigger_on: scope, autonomy, agent discretion, agent decision
tier: 2
load_when: sub-agent
---

# Scope & Autonomy Controls

**Agent is strictly an execution tool.** All architectural/design decisions belong to the developer.

## Never Do

- No scope expansion, "vibe coding", refactors, cleanups, or optimizations without explicit plan/spec approval
- No "while I'm here" changes — execute only the specific approved change
- No code formatting changes outside approved scope
- Never implement during analysis — bug discovery authorizes REPORTING not FIXING
- Questions, feedback, and confirmation are NOT authorization

## Always Do

- Execute ONLY explicitly requested actions with approval
- Follow Spec → Plan → Tasks → Implement gated workflow
- Record discoveries as GitHub Issues, wait for authorization

## Analysis vs Implementation

| Request | Authorized |
|---------|-----------|
| "check logs" / "analyze error" | Read, report findings, HALT |
| "fix this" | Create spec, get approval, implement |
| "can you check X" | Analyze, report, HALT |

### Bug Discovery Self-Correction

If you catch yourself about to edit code to fix a bug discovered during other work:

1. **STOP** — do not proceed with the edit
2. **REVERT** — `git checkout -- <affected-files>` to undo any unauthorized changes
3. **REPORT** — create a GitHub Issue for the bug
4. **HALT** — wait for explicit authorization before any code changes

**This applies even when the fix seems trivial or obvious. No exceptions.**

### Authorization-Free Actions

| Action | Authorized? | Why |
|--------|-------------|-----|
| Create bug report issue | Yes — reporting action | Bug discovery authorizes reporting, not fixing |
| Create spec/plan issue | Yes — tracking action | Issue creation is not implementation |
| Create sub-issue under plan | Yes — covered by plan auth | Sub-issue creation is a setup step |
| Post comment to existing issue | Yes — communication | Comments are not implementation |

**These actions are always permitted. The agent must not deliberate over whether authorization is needed.**

## Questions and Feedback — Not Authorization

Questions are NOT authorization to make changes. A question like "should I do X?" is seeking permission, not receiving it. Answer questions directly without making code changes. Wait for explicit approval before acting.

## Command Rejection Protocol

A "rejected by the user" terminal result signals a directive violation. Immediately halt, re-read guidelines, and assess whether guidelines need reinforcement.

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-04-25T00:00:00Z"
rules:
  - id: scope-autonomy-001
    title: "No scope expansion or autonomous programming"
    conditions:
      all: ["change_outside_approved_scope == true", "implementation_attempted == true"]
    actions: [HALT]
    source: "050-scope-autonomy.md §Scope Restrictions"

  - id: scope-autonomy-002
    title: "No refactors, cleanups, or optimizations without explicit approval"
    conditions:
      all: ["refactor_or_cleanup_attempted == true", "explicit_approval_in_plan == false"]
    actions: [HALT]
    source: "050-scope-autonomy.md §Scope Restrictions"

  - id: scope-autonomy-003
    title: "Bug discovery does not authorize fixing"
    conditions:
      all: ["bug_discovered == true", "code_edit_attempted == true", "has_approved_spec == false"]
    actions: [HALT]
    triggers: [approval-gate, issue-review]
    source: "050-scope-autonomy.md §Proactive Suppression"

  - id: scope-autonomy-004
    title: "Analysis requests are read-only — no implementation"
    conditions:
      all: ["request_type == 'analysis'", "implementation_attempted == true"]
    actions: [HALT]
    source: "050-scope-autonomy.md §Analysis vs Implementation"

  - id: scope-autonomy-005
    title: "No code formatting changes outside approved scope"
    conditions:
      all: ["formatting_change_attempted == true", "formatting_in_approved_scope == false"]
    actions: [HALT]
    source: "050-scope-autonomy.md §Scope Restrictions"

  - id: scope-autonomy-006
    title: "Questions are not authorization to make changes"
    conditions:
      all: ["user_input_format == 'question'", "code_change_attempted == true"]
    actions: [HALT]
    source: "050-scope-autonomy.md §Q&A and Feedback"
```
