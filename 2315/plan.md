---
plan_schema_version: "1.0"
issue: 2315
title: "Adopt RAGSync MCP as default retrieval service and retire srclight (deck purge)"
authorization_scope: for_implementation
pr_strategy: stacked
phase_count: 2
---

# Implementation Plan — #2315 — Adopt RAGSync MCP as default retrieval service and retire srclight (deck purge)

Issue: https://github.com/michael-conrad/.opencode/issues/2315

**Goal:** Register the RAGSync MCP server as a default-on local stdio service in `.opencode/opencode.jsonc`, configure it with local fastembed embeddings, per-source isolation, auto-sync, and a bounded indexing corpus scope, document the configuration, usage, and validation in the `.opencode` tree, and purge srclight references from the `.opencode/` deck tree per the §3.2 disposition rule with behavioral verification of srclight-free tool selection.

**Architecture:** Adopt RAGSync (`jsbroks/ragsync-mcp`) as-is per CON-1. Add a declarative `ragsync` service entry to the `.opencode/opencode.jsonc` `mcp` block following the existing `type: local` / `stdio` / `uvx` pattern (CON-2 keeps the corpus non-tracked). Create a RAGSync config file co-located with the registration (CON-5) whose `sources` list is the authoritative designation of the reference source corpora per spec §3.1 — one folder-type source per designated corpus (`opencode-agent-config` over the main repo working tree; `.opencode-deck` over the `.opencode/` submodule) with isolated index namespaces (CON-6), fastembed with a pinned default local model and no external embedding API (CON-7), auto-sync per source, and a bounded corpus scope covering all main-repo files plus every registered submodule while excluding non-registered git sub-repos absent a declared carveout (CON-8). Document service config, per-source layout per §3.1, usage, offline/cache path, and validation in the `.opencode` skill/guideline tree, plus a review checklist enforcing per-source isolation. In the deck tree, srclight references are purged per the §3.2 disposition rule (CON-10): genericized to capability-class wording where the capability mapping has value, removed outright where it does not, with graceful-degradation unavailability fallbacks preserved and no replacement-product naming in tool-selection text (CON-10, R-14); SC-9 verifies the purge behaviorally via an isolated opencode run that executes only after the purge commit is pushed and fresh-fetch-verified.

**Files:**
- `.opencode/opencode.jsonc` (mcp block — additive `ragsync` service entry)
- `.opencode/` RAG-Sync config file (new)
- `.opencode/` review checklist / documentation (new)
- `.opencode/` deck tree — srclight reference purge (§3.2 sweep scope: `guidelines/`, `skills/`, `tools/`, `README.md`; `reference/**` verified zero matches)

---

## Phase Table

| Phase | Skill | Task | Target | SCs | Depends On |
|-------|-------|------|--------|-----|------------|
| 1 — Configuration and registration work | `test-driven-development` | `red` | `.opencode/opencode.jsonc`, RAG-Sync config file, review checklist | SC-1, SC-2, SC-3, SC-4, SC-5, SC-7 | — |
| 2 — Documentation and deck-purge work | `test-driven-development` | `red` | `.opencode/` skill/guideline tree, deck srclight purge (§3.2 sweep scope) | SC-6, SC-8, SC-9 | 1 |

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

### Phase 2 — Documentation and deck-purge work

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/` skill/guideline tree, deck srclight purge (§3.2 sweep scope) |
| SCs | SC-6, SC-8, SC-9 |
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
deck_purge:
  sweep_command: "rg -i 'srclight' .opencode/ --hidden --no-ignore"
  sweep_exclusions: [".opencode/.git/**", ".opencode/.issues/**", "node_modules/**", "tmp/**", ".pytest_cache/**", ".ruff_cache/**"]
  footprint_baseline: "162 matches across 46 files (§3.2, enumerated 2026-09-24)"
  disposition_rule: "per-site genericize-or-remove per §3.2"
  product_name_rule: "no ragsync or replacement-product naming in deck tool-selection text (CON-10, R-14)"
  fallback_preservation: "equivalent graceful-degradation unavailability fallback rows preserved (CON-10)"
behavioral_verification_sc9:
  task_type: "code-verification (signature/blast-radius lookup)"
  red_state: "pre-purge deck (srclight references active)"
  green_delivery: "Item 8 genericized deck text + built-in read/grep fallback"
  ordering_gate: "Item 8 COMMIT + PUSH + fresh-fetch remote-ref containment precede the SC-9 verify run"
  evidence_artifacts: "{project_root}/tmp/"
```

