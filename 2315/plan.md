---
plan_schema_version: "1.0"
issue: 2315
title: "Adopt RAGSync MCP as default retrieval service and retire srclight (deck purge)"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 2
dispatch:
  - "phase-1: pre-regression (test-driven-development), red (test-driven-development), green (test-driven-development), post-regression (test-driven-development), verify (verification-before-completion), commit-inline (orchestrator)"
  - "phase-2: pre-regression (test-driven-development), red (test-driven-development), green (test-driven-development), post-regression (test-driven-development), verify (verification-before-completion), commit-inline (orchestrator), push (orchestrator, behavioral item SC-9 gate)"
  - "post: audit (audit), z3-check (orchestrator solve), structural-checks (finishing-a-development-branch), pre-pr-gate (verification-before-completion), regression-check (test-driven-development), review-prep (git-workflow-pr), create-pr (git-workflow-pr), exec-summary (completion-core)"
---

# Implementation Plan — #2315 — Adopt RAGSync MCP as default retrieval service and retire srclight (deck purge)

**Issue:** .opencode/.issues/2315/spec.md

**Goal:** Register the RAGSync MCP server as a default-on local stdio service in `.opencode/opencode.jsonc`, configure it with local fastembed embeddings, per-source isolation over the §3.1-designated corpora, auto-sync, and a bounded indexing corpus scope, document the configuration, usage, and validation in the `.opencode` tree, and purge srclight references from the `.opencode/` deck tree per the §3.2 disposition rule — with behavioral verification of srclight-free tool selection.

**Architecture:** Adopt RAGSync (`jsbroks/ragsync-mcp`) as-is per CON-1 (no bespoke RAG implementation). Add a declarative `ragsync` service entry to the `.opencode/opencode.jsonc` `mcp` block following the existing `type: local` / `stdio` / `uvx` pattern; the corpus stays non-tracked (CON-2) and the retired srclight service is never re-registered (CON-9). Create a RAGSync config file co-located with the registration (CON-5) whose `sources` list is the authoritative designation of the reference source corpora per spec §3.1 — one folder-type source per designated corpus (`opencode-agent-config` over the main repo working tree; `.opencode-deck` over the `.opencode/` submodule) with isolated index namespaces (CON-6), fastembed with a pinned default local model and no external embedding API (CON-7), auto-sync per source, and a bounded corpus scope covering all main-repo files plus every registered submodule while excluding non-registered git sub-repos absent a declared carveout (CON-8). Document service config, per-source layout per §3.1, usage, offline/cache path, and validation in the `.opencode` skill/guideline tree, plus a review checklist enforcing per-source isolation. In the deck tree, srclight references are purged per the §3.2 disposition rule (CON-10): genericized to capability-class wording where the capability mapping has value, removed outright where it does not, with graceful-degradation unavailability fallbacks preserved and no replacement-product naming in tool-selection text (R-14); SC-9 verifies the purge behaviorally via an isolated opencode run that executes only after the purge commit is pushed and fresh-fetch-verified.

**Files:**
- `.opencode/opencode.jsonc` (mcp block — additive `ragsync` service entry)
- `.opencode/ragsync-config.yaml` (new — co-located RAGSync config per CON-5)
- `.opencode/skills/` or `.opencode/guidelines/` tree — review checklist (new)
- `.opencode/skills/` or `.opencode/guidelines/` tree — service documentation (new)
- `.opencode/` deck tree — srclight reference purge (§3.2 sweep scope: `guidelines/`, `skills/` audit + brainstorming + misc, `tools/session-init`, `tools/session-to-timeline`, `README.md`; `reference/**` verified zero matches)
- `.gitmodules` (read-only dependency — authoritative CON-8 submodule list)
- `{project_root}/tmp/` (SC-9 behavioral evidence artifacts — no tracked-tree change)

