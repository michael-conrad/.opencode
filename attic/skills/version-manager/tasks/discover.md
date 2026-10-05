# Task: discover

## Purpose

Scan the entire codebase for version strings using dynamic regex patterns. No hardcoded file list — the agent uses grep with version-pattern regex across the entire project, then classifies each match by file type to determine the correct update syntax.

## Prerequisites

- [ ] 1.  Project root path available
- [ ] 2.  No prior version discovery results cached — always re-scan

## Steps

### Step 1: Scan for Version Patterns

Run grep across the entire project with the following regex patterns:

```
version\s*=\s*"(\d+\.\d+\.\d+)"          # pyproject.toml, setup.cfg, Cargo.toml
"version":\s*"(\d+\.\d+\.\d+)"           # package.json, composer.json
__version__\s*=\s*"(\d+\.\d+\.\d+)"      # */__init__.py, */version.py
version:\s*'(\d+\.\d+\.\d+)'              # Chart.yaml, values.yaml
VERSION\s*=\s*"(\d+\.\d+\.\d+)"           # VERSION files, *.cfg, *.ini
```

Use `grep -rn` with extended regex (`-E`) across the project root. Exclude `.git/` and `node_modules/`.

### Step 2: Classify Each Match

For each match, classify by file type:

| File Pattern | File Type | Update Syntax |
|-------------|-----------|---------------|
| `pyproject.toml` | Python project config | `version = "x.y.z"` |
| `Cargo.toml` | Rust project config | `version = "x.y.z"` |
| `package.json` | Node.js project config | `"version": "x.y.z"` |
| `*/__init__.py` | Python package init | `__version__ = "x.y.z"` |
| `*/version.py` | Python version module | `__version__ = "x.y.z"` |
| `Chart.yaml` | Helm chart | `version: 'x.y.z'` |
| `*.cfg`, `*.ini` | Config files | `VERSION = "x.y.z"` |
| Other | Generic | Preserve original format |

### Step 3: Return Results

Return a structured result contract:

```yaml
status: DONE
finding_summary: "Discovered N version strings across M files"
artifact_path: "{project_root}/tmp/version-discovery-{timestamp}.yaml"
version_locations:
  - file: "pyproject.toml"
    line: 3
    current_version: "1.2.3"
    file_type: "pyproject.toml"
  - file: "src/__init__.py"
    line: 1
    current_version: "1.2.3"
    file_type: "python-init"
current_version: "1.2.3"
```

## Exit Criteria

- [ ] 1. All version strings in the project are discovered
- [ ] 2. Each match is classified by file type
- [ ] 3. Results written to disk artifact
- [ ] 4. Result contract returned to orchestrator

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->
