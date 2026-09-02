---
number: 2315
title: "[SPEC] Add RAGSync MCP as default MCP service for opencode"
status: open
labels:
- needs-approval
- spec-draft
created: 2026-08-21T14:54:28Z
updated: 2026-09-02T03:01:25Z
remote_issue: 2315
remote_url: "https://github.com/michael-conrad/.opencode/issues/2315"
promoted_at: 2026-08-23T21:00:00Z
promotion_type: retroactive_import
last_sync: 2026-09-02T03:01:25Z
author: michael-conrad
---

# Spec: Add RAGSync MCP as default MCP service for opencode

## 1. Intent and Executive Summary

| # | Field | Description |
|---|-------|-------------|
| 1 | **Problem Statement** | The opencode agent has no default Retrieval-Augmented Generation (RAG) service for querying the locally-maintained corpus of non-tracked, copyright-sensitive reference and research documentation. It relies on live web search for verification and cannot retrieve grounded content from that corpus without leaking source material into the tracked repository. |
| 2 | **Root Cause / Motivation** | The `.opencode/opencode.jsonc` `mcp` block declares three local services (the-notebook-mcp, srclight, editor) but no RAG service. The agent needs a config-driven RAG backend that indexes a non-tracked corpus with auto-sync, local embeddings, per-source isolation, and a bounded indexing corpus scope, while keeping the copyrighted source material out of the tracked tree. |
| 3 | **Approach Chosen** | Adopt the RAGSync MCP server (`jsbroks/ragsync-mcp`) as-is and register it declaratively as a default local stdio MCP service in `.opencode/opencode.jsonc`, following the existing `type: local` / `stdio` / `uvx` pattern. RAGSync is configured via a config file that declares the reference source corpora per the §3.1 designation and the corpus scope, fastembed embedding settings with a pinned default model, auto-sync behavior, and per-source isolation with isolated index namespaces. |
| 4 | **Alternatives Considered & Why Discarded** | Building a bespoke/custom RAG implementation was considered and rejected because it duplicates an existing, maintained tool and adds in-repo maintenance and security surface for no functional gain. The RAGSync server is adopted as-is per constraint CON-1. |
| 5 | **Key Design Decisions** | (a) Register RAGSync as a default-on (`enabled: true`) local service so the agent gets RAG capability without per-session setup; tradeoff: one additional service loads at startup. (b) Use local embeddings via fastembed with a pinned default model; tradeoff: no external embedding API dependency at the cost of a first-run model download (mitigated by a documented offline/cache path). (c) Enforce per-source isolation with one config section per source; tradeoff: more config boilerplate in exchange for preventing cross-source retrieval leakage. (d) Bound the indexing corpus scope to the main repo plus its registered git submodules, excluding non-registered git sub-repos absent an explicit carveout; tradeoff: explicit scope enumeration in the config in exchange for preventing silently-indexed foreign git sub-repos. (e) Designate the RAGSync config's `sources` list as the authoritative declaration of the reference source corpora (§3.1), with two live-verified initial corpora — one over the main repo's tracked agent-facing text, one over the `.opencode/` submodule deck; tradeoff: explicit per-corpus config sections in exchange for a determinate, guess-free source set that two implementors would declare identically. |
| 6 | **User Intent / Original Prompt** | Add RAGSync MCP as a default MCP service for opencode, configured with local embeddings, per-source isolation, auto-sync, a bounded corpus scope (main repo + registered submodules only), and documentation in the `.opencode` skill/guideline tree. |

## 2. Not Included

- **Ingesting or tracking the actual copyright-sensitive reference material in the repository** — the source corpus remains non-tracked (CON-2); the spec only configures retrieval over it.
- **Building a bespoke/custom RAG implementation** — RAGSync is adopted as-is (CON-1).
- **Backfilling existing research cards or dictionaries into the RAG index** — no historical material is re-indexed (CON-3).
- **Any changes to the root `snea-phonetics` repo's `.issues/` tree** — this spec is scoped to the `.opencode` repo (CON-4).
- **Modifying any existing MCP service** (the-notebook-mcp, srclight, editor) — the change is purely additive.
- **Indexing git sub-repos that are not registered submodules** — e.g., the `.issues/` orphan-branch worktrees at the root repo and under `.opencode/` are excluded from the index unless a special carveout is declared in the RAGSync config (CON-8).

