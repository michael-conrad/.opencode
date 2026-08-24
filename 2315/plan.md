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

**Goal:** Register the RAGSync MCP server as a default-on local stdio service in `.opencode/opencode.jsonc`, configure it with local fastembed embeddings, per-source isolation, and auto-sync, and document the configuration, usage, and validation in the `.opencode` tree.

**Architecture:** Adopt RAGSync (`jsbroks/ragsync-mcp`) as-is per CON-1. Add a declarative `ragsync` service entry to the `.opencode/opencode.jsonc` `mcp` block following the existing `type: local` / `stdio` / `uvx` pattern (CON-2 keeps the corpus non-tracked). Create a RAGSync config file co-located with the registration (CON-5) that declares one config section per reference source corpus with isolated index namespaces (CON-6), fastembed with a pinned default local model and no external embedding API (CON-7), and auto-sync per source. Document service config, per-source layout, usage, offline/cache path, and validation in the `.opencode` skill/guideline tree, plus a review checklist enforcing per-source isolation.

**Files:**
- `.opencode/opencode.jsonc` (mcp block — additive `ragsync` service entry)
- `.opencode/` RAG-Sync config file (new)
- `.opencode/` review checklist / documentation (new)

---

## Phase Table

| Phase | Skill | Task | Target | SCs | Depends On |
|-------|-------|------|--------|-----|------------|
| 1 — Configuration and registration work | `test-driven-development` | `red` | `.opencode/opencode.jsonc`, RAG-Sync config file, review checklist | SC-1, SC-2, SC-3, SC-4, SC-5 | — |
| 2 — Documentation work | `test-driven-development` | `red` | `.opencode/` skill/guideline tree | SC-6 | 1 |

---

## Phase Details

### Phase 1 — Configuration and registration work

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/opencode.jsonc` mcp block, RAG-Sync config file, review checklist |
| SCs | SC-1, SC-2, SC-3, SC-4, SC-5 |
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
sources:
  - one_config_section_per_reference_source_corpus
  - isolated_index_namespace_per_source
  - auto_sync_enabled_per_source
review_checklist:
  enforces: per-source isolation
```

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
  - per_source_layout
  - usage
  - offline_cache_path
  - validation_step
```

---

## Exit Criteria

- [ ] C1. SC-1 PASS: `ragsync` service registered in `.opencode/opencode.jsonc` mcp block with `type: local`, `stdio`, `enabled: true`.
- [ ] C2. SC-2 PASS: RAG-Sync configured with fastembed local embeddings, pinned default model, no external embedding API.
- [ ] C3. SC-3 PASS: Per-source isolation configured — exactly one config section per source with isolated index namespaces.
- [ ] C4. SC-4 PASS: Review checklist documented in `.opencode` tree enforcing per-source isolation.
- [ ] C5. SC-5 PASS: Auto-sync enabled for each declared source.
- [ ] C6. SC-6 PASS: Documentation exists in `.opencode` tree covering config, per-source layout, usage, offline/cache path, validation.
