---
number: 1253
title: "[SPEC-FIX] Pin requires-python and all dependencies in every PEP 723 script"
id: FIX
type: spec-fix
created: 2026-06-16
author: Michael Conrad
related:
  - michael-conrad/.opencode#1252
---

## Intent

Every PEP 723 script in the live deck runs under a fully pinned, self-contained
environment: a three-part compatible-release `requires-python` pin resolved
through uv's managed python toolchain — never the project's python and never an
ambient system interpreter — and every dependency entry pinned with the `~=`
compatible-release operator so remote package updates cannot introduce an
untested major version into a script's environment between runs.

## Problem

The deck's PEP 723 scripts do not pin their runtime environments:

1. **Python pin too broad (observed failure recorded in this issue's own
   filing, 2026-06-16).** Two-part tilde
   `requires-python = "~=3.12"` is PEP 440 for `>=3.12, <4` — any 3.x
   interpreter satisfies it. uv then resolved a 3.13+ interpreter whose
   environment lacked the script's dependencies, failing with
   `ModuleNotFoundError`. uv itself flagged the ambiguity at the time:
   `Did you mean ~=3.12.0 to constrain the version as >=3.12.0, <3.13?`
   The failure was recorded while invoking the tool script under
   `uv run --script` with the arguments `import-remote 1252`; the filing's
   command line names an `import-remote` argument that is not — and never
   was — a `local-issues` subcommand (verified against the tool's current
   subcommand set and full git history). The recorded symptoms are
   import-time: with `~=3.12`, uv built the script environment on a 3.13+
   interpreter where the script's top-level imports failed before argument
   dispatch — surfacing first the header warning and then
   `ModuleNotFoundError: No module named 'yaml'`.
2. **Interpreter isolation is not enforced (live-verified 2026-10-16, uv
   0.11.19).** With a correctly pinned `~=3.12.0` header, plain
   `uv run --script` still resolved the system interpreter (`/usr/bin/python3.12`,
   3.12.3) on first resolution of a fresh script — only `--python-preference
   only-managed` forced uv's managed cpython (3.12.13). The project `.venv`
   also exists at `.opencode/.venv`, so ambient-project contamination is a
   live risk on the other side too. A header pin alone therefore does not
   satisfy "neither the project's python nor the system python"; the
   enforcement must live in the invocation. Invocation forms in the live tree
   vary — direct shebang exec, `bash <tool>` via the polyglot guard, and
   plain `uv run <tool>` (the tests-v2 harness calls `tools/session-to-timeline`
   this way at `tests-v2/behaviors/helpers.sh:2079`, live-verified today to
   resolve the system interpreter when the shebang carries no flags) — and
   plain `uv run` on a polyglot execs the file, so the kernel honors the
   shebang: flags carried in the shebang line make even that form resolve the
   managed interpreter (live-verified).
3. **Dependency specs permit remote breakage.** Bare package names and `>=`
   specs admit any future version, including untested majors: a remote package
   update can break a script overnight between two runs of the same unchanged
   file. Live violations today:
   - `tools/skildeck`, `tools/impl/skildeck/skildeck-lint`,
     `tools/impl/skildeck/skildeck-verify-issue`,
     `tools/impl/skildeck/skildeck-verify-acceptance`: `pyyaml>=6.0`
   - `tools/formal`: `pyyaml>=6.0`, `unified-planning>=1.3.0`, `up-tamer>=1.1.0`
   - `tools/web-search-mcp.py`: bare `rich`, bare `ollama` (its
     `requires-python` and `mcp~=1.0` are already conforming)
4. **The project manifest shares the defect.** `.opencode/pyproject.toml`
   declares the same two-part tilde (`requires-python = "~=3.12"`), so the
   project's own environment — the "project's python" that the isolation
   mandate excludes — remains resolvable to 3.13+ interpreters. The
   manifest's range is the machine-readable definition of the deck's python;
   leaving it unbounded keeps available the very interpreter class that
   produced the recorded failure.

