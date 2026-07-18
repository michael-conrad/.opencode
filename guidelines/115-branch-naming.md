---
trigger_on: branch naming, branch name, naming convention
tier: 2
load_when: sub-agent
---

# Branch Naming Conventions

## Branch Naming Rules

**Feature branches MUST use one of these prefixes:**

- `spec/<short-name>` — For spec-driven implementation
- `feature/<description>` — For feature development
- `hotfix/<description>` — For urgent production fixes

**Branch Naming is NOT Enforced by Hooks:**

- Git hooks block AI commits to trunk but do NOT validate branch naming
- AI intelligence determines appropriate branch name
- Developer can override AI-suggested names

## Stacking Prerequisite

**Feature branches are stacked sequentially as a prerequisite for code correctness.** This is not a preference or default — it is the required approach. Parallel execution is opportunistic and depends on circumstances genuinely allowing it.

**Why stacking is prerequisite (not preference):**
- Incremental merge conflict resolution — conflicts discovered one branch at a time, not all at once at PR time
- Clear causal chain in git history — each branch builds on the prior
- Hidden dependency detection — "independent" issues often share imports, fixtures, or configuration
- Context window savings from stacking outweigh time savings from parallelism

**When parallel execution MAY be opportunistic (requires documented justification):**
- Genuinely independent hotfixes touching completely separate files
- Time-critical production fixes where stacking delay is unacceptable
- Developer has verified no shared files, imports, fixtures, or configuration

**When in doubt, stack.**

## Trunk-Based Architecture

**Branch Model:**

- **Trunk** (`$DEFAULT_BRANCH`): Single mainline — whatever `git remote show origin` reports as HEAD branch. Never hardcoded as `main` or `master`.
- **Feature branches** (`spec/*` or `feature/*`): Short-lived, one per issue/spec, branched from trunk and merged back to trunk
- **Hotfix branches** (`hotfix/*`): Branched from trunk, PR targets trunk

**Merge Paths:**

1. **Feature → Trunk**: PR required (squash to single commit)
2. **Release**: Tag on trunk after PR merge (no separate release branch)
3. **Hotfix**: Branch from trunk, PR to trunk (same path as feature branches)

## Branching Workflow

**ALL feature branch creation uses worktrees (mandatory, no exceptions).** Load [using-git-worktrees skill](skills/using-git-worktrees/SKILL.md).

### Resolve Trunk Dynamically

The trunk branch is resolved at runtime — never hardcoded:

```bash
DEFAULT_BRANCH=$(git remote show origin | sed -n '/HEAD branch/s/.*: //p')
```

### Feature Development

```bash
# 1. Resolve trunk and sync
DEFAULT_BRANCH=$(git remote show origin | sed -n '/HEAD branch/s/.*: //p')
git checkout "$DEFAULT_BRANCH" && git pull origin "$DEFAULT_BRANCH"

# 2. Create feature worktree (using-git-worktrees skill)
git worktree add .worktrees/spec-my-feature -b spec/my-feature "$DEFAULT_BRANCH"

# 3. Work in the worktree (use workdir parameter on all bash commands)
# IMPORTANT: For read/edit/write/glob/grep tools, prefix filePath with worktree.path
#   read(filePath=f"{worktree.path}/src/main.py")  — NOT read(filePath="src/main.py")
#   edit(filePath=f"{worktree.path}/src/main.py", ...)  — NOT edit(filePath="src/main.py", ...)
# ... make changes, commit inside .worktrees/spec-my-feature ...

# 4. Push feature branch from worktree
git push -u origin spec/my-feature

# 5. Create PR targeting trunk
# PR base: $DEFAULT_BRANCH (dynamically resolved)

# 6. After PR merge, cleanup (git-workflow --task cleanup)
git worktree remove .worktrees/spec-my-feature
git worktree prune
```

### Hotfix Workflow

Hotfixes follow the same trunk-based pattern — no parallel branches:

```bash
# 1. Resolve trunk
DEFAULT_BRANCH=$(git remote show origin | sed -n '/HEAD branch/s/.*: //p')
git checkout "$DEFAULT_BRANCH" && git pull origin "$DEFAULT_BRANCH"

# 2. Create hotfix worktree
git worktree add .worktrees/hotfix-urgent-fix -b hotfix/urgent-fix "$DEFAULT_BRANCH"

# 3. Fix, commit, push
git push -u origin hotfix/urgent-fix

# 4. PR targets trunk (same as feature branches)
```

### Release Workflow

Releases are tags on trunk — no separate release branch:

```bash
# 1. Ensure trunk is up to date
DEFAULT_BRANCH=$(git remote show origin | sed -n '/HEAD branch/s/.*: //p')
git checkout "$DEFAULT_BRANCH" && git pull origin "$DEFAULT_BRANCH"

# 2. Tag the release
git tag -a "v1.2.3" -m "Release v1.2.3"
git push origin "v1.2.3"
```

**AI DOES NOT:**

- Create release branches
- Merge PRs (human-only)
- Tag releases
- Bypass trunk
