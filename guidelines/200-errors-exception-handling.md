# Error Handling: Exception Handling

## Global Absolute Prohibition

**NEVER FUCKING SWALLOW EXCEPTIONS OR OTHERWISE HIDE ERRORS OR MISSING DATA.**

This is a zero-tolerance rule. Violations will be:

- Caught in code review
- Flagged immediately during implementation
- Treated as critical bugs requiring immediate fix

______________________________________________________________________

## 1. Exception Handling Rules

### 🚫 FORBIDDEN PATTERNS

#### Bare except

```python
# ❌ FORBIDDEN - catches KeyboardInterrupt, SystemExit
try:
    ...
except:
    pass
```

**WHY**: Bare `except:` catches EVERYTHING, including system exit signals and keyboard interrupts. It hides critical control flow.

**CORRECT**: Specify exception types, or use `except Exception:` if truly needed.

______________________________________________________________________

#### Bare except Exception

```python
# ❌ FORBIDDEN - silently discards all errors
try:
    ...
except Exception:
    pass
```

**WHY**: This pattern is an anti-pattern used to "make code not crash". It's a bug factory - errors are hidden, not handled.

**CORRECT**:

```python
try:
    result = some_operation()
except SomeSpecificError as e:
    logger.error(f"Failed to X: {e}")
    raise  # RE-RAISE - do not swallow
except Exception as e:
    # Catch-all only for logging context, then re-raise
    logger.error(f"Unexpected error in Y: {e}")
    raise RuntimeError(f"Failed during Y: {e}") from e
```

______________________________________________________________________

#### Pass or continue in except block

```python
# ❌ FORBIDDEN - error is lost
try:
    process_data(data)
except Exception:
    pass  # or continue, or return None
```

**WHY**: The error disappears. Downstream code receives no signal that anything went wrong.

**CORRECT**:

```python
try:
    process_data(data)
except DataValidationError as e:
    raise ValueError(f"Invalid data at record {record_id}: {e}") from e
```

______________________________________________________________________

#### Log without re-raise

```python
# ❌ FORBIDDEN - log only, no propagation
try:
    ...
except Exception as e:
    logger.error(f"Something went wrong: {e}")
    # Function continues as if nothing happened
```

**WHY**: Logging is NOT error handling. The error is hidden from the caller.

**CORRECT**:

```python
try:
    ...
except Exception as e:
    logger.error(f"Critical failure: {e}")
    raise  # MUST RE-RAISE
```

______________________________________________________________________

### ✅ REQUIRED PATTERNS

#### Explicit exception types

```python
# ✅ GOOD - specific, re-raises
try:
    file_content = read_file(path)
except FileNotFoundError:
    raise ValueError(f"Configuration file not found: {path}")
except PermissionError as e:
    raise RuntimeError(f"Insufficient permissions for {path}: {e}") from e
```

______________________________________________________________________

#### Contextual error wrapping

```python
# ✅ GOOD - adds context at each layer
def process_record(record_id: int) -> ProcessedRecord:
    try:
        raw_data = fetch_raw_data(record_id)
        return transform(raw_data)
    except DatabaseError as e:
        raise DataFetchError(f"Failed to fetch record {record_id}: {e}") from e
    except ValidationError as e:
        raise ProcessingError(f"Record {record_id} failed validation: {e}") from e
```

**WHY**: Each layer adds relevant context. The final error message tells you WHERE (process_record), WHAT (fetch vs validation), and WHY (original cause).

______________________________________________________________________

#### Let it crash (when appropriate)

```python
# ✅ GOOD - don't catch if you can't handle
def calculate_average(values: list[float]) -> float:
    # Let ZeroDivisionError propagate naturally
    # The caller can decide if empty list is acceptable
    return sum(values) / len(values)
```

**WHY**: Not every error needs a try-except. If you can't add context or handle it meaningfully, let it propagate to code that can.

______________________________________________________________________

*Source: Content migrated from `095-never-hide-problems.md`*

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-04-25T00:00:00Z"
rules:
  - id: exception-handling-001
    title: "Never swallow exceptions or hide errors"
    conditions:
      any:
        - "code_pattern == 'except: pass'"
        - "code_pattern == 'except Exception: pass'"
        - "code_pattern == 'except Exception: continue'"
        - "code_pattern == 'except Exception: return None'"
    actions:
      - HALT
    conflicts_with: []
    requires: []
    triggers: []
    source: "200-errors-exception-handling.md §Global Absolute Prohibition"

  - id: exception-handling-002
    title: "No bare except blocks"
    conditions:
      all:
        - "code_pattern == 'except:'"
    actions:
      - HALT
    conflicts_with: []
    requires: []
    triggers: []
    source: "200-errors-exception-handling.md §Exception Handling Rules"

  - id: exception-handling-003
    title: "No log-without-reraise pattern"
    conditions:
      all:
        - "code_pattern == 'log_error_without_reraise'"
    actions:
      - HALT
    conflicts_with: []
    requires: []
    triggers: []
    source: "200-errors-exception-handling.md §Exception Handling Rules"

  - id: exception-handling-004
    title: "Exceptions must re-raise or wrap with context"
    conditions:
      all:
        - "except_block_exists == true"
        - "re_raises == false"
        - "wraps_with_context == false"
    actions:
      - HALT
    conflicts_with: []
    requires: []
    triggers: []
    source: "200-errors-exception-handling.md §Exception Handling Rules"

  - id: exception-handling-005
    title: "Use contextual error wrapping at each layer"
    conditions:
      all:
        - "exception_caught == true"
    actions:
      - PROCEED
    conflicts_with: []
    requires: []
    triggers: []
    source: "200-errors-exception-handling.md §Required Patterns"

  - id: exception-handling-006
    title: "Let it crash when you cannot add meaningful context"
    conditions:
      all:
        - "can_add_context == false"
        - "can_handle_meaningfully == false"
    actions:
      - PROCEED
    conflicts_with: []
    requires: []
    triggers: []
    source: "200-errors-exception-handling.md §Required Patterns"
```