## 3. Constraints

The following constraints bound the scope and approach of this spec. Each CON identifier referenced elsewhere in this document is defined here. The reference source corpora referenced by CON-6, R-4, R-8, SC-3, SC-4, the Cost Frame, and the Edge Cases are defined in §3.1.

| ID | Constraint | Rationale |
|----|-----------|-----------|
| CON-1 | RAGSync (`jsbroks/ragsync-mcp`) SHALL be adopted as-is; no bespoke/custom RAG implementation SHALL be built. | A maintained external tool covers the requirement; building in-house duplicates effort and adds maintenance/security surface for no functional gain. |
| CON-2 | The copyright-sensitive reference corpus SHALL remain non-tracked and SHALL NOT be ingested into the repository. | Keeps source material out of the tracked tree; the spec only configures retrieval over the non-tracked corpus. |
| CON-3 | No existing research cards or dictionaries SHALL be backfilled or re-indexed into the RAG index. | Scope boundary — no historical material is re-indexed. |
| CON-4 | This spec SHALL be scoped to the `.opencode` repo; no changes SHALL be made to the root `snea-phonetics` repo's `.issues/` tree. | Confines the change to the `.opencode` repo. |
| CON-5 | The RAGSync config and its opencode registration SHALL be co-located and validated to mitigate config drift. | Prevents the agent from loading a service pointing at stale configuration. |
| CON-6 | Per-source isolation SHALL be enforced with exactly one config section per reference source corpus as designated in §3.1, with a review checklist. | Prevents cross-source retrieval leakage between corpora. |
| CON-7 | The embedding model SHALL have a pinned default local model and a documented offline/cache path. | Mitigates first-run embedding model download failure. |
| CON-8 | The indexing corpus scope SHALL cover all files in the main repo plus every git submodule in the main repo's registered submodule list (per `.gitmodules`). Git sub-repos that are not registered submodules — concretely, the `.issues/` orphan-branch worktrees at the root repo and under `.opencode/` — SHALL NOT be indexed unless a special carveout is declared in the RAGSync config. | Prevents silently-indexed foreign git sub-repos (orphan-branch worktrees with separate issue-tracking history) from entering retrieval, and guarantees intended main-repo and submodule coverage. Verified by repo inspection: `.gitmodules` registers exactly one submodule (`.opencode`); the root `.issues/` and `.opencode/.issues/` trees are orphan-branch git worktrees, not registered submodules. |

### 3.1 Reference Source Corpus Designation (CON-6 authority)

**Designation authority:** The RAGSync config file itself (co-located per CON-5) is the authoritative declaration of the reference source corpus set. One folder-type source per corpus, named in the config's `sources` list, is the sole designation mechanism — no separate manifest, no implicit walk, no undeclared corpus. The initial corpus enumeration below is recorded in the config at Item 3 GREEN; the config remains authoritative for additions.

**Designated reference source corpora** — live-verified against the working tree 2026-09-02:

| Corpus Name | Source Directory | Content | Verified By |
|-------------|------------------|---------|-------------|
| `opencode-agent-config` | main repo working tree (config root `../..`, resolved against the `.opencode/` config location) | Tracked agent-facing text: `AGENTS.md`, `README.md`, `CHANGELOG.md`, `docs/` (research decks and papers), `skills/` (approval-gate task verification files) | `git ls-files` enumeration (tracked top-level: AGENTS.md, CHANGELOG.md, docs, README.md, skills) |
| `.opencode-deck` | `.opencode/` submodule (source root `.`) | Tracked agent-deck content: `AGENTS.md`, `README.md`, `guidelines/` (33 guideline files), `skills/` (skill cards and task cards), `reference/` (standards references), `docs/` | `git -C .opencode ls-files` enumeration; `.gitmodules` registers `.opencode` as the sole submodule (CON-8) |

**Include/exclude policy per corpus (CON-8 alignment):** Each corpus source declares gitignore-style include globs limited to agent-facing text (`*.md`, `*.txt`, `*.tex`) and exclude globs removing non-content and foreign git sub-repos:

