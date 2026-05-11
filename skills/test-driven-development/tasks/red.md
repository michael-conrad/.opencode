<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: Derived from majiayu000/claude-skill-registry (MIT) -->

# Task: red

## Invocation

`/skill test-driven-development --task red`

## Exit Criteria

Test written and confirmed FAILING (or ERROR if function doesn't exist yet).

## Verification Command

```bash
uv run pytest test/test_module.py::test_<name> -v
# Expected: FAILED (or ERROR)
```

## Dispatch Context Schema

```json
{
  "spec_context": "<scope of behavior to test>",
  "test_path": "<path to test file>",
  "worktree.path": "<if set>",
  "github.owner": "<from session>",
  "github.repo": "<from session>"
}
```
