---
name: python
description: "Load when working in or on a Python project — writing, modifying, reviewing, or testing Python code; managing its environment, dependencies, and tool runs; declaring, building, or running it. Owns the language's conventions and Python's DI practice, and routes to detail cards for environment and dependency operations, project definition, and conventions. General engineering principles and cross-language practices belong to `programming-principles`."
license: MIT
provenance: AI-authored, .opencode#2557
---

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2557; conventions restored from the defunct guidelines corpus (082, deck-level items) -->

# python

This card owns the Python-project ecosystem: the language's conventions, the
environment and tooling layer, and the project-definition surface. Detail cards
carry the depth — each is reached when its concern arises:

- **Environment and dependency operations** — [the uv detail card](references/uv.md):
  running, testing, and building through the project environment; dependency
  sets and lockfile; the Python specialization of build verification.
- **Project definition** — [the pyproject detail card](references/pyproject.md):
  declaring what the project is — metadata, dependencies, build backend,
  tool sections, entry points.
- **Language conventions** — [the conventions detail card](references/conventions.md):
  typing, pathlib, f-strings, print discipline, and Python's DI practice.

Python's DI practice presupposes the cross-language mandate — the shared card
under `programming-principles` carries the mandate and the tier table; this
card's conventions detail carries the Python pin.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