**Blast radius:** The change is additive at the config layer (one new mcp entry + one new co-located RAGSync config + two new `.opencode` tree documents) plus a text-only sweep across the 46 §3.2-enumerated deck files (162 baseline matches). Runtime blast radius: opencode loads one additional stdio service at startup; fastembed downloads a local model on first run (offline/cache path documented); existing services (the-notebook-mcp, editor) and the tracked corpus are untouched. Non-affected: `.opencode/reference/**` (zero matches), `.opencode/.issues/**` (sweep exclusion — historical evidence MUST NOT be rewritten), the `.srclight/` cache directory (deletion out of scope; excluded from the index by the §3.1 glob), root-repo `.issues/` tree (CON-4).

> **Compliance:** All SCs must pass before completion. Partial implementation is not permitted. Each item is daisy-chained — item N's commit is precondition for item N+1's RED.

> **One step at a time.** Execute exactly one step. Report progress. Wait for instruction before the next step.

> **Step status:** Report `[item N] [PASS|FAIL]` after each step. If FAIL, report blocker and halt.

**Enforcement gate:** All SCs must pass before this plan is complete. No SC may be left unverified; behavioral SCs require behavioral evidence and structural SCs require structural evidence — any evidence-type mismatch is a hard FAIL, and any `DONE_WITH_CONCERNS` verdict is coerced to FAIL.

## Phase Table

| Phase | Name | Concern | SCs | Depends On | Step Range | Dispatch |
|-------|------|---------|-----|------------|------------|----------|
| 1 | RAGSync configuration and registration | Register RAGSync as a default local stdio MCP service, configure fastembed local embeddings, per-source isolation over the §3.1-designated corpora, the isolation review checklist, auto-sync, and the CON-8-bounded corpus scope | SC-1, SC-2, SC-3, SC-4, SC-5, SC-7 | — | 1-39 | direct (3, 8, 9, 14, 15, 20, 21, 26, 27, 32, 33, 38) + task-card (1, 2, 4-7, 10-13, 16-19, 22-25, 28-31, 34-37, 39) |
| 2 | Documentation and deck srclight purge | Document the RAGSync service configuration, per-source layout, usage, offline/cache path, and validation step in the `.opencode` tree; purge srclight references from the deck tree per the §3.2 disposition rule; verify srclight-free tool-selection behavior | SC-6, SC-8, SC-9 | 1 | 40-55 | direct (40, 45, 47, 52, 53) + task-card (41-44, 46, 48-51, 54, 55) |
| Post | Post-implementation and delivery | Audit, Z3 verification, finishing checks, PR gate, regression check, review prep, PR creation, completion summary | all | 1, 2 | 56-63 | direct (57) + task-card (56, 58-63) |

## Exit Criteria

- [ ] C1. SC-1 PASS: `ragsync` service registered in `.opencode/opencode.jsonc` mcp block with `type: local`, `stdio` transport, `enabled: true` — behavioral evidence that the service spawns and lists its tools, and the config parses as valid JSONC.
- [ ] C2. SC-2 PASS: RAGSync configured with fastembed local embeddings, a pinned default local embedding model, and no external embedding API dependency — behavioral evidence via network-monitored retrieval.
- [ ] C3. SC-3 PASS: Per-source isolation configured — exactly one config section per §3.1-designated source with isolated index namespaces — behavioral evidence via cross-source search with no retrieval leakage.
- [ ] C4. SC-4 PASS: Review checklist documented in the `.opencode` tree enforcing per-source isolation, with the three topic-presence criteria (one config section per §3.1 source, isolated index namespaces, empty-source handling) — structural evidence.
- [ ] C5. SC-5 PASS: Auto-sync enabled for each declared source — behavioral evidence via source-file modification with index-freshness observation.
- [ ] C6. SC-6 PASS: Documentation exists in the `.opencode` tree covering service configuration, per-source layout per §3.1, usage, offline/cache path, and validation step — structural evidence with explicit topic-presence criteria.
- [ ] C7. SC-7 PASS: Corpus scope bounded to all main-repo files plus every registered submodule (per `.gitmodules`); non-registered git sub-repos (the `.issues/` orphan-branch worktrees at root and under `.opencode/`) excluded absent a declared carveout — behavioral evidence via runtime indexed-source enumeration.
- [ ] C8. SC-8 PASS: The `.opencode/` deck tree contains zero srclight references — every §3.2-enumerated reference removed outright or genericized to capability-class wording per the §3.2 disposition rule, with the §3.2 sweep exclusion list as the determinate sweep boundary — structural evidence via the zero-match deck sweep plus genericized-site spot checks.
- [ ] C9. SC-9 PASS: Agent tool-selection behavior is srclight-free — an isolated opencode run on a code-verification task shows tool selection via available tooling or the built-in `read`/`grep` fallback, with zero `srclight_*` tool-call attempts in the session evidence — behavioral evidence.

