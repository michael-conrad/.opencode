# Git Workflow Operating Protocol

## Entry Criteria

- Git operation requested (branch creation, commit, push, etc.)
- Working directory is a git repository

## Procedure

- [ ] 1. **Worktree first:** set `worktree.path` before file ops (direct-branch mode when `WORKTREE_REQUIRED` not set).
- [ ] 2. **Protected branches:** never commit to `main`.
- [ ] 3. **Squash discipline:** squash ONLY at PR creation, not during feature dev.
- [ ] 4. **Clean-room content diff:** before branch deletion, verify content exists on target branch.
- [ ] 5. **Compare URL base:** feature → `compare/<target>...<branch>`. Release → `compare/main...<target>`.
- [ ] 6. **Submodule repos:** git ops from inside submodule dir. No `--recursive`.
- [ ] 7. **Pair mode:** `pair-*` branches use WIP-commit switching, not worktrees.
- [ ] 8. **Adversarial-audit call:** after issue closure, before branch cleanup, call `audit --task closure-verification --pr <N>` with `audit_phase: post_merge`.
- [ ] 9. **Release branches:** use `release/v{semver}` naming convention. Release PRs use `compare/main...<target>` compare URL.
- [ ] 10. **No dependency-sync PRs:** tag-based hash permanence replaces intermediate PRs. Submodule SHAs are preserved via parent-repo-prefixed tags. See AGENTS.md §Tag Layers.
- [ ] 11. **Correctness over speed.** Every code path with runtime behavior requires live-wire testing against real systems. A slow correct answer is strictly better than a fast incorrect one. Static analysis alone is NOT acceptable verification — behavioral compliance requires actual execution with cross-validated PASS verdict.

### Tag Convention (Canonical)

All git tags in this project follow a unified naming convention. The suffix rule is defined in spec #950 and applies to ALL tag types.

**Suffix Rule:** Tag suffix MUST be derived from the discovered repo's directory name (e.g., `.opencode` → `-opencode`). Use glob scan to discover repo directories: `REPO_PATHS=$(ls -d .git/ */.git/ */.git 2>/dev/null | sed 's|/\.git$||' | sed 's|/$||')`. For each non-root path, use the directory name as the suffix. DO NOT use issue title, phase name, or any ad-hoc string.

| Tag Type | Format | Example | Purpose |
|----------|--------|---------|---------|
| Hash permanence | `<parent>/<issue>-<submodule>` | `opencode-config/950-opencode` | Pin submodule SHA at feature-branch tip |
| Checkpoint | `<parent>/checkpoint/<issue>/phase-<N>-<submodule>` | `opencode-config/checkpoint/391/phase-1-opencode` | Rollback anchor after sub-agent verification PASS |
| Release | `<parent>/v<version>` | `opencode-config/v0.1.1` | Release marker (no suffix) |

**Cross-references:**
- Spec #950 — canonical suffix derivation rule
- Spec #391 — checkpoint tag lifecycle (create during implementation-pipeline dispatch per the SKILL.md Trigger Dispatch Table, delete during cleanup)
- `pre-work.md` Step 3.5 — hash permanence tag creation
- `implementation-pipeline/SKILL.md` Trigger Dispatch Table — checkpoint creation and rollback substeps
- `branch-cleanup.md` Step 3.3 — checkpoint tag deletion

## Exit Criteria

- Git operation completed successfully
- Protocol rules verified
