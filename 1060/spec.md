# [SPEC] Spec Structure Expansion — SC Table Columns, Preamble Sections, Self-Review Checks

## Intent and Executive Summary

- **Problem Statement**: The `write.md` skill for spec-creation produces specs with basic SC tables (4 columns), optional preamble sections, and a 4-step self-review. Over 42 items of spec-output requirements from cross-project analysis remain unmapped — SCs lack traceability, verification gates, artifact paths, and binding metadata; preambles lack decision ledgers, risk tables, and revision policies; self-review lacks coherence checks and artifact-path consistency verification.
- **Root Cause / Motivation**: The current `write.md` was written before the spec-output requirements analysis identified 42 structural requirements for a complete spec. The result is underspecified specs that fail adversarial audit gates and require rework during implementation.
- **Approach Chosen**: Add 8 new SC table columns, 5 new preamble sections, 2 new mandatory content areas, and 2 new self-review substeps to `write.md`. All additions are gated behind behavioral enforcement tests.
- **Alternatives Considered & Why Discarded**: (1) Create a separate "extended spec" template — discarded because it creates a two-tier spec system where every spec should carry the full structure. (2) Add all 18 items as a single monolithic change — discarded per incremental build discipline; items break naturally into 5 grouped SCs.
- **Key Design Decisions**: Each SC table column is conditional (multi-phase only, CI-gate only, optional) except Requirement Traceability which is mandatory all tiers. Preamble sections and content areas are mandatory unless the spec is "simple" per write.md's existing simplicity heuristic.

## Objective

Expand `write.md` with the 18 items from the spec-output requirements analysis, organized into 5 SC groups: SC Table Columns, Preamble Sections, Mandatory Content Areas, Self-Review Substeps, and SC Metadata Annotations.

## Problem

The current `write.md` (`.opencode/skills/spec-creation/tasks/write.md`) produces SC tables with 4 columns (ID, Criterion, Verification Method, Remediation). Preamble sections are described as optional ("the agent decides"). Self-review covers 4 macro-level checks (placeholder, consistency, scope, ambiguity) plus a prose-structure check. This leaves 18 structural requirements unmapped — producing specs that lack traceability metadata, risk traceability, revision control, phase binding, verification gates, and cross-SC coherence verification.

The gap was surfaced across 42 items in the spec-output requirements analysis (sourced from `.opencode/.issues/850` coordination parent and downstream audits). Without this expansion, spec-audits will continue to flag missing metadata on every spec.

## Context

The `write.md` task file is the single output point for spec-creation. All other spec-creation tasks (requirements, decompose, traceability, risk, diagram) feed into `write.md` for assembly. The file currently has 331 lines, placing it within the 3,000-word limit but nearing content density that may require structural upkeep.

