<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->

<!-- SPDX-License-Identifier: MIT -->

<!-- Provenance: AI-generated -->

# Local Platform — Issue Read

## Overview

Read issues from the local `.issues/` directory. Five read types provide targeted or bundled access: full issue, comments only, labels only, links (sub-issues), or all-at-once.

**Primary tool:** `./.opencode/tools/local-issues`

All read commands output YAML for direct LLM consumption without special parsing.

______________________________________________________________________

## Cross-Repo Read Behavior

The `local-issues` tool supports cross-repo reads with two modes:

| Mode | Syntax | Behavior |
| ---- | ------ | -------- |
| **Bare** | `read --number N` | Scans ALL repos (`.issues/` and `.opencode/.issues/`). Returns ALL matches with `repo` field. If multiple repos have issue #N, all are returned. |
| **Qualified** | `read --number opencode-config#7` | Targets a specific repo only. The qualified form uses `{repo}#{N}` where `repo` matches the repo name from the issue's `spec_path` parent directory. |

Output format for both modes includes `repo`, `number`, `spec_path`, and `issue` data.

______________________________________________________________________

## Entry Criteria

- \[ \] Issue number N is known (integer, valid), optionally qualified as `{repo}#{N}`
- \[ \] For bare N: `.issues/<N>/` or `.opencode/.issues/<N>/` directory exists
- \[ \] For qualified `{repo}#{N}`: the specific repo's `.issues/` or `.opencode/.issues/` directory contains the issue
- \[ \] `./.opencode/tools/local-issues` CLI tool is available
- \[ \] Read type is one of: `full`, `comments`, `labels`, `links`, `all`

______________________________________________________________________

## Type Dispatch Table

| Type         | CLI Command                      | Output Format                                                                                          | Use Case                                                          |
| ------------ | -------------------------------- | ------------------------------------------------------------------------------------------------------ | ----------------------------------------------------------------- |
| **full**     | `./.opencode/tools/local-issues read N`            | YAML document (number, title, status, labels, phase, created, updated, github_issue, remote_url, body) | Full spec reading. One-dispatch access to issue body + metadata.  |
| **comments** | `./.opencode/tools/local-issues read-comments N`   | YAML list of `{author, timestamp, body}`                                                               | Reading discussion history without the spec body.                 |
| **labels**   | `./.opencode/tools/local-issues read-labels N`     | YAML `{labels: [string]}`                                                                              | Quick label check. Filtering by authorization state.              |
| **links**    | `./.opencode/tools/local-issues read-sub-issues N` | YAML `{parent, children, related, blocked_by, duplicate_of, superseded_by}`                            | Sub-issue and dependency graph. Reads `links.yaml`.               |
| **all**      | `./.opencode/tools/local-issues read N --all`      | Bundled YAML: `issue: {...}`, `comments: [...]`, `links: {...}`                                        | One-dispatch full context. Preferred when multiple facets needed. |

______________________________________________________________________

## Per-Type Procedure

### Type: full

Read the complete issue spec and metadata.

| Step | Action       | Command / Details                                       |
| ---- | ------------ | ------------------------------------------------------- |
| 1    | Validate     | Issue number N is a positive integer                    |
| 2    | Read         | `./.opencode/tools/local-issues read N`                                   |
| 3    | Parse output | YAML document with all frontmatter fields + body        |
| 4    | Verify       | Exit code 0, YAML is parseable, required fields present |

**Output fields:** `number`, `repo`, `spec_path`, `title`, `status`, `labels`, `phase`, `created`, `updated`, `github_issue` (if promoted), `remote_url` (if promoted), `body`

______________________________________________________________________

### Type: comments

Read only the comments for an issue.

| Step | Action       | Command / Details                            |
| ---- | ------------ | -------------------------------------------- |
| 1    | Validate     | Issue number N is a positive integer         |
| 2    | Read         | `./.opencode/tools/local-issues read-comments N`               |
| 3    | Parse output | YAML list of comment entries                 |
| 4    | Verify       | Exit code 0, output is a parseable YAML list |

**Output format:** `[{author, timestamp, body}, ...]`

