# Task: green

## Purpose

Write minimal implementation code to make the failing test pass. No more, no less. This is the GREEN phase of the Red-Green-Refactor TDD cycle — the sole objective is to transition the test from FAILING to PASSING with the simplest possible implementation.

## Operating Protocol

1. Invoked by: `/skill test-driven-development --task green`
2. When to use: After `--task red` has confirmed a failing test
3. Exit criteria: Implementation written, test PASSES

## Principles

1. **Write minimal code:** Only enough to make the test pass. If the test checks one case, implement exactly that case — no more.
2. **No premature optimization:** Get it working first. Optimization belongs in the REFACTOR phase.
3. **No scope creep:** Don't add features not tested. If the test doesn't require error handling, don't add it.
4. **Don't predict future tests:** Today's test only. Tomorrow's test drives tomorrow's implementation.
5. **Hardcoded values are acceptable:** If the test expects a specific value, returning that hardcoded value is valid. The REFACTOR phase generalizes later.
6. **Copy-paste is acceptable in GREEN:** Duplicate code to make tests pass. The REFACTOR phase eliminates duplication.

## Workflow

### Step 1: Read the Failing Test

Understand exactly what the test expects:
- Input values
- Expected output
- Exceptions expected
- Edge cases tested

### Step 2: Write Minimal Implementation

Write only the code needed to satisfy the test:

```python
# src/module.py

from datetime import date

def parse_date(date_string: str) -> date:
    """Parse ISO format date string to date object."""
    try:
        return date.fromisoformat(date_string)
    except ValueError:
        raise ValueError(f"Invalid date format: {date_string}")
```

### Step 3: Run the Test

```bash
uv run pytest test/test_module.py::test_parse_date_iso_format -v
# Expected: PASSED
```

### Step 4: Run All Related Tests

```bash
uv run pytest test/test_module.py -v
```

If previously passing tests now fail, the implementation introduced a regression. Revert and try a different approach.

### Step 5: Commit (Optional at GREEN)

If the TDD cycle uses per-phase commits:

```bash
git add src/module.py
git commit -m "feat: implement parse_date for ISO format strings"
```

Common TDD patterns commit only after REFACTOR, keeping GREEN commits as WIP.

## Common Anti-Patterns to Avoid

| Anti-Pattern | Why It's Wrong | Correct Approach |
|--------------|---------------|-----------------|
| Implementing error handling for untested cases | YAGNI — You Aren't Gonna Need It | Only handle tested cases |
| Adding a "useful" helper method | Scope creep — not driven by a test | Add helpers only when a test requires them |
| Generalizing a hard-coded return value | Premature abstraction | Keep hard-coded until REFACTOR |
| Writing multiple implementations for future tests | Predicting future requirements | One test, one implementation |

## Transition to REFACTOR

After GREEN phase is complete:
- All tests pass
- Implementation is minimal but correct
- Code may have duplication, poor names, or hard-coded values
- Proceed to `--task refactor` to clean up

## Context Required

- Related skills: `test-driven-development` (parent skill)
- Related tasks: `red`, `refactor`
- `091-incremental-build.md` — per-item TDD cycle discipline