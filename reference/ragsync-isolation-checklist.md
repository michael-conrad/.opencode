# Review Checklist — Per-Source Isolation (RAGSync)

<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

> Enforces spec `.opencode/.issues/2315/spec.md` CON-6 / R-11 / SC-3 / SC-4.
> Scope: any change to `.opencode/ragsync-config.yaml` or the `ragsync` MCP registration.

## Checklist

1. **One config section per §3.1-designated source.** The `sources:` list must contain exactly one section per corpus designated in spec §3.1 — currently `opencode-agent-config` and `.opencode-deck`. A source section outside the §3.1 designation (or a §3.1 corpus missing from the list) is a defect. New corpora within the CON-8 surface (main repo + registered submodules) are added by adding a source section — never by broadening an existing section's `path`.

2. **Isolated index namespaces.** Every source section must declare its own `vector_store.collection` value; no two sources may share a collection. Verify against the live index: `select name from collections` in `.opencode/vector_db/chroma.sqlite3` must show one collection per source.

3. **Empty-source handling.** A declared source whose directory yields no matching files must produce an empty index for that source without failing other sources (RAGSync behavior: source init errors are non-fatal per-source). Review must confirm each declared source currently yields ≥1 indexed document — an unexpectedly-zero count means the `path` or globs are misconfigured.

4. **Exclusion globs intact (CON-8 boundary).** Both sources must keep their §3.1 exclude globs — particularly `.issues/**` (the orphan-branch worktrees are non-registered git sub-repos and MUST NOT be indexed), `.opencode/**` (nested), `tests-v2/**`, and lock files. Removing an exclude glob silently widens the retrieval surface.

5. **Path-resolution arithmetic.** RAGSync resolves relative `connection.path` against the config file's directory (`.opencode/`). After any path edit, re-verify resolved paths via `AppConfig.from_yaml(...)` — the 2026-09-30 regression (source path `../..` resolving to `/home/muksihs/git`, indexing 31 foreign repos) came from exactly this arithmetic.

6. **Registration ↔ config co-location (CON-5).** The `ragsync` entry in `.opencode/opencode.jsonc` must point `--config` at this config file. Config edits and registration edits land in the same change; neither drifts alone.

## Known constraint (not a defect)

opencode 1.18.3 enforces a 30-second MCP connect window; the local embedding model's first-load takes ~75s CPU on cold start. A cold session may report ragsync unavailable — an environmental condition, not a config defect. Recorded on `.opencode#2315` (2026-10-01).

🤖 Co-authored with AI: OpenCode (ollama-cloud/glm-5.3-flash)