Current state of the 22 live PEP 723 scripts (verified 2026-10-16 by marker
scan over the tree excluding `attic/`): 19 still declare `~=3.12`; 1 declares
bare `>=3.12` (`tools/formal`); 2 declare `~=3.12.0` (`tools/local-issues`,
`tools/web-search-mcp.py`) but one of those two (`web-search-mcp.py`) still
violates the dependency rule. No script in the live deck enforces
managed-python resolution in its shebang or bash guard.

## Root Cause

1. Two-part tilde ambiguity: PEP 440 `~=X.Y` spans all minor-and-patch
   releases to the next major (`~=3.12` → `>=3.12, <4`), so interpreter
   selection is unbounded within a major.
2. Dependency specs written as bare names or `>=` place no ceiling on remote
   upgrades; uv re-resolves dependencies whenever it builds the script's
   environment, so an unpinned spec re-exposes the script to every future
   upstream release.
3. Interpreter selection is a property of the invocation, not the header: uv
   satisfies a pinned `requires-python` from whatever matching interpreter it
   finds first (managed or system), so isolation is only guaranteed when the
   invocation constrains the search.
4. The pinning norm's former home (the environment guideline) was moved to
   `attic/` in the deck revision, leaving the live deck with no statement of
   the rule and the scripts unconverted.
5. The project manifest carries the same two-part tilde, so project-mode
   `uv sync`/`uv run` can provision `.opencode/.venv` on an untested
   interpreter; that environment is exactly the "project's python" the
   isolation requirement excludes, so the manifest and the scripts must pin
   consistently for the exclusion to hold.

## Scope

### In Scope

- All 22 PEP 723 scripts in the live deck (`.opencode/` excluding `attic/`) —
  full inventory with current state under Affected Files.
- `.opencode/opencode.jsonc` — the `ollama-web-search` MCP command that
  launches `tools/web-search-mcp.py` via plain `uv run` (no `--script`, no
  interpreter enforcement).
- `.opencode/pyproject.toml` `requires-python` and its derived `uv.lock` —
  same two-part tilde defect in the project manifest.

### Out of Scope

- `attic/` contents — pre-revision deck preserved pending deletion; not live.
- `tests-v2/behaviors/fixtures/**` heredoc `pyproject.toml` payloads — scratch
  project manifests for behavioral fixtures, not PEP 723 scripts.
- `uvx`-based MCP entries in `opencode.jsonc` (`the-notebook-mcp`,
  `viewport-editor`, `ragsync`) — not PEP 723 scripts.
- Parent repository (`opencode-config`) — verified to contain no PEP 723
  scripts and no `opencode.json`.
- Dependency pins in `pyproject.toml` dependency groups and `uvx` entries —
  not PEP 723 script dependencies.
- Re-homing the pinning norm into a live deck card or guideline — deck
  governance, owned by the deck-governance card in its own pipeline.

## Requirements

- **R-1.** Every PEP 723 script in the live deck SHALL declare
  `requires-python = "~=3.12.0"` (three-part compatible release). Two-part
  tilde (`~=3.12`), bare `>=X.Y`, and bare version forms are prohibited.
- **R-2.** Every dependency entry in every PEP 723 script SHALL use the `~=`
  compatible-release operator. Bare package names, `>=`, and `==` specs are
  prohibited. Each converted pin SHALL preserve the floor version already
  recorded in the header (`pyyaml>=6.0` → `pyyaml~=6.0`,
  `unified-planning>=1.3.0` → `unified-planning~=1.3`,
  `up-tamer>=1.1.0` → `up-tamer~=1.1`); a dependency with no recorded floor
  (`rich`, `ollama`) SHALL be pinned with the `~=` compatible-release
  operator at the current stable version verified against the live PyPI
  registry at implementation time (the pin names the stable release's
  major.minor, e.g. stable 14.2.1 → `~=14.2`), never from recall.
- **R-3.** Executing a PEP 723 script SHALL resolve its interpreter through
  uv's managed python toolchain satisfying the script's pin: the project's
  python (`.venv` or any project environment) and ambient system interpreters
  SHALL NOT participate in the script's runtime. Every PEP 723 script that
  carries a shebang or a polyglot bash guard SHALL enforce this on both
  invocation paths — the shebang line and the guard line SHALL both carry
  `--python-preference only-managed`. An extensionless bash caller that
  invokes the python script with equivalent uv flags is an approved
  equivalent structure (developer-authorized latitude); the one live-deck
  script invoked only through configuration (`tools/web-search-mcp.py`, no
  shebang, no guard) is covered by R-4.
