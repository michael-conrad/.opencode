<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: Derived from majiayu000/claude-skill-registry (MIT) -->

# Task: patterns

## Purpose

Decision matrix for selecting the correct TDD pattern. Each pattern corresponds to a different level of certainty about the desired implementation.

## Four-Pattern Decision Matrix

| Pattern | When to Use | Certainty | Steps |
|---------|------------|-----------|-------|
| **Straight-Red** | Clear contract, algorithm known | High | RED → GREEN → REFACTOR |
| **Triangulation** | Boundary/edge cases uncertain | Medium | RED (edge 1) → GREEN → RED (edge 2) → GENERALIZE → REFACTOR |
| **Obvious Implementation** | Trivial solution, no design needed | Very High | GREEN only (skip RED) |
| **One-to-Many** | Same behavior across multiple inputs | High | RED (parameterized) → GREEN (loop/table) → REFACTOR |

## Pattern Details

### Straight-Red

Default pattern. Write one failing test, implement to pass, refactor. No ambiguity about what the function should do.

```
RED (write test → confirm FAIL)
  ↓
GREEN (minimal impl → confirm PASS)
  ↓
REFACTOR (clean → confirm still PASS)
```

```bash
# RED
uv run pytest test/test_module.py::test_feature_x -v
# Expected: FAILED

# GREEN
uv run pytest test/test_module.py::test_feature_x -v
# Expected: PASSED

# REFACTOR
uv run pytest test/ -v
# Expected: all PASSED
```

### Triangulation

Use when a single test doesn't force the right generalization. Add a second, third example until the implementation naturally generalizes.

```
RED (test case 1 → FAIL)
  ↓
GREEN (passes case 1)
  ↓
RED (test case 2 → FAIL)
  ↓
GREEN (passes case 1+2)
  ↓
... repeat until generalized
  ↓
REFACTOR
```

```python
# RED — case 1
def test_parse_date_iso():
    assert parse_date("2026-04-07") == date(2026, 4, 7)
# GREEN — return date(2026, 4, 7)

# RED — case 2
def test_parse_date_iso_alt():
    assert parse_date("2025-12-25") == date(2025, 12, 25)
# GREEN — use date.fromisoformat()
```

### Obvious Implementation

Skip RED when the solution is trivially correct and the test would pass on first write. Only applies when:
- One-liner implementation
- No design decisions needed
- Zero ambiguity about correctness

```python
# No RED needed — trivial
def is_positive(n: int) -> bool:
    return n > 0
```

### One-to-Many

Same assertion structure repeated across inputs. Use parameterized tests to collapse N tests into one.

```python
import pytest

@pytest.mark.parametrize("input,expected", [
    ("", 0),
    ("hello", 5),
    ("hello world", 11),
])
def test_string_length(input, expected):
    assert string_length(input) == expected
```

## Context Required

- Related skills: `test-driven-development` (parent skill)
- Related tasks: `red`, `green`, `refactor`, `checklist`