| Corpus | Exclude globs (mandatory) | Excludes |
|--------|---------------------------|----------|
| `opencode-agent-config` | `AGENTS.md` is included; excluded: `.git/**`, `node_modules/**`, `.opencode/**`, `.issues/**`, `.worktrees/**`, `tmp/**`, `.tools/**`, `.pytest_cache/**`, `.ruff_cache/**`, `.srclight/**`, `.idea/**`, `.github/**`, `tests/**`, `docs/**/results/**`, `docs/**/eval*/**`, `LICENSE` | Git internals, the submodule tree (indexed as its own corpus), the orphan-branch `.issues/` worktree (non-registered sub-repo, CON-8), tool/IDE/cache artifacts, binary model-qualification result sets, the LaTeX `eval` scratch trees, license boilerplate |
| `.opencode-deck` | excluded: `node_modules/**`, `.issues/**`, `tmp/**`, `.tools/**`, `.node/**`, `.opencode/**` (nested, none exists), `test-artifacts/**`, `tests-v2/**`, `.pytest_cache/**`, `uv.lock`, `package-lock.json`, `bun.lock` | Tool artifacts, the orphan-branch `.issues/` worktree (non-registered sub-repo, CON-8), behavioral-test fixture output, lock files |

**Non-corpora:** The `.issues/` orphan-branch worktrees at the root repo and under `.opencode/` (issue-tracking metadata, not agent-facing reference text) and any future non-registered git sub-repo are not corpora; they remain excluded per CON-8 unless a special carveout is declared in the RAGSync config. The `results/` directories under the parent repo's `docs/auditor-model-qualification/` hold binary/JSON model-qualification output rather than agent-facing text and are excluded by the include-glob policy rather than designated as corpora.

**Corpus-scope interplay:** This corpus designation is a subset of the CON-8 corpus scope. CON-8 guarantees the retrieval surface never exceeds main repo + registered submodules; this designation selects which agent-facing text corpora within that surface RAGSync declares as sources. Both are declared in the same RAGSync config; a source section outside the CON-8 surface is a config defect caught by SC-7 verification.

## 4. Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Documentation Sources |
|----|-----------|---------------|---------------------|----------------------|
| SC-1 | RAGSync (`jsbroks/ragsync-mcp`) SHALL be registered as a default MCP service in `.opencode/opencode.jsonc` with `type: local`, `stdio` transport, and `enabled: true`. | behavioral | Launch opencode and confirm the `ragsync` service spawns and lists its tools; confirm the `opencode.jsonc` mcp block contains the `ragsync` entry, parses as valid JSONC, and lists the service as enabled. | `.opencode/opencode.jsonc` (mcp block); existing service pattern; opencode runtime service-spawn behavior |
| SC-2 | RAGSync SHALL be configured to use local embeddings via `fastembed` with a pinned default local embedding model and no external embedding API dependency. | behavioral | Run a network-monitored retrieval query through the fastembed local path and confirm no external embedding API call is made; confirm the config references `fastembed` and a pinned default local model. | RAGSync config file; fastembed runtime; network-monitor output |
| SC-3 | Per-source isolation SHALL be configured with exactly one config section per reference source corpus designated in §3.1, with isolated index namespaces. | behavioral | Run a cross-source search asserting no retrieval leakage between corpus namespaces; confirm the config declares one section per source designated in §3.1 with isolated index namespaces. | RAGSync config file; §3.1 corpus designation; cross-source search output |
| SC-4 | A review checklist SHALL be documented that enforces per-source isolation. | structural | A review checklist exists in the `.opencode` tree and contains, at minimum, these topic-presence criteria: one config section per source designated in §3.1, isolated index namespaces, and empty-source handling. | `.opencode/` skills/guidelines tree; review checklist; §3.1 corpus designation |
| SC-5 | Auto-sync SHALL be enabled so the index updates on source file changes without manual re-indexing. | behavioral | Modify a source file, observe index freshness without manual re-indexing, and confirm the config enables auto-sync for each declared source. | RAGSync config file; RAGSync sync behavior; index-freshness observation |
| SC-6 | The service configuration, per-source layout, usage, offline/cache path, and validation step SHALL be documented in the `.opencode` skill/guideline tree. | structural | A documentation file exists in the `.opencode` tree and contains, at minimum, these topic-presence criteria: service configuration, per-source layout per §3.1, usage, offline/cache path, and validation. | `.opencode/` skills/guidelines tree; §3.1 corpus designation |
| SC-7 | The indexing corpus scope SHALL cover all files in the main repo plus every git submodule in the main repo's registered submodule list; git sub-repos that are not registered submodules SHALL NOT be indexed unless a special carveout is declared in the RAGSync config. | behavioral | Enumerate indexed sources at runtime and assert main-repo and registered-submodule coverage with non-registered sub-repos (e.g., the `.issues/` orphan-branch worktrees) excluded absent a carveout. | RAGSync config corpus scope; `.gitmodules` registered submodule list; runtime indexed-source enumeration |

