<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2557; conventions restored from the defunct 082-python-standards (deck-level items only) -->

# Python conventions

Deck-level language standards for Python code. Project-local rules (pipeline
constraints, database conventions) belong to the project's own AGENTS.md, not
this card.

## Typing

- Explicit type hints project-wide, using Pydantic models or dataclasses for
  structured data. Avoid `Any` — use concrete types; `Any` is acceptable only
  when imposed by third-party signatures.
- Use modern built-in generics — `list[str]`, `dict[str, Any]` — not
  `typing.List`/`typing.Dict` (3.9+ syntax).

## Filesystem — pathlib

- `pathlib.Path` exclusively for file and directory operations — no
  `os.path.join`, no `os.mkdir`, no string-concatenated paths. Use the `/`
  operator to build paths.

## Strings — f-strings

- f-strings for all string interpolation. `.format()` or `%` only when an
  external constraint requires them.

## Print discipline

Print statements are for data output and user-facing information only:

- Never add prints that narrate code changes, signal feature updates, or
  announce implementation details ("implemented phase 1", "now using X") —
  code speaks through documentation and version control, not console chatter.
- Valid uses: progress bars, data summaries, error messages, user-facing
  status, diagnostic output during development/testing.
- If context is needed, add a docstring, code comment, or documentation — never
  a print.

## Dependency injection — the Python pin

The cross-language mandate lives in the shared card under
`programming-principles` (use a DI approach; tier table and selection guidance
there). For Python the clear-standard package is **`dependency-injector`**:

- **Container-first pattern:** declare a container class that registers each
  dependency as a provider and wires them into services; define the wiring
  graph once and let the container resolve for all consumers.
- Do not hand-roll DI containers, use ad-hoc module-level singletons, or wire
  dependencies through arbitrary parameter passing.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