______________________________________________________________________

### Type: labels

Read only the labels for an issue.

| Step | Action       | Command / Details                                     |
| ---- | ------------ | ----------------------------------------------------- |
| 1    | Validate     | Issue number N is a positive integer                  |
| 2    | Read         | `./.opencode/tools/local-issues read-labels N`                          |
| 3    | Parse output | YAML `{labels: [string]}`                             |
| 4    | Verify       | Exit code 0, output has `labels` key with array value |

**Output format:** `labels: [SPEC, needs-approval]`

______________________________________________________________________

### Type: links

Read the sub-issue/dependency graph from `links.yaml`.

| Step | Action       | Command / Details                                |
| ---- | ------------ | ------------------------------------------------ |
| 1    | Validate     | Issue number N is a positive integer             |
| 2    | Read         | `./.opencode/tools/local-issues read-sub-issues N`                 |
| 3    | Parse output | YAML with all link fields                        |
| 4    | Verify       | Exit code 0, output has all expected link fields |

**Output format:**

```yaml
parent:
children: []
related: []
blocked_by: []
duplicate_of:
superseded_by:
```

______________________________________________________________________

### Type: all

Read full issue + comments + links in a single bundled call.

| Step | Action       | Command / Details                                               |
| ---- | ------------ | --------------------------------------------------------------- |
| 1    | Validate     | Issue number N is a positive integer                            |
| 2    | Read         | `./.opencode/tools/local-issues read N --all`                                     |
| 3    | Parse output | Bundled YAML with `issue`, `comments`, `links` top-level keys   |
| 4    | Verify       | Exit code 0, all three top-level sections present and parseable |

**Output format:**

```yaml
issue:
  number: N
  title: '...'
  status: open
  labels: [SPEC, needs-approval]
  phase: spec-design
  body: '...'

comments:
  - author: '...'
    timestamp: '...'
    body: '...'

links:
  parent:
  children: []
  related: []
  blocked_by: []
```

______________________________________________________________________

## Exit Criteria

- \[ \] CLI tool returned exit code 0
- \[ \] Output is valid YAML matching the expected schema for the read type
- \[ \] For `full` and `all`: required fields present (number, title, status, labels, phase)
- \[ \] For `comments`: output is a list, not an object
- \[ \] For `links`: all six link fields present
- \[ \] For `all`: all three top-level keys present and each is parseable

______________________________________________________________________

## Error Handling

| Error                                | Cause                                                             | Resolution                                                                           |
| ------------------------------------ | ----------------------------------------------------------------- | ------------------------------------------------------------------------------------ |
| `./.opencode/tools/local-issues read N` exits non-zero | Issue number N does not exist, directory missing, corrupted files | Verify `.issues/<N>/` exists. Check `spec.md`, `state.md`, `links.yaml` are present. |
| Empty YAML output                    | File exists but is empty                                          | Treat as corrupt. Report to orchestrator. Do not fabricate data.                     |
| YAML parse failure                   | Corrupted YAML frontmatter or malformed comments file             | Read raw files as fallback, report parse error.                                      |
| Issue directory missing              | `.issues/N/` path does not exist                                  | HALT. Issue N does not exist.                                                        |
| CLI tool not found                   | `./.opencode/tools/local-issues` missing                            | HALT. The tool must exist for local platform operations.                             |

**General rule:** All errors must HALT and report the specific failure to the orchestrator. Never silently fabricate or default missing data.

______________________________________________________________________

## CLI Tool Reference

| Operation | Command                                                         |
| --------- | --------------------------------------------------------------- |
| Full read | `./.opencode/tools/local-issues read <N>` (bare) or `read --number opencode-config#7` (qualified) |
| Comments  | `./.opencode/tools/local-issues read-comments <N>`              |
| Labels    | `./.opencode/tools/local-issues read-labels <N>`                |
| Links     | `./.opencode/tools/local-issues read-sub-issues <N>`            |
| Bundle    | `./.opencode/tools/local-issues read <N> --all` (bare) or `read <N> --all --number opencode-config#7` (qualified) |

All commands output YAML. Always check exit code before parsing output.

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