## 5. Requirements

- R-1. The `.opencode/opencode.jsonc` SHALL register RAGSync (`jsbroks/ragsync-mcp`) as a default MCP service using `type: local`, `stdio` transport, and `enabled: true`.
- R-2. The RAGSync service SHALL be registered in the `.opencode/opencode.jsonc` `mcp` block following the existing `uvx` runner pattern used by the current local services.
- R-3. RAGSync SHALL be configured to use local embeddings via `fastembed` with a pinned default local embedding model and no external embedding API dependency.
- R-4. RAGSync SHALL be configured with per-source isolation, with exactly one config section per reference source corpus designated in §3.1.
- R-5. RAGSync SHALL have auto-sync enabled so the index updates on source file changes.
- R-6. The service configuration, per-source layout, usage, offline/cache path, and validation step SHALL be documented in the `.opencode` skill/guideline tree.
- R-7. RAGSync SHALL be adopted as-is, with no bespoke/custom RAG implementation.
- R-8. The copyright-sensitive reference material SHALL remain non-tracked and SHALL NOT be ingested into the repository; §3.1 designates which tracked directories within the CON-8 surface are reference source corpora exposed to retrieval.
- R-9. The RAGSync config and its opencode registration SHALL be co-located and validated to mitigate config drift.
- R-10. The embedding model SHALL have a pinned default local model and a documented offline/cache path to mitigate first-run download failure.
- R-11. A review checklist SHALL be documented in the `.opencode` tree that enforces per-source isolation.
- R-12. The indexing corpus scope SHALL be bounded to all files in the main repo plus every git submodule in the main repo's registered submodule list (per `.gitmodules`); git sub-repos that are not registered submodules — concretely, the `.issues/` orphan-branch worktrees at the root repo and under `.opencode/` — SHALL NOT be indexed unless a special carveout is declared in the RAGSync config.

## 6. Items

### Item 1 (SC-1): Register RAGSync as a default MCP service

- RED: A check that the `ragsync` service entry is absent from the `.opencode/opencode.jsonc` mcp block fails (i.e., the entry does not yet exist).
- GREEN: Add the `ragsync` service entry to `.opencode/opencode.jsonc` with `type: local`, `stdio` transport, and `enabled: true`.
- verify: Launch opencode and confirm the `ragsync` service spawns and lists its tools; confirm the config parses as valid JSONC and the service is listed and enabled in the mcp block.
- commit: `.opencode/opencode.jsonc` registration change.

### Item 2 (SC-2): Configure local embeddings via fastembed

- RED: A check that RAGSync is configured with a pinned local fastembed model fails (no such configuration exists).
- GREEN: Configure RAGSync to use fastembed with a pinned default local embedding model and no external API dependency.
- verify: Run a network-monitored retrieval query through the fastembed local path and confirm no external embedding API call is made; confirm the config references fastembed and a pinned local model.
- commit: RAGSync embedding configuration.

### Item 3 (SC-3): Configure per-source isolation

- RED: A check that per-source config sections exist fails (no isolation is declared).
- GREEN: Declare one RAGSync config section per reference source corpus designated in §3.1 (the `opencode-agent-config` and `.opencode-deck` corpora), with isolated index namespaces.
- verify: Run a cross-source search asserting no leakage between corpus namespaces; confirm per-source config sections are present with isolated index namespaces.
- commit: RAGSync per-source isolation configuration.

### Item 4 (SC-4): Document the per-source isolation review checklist

- RED: A check that the per-source isolation review checklist exists fails (no checklist is documented).
- GREEN: Document a review checklist in the `.opencode` tree that enforces per-source isolation.
- verify: Confirm the review checklist exists and covers per-source isolation enforcement.
- commit: `.opencode/` review checklist addition.

