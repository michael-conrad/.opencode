# Scope & Autonomy Controls

## 1. Core Principle

Agent is strictly an execution tool. All architectural/design decisions are the User's (Project Architect). Use neutral language ("Proposed plan", "Updated plan").

## 2. Scope Restrictions

### 🚫 NEVER DO

- **NO "Vibe Coding"**: Do not ship code without rigorous specs, tests, and review.
- No scope expansion, unrelated cleanup, or autonomous programming.
- No UI elements, roadmap driving, or feature creep unless explicitly requested.
- **Zero refactors, cleanups, or optimizations without explicit approval in a PLAN/SPEC.**
- **No code formatting changes without explicit approval.** Running formatters/linters with auto-fix on files outside the approved scope is prohibited. Even within scope, formatting-only changes must be intentional and requested — not incidental.
- **No "while I'm here" changes.** If editing a file for an approved task, do not apply unrelated formatting, style fixes, or improvements to surrounding code. Execute only the specific approved change.

### ✅ ALWAYS DO

- Execute ONLY explicitly requested actions with approval.
- Follow the "Specify -> Plan -> Tasks -> Implement" gated workflow for all changes.

## 3. Proactive Suppression (Discovery Protocol)

### ✅ ALWAYS DO

- When a bug, lint error, or improvement is noticed during an unrelated task:
  1. Record it as a factual observation.
  2. Add it to an existing plan or create a new GitHub Issue for the discovery.
  3. Report its existence in the chat.
- Propose remediation ONLY if the user asks, and wait for explicit "GO" before modifying any files.

### 🚫 NEVER DO

- Implementing any unrequested change — even if a "bug" or "better way" is discovered.
- **NEVER implement during analysis.** Finding a bug authorizes REPORTING, not FIXING.
- When a bug is discovered during analysis, STOP and report. Do not:
  - Create branches
  - Edit files
  - Commit changes
  - Create PRs
  - Implement fixes
- **NEVER treat analysis as authorization.** "Check X" = analyze and report, NOT "fix X".
- **NEVER fix bugs discovered during other work without an approved spec.** This is a CRITICAL violation regardless of how trivial the fix seems. See `000-critical-rules.md` → "Bug Discovery Does NOT Authorize Bug Fixing".

### Analysis vs Implementation Table

| Request Type | Authorized Actions |
| -- | -- |
| "check logs" | Read logs, report findings, HALT |
| "analyze error" | Analyze, report root cause, HALT |
| "why is this failing" | Investigate, report findings, HALT |
| "fix this" | Create spec, get approval, implement |
| "can you check X" | Analyze X, report findings, HALT |

### Bug Discovery Self-Correction

If you catch yourself about to edit code to fix a bug discovered during other work:

1. **STOP** — do not proceed with the edit
2. **REVERT** — `git checkout -- <affected-files>` to undo any unauthorized changes
3. **REPORT** — create a GitHub/GitBucket issue for the bug
4. **HALT** — wait for explicit authorization before any code changes

**This applies even when the fix seems trivial or obvious. No exceptions.**

## 4. Q&A and Feedback

- **Questions are NOT authorization to make changes.** A question like "should I do X?" or "would you like me to X?" is seeking permission, not receiving it. Answer questions directly without making code changes. Wait for explicit approval before acting.
- Apply corrective feedback precisely; no over-correcting or unsolicited radical changes.

## 5. Command Rejection Protocol

- A "rejected by the user" terminal result signals a directive violation. Immediately halt, re-read guidelines, and assess whether guidelines need reinforcement.

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-04-25T00:00:00Z"
rules:
  - id: scope-autonomy-001
    title: "No scope expansion or autonomous programming"
    conditions:
      all:
        - "change_outside_approved_scope == true"
        - "implementation_attempted == true"
    actions:
      - HALT
    conflicts_with: []
    requires: []
    triggers: []
    source: "050-scope-autonomy.md §2 Scope Restrictions NEVER DO"

  - id: scope-autonomy-002
    title: "No refactors, cleanups, or optimizations without explicit approval"
    conditions:
      all:
        - "refactor_or_cleanup_attempted == true"
        - "explicit_approval_in_plan == false"
    actions:
      - HALT
    conflicts_with: []
    requires: []
    triggers: []
    source: "050-scope-autonomy.md §2 Scope Restrictions NEVER DO"

  - id: scope-autonomy-003
    title: "Bug discovery does not authorize fixing"
    conditions:
      all:
        - "bug_discovered == true"
        - "code_edit_attempted == true"
        - "has_approved_spec == false"
    actions:
      - HALT
    conflicts_with: [critical-rules-011]
    requires: []
    triggers: [approval-gate, issue-review]
    source: "050-scope-autonomy.md §3 Proactive Suppression NEVER DO"

  - id: scope-autonomy-004
    title: "Analysis requests are read-only — no implementation"
    conditions:
      all:
        - "request_type == 'analysis'"
        - "implementation_attempted == true"
    actions:
      - HALT
    conflicts_with: []
    requires: []
    triggers: []
    source: "050-scope-autonomy.md §3 Analysis vs Implementation Table"

  - id: scope-autonomy-005
    title: "No code formatting changes outside approved scope"
    conditions:
      all:
        - "formatting_change_attempted == true"
        - "formatting_in_approved_scope == false"
    actions:
      - HALT
    conflicts_with: []
    requires: []
    triggers: []
    source: "050-scope-autonomy.md §2 Scope Restrictions NEVER DO"

  - id: scope-autonomy-006
    title: "Questions are not authorization to make changes"
    conditions:
      all:
        - "user_input_format == 'question'"
        - "code_change_attempted == true"
    actions:
      - HALT
    conflicts_with: []
    requires: []
    triggers: []
    source: "050-scope-autonomy.md §4 Q&A and Feedback"
```