## Self-Remediation Protocol

> **Self-Remediation Protocol:** If a step FAILs: diagnose root cause, fix the deliverable, re-verify. If the fix requires spec revision, update the spec and re-enter the plan. Escalate only after remediation failure.

## Post-Implementation (one-time, after Phase 2)

- [ ] 56. **Audit (**task-card**).** Adversarial audit of the deliverable across both phases (DiMo investigator → validator → evaluator → arbiter, in sequence). Dispatch `task(..., prompt: "execute verification-audit DiMo investigator from audit. Read \`audit/tasks/verification-audit-investigator.md\` first")`, then dispatch validator, evaluator, and arbiter in sequence. Pre-clean first: `rm -f {project_root}/tmp/2315/artifacts/pipeline-audit-*`. **→ audit**
- [ ] 57. **Z3 check (**direct**).** Run the constraint-solver verification directly — no sub-agent dispatch: `.opencode/tools/solve check --state-path .opencode/.issues/2315/artifacts/state-analysis.yaml --contract-path .opencode/.issues/2315/dependency-contract.yaml`. Confirm SAT with the phase-1/phase-2 state assignment consistent with completed phases. Pre-clean first: `rm -f {project_root}/tmp/2315/artifacts/pipeline-z3-check-*`. **→ z3-check**
- [ ] 58. **Structural checks (**task-card**).** Run the finishing checklist (lint, format check, typecheck, and the repo's applicable verification commands) against the changed tree. Dispatch `task(..., prompt: "execute checklist task from finishing-a-development-branch")`. Pre-clean first: `rm -f {project_root}/tmp/2315/artifacts/pipeline-structural-checks-*`. **→ structural-checks**
- [ ] 59. **Pre-PR gate (**task-card**).** Read ALL SC verdicts (SC-1..SC-9) and BLOCK if any is FAIL (a `DONE_WITH_CONCERNS` verdict is coerced to FAIL). Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Pre-clean first: `rm -f {project_root}/tmp/2315/artifacts/pipeline-pre-pr-gate-*`. **→ pre-pr-gate**
- [ ] 60. **Regression check (**task-card**).** Final regression pass before PR creation. Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. Pre-clean first: `rm -f {project_root}/tmp/2315/artifacts/pipeline-regression-check-*`. **→ regression-check**
- [ ] 61. **Review prep (**task-card**).** Prepare the PR review context — branch readiness, changed-file inventory, SC verdict summary. Dispatch `task(..., prompt: "execute review-prep from git-workflow-pr. Read \`git-workflow-pr/tasks/review-prep.md\` first")`. **→ review-prep**
- [ ] 62. **Create PR (**task-card**).** Create the pull request (stacked strategy — one branch, commits per issue, single PR targeting the trunk; merge is human-only). Dispatch `task(..., prompt: "execute create task from git-workflow-pr")`. **→ create-pr**
- [ ] 63. **Executive summary (**task-card**).** Generate the completion executive summary for the PR and the issue lifecycle. Dispatch `task(..., prompt: "execute completion task from completion-core")`. **→ exec-summary**

---

## Phase 1 — RAGSync configuration and registration

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` (red/green per item), `verification-before-completion` (verify) |
| Task | `red` → `green` → post-regression (`phase-4`) → `verify` → commit-inline per item |
| Target | `.opencode/opencode.jsonc` mcp block; `.opencode/ragsync-config.yaml`; review checklist in `.opencode/skills/` or `.opencode/guidelines/` tree |
| SCs | SC-1, SC-2, SC-3, SC-4, SC-5, SC-7 |
| Depends On | — |

**Context (input parameters):**
- Feature branch exists per git-workflow pre-work; trunk-tip verified; submodules clean
- Baseline: `.opencode/opencode.jsonc` mcp block declares the-notebook-mcp and editor only (no `ragsync` entry; srclight already unregistered — re-registration banned per CON-9); no RAGSync config file exists
- RAGSync adopted as-is (`jsbroks/ragsync-mcp`), following the existing `type: local` / `stdio` / `uvx` runner pattern (CON-1, R-2)
- Embedding: fastembed with a pinned default local model, no external embedding API dependency (CON-7, R-3, R-10); offline/cache path documented (SC-6 documents it, phase 2)
- Corpus designation: the RAGSync config `sources` list is the sole authority per spec §3.1 — `opencode-agent-config` (main repo working tree, config root `../..`) and `.opencode-deck` (`.opencode/` submodule, source root `.`), each with the §3.1 mandatory include/exclude globs (`*.md`, `*.txt`, `*.tex` include policy; the §3.1 exclude-glob tables are binding — including the `.srclight/**` glob keeping stale cache out of the index)
- Per-corpus include/exclude values come from the spec §3.1 tables verbatim; no new corpora may be introduced in phase 1, and no source section may fall outside the CON-8 surface
- Corpus scope: all files in the main repo plus every submodule in `.gitmodules` (exactly one: `.opencode`); non-registered git sub-repos — the `.issues/` orphan-branch worktrees at root and under `.opencode/` — excluded absent a declared carveout (CON-8, R-12)
- Review checklist topics: one config section per §3.1-designated source; isolated index namespaces; empty-source handling (CON-6, R-11, SC-4)
- Item order: item-01 (SC-1), item-02 (SC-2), item-03 (SC-3), item-04 (SC-4), item-05 (SC-5), item-07 (SC-7) — sequential per-SC TDD cycles on the shared config file; each SC's RED asserts absence of its own concern
- Evidence types: behavioral for SC-1, SC-2, SC-3, SC-5, SC-7 (runtime service spawn + tool listing, network-monitored retrieval, cross-source leakage search, index-freshness observation, runtime indexed-source enumeration); structural for SC-4 (topic-presence file read)
- Phase executable steps live in `plan-01-configuration-registration.md` (steps 1-39); that phase file's per-step `(**direct**)`/`(**task-card**)` indicators are the normative execution truth per plan-artifact-format §4.2 — this index carries no duplicate step list (revision 2026-09-30 removed the drift-prone inline copies)

**Phase 1 sections (from analytical artifacts):**
- Code path coverage: `.opencode/opencode.jsonc` mcp block → opencode runtime MCP loader → spawned `ragsync` stdio server process (`uvx jsbroks/ragsync-mcp`) → tool listing (SC-1); RAGSync config → fastembed runtime → pinned local model + offline/cache path (SC-2); config sources list → per-source isolated `vector_store.collection` namespaces → cross-source query path (SC-3); static checklist path (SC-4); auto-sync watcher → index update without manual re-index (SC-5); `.gitmodules` registered submodule list → corpus-scope declaration → runtime indexed-source enumeration (SC-7)
- Cross-cutting SCs: SC-1 (config state crossed with runtime spawn verification); SC-3 (source isolation crossed with §3.1 corpus designation and CON-8 repo-structure surface — reviewed together with SC-7); SC-4 (documentation-shaped but enforcing the SC-3 isolation config); SC-5 (config declaration crossed with runtime index freshness); SC-7 (corpus scope crossed with `.gitmodules` repo structure and the data-integrity exclusion of non-registered sub-repos)
- Interface boundaries: opencode.jsonc mcp block ↔ opencode runtime MCP loader (additive `ragsync` key, existing entries unmodified; malformed entry rejected — JSONC validity asserted at SC-1 verify); opencode.jsonc registration ↔ RAGSync config file (co-located and validated together per CON-5); config sources list ↔ §3.1 designated corpora (sole designation mechanism; per-corpus include/exclude globs; out-of-surface source sections are config defects caught at SC-7); RAGSync ↔ fastembed runtime (pinned local model; first-run download falls back to the offline/cache path); RAGSync corpus scope ↔ repository git structure (derived from `.gitmodules`; drift caught by SC-7 enumeration)
- State transitions: mcp block from "no ragsync entry" to "enabled ragsync entry, JSONC parses" (SC-1); embedding config from none to pinned fastembed local model with local cache (SC-2); sources list from none to one section per §3.1 corpus with isolated namespaces (SC-3); checklist file from absent to present with the three topic criteria (SC-4); auto-sync from unconfigured to enabled per declared source with fresh-on-change index (SC-5); corpus scope from undeclared to main-repo + registered-submodule bounded with non-registered sub-repos excluded (SC-7)
- Entry conditions: spec #2315 approved (`approved-for-pr`, `spec-cleared` in local issue.yaml); feature branch exists per git-workflow pre-work; baseline confirmed (no `ragsync` entry, no RAGSync config, checklist absent)
- Exit conditions: SC-1, SC-2, SC-3, SC-4, SC-5, SC-7 all verified clean PASS and committed; `ragsync` registered and operational; `.opencode/ragsync-config.yaml` declares fastembed pinned local embeddings, the two §3.1 corpus sections with isolated namespaces and the §3.1 globs, auto-sync per source, and the CON-8-bounded corpus scope; review checklist exists and covers the three isolation topics

**Dispatch summary** (aligned to plan-01's normative per-step indicators — that phase file is the execution truth per plan-artifact-format §4.2): direct (steps 3, 8, 9, 14, 15, 20, 21, 26, 27, 32, 33, 38) + task-card (steps 1, 2, 4-7, 10-13, 16-19, 22-25, 28-31, 34-37, 39).

**Concern transition:** Leaving configuration and registration work → entering documentation and deck-purge work. Phase 2 depends on the landed service configuration (CON-5) and on Phase 1's VbC being clean; phase 2's documentation items describe exactly the artifacts phase 1 produced.

---

## Phase 2 — Documentation and deck srclight purge

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` (red/green per item), `verification-before-completion` (verify) |
| Task | `red` → `green` → post-regression (`phase-4`) → `verify` → commit-inline + push (behavioral item gate) per item |
| Target | `.opencode/skills/` or `.opencode/guidelines/` tree (service documentation, new); `.opencode/` deck tree srclight purge (§3.2 sweep scope) |
| SCs | SC-6, SC-8, SC-9 |
| Depends On | 1 |

**Context (input parameters):**
- Phase 1 complete: RAGSync registered and configured; Phase 1 VbC passed (SC-1..SC-5, SC-7 clean PASS)
- Documentation topics (SC-6, R-6, R-9): service configuration, per-source layout per §3.1, corpus scope (CON-8), usage, offline/cache path, validation step — the CON-5 config-drift mitigation requires the landed phase-1 configuration as its source of truth
- Deck purge scope (SC-8, CON-10, R-13, R-14): the §3.2 footprint — 162 srclight matches across 46 files (enumerated 2026-09-24) — with the per-site disposition rule (GENERICIZE to capability-class wording where the capability mapping has value; REMOVE product-specific references outright: srclight CLI troubleshooting commands in `mcp-tool-usage/tasks/selection-guide.md`, retired-service tier-table entries in `guidelines/060-tool-usage.md` and `mcp-tool-usage/SKILL.md`, the `check_srclight()` probe + `srclight_status` wiring + startup message in `tools/session-init`, the `srclight_*` normalizers in `tools/session-to-timeline`, the README mcp-block srclight line)
- Sweep command: `rg -i 'srclight' .opencode/ --hidden --no-ignore` with the §3.2 exclusion list as the determinate boundary: `.opencode/.git/**`, `.opencode/.issues/**`, `node_modules/**`, `tmp/**`, `.pytest_cache/**`, `.ruff_cache/**` — the `.opencode/.issues/` issue store MUST NOT be rewritten (historical evidence artifacts are records of past work, not agent-facing instructions)
- Product-name rule (R-14): no `ragsync` or any replacement-product naming in deck tool-selection text — name the capability, not the product
- Fallback preservation: wherever a task card carries an "if srclight unavailable → do NOT BLOCK" (or equivalent `TOOL_UNAVAILABLE` / `srclight_unavailable`) graceful-degradation row, the genericized text carries an equivalent unavailability fallback row
- SC-9 behavioral ordering (the behavioral-variant item): the RED behavioral run executes against the PRE-purge deck state (before Item 8's GREEN lands in the working tree); the verify behavioral run executes only after Item 8's COMMIT and PUSH with a fresh `git fetch` verifying the effective commit is contained in a remote ref; GREEN is delivered by Item 8's genericized deck text; SC-9 has no commit of its own beyond Item 8's purge commit; evidence artifacts recorded under `{project_root}/tmp/`
- Isolated opencode runs use the `with-test-home` wrapper per repo test discipline; runtime-behavioral claims demand behavioral evidence — the SC-8 sweep alone would be EVIDENCE_TYPE_MISMATCH for SC-9
- Evidence types: structural for SC-6, SC-8; behavioral for SC-9
- Phase executable steps live in `plan-02-documentation-work.md` (steps 40-55); that phase file's per-step `(**direct**)`/`(**task-card**)` indicators are the normative execution truth per plan-artifact-format §4.2

**Phase 2 sections (from analytical artifacts):**
- Code path coverage: static documentation path in the `.opencode` skill/guideline tree asserting the five SC-6 topic-presence criteria; text-state path across the 46 §3.2-enumerated deck files with per-site GENERICIZE/REMOVE dispositions and the §3.2 sweep boundary (SC-8); agent tool-selection runtime path — agent reads genericized deck text, selects available local index tooling or the built-in `read`/`grep` fallback, session evidence contains zero `srclight_*` attempts (SC-9)
- Cross-cutting SCs: SC-6 (service documentation crossed with all phase-1 config concerns — CON-5 config-drift mitigation motivates the phase-2 sequencing); SC-8 (deck purge spans guidelines, task cards with fallback rows, README, and executable session tooling — script-side removal changes script behavior, not just prose); SC-9 (behavioral evidence spans the text-state concern and the behavioral-verification infrastructure — validity depends on SC-8's purge being committed and pushed to a remote ref)
- Interface boundaries: genericized deck text ↔ agent tool-selection behavior (capability-class wording; preserved graceful-degradation fallback rows; no replacement product naming — removing a fallback row would hard-halt agents when no index tool exists); deck purge ↔ historical evidence artifacts (`.opencode/.issues/**` on the sweep exclusion list — MUST NOT be rewritten, rewriting would falsify historical audit trails)
- State transitions: documentation file from absent to present with the five topics (SC-6); deck text state from "162 matches across 46 files" to "zero matches within the sweep boundary; genericized sites carry capability-only wording with intact fallback rows" (SC-8); agent tool-selection behavior from "guidance routes toward `srclight_*` tools" to "selects available tooling or the built-in read/grep fallback; zero `srclight_*` attempts in session evidence" (SC-9)
- Entry conditions: phase 1 complete and VbC-passed; §3.2 footprint baseline available (162 matches / 46 files, enumerated 2026-09-24); `with-test-home` isolated-run environment available
- Exit conditions: SC-6, SC-8, SC-9 all verified clean PASS; documentation exists covering the five topics; §3.2 sweep returns zero matches; isolated behavioral run shows srclight-free tool selection with zero `srclight_*` attempts; purge commit pushed and fresh-fetch-verified (SC-9 verify precondition)

**Cost frames (per-phase, dark-prose-007):**
- Phase 1 cost frame: Behavioral verification of the running service (spawn + tool listing, network-monitored retrieval, cross-source search, index-freshness observation, indexed-source enumeration) costs minutes of bounded execution time. Skipping any of these behavioral gates means the defect ships: a malformed registration loads broken at startup, an unpinned model or external API dependency fails on first retrieval, cross-source leakage of copyrighted material surfaces only in downstream queries, a stale index yields confidently-wrong answers, and foreign git sub-repos silently enter the provenance trail — each a death-spiral defect discovered 1000×+ later than the gate that would have caught it. Correctness is the only metric.
- Phase 2 cost frame: The zero-match sweep costs one grep pass, the documentation topic check costs one file read, and the SC-9 behavioral run costs minutes in an isolated test home. Skipping the sweep leaves the retired service's tool names as live agent-facing instructions that misroute every future agent; skipping the behavioral run reduces the purge to a text-only claim (EVIDENCE_TYPE_MISMATCH for the behavior claim) — an agent following genericized guidance that still cannot fall back to built-in tooling halts where graceful degradation should have kept it working, and the defect ships to every subsequent session. Correctness is the only metric.

**Concern transition (post-implementation):** Leaving documentation and deck-purge work → entering post-implementation verification and delivery. The audit consumes the full deliverable across both phases; the pre-PR gate reads all SC verdicts before PR creation; merge is human-only.

## Pre-Flight Guard (Mandatory)

Check your tool list for a tool named `task`.

- Present ⇒ orchestrator — proceed.
- Absent ⇒ sub-agent — do NOT execute any instruction below. Return `BLOCKED` with `ORCHESTRATOR_ONLY_SKILL_CARD` (cards) or `ORCHESTRATOR_ONLY_PLAN` (plans) and halt.

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
| 2026-09-30T03:00:17Z | `plan_created` | Plan file `.opencode/.issues/2315/plan.md` regenerated by writing-plans/tasks/create against the current spec SC set (SC-1..SC-9) and structure artifact (2026-09-29 re-verified solve outputs: SAT / SAT / SOLVED_SATISFICING), phase count = 2; index + plan-01-configuration-registration.md + plan-02-documentation-work.md re-emitted with the full post-implementation gate set (audit, z3-check, structural-checks, pre-pr-gate, regression-check, review-prep, create-pr, exec-summary) per the implementation-workflow reference card; SC-9 behavioral ordering retained (RED pre-purge; verify after Item 8 commit+push+fetch gate) |
| 2026-09-30T03:22:00Z | `plan_revised` | Plan revised per validate-findings.yaml validation_pass 3 (overall_status FAIL; categories 1-5 PASS, category 6 FAIL; remediation iteration 1 of max 3). F-1 remediated — plan.md Phase-1 dispatch summary and phase-table Dispatch cell rewritten to plan-01's normative indicator enumeration (direct: 3, 8, 9, 14, 15, 20, 21, 26, 27, 32, 33, 38; task-card: 1, 2, 4-7, 10-13, 16-19, 22-25, 28-31, 34-37, 39 — step 39 now included in both). F-2 remediated — phase-2 task-card range corrected from "41-46" to "41-44, 46" in the plan.md phase-table Dispatch cell and plan-02 dispatch summary (step 45 is direct; was double-listed). F-3 root cause remediated — duplicated inline phase-1 step lists (pre-implementation + items 1-7 + Phase-1 VbC copies) removed from the plan.md index; plan-01 is the sole normative executable source per plan-artifact-format §4.2 and the index now carries only §3.4 Fields + Context plus a normative pointer, so the index can no longer drift from the phase files. Phase-2 and phase-1 context pointers extended with the plan-artifact-format §4.2 normative-indicator note. F-4 (deck-level reference-card↔skill-file token drift on create-pr) recorded, not fixed — out of scope for this plan artifact. F-5 (no phase-0 pre-regression step; per-item Pre-clean + post-regression instead) remains advisory/carried — not a check failure. Dependency contract reviewed: variables, preconditions, edges, phase SC sets, and file targets remain consistent — no structural change required; revision-review note appended. |
| 2026-09-30T03:37:12Z | `plan_created` | Plan file `.opencode/.issues/2315/plan.md` verified by writing-plans/tasks/completion, phase count = 2 (Phase 1: RAGSync configuration and registration, SC-1..SC-5/SC-7, steps 1-39; Phase 2: Documentation and deck srclight purge, SC-6/SC-8/SC-9 behavioral variant, steps 40-55; Post-implementation gates steps 56-63) following fresh re-validation PASS (validation pass 4); dependency-contract.yaml present at `.opencode/.issues/2315/dependency-contract.yaml`; lifecycle event appended and synced to issues-data |