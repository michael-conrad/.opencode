---
remote_issue: 2315
remote_url: "https://github.com/michael-conrad/.opencode/issues/2315"
last_sync: 2026-08-23T21:00:00Z
source: github
---

# Spec: Add RAGSync MCP as default MCP service for opencode

## 1. Intent and Executive Summary

| # | Field | Description |
|---|-------|-------------|
| 1 | **Problem Statement** | The opencode agent has no default Retrieval-Augmented Generation (RAG) service for querying a locally-maintained corpus of non-tracked, copyright-sensitive reference and research documentation. It relies on live web search for verification and cannot retrieve grounded content from that corpus without leaking source material into the tracked repository. |
| 2 | **Root Cause / Motivation** | The `.opencode/opencode.jsonc` `mcp` block declares three local services (the-notebook-mcp, srclight, editor) but no RAG service. The agent needs a config-driven RAG backend that indexes a non-tracked corpus with auto-sync, local embeddings, and per-source isolation, while keeping the copyrighted source material out of the tracked tree. |
| 3 | **Approach Chosen** | Adopt the RAGSync MCP server (`jsbroks/ragsync-mcp`) as-is and register it declaratively as a default local stdio MCP service in `.opencode/opencode.jsonc`, following the existing `type: local` / `stdio` / `uvx` pattern. RAGSync is configured via a config file that declares source directories, fastembed embedding settings, auto-sync behavior, and per-source isolation. |
| 4 | **Alternatives Considered & Why Discarded** | Building a bespoke/custom RAG implementation was considered and rejected because it duplicates an existing, maintained tool and adds in-repo maintenance and security surface for no functional gain. The RAGSync server is adopted as-is per constraint CON-1. |
| 5 | **Key Design Decisions** | (a) Register RAGSync as a default-on (`enabled: true`) local service so the agent gets RAG capability without per-session setup; tradeoff: one additional service loads at startup. (b) Use local embeddings via fastembed with a pinned default model; tradeoff: no external embedding API dependency at the cost of a first-run model download (mitigated by a documented offline/cache path). (c) Enforce per-source isolation with one config section per source; tradeoff: more config boilerplate in exchange for preventing cross-source retrieval leakage. |
| 6 | **User Intent / Original Prompt** | Add RAGSync MCP as a default MCP service for opencode, configured with local embeddings, per-source isolation, auto-sync, and documentation in the `.opencode` skill/guideline tree. |

## 2. Not Included

- **Ingesting or tracking the actual copyright-sensitive reference material in the repository** — the source corpus remains non-tracked (CON-2); the spec only configures retrieval over it.
- **Building a bespoke/custom RAG implementation** — RAGSync is adopted as-is (CON-1).
- **Backfilling existing research cards or dictionaries into the RAG index** — no historical material is re-indexed (CON-3).
- **Any changes to the root `snea-phonetics` repo's `.issues/` tree** — this spec is scoped to the `.opencode` repo (CON-4).
- **Modifying any existing MCP service** (the-notebook-mcp, srclight, editor) — the change is purely additive.

## 3. Constraints

The following constraints bound the scope and approach of this spec. Each CON identifier referenced elsewhere in this document is defined here.

| ID | Constraint | Rationale |
|----|-----------|-----------|
| CON-1 | RAGSync (`jsbroks/ragsync-mcp`) SHALL be adopted as-is; no bespoke/custom RAG implementation SHALL be built. | A maintained external tool covers the requirement; building in-house duplicates effort and adds maintenance/security surface for no functional gain. |
| CON-2 | The copyright-sensitive reference corpus SHALL remain non-tracked and SHALL NOT be ingested into the repository. | Keeps source material out of the tracked tree; the spec only configures retrieval over the non-tracked corpus. |
| CON-3 | No existing research cards or dictionaries SHALL be backfilled or re-indexed into the RAG index. | Scope boundary — no historical material is re-indexed. |
| CON-4 | This spec SHALL be scoped to the `.opencode` repo; no changes SHALL be made to the root `snea-phonetics` repo's `.issues/` tree. | Confines the change to the `.opencode` repo. |
| CON-5 | The RAGSync config and its opencode registration SHALL be co-located and validated to mitigate config drift. | Prevents the agent from loading a service pointing at stale configuration. |
| CON-6 | Per-source isolation SHALL be enforced with exactly one config section per reference source corpus, with a review checklist. | Prevents cross-source retrieval leakage between corpora. |
| CON-7 | The embedding model SHALL have a pinned default local model and a documented offline/cache path. | Mitigates first-run embedding model download failure. |

