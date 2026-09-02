---
plan_schema_version: "1.0"
issue: 2315
title: "Add RAGSync MCP as default MCP service for opencode"
authorization_scope: for_implementation
pr_strategy: stacked
phase_count: 2
---

# Implementation Plan — #2315 — Add RAGSync MCP as default MCP service for opencode

Issue: https://github.com/michael-conrad/.opencode/issues/2315

**Goal:** Register the RAGSync MCP server as a default-on local stdio service in `.opencode/opencode.jsonc`, configure it with local fastembed embeddings, per-source isolation, auto-sync, and a bounded indexing corpus scope, and document the configuration, usage, and validation in the `.opencode` tree.

**Architecture:** Adopt RAGSync (`jsbroks/ragsync-mcp`) as-is per CON-1. Add a declarative `ragsync` service entry to the `.opencode/opencode.jsonc` `mcp` block following the existing `type: local` / `stdio` / `uvx` pattern (CON-2 keeps the corpus non-tracked). Create a RAGSync config file co-located with the registration (CON-5) whose `sources` list is the authoritative designation of the reference source corpora per spec §3.1 — one folder-type source per designated corpus (`opencode-agent-config` over the main repo working tree; `.opencode-deck` over the `.opencode/` submodule) with isolated index namespaces (CON-6), fastembed with a pinned default local model and no external embedding API (CON-7), auto-sync per source, and a bounded corpus scope covering all main-repo files plus every registered submodule while excluding non-registered git sub-repos absent a declared carveout (CON-8). Document service config, per-source layout per §3.1, usage, offline/cache path, and validation in the `.opencode` skill/guideline tree, plus a review checklist enforcing per-source isolation.

**Files:**
- `.opencode/opencode.jsonc` (mcp block — additive `ragsync` service entry)
- `.opencode/` RAG-Sync config file (new)
- `.opencode/` review checklist / documentation (new)

---

## Phase Table

| Phase | Skill | Task | Target | SCs | Depends On |
|-------|-------|------|--------|-----|------------|
| 1 — Configuration and registration work | `test-driven-development` | `red` | `.opencode/opencode.jsonc`, RAG-Sync config file, review checklist | SC-1, SC-2, SC-3, SC-4, SC-5, SC-7 | — |
| 2 — Documentation work | `test-driven-development` | `red` | `.opencode/` skill/guideline tree | SC-6 | 1 |

---

## Phase Details

### Phase 1 — Configuration and registration work

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/opencode.jsonc` mcp block, RAG-Sync config file, review checklist |
| SCs | SC-1, SC-2, SC-3, SC-4, SC-5, SC-7 |
| Depends On | — |

**Context:**
```yaml
ragsync_service:
  name: ragsync
  type: local
  transport: stdio
  enabled: true
  runner_pattern: uvx
embedding:
  backend: fastembed
  model: "<pinned default local embedding model>"
  external_api_dependency: false
corpus_designation:
  authority: ragsync_config_sources_list
  spec_reference: §3.1
  sources:
    - id: opencode-agent-config
      root: main repo working tree (config root ../..)
      include_globs: ["**/*.md", "**/*.txt", "**/*.tex"]
      exclude_globs: [".git/**", "node_modules/**", ".opencode/**", ".issues/**", ".worktrees/**", "tmp/**", ".tools/**", ".pytest_cache/**", ".ruff_cache/**", ".srclight/**", ".idea/**", ".github/**", "tests/**", "docs/**/results/**", "docs/**/eval*/**", "LICENSE"]
    - id: .opencode-deck
      root: .opencode/ submodule (source root .)
      include_globs: ["**/*.md", "**/*.txt"]
      exclude_globs: ["node_modules/**", ".issues/**", "tmp/**", ".tools/**", ".node/**", "test-artifacts/**", "tests-v2/**", ".pytest_cache/**", "uv.lock", "package-lock.json", "bun.lock"]
    isolated_index_namespace: true
    auto_sync: true
corpus_scope:
  include: all files in main repo + every registered submodule (per .gitmodules)
  exclude_non_registered_git_subrepos: true
  carveout: declared in RAGSync config when required
review_checklist:
  enforces: per-source isolation
  topic_criteria: ["one config section per §3.1-designated source", "isolated index namespaces", "empty-source handling"]
