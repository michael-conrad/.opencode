---
name: submodule-divergence
description: Shared submodule divergence detection and resolution procedures extracted from pre-work.md
license: MIT
provenance: AI-generated
---

# Submodule Divergence Handling

## Purpose

This reference documents the shared submodule divergence detection and autonomous resolution procedures used by `pre-work.md` (Step 3). These procedures handle the case where `git pull --ff-only` fails on a submodule, indicating the local submodule has diverged from its remote tracking branch.

## Detection

When `git pull --ff-only` fails on a submodule, the divergence is detected and analyzed:

```bash
SUBMODULE_PATH="<path>"
DEFAULT_BRANCH=$(git remote show origin 2>/dev/null | sed -n 's/.*HEAD branch: //p')
AHEAD=$(git rev-list --count "origin/$DEFAULT_BRANCH..$DEFAULT_BRANCH" 2>/dev/null || echo "unknown")
BEHIND=$(git rev-list --count "$DEFAULT_BRANCH..origin/$DEFAULT_BRANCH" 2>/dev/null || echo "unknown")
echo "DIVERGENCE DETECTED: Submodule at $SUBMODULE_PATH"
echo "  Ahead by $AHEAD commits (local changes not on origin/$DEFAULT_BRANCH)"
echo "  Behind by $BEHIND commits (origin/$DEFAULT_BRANCH changes not in local $DEFAULT_BRANCH)"
```

## Autonomous Resolution

Based on the ahead/behind counts, the agent attempts autonomous resolution:

| Condition | Action | Outcome |
|-----------|--------|---------|
| Only behind (`AHEAD=0`, `BEHIND>0`) | `git pull origin "$DEFAULT_BRANCH"` | Fast-forward safe |
| Only ahead (`AHEAD>0`, `BEHIND=0`) | `git push origin "$DEFAULT_BRANCH"` | Push local changes |
| Both ahead and behind | `git rebase origin/$DEFAULT_BRANCH` | Rebase; escalate on conflict |
| Unknown counts | Escalate to developer | Manual resolution required |

### Resolution Script

```bash
# Autonomous resolution attempt:
if [ "$AHEAD" = "0" ] && [ "$BEHIND" != "0" ] && [ "$BEHIND" != "unknown" ]; then
  # Only behind — safe to fast-forward
  git pull origin "$DEFAULT_BRANCH"
elif [ "$AHEAD" != "0" ] && [ "$AHEAD" != "unknown" ] && [ "$BEHIND" = "0" ]; then
  # Only ahead — local changes not pushed, push them
  git push origin "$DEFAULT_BRANCH"
elif [ "$AHEAD" != "0" ] && [ "$BEHIND" != "0" ] && [ "$AHEAD" != "unknown" ] && [ "$BEHIND" != "unknown" ]; then
  # Both ahead and behind — semantic analysis needed
  # Attempt rebase first (safe for linear history)
  if git rebase "origin/$DEFAULT_BRANCH" 2>/dev/null; then
    echo "Autonomous rebase successful — divergence resolved."
  else
    echo "Autonomous rebase failed — semantic conflict detected."
    echo "HALT: Developer consultation required — divergence cannot be auto-resolved."
    echo "  Suggested resolution:"
    echo "    - Review and resolve rebase conflicts manually"
    echo "    - If local changes should be discarded: git reset --hard origin/$DEFAULT_BRANCH"
  fi
else
  echo "HALT: Developer consultation required — divergence cannot be auto-resolved."
  echo "  Suggested resolution:"
  echo "    - If local changes are intentional: git push origin $DEFAULT_BRANCH"
  echo "    - If local changes should be discarded: git reset --hard origin/$DEFAULT_BRANCH"
  echo "    - If local changes should be rebased: git rebase origin/$DEFAULT_BRANCH"
fi
```

## Result Contract

On divergence, the sub-agent returns a structured result contract:

```yaml
status: DONE | BLOCKED
reason: SUBMODULE_FF_FAILURE | SUBMODULE_DIVERGENCE_RESOLVED
submodule_path: "<path>"
ahead: <N>
behind: <N>
resolution: "autonomous_push | autonomous_rebase | escalated"
```

## Hard Gate: `--ff-only`

`git pull --ff-only` is a hard gate that prevents accidental divergence from trunk. On failure:

- Do NOT fall back to merge or rebase automatically
- Analyze ahead/behind counts first
- Only proceed with autonomous resolution when the divergence pattern is safe
- Escalate to developer when both ahead and behind with rebase conflicts

## Cross-References

- Source: `pre-work.md` Step 3 — Submodule Work
- Used by: `git-workflow-branch` sub-agent tasks
- Related: `git-workflow-branch/SKILL.md` — Branch and Submodule State Model
