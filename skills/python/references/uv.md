<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2557; command surface verified against live uv docs 2026-10-07 -->

# uv — environment and dependency operations

uv owns the project environment: the interpreter, the dependency set, the
lockfile, and the tool runs. Facts below verified against the live uv docs
(0.12.x, 2026-10-07).

## Runner discipline

- Run and test **through the project environment** — `uv run <cmd>` — never
  through bare interpreters. `uv run` auto-locks and auto-syncs the project
  environment first, so what executes matches the declared dependency set.
- Execute project tools the same way: `uv run ruff check src/`,
  `uv run python -m pytest`. Ephemeral CLI tools use `uvx <tool>`
  (equivalent to `uv tool run`) — a cached, isolated environment per tool.

## Dependency set and lockfile

- `uv add <pkg>` / `uv remove <pkg>` mutate `pyproject.toml` and the
  environment together (`--dev` / `--group` / `--optional` for the other
  dependency fields).
- `uv lock` creates/updates `uv.lock`; `uv lock --check` verifies staleness;
  `uv lock --upgrade` upgrades pinned versions.
- `uv sync` performs an exact sync (removes extraneous packages) and installs
  the project itself. `uv run`'s default sync is inexact — use `uv sync` when
  the environment must match the lockfile exactly.
- **`uv.lock` is checked into version control** — it is the reproducibility
  record; never hand-edit it (it is uv-managed and not usable by other tools).

## Canonical-command sourcing

Build/test commands come from the repository's declared build manifest — ask
when the manifest does not declare them; never guess. The manifest's commands
run through `uv run`/`uvx` as appropriate.

## Build verification — Python specialization

When a change affects build configuration or packaging (or the deliverable is a
build artifact), verify it the deck way, specialized for Python:

1. Shallow temp-copy checkout of the tree (`git clone --depth 1`).
2. Environment setup in the shallow checkout — `uv sync` establishes the
   project environment from the lockfile.
3. Run the manifest's canonical build — `uv build` produces the sdist and wheel
   into `dist/`.
4. Assert the final outputs: `dist/` contains the expected wheel and sdist, and
   the built artifact is sound (inspect metadata/version as the change warrants).

Tool cards specialize the universal practice; they never restate it — the
universal mechanism lives in the `implement` workflow reference.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
