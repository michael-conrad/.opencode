# Task: refactor

## Purpose

Clean up implementation code while keeping all tests passing. Refactoring changes structure, not behavior. The goal is to improve code quality — remove duplication, clarify names, simplify logic — while the test suite confirms no behavioral changes.

## Operating Protocol

1. Invoked by: `/skill test-driven-development --task refactor`
2. When to use: After `--task green` has confirmed passing tests
3. Exit criteria: Code refactored, all tests still pass, no behavior changes

## Principles

1. **Tests stay green:** All tests pass during and after refactoring. If any test fails, revert immediately.
2. **Small steps:** One refactoring at a time. Make the smallest possible change that improves the code, then run tests before the next change.
3. **Run tests after each step:** Ensure nothing breaks before proceeding. Never batch multiple refactorings without testing between them.
4. **No behavior changes:** Refactoring changes structure, not behavior. If the public API changes, it's not a refactoring — it's a new feature requiring a RED test.
5. **Remove duplication:** The primary goal of refactoring is to eliminate duplication revealed by the GREEN phase. When two pieces of code do the same thing, consolidate them.
6. **Improve names:** Rename variables, methods, and classes to better express intent. A good name eliminates the need for a comment.

## Workflow

### Step 1: Identify Refactoring Targets

Review the GREEN phase implementation for code smells:
- Duplicated code across test cases
- Long methods that do too much
- Unclear variable or method names
- Magic numbers without named constants
- Complex conditional logic
- Unnecessary abstraction

### Step 2: Make One Small Refactoring

Choose the smallest, most impactful improvement:
- Extract method (for long methods)
- Rename (for unclear names)
- Replace magic number with constant
- Consolidate duplicate code
- Simplify conditional

### Step 3: Run Tests

```bash
uv run pytest test/test_module.py -v
```

If tests pass → commit the refactoring.
If tests fail → revert the change and try a different approach.

### Step 4: Repeat Until Clean

Continue the cycle:
1. Identify next refactoring target
2. Make the change
3. Run tests
4. Commit if green, revert if red

### Step 5: Final Verification

After all refactorings are complete:
```bash
# All tests must pass
uv run pytest test/ -v

# Lint must pass
uv run ruff check src/ test/

# Type check must pass
uv run pyright src/
```

## Refactoring Techniques by Priority

| Priority | Technique | When to Apply |
|----------|-----------|---------------|
| 1 | Extract method | Long methods, duplicated logic |
| 2 | Rename | Unclear names, abbreviated variables |
| 3 | Replace magic number | Hard-coded values |
| 4 | Consolidate conditional | Complex if/else chains |
| 5 | Remove dead code | Unused imports, unreachable code |
| 6 | Simplify expression | Complex boolean expressions |

## When to Use TDD

| Situation | Use TDD? | Reason |
|-----------|----------|--------|
| New function/class with clear contract | ✅ Yes | Tests define expected behavior |
| Bug fix with clear reproduction | ✅ Yes | Test reproduces bug, fix resolves it |
| Complex algorithm | ✅ Yes | Tests verify edge cases |
| Exploration/prototyping | ❌ No | Behavior not yet defined |
| UI layout changes | ❌ No | Hard to test visually |
| Config/data changes | ❌ No | No code logic to test |
| Refactoring existing code | ✅ Yes | Tests ensure no behavior change |

## Context Required

- Related skills: `test-driven-development` (parent skill)
- Related tasks: `red`, `green`
- `091-incremental-build.md` — per-item TDD cycle discipline