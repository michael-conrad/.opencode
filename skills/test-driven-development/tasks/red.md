# Task: red

## Purpose

Write a failing test that defines the expected behavior before any implementation code exists. This is the RED phase of the Red-Green-Refactor TDD cycle — the test acts as a specification that drives the implementation.

## Operating Protocol

1. Invoked by: `/skill test-driven-development --task red`
2. When to use: When starting TDD cycle — writing the first test for new behavior
3. Exit criteria: Test written and confirmed FAILING (or ERROR if function doesn't exist yet)

## Principles

1. **Test defines the contract:** The test specifies exactly what the function/class should do. If the test is ambiguous, the specification is ambiguous.
2. **Test must fail:** If the test passes without implementation, the test is wrong — it's not testing anything meaningful. A passing RED test means the behavior already exists.
3. **One assertion per test concept:** Each test method should verify one behavioral concept. Multiple assertions are acceptable if they test the same concept (e.g., checking multiple properties of the same result).
4. **Use meaningful test names:** `test_functionName_expectedBehavior_whenCondition` — the test name should read as a sentence describing the expected behavior.
5. **Test the interface, not the implementation:** Tests should verify observable behavior, not internal structure. Avoid testing private methods or internal state.
6. **Arrange-Act-Assert pattern:** Structure each test with setup, execution, and verification phases separated clearly.

## Workflow

### Step 1: Identify the Behavior to Test

From the spec or plan, extract the specific behavior that needs a test:
- Input conditions
- Expected output
- Error conditions
- Edge cases

### Step 2: Write the Test

```python
# test/test_module.py

import pytest
from datetime import date
from src.module import parse_date  # Will fail at import — that's expected

def test_parse_date_iso_format():
    """parse_date should return date object for ISO format strings."""
    result = parse_date("2026-04-07")
    assert result == date(2026, 4, 7)

def test_parse_date_invalid_input_raises():
    """parse_date should raise ValueError for invalid date strings."""
    with pytest.raises(ValueError, match="Invalid date format"):
        parse_date("not-a-date")
```

### Step 3: Verify the Test Fails

```bash
uv run pytest test/test_module.py::test_parse_date_iso_format -v
# Expected: FAILED or ERROR (ImportError if function doesn't exist yet)
```

If the test PASSES, the test is not testing new behavior. Either:
- The function already exists with correct behavior (verify it's the right function)
- The test is trivially true (rewrite with meaningful assertions)

### Step 4: Record Test Location

Document where the test lives for the GREEN phase:

```
RED phase complete:
- Test file: test/test_module.py
- Test functions: test_parse_date_iso_format, test_parse_date_invalid_input_raises
- Status: FAILING (expected)
- Proceed to: --task green
```

## Test Location Convention

Tests go in `test/` directory following project convention:

```
test/
├── test_module.py          # Unit tests for src/module.py
├── test_integration.py     # Integration tests
└── conftest.py             # Shared fixtures
```

Test filenames mirror source filenames: `src/parser.py` → `test/test_parser.py`.

## Verification

```bash
# Test must FAIL before implementation
uv run pytest test/test_module.py::test_parse_date_iso_format -v
# Expected: FAILED (or ERROR if function doesn't exist yet)
```

## Edge Cases in RED Phase

| Situation | Resolution |
|-----------|-----------|
| Import fails (function doesn't exist) | Expected — ERROR status is valid RED |
| Test passes immediately | Test is wrong — rewrite to test new behavior |
| Multiple tests needed for one behavior | Write all RED tests, then go to GREEN |
| Test requires fixture | Add fixture to conftest.py |

## Context Required

- Related skills: `test-driven-development` (parent skill)
- Related tasks: `green`, `refactor`
- `091-incremental-build.md` — per-item TDD cycle discipline