<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: Derived from majiayu000/claude-skill-registry (MIT) -->

# Task: anti-patterns

## Purpose

Five common TDD anti-patterns with correct alternatives. Language-agnostic — applies to Python, Java, Go, Rust, JS, etc.

## Anti-Patterns

| # | Anti-Pattern | Symptom | Root Cause | Alternative |
|---|-------------|---------|------------|-------------|
| 1 | **Too-Big Step** | RED→GREEN cycle takes >5 min, multiple asserts in one test | Writing too much implementation at once | Smaller test, one assertion per concept |
| 2 | **Forgotten Red** | Test passes on first run | Test was written after implementation (or tests greenfield code) | Write test first, confirm FAIL before GREEN |
| 3 | **Over-Mocking** | Tests pass but production breaks | Mocked interface doesn't match real behavior | Use real objects or contract tests; mock only external I/O |
| 4 | **Green-Worship** | Code never refactored, accumulating technical debt | Fear of breaking passing tests | REFACTOR is mandatory, not optional. Tests protect you. |
| 5 | **Test-Once** | Single test covers one happy-path only | Edge cases unaddressed, regressions slip through | Add edge-case tests in RED phase; triangulate |

## Pattern Details

### 1. Too-Big Step

**Symptom:** RED→GREEN takes >5 minutes or test has >1 assertion.

**Root cause:** Writing a test that requires implementing multiple behaviors at once.

**Fix:** Decompose the test. Each test covers one behavior. Each RED→GREEN cycle takes 30 seconds to 3 minutes.

```python
# WRONG — Too-Big Step (2 behaviors, complex implementation)
def test_user_registration():
    user = register_user("alice@example.com", "pw")
    assert user.email == "alice@example.com"
    assert user.welcome_email_sent is True

# RIGHT — one behavior per test
def test_user_creation_sets_email():
    user = register_user("alice@example.com", "pw")
    assert user.email == "alice@example.com"

# (Separate RED→GREEN for welcome email)
def test_user_creation_sends_welcome_email():
    user = register_user("alice@example.com", "pw")
    assert user.welcome_email_sent is True
```

### 2. Forgotten Red

**Symptom:** First run of new test PASSES without any implementation code.

**Root cause:** The test was written after the implementation (post-hoc), or the test itself is vacuously true (e.g., testing a constant against itself).

**Fix:** Before writing any implementation, run the test and watch it FAIL. If it passes, the test is wrong.

```python
# WRONG — test written after implementation, always passes
# Implementation already exists
def test_existing_feature():
    assert existing_function() is not None

# RIGHT — test before implementation
# No implementation exists yet
def test_new_feature():
    result = new_function()
    assert result == expected
# First run: FAIL (function doesn't exist)
```

### 3. Over-Mocking

**Symptom:** All tests pass but production crashes.

**Root cause:** Mocks assume an interface contract that doesn't match reality. Common with deep mock chains.

**Fix:** Mock only at system boundaries (external APIs, databases, filesystem). Use real objects for in-process dependencies. Verify mocks match real API signatures.

```python
# WRONG — mocking internal logic
mock_validator = MagicMock()
mock_validator.validate.return_value = True
result = processor.process(mock_validator)
assert result.success

# RIGHT — real object for internal logic
validator = EmailValidator(config)
result = processor.process(validator)
# Mock only external HTTP call
mock_post.assert_called_once()
```

### 4. Green-Worship

**Symptom:** Code smells accumulate. No one refactors because "tests pass."

**Root cause:** Treating GREEN as the terminal state.

**Fix:** REFACTOR is part of every TDD cycle. Small, safe refactors keep code clean. Run tests after each refactor step. If test breaks, revert — the refactor introduced a bug.

```python
# Before REFACTOR — works but smells
def calc(a, b, op):
    if op == "+": return a + b
    if op == "-": return a - b
    if op == "*": return a * b
    if op == "/": return a / b

# After REFACTOR — same behavior, cleaner structure
OPERATIONS = {
    "+": operator.add,
    "-": operator.sub,
    "*": operator.mul,
    "/": operator.truediv,
}

def calc(a, b, op):
    return OPERATIONS[op](a, b)
```

### 5. Test-Once

**Symptom:** Single happy-path test. Regressions appear in edge cases that "were never tested."

**Root cause:** One test per function. No boundary/edge/error cases.

**Fix:** Each TDD cycle adds edge cases. Use triangulation to generalize. Empty/zero/null/overflow/exception cases are mandatory.

```python
# WRONG — Test-Once (happy path only)
def test_divide():
    assert divide(6, 3) == 2

# RIGHT — happy + edge cases
def test_divide_normal():
    assert divide(6, 3) == 2

def test_divide_by_zero_raises():
    with pytest.raises(ZeroDivisionError):
        divide(6, 0)

def test_divide_negative():
    assert divide(-6, 3) == -2
```

## Context Required

- Related skills: `test-driven-development` (parent skill)
- Related tasks: `patterns`, `checklist`
