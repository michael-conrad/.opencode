---
trigger_on: session trigger, trigger, trigger warning, SESSION_TRIGGER
tier: 1
load_when: sub-agent
---

# Session Trigger Behavior

## Overview

Session context triggers (`session_context_triggers.py` + `session-enforcement.ts`) detect repository state and inject trigger data into the agent's first user message. This guideline prescribes how the agent MUST process that data — not by echoing it, but by taking intelligent action.

**Core principle:** Triggers drive internal agent behavior, not chat output. The agent analyzes trigger data and acts on it; the agent does NOT print trigger content verbatim.

**Purged triggers (spec #426):** All branch-status-based triggers that caused AI agent malfunctions have been removed. These included `on_main_branch`, `protected_branch_with_changes`, `dev_branch_with_changes`, `uncommitted_work_warning`, `stale_stash`, `stale_submodule`, `merge_conflict`, `unpushed_commits`, `orphaned_worktrees`, `local_only_repo`, and the `detect_check_prs_intent` trigger. The per-turn protected branch edit guard in `session-enforcement.ts` has also been removed.

## No-Echo Rule (Tier 1 Mandate)

**The agent MUST NOT print `<SESSION_TRIGGERS>` content verbatim in chat output.** This includes:

- Copying trigger section headings (e.g., "Pair Mode Resumed")
- Parroting trigger data (e.g., "Pair mode branch detected")
- Acknowledging triggers with a "Session triggers acknowledged" section
- Printing content from the `### NESTED_OPENCODE_FATAL` block

Triggers are internal state data for decision-making. The agent processes them and takes action — the trigger text itself never appears in the agent's response.

**Violation of this rule is a CRITICAL GUIDELINE VIOLATION per `000-critical-rules.md`.**

## Trigger Behavior Map

After the spec #426 purge, only two triggers remain:

| Trigger Type | Agent Behavior |
|---|---|
| `pair_mode_resume` | Continue pair mode workflow (already works correctly — no change needed) |
| `nested_opencode_fatal` | **HALT all operations.** Report to developer immediately. Do NOT continue working. |

### `nested_opencode_fatal` — Critical Configuration Error

When the `### NESTED_OPENCODE_FATAL` block appears, the agent MUST:

1. **HALT immediately** — do not proceed with any operations
2. **Report to the developer** — inform them that the AI agent configuration is broken due to a nested `.opencode/.opencode/` directory
3. **Instruct the developer** to delete the nested `.opencode/.opencode/` directory
4. **Verify** that `.opencode/.gitignore` contains `.opencode/` to prevent recurrence

This is not a suggestion — it is a hard halt. A nested `.opencode/` directory completely breaks skill discovery and makes the agent non-functional for its primary purpose.

## Suppression Rule

Triggers that cannot drive meaningful action in the current context should be processed internally and suppressed from the agent's response entirely. The `<SESSION_TRIGGERS>` block remains in the user message for internal reasoning, but if a trigger provides no actionable insight, the agent should not mention it.

**Only `pair_mode_resume` produces visible agent behavior** — `nested_opencode_fatal` produces a hard halt. All other trigger types have been purged per spec #426.

## Cross-References

- `116-pair-mode.md` — Pair mode branch discipline and session detection
- `000-critical-rules.md` — Tier 1 mandate for trigger echo prohibition
- `session_context_triggers.py` — Trigger detection and data generation (purged per spec #426)
- `session-enforcement.ts` — Plugin that injects trigger content into first user message (per-turn guard removed per spec #426)
