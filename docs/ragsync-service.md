# RAGSync MCP Service — Configuration and Usage

<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Default retrieval service for the agent's reference-corpus queries (spec CON-1 recorded in the `issues-data` store; adopted as `jsbroks/ragsync-mcp`).

## Service configuration

`ragsync` is registered in `.opencode/opencode.jsonc` `mcp` block: `type: "local"`, stdio transport through the hardened launch wrapper (`.opencode/tools/ragsync-launch.py -- uvx --with "mcp<2" ragsync --config <path>`, `.opencode#2624`), `enabled: true` (default-on; no per-session setup). The wrapper must be the MCP client's direct child — the PPID lineage is its only client-death signal — and is therefore stdlib-only under the host python; the `mcp<2` pin keeps the mcp Python SDK at the 1.x API the server is built against.

The service is configured by `.opencode/ragsync-config.yaml` (co-located with the registration per CON-5 — config edits and registration edits land in the same change; see the [isolation review checklist](reference/ragsync-isolation-checklist.md) before touching either). The wrapper's hardening defaults are co-located but **separate**: `.opencode/ragsync-hardening.yaml` — NOT inside `ragsync-config.yaml`, which upstream ragsync validates with pydantic `extra="forbid"` (any added key crashes the server at startup).

## Hardened launch path (`.opencode#2624`)

The wrapper supervises the server tree and enforces the hardening contract:

- **Client death → tree reap (SC-1/R-1).** A PPID-poll loop detects the client's death and terminates the whole tree; the supervised child additionally sets PR_SET_PDEATHSIG, so a wrapper death kills the server directly. No dependence on stdout activity or EPIPE.
- **Busy/idle arms (SC-6/R-6).** At client death the tree is classified by sampled CPU rate (movement above ~20% of one core = busy): a busy clientless tree — the incident's expensive shape — is terminated immediately; an idle one self-terminates at `idle_timeout_seconds` of clientlessness, hard-bounded by `reap_deadline_seconds` (reap boundary = clientless moment + `min(reap_deadline, idle_timeout)`). A client-attached tree is never reaped by this arm (SC-7).
- **Memory ceiling (SC-2/R-2).** `memory_ceiling_bytes` bounds memory demand two ways: a kernel RLIMIT_AS on the launched child (per-process, inherited by every descendant — no tree process can allocate beyond the ceiling) plus a sampled-demand kill that terminates the whole tree when its summed RSS exceeds the ceiling (the observable enforcement path; the sampled sum is the tree-level bound).
- **Thread cap (SC-3/R-3).** `thread_cap` is enforced by the per-tick `/proc` sampler: a breach terminates the tree (no kernel rlimit bounds a tree's threads; one enforcement-cadence overshoot is inherent).
- **Host-memory admission (SC-4/R-4).** `MemAvailable` below `admission_min_free_bytes` refuses the launch before any child spawn: non-zero exit + structured stderr line, live re-read per launch (never latched).
- **Same-host heavyweight slot (SC-5/R-5).** One `flock` slot per host user (`$XDG_RUNTIME_DIR`, per-user 0700 `/tmp` fallback) is held from spawn until the tree settles (summed RSS growth < 5% across a 60 s window) or exits, hard-bounded by `heavy_window_seconds`; waiters exceeding `lock_wait_seconds` decline honestly (exit 6) rather than wedging the client's connect window. Hold windows are journaled (`ragsync-heavyweight.journal`) with a stale-holder record rule.

All defaults with inline rationale: `reap_deadline_seconds: 30` (inside the documented 30 s connect window), `memory_ceiling_bytes: 16 GiB` (~5× the warm embedding baseline, 2.4× below the incident peak), `thread_cap: 128` (~1.6× measured full-tree demand, below the incident's 151 threads), `admission_min_free_bytes: 20 GiB` (above the ceiling itself), `idle_timeout_seconds: 900` (defaults keep the watchdog dominant, per spec §5(d)), `idle_poll_seconds: 60`, `heavy_window_seconds: 1800`, `lock_wait_seconds: 25`, `lock_name: "ragsync-heavyweight.lock"`, `runtime_dir: ""`.

The refusal and decline states are the honest best-effort continuation (CON-7): a refused or declined launch is a non-zero process exit with a structured stderr line — the session continues without RAG.

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