The parent coordination issue [#850](https://github.com/michael-conrad/.opencode/issues/850) tracks the full spec-output requirements initiative. This spec covers 18 of the 42 identified items, focusing on the SC table columns, preamble sections, and self-review checks that directly affect `write.md`.

## Affected Files

## Affected Files

| File | Nature of Change |
|------|-----------------|
| `.opencode/skills/spec-creation/tasks/write.md` | Add SC table columns, preamble sections, content areas, and self-review substeps into existing Step 1, Step 3, and Step 6 sections; add new pre-Step-0.8 stub creation between card catalogue and requirements task; add new Step 7a (exec-summary format rules) between Step 7 and Step 8; add new Step 7b (remote push + local mirror) after Step 7a |
| `.issues/{N}/remote-exec-summary.md` | NEW — local mirror of remote platform issue body; updated when remote body is updated |

## Explicit Non-Goals

The following items from the 42-item analysis are NOT covered by this spec:

- Item 6: Mean-vs-Expert enforcement text check — covered by separate spec under #850 coordination
- Items 1, 2, 4, 5, 7, 9, 10, 21-30, 33, 35-39: Assigned to other sub-specs under [#850](https://github.com/michael-conrad/.opencode/issues/850)
- Any changes to task files other than `write.md`

## Regression Invariants

The following MUST remain unchanged after implementation:

1. The existing 4-column SC table format remains the base — new columns are ADDITIONS to this table, not replacements
2. Existing Step 6 self-review checkpoints remain in the same order — new substeps are appended
3. Step 1 preamble sections remain optional for simple specs — only new sections are added as mandatory-for-complex/standard
4. The "any format that covers the required content areas" flexibility remains

## Success Criteria

| ID | Criterion | Evidence Type | Pipeline Step Binding | Artifact Path | Verification Gate | Remediation |
|----|-----------|---------------|----------------------|---------------|-------------------|-------------|
| SC-1 | `write.md` SC table template specifies 12 columns (4 existing + 8 new: Pipeline Step Binding, Artifact Path, Requirement Traceability, Phase Binding, Verification Gate, Integration Mode, Affinity Group, Re-Entry Step) with per-column conditions (mandatory vs conditional) documented in column header definitions | `string` | write | `.opencode/skills/spec-creation/tasks/write.md` | red-green | Add column header definitions to Step 3 SC table format; verify via `grep -c` for all 12 column headers |
| SC-2 | Requirement Traceability column is marked as mandatory for ALL tiers (not conditional) with explicit RFC 2119 MUST language | `string` | write | `write.md` | red-green | Add `MUST` declaration for Requirement Traceability column; verify via grep for the column header and MUST qualification |
| SC-3 | Phase Binding column is documented as multi-phase-only (absent for single-task specs) with the condition stated in the column definition header | `string` | write | `write.md` | red-green | Add condition annotation to Phase Binding column definition; verify via grep for conditional marker |
| SC-4 | Verification Gate column specifies 3 tiers (red-green, pre-commit, ci) with per-tier semantics defined in column header annotations | `string` | write | `write.md` | red-green | Add 3-tier gate definitions; verify via grep for all three gate tiers |
| SC-5 | Integration Mode column definition states "required when Gate=ci, optional otherwise" with supported values documented | `string` | write | `write.md` | red-green | Add Integration Mode column with conditional rule; verify via grep for Gate=ci condition |
| SC-6 | Re-Entry Step column definition states "all tiers" (mandatory for every SC, not conditional) with Re-Entry semantics documented | `string` | write | `write.md` | red-green | Add Re-Entry Step column with all-tiers declaration; verify via grep for mandatory qualifier |
| SC-7 | Step 1 preamble explicitly lists 5 new sections as mandatory building blocks: Decision Ledger (DEC-IDs with RFC 2119 keys), Risk Traceability Table (RISK-IDs with Verifying SC binding), Revision Policy (artifact cascade declarations), Decomposition Classification (single-task/multi-phase), Spec Family Annotation (optional punch list selector) — each with a 1-2 sentence purpose definition and an example block | `string` | write | `write.md` | red-green | Add 5 preamble section definitions to Step 1; verify via grep for each section header and its purpose sentence |
| SC-8 | Decision Ledger preamble section mandates stable DEC-IDs with RFC 2119 requirement keys (MUST/SHOULD/MAY) as column headers in the ledger table, with an example table included | `string` | write | `write.md` | red-green | Add Decision Ledger template with DEC-ID + RFC 2119 key columns; verify via grep for DEC-ID prefix and RFC 2119 key headers |
| SC-9 | Risk Traceability preamble section mandates RISK-IDs with a Verifying SC column that binds each risk to exactly one SC, with an example table included | `string` | write | `write.md` | red-green | Add Risk Traceability table template with RISK-ID + Verifying SC columns; verify via grep for RISK-ID prefix and binding column |
| SC-10 | Revision Policy section mandates artifact cascade declarations — when a parent spec is revised, which dependent artifacts (plans, sub-issues, tests) MUST also be revised, with the cascade rule expressed as a declarative table | `string` | write | `write.md` | red-green | Add Revision Policy template with artifact cascade table; verify via grep for cascade declaration pattern |
| SC-11 | Explicit Non-Goals section is documented in Step 1 as a mandatory content area (not optional) with a template header: `## Explicit Non-Goals` followed by a bullet list of exclusions | `string` | write | `write.md` | red-green | Add Non-Goals mandate to Step 1 content areas; verify via grep for `## Explicit Non-Goals` in write.md |
| SC-12 | Regression Invariants subsection is documented as a mandatory content area (not optional) appearing directly after Explicit Non-Goals, with a template header: `## Regression Invariants` followed by a numbered list of things that MUST NOT change | `string` | write | `write.md` | red-green | Add Regression Invariants subsection mandate; verify via grep for `## Regression Invariants` |
| SC-13 | Step 6 self-review includes a new substep for SC-to-SC coherence check: verify that no two SCs contradict each other (e.g., SC-A says "MUST reject X" and SC-B says "MUST accept X"), with the verification action requiring a pairwise comparison scan | `string` | write | `write.md` | red-green | Add SC-to-SC coherence substep to Step 6; verify via grep for coherence check language |
| SC-14 | Step 6 self-review includes a new substep for Verification-Method-to-Artifact-Path consistency check: verify that each SC's Artifact Path column value is consistent with its Verification Method column (e.g., if Verification Method references a tool, Artifact Path references the same file or directory), with a cross-column comparison action | `string` | write | `write.md` | red-green | Add consistency check substep to Step 6; verify via grep for consistency check language |
| SC-15 | Cross-cutting/Common SC designation is documented: a column annotation in the SC table or a preamble section marker that identifies SCs applying across multiple phases/components, with semantics (shares verification budget, must PASS once for all phases) defined | `string` | write | `write.md` | red-green | Add Common SC designation rules; verify via grep for cross-cutting/common marker |
| SC-16 | Affinity Group column definition states "optional" with documentation of typical use cases (SCs sharing a verification setup, e.g., same test fixture) | `string` | write | `write.md` | red-green | Add Affinity Group column with optional qualifier and use-case examples; verify via grep for optional marker and use-case |
| SC-17 | Artifact Path column definition specifies the `./tmp/{issue-N}/` convention for runtime artifacts, with the convention documented in the column header annotation including an example path | `string` | write | `write.md` | red-green | Add Artifact Path column with `./tmp/{issue-N}/` convention; verify via grep for tmp path convention |
| SC-18 | Decomposition Classification annotation in preamble must distinguish single-task vs multi-phase with a bullet list or table showing the distinguishing criteria (number of phases, sub-issue requirements, PR strategy) | `string` | write | `write.md` | red-green | Add Decomposition Classification section with distinguishing table; verify via grep for both classification values |
| SC-19 | Spec Family annotation in preamble is documented as optional (punch list) with semantics: allows selecting a subset of preamble sections when the same spec format applies to multiple related issues, with the selector syntax documented | `string` | write | `write.md` | red-green | Add Spec Family annotation as optional punch list; verify via grep for optional qualifier and selector syntax |
| SC-20 | New Step 7a in write.md specifies the exec-summary format rules: no checkboxes, no status markers, no completion flags; cards listed in dependency order with SC count+type breakdown; Key Decisions and Risk Callouts sections present and stable. Rules table documents each rule with rationale | `string` | write | `write.md` | red-green | Add Step 7a with format template and rules table; verify via grep for no-tracking rule language and template block |
| SC-21 | New Step 7b in write.md specifies that after the exec summary is pushed to the remote platform, a local mirror is saved at `.issues/{N}/remote-exec-summary.md`. The mirror is updated whenever the remote body is updated. The mirror is never the authoritative spec — it is a maintenance convenience copy | `string` | write | `write.md`, `.issues/{N}/remote-exec-summary.md` | red-green | Add Step 7b with mirror requirement; verify via grep for remote-exec-summary.md reference |
| SC-22 | New pre-Step-0.8 in write.md specifies stub creation: after card catalogue is complete but before requirements extraction begins, the spec writer dispatches a routed `local-issues create` call with a minimal exec summary (title + dependency list + "Full spec forthcoming at .issues/{N}/"). Returns the real issue number used for all subsequent local paths, spec body cross-references, and artifact directories. The stub body is later replaced with the full exec summary in Step 7b | `behavioral` | requirements (pre) | `write.md` | red-green | Add pre-Step-0.8 with stub creation procedure; verify via behavioral test: agent creating a spec must create a remote stub before writing requirements |

## ALL-OR-NOTHING GATE: ALL 22 success criteria MUST pass for implementation to be considered complete.

## Edge Cases

| Edge Case | Handling |
|-----------|----------|
| Simple spec (bug fix, one file) uses minimal format | New preamble sections and content areas are mandatory even for simple specs — simplicity heuristic applies to structure flexibility, not to required content categories. However, simple specs MAY omit columns that require data not applicable (e.g., Phase Binding for single-task). |
| Existing specs already written without new columns | No retroactive migration required. Only newly created specs after implementation MUST include new columns. Grandfather clause applies per `080-code-standards.md` numbering grandfather precedent. |
| SC table becomes unreadably wide with 12 columns | The column definitions in write.md MUST include a rendering note: "For multi-column tables exceeding 8 columns, split into a core table (ID + Criterion + Verification Method + Remediation) with a companion metadata table cross-referenced by SC ID." |
| Column applies conditionally (multi-phase) but spec is single-task | Column definition header MUST explicitly state: "Absent for single-task specs. Include with empty cells for multi-phase specs where the phase is not yet assigned." |
| Stub created on remote but spec writing fails before completion | Stub remains on remote with "spec forthcoming" text — no cleanup required. The stub is a valid placeholder. Next agent encountering it reads from `.issues/{N}/` which may be empty or partially written. |
| Remote platform unavailable during stub creation | pre-Step-0.8 checks platform availability first. If remote is unreachable, stub creation is skipped and a local-only number is used (auto-number from `local-issues create`). The `promote` step later handles renumbering. |
| Remote platform has no `issue-create` API (read-only mirror) | pre-Step-0.8 detects platform capability before dispatching. If no create API, falls back to local auto-numbering. Spec writing continues with local number; no renumbering needed. |

## Dependencies

| Dependency | Type | Impact |
|------------|------|--------|
| [#850](https://github.com/michael-conrad/.opencode/issues/850) | Parent coordination | Defines the overall spec-output requirements initiative |
| Behavioral enforcement test framework at `.opencode/tests/` | Infrastructure | Required for RED/GREEN validation per SC-1 through SC-19 |

All 22 SCs: 21 `string` evidence type (content verification via grep), 1 `behavioral` (SC-22 — stub creation requires agent behavior change). Behavioral RED/GREEN test required for SC-22; all other SCs may use structural/string verification only.

## Risk

| RISK-ID | Description | Likelihood | Impact | Verifying SC | Mitigation |
|---------|-------------|------------|--------|--------------|------------|
| RISK-1 | 12-column SC table + 5 preamble sections + 2 content areas makes write.md exceed 3,000-word limit | Medium | High | SC-1, SC-7 | Monitor word count during implementation; if approaching limit, split preamble section definitions into a separate reference file under `spec-creation/reference/` |
| RISK-2 | New columns increase spec authoring burden, causing agents to skip them | Medium | Medium | SC-2, SC-4, SC-6 | Requirement Traceability, Verification Gate, and Re-Entry Step marked as mandatory (MUST); behaviorally enforced via spec-auditor |
| RISK-3 | Grandfather clause creates inconsistent spec set between new and old specs | Low | Low | N/A | Per-item gap-fill during spec revision cycles; no global migration needed |
| RISK-4 | Wide SC table splits (core + metadata) may confuse agents | Low | Medium | SC-1 edge case | Rendering note with fork-table pattern in write.md; verify via adversarial audit |
| RISK-5 | Remote platform stub creation adds latency to spec writing pipeline | Low | Low | SC-22 | Stub is minimal (title + 2-line body); creation takes <1 API call. Fallback to local auto-numbering for platform-unavailable cases |
| RISK-6 | Stub-remote number conflicts with existing local issues | Low | Medium | SC-22, Edge Case 5 | Stub number is assigned by platform, guaranteed unique on that platform. Local issue dir uses platform number; `local-issues create --number <N>` overwrite protection prevents collision |

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|-----------------|-------------------|---------|
| Direct source search | `srclight_search_symbols("write")`, `glob` for task files | Identify affected file and current SC table format |
| Local docs | `.opencode/skills/spec-creation/tasks/write.md` | Analyze current 4-column table, preamble, and self-review structure |
| Issue body | [michael-conrad/.opencode/issues/1060](https://github.com/michael-conrad/.opencode/issues/1060) | Extract item list and scope boundaries |
| Parent coordination | [michael-conrad/.opencode/issues/850](https://github.com/michael-conrad/.opencode/issues/850) | Verify scope alignment with 42-item analysis |

