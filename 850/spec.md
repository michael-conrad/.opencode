## Intent and Executive Summary

**Problem Statement:** Spec enforcement statements (success criteria, risk entries, non-goals, exit criteria) currently lack a structured enforcement-text-style gate. Content passes through the pipeline without verification that enforcement language uses the correct dark prose, distribution-shifting, and procedural-discipline patterns per section type. The 42-item analysis at `tmp/spec-output-requirements-analysis.md` identified 42 structural gaps; items 1, 5, and 6 address the enforcement-text-style dimension at three points in the workflow.

**Root Cause / Motivation:** Specs are produced with enforcement statements that use mean-response language (hedged, qualified, advisory) instead of expert-framed language (absolute, identity-anchored, contrastive). No pre-approval gate verifies pattern compliance, no self-review step checks for Mean-vs-Expert categorization, and no spec-auditor task scans for per-section compliance. Enforcement text that reads "verification is recommended" instead of "verification IS completion" passes through unremediated, and the implementing agent receives structurally weakened directives.

**Approach Chosen:** Three independent injection points targeting different pipeline stages:
1. Pre-pipeline enforcement text style gate (before implementation, after approval) — a `solve`-validated structural check run by spec-auditor before the pipeline begins
2. Enforcement-text-style scan in spec-auditor (pre-approval) — per-section pattern compliance verified during spec audit
3. Mean-vs-Expert self-check template in Step 6 of spec-creation write.md (at spec authorship) — author checks own enforcement text before the spec is submitted

These three points form a cascade: catch at authorship (item 6), catch at audit (item 5), catch at pipeline entry (item 1). Each successive gate catches what the prior gate missed.

**Alternatives Considered & Why Discarded:**
- Single monolithic gate after approval-gate only: Would let Mean-framed enforcement text reach the spec issue and survive review — too late for low-cost fixes
- All-42-items spec: The 42-item analysis covers too many concerns (SC columns, artifacts, handoffs, pipeline steps). Narrowing to items 1/5/6 keeps enforcement-text-style as a focused, implementable scope
- Behavioral enforcement test for the gate itself: Deferred — enforcement text style is structural/string-verifiable (grep for prohibited patterns); behavioral tests for the pipeline behavior will be added in downstream specs

**Key Design Decisions:**
- DEC-1: Item 5 scan runs in spec-auditor (pre-approval), NOT in a standalone gate — reuses existing audit infrastructure instead of creating a new pipeline step
- DEC-2: Item 6 self-check template uses a 4-row table (SC enforcement, Risk entries, Non-Goals, Exit criteria) with Mean/Expert columns — simple enough for the author to apply without tool support
- DEC-3: Item 1 gate uses structural checks only (grep for prohibited patterns, exit 1 on match) — no model calls for style evaluation, keeping the gate fast and deterministic

## Objective

