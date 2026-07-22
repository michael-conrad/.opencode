# Task: create-release

## Purpose

Create a GitHub Release from an existing tag with the changelog body as the release description.

## Prerequisites

- [ ] 1.  Tag exists (from `release-promoter --task tag`)
- [ ] 2.  Changelog body available (from `changelog-generator --task since-last-release`)

## Steps

### Step 1: Verify Tag Exists

```bash
git tag -l v{NEXT_VERSION}
```

If the tag does not exist, BLOCK and report.

### Step 2: Create GitHub Release

Use the GitHub MCP tool to create a release:

- Title: `v{NEXT_VERSION}`
- Tag name: `v{NEXT_VERSION}`
- Body: changelog entries for this version

### Step 3: Return Results

```yaml
status: DONE
finding_summary: "Created GitHub Release v{NEXT_VERSION}"
artifact_path: "{project_root}/tmp/release-create-{timestamp}.yaml"
release_url: "<html_url from API response>"
tag_name: "v{NEXT_VERSION}"
```

## Exit Criteria

- [ ] 1. GitHub Release created from tag
- [ ] 2. Release body contains changelog entries
- [ ] 3. Release URL extracted from API response
- [ ] 4. Result contract returned to orchestrator

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->