- **R-4.** The `ollama-web-search` MCP command in `.opencode/opencode.jsonc`
  SHALL carry the same enforcement — `uv run --script
  --python-preference only-managed .opencode/tools/web-search-mcp.py` — since
  that file has no bash guard of its own and is invoked only through the
  config.
- **R-5.** `.opencode/pyproject.toml` SHALL declare
  `requires-python = "~=3.12.0"`, and `uv.lock` SHALL be regenerated so its
  recorded resolution range matches the tightened manifest.

## Approach

Per-file transform, no restructuring required:

1. In each of the 19 scripts carrying `~=3.12`: change the header to
   `requires-python = "~=3.12.0"`. In `tools/formal`: additionally convert the
   three `>=` dependency specs per R-2.
2. In the four scripts carrying `pyyaml>=6.0` and in `tools/formal`: convert
   each dependency entry to `~=` with the floor preserved.
3. In `tools/web-search-mcp.py`: pin `rich` and `ollama` at the live-registry
   verified current stable (PyPI `https://pypi.org/pypi/<package>/json`);
   `mcp~=1.0` stays.
4. In every script carrying a shebang and bash guard: append
   `--python-preference only-managed` to both lines. Guard-line quoting keeps
   each flag as its own quoted token
   (`"exec" "uv" "run" "--script" "--python-preference" "only-managed" "$0" "$@"`).
   Both forms were live-verified to resolve managed cpython 3.12.13 on this
   machine. `tools/web-search-mcp.py` gets its enforcement through R-4's
   config command instead.
5. Edit `.opencode/pyproject.toml`, then `uv lock` to regenerate `uv.lock`.
6. `tools/local-issues` is already conforming in header and deps; it changes
   only in its shebang and guard lines.

Alternative mechanisms weighed:

- **Header pin alone** — rejected on live evidence: first resolution of a
  fresh script picked the system interpreter.
- **Explicit `--python 3.12` flag** — workable but duplicates the version
  literal outside the header; the header stays the single version source of
  truth and `--python-preference only-managed` composes with it.
- **Extensionless bash caller wrapping every python script** — permitted by
  the developer as an equivalent structure, but heavier than flag
  augmentation; not required where the standard structure already expresses
  the requirement.

## Affected Files

Live-tree inventory, verified 2026-10-16 (marker scan `^# /// script`,
excluding `attic/`). "RP" = current `requires-python`; "Deps" = current
dependency entries.

| # | File | RP | Deps |
|---|------|----|------|
| 1 | `tools/formal` | `>=3.12` | `pyyaml>=6.0`, `unified-planning>=1.3.0`, `up-tamer>=1.1.0` |
| 2 | `tools/py` | `~=3.12` | — |
| 3 | `tools/reference-integrity` | `~=3.12` | — |
| 4 | `tools/jupyter-stop` | `~=3.12` | — |
| 5 | `tools/file-exists` | `~=3.12` | — |
| 6 | `tools/skildeck` | `~=3.12` | `pyyaml>=6.0` |
| 7 | `tools/impl/jupyter-stop` | `~=3.12` | — |
| 8 | `tools/impl/py-mkpkg` | `~=3.12` | — |
| 9 | `tools/impl/skildeck/skildeck-lint` | `~=3.12` | `pyyaml>=6.0` |
| 10 | `tools/impl/skildeck/skildeck-verify-issue` | `~=3.12` | `pyyaml>=6.0` |
| 11 | `tools/impl/skildeck/skildeck-verify-acceptance` | `~=3.12` | `pyyaml>=6.0` |
| 12 | `tools/impl/py-ls` | `~=3.12` | — |
| 13 | `tools/jupyter` | `~=3.12` | — |
| 14 | `tools/impl/jupyter-start` | `~=3.12` | — |
| 15 | `tools/session-to-timeline` | `~=3.12` | — |
| 16 | `tools/help` | `~=3.12` | — |
| 17 | `tools/schema-version` | `~=3.12` | — |
| 18 | `tools/session-init` | `~=3.12` | — |
| 19 | `tools/jupyter-start` | `~=3.12` | — |
| 20 | `scripts/session_context_triggers.py` | `~=3.12` | — |
| 21 | `tools/local-issues` | `~=3.12.0` | `pyyaml~=6.0` |
| 22 | `tools/web-search-mcp.py` | `~=3.12.0` | `mcp~=1.0`, `rich` (bare), `ollama` (bare) |