## 4. Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Documentation Sources |
|----|-----------|---------------|---------------------|----------------------|
| SC-1 | RAGSync (`jsbroks/ragsync-mcp`) SHALL be registered as a default MCP service in `.opencode/opencode.jsonc` with `type: local`, `stdio` transport, and `enabled: true`. | structural | `opencode.jsonc` mcp block contains the `ragsync` service entry, parses as valid JSONC, and lists the service as enabled. | `.opencode/opencode.jsonc` (mcp block); existing service pattern |
| SC-2 | RAGSync SHALL be configured to use local embeddings via `fastembed` with a pinned default local embedding model and no external embedding API dependency. | structural | RAGSync config references `fastembed` and a pinned default local model; no external embedding API endpoint is declared. | RAGSync config file; fastembed runtime |
| SC-3 | Per-source isolation SHALL be configured with exactly one config section per reference source corpus, with isolated index namespaces. | structural | RAGSync config declares one section per source with isolated index namespaces. | RAGSync config file |
| SC-4 | A review checklist SHALL be documented that enforces per-source isolation. | structural | A review checklist exists in the `.opencode` tree covering per-source isolation enforcement. | `.opencode/` skills/guidelines tree; review checklist |
| SC-5 | Auto-sync SHALL be enabled so the index updates on source file changes without manual re-indexing. | structural | RAGSync config enables auto-sync for each declared source. | RAGSync config file; RAGSync sync behavior |
| SC-6 | The service configuration, per-source layout, usage, offline/cache path, and validation step SHALL be documented in the `.opencode` skill/guideline tree. | structural | A documentation file exists in the `.opencode` tree covering config, per-source layout, usage, offline/cache path, and validation. | `.opencode/` skills/guidelines tree |

## 5. Requirements

- R-1. The `.opencode/opencode.jsonc` SHALL register RAGSync (`jsbroks/ragsync-mcp`) as a default MCP service using `type: local`, `stdio` transport, and `enabled: true`.
- R-2. The RAGSync service SHALL be registered in the `.opencode/opencode.jsonc` `mcp` block following the existing `uvx` runner pattern used by the current local services.
- R-3. RAGSync SHALL be configured to use local embeddings via `fastembed` with a pinned default local embedding model and no external embedding API dependency.
- R-4. RAGSync SHALL be configured with per-source isolation, with exactly one config section per reference source corpus.
- R-5. RAGSync SHALL have auto-sync enabled so the index updates on source file changes.
- R-6. The service configuration, per-source layout, usage, offline/cache path, and validation step SHALL be documented in the `.opencode` skill/guideline tree.
- R-7. RAGSync SHALL be adopted as-is, with no bespoke/custom RAG implementation.
- R-8. The copyright-sensitive reference material SHALL remain non-tracked and SHALL NOT be ingested into the repository.
- R-9. The RAGSync config and its opencode registration SHALL be co-located and validated to mitigate config drift.
- R-10. The embedding model SHALL have a pinned default local model and a documented offline/cache path to mitigate first-run download failure.
- R-11. A review checklist SHALL be documented in the `.opencode` tree that enforces per-source isolation.

## 6. Items

### Item 1 (SC-1): Register RAGSync as a default MCP service

- RED: A check that the `ragsync` service entry is absent from the `.opencode/opencode.jsonc` mcp block fails (i.e., the entry does not yet exist).
- GREEN: Add the `ragsync` service entry to `.opencode/opencode.jsonc` with `type: local`, `stdio` transport, and `enabled: true`.
- verify: Confirm the config parses as valid JSONC and the `ragsync` service is listed and enabled in the mcp block.
- commit: `.opencode/opencode.jsonc` registration change.

