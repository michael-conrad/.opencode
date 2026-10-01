# Task: selection-guide

## Purpose

File-type tool boundary reference.

## File-Type Tool Boundaries

| File Extension | Linter | Formatter |
|----------------|--------|-----------|
| `.py` | `ruff check` | `ruff format` |
| `.md` | `pymarkdownlnt scan` | `mdformat` |

**CRITICAL:** Never run `ruff` on `.md` files. Never run `pymarkdownlnt` on `.py` files.
