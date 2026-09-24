---
number: 2315
title: "[SPEC] Adopt RAGSync MCP as default retrieval service and retire srclight (deck purge)"
status: open
labels:
- needs-approval
- spec-draft
created: 2026-08-21T14:54:28Z
updated: 2026-09-24T05:30:02Z
remote_issue: 2315
remote_url: "https://github.com/michael-conrad/.opencode/issues/2315"
promoted_at: 2026-08-23T21:00:00Z
promotion_type: retroactive_import
last_sync: 2026-09-24T05:30:02Z
author: michael-conrad
---

# Spec: Adopt RAGSync MCP as default retrieval service and retire srclight (deck purge)

## 1. Intent and Executive Summary

| # | Field | Description |
|---|-------|-------------|
| 1 | **Problem Statement** | The opencode agent has no default Retrieval-Augmented Generation (RAG) service for querying the locally-maintained corpus of non-tracked, copyright-sensitive reference and research documentation. It relies on live web search for verification and cannot retrieve grounded content from that corpus without leaking source material into the tracked repository. |
| 2 | **Root Cause / Motivation** | The `.opencode/opencode.jsonc` `mcp` block currently declares two local services (the-notebook-mcp, editor) — verified 2026-09-24 — but no RAG service. The retired srclight service was the nearest prior neighbor for this role (a local code-indexing service) and has been replaced: per developer directive (2026-09-24) it is retired because it suffered recurring init failures and Python dependency conflicts, depended on an external embedding API (conflicting with this spec's local-embeddings direction), and indexed Python code only, while the developer's repos also include Java, C#, and Godot script (GDScript), which srclight cannot index. RAGSync replaces srclight's role (CON-9). Additionally, per developer directive (2026-09-24, second round), the deck (the `.opencode/` submodule skill/guideline tree) still carries agent-facing instruction text referencing the retired service — a fresh exhaustive enumeration (2026-09-24, §3.2) found 162 srclight matches across 46 deck files — and agent-facing instructions must not direct agents toward a retired service. The agent needs a config-driven RAG backend that indexes a non-tracked corpus with auto-sync, local embeddings, per-source isolation, and a bounded indexing corpus scope, while keeping the copyrighted source material out of the tracked tree, plus a deck tree free of srclight references. |
| 3 | **Approach Chosen** | Adopt the RAGSync MCP server (`jsbroks/ragsync-mcp`) as-is and register it declaratively as a default local stdio MCP service in `.opencode/opencode.jsonc`, following the existing `type: local` / `stdio` / `uvx` pattern. RAGSync is configured via a config file that declares the reference source corpora per the §3.1 designation and the corpus scope, fastembed embedding settings with a pinned default model, auto-sync behavior, and per-source isolation with isolated index namespaces. In the deck tree, srclight references are purged per the §3.2 disposition rule: genericized to capability-class wording (symbol/signature lookup, callers/callees/dependents blast-radius lookup, code search) where the capability mapping has value, removed outright where it does not (e.g., product-specific CLI troubleshooting commands), with graceful-degradation unavailability fallbacks preserved and no replacement product-name hardwiring (CON-10). |
| 4 | **Alternatives Considered & Why Discarded** | Building a bespoke/custom RAG implementation was considered and rejected because it duplicates an existing, maintained tool and adds in-repo maintenance and security surface for no functional gain. The RAGSync server is adopted as-is per constraint CON-1. Leaving the deck's srclight references in place until each consumer file is next edited was considered and rejected because stale instruction text actively misroutes agents toward a retired service; a one-time deck-wide purge (CON-10) removes the coupling defect at once instead of spreading it across future edits. |
| 5 | **Key Design Decisions** | (a) Register RAGSync as a default-on (`enabled: true`) local service so the agent gets RAG capability without per-session setup; tradeoff: one additional service loads at startup. (b) Use local embeddings via fastembed with a pinned default model; tradeoff: no external embedding API dependency at the cost of a first-run model download (mitigated by a documented offline/cache path). (c) Enforce per-source isolation with one config section per source; tradeoff: more config boilerplate in exchange for preventing cross-source retrieval leakage. (d) Bound the indexing corpus scope to the main repo plus its registered git submodules, excluding non-registered git sub-repos absent an explicit carveout; tradeoff: explicit scope enumeration in the config in exchange for preventing silently-indexed foreign git sub-repos. (e) Designate the RAGSync config's `sources` list as the authoritative declaration of the reference source corpora (§3.1), with two live-verified initial corpora — one over the main repo's tracked agent-facing text, one over the `.opencode/` submodule deck; tradeoff: explicit per-corpus config sections in exchange for a determinate, guess-free source set that two implementors would declare identically. (f) Purge deck srclight references with a two-disposition rule (§3.2) — genericize where capability wording has value, remove where it does not — with per-site judgment delegated to the implementor; tradeoff: judgment-based dispositions require per-site review in exchange for keeping procedures portable across any available index tooling without recreating product-name coupling. |
| 6 | **User Intent / Original Prompt** | Add RAGSync MCP as a default MCP service for opencode, configured with local embeddings, per-source isolation, auto-sync, a bounded corpus scope (main repo + registered submodules only), and documentation in the `.opencode` skill/guideline tree. Revision rounds (2026-09-24): the first round retired srclight in favor of RAGSync (CON-9); the second round folded the deck-wide srclight reference purge into this spec's scope (CON-10, §3.2) — no longer an external follow-up. |

## 2. Not Included

- **Ingesting or tracking the actual copyright-sensitive reference material in the repository** — the source corpus remains non-tracked (CON-2); the spec only configures retrieval over it.
- **Building a bespoke/custom RAG implementation** — RAGSync is adopted as-is (CON-1).
- **Backfilling existing research cards or dictionaries into the RAG index** — no historical material is re-indexed (CON-3).
- **Any changes to the root `snea-phonetics` repo's `.issues/` tree** — this spec is scoped to the `.opencode` repo (CON-4).
- **Modifying any existing MCP service** (the-notebook-mcp, editor) — the change is purely additive for the currently-registered services. The srclight service is already unregistered (verified 2026-09-24); its removal is recorded here, not protected — re-registration is prohibited by CON-9.
- **Indexing git sub-repos that are not registered submodules** — e.g., the `.issues/` orphan-branch worktrees at the root repo and under `.opencode/` are excluded from the index unless a special carveout is declared in the RAGSync config (CON-8).
- **Deleting the `.srclight/` working-tree cache directory** — file deletion is a destructive operation requiring separate, explicit authorization; the §3.1 `.srclight/**` exclude glob already keeps the stale cache out of the RAG index. Only the deck-tree references to srclight are purged in this spec.

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
| CON-7 | The embedding model SHALL have a pinned default local model and a documented offline/cache path. | Mitigates first-run embedding model download failure. |
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
| SC-2 | RAGSync SHALL be configured to use local embeddings via `fastembed` with a pinned default local embedding model and no external embedding API dependency. | behavioral | Run a network-monitored retrieval query through the fastembed local path and confirm no external embedding API call is made; confirm the config references `fastembed` and a pinned default local model. | RAGSync config file; fastembed runtime; network-monitor output |
| SC-3 | Per-source isolation SHALL be configured with exactly one config section per reference source corpus designated in §3.1, with isolated index namespaces. | behavioral | Run a cross-source search asserting no retrieval leakage between corpus namespaces; confirm the config declares one section per source designated in §3.1 with isolated index namespaces. | RAGSync config file; §3.1 corpus designation; cross-source search output |
| SC-4 | A review checklist SHALL be documented that enforces per-source isolation. | structural | A review checklist exists in the `.opencode` tree and contains, at minimum, these topic-presence criteria: one config section per source designated in §3.1, isolated index namespaces, and empty-source handling. | `.opencode/` skills/guidelines tree; review checklist; §3.1 corpus designation |
| SC-5 | Auto-sync SHALL be enabled so the index updates on source file changes without manual re-indexing. | behavioral | Modify a source file, observe index freshness without manual re-indexing, and confirm the config enables auto-sync for each declared source. | RAGSync config file; RAGSync sync behavior; index-freshness observation |
| SC-6 | The service configuration, per-source layout, usage, offline/cache path, and validation step SHALL be documented in the `.opencode` skill/guideline tree. | structural | A documentation file exists in the `.opencode` tree and contains, at minimum, these topic-presence criteria: service configuration, per-source layout per §3.1, usage, offline/cache path, and validation. | `.opencode/` skills/guidelines tree; §3.1 corpus designation |
| SC-7 | The indexing corpus scope SHALL cover all files in the main repo plus every git submodule in the main repo's registered submodule list; git sub-repos that are not registered submodules SHALL NOT be indexed unless a special carveout is declared in the RAGSync config. | behavioral | Enumerate indexed sources at runtime and assert main-repo and registered-submodule coverage with non-registered sub-repos (e.g., the `.issues/` orphan-branch worktrees) excluded absent a carveout. | RAGSync config corpus scope; `.gitmodules` registered submodule list; runtime indexed-source enumeration |
| SC-8 | The `.opencode/` deck tree SHALL contain zero srclight references: every reference enumerated in §3.2 is either removed outright or genericized to capability-class wording per the §3.2 disposition rule, with the §3.2 sweep exclusion list as the determinate sweep boundary. | structural | Run the §3.2 deck sweep (`rg -i 'srclight' .opencode/ --hidden --no-ignore` with the §3.2 exclusions) and assert zero matches; spot-check genericized sites for capability-only wording (no product name). | §3.2 footprint enumeration; deck sweep output; CON-10 |
| SC-9 | Agent tool-selection behavior SHALL be srclight-free: when a task requires symbol/signature lookup, callers/callees/dependents blast-radius analysis, or code search, the agent SHALL use available tooling or the built-in `read`/`grep` fallback per the genericized deck text and SHALL NOT attempt `srclight_*` tools. | behavioral | An isolated opencode run on a code-verification task (signature/blast-radius lookup) shows the agent selecting available tooling or the built-in read/grep fallback, with zero `srclight_*` tool-call attempts in the session evidence. | Genericized deck text; opencode run session evidence; CON-10 |

**Evidence-type statement (deliberate):** SC-8 is a text-state criterion and is verified structurally (zero-match sweep). SC-9 claims a change to agent tool-selection behavior, which is runtime-behavioral; per the evidence-type uplift rule its evidence is behavioral (an opencode run), not the structural sweep — the sweep alone would be EVIDENCE_TYPE_MISMATCH for the behavior claim.

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
- R-13. Srclight references in the `.opencode/` deck tree SHALL be removed outright or genericized to capability-class wording per the §3.2 disposition rule (CON-10), preserving graceful-degradation unavailability fallbacks in genericized text.
- R-14. Genericized deck tool-selection text SHALL name capabilities, not products — no `ragsync` (or other replacement-product) naming in deck tool-selection text.

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

## 7. Dependencies

| Reference | Relationship | Status |
|-----------|--------------|--------|
| `jsbroks/ragsync-mcp` | External MCP server adopted as-is; must be available and version-stable for the service to start. | Pending (external) |
| `fastembed` | Local embedding runtime; model downloaded on first run with offline/cache path mitigation. | Pending (external) |
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
| Deck srclight footprint (§3.2) | working-tree | `.opencode/` deck tree | Verified 2026-09-24: `rg -i 'srclight' .opencode/ --hidden --no-ignore` (excluding `.opencode/.git/**`, `.opencode/.issues/**`) → 162 matches across 46 files; `reference/**` zero matches |

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
- SC-8: Verifying the deck purge with the §3.2 sweep costs one grep pass. Skipping means the retired service's tool names remain live instructions in agent-facing text — every agent consulting a task card or tier table is misrouted toward tools that no longer exist, and each future edit to those files propagates the stale references further.
- SC-9: Verifying srclight-free tool selection costs one isolated opencode run. Skipping means the purge is text-only — an agent following the genericized guidance could still fail to fall back to built-in tooling when no index tool is available, halting where graceful degradation should have kept it working.

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
- **Failure mode — genericized capability has no available tool:** A deck file references a generic capability (e.g., symbol/signature lookup or callers/callees/dependents blast-radius lookup) that no available local index tool provides at runtime. Resolution: the built-in `read`/`grep` fallback remains valid; the preserved graceful-degradation fallback row (CON-10) marks the affected evidence as file-path-only or unverified — do NOT BLOCK — rather than halting the task.
- **State transition — historical evidence artifacts reference srclight:** Behavioral-test evidence artifacts under `.opencode/.issues/**` legitimately contain historical `srclight_*` tool calls from past runs. Resolution: they are on the §3.2 sweep exclusion list and MUST NOT be rewritten — they are records of past work, not agent-facing instructions (CON-10).

## Change Control

| Date | What Changed | Why | Authorized By |
|------|--------------|-----|---------------|
| 2026-08-21 | Added Section 3 "Constraints" defining CON-1 through CON-7 and renumbered subsequent sections 3-11 to 4-12. | Validation finding: spec referenced CON-1..CON-7 across Sections 1, 2, 8, 10, 11 without defining them (Completeness / Internal-Consistency failure). | Spec-creation revision pipeline (validation remediation) |
| 2026-08-21 | Replaced exact line-number references "lines 101-136" with file-area references (`.opencode/opencode.jsonc` mcp block) in Intent field 2, SC-1 Documentation Sources, and Section 9. | Validation finding: exact line numbers violate spec-structure-standards.md "Prohibited Content Patterns"; file-area references required. | Spec-creation revision pipeline (validation remediation) |
| 2026-08-21 | Decomposed SC-3 into two atomic SCs: SC-3 (one config section per source with isolated index namespaces) and SC-4 (review checklist enforcing isolation). Renumbered former SC-4/SC-5 to SC-5/SC-6 and updated Items, Traceability, and Cost Frame references accordingly. | Validation finding: Compound-SC detection FAIL on SC-3 — it bundled two independently verifiable claims (per-source config sections; review checklist). | Spec-creation revision pipeline (validation remediation) |
| 2026-08-21 | Added requirement R-11 (review checklist enforcing per-source isolation) and mapped it to SC-4 in the Section 8 Traceability table. | Validation finding: Traceability FAIL — SC-4 was an orphan in the Section 8 Traceability table, tracing to no requirement (R-1..R-10). | Spec-creation revision pipeline (validation remediation) |
| 2026-09-02 | Corpus-scope sync revision per 2026-09-01 developer directive: added CON-8 (bounded corpus scope = main repo + registered submodule list; non-registered git sub-repos — concretely the `.issues/` orphan-branch worktrees at root and under `.opencode/` — excluded absent a declared carveout), SC-7 with behavioral evidence (runtime indexed-source enumeration), R-12, Item 7 (per-SC RED/GREEN/verify/commit), Not-Included entry for non-registered sub-repos, Dependencies/Documentation-Sources rows for the `.gitmodules` submodule list, Traceability row R-12→SC-7 Phase 1, Cost Frame entry for SC-7, two Edge Cases (naive-walk encounter; submodule list drift), and behavioral uplift of SC-1/SC-2/SC-3/SC-5 (runtime service spawn + tool listing, network-monitored retrieval, cross-source leakage search, index-freshness observation) with corresponding Items 1/2/3/5 verify-step updates. | Spec-audit finding: the 2026-09-01 corpus-scope revision existed only as a condensed summary in the remote GitHub issue body; the authoritative local spec was missing the full success criterion text, definitions, behavioral uplift notes, Item 7, Traceability/Cost-Frame/Edge-Case entries, and the Change Control row. Revision restores full parity with the remote revision content. | Developer directive (2026-09-01 corpus-scope revision) applied via spec-creation revise task; audit finding per michael-conrad/.opencode#2315 spec audit |
| 2026-09-02 | Added §3.1 "Reference Source Corpus Designation (CON-6 authority)": designated the RAGSync config's `sources` list as the authoritative corpus declaration mechanism and live-verified the initial corpus enumeration — two folder-type corpora (`opencode-agent-config` over the main repo working tree; `.opencode-deck` over the `.opencode/` submodule) with mandatory exclude globs (git internals, non-registered `.issues/` orphan-branch worktrees per CON-8, tool/cache/lock artifacts, binary model-qualification result sets), a non-corpora list, and the CON-8 interplay rule. Updated CON-6, SC-3, R-4, R-8, Item 3 GREEN, Cost Frame SC-3 entry, and the cross-source isolation Edge Case to reference §3.1; added Dependencies and Documentation-Sources rows for the designation; added the "new reference corpus appears" Edge Case; made SC-4/SC-6 verification methods state explicit topic-presence criteria instead of bare existence. | Validation FAIL (aggregate) — Completeness and Implementability dimensions: the central concept "reference source corpus" was used in CON-6, R-4, R-8, SC-3, SC-4, the Cost Frame, and Edge Cases but never defined, leaving Item 3 GREEN ("Declare one RAGSync config section per reference source corpus") unexecutable without guessing corpus locations. Non-blocking validator notes (artifacts directory absent — warning only; SC-4/SC-6 structural evidence with content-coverage verify methods) addressed by the explicit topic-presence criteria; the artifacts directory is created downstream by the writing-plans pipeline and needed no spec change. | Spec-creation revision pipeline (validation remediation) |
| 2026-09-24 | Removed srclight from this spec per developer directive (the intent is now to replace srclight with RAGSync MCP): corrected the stale Root Cause field 2 claim (the `mcp` block currently declares two local services — the-notebook-mcp, editor — verified 2026-09-24; srclight is already unregistered), updated the Not-Included "Modifying any existing MCP service" bullet to the-notebook-mcp and editor only, updated the Dependencies "Existing MCP services" row accordingly, added CON-9 (the retired srclight service SHALL NOT be re-registered; RAGSync replaces its role) with the developer rationale (recurring init failures and Python dependency conflicts; external embedding API dependency conflicting with the spec's local-embeddings direction; Python-only indexing vs the Java/C#/GDScript portfolio), and updated the §3.1 `.srclight/**` exclude-glob rationale (stale cache artifacts of the removed srclight service — the glob is kept so the `.srclight/` working-tree cache directory does not enter the RAG index). No SC, Item, Traceability, Cost Frame, or Edge Case changes — srclight is already unregistered so no removal implementation work exists; the replacement ban is a constraint, not a criterion. RAGSync implementation intent and scope are unchanged. | Developer directive (2026-09-24): remove srclight from this spec — replace srclight with RAGSync MCP. | Developer directive (2026-09-24, michael-conrad) |
| 2026-09-24 | Folded the deck-wide srclight reference purge into this spec (previously an external follow-up): added CON-10 (purge per disposition rule; no replacement product-name hardwiring in deck tool-selection text; graceful-degradation fallback preservation; §3.2 sweep exclusion list as the determinate sweep boundary), §3.2 (fresh exhaustive footprint enumeration — 162 matches across 46 files, reference/** verified zero matches — with the genericize/remove disposition rule, canonical capability mappings, fallback-preservation rule, determinate sweep exclusion list, and the `.srclight/` cache-directory not-included carveout), SC-8 (structural zero-match deck sweep) and SC-9 (behavioral srclight-free tool-selection run) with a deliberate evidence-type statement, R-13/R-14, Items 8-9 (Item 9 as the behavioral variant with commit+push preceding the behavioral run), Dependencies/Documentation-Sources rows for the §3.2 footprint, Traceability rows R-13/R-14 → SC-8/SC-9 Phase 2, Cost Frame entries for SC-8/SC-9, two Edge Cases (capability with no available tool; historical evidence artifacts on the exclusion list), the "deck-wide srclight references out of scope" framing removed from the mirrored exec summary, and a renamed title: "Adopt RAGSync MCP as default retrieval service and retire srclight (deck purge)". Substantive SC-set change: per approval-gate-006 the linked plan approvals are REVOKED (recorded as a `plan_approval_revoked` lifecycle event in plan.md; plan content revision is a separate downstream writing-plans dispatch). | Developer directive (2026-09-24, second round): the deck must be purged of srclight references — genericized to capability-class wording where the capability mapping has value, removed outright where it does not; tool-site judgment delegated to agent intelligence. | Developer directive (2026-09-24, second round, michael-conrad) |

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
