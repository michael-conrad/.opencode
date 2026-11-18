<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2748 -->

# .opencode — the OpenCode agent deck

An agent instruction deck for [OpenCode](https://opencode.ai): a minimal
always-injected instruction floor plus self-contained, on-demand skill
cards, guidelines, agent cards, tools, and hooks. It is consumed as a git
submodule mounted at `.opencode/`.

## Install

```bash
git submodule add git@github.com:michael-conrad/.opencode.git .opencode
```

The submodule tracks the `main` branch — the single trunk. Keep the
checkout on a tracked branch, never detached HEAD, so `git pull` receives
updates.

## Architecture — floor plus on-demand cards

`floor.md` is the **entire always-injected instruction surface**: identity,
the authorization vocabulary (a closed token set), default read-only
scope, dispatch scope-bounding, the spec → plan → implement → PR
pipeline, deck governance, and the safety irreducibles. `opencode.jsonc`
loads exactly one instruction: the floor.

Everything else loads on demand — the agent matches its current intent
against the available card descriptions and loads only what matches.

| Directory | Contents |
|---|---|
| `skills/` | Skill cards (one `SKILL.md` each, YAML frontmatter: name, description, license, provenance) — the work lifecycle (`work`, `spec`, `plan`, `implement`, `verify`, `issues`, `correspondence`), the git-workflow family, release cards, platform CLI cards (`gh-cli`, `gb-cli`, `wiki-operations`), language/build cards, testing and research cards, ops cards, and the deck's own governance card (`skill-creator`). The inventory is the directory itself — the platform surfaces each card's description. |
| `guidelines/` | Routed guidelines, loaded when the floor's trigger routes to them: `ainglish-writing-discipline.md` (authoring normative prose) and `deprecation-encounter-protocol.md` (deprecation encounters and `[BITROT]` tickets). |
| `agents/` | Agent cards: `email-ops`, `math-ops`, `notebook-ops`, `visual-design-agent`. |
| `tools/` | Deck tooling — see below. |
| `hooks/` | The trunk-protection hook pair (`pre-commit`, `pre-push`) — the one surviving hook family, installed by `session-init` into each repo's git dir. |
| `plugins/` | OpenCode V2 plugins — see below. |
| `prompts/` | The `build` and `plan` agents' system prompt. |
| `tests/` | pytest suite for the `local-issues` and `session-init` tools. |
| `tests-v2/` | The behavioral test harness — see Testing. |
| `docs/` | Supporting documentation (dispatch-audit schema, model dependency, ragsync service, secret detection). |
| `attic/` | The pre-replacement deck, preserved unloaded (tag `pre-rip`) pending soak and deletion. |
| `.issues/` | This repo's own issue store — see Issue stores. |

## Configuration (`opencode.jsonc`)

- **instructions**: `floor.md` only.
- **agents**: `build` and `plan`, both using `prompts/default.txt` as
  their system prompt. No model or provider is pinned anywhere in the
  deck — the invoking session supplies the provider and model.
- **MCP servers** (all local): `the-notebook-mcp` (Jupyter),
  `editor` (viewport-editor), `ragsync` (retrieval over
  `ragsync-config.yaml` — the deck's and the parent repo's agent-facing
  text, chroma-backed), and `ollama-web-search`.
- **permissions**: `gmail_*`, `math_*`, and `the-notebook-mcp_*` are
  **denied** in the main session. Those capabilities route exclusively
  through the `email-ops`, `math-ops`, and `notebook-ops` agent cards,
  which hold the tool permissions — dispatch-bound authorization made
  structural in the config.

## Plugins (V2)

Local plugins are **auto-discovered** from `.opencode/plugins/*.ts`. The
`plugins` array in `opencode.jsonc` configures *additional* paths — an
empty array is not a disable. The V2 plugin contract (and how to verify a
plugin loads) is documented in `plugins/AGENTS.md`.

- **env-loader** — reads the project's `.env` and injects all its
  key-value pairs into every shell session (the shell `create.before`
  hook). It is the sole provider of bash environment variables.
- **session-enforcement** — runs `tools/session-init` and injects its
  output (owner, repo, platform, credential status, hook inventory, the
  repo routing table) into the model context per model request (the
  session `context` hook).

## Tools (`tools/`)

| Tool | Purpose |
|---|---|
| `session-init` | Session context emitter — the canonical source for per-root identity data (owner, repo, platform, issue-store paths, the repo routing table). |
| `local-issues` | Local issue-store CLI for `.issues/` stores — qualified `repo#N` names, sync/mirror mechanics, comments, links. |
| `skildeck` | Deck lint (`lint`) and acceptance-criteria verification (`verify-acceptance`, `verify-issue`). |
| `formal` | Vendored formal tooling: the z3 binary (SMT-LIB2) and unified-planning's `up` CLI. |
| `reference-integrity` | Read-link validation for agent-facing markdown — run before committing agent-facing markdown edits. |
| `jupyter`, `jupyter-start`, `jupyter-stop` | Jupyter server management. |
| `ollama-probe` | Probe the local Ollama server. |
| `schema-version` | Current UTC timestamp emitter. |
| `session-to-timeline` | `session.yaml` → condensed tool-call timeline for behavioral evaluation. |
| `detect-secrets-wrapper.sh` | Opt-in `detect-secrets` pre-commit wrapper (semaphore: runs only when `.secrets.baseline` exists in the repo root). |
| `web-search-mcp.py` | The `ollama-web-search` MCP server script. |
| `ensure-node`, `file-exists`, `py`, `help` | Node toolchain bootstrap, path existence checks, Python tools dispatcher, tool listing. |

Vendored, gitignored runtimes live under `.node/`, `.tools/` (z3, uv, the
opencode standalone binary), and `.venv/`, provisioned per tool runbooks.

## Testing

- **`tests-v2/` — behavioral harness** (spec: `tests-v2/AGENTS.md`):
  artifact-only generators — scenario scripts run the model, collect
  artifacts, and exit 0; evaluation is the orchestrator's job, never the
  script's. `with-test-home` provides full isolation (`env -i` with an
  explicit allowlist); tier-2 scenarios run in a Docker container with
  only `tmp/` mounted; remote-API scenarios get a self-contained
  GitBucket container. The default test model is defined solely by
  `DEFAULT_TEST_MODEL` in `tests-v2/default-model.sh` — that file is the
  single source of truth.
