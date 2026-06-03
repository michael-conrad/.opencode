<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->

<!-- SPDX-License-Identifier: MIT -->

<!-- Provenance: AI-generated -->

# Local Platform — List Issues

## Overview

List local issues in the `.issues/` directory. Simpler than search — no label or text query filters. Returns a YAML array for machine consumption.

**Primary tool:** `.opencode/tools/local-issues list`

**Interface:**

```bash
local-issues list [--status open|closed|all]
```

**Returns:** YAML array of issue summaries. Empty array `[]` if no issues.

```yaml
  - number: 979
    title: '[SPEC] Example issue title'
    status: open
    phase: spec-design
  - number: 40
    title: '[SPEC] Another issue'
    status: open
```

______________________________________________________________________

## Entry Criteria

- \[ \] `.issues/` directory exists at repo root
- \[ \] `.opencode/tools/local-issues` CLI tool is available
- \[ \] `--status` argument is one of `open`, `closed`, or `all` (default: `open`)

______________________________________________________________________

## Procedure

| Step | Action                | Details                                                                                                                                          |
| ---- | --------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| 1    | Resolve status filter | Default `open` if omitted. `all` = no status filtering.                                                                                          |
| 2    | Execute list          | `.opencode/tools/local-issues list` — iterates `.issues/<N>/issue.yaml` files                                                                                    |
| 3    | Post-filter by status | Apply `--status` filter not supported by current CLI. If tool does not natively filter by status, apply Python-level filtering in the task step. |
| 4    | Format output         | Transform into YAML result format. Each entry includes `number`, `title`, `status`, `phase` (when set).                                          |
| 5    | Return YAML           | YAML array piped to orchestrator. Empty array `[]` if no issues match.                                                                           |

### Filter Behavior

| Filter            | Behavior                              |
| ----------------- | ------------------------------------- |
| `--status open`   | Only issues with `status == "open"`   |
| `--status closed` | Only issues with `status == "closed"` |
| `--status all`    | No status filtering (include both)    |

### Phase Field

The `phase` field is included only when the issue has a `phase` key set in its `issue.yaml` frontmatter. If absent, the field is omitted from the YAML entry (not set to `null`).

______________________________________________________________________

## Exit Criteria

- \[ \] YAML array returned (even if empty)
- \[ \] Every entry has `number`, `title`, `status`
- \[ \] `phase` included only when present in source data
- \[ \] Status filter applied correctly (open/closed/all)
- \[ \] Return format is valid YAML — parseable by `yaml.safe_load()`

______________________________________________________________________

## Error Handling

| Error                                      | Cause                                  | Resolution                                                                                              |
| ------------------------------------------ | -------------------------------------- | ------------------------------------------------------------------------------------------------------- |
| `.issues/` directory missing               | No local issues ever created           | Return empty array `[]`. Not an error — no issues to list.                                              |
| Invalid `--status` value                   | Not `open`, `closed`, or `all`         | HALT. Report valid options.                                                                             |
| CLI tool not found                         | `.opencode/tools/local-issues` missing | HALT. The tool must exist for local platform operations.                                                |
| Issue directory has malformed `issue.yaml` | YAML parse error or missing fields     | Skip the malformed entry. Log warning to stderr: `WARN: issue <N> has malformed issue.yaml — skipping`. |

**General rule:** Structural errors HALT and report. Data-level errors (malformed single issue) skip and warn. Never silently return incomplete results.

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