**Procedure:**
1. Confirm Phase 1 is complete and its VbC passed (SC-1..SC-5, SC-7 clean PASS) before starting Phase 2 work.
2. **Item 6 (SC-6)** — Pre-clean stale artifacts, then run RED (assert RAGSync documentation file absent) → GREEN (write documentation covering service configuration, per-source layout per §3.1, corpus scope, usage, offline/cache path, validation step) → post-regression → verify (structural with explicit topic-presence criteria) → commit the documentation change.
3. **Item 9 RED (SC-9, behavioral, pre-purge)** — run the behavioral RED before the purge lands: an isolated opencode run on a code-verification task (signature/blast-radius lookup) against the deck state that still carries srclight references, asserting zero `srclight_*` tool-call attempts in the session evidence; the assertion fails (the stale tier-table/task-card guidance misroutes the agent into `srclight_*` attempts), which is the RED evidence.
4. **Item 8 (SC-8)** — RED (run the §3.2 deck sweep and assert the 162-match/46-file footprint is present) → GREEN (apply the §3.2 disposition rule per site across all 46 enumerated files: genericize capability-bearing references to capability-class wording with no product-name hardwiring; remove product-specific references outright; preserve equivalent graceful-degradation unavailability fallback rows) → post-regression → verify (structural: the §3.2 sweep returns zero matches; spot-check genericized sites for capability-only wording and intact fallback rows) → commit the purge → push the commit to its remote branch → fresh `git fetch` verifying the effective commit is contained in a remote ref (behavioral-item ordering gate before the SC-9 verify run).
5. **Item 9 verify (SC-9, behavioral, post-purge)** — an isolated opencode run on a code-verification task shows tool selection via available tooling or the built-in `read`/`grep` fallback, with zero `srclight_*` tool-call attempts in the session evidence (evidence artifacts recorded under `{project_root}/tmp/`).
6. Run the **Phase 2 VbC** (clean-room) verifying SC-6, SC-8, and SC-9 are all clean PASS.

---

## Exit Criteria

- [ ] C1. SC-1 PASS: `ragsync` service registered in `.opencode/opencode.jsonc` mcp block with `type: local`, `stdio`, `enabled: true` (behavioral: service spawns and lists tools).
- [ ] C2. SC-2 PASS: RAG-Sync configured with fastembed local embeddings, pinned default model, no external embedding API (behavioral: network-monitored retrieval).
- [ ] C3. SC-3 PASS: Per-source isolation configured — exactly one config section per §3.1-designated source with isolated index namespaces (behavioral: cross-source search, no leakage).
- [ ] C4. SC-4 PASS: Review checklist documented in `.opencode` tree enforcing per-source isolation with the topic-presence criteria (one config section per §3.1-designated source, isolated index namespaces, empty-source handling).
- [ ] C5. SC-5 PASS: Auto-sync enabled for each declared source (behavioral: index-freshness observation).
- [ ] C6. SC-6 PASS: Documentation exists in `.opencode` tree covering config, per-source layout per §3.1, corpus scope, usage, offline/cache path, validation (structural with explicit topic-presence criteria).
- [ ] C7. SC-7 PASS: Corpus scope bounded to all main-repo files plus every registered submodule; non-registered git sub-repos excluded absent a declared carveout (behavioral: runtime indexed-source enumeration).
- [ ] C8. SC-8 PASS: The `.opencode/` deck tree contains zero srclight references — every §3.2-enumerated reference removed outright or genericized to capability-class wording per the §3.2 disposition rule, with the §3.2 sweep exclusion list as the determinate sweep boundary (structural: zero-match deck sweep).
- [ ] C9. SC-9 PASS: Agent tool-selection behavior is srclight-free — an isolated opencode run on a code-verification task shows tool selection via available tooling or the built-in `read`/`grep` fallback, with zero `srclight_*` tool-call attempts in the session evidence (behavioral).

---

## Pre-Flight Guard (Mandatory)

Check your tool list for a tool named `task`.

- Present ⇒ orchestrator — proceed.
- Absent ⇒ sub-agent — do NOT execute any instruction below. Return `BLOCKED` with `ORCHESTRATOR_ONLY_SKILL_CARD` (cards) or `ORCHESTRATOR_ONLY_PLAN` (plans) and halt.

---

## Lifecycle Events