- **`tests/` — pytest suite**: unit tests for `local-issues` and
  `session-init` (`uv run pytest`).
- **`skildeck lint`**: the deck's consistency gate — expected to report
  zero findings.
- **`reference-integrity`**: Read-link validation for agent-facing
  markdown (harness spec §6c).

## Governance

- Every card carries SPDX headers and a provenance line citing the
  upstream issue(s) that landed it — the deck is audit-traceable rule by
  rule.
- Deck changes are authored upstream (this repository) through the
  pipeline — spec, plan, implementation, PR — with a human-only merge
  boundary. Consuming checkouts are read-only: they receive deck updates
  by pulling upstream, and agents never patch local `.opencode/` copies
  to escape a mis-scoped mandate.
- New cards, card edits, and card retirement go through the
  `skill-creator` card (admission gate, retirement gate, vendor-card
  boundary).
- `CHANGELOG.md` (Keep a Changelog) documents notable deck changes; the
  `[Unreleased]` section carries pending work.
- Secret handling: `vibeguard.config.json` (pattern masking with
  placeholder sessions), the opt-in detect-secrets wrapper, and
  credential-file gitignore coverage verified by `session-init`'s
  credential guard.

## Issue stores

Issue artifacts live in a `.issues/` orphan-branch worktree (the
`issues-data` branch) — gitignored in its parent repo, never a submodule,
and managed through `tools/local-issues` (never by hand). This repo's own
store sits at `.issues/`; consuming repos get their own store at their
root.

## Submodule tracking

`main` is the single trunk — the historical `dev` branch was removed.

```bash
git -C .opencode branch --show-current   # main
```

Pointer updates in consuming repos ride with real consuming-repo changes
in the same commit — never pointer-only commits.

## License

MIT