### Item 5 (SC-5): Enable auto-sync

- RED: A check that auto-sync is enabled fails (it is not configured).
- GREEN: Enable auto-sync for each declared source in the RAGSync config.
- verify: Modify a source file, observe index freshness without manual re-indexing, and confirm auto-sync is enabled in the RAGSync config for each source.
- commit: RAGSync auto-sync configuration.

### Item 6 (SC-6): Document service configuration and usage

- RED: A check that the documentation file exists fails (no RAGSync documentation is present).
- GREEN: Write documentation in the `.opencode` skill/guideline tree covering service configuration, per-source layout, usage, offline/cache path, and validation step.
- verify: Confirm the documentation file exists and covers the required topics.
- commit: `.opencode/` documentation addition.

### Item 7 (SC-7): Configure and verify the bounded corpus scope

- RED: A check that the RAGSync config declares a corpus scope covering all main-repo files plus every registered submodule fails (no corpus scope is declared; non-registered sub-repos would be silently indexed by a naive file walk).
- GREEN: Configure the RAGSync corpus scope to cover all files in the main repo plus every git submodule in the main repo's registered submodule list (per `.gitmodules`), excluding non-registered git sub-repos (the `.issues/` orphan-branch worktrees at the root repo and under `.opencode/`) unless a special carveout is declared in the RAGSync config.
- verify: Enumerate indexed sources at runtime and assert main-repo and registered-submodule coverage with non-registered sub-repos excluded absent a carveout.
- commit: RAGSync corpus-scope configuration.

## 7. Dependencies

| Reference | Relationship | Status |
|-----------|--------------|--------|
| `jsbroks/ragsync-mcp` | External MCP server adopted as-is; must be available and version-stable for the service to start. | Pending (external) |
| `fastembed` | Local embedding runtime; model downloaded on first run with offline/cache path mitigation. | Pending (external) |
| opencode MCP local-server registration | Required capability; confirmed present in `.opencode/opencode.jsonc` mcp block. | Satisfied |
| Existing MCP services (the-notebook-mcp, srclight, editor) | Unmodified; must continue to function alongside the new service. | Satisfied |
| Main repo `.gitmodules` registered submodule list | Authoritative source for the CON-8 corpus scope; currently registers exactly one submodule (`.opencode`). | Satisfied (verified) |
| Designated corpus directories (§3.1) | Live-verified enumeration of the reference source corpora declared in the RAGSync config (SC-3); verified against the working tree 2026-09-02. | Satisfied (verified) |

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
| R-12 | SC-7 | Phase 1 |

## 9. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|--------------|
| opencode MCP config | config | `.opencode/opencode.jsonc` (mcp block) | Read via config file inspection; existing service pattern confirmed |
| RAGSync MCP server | code/external | `jsbroks/ragsync-mcp` | External tool; adopted as-is (CON-1) |
| fastembed embedding runtime | code/external | fastembed | Local runtime; model pinned and offline/cache path documented (CON-7) |
| RAGSync config | config | RAGSync config file (to be created) | Declared per-source layout, corpus scope, and auto-sync |
| `.opencode` skill/guideline tree | doc | `.opencode/skills/` or `.opencode/guidelines/` | Documentation file exists covering config, layout, usage |
| Main repo submodule list | config | `.gitmodules` (main repo root) | Verified 2026-09-01: registers exactly one submodule (`.opencode` → `michael-conrad/.opencode`); root `.issues/` and `.opencode/.issues/` are orphan-branch git worktrees, not registered submodules (CON-8) |
| §3.1 designated corpus directories | config/working-tree | main repo working tree; `.opencode/` submodule | Verified 2026-09-02 via `git ls-files` enumeration (parent: AGENTS.md, CHANGELOG.md, docs, README.md, skills; submodule: AGENTS.md, README.md, guidelines/, skills/, reference/, docs/) and RAGSync README source semantics (folder sources, gitignore-style include/exclude, per-source `vector_store.collection` namespaces) |

