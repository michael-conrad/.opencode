---
name: submodule-tag-prework
description: Tag each submodule at dev tip with <parent-repo>/<issue-number> and push tags to submodule remotes. Invoked during pre-work Step 3.5. ALL git operations are dispatched to this sub-agent — the main agent MUST NOT perform git tag/push operations on submodules inline.
type: sub-agent-command
provenance: AI-generated
compatibility: opencode
---

# Command: submodule-tag-prework

## Purpose

Tag each submodule at its current dev tip with the format `<parent-repo>/<issue-number>` and push those tags to the submodule remotes. This replaces the old bump-commit approach — tags guarantee hash reachability without creating commits in the parent repo.

## Operating Protocol

1. **Mandatory invocation during pre-work:** This command is invoked by `git-workflow --task pre-work` Step 3.5
2. **Sub-agent dispatch:** The main agent dispatches this command; all git operations run in a clean sub-agent context
3. **No bump commit:** Tags replace submodule bump commits entirely. The agent MUST NOT run `git add <submodule-path>` or `git commit` for submodule SHA changes during pre-work

## Entry Criteria

- `.gitmodules` exists in the repository
- Agent has authorization to modify submodules (pre-work authorization)
- Each submodule is on `dev` branch (verified by Step 2.6)

## Exit Criteria

- Each submodule tagged at its current dev tip with `<parent-repo>/<issue-number>`
- All tags pushed to their respective submodule remotes
- Submodule hashes are left dirty (no bump commit in parent)

## Procedure

### Step 1: Enumerate Submodules

```bash
git config --file .gitmodules --get-regexp path | awk '{print $2}'
```

If no submodules found, report SKIP and exit.

### Step 2: Determine Tag Name

The tag name uses the format:

```
<parent-repo-short>/<issue-number>
```

- `<parent-repo-short>`: Repository name without owner (e.g., `opencode-config-parent`)
- `<issue-number>`: The issue being implemented

**Determine parent repo short name:**

```bash
basename $(git rev-parse --show-toplevel)
```

### Step 3: Tag Each Submodule at Dev Tip

For each submodule path:

```bash
cd <submodule-path>
TAG="<parent-repo-short>/<issue-number>"

# Check if tag already exists
if git tag -l "$TAG" | grep -q "$TAG"; then
    echo "Tag $TAG already exists in $submodule-path. Skipping."
else
    git tag "$TAG"
    echo "Created tag $TAG in $submodule-path at $(git rev-parse --short HEAD)"
fi

cd <parent-repo-root>
```

### Step 4: Push Tags to Submodule Remotes

For each submodule path:

```bash
cd <submodule-path>
git push origin "<parent-repo-short>/<issue-number>"
cd <parent-repo-root>
```

**If tag push fails:** Report the failure and HALT. Do not attempt inline remediation.

### Step 5: Verify Tags Exist

```bash
git submodule foreach 'git tag -l "<parent-repo-short>/<issue-number>"'
```

All submodules must report the tag exists.

### Step 6: Report Result

Report each submodule's:
- Path
- Tag name created
- SHA that was tagged
- Whether tag push succeeded

**Evidence artifacts (MANDATORY):**

1. `git tag -l` output showing created tags in each submodule
2. `git push origin --tags` output confirming push

## Result Contract

```yaml
status: DONE | BLOCKED | SKIP
task: submodule-tag-prework
submodule_results:
  - path: <submodule-path>
    tag_name: <parent-repo>/<issue-number>
    sha_tagged: <sha>
    tag_pushed: bool
evidence_artifacts:
  - tool: git tag -l
    output: <tag list showing created tags>
  - tool: git push origin --tags
    output: <push confirmation>
```

## CRITICAL: No Bump Commit

The agent MUST NOT:
- Run `git add <submodule-path>` to stage submodule SHA changes during pre-work
- Run `git commit -m "chore(submodule): pin ..."` during pre-work
- Create any commit in the parent repo that records a submodule SHA change as part of pre-work

Tags provide hash permanence without polluting the commit history. Submodule hashes are intentionally left dirty during development.

## Context Required

- `issue_number`: From authorization context
- `github.owner`, `github.repo`: From session init
- Parent repo short name: Derived from repository name