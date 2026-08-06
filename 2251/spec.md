# SPEC — Remediate spec-creation Documentation-Sources column drift and analytical-artifact line-number references

## 1. Intent and Executive Summary

### Problem Statement

A validated spec (#2250, Plan Writer and Plan Audit remediation) surfaced two non-blocking audit warnings that are outside that spec's scope. Both are internal-consistency defects in agent-facing text and analytical artifacts:

1. **Stale "Documentation Sources column" instruction in the `spec-creation` skill.** The canonical `reference/spec-structure-standards.md` mandates the SC table has exactly 4 columns (ID, Criterion, Evidence Type, Verification Method) and treats Documentation Sources as a separate top-level §8 section (table: Source | Type | Location | Verification). Three occurrences in `skills/spec-creation/` wrongly instruct that the SC table must include a "Documentation Sources column". An agent following them would build an SC table that violates the canonical reference.

2. **Prescriptive line-number references in the analytical artifacts for spec #2250.** The artifacts at `.issues/2250/artifacts/` and `tmp/TBD/artifacts/` (byte-identical copies) embed exact line numbers in verification-method and evidence text (e.g., "holistic-dimensions.yaml lines 98-114", "writing-plans/SKILL.md line 13"). This violates `reference/spec-structure-standards.md` §Prohibited Content Patterns ("exact file paths with line numbers → FAIL"; use stable file-area references). Line numbers are brittle and shift on edit.

### Root Cause / Motivation

Both defects stem from drift between skill cards/task cards and the consolidated `reference/spec-structure-standards.md` after the reference migration, and from analytical artifacts copying verbose line-anchored source notes verbatim instead of converting to stable anchors. Because agent-facing text is consumed as routing instructions, the stale "column" instruction misroutes spec assembly, and the line-number references produce non-deterministic verification targets. Both must be remediated so downstream specs and audits are assembled against the canonical reference and verify against stable anchors.

### Approach Chosen

Apply exactly ONE prescriptive resolution per defect, mapped one-to-one to a success criterion (SC-1..SC-N). Changes are confined to agent-facing markdown/yaml files and analytical artifacts in `.opencode/` — no `src/` code changes. Decomposed into two concern-coherent phases: (1) fix the `spec-creation` Documentation-Sources column drift (3 text edits), (2) replace prescriptive line-number references with stable file-area references across the #2250 analytical artifacts (both `.issues/2250/artifacts/` and `tmp/TBD/artifacts/`).

### Alternatives Considered & Why Discarded

- **Full rewrite of the skill cards** — discarded: only 3 stale text occurrences exist; a rewrite risks new drift.
- **Deferring artifact cleanup** — discarded: artifacts are consumed by audits; non-deterministic anchors compound downstream verification failures.
- **Single monolithic fix commit** — discarded: violates per-SC TDD decomposition; each fix is independently verifiable.

## 2. Not Included

- Any change to the plan writer (`writing-plans`, `plan`) or plan audit (`audit`) skill card sets — those are spec #2250's scope.
- Any behavioral-enforcement-test work.
- Any change to `spec-structure-standards.md` itself — it is the authoritative reference and is correct.
- Any change to the spec #2250 body (`spec.md`) — it already uses stable anchors.
- Reformatting or rewriting artifact prose beyond stripping line-number references.

## 3. Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `spec-creation/tasks/validate.md` contains no "Documentation Sources column" instruction; it verifies the §8 Documentation Sources section | structural | grep `skills/spec-creation/tasks/validate.md` for "Documentation Sources column" returns zero; the conformance step references the §8 Documentation Sources section (Source, Type, Location, Verification table) |
| SC-2 | `spec-creation/tasks/create.md` contains no "Documentation Sources column(s)" instruction; it directs assembly of the §8 Documentation Sources section | structural | grep `skills/spec-creation/tasks/create.md` for "Documentation Sources column" returns zero; both the assembly step and the format-level exit-criteria checklist reference the §8 Documentation Sources section |
| SC-3 | `testability-assessment.yaml` (both `.issues/2250/artifacts/` and `tmp/TBD/artifacts/`) contains no prescriptive line-number references in verification methods | string | grep both copies for `line ` / `lines ` patterns returns zero; each verification method references a stable file-area anchor (e.g., `cross_reference.audit_gates`, `Overview`, `Purpose and Exit Criteria`, `description`) |
| SC-4 | `code-path-inventory.yaml` (both locations) contains no prescriptive line-number references | string | grep both copies for `line` / `lines` returns zero; touched-section values use stable file-area anchors |
| SC-5 | `pre-spec-inspection.yaml` (both locations) contains no `line:`/`lines:` keys and no embedded line numbers in evidence/defect/resolution text | string | grep both copies for `line:` / `lines:` keys and `line N` patterns returns zero; affected-file entries use `section:`/`sections:` fields with stable anchors |
| SC-6 | `research-card-consultation.yaml` and `state-analysis.yaml` (both locations) contain no prescriptive line-number references | string | grep both copies for `line` / `lines` returns zero; references use stable anchors |
| SC-7 | The two artifact locations `.issues/2250/artifacts/` and `tmp/TBD/artifacts/` remain byte-identical after remediation | string | `diff -r .issues/2250/artifacts/ tmp/TBD/artifacts/` returns no differences |

## 4. Requirements

- R-1. The `spec-creation` task cards SHALL direct spec assembly and validation against the canonical `reference/spec-structure-standards.md` §8 Documentation Sources section, not an SC-table "Documentation Sources column".
- R-2. The #2250 analytical artifacts SHALL use stable file-area references, not prescriptive line numbers, in all verification-method, evidence, defect, and resolution text.
- R-3. The two artifact copies (`.issues/2250/artifacts/` and `tmp/TBD/artifacts/`) SHALL be kept byte-identical.
- R-4. No change SHALL be made outside the affected `skills/spec-creation/` files and the #2250 analytical artifacts.

## 5. Items

### Item 1 (SC-1): Fix validate.md Documentation-Sources conformance step

- RED: grep `skills/spec-creation/tasks/validate.md` for "Documentation Sources column" — present.
- GREEN: replace line 54 text with a conformance step verifying the §8 Documentation Sources section.
- verify: grep for "Documentation Sources column" returns zero.
- commit: `skills/spec-creation/tasks/validate.md`

### Item 2 (SC-2): Fix create.md Documentation-Sources assembly step and exit checklist

- RED: grep `skills/spec-creation/tasks/create.md` for "Documentation Sources column" — present (lines 50, 116).
- GREEN: replace line 50 and line 116 to reference the §8 Documentation Sources section.
- verify: grep for "Documentation Sources column" returns zero.
- commit: `skills/spec-creation/tasks/create.md`

### Item 3 (SC-3): Fix testability-assessment.yaml line-number references (both copies)

- RED: grep both copies for `line ` / `lines ` — present (lines 30, 62, 68, 81).
- GREEN: replace each with the stable anchor (`cross_reference.audit_gates`, `Overview`, `Purpose and Exit Criteria`, `description`).
- verify: grep returns zero in both copies.
- commit: `.issues/2250/artifacts/testability-assessment.yaml`, `tmp/TBD/artifacts/testability-assessment.yaml`

### Item 4 (SC-4): Fix code-path-inventory.yaml line-number references (both copies)

- RED: grep both copies for `line` / `lines` — present (lines 46, 49, 56, 59, 62, 65, 68, 81).
- GREEN: replace each with stable file-area anchors.
- verify: grep returns zero in both copies.
- commit: `.issues/2250/artifacts/code-path-inventory.yaml`, `tmp/TBD/artifacts/code-path-inventory.yaml`

### Item 5 (SC-5): Fix pre-spec-inspection.yaml line keys and embedded line numbers (both copies)

- RED: grep both copies for `line:` / `lines:` and `line N` — present.
- GREEN: replace `line:`/`lines:` keys with `section:`/`sections:` fields and strip embedded line numbers from evidence/defect/resolution text per the exact mapping.
- verify: grep returns zero for `line:` / `lines:` keys and `line N` patterns in both copies.
- commit: `.issues/2250/artifacts/pre-spec-inspection.yaml`, `tmp/TBD/artifacts/pre-spec-inspection.yaml`

### Item 6 (SC-6): Fix research-card-consultation.yaml and state-analysis.yaml line references (both copies)

- RED: grep both copies for `line` / `lines` — present.
- GREEN: replace each with stable anchors.
- verify: grep returns zero in both copies.
- commit: `.issues/2250/artifacts/{research-card-consultation,state-analysis}.yaml`, `tmp/TBD/artifacts/{research-card-consultation,state-analysis}.yaml`

### Item 7 (SC-7): Verify artifact copies remain byte-identical

- RED: `diff -r .issues/2250/artifacts/ tmp/TBD/artifacts/` — expected to differ before both sides are edited consistently.
- GREEN: apply the same edits to both copies for every artifact.
- verify: `diff -r` returns no differences.
- commit: (no source change; verification gate)

## 6. Dependencies

- Item 3 depends on Item 2 pattern (stable-anchor style established in `create.md`/`validate.md`).
- Items 3-6 each touch both artifact copies; Item 7 verifies their identity.
- No external service dependencies.

## 7. Traceability

| Requirement | SCs |
|-------------|-----|
| R-1 | SC-1, SC-2 |
| R-2 | SC-3, SC-4, SC-5, SC-6 |
| R-3 | SC-7 |
| R-4 | SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7 |

| Phase | SCs |
|-------|-----|
| Phase 1: spec-creation Documentation-Sources drift | SC-1, SC-2 |
| Phase 2: analytical-artifact line-number references | SC-3, SC-4, SC-5, SC-6, SC-7 |

## 8. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|--------------|
| `reference/spec-structure-standards.md` | code | `.opencode/reference/` | read |
| `skills/spec-creation/tasks/validate.md` | code | `.opencode/skills/spec-creation/tasks/` | read |
| `skills/spec-creation/tasks/create.md` | code | `.opencode/skills/spec-creation/tasks/` | read |
| `.issues/2250/artifacts/testability-assessment.yaml` | data | `.opencode/.issues/2250/artifacts/` | read |
| `.issues/2250/artifacts/code-path-inventory.yaml` | data | `.opencode/.issues/2250/artifacts/` | read |
| `.issues/2250/artifacts/pre-spec-inspection.yaml` | data | `.opencode/.issues/2250/artifacts/` | read |
| `.issues/2250/artifacts/research-card-consultation.yaml` | data | `.opencode/.issues/2250/artifacts/` | read |
| `.issues/2250/artifacts/state-analysis.yaml` | data | `.opencode/.issues/2250/artifacts/` | read |
| `tmp/TBD/artifacts/` | data | `.opencode/tmp/TBD/artifacts/` | read |

## 9. Enforcement Gate

All SCs are structural/string consistency checks verified by `grep`, `diff`, and file reads against the live filesystem. No behavioral (`opencode run`) tests are required — the changes alter static agent-facing text and artifact content, not runtime dispatch behavior. This matches the evidence-type taxonomy in `reference/spec-structure-standards.md`.

## 10. Cost Frame (dark-prose-007)

- **Action cost:** Applying these edits is low — a handful of targeted text replacements in 2 task cards and 5 artifact files (2 copies each). Each change is deterministic and individually verifiable.
- **Skipping cost:** Skipping is expensive. The stale "Documentation Sources column" instruction misroutes every future spec assembled through `spec-creation`, producing SC tables that violate the canonical reference and fail validation. The line-number references in artifacts cause verification to target shifting lines, producing non-deterministic audit results and false PASS/FAIL across re-runs. **Correctness is the only success metric** — there is no score for speed, brevity, or economy.
- **Correctness anchor:** Each SC is binary and testable: grep/diff return zero for the prohibited pattern, and the two artifact copies remain byte-identical.

## 11. Edge Cases

- **Artifact regeneration:** If the spec-creation pipeline re-copies artifacts from `tmp/TBD/artifacts/` into `.issues/{N}/artifacts/`, both copies must be fixed so identity (SC-7) holds. This is why both locations are in scope.
- **Anchor existence:** Every stable anchor referenced (e.g., `cross_reference.audit_gates`, `## Overview`, `## Purpose`, `## Exit Criteria`, `description:`) is verified to exist in its target file before adoption; verification methods may add a fallback note if an anchor name differs.
- **Whitespace/format:** The YAML edits preserve structure and do not alter field semantics beyond the line→section key change in `pre-spec-inspection.yaml`.
- **Out-of-scope drift:** If additional line-number references are found in artifacts not listed here, they are flagged but not fixed by this spec.

## 12. Change Control

| Date | Change | Author |
|------|--------|--------|
| 2026-08-06 | Initial spec creation (issue #2251) | 🤖 OpenCode (ollama-cloud/deepseek-v4-flash:0731) |
