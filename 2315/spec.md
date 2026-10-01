---
number: 2315
title: "[SPEC] Adopt RAGSync MCP as default retrieval service and retire srclight (deck purge)"
status: open
labels:
- needs-approval
- spec-draft
created: 2026-08-21T14:54:28Z
updated: 2026-09-30T04:21:46Z
remote_issue: 2315
remote_url: "https://github.com/michael-conrad/.opencode/issues/2315"
promoted_at: 2026-08-23T21:00:00Z
promotion_type: retroactive_import
last_sync: 2026-09-30T04:21:46Z
author: michael-conrad
---

# Spec: Adopt RAGSync MCP as default retrieval service and retire srclight (deck purge)

## 1. Intent and Executive Summary

| # | Field | Description |
|---|-------|-------------|
| 1 | **Problem Statement** | The opencode agent has no default Retrieval-Augmented Generation (RAG) service for querying the locally-maintained corpus of non-tracked, copyright-sensitive reference and research documentation. It relies on live web search for verification and cannot retrieve grounded content from that corpus without leaking source material into the tracked repository. |
| 2 | **Root Cause / Motivation** | The `.opencode/opencode.jsonc` `mcp` block currently declares two local services (the-notebook-mcp, editor) — verified 2026-09-24 — but no RAG service. The retired srclight service was the nearest prior neighbor for this role (a local code-indexing service) and has been replaced: per developer directive (2026-09-24) it is retired because it suffered recurring init failures and Python dependency conflicts, depended on an external embedding API (conflicting with this spec's local-embeddings direction), and indexed Python code only, while the developer's repos also include Java, C#, and Godot script (GDScript), which srclight cannot index. RAGSync replaces srclight's role (CON-9). Additionally, per developer directive (2026-09-24, second round), the deck (the `.opencode/` submodule skill/guideline tree) still carries agent-facing instruction text referencing the retired service — a fresh exhaustive enumeration (2026-09-24, §3.2) found 162 srclight matches across 46 deck files — and agent-facing instructions must not direct agents toward a retired service. The agent needs a config-driven RAG backend that indexes a non-tracked corpus with auto-sync, local embeddings, per-source isolation, and a bounded indexing corpus scope, while keeping the copyrighted source material out of the tracked tree, plus a deck tree free of srclight references. |
| 3 | **Approach Chosen** | Adopt the RAGSync MCP server (`jsbroks/ragsync-mcp`) as-is and register it declaratively as a default local stdio MCP service in `.opencode/opencode.jsonc`, following the existing `type: local` / `stdio` / `uvx` pattern. RAGSync is configured via a config file that declares the reference source corpora per the §3.1 designation and the corpus scope, fastembed embedding settings with a single default model pinned by name (`Qwen/Qwen3-Embedding-0.6B-Q` — the fastembed quantized variant) and nothing pinned beyond the name, with local runtime caching keeping the downloaded model from being refetched on every service start, auto-sync behavior, per-source isolation with isolated index namespaces, and hard-fail failure semantics when the embedding model is not retrievable (the session continues best-effort without RAG capability). In the deck tree, srclight references are purged per the §3.2 disposition rule: genericized to capability-class wording (symbol/signature lookup, callers/callees/dependents blast-radius lookup, code search) where the capability mapping has value, removed outright where it does not (e.g., product-specific CLI troubleshooting commands), with graceful-degradation unavailability fallbacks preserved and no replacement product-name hardwiring (CON-10). |
| 4 | **Alternatives Considered & Why Discarded** | Building a bespoke/custom RAG implementation was considered and rejected because it duplicates an existing, maintained tool and adds in-repo maintenance and security surface for no functional gain. The RAGSync server is adopted as-is per constraint CON-1. Leaving the deck's srclight references in place until each consumer file is next edited was considered and rejected because stale instruction text actively misroutes agents toward a retired service; a one-time deck-wide purge (CON-10) removes the coupling defect at once instead of spreading it across future edits. |
| 5 | **Key Design Decisions** | (a) Register RAGSync as a default-on (`enabled: true`) local service so the agent gets RAG capability without per-session setup; tradeoff: one additional service loads at startup. (b) Use local embeddings via fastembed with a single default model pinned by name (`Qwen/Qwen3-Embedding-0.6B-Q`) and nothing beyond the name — no HF revision pin, no checksums; local runtime caching of the downloaded weights (the fastembed/HF Hub on-disk model cache) is KEPT so the model is not refetched on every service start, and only offline/cache-path contingency machinery (offline cache-prefill procedures, cache-path contingency planning) is excluded; tradeoff: no external embedding API dependency at the cost of a first-run model download that is then cached locally for subsequent runs, whose failure is a hard fail for the RAG service (the session continues best-effort without RAG capability). (c) Enforce per-source isolation with one config section per source; tradeoff: more config boilerplate in exchange for preventing cross-source retrieval leakage. (d) Bound the indexing corpus scope to the main repo plus its registered git submodules, excluding non-registered git sub-repos absent an explicit carveout; tradeoff: explicit scope enumeration in the config in exchange for preventing silently-indexed foreign git sub-repos. (e) Designate the RAGSync config's `sources` list as the authoritative declaration of the reference source corpora (§3.1), with two live-verified initial corpora — one over the main repo's tracked agent-facing text, one over the `.opencode/` submodule deck; tradeoff: explicit per-corpus config sections in exchange for a determinate, guess-free source set that two implementors would declare identically. (f) Purge deck srclight references with a two-disposition rule (§3.2) — genericize where capability wording has value, remove where it does not — with per-site judgment delegated to the implementor; tradeoff: judgment-based dispositions require per-site review in exchange for keeping procedures portable across any available index tooling without recreating product-name coupling. |
| 6 | **User Intent / Original Prompt** | Add RAGSync MCP as a default MCP service for opencode, configured with local embeddings, per-source isolation, auto-sync, a bounded corpus scope (main repo + registered submodules only), and documentation in the `.opencode` skill/guideline tree. Revision rounds (2026-09-24): the first round retired srclight in favor of RAGSync (CON-9); the second round folded the deck-wide srclight reference purge into this spec's scope (CON-10, §3.2) — no longer an external follow-up. |

## 2. Not Included

- **Ingesting or tracking the actual copyright-sensitive reference material in the repository** — the source corpus remains non-tracked (CON-2); the spec only configures retrieval over it.
- **Building a bespoke/custom RAG implementation** — RAGSync is adopted as-is (CON-1).
- **Backfilling existing research cards or dictionaries into the RAG index** — no historical material is re-indexed (CON-3).
- **Any changes to the root `snea-phonetics` repo's `.issues/` tree** — this spec is scoped to the `.opencode` repo (CON-4).
- **Modifying any existing MCP service** (the-notebook-mcp, editor) — the change is purely additive for the currently-registered services. The srclight service is already unregistered (verified 2026-09-24); its removal is recorded here, not protected — re-registration is prohibited by CON-9.
- **Indexing git sub-repos that are not registered submodules** — e.g., the `.issues/` orphan-branch worktrees at the root repo and under `.opencode/` are excluded from the index unless a special carveout is declared in the RAGSync config (CON-8).
- **Deleting the `.srclight/` working-tree cache directory** — file deletion is a destructive operation requiring separate, explicit authorization; the §3.1 `.srclight/**` exclude glob already keeps the stale cache out of the RAG index. Only the deck-tree references to srclight are purged in this spec.
- **Pinning the embedding model beyond its name** — no HF revision pin, no SHA-256 checksums, no integrity ledger, and no offline/cache-path contingency machinery are included; the name (`Qwen/Qwen3-Embedding-0.6B-Q`) is the whole pin (CON-7, developer directives 2026-09-30).
- **Committing the embedding model weights to the repository** — the ~1.12 GB single int8 blob is GitHub 100 MiB block / LFS territory and remains downloaded from the HF Hub at runtime into the local model cache (CON-7).
- **Building fallback or model-availability mitigation machinery** — an unavailable embedding model is a hard fail for the RAG service with best-effort no-RAG session continuation (CON-7); no fallback model and no elaborate failure-reporting paperwork are in scope (developer directives 2026-09-30). Local runtime caching is NOT this machinery — it is standard download-cache behavior (fastembed/HF Hub local cache directory) and stays in scope per the caching-≠-pinning developer correction (2026-09-30).

## 3. Constraints

The following constraints bound the scope and approach of this spec. Each CON identifier referenced elsewhere in this document is defined here. The reference source corpora referenced by CON-6, R-4, R-8, SC-3, SC-4, the Cost Frame, and the Edge Cases are defined in §3.1. The deck purge scope referenced by CON-10, R-13, R-14, SC-8, SC-9, and the Edge Cases is defined in §3.2.

| ID | Constraint | Rationale |
|----|-----------|-----------|
| CON-1 | RAGSync (`jsbroks/ragsync-mcp`) SHALL be adopted as-is; no bespoke/custom RAG implementation SHALL be built. | A maintained external tool covers the requirement; building in-house duplicates effort and adds maintenance/security surface for no functional gain. |
| CON-2 | The copyright-sensitive reference corpus SHALL remain non-tracked and SHALL NOT be ingested into the repository. | Keeps source material out of the tracked tree; the spec only configures retrieval over the non-tracked corpus. |
| CON-3 | No existing research cards or dictionaries SHALL be backfilled or re-indexed into the RAG index. | Scope boundary — no historical material is re-indexed. |
| CON-4 | This spec SHALL be scoped to the `.opencode` repo; no changes SHALL be made to the root `snea-phonetics` repo's `.issues/` tree. | Confines the change to the `.opencode` repo. |
| CON-5 | The RAGSync config and its opencode registration SHALL be co-located and validated to mitigate config drift. | Prevents the agent from loading a service pointing at stale configuration. |
| CON-6 | Per-source isolation SHALL be enforced with exactly one config section per reference source corpus as designated in §3.1, with a review checklist. | Prevents cross-source retrieval leakage between corpora. |
| CON-7 | The embedding model SHALL be pinned by name only — the pinned default local model is `Qwen/Qwen3-Embedding-0.6B-Q` (fastembed model name, provider fastembed). Pin NOTHING beyond the name: no HF revision pin, no SHA-256 checksums, no integrity ledger, and no offline/cache-path contingency machinery. Local runtime caching is distinct from pinning and SHALL be kept: after the first successful HF Hub download, the model weights live in the local runtime model cache (the fastembed/HF Hub on-disk cache directory) and SHALL NOT be refetched on every service start; the spec does not add cache-path contingency planning or offline prefill procedures — the cache is runtime behavior of the embedding stack, managed by fastembed/HF Hub defaults. The model weights SHALL NOT be committed to the repo. If the embedding model is not retrievable (first-run download failure or any model-availability failure), that is a HARD FAIL for the RAG MCP service — no fallback model, no silent degradation, no masking of the failure; the session continues best-effort WITHOUT RAG capability, with the failure surfaced honestly. | Developer directives (2026-09-30): the name pin is the stable, sufficient contract — the developer accepts the HF Hub as the permanently-available source, and extra pins (revisions, checksums, offline/cache contingency machinery) make the config brittle; the caching-≠-pinning correction (2026-09-30) keeps standard local model caching (so the model is not refetched on every service start) while only the heavyweight offline/cache contingency machinery is dropped; hard-fail semantics keep the service honest instead of masking an unavailable RAG capability. |
| CON-8 | The indexing corpus scope SHALL cover all files in the main repo plus every git submodule in the main repo's registered submodule list (per `.gitmodules`). Git sub-repos that are not registered submodules — concretely, the `.issues/` orphan-branch worktrees at the root repo and under `.opencode/` — SHALL NOT be indexed unless a special carveout is declared in the RAGSync config. | Prevents silently-indexed foreign git sub-repos (orphan-branch worktrees with separate issue-tracking history) from entering retrieval, and guarantees intended main-repo and submodule coverage. Verified by repo inspection: `.gitmodules` registers exactly one submodule (`.opencode`); the root `.issues/` and `.opencode/.issues/` trees are orphan-branch git worktrees, not registered submodules. |
| CON-9 | The retired srclight MCP service SHALL NOT be re-registered in `.opencode/opencode.jsonc`; RAGSync replaces its role as the retrieval/indexing service. | Developer directive (2026-09-24): srclight suffered recurring init failures and Python dependency conflicts, required an external embedding API (conflicting with this spec's local-embeddings direction), and indexed Python code only — the developer's repos also include Java, C#, and Godot script (GDScript), which srclight cannot index; RAGSync's gitignore-style text-file indexing is language-agnostic and covers them. Srclight is already unregistered (verified 2026-09-24: the `mcp` block declares only the-notebook-mcp and editor), so no removal implementation work remains in this spec — the ban prevents regression. |
| CON-10 | Deck srclight references SHALL be purged per the §3.2 disposition rule: genericized to capability-class wording where the capability mapping has value, removed outright where it does not (e.g., srclight-CLI-specific troubleshooting commands). Generic rewrites SHALL NOT hardwire a replacement product name — no `ragsync` (or other replacement-product) naming in deck tool-selection text; name the capability, not the product. Genericized text SHALL preserve the existing graceful-degradation behavior: wherever a task card carries an "if srclight unavailable → do NOT BLOCK" fallback row, the genericized text SHALL carry an equivalent unavailability fallback row. The §3.2 sweep exclusion list is the determinate boundary of the SC-8 sweep. | Developer directive (2026-09-24, second round): agent-facing instruction text must not reference a retired service; capability-class wording keeps procedures usable by ANY available local index tooling; hardwiring a new product name would recreate the same tool-coupling defect srclight left behind. |

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
| `opencode-agent-config` | `AGENTS.md` is included; excluded: `.git/**`, `node_modules/**`, `.opencode/**`, `.issues/**`, `.worktrees/**`, `tmp/**`, `.tools/**`, `.pytest_cache/**`, `.ruff_cache/**`, `.srclight/**`, `.idea/**`, `.github/**`, `tests/**`, `docs/**/results/**`, `docs/**/eval*/**`, `LICENSE` | Git internals, the submodule tree (indexed as its own corpus), the orphan-branch `.issues/` worktree (non-registered sub-repo, CON-8), stale cache artifacts of the removed srclight service (the `.srclight/` directory remains in the working tree and must not enter the RAG index), tool/IDE/cache artifacts, binary model-qualification result sets, the LaTeX `eval` scratch trees, license boilerplate |
| `.opencode-deck` | excluded: `node_modules/**`, `.issues/**`, `tmp/**`, `.tools/**`, `.node/**`, `.opencode/**` (nested, none exists), `test-artifacts/**`, `tests-v2/**`, `.pytest_cache/**`, `uv.lock`, `package-lock.json`, `bun.lock` | Tool artifacts, the orphan-branch `.issues/` worktree (non-registered sub-repo, CON-8), behavioral-test fixture output, lock files |

**Non-corpora:** The `.issues/` orphan-branch worktrees at the root repo and under `.opencode/` (issue-tracking metadata, not agent-facing reference text) and any future non-registered git sub-repo are not corpora; they remain excluded per CON-8 unless a special carveout is declared in the RAGSync config. The `results/` directories under the parent repo's `docs/auditor-model-qualification/` hold binary/JSON model-qualification output rather than agent-facing text and are excluded by the include-glob policy rather than designated as corpora.

**Corpus-scope interplay:** This corpus designation is a subset of the CON-8 corpus scope. CON-8 guarantees the retrieval surface never exceeds main repo + registered submodules; this designation selects which agent-facing text corpora within that surface RAGSync declares as sources. Both are declared in the same RAGSync config; a source section outside the CON-8 surface is a config defect caught by SC-7 verification.

### 3.2 Deck srclight Reference Purge Scope (CON-10 authority)

**Footprint enumeration (fresh, exhaustive, 2026-09-24):** Performed with `rg -i 'srclight' .opencode/ --hidden --no-ignore` excluding `.opencode/.git/**` and `.opencode/.issues/**`. Result: **162 matches across 46 files**. `.opencode/reference/**` verified zero matches. Every in-scope file and its match count:

| Deck area | File | Matches |
|-----------|------|---------|
| guidelines | `guidelines/015-pre-spec-inspection.md` | 4 |
| guidelines | `guidelines/020-go-prohibitions.md` | 1 |
| guidelines | `guidelines/025-discussion-mode.md` | 1 |
| guidelines | `guidelines/060-tool-usage.md` | 2 |
| guidelines | `guidelines/065-verification-honesty.md` | 2 |
| guidelines | `guidelines/075-docs-verification.md` | 3 |
| guidelines | `guidelines/080-code-standards.md` | 1 |
| guidelines | `guidelines/143-planning-spec-templates.md` | 2 |
| guidelines | `guidelines/144-planning-spec-examples.md` | 2 |
| skills/audit | `tasks/concern-separation-evaluator.md` | 1 |
| skills/audit | `tasks/concern-separation-investigator.md` | 10 |
| skills/audit | `tasks/concern-separation-validator.md` | 24 |
| skills/audit | `tasks/content-audit-investigator.md` | 3 |
| skills/audit | `tasks/content-audit-validator.md` | 4 |
| skills/audit | `tasks/drift-detection-investigator.md` | 9 |
| skills/audit | `tasks/drift-detection-validator.md` | 10 |
| skills/audit | `tasks/plan-fidelity-evaluator.md` | 1 |
| skills/audit | `tasks/plan-fidelity-investigator.md` | 2 |
| skills/audit | `tasks/plan-fidelity-validator.md` | 5 |
| skills/audit | `tasks/spec-audit-evaluator.md` | 1 |
| skills/audit | `tasks/spec-audit-investigator.md` | 3 |
| skills/audit | `tasks/spec-audit-validator.md` | 2 |
| skills/brainstorming | `tasks/enforcement.md` | 3 |
| skills/brainstorming | `tasks/explore/exploration-workflow.md` | 1 |
| skills/brainstorming | `tasks/explore/pre-spec-inspection.md` | 12 |
| skills/brainstorming | `tasks/top-down-analysis.md` | 6 |
| skills | `correspondence/tasks/draft.md` | 1 |
| skills | `engineering-approach/tasks/verify-understanding.md` | 4 |
| skills | `issue-operations-core/tasks/pre-creation.md` | 4 |
| skills | `issue-operations-core/tasks/read-issue.md` | 1 |
| skills | `issue-review/tasks/analyze-and-spec.md` | 1 |
| skills | `mcp-tool-usage/SKILL.md` | 3 |
| skills | `mcp-tool-usage/tasks/selection-guide.md` | 9 |
| skills | `spec-creation/SKILL.md` | 1 |
| skills | `spec-creation/tasks/analyze.md` | 3 |
| skills | `systematic-debugging/tasks/diagnose.md` | 2 |
| skills | `systematic-debugging/tasks/fix.md` | 1 |
| skills | `test-driven-development/SKILL.md` | 1 |
| skills | `test-driven-development/tasks/phase-0.md` | 2 |
| skills | `test-driven-development/tasks/phase-4.md` | 1 |
| skills | `verification-before-completion/tasks/collect.md` | 1 |
| skills | `verification-before-completion/tasks/operating-protocol.md` | 1 |
| skills | `verification-before-completion/tasks/verify.md` | 1 |
| other deck | `README.md` | 1 |
| other deck | `tools/session-init` | 6 |
| other deck | `tools/session-to-timeline` | 3 |
| | **Total** | **162** |

**Disposition rule (per-site judgment delegated to the implementor):** Each srclight reference is resolved with exactly one of two dispositions:

1. **GENERICIZE** — rewrite the reference so the procedure works with ANY available local index tooling, using capability-class wording. Canonical capability mappings:
   - `srclight_get_signature` → symbol/signature lookup
   - `srclight_get_symbol` → symbol lookup
   - `srclight_get_callers` / `srclight_get_callees` / `srclight_get_dependents` → callers/callees/dependents (blast-radius) lookup
   - `srclight_search_symbols` / `srclight_hybrid_search` → code search
   - `srclight_symbols_in_file` → symbol enumeration in a file
   - `srclight_get_tests_for` → test-coverage lookup
   - `srclight_recent_changes` → recent-changes lookup
   - `srclight_*` as a tool-call class in enumeration lists → "available local index tooling" / "index-tool calls"
   Generic rewrites MUST NOT name a replacement product: no `ragsync` (or any other product) in deck tool-selection text — name the capability, not the product (CON-10).
2. **REMOVE** — delete the reference outright where genericization has no value. Concretely: the srclight CLI troubleshooting section in `mcp-tool-usage/tasks/selection-guide.md` (`uvx srclight index --embed qwen3-embedding`, `uvx srclight status`, `uvx srclight search` and its troubleshooting-table rows referencing those commands); the srclight entries in the tier tables of `guidelines/060-tool-usage.md` and `mcp-tool-usage/SKILL.md` (a retired service does not belong in a tool-selection table); the `check_srclight()` probe, its `srclight_status` wiring, and the "run: uvx srclight index" startup message in `tools/session-init`; the `srclight_*` tool-name normalizers in `tools/session-to-timeline`; the `"srclight": { ... }` line in the `README.md` mcp-block example.

**Fallback preservation:** Wherever a task card currently carries an "if srclight unavailable → do NOT BLOCK" (or equivalent `TOOL_UNAVAILABLE` / `srclight_unavailable`) graceful-degradation row, the genericized text SHALL preserve an equivalent unavailability fallback row (e.g., "if no local index tool provides the capability → proceed with file-path-only evidence, do NOT BLOCK").

**Sweep exclusion list (determinate boundary of the SC-8 sweep):** The deck sweep targets the `.opencode/` working tree with these exclusions only: `.opencode/.git/**`, `.opencode/.issues/**` (the issue store — historical specs, plans, artifacts, evidence logs, lessons-learned records; these are records of past work, not agent-facing instructions, and MUST NOT be rewritten), `node_modules/**`, `tmp/**`, `.pytest_cache/**`, `.ruff_cache/**`. Every other file under `.opencode/` — including `README.md`, `reference/**`, and `tools/` — is in sweep scope.

**Not-included carveout:** Deleting the `.srclight/` working-tree cache directory is out of scope (destructive file deletion, separately authorized); the §3.1 `.srclight/**` exclude glob already keeps it out of the RAG index.

## 4. Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Documentation Sources |
|----|-----------|---------------|---------------------|----------------------|
| SC-1 | RAGSync (`jsbroks/ragsync-mcp`) SHALL be registered as a default MCP service in `.opencode/opencode.jsonc` with `type: local`, `stdio` transport, and `enabled: true`. | behavioral | Launch opencode and confirm the `ragsync` service spawns and lists its tools; confirm the `opencode.jsonc` mcp block contains the `ragsync` entry, parses as valid JSONC, and lists the service as enabled. | `.opencode/opencode.jsonc` (mcp block); existing service pattern; opencode runtime service-spawn behavior |
| SC-2 | RAGSync SHALL be configured to use local embeddings via `fastembed` with a single default local embedding model pinned by name (`Qwen/Qwen3-Embedding-0.6B-Q`) and nothing beyond the name, with no external embedding API dependency; the downloaded model SHALL be cached locally by the embedding stack's standard runtime cache so it is not refetched on every service start (caching is NOT pinning — no offline/cache-path contingency machinery is configured); if the model is not retrievable, the RAG service hard-fails and the session continues best-effort without RAG capability. | behavioral | Run a network-monitored retrieval query through the fastembed local path and confirm no external embedding API call is made; confirm the config references `fastembed` and the named model `Qwen/Qwen3-Embedding-0.6B-Q` and nothing beyond the name (no revision pin, no checksums); observe that a subsequent retrieval after cache warm does not refetch the model from the HF Hub (local cache hit — caching-≠-pinning verification); block the RAGSync service from reaching the HF Hub in a separate run and confirm the service hard-fails with the model-unavailability failure surfaced honestly rather than silently degrading to a fallback model. | RAGSync config file; fastembed runtime; network-monitor output; cache-observation output; block-run output |
| SC-3 | Per-source isolation SHALL be configured with exactly one config section per reference source corpus designated in §3.1, with isolated index namespaces. | behavioral | Run a cross-source search asserting no retrieval leakage between corpus namespaces; confirm the config declares one section per source designated in §3.1 with isolated index namespaces. | RAGSync config file; §3.1 corpus designation; cross-source search output |
| SC-4 | A review checklist SHALL be documented that enforces per-source isolation. | structural | A review checklist exists in the `.opencode` tree and contains, at minimum, these topic-presence criteria: one config section per source designated in §3.1, isolated index namespaces, and empty-source handling. | `.opencode/` skills/guidelines tree; review checklist; §3.1 corpus designation |
| SC-5 | Auto-sync SHALL be enabled so the index updates on source file changes without manual re-indexing. | behavioral | Modify a source file, observe index freshness without manual re-indexing, and confirm the config enables auto-sync for each declared source. | RAGSync config file; RAGSync sync behavior; index-freshness observation |
| SC-6 | The service configuration, per-source layout, usage, and validation step SHALL be documented in the `.opencode` skill/guideline tree. | structural | A documentation file exists in the `.opencode` tree and contains, at minimum, these topic-presence criteria: service configuration, per-source layout per §3.1, usage, and validation. | `.opencode/` skills/guidelines tree; §3.1 corpus designation |
| SC-7 | The indexing corpus scope SHALL cover all files in the main repo plus every git submodule in the main repo's registered submodule list; git sub-repos that are not registered submodules SHALL NOT be indexed unless a special carveout is declared in the RAGSync config. | behavioral | Enumerate indexed sources at runtime and assert main-repo and registered-submodule coverage with non-registered sub-repos (e.g., the `.issues/` orphan-branch worktrees) excluded absent a carveout. | RAGSync config corpus scope; `.gitmodules` registered submodule list; runtime indexed-source enumeration |
| SC-8 | The `.opencode/` deck tree SHALL contain zero srclight references: every reference enumerated in §3.2 is either removed outright or genericized to capability-class wording per the §3.2 disposition rule, with the §3.2 sweep exclusion list as the determinate sweep boundary. | structural | Run the §3.2 deck sweep (`rg -i 'srclight' .opencode/ --hidden --no-ignore` with the §3.2 exclusions) and assert zero matches; spot-check genericized sites for capability-only wording (no product name). | §3.2 footprint enumeration; deck sweep output; CON-10 |
| SC-9 | Agent tool-selection behavior SHALL be srclight-free: when a task requires symbol/signature lookup, callers/callees/dependents blast-radius analysis, or code search, the agent SHALL use available tooling or the built-in `read`/`grep` fallback per the genericized deck text and SHALL NOT attempt `srclight_*` tools. | behavioral | An isolated opencode run on a code-verification task (signature/blast-radius lookup) shows the agent selecting available tooling or the built-in read/grep fallback, with zero `srclight_*` tool-call attempts in the session evidence. | Genericized deck text; opencode run session evidence; CON-10 |
| SC-10 | Verification of the RAGSync service lifecycle (spawn, retrieval, index freshness, isolation, corpus enumeration) SHALL be performed by semantic runtime analysis — the prescribed instruments are isolated `opencode run` sessions (via the `with-test-home` harness) and direct observation of the running service's live behavior and session/log evidence. Substituting hand-spawned JSONRPC probe scripts that POLL the server's stdout in static read loops, or static string/file-pattern checks standing in for a behavioral claim, is an EVIDENCE_TYPE_MISMATCH: any SC whose verification is executed that way SHALL be adjudicated FAIL (re-verified with the semantic instrument). Probe scripts may exist only as diagnostic aids alongside, never instead of, the semantic run. A sub-agent executing SC verification SHALL NOT modify harness files (`.opencode/tests-v2/**`) or the service registration/config under test as a side effect; harness defects discovered during verification are reported, not patched mid-SC. | behavioral | Audit of the SC-1..SC-7 verification evidence: each behavioral SC verdict cites a semantic instrument (session yaml from `with-test-home opencode run`, live service log observation) — zero verdicts derived solely from static probe-poll scripts or string-only checks; harness/config diff scan shows no verification-stage commits touching `.opencode/tests-v2/**` or the files under test. | SC verification evidence artifacts; `with-test-home` harness; evidence-type taxonomy (test-driven-development SKILL.md) |

**Evidence-type statement (deliberate):** SC-8 is a text-state criterion and is verified structurally (zero-match sweep). SC-9 claims a change to agent tool-selection behavior, which is runtime-behavioral; per the evidence-type uplift rule its evidence is behavioral (an opencode run), not the structural sweep — the sweep alone would be EVIDENCE_TYPE_MISMATCH for the behavior claim. SC-10 is the enforcement counterpart: it pins the SEMANTIC instrument requirement for all RAGSync lifecycle verification (added 2026-09-30 after a verification sub-agent substituted a static stdout-polling probe script for the prescribed semantic run — regressed procedure, adjudicated and remediated).

## 5. Requirements

- R-1. The `.opencode/opencode.jsonc` SHALL register RAGSync (`jsbroks/ragsync-mcp`) as a default MCP service using `type: local`, `stdio` transport, and `enabled: true`.
- R-2. The RAGSync service SHALL be registered in the `.opencode/opencode.jsonc` `mcp` block following the existing `uvx` runner pattern used by the current local services.
- R-3. RAGSync SHALL be configured to use local embeddings via `fastembed` with a single default local embedding model pinned by name (`Qwen/Qwen3-Embedding-0.6B-Q`) and no external embedding API dependency.
- R-4. RAGSync SHALL be configured with per-source isolation, with exactly one config section per reference source corpus designated in §3.1.
- R-5. RAGSync SHALL have auto-sync enabled so the index updates on source file changes.
- R-6. The service configuration, per-source layout, usage, and validation step SHALL be documented in the `.opencode` skill/guideline tree.
- R-7. RAGSync SHALL be adopted as-is, with no bespoke/custom RAG implementation.
- R-8. The copyright-sensitive reference material SHALL remain non-tracked and SHALL NOT be ingested into the repository; §3.1 designates which tracked directories within the CON-8 surface are reference source corpora exposed to retrieval.
- R-9. The RAGSync config and its opencode registration SHALL be co-located and validated to mitigate config drift.
- R-10. The embedding model SHALL be pinned by name only (`Qwen/Qwen3-Embedding-0.6B-Q`, fastembed model name) — no HF revision pin, no checksums, no offline/cache-path contingency machinery; local runtime caching SHALL be kept (after first successful download the model is served from the embedding stack's local cache and is not refetched on every service start — caching is NOT pinning); if the model is not retrievable, the RAG MCP service SHALL hard-fail (no fallback, no silent degradation) and the session SHALL continue best-effort without RAG capability.
- R-11. A review checklist SHALL be documented in the `.opencode` tree that enforces per-source isolation.
- R-12. The indexing corpus scope SHALL be bounded to all files in the main repo plus every git submodule in the main repo's registered submodule list (per `.gitmodules`); git sub-repos that are not registered submodules — concretely, the `.issues/` orphan-branch worktrees at the root repo and under `.opencode/` — SHALL NOT be indexed unless a special carveout is declared in the RAGSync config.
- R-13. Srclight references in the `.opencode/` deck tree SHALL be removed outright or genericized to capability-class wording per the §3.2 disposition rule (CON-10), preserving graceful-degradation unavailability fallbacks in genericized text.
- R-14. Genericized deck tool-selection text SHALL name capabilities, not products — no `ragsync` (or other replacement-product) naming in deck tool-selection text.
- R-15. Verification of the RAGSync service lifecycle SHALL use semantic runtime analysis (the prescribed instruments: isolated `with-test-home opencode run` sessions, live service log/session observation); static probe-poll scripts, string-only checks, or file-pattern sweeps standing in for a behavioral verdict SHALL be adjudicated EVIDENCE_TYPE_MISMATCH (= FAIL for the affected SC). Sub-agents executing SC verification SHALL NOT modify harness files (`.opencode/tests-v2/**`) or the files under test as verification side effects — defects found are reported, not patched mid-SC.

## 6. Items

### Item 1 (SC-1): Register RAGSync as a default MCP service

- RED: A check that the `ragsync` service entry is absent from the `.opencode/opencode.jsonc` mcp block fails (i.e., the entry does not yet exist).
- GREEN: Add the `ragsync` service entry to `.opencode/opencode.jsonc` with `type: local`, `stdio` transport, and `enabled: true`.
- verify: Launch opencode and confirm the `ragsync` service spawns and lists its tools; confirm the config parses as valid JSONC and the service is listed and enabled in the mcp block.
- commit: `.opencode/opencode.jsonc` registration change.

### Item 2 (SC-2): Configure local embeddings via fastembed

- RED: A check that RAGSync is configured with the named default local fastembed model `Qwen/Qwen3-Embedding-0.6B-Q` fails (no such configuration exists).
- GREEN: Configure RAGSync to use fastembed with the default local embedding model pinned by name only — `Qwen/Qwen3-Embedding-0.6B-Q` — and no external API dependency; no HF revision pin, no checksums; local runtime caching of the downloaded weights is kept (standard fastembed/HF Hub cache behavior so the model is not refetched on every service start), with no offline/cache-path contingency machinery.
- verify: Run a network-monitored retrieval query through the fastembed local path and confirm no external embedding API call is made; confirm the config references fastembed and the named model and nothing beyond the name; observe that a subsequent retrieval after cache warm does not refetch the model (local cache hit); block the HF Hub in a separate run and confirm the RAG service hard-fails with the availability failure surfaced honestly (best-effort no-RAG session continuation).
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
- GREEN: Write documentation in the `.opencode` skill/guideline tree covering service configuration, per-source layout, usage, local model-cache behavior (caching is NOT pinning — the embedding stack's standard runtime cache keeps the model from refetching on every service start), and validation step.
- verify: Confirm the documentation file exists and covers the required topics.
- commit: `.opencode/` documentation addition.

### Item 7 (SC-7): Configure and verify the bounded corpus scope

- RED: A check that the RAGSync config declares a corpus scope covering all main-repo files plus every registered submodule fails (no corpus scope is declared; non-registered sub-repos would be silently indexed by a naive file walk).
- GREEN: Configure the RAGSync corpus scope to cover all files in the main repo plus every git submodule in the main repo's registered submodule list (per `.gitmodules`), excluding non-registered git sub-repos (the `.issues/` orphan-branch worktrees at the root repo and under `.opencode/`) unless a special carveout is declared in the RAGSync config.
- verify: Enumerate indexed sources at runtime and assert main-repo and registered-submodule coverage with non-registered sub-repos excluded absent a carveout.
- commit: RAGSync corpus-scope configuration.

### Item 8 (SC-8): Purge srclight references from the deck tree

- RED: The §3.2 deck sweep (`rg -i 'srclight' .opencode/ --hidden --no-ignore` with the §3.2 exclusions) returns srclight matches — the references enumerated in §3.2 are still present.
- GREEN: Apply the §3.2 disposition rule per site across all 46 enumerated files: genericize capability-bearing references to capability-class wording (symbol/signature lookup, callers/callees/dependents blast-radius lookup, code search) with no product-name hardwiring; remove product-specific references outright (srclight CLI troubleshooting commands, retired-service tier-table entries, `check_srclight()` probe and its startup message, `session-to-timeline` srclight normalizers, the README mcp-block srclight line). Preserve equivalent graceful-degradation unavailability fallback rows wherever they exist today.
- verify: The §3.2 deck sweep returns zero matches; spot-check genericized sites for capability-only wording and intact fallback rows.
- commit: `.opencode/` deck srclight purge.

### Item 9 (SC-9): Verify srclight-free tool-selection behavior (behavioral)

- RED: A behavioral run of a code-verification task (signature/blast-radius lookup) shows the agent attempting `srclight_*` tools — the stale tier-table/task-card guidance misroutes it.
- GREEN: Delivered by Item 8's genericized deck text (capability-class wording plus the built-in read/grep fallback). Behavioral item ordering per the incremental-build rule: Item 8's COMMIT and PUSH to the remote branch precede this behavioral run — a fresh `git fetch` verifies the effective commit is contained in a remote ref before the run executes.
- verify: An isolated opencode run on a code-verification task shows tool selection via available tooling or the built-in `read`/`grep` fallback, with zero `srclight_*` tool-call attempts in the session evidence.
- commit: None beyond Item 8's purge commit (this is the behavioral evidence item; evidence artifacts are recorded under `{project_root}/tmp/`).

### Item 10 (SC-10): Enforce semantic-instrument verification for RAGSync lifecycle SCs

- GREEN: A post-implementation verification audit confirming every behavioral SC verdict (SC-1..SC-7) cites a semantic instrument (session yaml from an isolated `with-test-home opencode run`, or live service log observation), with zero verdicts derived solely from static probe-poll scripts or string-only checks; plus a diff scan confirming no verification-stage commits touched `.opencode/tests-v2/**` or the files under test. Verification-stage side-effect commits (a harness fix and an unverified `{file:}` template rewrite) introduced by a prior verification sub-agent are reverted/repaired as part of this item's remediation.
- verify: The audit evidence artifact enumerates each SC with its instrument class (semantic vs static) and the diff scan result; any static-only verdict re-runs with the semantic instrument before PASS.
- commit: Evidence artifact under `{project_root}/tmp/` plus whatever remediation commits the audit mandates (e.g., revert of verification-stage side-effect commits).

## 7. Dependencies

| Reference | Relationship | Status |
|-----------|--------------|--------|
| `jsbroks/ragsync-mcp` | External MCP server adopted as-is; must be available and version-stable for the service to start. | Pending (external) |
| `fastembed` | Local embedding runtime; model `Qwen/Qwen3-Embedding-0.6B-Q` downloaded from the HF Hub on first run and cached locally by the embedding stack's standard runtime cache (not refetched on every service start); a retrieval failure is a hard fail for the RAG service (best-effort no-RAG session continuation). | Pending (external) |
| opencode MCP local-server registration | Required capability; confirmed present in `.opencode/opencode.jsonc` mcp block. | Satisfied |
| Existing MCP services (the-notebook-mcp, editor) | Unmodified; must continue to function alongside the new service. | Satisfied |
| Main repo `.gitmodules` registered submodule list | Authoritative source for the CON-8 corpus scope; currently registers exactly one submodule (`.opencode`). | Satisfied (verified) |
| Designated corpus directories (§3.1) | Live-verified enumeration of the reference source corpora declared in the RAGSync config (SC-3); verified against the working tree 2026-09-02. | Satisfied (verified) |
| Deck srclight footprint (§3.2) | Fresh exhaustive enumeration of deck files requiring the CON-10 purge (SC-8); enumerated 2026-09-24 via the §3.2 sweep command. | Satisfied (verified) |

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
| R-13 | SC-8, SC-9 | Phase 2 |
| R-14 | SC-8, SC-9 | Phase 2 |
| R-15 | SC-10 | Post (verification gate) |

## 9. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|--------------|
| opencode MCP config | config | `.opencode/opencode.jsonc` (mcp block) | Read via config file inspection; existing service pattern confirmed |
| RAGSync MCP server | code/external | `jsbroks/ragsync-mcp` | External tool; adopted as-is (CON-1) |
| fastembed embedding runtime | code/external | fastembed | Local runtime; model pinned by name only (`Qwen/Qwen3-Embedding-0.6B-Q`, verified in the fastembed model registry 2026-09-30) with local runtime caching of the downloaded weights (fastembed/HF Hub on-disk cache — caching is NOT pinning) and hard-fail unavailability semantics (CON-7) |
| RAGSync config | config | RAGSync config file (to be created) | Declared per-source layout, corpus scope, and auto-sync |
| `.opencode` skill/guideline tree | doc | `.opencode/skills/` or `.opencode/guidelines/` | Documentation file exists covering config, layout, usage |
| Main repo submodule list | config | `.gitmodules` (main repo root) | Verified 2026-09-01: registers exactly one submodule (`.opencode` → `michael-conrad/.opencode`); root `.issues/` and `.opencode/.issues/` are orphan-branch git worktrees, not registered submodules (CON-8) |
| §3.1 designated corpus directories | config/working-tree | main repo working tree; `.opencode/` submodule | Verified 2026-09-02 via `git ls-files` enumeration (parent: AGENTS.md, CHANGELOG.md, docs, README.md, skills; submodule: AGENTS.md, README.md, guidelines/, skills/, reference/, docs/) and RAGSync README source semantics (folder sources, gitignore-style include/exclude, per-source `vector_store.collection` namespaces) |
| Deck srclight footprint (§3.2) | working-tree | `.opencode/` deck tree | Verified 2026-09-24: `rg -i 'srclight' .opencode/ --hidden --no-ignore` (excluding `.opencode/.git/**`, `.opencode/.issues/**`) → 162 matches across 46 files; `reference/**` zero matches |

## 10. Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## 11. Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- SC-1: Verifying the `ragsync` service spawns and is registered costs one runtime launch with tool listing. Skipping means a malformed or missing registration isn't caught until opencode fails to load the service at startup — a config defect discovered at runtime rather than design time.
- SC-2: Verifying the fastembed local path with network monitoring costs one instrumented retrieval query plus one cache-warm observation. Skipping means an external embedding API dependency or a wrongly-named/unpinned model ships, producing an undeclared network dependency and a failure mode that is only discovered at first retrieval, or a model refetched on every service start goes unnoticed; the hard-fail unavailability run costs one additional block-run and verifies the failure semantics actually hold.
- SC-3: Verifying per-source isolation with a cross-source search costs one instrumented query pair. Skipping means cross-source retrieval leakage ships unchecked — copyrighted material from one corpus designated in §3.1 leaking into another's retrieval results is a data-integrity and provenance defect discovered only in downstream queries.
- SC-4: Verifying the per-source isolation review checklist exists costs one file read. Skipping means the isolation enforcement is undocumented, so a future operator cannot verify that cross-source leakage is prevented.
- SC-5: Verifying auto-sync via source-file modification and index-freshness observation costs one modification cycle. Skipping means a stale index ships, and the agent retrieves outdated content while believing it is current — a silent-correctness defect that surfaces as confidently-wrong answers.
- SC-6: Verifying the documentation file exists and covers the required topics costs one file read. Skipping means the config and registration drift apart undetected (CON-5), and the service's configuration and validation semantics are undocumented for the next operator.
- SC-7: Verifying the corpus scope via runtime indexed-source enumeration costs one enumeration pass. Skipping means the corpus scope is silently wrong — non-registered git sub-repos (the `.issues/` orphan-branch worktrees with their own issue-tracking content) enter retrieval, or intended main-repo/submodule coverage is missing — a provenance and data-integrity defect discovered only when retrieved content traces to an unintended source.
- SC-8: Verifying the deck purge with the §3.2 sweep costs one grep pass. Skipping means the retired service's tool names remain live instructions in agent-facing text — every agent consulting a task card or tier table is misrouted toward tools that no longer exist, and each future edit to those files propagates the stale references further.
- SC-9: Verifying srclight-free tool selection costs one isolated opencode run. Skipping means the purge is text-only — an agent following the genericized guidance could still fail to fall back to built-in tooling when no index tool is available, halting where graceful degradation should have kept it working.
- SC-10: Auditing the verification instruments across SC-1..SC-7 costs one evidence review plus one diff scan; re-running any static-only verdict costs one semantic run each. Skipping means hand-spawned probe scripts that poll a server's stdout are accepted as behavioral evidence — the exact regression that motivated this criterion — and verification-stage side-effect commits (harness edits, registration rewrites with unverified template semantics) survive to the PR.

## 12. Edge Cases

- **Input boundary — empty source directory:** If a declared source directory is empty, RAGSync SHALL produce an empty index for that source without failing other sources. Resolution: document per-source empty-handling in the review checklist.
- **Input boundary — new reference corpus appears in the working tree:** If a new agent-facing text corpus is added within the CON-8 surface (e.g., a new docs tree in the main repo), it SHALL be designated by adding a source section to the RAGSync config (the §3.1 designation authority); the review checklist's §3.1 topic criterion catches an undeclared corpus during review.
- **Failure mode — embedding model download fails on first run:** If fastembed cannot download the default model (`Qwen/Qwen3-Embedding-0.6B-Q`) — or the model is otherwise unavailable — the RAG MCP service SHALL hard-fail — no fallback model, no silent degradation, no masking of the failure — and the session SHALL continue best-effort WITHOUT RAG capability, with the model-availability failure surfaced honestly. On an ordinarily successful first run, the downloaded model is cached locally by the embedding stack's standard runtime cache (fastembed/HF Hub on-disk cache) and is not refetched on every service start. Resolution: pin the model by name only, keep the standard local runtime cache, and declare the hard-fail/no-RAG semantics (CON-7); no offline/cache-path contingency machinery is built.
- **Failure mode — malformed MCP registration:** If the `ragsync` entry is malformed, opencode SHALL reject the config rather than silently loading a broken service. Resolution: verify JSONC validity in the SC-1 verification step.
- **Failure mode — cross-source isolation misconfigured:** If per-source isolation is misconfigured, retrieval SHALL NOT leak material between corpora designated in §3.1. Resolution: enforce one config section per source designated in §3.1 and a review checklist (CON-6).
- **State transition — config drift:** If the RAGSync config and the opencode registration diverge, the agent may load a service pointing at stale configuration. Resolution: co-locate and validate both, and document the validation step (CON-5).
- **Concurrency — auto-sync during active retrieval:** If a source file changes while retrieval is in flight, RAGSync SHALL update the index without corrupting in-flight queries. Resolution: rely on RAGSync's auto-sync behavior; document that re-sync is non-destructive.
- **Input boundary — naive file walk encounters non-registered git sub-repos:** A naive recursive walk of the main repo encounters the `.issues/` orphan-branch worktrees (root and under `.opencode/`), which are git sub-repos but not registered submodules. RAGSync SHALL NOT index them absent an explicit carveout in the RAGSync config. Resolution: declare the corpus scope explicitly (main repo + registered submodule list) and verify via runtime indexed-source enumeration (CON-8, SC-7).
- **Failure mode — submodule list drift:** If the main repo registers a new submodule, the RAGSync corpus scope SHALL be updated to include it; coverage assertions in the SC-7 verification catch drift between `.gitmodules` and the declared corpus scope. Resolution: derive the corpus scope from the registered submodule list and re-verify on submodule changes (CON-8, SC-7).
- **Failure mode — genericized capability has no available tool:** A deck file references a generic capability (e.g., symbol/signature lookup or callers/callees/dependents blast-radius lookup) that no available local index tool provides at runtime. Resolution: the built-in `read`/`grep` fallback remains valid; the preserved graceful-degradation fallback row (CON-10) marks the affected evidence as file-path-only or unverified — do NOT BLOCK — rather than halting the task.
- **State transition — historical evidence artifacts reference srclight:** Behavioral-test evidence artifacts under `.opencode/.issues/**` legitimately contain historical `srclight_*` tool calls from past runs. Resolution: they are on the §3.2 sweep exclusion list and MUST NOT be rewritten — they are records of past work, not agent-facing instructions (CON-10).

## Change Control

| Date | What Changed | Why | Authorized By |
|------|--------------|-----|---------------|
| 2026-09-30 (SC-10) | Added SC-10 (semantic-instrument verification enforcement) with R-15, Item 10 (post gate), Traceability row R-15→SC-10, and a Cost Frame entry. Scope: all RAGSync lifecycle behavioral SCs (SC-1..SC-7) must be verified by semantic runtime analysis (isolated `with-test-home opencode run` sessions, live service log observation); static probe-poll scripts / string-only checks standing in for behavioral verdicts are EVIDENCE_TYPE_MISMATCH (= FAIL, re-verified semantically); verification sub-agents SHALL NOT modify harness files (`.opencode/tests-v2/**`) or files under test as side effects. Motivating regression (2026-09-30, SC-2 verify): a verification sub-agent substituted hand-spawned JSONRPC probe scripts that poll the server's stdout in static read loops for the prescribed semantic run, and landed two unverified side-effect commits — `26e0611e` (tests-v2 harness edit) and `73f3029f` (ragsync `--config` rewritten to a `{file:}` template; live run `a.err`-evidence shows ragsync received the literal template string, proving `{file:}` does not interpolate in mcp `command` args there). Substantive SC-set change (SC-1..SC-9 → SC-1..SC-10); prior plan approvals are treated per approval-gate-006 with the developer-directive exception (revoked and regenerated in-line under the active `for_pr` authorization). | Developer directive (2026-09-30): "subagent is doing static polling in violation of semantic analysis requirements. identify the regression, add an SC to deal with the regression, then implement the SC, then continue implementation." | Developer directive (2026-09-30, michael-conrad) |
| 2026-09-30 (SC-10 round 2) | SC-10 scope extended after a SECOND occurrence of the same regression class during SC-3 verification: (a) the verification sub-agent again substituted static probing/polling for the semantic instrument (SC-3 verify run produced no semantic evidence); (b) direct semantic inspection by the orchestrator exposed a live corpus-scope violation: the `opencode-agent-config` source path `../..` resolves against the config file's directory (`.opencode/`), landing on `/home/muksihs/git` and indexing 31 foreign repositories (1584 distinct files, including copyrighted material from sibling projects) into the `opencode_agent_config` collection — a CON-8 surface violation far exceeding the mandated boundary. Remediated: source path corrected to `..` (resolver-verified against the live RAGSync `AppConfig.from_yaml`), polluted `vector_db/` runtime state purged (gitignored), fix committed and pushed (`e0c2a3ec`). Instrument mandate tightened: SC-10 verdicts additionally require that cross-source/corpus-scope verification is performed by orchestrator-executed semantic inspection (live resolver + indexed-content enumeration against the CON-8 surface), not delegated-by-default. | Developer directive (2026-09-30): "the sub-agent is doing nothing but polling and is refusing to do semantic checks. this is a regression. create an SC to address the regression, implement the SC, then continue." | Developer directive (2026-09-30, michael-conrad) |
|------|--------------|-----|---------------|
| 2026-08-21 | Added Section 3 "Constraints" defining CON-1 through CON-7 and renumbered subsequent sections 3-11 to 4-12. | Validation finding: spec referenced CON-1..CON-7 across Sections 1, 2, 8, 10, 11 without defining them (Completeness / Internal-Consistency failure). | Spec-creation revision pipeline (validation remediation) |
| 2026-08-21 | Replaced exact line-number references "lines 101-136" with file-area references (`.opencode/opencode.jsonc` mcp block) in Intent field 2, SC-1 Documentation Sources, and Section 9. | Validation finding: exact line numbers violate spec-structure-standards.md "Prohibited Content Patterns"; file-area references required. | Spec-creation revision pipeline (validation remediation) |
| 2026-08-21 | Decomposed SC-3 into two atomic SCs: SC-3 (one config section per source with isolated index namespaces) and SC-4 (review checklist enforcing isolation). Renumbered former SC-4/SC-5 to SC-5/SC-6 and updated Items, Traceability, and Cost Frame references accordingly. | Validation finding: Compound-SC detection FAIL on SC-3 — it bundled two independently verifiable claims (per-source config sections; review checklist). | Spec-creation revision pipeline (validation remediation) |
| 2026-08-21 | Added requirement R-11 (review checklist enforcing per-source isolation) and mapped it to SC-4 in the Section 8 Traceability table. | Validation finding: Traceability FAIL — SC-4 was an orphan in the Section 8 Traceability table, tracing to no requirement (R-1..R-10). | Spec-creation revision pipeline (validation remediation) |
| 2026-09-02 | Corpus-scope sync revision per 2026-09-01 developer directive: added CON-8 (bounded corpus scope = main repo + registered submodule list; non-registered git sub-repos — concretely the `.issues/` orphan-branch worktrees at root and under `.opencode/` — excluded absent a declared carveout), SC-7 with behavioral evidence (runtime indexed-source enumeration), R-12, Item 7 (per-SC RED/GREEN/verify/commit), Not-Included entry for non-registered sub-repos, Dependencies/Documentation-Sources rows for the `.gitmodules` submodule list, Traceability row R-12→SC-7 Phase 1, Cost Frame entry for SC-7, two Edge Cases (naive-walk encounter; submodule list drift), and behavioral uplift of SC-1/SC-2/SC-3/SC-5 (runtime service spawn + tool listing, network-monitored retrieval, cross-source leakage search, index-freshness observation) with corresponding Items 1/2/3/5 verify-step updates. | Spec-audit finding: the 2026-09-01 corpus-scope revision existed only as a condensed summary in the remote GitHub issue body; the authoritative local spec was missing the full success criterion text, definitions, behavioral uplift notes, Item 7, Traceability/Cost-Frame/Edge-Case entries, and the Change Control row. Revision restores full parity with the remote revision content. | Developer directive (2026-09-01 corpus-scope revision) applied via spec-creation revise task; audit finding per michael-conrad/.opencode#2315 spec audit |
| 2026-09-02 | Added §3.1 "Reference Source Corpus Designation (CON-6 authority)": designated the RAGSync config's `sources` list as the authoritative corpus declaration mechanism and live-verified the initial corpus enumeration — two folder-type corpora (`opencode-agent-config` over the main repo working tree; `.opencode-deck` over the `.opencode/` submodule) with mandatory exclude globs (git internals, non-registered `.issues/` orphan-branch worktrees per CON-8, tool/cache/lock artifacts, binary model-qualification result sets), a non-corpora list, and the CON-8 interplay rule. Updated CON-6, SC-3, R-4, R-8, Item 3 GREEN, Cost Frame SC-3 entry, and the cross-source isolation Edge Case to reference §3.1; added Dependencies and Documentation-Sources rows for the designation; added the "new reference corpus appears" Edge Case; made SC-4/SC-6 verification methods state explicit topic-presence criteria instead of bare existence. | Validation FAIL (aggregate) — Completeness and Implementability dimensions: the central concept "reference source corpus" was used in CON-6, R-4, R-8, SC-3, SC-4, the Cost Frame, and Edge Cases but never defined, leaving Item 3 GREEN ("Declare one RAGSync config section per reference source corpus") unexecutable without guessing corpus locations. Non-blocking validator notes (artifacts directory absent — warning only; SC-4/SC-6 structural evidence with content-coverage verify methods) addressed by the explicit topic-presence criteria; the artifacts directory is created downstream by the writing-plans pipeline and needed no spec change. | Spec-creation revision pipeline (validation remediation) |
| 2026-09-24 | Removed srclight from this spec per developer directive (the intent is now to replace srclight with RAGSync MCP): corrected the stale Root Cause field 2 claim (the `mcp` block currently declares two local services — the-notebook-mcp, editor — verified 2026-09-24; srclight is already unregistered), updated the Not-Included "Modifying any existing MCP service" bullet to the-notebook-mcp and editor only, updated the Dependencies "Existing MCP services" row accordingly, added CON-9 (the retired srclight service SHALL NOT be re-registered; RAGSync replaces its role) with the developer rationale (recurring init failures and Python dependency conflicts; external embedding API dependency conflicting with the spec's local-embeddings direction; Python-only indexing vs the Java/C#/GDScript portfolio), and updated the §3.1 `.srclight/**` exclude-glob rationale (stale cache artifacts of the removed srclight service — the glob is kept so the `.srclight/` working-tree cache directory does not enter the RAG index). No SC, Item, Traceability, Cost Frame, or Edge Case changes — srclight is already unregistered so no removal implementation work exists; the replacement ban is a constraint, not a criterion. RAGSync implementation intent and scope are unchanged. | Developer directive (2026-09-24): remove srclight from this spec — replace srclight with RAGSync MCP. | Developer directive (2026-09-24, michael-conrad) |
| 2026-09-24 | Folded the deck-wide srclight reference purge into this spec (previously an external follow-up): added CON-10 (purge per disposition rule; no replacement product-name hardwiring in deck tool-selection text; graceful-degradation fallback preservation; §3.2 sweep exclusion list as the determinate sweep boundary), §3.2 (fresh exhaustive footprint enumeration — 162 matches across 46 files, reference/** verified zero matches — with the genericize/remove disposition rule, canonical capability mappings, fallback-preservation rule, determinate sweep exclusion list, and the `.srclight/` cache-directory not-included carveout), SC-8 (structural zero-match deck sweep) and SC-9 (behavioral srclight-free tool-selection run) with a deliberate evidence-type statement, R-13/R-14, Items 8-9 (Item 9 as the behavioral variant with commit+push preceding the behavioral run), Dependencies/Documentation-Sources rows for the §3.2 footprint, Traceability rows R-13/R-14 → SC-8/SC-9 Phase 2, Cost Frame entries for SC-8/SC-9, two Edge Cases (capability with no available tool; historical evidence artifacts on the exclusion list), the "deck-wide srclight references out of scope" framing removed from the mirrored exec summary, and a renamed title: "Adopt RAGSync MCP as default retrieval service and retire srclight (deck purge)". Substantive SC-set change: per approval-gate-006 the linked plan approvals are REVOKED (recorded as a `plan_approval_revoked` lifecycle event in plan.md; plan content revision is a separate downstream writing-plans dispatch). | Developer directive (2026-09-24, second round): the deck must be purged of srclight references — genericized to capability-class wording where the capability mapping has value, removed outright where it does not; tool-site judgment delegated to agent intelligence. | Developer directive (2026-09-24, second round, michael-conrad) |
| 2026-09-30 | Embedded-model selection revision per developer directives (2026-09-30, three messages, single revision round): (1) pinned the model by name only — CON-7 rewritten to name the pinned default local model `Qwen/Qwen3-Embedding-0.6B-Q` (fastembed model name, provider fastembed; verified live in the fastembed model registry 2026-09-30) and to forbid everything beyond the name (no HF revision pin, no SHA-256 checksums, no integrity ledger); weights are NOT committed to the repo (1.12 GB single int8 blob, GitHub 100 MiB block / LFS territory — out of scope); (2) hard-fail failure semantics — an unavailable embedding model is a HARD FAIL for the RAG MCP service (no fallback model, no silent degradation, no masking; session continues best-effort WITHOUT RAG capability with the failure surfaced honestly); (3) superseded by the caching-≠-pinning row below — this round's offline/cache-path-machinery removal is recorded with its full rationale there. | Developer directives (2026-09-30): pin nothing beyond the name (developer accepts HF Hub as the permanently-available model source; extra pins make the config brittle) and make model unavailability a hard fail with best-effort no-RAG session continuation. | Developer directives (2026-09-30, three messages, michael-conrad) |
| 2026-09-30 | Caching-≠-pinning revision per the final consolidated developer directives (2026-09-30): (1) corrected the prior round's overreach that treated local caching as dropped mitigation — local runtime caching is DISTINCT from pinning and is KEPT: after the first successful HF Hub download the model weights live in the embedding stack's standard on-disk model cache (fastembed/HF Hub local cache directory) and are not refetched on every service start; (2) only the heavyweight offline/cache-path contingency machinery (documented offline cache-prefill procedures, cache-path contingency planning) is dropped; (3) re-affirmed the name-only pin (`Qwen/Qwen3-Embedding-0.6B-Q`, provider fastembed; no HF revision pin, no SHA-256 checksums, no integrity ledger; weights NOT committed to the repo — 1.12 GB int8 blob) and the hard-fail semantics (model unavailability = HARD FAIL for the RAG MCP service, no fallback/no silent degradation/no masking; session continues best-effort WITHOUT RAG capability with the failure surfaced honestly; no failure-reporting paperwork). Updated: CON-7 (rewritten: name-only pin + kept local cache + hard-fail semantics), R-10 (cache clause added), SC-2 (criterion gains the local-cache clause and the verify method gains a cache-warm refetch observation — behavioral, NOT lobotomized; offline-path clause dropped), Item 2 GREEN/verify (cache wording + cache-warm observation), Cost Frame SC-2 entry (cache-warm observation), the Edge Case "embedding model download fails on first run" (hard-fail/best-effort-no-RAG semantics with the on-success cache statement), Not-Included entries (pinning-beyond-name and mitigation-machinery rows now distinguish offline/cache-path contingency machinery from kept runtime caching; weights row notes runtime download into the local cache), Intent field 3 and Key Decisions (b) (cache retained, contingency machinery excluded), SC-6 documentation topics (offline/cache-path topic replaced by local model-cache behavior), the Dependencies and Documentation-Sources fastembed rows, and the mirrored remote exec summary. No corpus-scope, per-source-isolation, or srclight-purge changes — those sections are untouched beyond consistency. No SC added or removed — SC set remains SC-1..SC-9; the SC-set anchor used by approval-gate-006 is unchanged, but this directive set is a substantive revision of SC-2 wording, so linked plan approvals are treated per the developer-directive exception to approval-gate-006 (recorded in the plan lifecycle events). | Developer directives (2026-09-30, final consolidated set): caching is NOT pinning — keep local caching so the model does not refetch on every service start; drop only the offline/cache contingency machinery; the name is the whole pin and hard-fail semantics keep the service honest. | Developer directives (2026-09-30, final consolidated set, michael-conrad) |

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
🤖 Co-authored with AI: OpenCode (ollama-cloud/glm-5.3-flash)
