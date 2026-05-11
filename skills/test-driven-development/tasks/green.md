<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: Derived from majiayu000/claude-skill-registry (MIT) -->

# Task: green

## Invocation

`/skill test-driven-development --task green`

## Exit Criteria

Implementation written, test PASSES.

## Verification Command

```bash
uv run pytest test/test_module.py::test_<name> -v
# Expected: PASSED

# Confirm no regressions
uv run pytest test/ -v
# Expected: all PASSED
```

## Dispatch Context Schema

```json
{
  "spec_context": "<scope of behavior to implement>",
  "test_path": "<path to test file>",
  "worktree.path": "<if set>",
  "github.owner": "<from session>",
  "github.repo": "<from session>"
}
```
