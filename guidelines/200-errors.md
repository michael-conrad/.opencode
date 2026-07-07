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

## 4. Agent Behavior Requirements

- Agents MUST never write code that swallows exceptions
- Agents MUST never hide missing data with placeholders
- Agents MUST always add context when wrapping exceptions
- When in doubt: raise, don't return

## 5. Code Review Checklist

When reviewing code for error handling compliance:
- [ ] No bare `except:` blocks
- [ ] No `except: pass` or `except Exception: pass/continue`
- [ ] No log-without-reraise patterns
- [ ] All exceptions are wrapped with context (`raise X from e`)
- [ ] Required data never gets silent defaults
- [ ] Domain-specific exceptions at module boundaries
- [ ] Optional data uses explicit `Optional[X]` type hints
- [ ] Fail-fast validation at function entry