### Item 2 (SC-2): Configure local embeddings via fastembed

- RED: A check that RAGSync is configured with a pinned local fastembed model fails (no such configuration exists).
- GREEN: Configure RAGSync to use fastembed with a pinned default local embedding model and no external API dependency.
- verify: Confirm the RAGSync embedding configuration references fastembed and a pinned local model.
- commit: RAGSync embedding configuration.

### Item 3 (SC-3): Configure per-source isolation

- RED: A check that per-source config sections exist fails (no isolation is declared).
- GREEN: Declare one RAGSync config section per reference source corpus with isolated index namespaces.
- verify: Confirm per-source config sections are present with isolated index namespaces.
- commit: RAGSync per-source isolation configuration.

### Item 4 (SC-4): Document the per-source isolation review checklist

- RED: A check that the per-source isolation review checklist exists fails (no checklist is documented).
- GREEN: Document a review checklist in the `.opencode` tree that enforces per-source isolation.
- verify: Confirm the review checklist exists and covers per-source isolation enforcement.
- commit: `.opencode/` review checklist addition.

### Item 5 (SC-5): Enable auto-sync

- RED: A check that auto-sync is enabled fails (it is not configured).
- GREEN: Enable auto-sync for each declared source in the RAGSync config.
- verify: Confirm auto-sync is enabled in the RAGSync config for each source.
- commit: RAGSync auto-sync configuration.

### Item 6 (SC-6): Document service configuration and usage

- RED: A check that the documentation file exists fails (no RAGSync documentation is present).
- GREEN: Write documentation in the `.opencode` skill/guideline tree covering service configuration, per-source layout, usage, offline/cache path, and validation step.
- verify: Confirm the documentation file exists and covers the required topics.
- commit: `.opencode/` documentation addition.

## 7. Dependencies

| Reference | Relationship | Status |
|-----------|--------------|--------|
| `jsbroks/ragsync-mcp` | External MCP server adopted as-is; must be available and version-stable for the service to start. | Pending (external) |
| `fastembed` | Local embedding runtime; model downloaded on first run with offline/cache path mitigation. | Pending (external) |
| opencode MCP local-server registration | Required capability; confirmed present in `.opencode/opencode.jsonc` mcp block. | Satisfied |
| Existing MCP services (the-notebook-mcp, srclight, editor) | Unmodified; must continue to function alongside the new service. | Satisfied |

## 8. Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1, R-2 | SC-1 | Phase 1 |
| R-3 | SC-2 | Phase 1 |
| R-4 | SC-3 | Phase 1 |
| R-5 | SC-5 | Phase 1 |
| R-6 | SC-6 | Phase 2 |
| R-7 | SC-1 | Phase 1 |
| R-8 | SC-3 | Phase 1 |
| R-9 | SC-6 | Phase 2 |
| R-10 | SC-2 | Phase 1 |
| R-11 | SC-4 | Phase 1 |

## 9. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|--------------|
| opencode MCP config | config | `.opencode/opencode.jsonc` (mcp block) | Read via config file inspection; existing service pattern confirmed |
| RAGSync MCP server | code/external | `jsbroks/ragsync-mcp` | External tool; adopted as-is (CON-1) |
| fastembed embedding runtime | code/external | fastembed | Local runtime; model pinned and offline/cache path documented (CON-7) |
| RAGSync config | config | RAGSync config file (to be created) | Declared per-source layout and auto-sync |
| `.opencode` skill/guideline tree | doc | `.opencode/skills/` or `.opencode/guidelines/` | Documentation file exists covering config, layout, usage |

