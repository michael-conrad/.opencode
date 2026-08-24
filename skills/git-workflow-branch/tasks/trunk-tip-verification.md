# Task: trunk-tip-verification

## Purpose

Verify that the parent repo and all submodules are at remote trunk tip with clean working trees before feature branch creation. This is the 8-step gate that prevents starting work from a stale or dirty base state.

## Entry Criteria

- Authorization has been verified (approval-gate passed)
- Working tree is on `$DEFAULT_BRANCH`
- Remote `origin` is reachable

## Procedure

- [ ] 1. **Parent repo remote trunk tip:** Verify current branch is `$DEFAULT_BRANCH`:
      ```bash
      git branch --show-current | grep -q "^${DEFAULT_BRANCH}$" || echo "FAIL: Not on $DEFAULT_BRANCH"
      ```

- [ ] 2. **Parent repo zero pending changes:** Verify working tree is clean:
      ```bash
      git status --porcelain | head -5
      # MUST be empty — no uncommitted changes
      ```

- [ ] 3. **Parent repo remote tracking match:** Verify local `$DEFAULT_BRANCH` matches `origin/$DEFAULT_BRANCH`:
      ```bash
      git fetch origin "$DEFAULT_BRANCH"
      LOCAL=$(git rev-parse "$DEFAULT_BRANCH")
      REMOTE=$(git rev-parse "origin/$DEFAULT_BRANCH")
      if [ "$LOCAL" != "$REMOTE" ]; then
        echo "FAIL: Local $DEFAULT_BRANCH ($LOCAL) does not match origin/$DEFAULT_BRANCH ($REMOTE)"
        echo "  Run: git pull origin $DEFAULT_BRANCH"
      fi
      ```

- [ ] 4. **Submodule remote trunk tip:** For each submodule, verify it is on `$DEFAULT_BRANCH`:
      ```bash
      git submodule foreach "
        DEFAULT_BRANCH=\$(git remote show origin 2>/dev/null | sed -n 's/.*HEAD branch: //p')
        CURRENT=\$(git branch --show-current)
        if [ \"\$CURRENT\" != \"\$DEFAULT_BRANCH\" ]; then
          echo \"FAIL: Submodule \$path is on \$CURRENT, not \$DEFAULT_BRANCH\"
        fi
      "
      ```

- [ ] 5. **Submodule zero pending changes:** For each submodule, verify clean working tree:
      ```bash
      git submodule foreach "
        if [ -n \"\$(git status --porcelain)\" ]; then
          echo \"FAIL: Submodule \$path has uncommitted changes\"
        fi
      "
      ```

- [ ] 6. **Submodule remote tracking match:** For each submodule, verify local matches remote:
      ```bash
      git submodule foreach "
        DEFAULT_BRANCH=\$(git remote show origin 2>/dev/null | sed -n 's/.*HEAD branch: //p')
        git fetch origin \"\$DEFAULT_BRANCH\"
        LOCAL=\$(git rev-parse \"\$DEFAULT_BRANCH\")
        REMOTE=\$(git rev-parse \"origin/\$DEFAULT_BRANCH\")
        if [ \"\$LOCAL\" != \"\$REMOTE\" ]; then
          echo \"FAIL: Submodule \$path local \$DEFAULT_BRANCH does not match origin/\$DEFAULT_BRANCH\"
        fi
      "
      ```

- [ ] 7. **Submodule pointer match:** Verify submodule pointer matches committed SHA (no `+` prefix):
      ```bash
      git submodule status | grep '^+'
      # MUST be empty — no dirty submodule pointers
      ```

- [ ] 8. **Submodule merged-commit check:** For each submodule, verify its committed pointer SHA is an ancestor of the submodule's remote trunk (`origin/$DEFAULT_BRANCH`) using `git merge-base --is-ancestor`. A pointer referencing a local-only commit means the submodule's own PR has not been merged — the build system would resolve it to a commit that does not exist on the remote. If ANY submodule pointer is local-only, return BLOCKED with `SUBMODULE_UNMERGED_COMMIT`:
      ```bash
      git submodule foreach "
        DEFAULT_BRANCH=\$(git remote show origin 2>/dev/null | sed -n 's/.*HEAD branch: //p')
        git fetch origin \"\$DEFAULT_BRANCH\"
        POINTER=\$(git rev-parse HEAD)
        if ! git merge-base --is-ancestor \"\$POINTER\" \"origin/\$DEFAULT_BRANCH\"; then
          echo \"FAIL: Submodule \$path pointer \$POINTER is not on origin/\$DEFAULT_BRANCH\"
          exit 1
        fi
      " || echo "SUBMODULE_UNMERGED_COMMIT: a submodule pointer references a local-only commit"
      ```
      **Fail open on network error:** If `git fetch` fails because the remote is unreachable, do NOT block — warn and continue. Network flakiness must never block development:
      ```bash
      git submodule foreach "
        DEFAULT_BRANCH=\$(git remote show origin 2>/dev/null | sed -n 's/.*HEAD branch: //p')
        if ! git fetch origin \"\$DEFAULT_BRANCH\" 2>/dev/null; then
          echo \"WARN: Submodule \$path remote unreachable — skipping merged-commit check\"
          continue
        fi
        POINTER=\$(git rev-parse HEAD)
        if ! git merge-base --is-ancestor \"\$POINTER\" \"origin/\$DEFAULT_BRANCH\"; then
          echo \"FAIL: Submodule \$path pointer \$POINTER is not on origin/\$DEFAULT_BRANCH\"
          exit 1
        fi
      " || echo "SUBMODULE_UNMERGED_COMMIT: a submodule pointer references a local-only commit"
      ```

## Exit Criteria

- Parent repo is on `$DEFAULT_BRANCH` with zero pending changes at remote trunk tip
- All submodules are on `$DEFAULT_BRANCH` with zero pending changes at remote trunk tip
- Submodule pointers match committed SHAs
- All submodule pointer SHAs are ancestors of their submodule's remote `origin/$DEFAULT_BRANCH` (merged) — no local-only submodule commits
- If ANY check fails: return BLOCKED with the specific failure

## Result Contract

```yaml
status: DONE | BLOCKED
checks:
  parent_on_default: PASS | FAIL
  parent_clean: PASS | FAIL
  parent_remote_match: PASS | FAIL
  submodule_on_default: PASS | FAIL
  submodule_clean: PASS | FAIL
  submodule_remote_match: PASS | FAIL
  submodule_pointer_match: PASS | FAIL
  submodule_merged_commit: PASS | FAIL | SKIP
blocker_reason: "<description of which check failed and why>"
```

## Cross-References

- `pre-work.md` — this gate runs before feature branch creation
- `submodule-sync.md` — mid-feature submodule currency
- `pre-commit-pointer-check.md` — pre-commit submodule pointer verification
