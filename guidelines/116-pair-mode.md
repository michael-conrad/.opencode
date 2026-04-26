# Pair Mode Branch Discipline

## Overview

Pair mode (`pair-` prefix branches) allows the AI agent to work directly in the main project directory alongside the developer, using WIP-commit branch switching instead of worktrees. This is a Tier 2 waiver of the worktree mandate — the developer is present and accepting branch hygiene responsibility.

## Branch Naming

| Branch Pattern | Mode | Working Directory |
|---|---|---|
| `pair-feature/123-xyz` | Dev-pair | Main project dir |
| `pair-spec/456-abc` | Dev-pair | Main project dir |
| `feature/789-xyz` | Autonomous | `.worktrees/` |
| `spec/789-abc` | Autonomous | `.worktrees/` |
| `dev` or `main` | None | Prompt to create/switch |

The `pair-` prefix IS the mode signal. No state files needed — branch name carries everything.

## Mandatory Rules

### 1. Always Use `pair-` Prefix

No exceptions. If the developer is present and driving, use `pair-` prefix. If the AI is autonomous, use `feature/` or `spec/` with worktrees.

### 2. Never Operate in `.worktrees/` When Pair Mode Active

Pair mode branches work in the main project directory. Worktrees must not be created for pair mode branches.

### 3. WIP Commits Before Branch Switches

Before any branch switch in pair mode, the AI MUST:

1. Check `git status --porcelain`
2. If changes exist: `git add -A && git commit -m "WIP: <description>"` with co-author trailers
3. `git checkout <target-branch>`
4. On return, optionally `git reset HEAD~1` to uncommit the WIP

### 4. Commit Trailers Include `[pair-mode]`

Pair mode commits include:

```
Co-authored-by: Human Name <human@email> [pair-mode]
Co-authored-by: AI: <AgentName> (<ModelId>) [pair-mode]
```

The `[pair-mode]` tag distinguishes these from autonomous mode commits.

### 5. PR Body Uses `Implements #N`

Never `Fixes` or `Closes` — avoids premature issue closure. Use `Implements #N` to link without auto-closing.

## Session Detection

The `session_context_triggers.py` script detects pair mode at session start when the current branch starts with `pair-`. It emits:

- Identity section (always): `github.owner`, `github.repo`, `github.platform`, credential status
- Pair mode resume context: branch name, related issue, diff summary
- Trigger warnings: `on_main_branch`, `protected_branch_with_changes`, `uncommitted_work`

### Pair Mode Suggestion Protocol

When the agent detects uncommitted changes on a protected branch (`dev` or `main`) — not just when on a `pair-` branch — it MUST suggest entering pair mode as the default workflow:

1. The agent analyzes the diff summary and produces an executive summary of pending changes
2. The agent suggests entering pair mode with a concrete issue reference (if inferable from branch name, commit messages, or diff content) or prompts to create an issue
3. The agent suggests a branch name: `pair-feature/<issue>-<description>` or `pair-spec/<issue>-<description>`
4. The developer confirms or declines — pair mode entry requires developer confirmation (constraint C4)

This is a behavioral trigger from `<SESSION_TRIGGERS>`, not a `pair-` branch detection. See `117-session-trigger-behavior.md` for the complete trigger behavior map.

## Task Sequence

```
Session start → pair-mode-resume detects pair-* branch
    ↓
pair-pre-work: WIP-commit switch (no worktree)
    ↓
(pair commits as needed during work)
    ↓
pair-pr-creation: Squash → Push → Create PR
    ↓
(Developer merges PR)
    ↓
pair-cleanup: Delete branch, clean stashes
```

## Tier 2 Worktree Waiver

Pair mode is a Tier 2 waiver of the Tier 1 worktree mandate (per `000-critical-rules.md` Mandate Tiering). The developer is present and accepts responsibility for:

- Branch hygiene (no accidental commits to `dev`/`main`)
- WIP commit cleanup after branch switches
- Merge conflict awareness

The `pair-` prefix IS the waiver signal. No additional configuration or state files are required.

## Issue Association

When on a `pair-` branch:

- Infer issue number from branch name: `pair-feature/123-xyz` → issue #123
- Ask: "Commit for issue #123?" before committing
- If branch has no issue number, ask: "Which issue is this for?"

## Prohibited Actions in Pair Mode

- Creating worktrees for pair mode branches
- Committing directly to `dev` or `main` (hooks enforce this)
- Using `Fixes` or `Closes` in PR body (use `Implements`)
- Skipping WIP commit before branch switches
- Omitting `[pair-mode]` tag from commit trailers

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-04-25T00:00:00Z"
rules:
  - id: pair-mode-001
    title: "Pair mode requires pair- prefix on branch name"
    conditions:
      all:
        - "developer_present == true"
        - "branch_prefix != 'pair-'"
    actions:
      - HALT
    conflicts_with: []
    requires: []
    triggers: [git-workflow]
    source: "116-pair-mode.md §Mandatory Rules"

  - id: pair-mode-002
    title: "Never create worktrees for pair mode branches"
    conditions:
      all:
        - "branch_prefix == 'pair-'"
        - "action == 'create_worktree'"
    actions:
      - HALT
    conflicts_with: []
    requires: []
    triggers: [git-workflow]
    source: "116-pair-mode.md §Mandatory Rules"

  - id: pair-mode-003
    title: "WIP commit required before branch switch in pair mode"
    conditions:
      all:
        - "branch_prefix == 'pair-'"
        - "action == 'branch_switch'"
        - "working_tree_dirty == true"
        - "wip_committed == false"
    actions:
      - HALT
    conflicts_with: []
    requires: []
    triggers: [git-workflow]
    source: "116-pair-mode.md §Mandatory Rules"

  - id: pair-mode-004
    title: "Pair mode PR body must use Implements not Fixes"
    conditions:
      all:
        - "branch_prefix == 'pair-'"
        - "pr_body_contains in ['Fixes', 'Closes']"
    actions:
      - HALT
    conflicts_with: []
    requires: []
    triggers: [git-workflow]
    source: "116-pair-mode.md §Mandatory Rules"

  - id: pair-mode-005
    title: "Pair mode commits must include pair-mode tag"
    conditions:
      all:
        - "branch_prefix == 'pair-'"
        - "commit_trailer_contains_pair_mode == false"
    actions:
      - HALT
    conflicts_with: []
    requires: []
    triggers: [git-workflow]
    source: "116-pair-mode.md §Mandatory Rules"

  - id: pair-mode-006
    title: "Suggest pair mode when protected branch has uncommitted changes"
    conditions:
      all:
        - "branch_name in ['dev', 'main']"
        - "uncommitted_changes == true"
    actions:
      - INVOKE(git-workflow)
    conflicts_with: []
    requires: []
    triggers: [git-workflow]
    source: "116-pair-mode.md §Session Detection"

  - id: pair-mode-007
    title: "Never commit directly to dev or main even in pair mode"
    conditions:
      all:
        - "target_branch in ['dev', 'main']"
        - "action == 'commit'"
    actions:
      - HALT
    conflicts_with: []
    requires: []
    triggers: [git-workflow]
    source: "116-pair-mode.md §Prohibited Actions"
```