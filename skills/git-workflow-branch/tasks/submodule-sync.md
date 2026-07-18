# Task: submodule-sync

## Purpose
Sync dirty submodule pointers to latest trunk tip. Used for mid-feature submodule currency and user "sync submodules" requests.

## Entry Criteria
- One or more submodules have dirty pointers in parent repo
- `.gitmodules` exists in worktree

## Procedure
- [ ] 1. Detect submodules: read `.gitmodules` for `[submodule "..."]` paths
- [ ] 2. For each submodule path:
      - Resolve trunk branch: `DEFAULT_BRANCH=$(git remote show origin 2>/dev/null | sed -n 's/.*HEAD branch: //p')`
      - `git checkout "$DEFAULT_BRANCH" && git pull origin "$DEFAULT_BRANCH" --ff-only`
      - **On `--ff-only` failure (diverged history):** Agent autonomously analyzes and attempts resolution:
        ```bash
        SUBMODULE_PATH="<path>"
        DEFAULT_BRANCH=$(git remote show origin 2>/dev/null | sed -n 's/.*HEAD branch: //p')
        AHEAD=$(git rev-list --count "origin/$DEFAULT_BRANCH..$DEFAULT_BRANCH" 2>/dev/null || echo "unknown")
        BEHIND=$(git rev-list --count "$DEFAULT_BRANCH..origin/$DEFAULT_BRANCH" 2>/dev/null || echo "unknown")
        echo "DIVERGENCE DETECTED: Submodule at $SUBMODULE_PATH"
        echo "  Ahead by $AHEAD commits (local changes not on origin/$DEFAULT_BRANCH)"
        echo "  Behind by $BEHIND commits (origin/$DEFAULT_BRANCH changes not in local $DEFAULT_BRANCH)"
        # Autonomous resolution attempt:
        if [ "$AHEAD" = "0" ] && [ "$BEHIND" != "0" ] && [ "$BEHIND" != "unknown" ]; then
          git pull origin "$DEFAULT_BRANCH"
        elif [ "$AHEAD" != "0" ] && [ "$AHEAD" != "unknown" ] && [ "$BEHIND" = "0" ]; then
          git push origin "$DEFAULT_BRANCH"
        elif [ "$AHEAD" != "0" ] && [ "$BEHIND" != "0" ] && [ "$AHEAD" != "unknown" ] && [ "$BEHIND" != "unknown" ]; then
          if git rebase "origin/$DEFAULT_BRANCH" 2>/dev/null; then
            echo "Autonomous rebase successful — divergence resolved."
          else
            echo "Autonomous rebase failed — semantic conflict detected."
            echo "HALT: Developer consultation required — divergence cannot be auto-resolved."
          fi
        else
          echo "HALT: Developer consultation required — divergence cannot be auto-resolved."
        fi
        ```
      - On non-divergence failure (network error, etc.): log the submodule path and error; continue to next submodule
- [ ] 3. Return to parent repo: `git -C <parent> checkout <original-branch>`
- [ ] 4. Report: which submodules were synced successfully, which (if any) failed, which (if any) diverged and how they were resolved

## Exit Criteria
All accessible submodules point to latest trunk tip. Failed submodules reported but do not block.

## Cross-References
- Load [Tag Convention](skills/git-workflow/SKILL.md) — hash permanence tags preserve SHAs before sync
- `pre-work` task — submodule tagging at feature start