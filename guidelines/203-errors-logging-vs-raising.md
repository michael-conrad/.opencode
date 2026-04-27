# Error Handling: Logging vs Raising

## 3. Logging vs Raising

### Rule: Log AND Raise, Not Log OR Raise

```python
# ❌ WRONG - log only
try:
    risky_operation()
except Exception as e:
    logger.error(f"Failed: {e}")
    # Swallowed - error is lost

# ❌ WRONG - raise only (misses log record)
try:
    risky_operation()
except Exception as e:
    raise  # No log trail

# ✅ CORRECT - log AND raise
try:
    risky_operation()
except Exception as e:
    logger.error(f"Operation failed: {e}", exc_info=True)
    raise  # Preserve traceback
```

______________________________________________________________________

## 4. Agent Behavior Requirements

Agents MUST:

1. **Never write code that swallows exceptions** - no `except: pass`, no `except Exception: continue`, no silent returns
2. **Never hide missing data** - no defaults, no placeholders, no synthetic data for required fields
3. **Always add context** - wrap exceptions with relevant information at each layer
4. **Use domain-specific exceptions when appropriate** - create API/module-specific exception classes (e.g., `MeshValidationError`, `PubMedAPIError`) to clarify WHERE and WHAT failed
5. **Validate early** - check required parameters at function entry
6. **Use type hints** - `Optional` for optional data, non-optional for required data
7. **Document failure modes** - if a function can fail, document HOW it fails in docstring

______________________________________________________________________

## 5. Code Review Checklist

When reviewing code, check:

- [ ] No bare `except:` blocks
- [ ] No `except Exception: pass` or `except: pass`
- [ ] All `except` blocks either re-raise or raise a new exception
- [ ] Required parameters validated at function entry
- [ ] No defaults applied to missing required data
- [ ] No placeholder/fabricated data used to fill gaps
- [ ] Type hints use `Optional` explicitly for nullable data
- [ ] Error messages include relevant context (ids, names, paths)
- [ ] Logging is paired with re-raising, not standalone
- [ ] Domain-specific exception classes used for API/module boundaries
- [ ] Exception hierarchies used for complex modules (BaseError, APIError, ValidationError, etc.)

______________________________________________________________________

## 6. Cross-References

- **090-data-integrity.md** - Data quality and validation rules
- **070-environment.md** - Production data protection
- **080-code-standards.md** - Code quality standards
- **Session Init Plugin**: Agent initialization and boundaries

This guideline is foundational. When in doubt: **raise, don't return.**

______________________________________________________________________

*Source: Content migrated from `095-never-hide-problems.md`*

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-04-25T00:00:00Z"
rules:
  - id: logging-vs-raising-001
    title: "Log AND raise — never log only or raise only"
    conditions:
      any:
        - "pattern == 'log_without_reraise'"
        - "pattern == 'raise_without_log'"
    actions:
      - HALT
    conflicts_with: []
    requires: []
    triggers: []
    source: "203-errors-logging-vs-raising.md §3. Logging vs Raising"

  - id: logging-vs-raising-002
    title: "Agents must never write code that swallows exceptions"
    conditions:
      any:
        - "code_pattern == 'except: pass'"
        - "code_pattern == 'except Exception: continue'"
        - "code_pattern == 'silent_return'"
    actions:
      - HALT
    conflicts_with: []
    requires: []
    triggers: []
    source: "203-errors-logging-vs-raising.md §4. Agent Behavior"

  - id: logging-vs-raising-003
    title: "Agents must never hide missing data"
    conditions:
      any:
        - "code_pattern == 'default_for_required_field'"
        - "code_pattern == 'placeholder_data'"
        - "code_pattern == 'synthetic_data'"
    actions:
      - HALT
    conflicts_with: []
    requires: []
    triggers: []
    source: "203-errors-logging-vs-raising.md §4. Agent Behavior"

  - id: logging-vs-raising-004
    title: "Always add context when wrapping exceptions"
    conditions:
      all:
        - "catching_exception == true"
        - "context_added == false"
        - "re_raising == true"
    actions:
      - HALT
    conflicts_with: []
    requires: []
    triggers: []
    source: "203-errors-logging-vs-raising.md §4. Agent Behavior"

  - id: logging-vs-raising-005
    title: "When in doubt raise, don't return"
    conditions:
      all:
        - "error_occurred == true"
        - "action == 'return_value'"
    actions:
      - HALT
    conflicts_with: []
    requires: []
    triggers: []
    source: "203-errors-logging-vs-raising.md §6. Cross-References"
```