```

**Procedure:**
1. Run the coherence gate and baseline check (clean-room) to confirm the plan faithfully derives from the approved spec #2315 and the feature branch is at trunk-tip with `.opencode/opencode.jsonc` declaring no `ragsync` service.
2. **Item 1 (SC-1)** — Pre-clean stale artifacts, then run RED (assert `ragsync` entry absent) → GREEN (add `ragsync` service entry with `type: local`, `stdio`, `enabled: true`) → post-regression → verify (behavioral: launch opencode, confirm service spawns and lists tools) → commit the registration change.
3. **Item 2 (SC-2)** — Pre-clean, then RED (assert pinned local fastembed config absent) → GREEN (configure fastembed with a pinned default local model, no external embedding API) → post-regression → verify (behavioral: network-monitored retrieval query through the fastembed local path) → commit the embedding config.
4. **Item 3 (SC-3)** — Pre-clean, then RED (assert no per-source config sections) → GREEN (declare one config section per §3.1-designated corpus — `opencode-agent-config` and `.opencode-deck` — with isolated index namespaces) → post-regression → verify (behavioral: cross-source search asserting no namespace leakage) → commit the per-source isolation config.
5. **Item 4 (SC-4)** — Pre-clean, then RED (assert review checklist absent) → GREEN (document review checklist enforcing per-source isolation with the topic-presence criteria: one config section per §3.1-designated source, isolated index namespaces, empty-source handling) → post-regression → verify (structural with explicit topic-presence criteria) → commit the checklist.
6. **Item 5 (SC-5)** — Pre-clean, then RED (assert auto-sync not enabled) → GREEN (enable auto-sync for each declared source) → post-regression → verify (behavioral: source-file modification with index-freshness observation) → commit the auto-sync config.
7. **Item 7 (SC-7)** — Pre-clean, then RED (assert no bounded corpus scope declared; a naive walk would index non-registered sub-repos) → GREEN (configure corpus scope to cover all main-repo files plus every registered submodule per `.gitmodules`, excluding non-registered git sub-repos — the `.issues/` orphan-branch worktrees at root and under `.opencode/` — absent a declared carveout) → post-regression → verify (behavioral: runtime enumeration of indexed sources asserting coverage and exclusion) → commit the corpus-scope config.
8. Run the **Phase 1 VbC** (clean-room) verifying SC-1..SC-5 and SC-7 are all clean PASS.

### Phase 2 — Documentation work

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/` skill/guideline tree |
| SCs | SC-6 |
| Depends On | 1 |

**Context:**
```yaml
documentation_topics:
  - service_configuration
  - per_source_layout_per_spec_3_1
  - corpus_scope
  - usage
  - offline_cache_path
  - validation_step
```

**Procedure:**
1. Confirm Phase 1 is complete and its VbC passed (SC-1..SC-5, SC-7 clean PASS) before starting documentation work.
2. **Item 6 (SC-6)** — Pre-clean stale artifacts, then run RED (assert RAGSync documentation file absent) → GREEN (write documentation covering service configuration, per-source layout per §3.1, corpus scope, usage, offline/cache path, validation step) → post-regression → verify (structural with explicit topic-presence criteria) → commit the documentation change.
3. Run the **Phase 2 VbC** (clean-room) verifying SC-6 is clean PASS.

---

## Exit Criteria

- [ ] C1. SC-1 PASS: `ragsync` service registered in `.opencode/opencode.jsonc` mcp block with `type: local`, `stdio`, `enabled: true` (behavioral: service spawns and lists tools).
- [ ] C2. SC-2 PASS: RAG-Sync configured with fastembed local embeddings, pinned default model, no external embedding API (behavioral: network-monitored retrieval).
- [ ] C3. SC-3 PASS: Per-source isolation configured — exactly one config section per §3.1-designated source with isolated index namespaces (behavioral: cross-source search, no leakage).
- [ ] C4. SC-4 PASS: Review checklist documented in `.opencode` tree enforcing per-source isolation with the topic-presence criteria (one config section per §3.1-designated source, isolated index namespaces, empty-source handling).
- [ ] C5. SC-5 PASS: Auto-sync enabled for each declared source (behavioral: index-freshness observation).
- [ ] C6. SC-6 PASS: Documentation exists in `.opencode` tree covering config, per-source layout per §3.1, corpus scope, usage, offline/cache path, validation (structural with explicit topic-presence criteria).
- [ ] C7. SC-7 PASS: Corpus scope bounded to all main-repo files plus every registered submodule; non-registered git sub-repos excluded absent a declared carveout (behavioral: runtime indexed-source enumeration).

---

## Lifecycle Events

| Timestamp | Event | Details |
|-----------|-------|---------|
| 2026-08-24T13:02:22Z | `plan_created` | Plan file `.opencode/.issues/2315/plan.md` verified, phase count = 2 |
| 2026-09-02T03:01:25Z | `spec_revision` | Spec #2315 revised (corpus-scope sync per 2026-09-01 developer directive): CON-8/R-12/SC-7 added, SC-1/2/3/5 uplifted to behavioral evidence |
| 2026-09-02T03:01:25Z | `plan_revised` | Plan regenerated against revised spec SC set: SC-7 added to Phase 1 (Item 7), behavioral verify steps added to Items 1/2/3/5, corpus scope added to documentation topics, Exit Criteria C7 added |
| 2026-09-02T03:41:00Z | `plan_revised` | Plan regenerated against spec revised with §3.1 Reference Source Corpus Designation: Architecture and Phase 1 context updated with the two §3.1-designated corpora (`opencode-agent-config`, `.opencode-deck`) and their include/exclude globs, Item 3 GREEN names the designated corpora, Items 4/6 verification updated to explicit topic-presence criteria, documentation topics reference §3.1 per-source layout |