Plus:

- `.opencode/opencode.jsonc` — line 45, `ollama-web-search` command.
- `.opencode/pyproject.toml` — line 5, `requires-python = "~=3.12"`.
- `.opencode/uv.lock` — derived; regenerate.

## Success Criteria

| ID | Criterion | Class | Instrument |
|----|-----------|-------|------------|
| SC-1 | The set of PEP 723 scripts in the live deck (marker scan of `.opencode/` excluding `attic/`) equals the 22-file inventory above — no unlisted PEP 723 script exists and none of the listed files was dropped from the deck | structural | marker scan; file list diff against the inventory table |
| SC-2 | Every script in the inventory declares `requires-python = "~=3.12.0"` | structural | grep `requires-python` across the 22 files; zero nonconforming headers |
| SC-3 | Every non-empty `dependencies` entry across the 22 files uses `~=`; no bare package names, no `>=`, no `==` | structural | grep dependency lines; zero nonconforming entries |
| SC-4 | Converted pins preserve recorded floors (`pyyaml~=6.0` ×5, `unified-planning~=1.3`, `up-tamer~=1.1`, `mcp~=1.0`), and `rich`/`ollama` are pinned at versions whose PyPI registry query is recorded in the implementation evidence | structural | grep pin values; registry query output in evidence |
| SC-5 | Every script with a shebang and bash guard carries `--python-preference only-managed` on both lines | structural | grep shebang line 1 and guard line per file; zero missing |
| SC-6 | The `ollama-web-search` command in `.opencode/opencode.jsonc` is `["uv", "run", "--script", "--python-preference", "only-managed", ".opencode/tools/web-search-mcp.py"]` | structural | grep the config entry |
| SC-7 | `.opencode/pyproject.toml` declares `requires-python = "~=3.12.0"` and `uv.lock` is consistent with the tightened manifest | structural | grep pyproject; `uv lock --check` exits 0 |
| SC-8 | Behavioral, direct-exec path: a probe script carrying the deck-standard header, executed via its shebang with a foreign `VIRTUAL_ENV` active and cwd inside `.opencode` (project `.venv` present), reports python 3.12.x and `sys.base_prefix` under uv's managed python directory — never `/usr`, never a project or foreign venv | behavioral | run probe; capture version + `base_prefix` |
| SC-9 | Behavioral, bash-guard path: the same probe executed via `bash <script>` reports the same managed interpreter identity | behavioral | run probe via bash; capture version + `base_prefix` |
| SC-10 | Behavioral, tools run clean: `./.opencode/tools/local-issues --help` and `./.opencode/tools/py --description` exit 0 with no `ModuleNotFoundError` and no uv resolution warnings, with a foreign `VIRTUAL_ENV` active | behavioral | run both; capture exit codes and output |
| SC-11 | Behavioral, harness-style plain invocation: `uv run <probe>` (no `--script`, no caller flags — the `tests-v2/behaviors/helpers.sh:2079` form) on a probe carrying the deck-standard flagged shebang and guard, with a foreign `VIRTUAL_ENV` active, reports python 3.12.x and `sys.base_prefix` under uv's managed python directory | behavioral | run `uv run` on the probe; capture version + `base_prefix` |
| SC-12 | No live-tree call site invokes a PEP 723 tool with caller-supplied `uv run --script` lacking `--python-preference only-managed` (caller-supplied `--script` bypasses the shebang; the live tree today contains none — the criterion preserves that state) | structural | grep the live tree (excluding `attic/`) for `uv run --script` invocations of `tools/` or `scripts/` paths; zero unflagged hits |
| SC-13 | Behavioral, new pins viable: the registry-verified `rich` and `ollama` pins resolve together and both packages import under the pinned specifiers | behavioral | `uv run --no-project --with 'rich~=<verified>' --with 'ollama~=<verified>' python -c "import rich, ollama"` exits 0 |
| SC-14 | Behavioral, config path end-to-end: in the `811-sc5-ollama-web-search-invocation` scenario artifacts, the ollama-web-search MCP server launches and serves `web_search`/`web_fetch` calls under the modified flagged config command | behavioral | run the `811-sc5-ollama-web-search-invocation` scenario through the tests-v2 behavioral harness to generate session artifacts (the run's exit code signals artifact generation, not a verdict), then clean-room sub-agent evaluation of the session's `session.yaml` tool evidence confirms the MCP launch and tool calls under the flagged command; the criterion's outcome is the evaluation verdict, never the generator run's exit code |

## Evidence Recorded During Revision

All current-state claims above were verified live on 2026-10-16 (uv 0.11.19):

- PEP 440 bounds via `packaging.SpecifierSet`: `~=3.12` → `>=3.12, <4`;
  `~=3.12.0` → `>=3.12.0, <3.13`; `~=6.0` → `>=6.0, <7.0`; `~=1.3` →
  `>=1.3, <2.0`.
- Plain `uv run --script` on a fresh `~=3.12.0` probe resolved the system
  interpreter (`/usr/bin/python3.12`, 3.12.3, base prefix `/usr`);
  `--python-preference only-managed` resolved managed cpython 3.12.13
  (base prefix under `~/.local/share/uv/python/`).
- Shebang form `#!/usr/bin/env -S uv run --script --python-preference
  only-managed` and guard form
  `"exec" "uv" "run" "--script" "--python-preference" "only-managed" "$0" "$@"`
  both executed correctly (direct and `bash` invocation paths).
- Pin conversion is resolution-neutral today: `pyyaml~=6.0` → 6.0.3,
  `unified-planning~=1.3` → 1.3.0, `up-tamer~=1.1` and `mcp~=1.0` resolve
  under the tightened specifiers (preserved-floor conversions only;
  `rich`/`ollama` are new constraints — verified at implementation per SC-13).
- `.opencode/.venv` exists (project environment present); `.opencode/hooks/`
  contains no references to `uv` or `tools/`.
- No deprecated `# /// pyproject.toml` markers exist in the live deck.

## Impact

- **Consumers:** `tools/session-init` runs at every session start and must
  keep working (SC-10 class); the `formal-tooling` card documents invoking
  `tools/formal`, and the `tests-v2` harness scripts
  (`tests-v2/test-enforcement.sh`, `tests-v2/test-skill-deck-completeness.sh`,
  behavior fixtures) invoke `tools/skildeck` and its impl scripts — CLI
  arguments are unchanged; `tests-v2/behaviors/helpers.sh:2079` launches
  `tools/session-to-timeline` via plain `uv run`, which resolves through the
  script's own flagged shebang after the change (SC-11) — no harness edit
  required; the `ollama-web-search` MCP server launches through the config
  command (SC-6), and the existing Tier-2 behavioral fixture
  `tests-v2/behaviors/811-sc5-ollama-web-search-invocation.sh` exercises that
  entry from the pushed config in a real session — it is the end-to-end
  instrument for the changed launch path (SC-14); `.opencode/hooks/`
  references no tools (verified).
- **First-run cost:** on a machine with no managed 3.12 installed, the first
  script execution downloads uv's managed cpython once (observed: seconds);
  subsequent runs reuse it.
- **Resolution stability:** preserved-floor conversions do not change today's
  resolution (verified above); the change removes only future-major exposure.
  The two new pins (`rich`, `ollama`) are new constraints, not conversions —
  their resolution and importability are verified at implementation (SC-13).
- **Vendored file:** `tools/web-search-mcp.py` is vendored
  (provenance header in file); only its dependency pins change — body untouched.

*Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)*