## 10. Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## 11. Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- SC-1: Verifying the `ragsync` service spawns and is registered costs one runtime launch with tool listing. Skipping means a malformed or missing registration isn't caught until opencode fails to load the service at startup — a config defect discovered at runtime rather than design time.
- SC-2: Verifying the fastembed local path with network monitoring costs one instrumented retrieval query. Skipping means an external embedding API dependency or unpinned model ships, producing an undeclared network dependency and a first-run failure that is only discovered at first retrieval.
- SC-3: Verifying per-source isolation with a cross-source search costs one instrumented query pair. Skipping means cross-source retrieval leakage ships unchecked — copyrighted material from one corpus designated in §3.1 leaking into another's retrieval results is a data-integrity and provenance defect discovered only in downstream queries.
- SC-4: Verifying the per-source isolation review checklist exists costs one file read. Skipping means the isolation enforcement is undocumented, so a future operator cannot verify that cross-source leakage is prevented.
- SC-5: Verifying auto-sync via source-file modification and index-freshness observation costs one modification cycle. Skipping means a stale index ships, and the agent retrieves outdated content while believing it is current — a silent-correctness defect that surfaces as confidently-wrong answers.
- SC-6: Verifying the documentation file exists and covers the required topics costs one file read. Skipping means the config and registration drift apart undetected (CON-5), and the offline/cache path is undocumented, so a first-run embedding download failure becomes an unrecoverable blocker for the next operator.
- SC-7: Verifying the corpus scope via runtime indexed-source enumeration costs one enumeration pass. Skipping means the corpus scope is silently wrong — non-registered git sub-repos (the `.issues/` orphan-branch worktrees with their own issue-tracking content) enter retrieval, or intended main-repo/submodule coverage is missing — a provenance and data-integrity defect discovered only when retrieved content traces to an unintended source.

## 12. Edge Cases

- **Input boundary — empty source directory:** If a declared source directory is empty, RAGSync SHALL produce an empty index for that source without failing other sources. Resolution: document per-source empty-handling in the review checklist.
- **Input boundary — new reference corpus appears in the working tree:** If a new agent-facing text corpus is added within the CON-8 surface (e.g., a new docs tree in the main repo), it SHALL be designated by adding a source section to the RAGSync config (the §3.1 designation authority); the review checklist's §3.1 topic criterion catches an undeclared corpus during review.
- **Failure mode — embedding model download fails on first run:** If fastembed cannot download the default model, RAGSync SHALL fall back to the documented offline/cache path. Resolution: pin a default local model and document the offline/cache path (CON-7).
- **Failure mode — malformed MCP registration:** If the `ragsync` entry is malformed, opencode SHALL reject the config rather than silently loading a broken service. Resolution: verify JSONC validity in the SC-1 verification step.
- **Failure mode — cross-source isolation misconfigured:** If per-source isolation is misconfigured, retrieval SHALL NOT leak material between corpora designated in §3.1. Resolution: enforce one config section per source designated in §3.1 and a review checklist (CON-6).
- **State transition — config drift:** If the RAGSync config and the opencode registration diverge, the agent may load a service pointing at stale configuration. Resolution: co-locate and validate both, and document the validation step (CON-5).
- **Concurrency — auto-sync during active retrieval:** If a source file changes while retrieval is in flight, RAGSync SHALL update the index without corrupting in-flight queries. Resolution: rely on RAGSync's auto-sync behavior; document that re-sync is non-destructive.
- **Input boundary — naive file walk encounters non-registered git sub-repos:** A naive recursive walk of the main repo encounters the `.issues/` orphan-branch worktrees (root and under `.opencode/`), which are git sub-repos but not registered submodules. RAGSync SHALL NOT index them absent an explicit carveout in the RAGSync config. Resolution: declare the corpus scope explicitly (main repo + registered submodule list) and verify via runtime indexed-source enumeration (CON-8, SC-7).
- **Failure mode — submodule list drift:** If the main repo registers a new submodule, the RAGSync corpus scope SHALL be updated to include it; coverage assertions in the SC-7 verification catch drift between `.gitmodules` and the declared corpus scope. Resolution: derive the corpus scope from the registered submodule list and re-verify on submodule changes (CON-8, SC-7).

## Change Control