Enforce that spec enforcement statements — success criteria, risk analysis entries, non-goals, and exit criteria — use correct expert-framed language (dark prose + distribution shifting + procedural discipline per the co-application mandate [#849](https://github.com/michael-conrad/.opencode/issues/849)) at three pipeline stages: authorship self-review (item 6), spec-audit time (item 5), and pre-pipeline entry (item 1).

## Problem

Spec enforcement statements are where the spec communicates non-negotiable behavioral requirements to the implementing agent. Currently these statements use mean-response language — hedged, qualified, advisory patterns that RLHF-aligned models default to. Research shows that without external-signal verification (Kamoi et al., 2024, https://arxiv.org/abs/2406.01297), self-detection of mean-response drift is unreliable. Distribution shifting patterns (naming the mean response, contrasting with the expert version) are documented in the 255-distribution-shifting-reference card [#848](https://github.com/michael-conrad/.opencode/issues/848) and dark prose patterns in the 250-dark-prose-reference card, but no gate enforces their application in spec enforcement text.

Without injection at all three pipeline positions:
- **At authorship**: The spec author writes mean-framed enforcement because no template reminds them to check
- **At audit**: The spec-auditor checks structure but not enforcement-text-style per section type
- **At pipeline entry**: The pipeline starts with a spec whose enforcement text uses weak language — the implementing agent receives structurally weakened directives

## Context

The 42-item analysis at `tmp/spec-output-requirements-analysis.md` identifies enforcement-text-style gaps at three specific points:

**Item 1 — Pre-pipeline enforcement text style gate (analysis §42-43):** A structural gate between approval-gate and sc-coherence-gate (pipeline step 1) that verifies spec enforcement statements use correct patterns per section before the implementation pipeline begins. Uses a per-section pattern mapping table:

| Spec Section | Required Pattern |
|---|---|
| Success Criteria | dist-shift-002 + dark-prose-003 |
| Risk Analysis | dist-shift-004 + dark-prose-005 |
| Non-Goals | dist-shift-002 + dark-prose-002 |

**Item 5 — Enforcement-text-style scan in spec-auditor (analysis §54-63):** Per-section pattern compliance check at spec-auditor time (pre-approval). Checks each spec section against the pattern mapping table. Reuses the existing spec-auditor dispatch infrastructure — the auditor reads spec body and checks section-level compliance against the mapping table.

**Item 6 — Mean-vs-Expert self-check template (analysis §64-73):** Self-review substep in spec-creation write.md Step 6. The spec author scans enforcement statements in each section, classifies each as Mean vs Expert using a 4-row categorization table, and rewrites Mean entries before submission.

The co-application mandate [#849](https://github.com/michael-conrad/.opencode/issues/849) requires all three reference cards (250, 255, 257) to be consulted for AI-agent-facing text. Enforcement text style is the first concrete domain where co-application must be enforced — this spec provides the enforcement infrastructure.

Dependencies on [#1060](https://github.com/michael-conrad/.opencode/issues/1060) (spec structure expansion — Non-Goals as mandatory section), [#848](https://github.com/michael-conrad/.opencode/issues/848) (255-distribution-shifting-reference card), and [#853](https://github.com/michael-conrad/.opencode/issues/853) (257-procedural-discipline-reference card) mean that this spec's implementation must validate against the pattern definitions established by those cards.

## Affected Files

- `spec-creation/tasks/write.md` (`.opencode/skills/`) — Add Mean-vs-Expert self-check template to Step 6
- `adversarial-audit/tasks/spec-audit.md` (`.opencode/skills/`) — Add enforcement-text-style per-section compliance scan
- `implementation-pipeline/tasks/assemble-work.md` (`.opencode/skills/`) — Add pre-pipeline enforcement text style gate step (or add as new task file if decomposition requires)

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Remediation |
|----|-----------|---------------|---------------------|-------------|
| SC-1 | `spec-creation/tasks/write.md` Step 6 includes a Mean-vs-Expert self-check substep with the 4-row categorization table (SC enforcement, Risk entries, Non-Goals, Exit criteria) and instructions to rewrite Mean entries before submission | `string` | `grep -q "Mean.*Expert\|Mean (FAIL)\|Expert (PASS)" .opencode/skills/spec-creation/tasks/write.md` | Add the substep as a numbered step after the prose-structure check and before Step 6.5 evidence artifact verification. The template table MUST match the 4-row format from the analysis. Re-verify with grep. |
| SC-2 | The self-check's instruction requires the spec author to scan ALL enforcement statements in the spec body (not just Success Criteria), classify each as Mean vs Expert using the table, and rewrite Mean entries — confirmed by reading the substep text | `structural` | `grep -c "classif\|categor\|rewrite\|Mean\|Expert" .opencode/skills/spec-creation/tasks/write.md` must be > 5 — verifies the substep contains substantive classification infrastructure, not a placeholder | Extend the substep text from a skeleton to a complete procedure including scan scope, classification table, rewrite instructions, and re-scan exit criterion |
| SC-3 | `adversarial-audit/tasks/spec-audit.md` includes an enforcement-text-style per-section compliance scan that checks each spec section (Success Criteria, Risk Analysis, Non-Goals) against the pattern mapping table from the analysis | `string` | `grep -q "dist-shift-002\|dark-prose-003\|enforcement.text.style\|section.*pattern" .opencode/skills/adversarial-audit/tasks/spec-audit.md` | Add a scan substep that reads the spec body, extracts section boundaries, and checks each section's enforcement statements against the required pattern mapping table. Re-verify with grep. |
| SC-4 | The spec-auditor's enforcement-text-style scan classifies findings according to the existing audit taxonomy (auto-fix / conditional / flag-for-review) — structural fixable patterns (Mean/Expert mismatch) are auto-fix; semantically ambiguous sections are flag-for-review | `string` | `grep -q "auto.fix\|flag.for.review\|classif" .opencode/skills/adversarial-audit/tasks/spec-audit.md` | Ensure the scan substep references the existing audit classification system. Patterns that produce a deterministic PASS/FAIL on grep are auto-fix; patterns requiring auditor judgment are flag-for-review. |
| SC-5 | `implementation-pipeline/tasks/assemble-work.md` (or a new task file) includes a pre-pipeline enforcement text style gate that runs between approval-gate and sc-coherence-gate — verifies enforcement statements in the approved spec's Success Criteria, Risk Analysis, and Non-Goals sections use correct dark prose and distribution-shifting patterns per the pattern mapping table; FAIL exits the pipeline | `string` | `grep -q "enforcement.*text.*style\|pre.pipeline\|approval.gate.*sc.coherence" .opencode/skills/implementation-pipeline/tasks/assemble-work.md` | Add the gate step with: grep-based structural checks for prohibited Mean patterns in each section → FAIL on match (exit pipeline) → PASS allows sc-coherence-gate to proceed. The gate MUST NOT call a model — structural checks only. |
| SC-6 | All three injection points (item 6 self-check, item 5 spec-auditor scan, item 1 pre-pipeline gate) reference the co-application mandate from [#849](https://github.com/michael-conrad/.opencode/issues/849) and the three reference cards (250, 255, 257) | `string` | For each file: `grep -q "849\|250\|255\|257\|co.application"` on the file — returns 0 for all three | For any file missing the reference, add a cross-reference sentence in the substep preamble that identifies the co-application mandate and the three reference cards. |
| SC-7 | Behavioral enforcement test exists in `.opencode/tests/behaviors/` that verifies: spec-creation agent includes the Mean-vs-Expert self-check when producing a spec (stderr evidence of the substep being invoked) — confirm RED state (test fails before implementation) | `behavioral` | `bash .opencode/tests/behaviors/sc-enforcement-style-selfcheck.sh` — test MUST fail before implementation (RED) and pass after GREEN. Use `assert_stderr_pattern_present` on stderr for `Mean.*Expert` or `enforcement.style` tool call strings. | RED test fails before change → implement → GREEN test passes. If test infrastructure unavailable, write the test file first, confirm RED, then implement. |

**ALL-OR-NOTHING GATE:** All SCs MUST pass for implementation to be considered complete. Any SKIPPED is treated as FAIL. Any FAILED triggers autonomous remediation with re-verification. Double-failure halts with blocker report.

## Edge Cases

| Edge Case | Handling |
|-----------|----------|
| Spec has no Risk Analysis section | Item 1 gate and item 5 scan skip Risk Analysis check — mapping table entry for Risk Analysis is optional, not required |
| Spec has no Non-Goals section | Same as above — Non-Goals check is optional per spec-creation tier (non-goals are required for standard/complex, optional for minimal) |
| Spec author writes enforcement text that is Expert-framed but uses different wording than the pattern mapping table | The pattern mapping table defines structural categories (grep-detectable patterns per section type), not exact phrasing. Different but Expert-framed wording passes if it avoids the prohibited Mean patterns |
| Spec-auditor runs on a spec that was created before this spec's implementation | The spec-auditor scan reads live spec body — pattern compliance is per-spec, not gated on spec creation date. Pre-existing specs with Mean-framed language are flagged at audit time |
| Pre-pipeline gate runs before the co-application mandate [#849](https://github.com/michael-conrad/.opencode/issues/849) is implemented | The gate references the mandate but MUST NOT depend on its implementation — the gate uses structural checks (grep for prohibited patterns), not co-application verification. Co-application verification is a future enhancement |

## Dependencies

| Dependency | Type | Impact |
|---|---|---|
| [#848](https://github.com/michael-conrad/.opencode/issues/848) — 255-distribution-shifting-reference card | Content dependency | Pattern mapping table references dist-shift-002, dist-shift-004 — these pattern IDs MUST exist before spec verification commands can reference them |
| [#853](https://github.com/michael-conrad/.opencode/issues/853) — 257-procedural-discipline-reference card | Content dependency | Pipeline-level enforcement gates reference p-dis patterns — these MUST exist for the pre-pipeline gate to cite its authority |
| [#849](https://github.com/michael-conrad/.opencode/issues/849) — Mandatory co-application policy | Policy dependency | All three injection points reference the co-application mandate — SC-6 requires cross-references to #849 and the three cards |
| [#1060](https://github.com/michael-conrad/.opencode/issues/1060) — Spec structure expansion | Structural dependency | Non-Goals section is referenced by the pattern mapping table — #1060 makes Non-Goals a mandatory content area for standard/complex specs |
| [#1061](https://github.com/michael-conrad/.opencode/issues/1061) — SC coverage YAML, solve contracts, lifecycle manifest | Structural dependency | Pre-pipeline gate may use `solve` for validation — #1061 defines the solve contract convention |
| [#1062](https://github.com/michael-conrad/.opencode/issues/1062) — Handoff gates | Structural dependency | Pre-pipeline gate positioning between approval-gate and sc-coherence-gate must be consistent with #1062's handoff architecture |
| [#1063](https://github.com/michael-conrad/.opencode/issues/1063) — Pipeline enforcement gates | Structural dependency | Item 1 pre-pipeline gate is a pipeline enforcement gate — must be consistent with #1063's routing table |
| [#1064](https://github.com/michael-conrad/.opencode/issues/1064) — Writing-plans consumer awareness | Structural dependency | Spec-auditor scan reads spec body sections — output structure from #1064 affects how sections are identified |

## Risk

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Pattern mapping table IDs (dist-shift-002, dark-prose-003) change before this spec's implementation | Low | Medium — grep patterns become stale references | Verification uses grep patterns, not numeric IDs; the table is advisory context for the implementing agent |
| Spec-auditor enforcement scan produces false positives on creatively-framed Expert text | Medium | Low — flag-for-review classification handles this | Scan uses a narrow prohibited-pattern list (not broad style rules); flagged items go to flag-for-review, not auto-fix |
| Pre-pipeline gate adds latency to pipeline startup | Low | Low — structural grep checks complete in <1s | Gate uses grep-only checks, no model calls; latency is bounded by file read + regex |

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|-----------------|-------------------|---------|
| Local docs | `tmp/spec-output-requirements-analysis.md` | Extract items 1, 5, 6 content and pattern mapping tables |
| Direct source search | `grep -r "spec-audit" .opencode/skills/adversarial-audit/tasks/` | Verify spec-auditor task file exists and understand its structure |
| Direct source search | `grep -r "self.review\|Step 6" .opencode/skills/spec-creation/tasks/write.md` | Verify Step 6 self-review substeps exist and identify insertion point |
| MCP search | `srclight_search_symbols("assemble-work")` | Locate implementation-pipeline assemble-work task file for gate insertion point |
| Issue operations | [Issue #850](https://github.com/michael-conrad/.opencode/issues/850) body, [Issue #854](https://github.com/michael-conrad/.opencode/issues/854) coordination plan, [Issue #849](https://github.com/michael-conrad/.opencode/issues/849) co-application mandate, [Issue #853](https://github.com/michael-conrad/.opencode/issues/853) procedural discipline card, [Issue #848](https://github.com/michael-conrad/.opencode/issues/848) distribution-shifting card | Understand full dependency graph, coordination structure, and pattern definitions |

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)