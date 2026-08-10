# Spec Structure Standards

Canonical reference document defining the required structure for specification documents. Both producers (`spec-creation/tasks/create.md`) and auditors (`spec-audit` tasks) read this document via `Read [Text](path)`.

## 1. Intent and Executive Summary

Every spec MUST open with a preamble containing exactly these 6 fields in order:

| # | Field | Description |
|---|-------|-------------|
| 1 | **Problem Statement** | What problem is being solved. Must be specific and testable — not a general observation. |
| 2 | **Root Cause / Motivation** | Why this problem exists and why it must be solved now. Distinguishes symptom from root cause. |
| 3 | **Approach Chosen** | The selected solution approach at a high level. Must be concrete enough to evaluate. |
| 4 | **Alternatives Considered & Why Discarded** | At least one alternative approach with a documented reason for rejection. "Not applicable" is not valid. |
| 5 | **Key Design Decisions** | Architectural or design choices that constrain implementation. Each decision must name a tradeoff. |
| 6 | **User Intent / Original Prompt** | The user's original request or trigger that motivated this spec. Preserves traceability to the source. |

This section subsumes any separate "Objective" or "Background" sections — those fields are covered by Problem Statement and Root Cause.

## 2. Not Included

Explicitly excluded scope. Every spec MUST list what is NOT being addressed. Each exclusion MUST include a brief rationale.

Format:

```
- **[Feature/Area]** — Rationale for exclusion
```

If nothing is excluded, state "Nothing is explicitly excluded" — do not omit the section.

## 3. Success Criteria

Table with exactly these 4 columns:

| Column | Required | Description |
|--------|----------|-------------|
| ID | Yes | Unique SC identifier (SC-1, SC-2, ...) |
| Criterion | Yes | What must be true for this SC to pass. Must be testable and unambiguous. |
| Evidence Type | Yes | One of: `structural`, `string`, `semantic`, `behavioral` |
| Verification Method | Yes | How the SC is verified. Must name a specific tool or procedure. |

Each SC maps to exactly one item in the Items section. No SC may cover multiple items, and no item may cover multiple SCs.

## 4. Requirements

Numbered requirements using SHALL language (RFC 2119). Each requirement MUST:

- Be numbered sequentially (R-1, R-2, ...)
- Use "SHALL" for mandatory requirements
- Use "SHOULD" for recommended requirements
- Use "MAY" for optional requirements
- Be testable independently

Format:

```
R-1. The system SHALL [behavior] under [condition].
R-2. The system SHOULD [behavior] under [condition].
```

## 5. Items

Per-SC item enumeration. Each SC maps to exactly one item. Items are numbered sequentially from 1.

Each item entry MUST include:

- **SC:** The SC ID this item implements
- **Description:** What this item produces
- **TDD cycle:** RED → GREEN → verify → commit

Format:

```
### Item N (SC-N): Description

- RED: [enforcement test that fails]
- GREEN: [implementation that makes it pass]
- verify: [verification procedure]
- commit: [commit scope]
```

## 6. Dependencies

Prerequisite specs, skills, guidelines, or other resources that must exist before this spec can be implemented.

Each dependency MUST include:

- **Reference:** Issue number, skill name, or file path
- **Relationship:** How this spec depends on it (e.g., "must be merged first", "must be read before implementation")
- **Status:** Whether the dependency is satisfied or pending

## 7. Traceability

Table mapping Requirements → SCs → Phases. Every requirement MUST trace to at least one SC. Every SC MUST trace to at least one requirement.

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-1, SC-2 | Phase 1 |
| R-2 | SC-3 | Phase 2 |

## 8. Documentation Sources

Table with Source, Type, Location, Verification columns. Every external source referenced in the spec MUST be documented here.

| Source | Type | Location | Verification |
|--------|------|----------|-------------|
| [Name] | [doc/code/config/API] | [URL or file path] | [How verified: live API call, read, grep] |

## 9. Enforcement Gate

All-or-nothing statement: all SCs MUST pass before this spec is considered complete. Partial implementation is not permitted.

Format:

```
> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.
```

## 10. Cost Frame

Per-SC cost-frame language following the dark-prose-007 pattern (see `reference/cost-model-standards.md`). Each SC MUST have a cost-frame statement that:

- Frames cost as defect-discovery-latency, not tool calls
- States the action cost: what it costs to do the verification
- States the skipping cost: what it costs to skip the verification
- Anchors in the identity: correctness is the only metric

Format:

```
- **SC-N:** [action] costs [magnitude] — [consequence]. Skipping costs [magnitude] — [consequence].
```

## 11. Edge Cases

Boundary conditions, failure modes, and their resolutions. Every spec MUST address at least the following categories:

- **Input boundaries:** Empty, null, maximum, minimum values
- **State transitions:** What happens at each state boundary
- **Failure modes:** What happens when dependencies fail, data is missing, or invariants are violated
- **Concurrency:** Race conditions, deadlocks, resource contention
- **Recovery:** How the system recovers from each failure mode

Each edge case MUST include:

- **Condition:** The boundary or failure scenario
- **Expected behavior:** How the system MUST respond
- **Resolution:** How the condition is handled (if applicable)

---

## SC Table Column Requirements

| Column | Required | Description |
|--------|----------|-------------|
| ID | Yes | Unique SC identifier (SC-1, SC-2, etc.) |
| Criterion | Yes | What must be true for this SC to pass |
| Evidence Type | Yes | One of: structural, string, semantic, behavioral |
| Verification Method | Yes | How the SC is verified |

## Evidence Type Taxonomy

| Type | Minimum Acceptable Evidence | Example |
|------|---------------------------|---------|
| `structural` | File existence | `ls path/to/file` |
| `string` | grep/pattern match | `grep for pattern` |
| `semantic` | Sub-agent read + judgment | Clean-room sub-agent reads and evaluates |
| `behavioral` | Test execution with output inspection | `opencode run` with assertion helpers |

**EVIDENCE_TYPE_MISMATCH rules:**
- Declared type `behavioral` with only structural evidence → FAIL
- Declared type `semantic` with only string evidence → FAIL
- A missing evidence-type declaration is a hard FAIL routed to the remediation workflow — it MUST NOT default to `string`, warn, or fall back to a backwards-compat tier

## Prohibited Content Patterns

- **Tracking/status language:** "implemented", "pending", "confirmed", "viable", "completed" used as status markers → FAIL
- Only forward-looking "MUST be" language is permitted
- **Prescriptive code:** exact file paths with line numbers, exact import strings, exact assertion code → FAIL
- Specs should use file area references only (e.g., "the producer template" not "line 42 of create.md")

## Format Requirements

- Pipeline gates use canonical checklist format: numbered `- [ ] N.` with dispatch mode indicators
- Gate tables (per-unit or shared cross-reference) → FAIL
- If spec defines plan output format requirements, they must use canonical checklist format
- Dispatch tables, shared cross-references → FAIL

---

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (deepseek-v4-flash)