| Date | What Changed | Why | Authorized By |
|------|--------------|-----|---------------|
| 2026-08-21 | Added Section 3 "Constraints" defining CON-1 through CON-7 and renumbered subsequent sections 3-11 to 4-12. | Validation finding: spec referenced CON-1..CON-7 across Sections 1, 2, 8, 10, 11 without defining them (Completeness / Internal-Consistency failure). | Spec-creation revision pipeline (validation remediation) |
| 2026-08-21 | Replaced exact line-number references "lines 101-136" with file-area references (`.opencode/opencode.jsonc` mcp block) in Intent field 2, SC-1 Documentation Sources, and Section 9. | Validation finding: exact line numbers violate spec-structure-standards.md "Prohibited Content Patterns"; file-area references required. | Spec-creation revision pipeline (validation remediation) |
| 2026-08-21 | Decomposed SC-3 into two atomic SCs: SC-3 (one config section per source with isolated index namespaces) and SC-4 (review checklist enforcing isolation). Renumbered former SC-4/SC-5 to SC-5/SC-6 and updated Items, Traceability, and Cost Frame references accordingly. | Validation finding: Compound-SC detection FAIL on SC-3 — it bundled two independently verifiable claims (per-source config sections; review checklist). | Spec-creation revision pipeline (validation remediation) |
| 2026-08-21 | Added requirement R-11 (review checklist enforcing per-source isolation) and mapped it to SC-4 in the Section 8 Traceability table. | Validation finding: Traceability FAIL — SC-4 was an orphan in the Section 8 Traceability table, tracing to no requirement (R-1..R-10). | Spec-creation revision pipeline (validation remediation) |
| 2026-09-02 | Corpus-scope sync revision per 2026-09-01 developer directive: added CON-8 (bounded corpus scope = main repo + registered submodule list; non-registered git sub-repos — concretely the `.issues/` orphan-branch worktrees at root and under `.opencode/` — excluded absent a declared carveout), SC-7 with behavioral evidence (runtime indexed-source enumeration), R-12, Item 7 (per-SC RED/GREEN/verify/commit), Not-Included entry for non-registered sub-repos, Dependencies/Documentation-Sources rows for the `.gitmodules` submodule list, Traceability row R-12→SC-7 Phase 1, Cost Frame entry for SC-7, two Edge Cases (naive-walk encounter; submodule list drift), and behavioral uplift of SC-1/SC-2/SC-3/SC-5 (runtime service spawn + tool listing, network-monitored retrieval, cross-source leakage search, index-freshness observation) with corresponding Items 1/2/3/5 verify-step updates. | Spec-audit finding: the 2026-09-01 corpus-scope revision existed only as a condensed summary in the remote GitHub issue body; the authoritative local spec was missing the full success criterion text, definitions, behavioral uplift notes, Item 7, Traceability/Cost-Frame/Edge-Case entries, and the Change Control row. Revision restores full parity with the remote revision content. | Developer directive (2026-09-01 corpus-scope revision) applied via spec-creation revise task; audit finding per michael-conrad/.opencode#2315 spec audit |
| 2026-09-02 | Added §3.1 "Reference Source Corpus Designation (CON-6 authority)": designated the RAGSync config's `sources` list as the authoritative corpus declaration mechanism and live-verified the initial corpus enumeration — two folder-type corpora (`opencode-agent-config` over the main repo working tree; `.opencode-deck` over the `.opencode/` submodule) with mandatory exclude globs (git internals, non-registered `.issues/` orphan-branch worktrees per CON-8, tool/cache/lock artifacts, binary model-qualification result sets), a non-corpora list, and the CON-8 interplay rule. Updated CON-6, SC-3, R-4, R-8, Item 3 GREEN, Cost Frame SC-3 entry, and the cross-source isolation Edge Case to reference §3.1; added Dependencies and Documentation-Sources rows for the designation; added the "new reference corpus appears" Edge Case; made SC-4/SC-6 verification methods state explicit topic-presence criteria instead of bare existence. | Validation FAIL (aggregate) — Completeness and Implementability dimensions: the central concept "reference source corpus" was used in CON-6, R-4, R-8, SC-3, SC-4, the Cost Frame, and Edge Cases but never defined, leaving Item 3 GREEN ("Declare one RAGSync config section per reference source corpus") unexecutable without guessing corpus locations. Non-blocking validator notes (artifacts directory absent — warning only; SC-4/SC-6 structural evidence with content-coverage verify methods) addressed by the explicit topic-presence criteria; the artifacts directory is created downstream by the writing-plans pipeline and needed no spec change. | Spec-creation revision pipeline (validation remediation) |

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)