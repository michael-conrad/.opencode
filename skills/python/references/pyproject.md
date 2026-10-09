<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2557 -->

# pyproject.toml — project definition

`pyproject.toml` declares what the project is. It is the single project-level
source for metadata, dependencies, build backend, tool configuration, and entry
points.

## Sections that matter

- **`[build-system]`** — the build backend and its requirements
  (`requires = [...]`, `build-backend = "..."`). The backend determines how
  `uv build`/pip produce distributions.
- **`[project]`** — core metadata: `name`, `version`, `description`,
  `requires-python`, `dependencies`, optional `[project.optional-dependencies]`
  and dependency groups.
- **`[project.scripts]`** — console entry points (command name → module:function).
- **Tool sections** — `[tool.<name>]` per tool (ruff, pytest, coverage, …);
  each tool reads its own section; keep tool configuration in the project
  definition rather than scattered dotfiles where the tool supports pyproject.

## Discipline

- The declared version is the release truth — bump it through the
  version-manager discipline (semver level follows the changelog category), not
  by hand-editing ad hoc.
- Dependency declarations are explicit: name + constraint. Prefer bounded
  constraints (`>=x,<y`) for applications; looser floors for libraries.
- When a change adds/removes dependencies, `uv add`/`uv remove` keeps
  pyproject.toml and the lockfile coherent — hand-editing pyproject.toml alone
  leaves the lockfile stale.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
