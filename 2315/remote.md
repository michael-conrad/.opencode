---
remote_issue: 2315
remote_url: "https://github.com/michael-conrad/.opencode/issues/2315"
last_sync: 2026-09-24T05:30:02Z
source: github
---

> **Full spec and artifacts: [`.opencode/.issues/2315/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2315)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2315/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Problem

The opencode agent has no default Retrieval-Augmented Generation (RAG) service for querying the locally-maintained corpus of non-tracked, copyright-sensitive reference and research documentation. It relies on live web search for verification and cannot retrieve grounded content from that corpus without leaking source material into the tracked repository. This spec registers the RAGSync MCP server (`jsbroks/ragsync-mcp`) as a default local stdio MCP service with local embeddings, per-source isolation, auto-sync, and a bounded indexing corpus scope, replacing the retired srclight service. Additionally, the deck (the `.opencode/` submodule skill/guideline tree) still carries agent-facing instruction text referencing the retired service — a fresh exhaustive enumeration (2026-09-24) found 162 srclight matches across 46 deck files — which must be purged.

## Scope

- Register RAGSync as a default MCP service in `.opencode/opencode.jsonc` with `type: local`, `stdio` transport, and `enabled: true`, following the existing `uvx` runner pattern (SC-1).
- Configure local embeddings via `fastembed` with a pinned default local model and a documented offline/cache path — no external embedding API dependency (SC-2).
- Enforce per-source isolation with exactly one config section per reference source corpus designated in §3.1 of the spec (two live-verified corpora: `opencode-agent-config` over the main repo's tracked agent-facing text; `.opencode-deck` over the `.opencode/` submodule deck) and isolated index namespaces, plus a documented review checklist enforcing isolation (SC-3, SC-4).
- Enable auto-sync so the index updates on source file changes without manual re-indexing (SC-5).
- Bound the indexing corpus scope to all files in the main repo plus every git submodule in its registered submodule list; git sub-repos that are not registered submodules are not indexed unless a special carveout is declared in the RAGSync config (SC-7, CON-8).
- Document service configuration, per-source layout, usage, offline/cache path, and validation in the `.opencode` skill/guideline tree (SC-6).
- Purge the deck tree of srclight references per the §3.2 disposition rule (CON-10): genericize to capability-class wording (symbol/signature lookup, callers/callees/dependents blast-radius lookup, code search) where the capability mapping has value, remove outright where it does not (e.g., srclight CLI troubleshooting commands), with graceful-degradation unavailability fallbacks preserved and no replacement product-name hardwiring — verified structurally by a deck-wide zero-match sweep (SC-8) and behaviorally by an isolated opencode run showing srclight-free tool selection (SC-9).

**Out of scope:**

- Ingesting or tracking the actual copyright-sensitive reference material in the repository — the source corpus remains non-tracked (CON-2); the spec only configures retrieval over it.
- Building a bespoke/custom RAG implementation — RAGSync is adopted as-is (CON-1).
- Backfilling existing research cards or dictionaries into the RAG index (CON-3).
- Any changes to the root `snea-phonetics` repo's `.issues/` tree (CON-4), or modifying any existing MCP service (the-notebook-mcp, editor). The already-unregistered srclight service is not re-registered — RAGSync replaces its role (CON-9).
- Deleting the `.srclight/` working-tree cache directory — destructive file deletion, separately authorized; the §3.1 `.srclight/**` exclude glob already keeps it out of the RAG index.

## Approach

Adopt the RAGSync MCP server as-is and register it declaratively as a default local stdio MCP service in the `.opencode/opencode.jsonc` `mcp` block, mirroring the existing local-service registration pattern. RAGSync is configured via a single YAML config file whose `sources` list is the authoritative designation of the reference source corpora (spec §3.1): two folder-type sources with gitignore-style include/exclude globs restricted to agent-facing text, per-source vector-store collections as isolated namespaces, fastembed with a pinned default local model, and auto-sync per source. The corpus scope is bounded per CON-8 — main repo plus the registered `.opencode` submodule — with the `.issues/` orphan-branch worktrees and other non-registered git sub-repos excluded absent a declared carveout. In the deck tree, srclight references are purged per the §3.2 disposition rule: genericize capability-bearing references (no product-name hardwiring — name the capability, not the product), remove product-specific references (srclight CLI troubleshooting, retired-service tier-table entries, the `check_srclight()` session-init probe, `session-to-timeline` srclight normalizers, the README mcp-block srclight line). Verification is behavioral for the runtime-behavioral criteria: launching opencode to confirm the service spawns and lists its tools (SC-1), a network-monitored retrieval query through the fastembed local path (SC-2), a cross-source search asserting no leakage between corpus namespaces (SC-3), a source-file modification with index-freshness observation (SC-5), runtime enumeration of indexed sources asserting coverage and exclusion (SC-7), and an isolated opencode run showing the agent selecting available tooling or the built-in read/grep fallback with zero `srclight_*` tool-call attempts (SC-9). The isolation review checklist (SC-4), the service documentation (SC-6), and the deck-wide zero-match sweep (SC-8) are verified structurally with explicit topic-presence/sweep criteria.

## Impact

**Top 3 risks:**

1. Service fails to spawn or the RAGSync config drifts from its registration — mitigated by co-located, validated config (CON-5) and runtime service-spawn verification with tool listing (SC-1).
2. Cross-source retrieval leakage of copyrighted material between the §3.1-designated corpora — mitigated by per-source isolation with isolated namespaces (CON-6, SC-3) and the documented isolation review checklist (SC-4).
3. Indexing corpus scope silently wrong — non-registered git sub-repos enter retrieval, or intended main-repo/submodule coverage is missing — mitigated by the CON-8 corpus-scope rule verified via runtime source enumeration (SC-7). The deck purge (CON-10, SC-8/SC-9) removes a fourth risk class: stale srclight tool names remaining as live instructions that misroute agents toward a retired service.

**Key dependencies:** `jsbroks/ragsync-mcp` (external MCP server, must be available and version-stable); `fastembed` (local embedding runtime; first-run model download mitigated by the pinned model and documented offline/cache path, CON-7).

**Call to action:** Review the 2026-09-24 second-round revision — per developer directive the deck-wide srclight reference purge is now folded into this spec as first-class scope (CON-10, §3.2 footprint enumeration: 162 matches across 46 files; SC-8 structural sweep + SC-9 behavioral tool-selection run; R-13/R-14; Items 8-9), alongside the first-round srclight retirement (RAGSync replaces srclight's role per CON-9). This substantive SC-set change revokes the linked plan approvals per approval-gate-006 (recorded in the plan lifecycle events; plan regeneration is a downstream writing-plans dispatch). Full spec text and artifacts: https://github.com/michael-conrad/.opencode/tree/issues-data/2315/

---
🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
🤖 Co-authored with AI: OpenCode (ollama-cloud/glm-5.3-flash)
🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
