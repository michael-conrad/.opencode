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

## Task Context Schema

```json
{
  "spec_context": "<scope of behavior to implement>",
  "test_path": "<path to test file>",
  "worktree.path": "<if set>",
  "github.owner": "<from session>",
  "github.repo": "<from session>"
}
```

## GREEN Persona Enforcement

GREEN-phase sub-agents implement code only — they MUST NOT write or modify test files.

### 🚫 FORBIDDEN

- Writing new test files
- Modifying existing test files
- Editing test fixtures or test configuration
- Creating any file under `test/` or designated test directories

### ✅ PERMITTED

- Writing implementation code in `src/` or designated source directories
- Modifying existing source files
- Running tests to confirm PASS status (read-only execution)
- Reading test files to understand expected behavior

### Violation Handling

The `post-green-enforcement` gate runs
`git diff --name-only -- test/ | wc -l` and FAILs if the count > 0. If this gate
fires, the orchestrator re-dispatches the GREEN-phase from clean-room state — no
inline fallback.
