# RAGSync MCP Service — Configuration and Usage

<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Default retrieval service for the agent's reference-corpus queries (spec CON-1 recorded in the `issues-data` store; adopted as `jsbroks/ragsync-mcp`).

## Service configuration

`ragsync` is registered in `.opencode/opencode.jsonc` `mcp` block: `type: "local"`, stdio transport via the uvx runner pattern (`uvx --with "mcp<2" ragsync --config <path>`), `enabled: true` (default-on; no per-session setup). The `mcp<2` pin keeps the mcp Python SDK at the 1.x API the server is built against.

The service is configured by `.opencode/ragsync-config.yaml` (co-located with the registration per CON-5 — config edits and registration edits land in the same change; see the [isolation review checklist](reference/ragsync-isolation-checklist.md) before touching either).

## Per-source layout (spec §3.1)

Exactly one config section per designated corpus; the config's `sources:` list is the sole designation authority (no separate manifest, no implicit walk):

| Source | Path (resolved against config dir) | Collection | Content |
|--------|-----------------------------------|------------|---------|
| `opencode-agent-config` | `..` (main repo working tree) | `opencode_agent_config` | Tracked agent-facing text: `AGENTS.md`, `README.md`, `CHANGELOG.md`, `docs/`, `skills/` |
| `.opencode-deck` | `.` (this submodule) | `opencode_deck` | Tracked deck text: `AGENTS.md`, `README.md`, `guidelines/`, `skills/`, `reference/`, `docs/` |

Include policy is agent-facing text only (`*.md`, `*.txt`, `*.tex`); exclude globs (per §3.1, binding) remove git internals, the `.issues/` orphan-branch worktrees (non-registered sub-repos, CON-8), tool/cache artifacts, lock files, and any stale local-indexer cache directories left by retired prior tooling. The index corpus is bounded to the main repo plus registered submodules (`.gitmodules` registers exactly `.opencode`).

**Isolation boundary:** each source has its own `vector_store.collection` namespace — retrieval results never cross corpora (CON-6). Cross-source leakage is a review-checklist defect, caught by [reference/ragsync-isolation-checklist.md](reference/ragsync-isolation-checklist.md).

## Usage

Five stable tools: `search` (semantic search across one or all sources, `[0,1]` scores), `list_sources`, `get_document`, `get_index_status`, `reindex`. Scope searches with the `source` parameter to keep results inside one corpus. Errors return structured `{"error": ...}` objects — recoverable conversationally.

## Local model-cache behavior (caching is NOT pinning)

Embeddings run locally via fastembed with the default model pinned **by name only** — `Qwen/Qwen3-Embedding-0.6B-Q` (fastembed quantized variant, served from `Qdrant/Qwen3-Embedding-0.6B-onnx`). Nothing beyond the name is pinned: no HF revision, no checksums. The ~1.12 GB int8 weights are downloaded from the HF Hub on first run into the embedding stack's standard on-disk cache and are **not refetched on every service start** — the local runtime cache is standard download-cache behavior, kept deliberately (this is not the dropped offline/cache-path contingency machinery). Weights are never committed to the repo.

If the model is not retrievable, the RAG service **hard-fails** — no fallback model, no silent degradation — and the session continues best-effort without RAG capability, with the failure surfaced honestly (CON-7). On machines where VRAM is available the same wheels can use the CUDA execution provider; when it is not, the CPU provider runs (silent fallback by design).

## Validation step

After any config or registration change:

1. Parse check: `.opencode/opencode.jsonc` valid JSONC; `ragsync-config.yaml` passes RAGSync's schema (`AppConfig.from_yaml`).
2. Scope check: resolver output shows exactly the §3.1 sources with expected absolute paths and per-source collections.
3. Runtime check: service start reports `ready: 2 source(s) configured`; `list_sources` shows both sources with distinct collections and non-zero document counts.
4. Isolation check: run the checklist in [reference/ragsync-isolation-checklist.md](reference/ragsync-isolation-checklist.md).

## Known constraint

opencode 1.18.3 enforces a 30-second MCP connect window; first-run model download plus cold load can exceed it. A session that loses that race reports ragsync unavailable — the session continues best-effort without RAG (CON-7 semantics), and the next warm start connects. Recorded on `.opencode#2315` (2026-10-01).

🤖 Co-authored with AI: OpenCode (ollama-cloud/glm-5.3-flash)