| Timestamp | Event | Details |
|-----------|-------|---------|
| 2026-08-24T13:02:22Z | `plan_created` | Plan file `.opencode/.issues/2315/plan.md` verified, phase count = 2 |
| 2026-09-02T03:01:25Z | `spec_revision` | Spec #2315 revised (corpus-scope sync per 2026-09-01 developer directive): CON-8/R-12/SC-7 added, SC-1/2/3/5 uplifted to behavioral evidence |
| 2026-09-02T03:01:25Z | `plan_revised` | Plan regenerated against revised spec SC set: SC-7 added to Phase 1 (Item 7), behavioral verify steps added to Items 1/2/3/5, corpus scope added to documentation topics, Exit Criteria C7 added |
| 2026-09-02T03:41:00Z | `plan_revised` | Plan regenerated against spec revised with §3.1 Reference Source Corpus Designation: Architecture and Phase 1 context updated with the two §3.1-designated corpora (`opencode-agent-config`, `.opencode-deck`) and their include/exclude globs, Item 3 GREEN names the designated corpora, Items 4/6 verification updated to explicit topic-presence criteria, documentation topics reference §3.1 per-source layout |
| 2026-09-24T04:48:39Z | `spec_revision` | Spec #2315 revised per 2026-09-24 developer directive (srclight retirement — RAGSync replaces srclight): Root Cause field 2 corrected (mcp block declares the-notebook-mcp + editor only; srclight already unregistered), Not-Included "Modifying any existing MCP service" bullet and Dependencies row updated, CON-9 added (srclight SHALL NOT be re-registered), §3.1 `.srclight/**` exclude-glob rationale updated to "stale cache artifacts of the removed srclight service". SC set unchanged. |
| 2026-09-24T04:48:39Z | `plan_revised` | Plan evaluated against the revised spec's SC set: SC-1..SC-7 coverage unchanged (CON-9 is a negative re-registration ban recorded as a constraint, not a criterion — no new/removed SC, no implementation work added or removed), so no regeneration delta exists; the plan remains current with the revised spec. |
| 2026-09-24T05:30:02Z | `plan_approval_revoked` | Spec #2315 substantively revised per the 2026-09-24 second-round developer directive (deck-wide srclight purge folded into the spec: CON-10, §3.2, SC-8, SC-9, R-13, R-14, Items 8-9). The SC set CHANGED, so per approval-gate-006 the linked plan approvals are REVOKED — the `approved-for-pr` authorization and this plan's content are no longer valid for the revised SC set. Plan content is NOT revised in this task; plan regeneration against the revised SC set (adding Items 8-9 and the deck-purge work) is a separate downstream writing-plans dispatch requiring re-approval. |
| 2026-09-24T13:11:03Z | `plan_revised` | Plan regenerated against the revised spec SC set per the 2026-09-24 second-round developer directive (the downstream writing-plans dispatch designated by the preceding `plan_approval_revoked` event): SC-8/SC-9 added to Phase 2 (now "Documentation and deck-purge work", SC-6/SC-8/SC-9), deck-purge scope added to Architecture/Files/Phase-2 context per §3.2 (sweep command, exclusion list, 162-match/46-file footprint baseline, genericize-or-remove disposition rule, no-product-name rule, fallback preservation), Phase 2 procedure encodes the behavioral-item ordering (Item 9 RED behavioral run pre-purge; Item 8 COMMIT+PUSH+fresh-fetch remote-ref containment before the Item 9 verify behavioral run), Exit Criteria C8/C9 added, plan title aligned with the revised spec title, and the canonical Pre-Flight Guard section (reason code `ORCHESTRATOR_ONLY_PLAN`) emitted per plan-artifact-format §3.5. Dependency contract updated: phase_2 SCs extended to SC-6/SC-8/SC-9 with deck-purge file targets and behavioral-ordering note. Phase files synced: `plan-02-documentation-work.md` regenerated with Items 6/8/9, renumbered to continue Phase 1's global step numbering. |
| 2026-09-24T13:28:11Z | `plan_revised` | Plan revised per validate-findings.yaml (overall_status FAIL, 2026-09-24T13:24:36Z; categories 1-5 PASS, category 6 FAIL): F-1 remediated — plan-01 dispatch vocabulary migrated from the retired three-indicator set to the canonical two-indicator set per plan-artifact-format §4.2 (12x inline→direct; 18x sub-agent + 9x clean-room→task-card), aligning plan-01 with plan-02's vocabulary; F-2 remediated — plan-01 Pre-implementation step 1 (coherence gate) SC enumeration updated from stale SC-1..SC-7 to the revised SC-1..SC-9 with correct evidence-type mapping (behavioral SC-1/2/3/5/7/9; structural SC-4/6/8); observation fix applied in the same pass (same revision-lag root cause) — plan-01 step 17 (Item 3 GREEN) now names the §3.1-designated corpora (`opencode-agent-config`, `.opencode-deck`) matching the plan index and Phase-1 procedure. Dependency contract reviewed: no changes required (findings were plan-01-only; contract phase SCs/edges/files remain consistent with the revised spec). Root cause of both findings: the 2026-09-24T13:11:03Z regeneration updated plan.md and plan-02 but not plan-01. |
| 2026-09-24T13:35:19Z | `plan_created` | Plan file `.opencode/.issues/2315/plan.md` verified, phase count = 2 |