## 10. Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## 11. Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- SC-1: Verifying the `ragsync` service is registered and the config parses costs one config-inspection read. Skipping means a malformed or missing registration isn't caught until opencode fails to load the service at startup — a config defect discovered at runtime rather than design time.
- SC-2: Verifying the fastembed configuration and pinned model costs one config-inspection read. Skipping means an external embedding API dependency or unpinned model ships, producing an undeclared network dependency and a first-run failure that is only discovered at first retrieval.
- SC-3: Verifying per-source isolation sections costs one config-inspection read. Skipping means cross-source retrieval leakage ships unchecked — copyrighted material from one corpus leaking into another's retrieval results is a data-integrity and provenance defect discovered only in downstream queries.
- SC-4: Verifying the per-source isolation review checklist exists costs one file read. Skipping means the isolation enforcement is undocumented, so a future operator cannot verify that cross-source leakage is prevented.
- SC-5: Verifying auto-sync is enabled costs one config-inspection read. Skipping means a stale index ships, and the agent retrieves outdated content while believing it is current — a silent-correctness defect that surfaces as confidently-wrong answers.
- SC-6: Verifying the documentation file exists and covers the required topics costs one file read. Skipping means the config and registration drift apart undetected (CON-5), and the offline/cache path is undocumented, so a first-run embedding download failure becomes an unrecoverable blocker for the next operator.

## 12. Edge Cases

- **Input boundary — empty source directory:** If a declared source directory is empty, RAGSync SHALL produce an empty index for that source without failing other sources. Resolution: document per-source empty-handling in the review checklist.
- **Failure mode — embedding model download fails on first run:** If fastembed cannot download the default model, RAGSync SHALL fall back to the documented offline/cache path. Resolution: pin a default local model and document the offline/cache path (CON-7).
- **Failure mode — malformed MCP registration:** If the `ragsync` entry is malformed, opencode SHALL reject the config rather than silently loading a broken service. Resolution: verify JSONC validity in the SC-1 verification step.
- **Failure mode — cross-source isolation misconfigured:** If per-source isolation is misconfigured, retrieval SHALL NOT leak material between corpora. Resolution: enforce one config section per source and a review checklist (CON-6).
- **State transition — config drift:** If the RAGSync config and the opencode registration diverge, the agent may load a service pointing at stale configuration. Resolution: co-locate and validate both, and document the validation step (CON-5).
- **Concurrency — auto-sync during active retrieval:** If a source file changes while retrieval is in flight, RAGSync SHALL update the index without corrupting in-flight queries. Resolution: rely on RAGSync's auto-sync behavior; document that re-sync is non-destructive.

## Change Control

| Date | What Changed | Why | Authorized By |
|------|--------------|-----|---------------|
| 2026-08-21 | Added Section 3 "Constraints" defining CON-1 through CON-7 and renumbered subsequent sections 3-11 to 4-12. | Validation finding: spec referenced CON-1..CON-7 across Sections 1, 2, 8, 10, 11 without defining them (Completeness / Internal-Consistency failure). | Spec-creation revision pipeline (validation remediation) |
| 2026-08-21 | Replaced exact line-number references "lines 101-136" with file-area references (`.opencode/opencode.jsonc` mcp block) in Intent field 2, SC-1 Documentation Sources, and Section 9. | Validation finding: exact line numbers violate spec-structure-standards.md "Prohibited Content Patterns"; file-area references required. | Spec-creation revision pipeline (validation remediation) |
| 2026-08-21 | Decomposed SC-3 into two atomic SCs: SC-3 (one config section per source with isolated index namespaces) and SC-4 (review checklist enforcing isolation). Renumbered former SC-4/SC-5 to SC-5/SC-6 and updated Items, Traceability, and Cost Frame references accordingly. | Validation finding: Compound-SC detection FAIL on SC-3 — it bundled two independently verifiable claims (per-source config sections; review checklist). | Spec-creation revision pipeline (validation remediation) |
| 2026-08-21 | Added requirement R-11 (review checklist enforcing per-source isolation) and mapped it to SC-4 in the Section 8 Traceability table. | Validation finding: Traceability FAIL — SC-4 was an orphan in the Section 8 Traceability table, tracing to no requirement (R-1..R-10). | Spec-creation revision pipeline (validation remediation) |

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
