<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->

<!-- SPDX-License-Identifier: MIT -->

<!-- Provenance: AI-generated -->

# Local Platform — Tag Gate

## Overview

Reusable task for creating gate tags on the `.opencode` submodule at key pipeline stages. Gate tags provide traceability for promotion, audit, VbC, and review-prep checkpoints. Tags are permanent — never moved, deleted, or overwritten.

**Primary tool:** `git tag` (within `.opencode/` submodule)

**Tag naming convention:**

- `opencode-config/<issue>/phase-<N>-opencode` — GREEN VbC pass checkpoint
- `opencode-config/<issue>/audit-pass-opencode` — Adversarial audit PASS
- `opencode-config/<issue>/code-review-opencode` — Code review ready

______________________________________________________________________

## Parameters

Supplied by calling task via dispatch context:

| Parameter   | Type   | Description                     | Example                                   |
| ----------- | ------ | ------------------------------- | ----------------------------------------- |
| `gate_name` | string | Tag suffix name (maps to phase) | `phase-1-opencode`, `audit-pass-opencode` |
| `issue`     | int    | GitHub issue number             | `979`                                     |
| `message`   | string | Annotation message for the tag  | `"VbC GREEN pass for issue 979 phase 1"`  |

______________________________________________________________________

## Tag Name Construction

```bash
tag_name = "opencode-config/${issue}/${gate_name}"
```

Examples:

- `opencode-config/979/phase-1-opencode`
- `opencode-config/979/audit-pass-opencode`
- `opencode-config/979/code-review-opencode`

______________________________________________________________________

## Entry Criteria

- \[ \] `.opencode/` submodule directory exists and is initialized
- \[ \] `.opencode/` is on a checked-out branch (not detached HEAD — verified via `git branch --show-current` in `.opencode/`)
- \[ \] Clean working tree in `.opencode/` (no uncommitted changes — `git status --porcelain` in `.opencode/` returns empty)
- \[ \] Feature branch is checked out in the parent repo
- \[ \] `gate_name`, `issue`, `message` parameters are all provided and non-empty
- \[ \] Tag does not already exist (`git tag -l "<tag_name>"` in `.opencode/` returns empty)
- \[ \] `issue` is a positive integer

______________________________________________________________________

## Procedure

### Step 1: Construct tag name

Construct the full tag name from the issue number and gate name:

```bash
TAG_NAME="opencode-config/${ISSUE}/${GATE_NAME}"
```

### Step 2: Verify tag does not exist

Check that the tag isn't already created (tags are permanent — never overwritten).

```bash
git tag -l "${TAG_NAME}"  # in .opencode/
```

If non-empty output: HALT and report tag already exists. Tags are permanent — do not overwrite.

### Step 3: Create annotated tag

```bash
git tag "${TAG_NAME}" -m "${MESSAGE}"  # in .opencode/
```

The `-m` flag creates an annotated tag with the supplied message. Annotated tags carry metadata (author, date, message) for audit traceability.

### Step 4: Verify tag creation

```bash
git tag -l "${TAG_NAME}"  # in .opencode/
```

Confirm the tag appears in the tag list. If missing, HALT and report creation failure.

### Step 5: Return result contract

```json
{
  "tag": "opencode-config/<issue>/<gate_name>",
  "created": true
}
```

______________________________________________________________________

## Exit Criteria

- \[ \] Tag name constructed correctly: `opencode-config/<issue>/<gate_name>`
- \[ \] Pre-existing tag verified absent before creation (no overwrites)
- \[ \] Tag created via `git tag <name> -m "<message>"` in `.opencode/`
- \[ \] Tag verified present via `git tag -l` in `.opencode/`
- \[ \] Result contract returned to calling task
- \[ \] No files modified outside `.opencode/`

______________________________________________________________________

## Error Handling

| Error                                    | Cause                                                      | Resolution                                                                                                              |
| ---------------------------------------- | ---------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------- |
| `.opencode/` not found or not a git repo | Submodule not initialized, path missing                    | HALT. Initialize submodule first (`git submodule init && git submodule update`). Report to orchestrator.                |
| Detached HEAD in `.opencode/`            | Submodule on detached HEAD, cannot tag reliably            | HALT. Checkout dev branch in submodule first. Report to orchestrator.                                                   |
| Uncommitted changes in `.opencode/`      | Dirty working tree — tag would reference uncommitted state | HALT. Commit or stash changes in `.opencode/` first. Clean state required before tagging.                               |
| Tag already exists                       | Tag overwrite attempted (tags are permanent)               | HALT. Report existing tag name. Do NOT force or overwrite. The calling task should verify whether re-tagging is needed. |
| `git tag` fails                          | Invalid tag name (spaces, special chars), filesystem error | HALT. Verify tag name format: `opencode-config/<integer>/<alphanumeric-plus-hyphen>`. Report to orchestrator.           |
| Parameters missing                       | `gate_name`, `issue`, or `message` not provided            | HALT. All three parameters are required. Report missing fields.                                                         |
| Invalid issue number                     | `issue` not a positive integer                             | HALT. Issue must be a positive integer. Report to orchestrator.                                                         |

**General rule:** Tags are permanent — never force, overwrite, move, or delete. If tag creation fails, HALT and report. Never silently skip.

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
