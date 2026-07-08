# Task: bump

## Purpose

Determine the next version from changelog categories using semver rules, then update all discovered version locations.

## Prerequisites

- [ ] 1. (**inline**) Version locations from `discover` task result contract
- [ ] 2. (**inline**) Changelog categories from `changelog-generator --task since-last-release`

## Steps

### Step 1: Determine Bump Type

Read changelog categories and determine bump type:

| Changelog Content | Bump | Example |
|-------------------|------|---------|
| Breaking changes | Major | `1.2.3` → `2.0.0` |
| New features (Added) | Minor | `1.2.3` → `1.3.0` |
| Fixes/other (Fixed, Changed, etc.) | Patch | `1.2.3` → `1.2.4` |

If multiple categories are present, use the highest precedence: breaking > added > fix.

### Step 2: Compute Next Version

Parse the current version (semver: `MAJOR.MINOR.PATCH`), apply the bump type, and compute the next version string.

### Step 3: Update All Version Locations

For each discovered version location, update the version string using the correct syntax for that file type:

| File Type | Update Pattern |
|-----------|---------------|
| `pyproject.toml` | `version = "{next_version}"` |
| `Cargo.toml` | `version = "{next_version}"` |
| `package.json` | `"version": "{next_version}"` |
| `python-init` | `__version__ = "{next_version}"` |
| `python-version` | `__version__ = "{next_version}"` |
| `Chart.yaml` | `version: '{next_version}'` |
| `config` | `VERSION = "{next_version}"` |
| `generic` | Preserve original format, replace version string |

### Step 4: Return Results

```yaml
status: DONE
finding_summary: "Bumped version from {current_version} to {next_version} ({bump_type})"
artifact_path: "{project_root}/tmp/version-bump-{timestamp}.yaml"
next_version: "2.0.0"
bump_type: "major"
updated_locations:
  - file: "pyproject.toml"
    line: 3
    old_version: "1.2.3"
    new_version: "2.0.0"
```

## Exit Criteria

- [ ] 1. Bump type determined from changelog categories
- [ ] 2. Next version computed correctly
- [ ] 3. All discovered version locations updated
- [ ] 4. Result contract returned to orchestrator

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->
