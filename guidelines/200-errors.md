---
trigger_on: exception, error handling, missing data, null, absent, logging, raise, domain exception
tier: 2
load_when: sub-agent
---

# Error Handling

**NEVER FUCKING SWALLOW EXCEPTIONS OR OTHERWISE HIDE ERRORS OR MISSING DATA.**

## Forbidden Patterns

- `except: pass`, `except Exception: pass/continue/return None`
- Log without re-raise (log AND raise, not log OR raise)
- Silent defaults for required data (`data.get("key", "default")` when key required)
- Placeholder/synthetic data for missing fields
- None returns for required data (raise instead)
- Bare `Exception` for domain errors

## Required Patterns

- Specific exception types with contextual wrapping (`raise XError(...) from e`)
- Use domain-specific exception classes for API/module boundaries
- Preserve exception chain with `from e`
- `Optional[X]` type hint for nullable data, `X` for required
- Fail fast — validate required parameters at function entry
- When in doubt: raise, don't return

**See also:** `090-data-integrity.md`, `080-code-standards.md`, `programming-principles` skill.

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
    actions: [HALT]
    source: "200-errors.md §Forbidden Patterns"

  - id: exception-handling-002
    title: "No bare except blocks"
    conditions:
      all: ["code_pattern == 'except:'"]
    actions: [HALT]
    source: "200-errors.md §Forbidden Patterns"

  - id: exception-handling-003
    title: "No log-without-reraise pattern"
    conditions:
      all: ["code_pattern == 'log_error_without_reraise'"]
    actions: [HALT]
    source: "200-errors.md §Forbidden Patterns"

  - id: exception-handling-004
    title: "Exceptions must re-raise or wrap with context"
    conditions:
      all: ["except_block_exists == true", "re_raises == false", "wraps_with_context == false"]
    actions: [HALT]
    source: "200-errors.md §Forbidden Patterns"

  - id: exception-handling-005
    title: "Use contextual error wrapping at each layer"
    conditions:
      all: ["exception_caught == true"]
    actions: [PROCEED]
    source: "200-errors.md §Required Patterns"

  - id: exception-handling-006
    title: "Let it crash when you cannot add meaningful context"
    conditions:
      all: ["can_add_context == false", "can_handle_meaningfully == false"]
    actions: [PROCEED]
    source: "200-errors.md §Required Patterns"

  - id: missing-data-001
    title: "No silent defaults for required data"
    conditions:
      all: ["data_field_required == true", "default_applied == true"]
    actions: [HALT]
    source: "200-errors.md §Forbidden Patterns"

  - id: missing-data-002
    title: "No placeholder or synthetic data for missing fields"
    conditions:
      any:
        - "code_pattern == 'or_date_today'"
        - "code_pattern == 'or_unknown_string'"
        - "code_pattern == 'fabricated_default'"
    actions: [HALT]
    source: "200-errors.md §Forbidden Patterns"

  - id: missing-data-003
    title: "No None returns for required data"
    conditions:
      all: ["function_return_type == 'Optional'", "data_is_required == true"]
    actions: [HALT]
    source: "200-errors.md §Forbidden Patterns"

  - id: missing-data-004
    title: "Required data must raise on missing"
    conditions:
      all: ["required_field_missing == true", "exception_raised == false"]
    actions: [HALT]
    source: "200-errors.md §Required Patterns"

  - id: missing-data-005
    title: "Optional data must use Optional type hints explicitly"
    conditions:
      all: ["data_may_be_none == true", "type_hint != 'Optional'"]
    actions: [HALT]
    source: "200-errors.md §Required Patterns"

  - id: domain-exceptions-001
    title: "Use domain-specific exception classes for API/module boundaries"
    conditions:
      all: ["has_distinct_api_module == true", "different_failure_modes == true", "using_generic_Exception == true"]
    actions: [PROCEED]
    source: "200-errors.md §Required Patterns"

  - id: domain-exceptions-002
    title: "Preserve exception chain with from e"
    conditions:
      all: ["wrapping_exception == true", "from_e_used == false"]
    actions: [HALT]
    source: "200-errors.md §Required Patterns"

  - id: domain-exceptions-003
    title: "Don't create domain exceptions for local-only errors"
    conditions:
      all: ["error_local_to_one_function == true", "caught_immediately == true", "ValueError_sufficient == true"]
    actions: [PROCEED]
    source: "200-errors.md §When not needed"

  - id: domain-exceptions-004
    title: "Never use bare Exception for domain errors"
    conditions:
      all: ["raise_statement == 'Exception'"]
    actions: [HALT]
    source: "200-errors.md §Forbidden Patterns"

  - id: logging-vs-raising-001
    title: "Log AND raise — never log only or raise only"
    conditions:
      any: ["pattern == 'log_without_reraise'", "pattern == 'raise_without_log'"]
    actions: [HALT]
    source: "200-errors.md §Forbidden Patterns"

  - id: logging-vs-raising-002
    title: "Agents must never write code that swallows exceptions"
    conditions:
      any:
        - "code_pattern == 'except: pass'"
        - "code_pattern == 'except Exception: continue'"
        - "code_pattern == 'silent_return'"
    actions: [HALT]
    source: "200-errors.md §Forbidden Patterns"

  - id: logging-vs-raising-003
    title: "Agents must never hide missing data"
    conditions:
      any:
        - "code_pattern == 'default_for_required_field'"
        - "code_pattern == 'placeholder_data'"
        - "code_pattern == 'synthetic_data'"
    actions: [HALT]
    source: "200-errors.md §Forbidden Patterns"

  - id: logging-vs-raising-004
    title: "Always add context when wrapping exceptions"
    conditions:
      all: ["catching_exception == true", "context_added == false", "re_raising == true"]
    actions: [HALT]
    source: "200-errors.md §Required Patterns"

  - id: logging-vs-raising-005
    title: "When in doubt raise, don't return"
    conditions:
      all: ["error_occurred == true", "action == 'return_value'"]
    actions: [HALT]
    source: "200-errors.md §Rule"
```
