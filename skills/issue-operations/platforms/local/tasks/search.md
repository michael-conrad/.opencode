<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->

<!-- SPDX-License-Identifier: MIT -->

<!-- Provenance: AI-generated -->

# Local Platform — Search Issues

## Overview

Search local issues in the `.issues/` directory with label and text filters. Returns a YAML array for machine consumption — pipeable to other tools, parseable by agents.

**Primary tool:** `.opencode/tools/local-issues search`

**Interface:**

```bash
local-issues search [--status open|closed|all] [--labels L1,L2] [--query TEXT]
```

**Returns:** YAML array of issue summaries. Empty array `[]` if no matches.

```yaml
  - number: 979
    title: '[SPEC] Example issue title'
    status: open
    labels: [SPEC, needs-approval]
    phase: spec-design
  - number: 40
    title: '[SPEC] Another issue'
    status: open
    labels: [SPEC]
    phase: draft
```

______________________________________________________________________

## Entry Criteria

- \[ \] `.issues/` directory exists at repo root
- \[ \] `.opencode/tools/local-issues` CLI tool is available
- \[ \] Arguments are valid: `--status` is one of `open`, `closed`, `all`; `--labels` is comma-separated (if provided); `--query` is free text (if provided)
- \[ \] At least one filter dimension active when searching (query, labels, or status constraint)

______________________________________________________________________

## Procedure

| Step | Action                | Details                                                                                                                                                                |
| ---- | --------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1    | Resolve status filter | Default `open` if omitted. `all` = no status filtering.                                                                                                                |
| 2    | Resolve label filter  | Parse comma-separated `--labels` into list. Omitted = no label filtering.                                                                                              |
| 3    | Resolve query         | Free text `--query`. Omitted = no text filtering.                                                                                                                      |
| 4    | Execute search        | `local-issues search --query "<query>"` — the tool iterates `.issues/<N>/issue.yaml` files                                                                             |
| 5    | Post-filter in task   | Apply status + label filters not supported by current CLI arguments. If tool does not natively filter by status/labels, apply Python-level filtering in the task step. |
| 6    | Format output         | Transform tool output into the YAML result format. Each entry includes `number`, `title`, `status`, `labels`, `phase` (when set).                                      |
| 7    | Return YAML           | YAML array piped to orchestrator. Empty array `[]` if no results match.                                                                                                |

### Filter Semantics

All filters are AND-combined — a result must match every active filter to be included:

| Filter            | Behavior                                                                        |
| ----------------- | ------------------------------------------------------------------------------- |
| `--status open`   | Only issues with `status == "open"`                                             |
| `--status closed` | Only issues with `status == "closed"`                                           |
| `--status all`    | No status filtering (include both)                                              |
| `--labels L1,L2`  | Issue must have ALL specified labels (AND within labels). Case-sensitive match. |
| `--query TEXT`    | Substring match against title + body. Case-insensitive.                         |

### Phase Field

The `phase` field is included only when the issue has a `phase` key set in its `issue.yaml` frontmatter. If absent, the field is omitted from the YAML entry (not set to `null`).

______________________________________________________________________

## Exit Criteria

- \[ \] YAML array returned (even if empty)
- \[ \] Every entry has `number`, `title`, `status`, `labels`
- \[ \] `phase` included only when present in source data
- \[ \] Status filter applied correctly (open/closed/all)
- \[ \] Label filter applied correctly (AND within labels)
- \[ \] Query filter applied as case-insensitive substring match
- \[ \] Return format is valid YAML — parseable by `yaml.safe_load()`

______________________________________________________________________

## Error Handling

| Error                                      | Cause                                                       | Resolution                                                                                                 |
| ------------------------------------------ | ----------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------- |
| `.issues/` directory missing               | No local issues ever created                                | Return empty array `[]`. Not an error — no issues to search.                                               |
| Invalid `--status` value                   | Not `open`, `closed`, or `all`                              | HALT. Report valid options.                                                                                |
| `--labels` contains empty string           | Trailing comma or empty label                               | Strip empty strings from label list. If all labels are empty, treat as no label filter.                    |
| CLI tool not found                         | `.opencode/tools/local-issues` missing                      | HALT. The tool must exist for local platform operations.                                                   |
| Issue directory has malformed `issue.yaml` | YAML parse error or missing fields                          | Skip the malformed entry. Log warning to stderr: `WARN: issue <N> has malformed issue.yaml — skipping`.    |
| No filters provided                        | Empty `--query`, no `--labels`, and `--status` left default | Return ALL open issues (default behavior). This is valid — listing is a search with no text/label filters. |

**General rule:** Structural errors HALT and report. Data-level errors (malformed single issue) skip and warn. Never silently return incomplete results.

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
