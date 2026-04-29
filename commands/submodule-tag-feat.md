---
name: submodule-tag-feat
description: Push submodule feature branches and create tip tags with <parent-repo>/<issue-number>-<sub> format. Invoked during review-prep Step 0. ALL git operations are dispatched to this sub-agent — the main agent MUST NOT perform git push/tag operations on submodules inline.
type: sub-agent-command
provenance: AI-generated
compatibility: opencode
---

# Command: submodule-tag-feat

## Purpose

For each submodule that has changes during implementation, push the submodule's feature branch to its remote and tag the tip with `<parent-repo>/<issue-number>-<submodule-name>`. This guarantees hash reachability at PR-time and maintains feature-branch provenance tracking.

## Operating Protocol

1. **Mandatory invocation during review-prep:** This command is invoked by `git-workflow --task review-prep` Step 0 (submodule feature-branch push)
2. **Sub-agent dispatch:** The main agent dispatches this command; all git operations run in a clean sub-agent context
3. **Feature-branch push:** Submodule changes go on feature branches, NOT directly to dev

## Entry Criteria

- `.gitmodules` exists
- At least one submodule has uncommitted/unpushed changes
- The parent feature branch has been created

## Exit Criteria

- Each changed submodule has its feature branch pushed to its remote
- Each changed submodule has a tip tag `<parent-repo>/<issue-number>-<submodule-name>` created and pushed
- Provenance tracking invoked for each pushed submodule (best-effort, non-blocking)

## Procedure

### Step 1: Detect Changed Submodules

```bash
git submodule foreach 'git diff HEAD --quiet || echo CHANGED'
```

If NO submodules report CHANGED: Report SKIP and exit.

### Step 2: Determine Tag Names

For each changed submodule, the tip tag format is:

```
<parent-repo-short>/<issue-number>-<submodule-name>
```

- `<parent-repo-short>`: Repository name without owner (e.g., `opencode-config-parent`)
- `<submodule-name>`: The submodule directory name (e.g., `opencode`)
- Example: `opencode-config-parent/215-opencode`

### Step 3: Push Feature Branch for Each Changed Submodule

For each changed submodule:

```bash
cd <submodule-path>

# Determine the feature branch name (matching the parent branch pattern)
PARENT_BRANCH="<parent-feature-branch-name>"
SUB_BRANCH="${PARENT_BRANCH}"  # Use same branch name in submodule

# Check if branch exists locally or remotely
git checkout -b "$SUB_BRANCH" 2>/dev/null || git checkout "$SUB_BRANCH"

# Commit any uncommitted changes
git add -A
git diff --cached --quiet || git commit -m "feat: changes from <parent-repo>/<parent-branch>"

# Push feature branch to submodule remote
git push origin "$SUB_BRANCH"

cd <parent-repo-root>
```

### Step 4: Create and Push Tip Tags

For each changed submodule:

```bash
cd <submodule-path>
TAG="<parent-repo-short>/<issue-number>-<submodule-name>"

git tag "$TAG"
git push origin "$TAG"

cd <parent-repo-root>
```

### Step 5: Stage Submodule Reference in Parent

After all submodules are pushed:

```bash
git add <submodule-path>
```

**Note:** This stages the updated submodule reference in the parent repo. The commit will happen as part of the normal review-prep flow. This is NOT a bump commit — it's recording the updated submodule reference for the push.

### Step 6: Invoke Provenance Tracking

For each pushed submodule, invoke provenance tracking:

```
Invoke: /skill git-workflow --task provenance --mode=dev-push
```

Provenance is best-effort and never blocks the git workflow.

### Step 7: Report Result

Report each submodule's:
- Path
- Feature branch name pushed
- Tip tag name created
- SHA that was tagged
- Whether tag push succeeded

**Evidence artifacts (MANDATORY):**

1. `git push origin <branch>` output confirming push
2. `git tag -l` output showing created tags
3. `git push origin --tags` output confirming push

## Result Contract

```yaml
status: DONE | BLOCKED | SKIP
task: submodule-feature-push
submodule_results:
  - path: <submodule-path>
    branch_pushed: <branch-name>
    tag_name: <parent-repo>/<issue-number>-<sub>
    sha_tagged: <sha>
    tag_pushed: bool
evidence_artifacts:
  - tool: git push origin <branch>
    output: <push confirmation>
  - tool: git tag -l
    output: <tag list>
  - tool: git push origin --tags
    output: <push confirmation>
```

## CRITICAL: Submodule Pushes Are Feature-Branch Pushes

Submodule changes are pushed on feature branches, NOT directly to dev. This maintains the same branch model as the parent repo and enables proper provenance tracking. The `dev` push approach from the old system is replaced by feature-branch pushes with tip tags.

## Context Required

- `issue_number`: From authorization context
- `github.owner`, `github.repo`: From session init
- `dev.name`, `dev.email`: From session init
- Feature branch name: From current branch
- Parent repo short name: Derived from repository name
- Changed submodule paths: From Step 1 detection