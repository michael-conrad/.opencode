<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: Derived from majiayu000/claude-skill-registry (MIT) -->

# Task: refactor

## Invocation

`` `skill({name: "test-driven-development"})` `` then `` `task(..., prompt: "execute refactor task from test-driven-development")` ``

## Exit Criteria

Code refactored, all tests still pass, no behavior changes.

## Verification Command

```bash
uv run pytest test/ -v
# Expected: all PASSED
```

## Task Context Schema

```json
{
  "spec_context": "<scope of behavior to refactor>",
  "test_path": "<path to test file>",
  "worktree.path": "<if set>",
  "github.owner": "<from session>",
  "github.repo": "<from session>"
}
```

## When to Use TDD

| Situation | Use TDD? | Reason |
|-----------|----------|--------|
| New function/class with clear contract | ✅ Yes | Tests define expected behavior |
| Bug fix with clear reproduction | ✅ Yes | Test reproduces bug, fix resolves it |
| Complex algorithm | ✅ Yes | Tests verify edge cases |
| Exploration/prototyping | ❌ No | Behavior not yet defined |
| UI layout changes | ❌ No | Hard to test visually |
| Config/data changes | ❌ No | No code logic to test |
