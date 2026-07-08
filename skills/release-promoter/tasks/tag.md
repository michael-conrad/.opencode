# Task: tag

## Purpose

Create an annotated git tag with v prefix on the merge commit and push it to the remote.

## Prerequisites

- [ ] 1. (**inline**) Release PR has merged — verify merge commit exists
- [ ] 2. (**inline**) Next version determined (from version-manager --task bump)

## Steps

### Step 1: Verify Merge State

Verify the release PR has actually merged:
- Check `git log --oneline -1` to confirm we're on the merge commit
- If on a feature branch, checkout the target branch (main/dev) and pull latest

### Step 2: Create Annotated Tag

```bash
git tag -a v{NEXT_VERSION} -m "Release v{NEXT_VERSION}"
```

### Step 3: Push Tag

```bash
git push origin v{NEXT_VERSION}
```

### Step 4: Return Results

```yaml
status: DONE
finding_summary: "Created and pushed annotated tag v{NEXT_VERSION}"
artifact_path: "{project_root}/tmp/release-tag-{timestamp}.yaml"
tag_name: "v{NEXT_VERSION}"
tag_sha: "<sha from git rev-parse>"
```

## Exit Criteria

- [ ] 1. Annotated tag created with v prefix
- [ ] 2. Tag pushed to remote
- [ ] 3. Result contract returned to orchestrator

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->
