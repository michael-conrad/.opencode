# Session Trigger Behavior

## Overview

Session context triggers (`session_context_triggers.py` + `session-enforcement.ts`) detect repository state and inject `<SESSION_TRIGGERS>` data into the agent's first user message. This guideline prescribes how the agent MUST process that data — not by echoing it, but by taking intelligent action.

**Core principle:** Triggers drive internal agent behavior, not chat output. The agent analyzes trigger data and acts on it; the agent does NOT print trigger content verbatim.

## No-Echo Rule (Tier 1 Mandate)

**The agent MUST NOT print `<SESSION_TRIGGERS>` content verbatim in chat output.** This includes:

- Copying trigger section headings (e.g., "Protected Branch with Uncommitted Changes")
- Parroting trigger data (e.g., "3 uncommitted changes on dev")
- Printing "Suggest:" lines from trigger output
- Acknowledging triggers with a "Session triggers acknowledged" section

Triggers are internal state data for decision-making. The agent processes them and takes action — the trigger text itself never appears in the agent's response.

**Violation of this rule is a CRITICAL GUIDELINE VIOLATION per `000-critical-rules.md`.**

## Trigger Behavior Map

Each trigger type maps to a required agent behavior:

| Trigger Type | Agent Behavior |
|---|---|
| `protected_branch_with_changes` | Analyze `git diff --stat` and `git diff`, produce a 1-2 sentence exec summary, suggest entering pair mode with a concrete issue reference or prompt to create one |
| `on_main_branch` | Same as `protected_branch_with_changes` plus explicit warning about working on production branch |
| `stale_stash` | Analyze stash contents via `git stash show -p stash@{N}`, classify as resumable/obsolete/ambiguous, recommend action with issue reference when available |
| `pair_mode_resume` | Continue pair mode workflow (already works correctly — no change needed) |
| `merge_conflict` | Process internally: note conflict files, plan resolution approach, do not echo the file list |
| `unpushed_commits` | Process internally: note count, do not echo. Push when explicitly asked or when review-prep requires it |
| `orphaned_worktrees` | Process internally: note paths, suggest cleanup when appropriate, do not echo the path list |
| `stale_submodule` | If active work (feature branch, approved spec): advance submodule to dev tip, read commit log between old and new SHA, commit the bump into the current feature branch with a generated commit message summarizing the delta. If read-only (no active work): suppress trigger per suppression rule. |

## Diff Analysis Requirement

When the `protected_branch_with_changes` or `on_main_branch` trigger fires, the agent MUST:

1. Run `git diff --stat` to understand the scope of changes
2. Run `git diff` for key files to understand the nature of changes
3. Produce a 1-2 sentence executive summary of what the pending changes are about
4. Suggest entering pair mode with:
   - A concrete issue number if one can be inferred from branch names, commit messages, or diff content
   - A prompt to create an issue if no issue reference is found
5. Example: "You have 3 uncommitted changes on `dev` (modifying session trigger handling and test updates). Want to enter pair mode for issue #1172?"

## Stash Analysis Protocol

The `stale_stash` trigger payload includes embedded triage instructions when stashes exist. The agent MUST follow the embedded directive — auto-resolve OBSOLETE and RESUMABLE stashes, only escalate AMBIGUOUS stashes to the developer.

When no stale stashes exist, no triage instructions are injected and no stash action is needed.

## Pair Mode Suggestion Protocol

When on a protected branch (`dev`/`main`) with uncommitted changes, the agent MUST suggest entering pair mode as the default workflow:

1. Analyze the diff to understand the changes
2. Extract or suggest an issue connection
3. Suggest a `pair-feature/<issue>-<description>` or `pair-spec/<issue>-<description>` branch name
4. Wait for developer confirmation (pair mode entry requires developer confirmation per `116-pair-mode.md` constraint C4)

This applies regardless of whether the current branch has a `pair-` prefix. The suggestion comes from the trigger data, not the branch name.

## Suppression Rule

Triggers that cannot drive meaningful action in the current context should be processed internally and suppressed from the agent's response entirely. The `<SESSION_TRIGGERS>` block remains in the user message for internal reasoning, but if a trigger provides no actionable insight (e.g., `unpushed_commits` when no push is pending), the agent should not mention it.

**The only triggers that produce visible agent behavior** are `protected_branch_with_changes`, `on_main_branch`, `stale_stash`, and `stale_submodule` (when active work exists) — all others are processed silently.

## Cross-References

- `116-pair-mode.md` — Pair mode branch discipline and session detection
- `000-critical-rules.md` — Tier 1 mandate for trigger echo prohibition
- `session_context_triggers.py` — Trigger detection and data generation
- `session-enforcement.ts` — Plugin that injects `<SESSION_TRIGGERS>` into first user message

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-04-25T00:00:00Z"
rules:
  - id: session-trigger-001
    title: "Agent must not echo SESSION_TRIGGERS content verbatim"
    conditions:
      any:
        - "agent_output_contains == 'trigger_section_heading'"
        - "agent_output_contains == 'trigger_dataverbatim'"
        - "agent_output_contains == 'Suggest:_line'"
    actions:
      - HALT
    conflicts_with: []
    requires: []
    triggers: []
    source: "117-session-trigger-behavior.md §No-Echo Rule"

  - id: session-trigger-002
    title: "protected_branch_with_changes requires diff analysis and pair mode suggestion"
    conditions:
      all:
        - "trigger_type == 'protected_branch_with_changes'"
    actions:
      - INVOKE(git-workflow)
    conflicts_with: []
    requires: []
    triggers: [git-workflow, 116-pair-mode]
    source: "117-session-trigger-behavior.md §Trigger Behavior Map"

  - id: session-trigger-003
    title: "on_main_branch requires diff analysis plus production warning"
    conditions:
      all:
        - "trigger_type == 'on_main_branch'"
    actions:
      - INVOKE(git-workflow)
    conflicts_with: []
    requires: [session-trigger-002]
    triggers: [git-workflow, 116-pair-mode]
    source: "117-session-trigger-behavior.md §Trigger Behavior Map"

  - id: session-trigger-004
    title: "stale_stash requires stash analysis and triage"
    conditions:
      all:
        - "trigger_type == 'stale_stash'"
    actions:
      - INVOKE(git-workflow)
    conflicts_with: []
    requires: []
    triggers: [git-workflow]
    source: "117-session-trigger-behavior.md §Stash Analysis Protocol"

  - id: session-trigger-005
    title: "Suppression rule — non-actionable triggers processed silently"
    conditions:
      all:
        - "trigger_type not in ['protected_branch_with_changes', 'on_main_branch', 'stale_stash', 'stale_submodule']"
    actions:
      - SKIP
    conflicts_with: []
    requires: []
    triggers: []
    source: "117-session-trigger-behavior.md §Suppression Rule"

  - id: session-trigger-006
    title: "stale_submodule with active work requires bump and commit"
    conditions:
      all:
        - "trigger_type == 'stale_submodule'"
        - "active_work == true"
    actions:
      - INVOKE(git-workflow)
    conflicts_with: []
    requires: []
    triggers: [git-workflow]
    source: "117-session-trigger-behavior.md §Trigger Behavior Map"
```