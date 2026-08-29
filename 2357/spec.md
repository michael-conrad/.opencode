---
number: 2357
title: '[SPEC] Condense 090-data-integrity.md — move batch/retention/classification to shared ref'
status: open
labels: [needs-approval, spec-draft]
---

> **Full spec and artifacts: [`.opencode/.issues/2357/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2357/)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2357/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

# Spec: Condense 090-data-integrity.md — move batch/retention/classification to shared ref

## 1. Intent and Executive Summary

| # | Field | Description |
|---|-------|-------------|
| 1 | **Problem Statement** | The preloaded `.opencode/guidelines/090-data-integrity.md` costs ~5.5k tokens in every orchestrator session. Roughly half of its content is procedural operational detail (batch operations, long-running tasks, serialization integrity, data classification, migration integrity, audit trail, data retention) that only sub-agents performing those operations need — not the orchestrator's safety-critical core. |
| 2 | **Root Cause / Motivation** | The 14,806-byte guideline is loaded wholesale into orchestrator system context on every session start, yet only the zero-tolerance cores (no-synthetic-data, fail-fast, no-unauthorized-semantic-change, production-data-protection, no-hardcoded-entity-ids, data-validation-at-boundaries) are safety-critical routing content. The procedural half inflates orchestrator context with detail that belongs in on-demand sub-agent context, violating the Orchestrator Context Lean model. The established `.opencode/reference/` pattern (cost-model-standards.md, plan-structure-standards.md) already proves shared reference docs loaded via mandatory Read-links work. |
| 3 | **Approach Chosen** | Create `.opencode/reference/data-integrity-reference.md` as the shared home for the seven procedural sections, relocated verbatim from 090. Condense `090-data-integrity.md` to retain only the zero-tolerance cores (plus the mixed Verify Before Recommend section) preloaded. Add mandatory `Read [Text](path)` links in the condensed guideline to the shared reference for the relocated topics, per the Read-Link Cross-Reference Rule. Keep `090-data-integrity.md` in the `opencode.jsonc` instructions array unchanged. |
| 4 | **Alternatives Considered & Why Discarded** | **Alternative: leave the guideline unchanged.** Discarded — the ~2.7k token savings target is the issue's stated benefit, and leaving ~50% procedural content preloaded is exactly the context waste this issue exists to remove. **Alternative: delete the procedural content outright.** Discarded — relocation is not deletion; the procedural rules (batch-size limits, tqdm mandate, serialization versioning, retention windows) must remain enforceable. **Alternative: re-inline procedural rules into each consuming skill.** Discarded — duplicates content across files, creates drift risk, and defeats the single-source-of-truth convention already established by `.opencode/reference/`. |
| 5 | **Key Design Decisions** | (1) The shared reference is a prose reference document consumed via mandatory Read-links — NOT a preloaded guideline and NOT a task card; it enters sub-agent context on demand, keeping orchestrator context lean. (2) Cores stay in the preloaded guideline verbatim — removing or weakening no-synthetic-data is the #497-class safety regression; this is a hard invariant. (3) Cross-references use the mandatory `Read [Text](path)` form exclusively — bare `See §` citations are defective per the Read-Link Cross-Reference Rule. (4) `opencode.jsonc` instructions array is NOT modified — `090-data-integrity.md` remains preloaded. |
| 6 | **User Intent / Original Prompt** | Issue #2357: "Condense 090-data-integrity.md — move batch/retention/classification to shared ref." The requirement is to relocate the procedural sections to a shared data-integrity reference loaded via mandatory Read-links, retain the zero-tolerance cores preloaded, and realize ~2.7k token savings without losing any data-integrity rule. |

## 2. Not Included

- **Removing any data-integrity zero-tolerance core** — All zero-tolerance cores (Global Absolute Prohibition, Fail-Fast, No Unauthorized Semantic Changes, Production Data Protection, No Hardcoded Entity IDs, Data Validation at System Boundaries) stay in the preloaded guideline verbatim. Explicitly out of scope per the issue.
- **Changing the no-synthetic-data prohibition language** — The Global Absolute Prohibition wording is retained verbatim; no rewording is permitted.
- **Modifying the `opencode.jsonc` instructions array** — No instruction entry is removed; `090-data-integrity.md` stays preloaded. Only the guideline file's content changes.
- **Modifying the `INDEX.md` entry for 090** — Trigger patterns (data integrity, mutable, mutation, database, production data) are core-based and retained, so no routing-metadata edit is expected.
- **Adding sub-issue or task-card artifacts** — Only the shared reference file, the condensed guideline, and Read-links are produced.
- **Relocating the Verify Before Recommend section** — It is a mixed section; its core sub-rules remain in 090 (procedural sub-rules stay in place per the issue's relocation set).

## 3. Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Documentation Sources |
|----|-----------|---------------|---------------------|----------------------|
| SC-1 | The file `.opencode/reference/data-integrity-reference.md` exists. | structural | `file-exists` check on `.opencode/reference/data-integrity-reference.md` | `.opencode/reference/` |
| SC-2 | The reference file contains the `## Batch Operations` section content. | string | `grep` for `## Batch Operations` and the POSTGRESQL PARAMETER LIMIT rule line | `.opencode/reference/data-integrity-reference.md` |
| SC-3 | The reference file contains the `## Long-Running Tasks` section content. | string | `grep` for `## Long-Running Tasks` and the `tqdm` mandate line | `.opencode/reference/data-integrity-reference.md` |
| SC-4 | The reference file contains the `## Serialization Integrity` section content. | string | `grep` for `## Serialization Integrity` and the VERSION ALL SERIALIZED FORMATS rule line | `.opencode/reference/data-integrity-reference.md` |
| SC-5 | The reference file contains the `## Data Classification` section content. | string | `grep` for `## Data Classification` and the CLASSIFY DATA BY SENSITIVITY rule line | `.opencode/reference/data-integrity-reference.md` |
| SC-6 | The reference file contains the `## Migration Integrity` section content. | string | `grep` for `## Migration Integrity` and the MAKE ALL DATA MIGRATIONS REVERSIBLE rule line | `.opencode/reference/data-integrity-reference.md` |
| SC-7 | The reference file contains the `## Audit Trail` section content. | string | `grep` for `## Audit Trail` and the EVERY DATA MUTATION TRACEABLE rule line | `.opencode/reference/data-integrity-reference.md` |
| SC-8 | The reference file contains the `## Data Retention` section content. | string | `grep` for `## Data Retention` and the DEFINE RETENTION POLICIES rule line | `.opencode/reference/data-integrity-reference.md` |
| SC-9 | The reference file does NOT contain the `## Global Absolute Prohibition` section header. | string | `grep` confirms absence of `## Global Absolute Prohibition` in the reference file | `.opencode/reference/data-integrity-reference.md` |
| SC-10 | The reference file contains the `Provenance: AI-generated` header line. | string | `grep` for `Provenance: AI-generated` in the reference file | `.opencode/reference/data-integrity-reference.md` |
| SC-11 | The condensed `090-data-integrity.md` does NOT contain the `## Batch Operations` section header. | string | `grep` confirms absence of `## Batch Operations` in the condensed guideline | `.opencode/guidelines/090-data-integrity.md` |
| SC-12 | The condensed `090-data-integrity.md` does NOT contain the `## Long-Running Tasks` section header. | string | `grep` confirms absence of `## Long-Running Tasks` in the condensed guideline | `.opencode/guidelines/090-data-integrity.md` |
| SC-13 | The condensed `090-data-integrity.md` does NOT contain the `## Serialization Integrity` section header. | string | `grep` confirms absence of `## Serialization Integrity` in the condensed guideline | `.opencode/guidelines/090-data-integrity.md` |
| SC-14 | The condensed `090-data-integrity.md` does NOT contain the `## Data Classification` section header. | string | `grep` confirms absence of `## Data Classification` in the condensed guideline | `.opencode/guidelines/090-data-integrity.md` |
| SC-15 | The condensed `090-data-integrity.md` does NOT contain the `## Migration Integrity` section header. | string | `grep` confirms absence of `## Migration Integrity` in the condensed guideline | `.opencode/guidelines/090-data-integrity.md` |
| SC-16 | The condensed `090-data-integrity.md` does NOT contain the `## Audit Trail` section header. | string | `grep` confirms absence of `## Audit Trail` in the condensed guideline | `.opencode/guidelines/090-data-integrity.md` |
| SC-17 | The condensed `090-data-integrity.md` does NOT contain the `## Data Retention` section header. | string | `grep` confirms absence of `## Data Retention` in the condensed guideline | `.opencode/guidelines/090-data-integrity.md` |
| SC-18 | The condensed `090-data-integrity.md` retains the `## Global Absolute Prohibition` section header. | string | `grep` for `## Global Absolute Prohibition` in the condensed guideline | `.opencode/guidelines/090-data-integrity.md` |
| SC-19 | The condensed `090-data-integrity.md` retains the `## Fail-Fast` section header. | string | `grep` for `## Fail-Fast` in the condensed guideline | `.opencode/guidelines/090-data-integrity.md` |
| SC-20 | The condensed `090-data-integrity.md` retains the `## No Unauthorized Semantic Changes` section header. | string | `grep` for `## No Unauthorized Semantic Changes` in the condensed guideline | `.opencode/guidelines/090-data-integrity.md` |
| SC-21 | The condensed `090-data-integrity.md` retains the `## Production Data Protection` section header. | string | `grep` for `## Production Data Protection` in the condensed guideline | `.opencode/guidelines/090-data-integrity.md` |
| SC-22 | The condensed `090-data-integrity.md` retains the `## No Hardcoded Entity IDs` section header. | string | `grep` for `## No Hardcoded Entity IDs` in the condensed guideline | `.opencode/guidelines/090-data-integrity.md` |
| SC-23 | The condensed `090-data-integrity.md` retains the `## Data Validation at System Boundaries` section header. | string | `grep` for `## Data Validation at System Boundaries` in the condensed guideline | `.opencode/guidelines/090-data-integrity.md` |
| SC-24 | The condensed `090-data-integrity.md` retains the `## Verify Before Recommend` section header. | string | `grep` for `## Verify Before Recommend` in the condensed guideline | `.opencode/guidelines/090-data-integrity.md` |
| SC-25 | The condensed `090-data-integrity.md` contains the mandatory `Read [Text](.opencode/reference/data-integrity-reference.md)` link. | string | `grep` for the `Read [Text](.opencode/reference/data-integrity-reference.md)` imperative link form in the condensed guideline | `.opencode/guidelines/090-data-integrity.md` |
| SC-26 | The condensed `090-data-integrity.md` contains no bare `See §` citation for the relocated data-integrity content. | string | `grep` confirms absence of `See §` patterns referencing the relocated content in the condensed guideline | `.opencode/guidelines/090-data-integrity.md` |
| SC-27 | The condensed `090-data-integrity.md` achieves approximately 2,700 tokens of savings relative to the original 14,806-byte file. | structural | Measure byte count (and token estimate) of the condensed guideline against the original; assert ~50% reduction | `.opencode/guidelines/090-data-integrity.md` |
| SC-28 | The `.opencode/opencode.jsonc` instructions array retains `.opencode/guidelines/090-data-integrity.md` as a preload entry. | structural | `grep`/config diff of the `instructions` array in `.opencode/opencode.jsonc`; assert the 090 entry remains present | `.opencode/opencode.jsonc` |
| SC-29 | An agent prompted to fabricate synthetic data still refuses after the condensation. | behavioral | `opencode run` (via `with-test-home`) with a synthetic-data prompt; assert stderr shows the agent refusing to fabricate data | `.opencode/guidelines/090-data-integrity.md` |
| SC-30 | An agent prompted for a batch-operations procedure follows the shared reference's batch-size/pagination rules via the Read-link. | behavioral | `opencode run` (via `with-test-home`) with a batch-operations prompt; assert stderr shows the agent following the reference's batch rules | `.opencode/reference/data-integrity-reference.md` |

## 4. Requirements

R-1. The system SHALL create `.opencode/reference/data-integrity-reference.md` as the shared data-integrity reference document.

R-2. The shared reference SHALL contain the relocated procedural sections (Batch Operations, Long-Running Tasks, Serialization Integrity, Data Classification, Migration Integrity, Audit Trail, Data Retention) with their original content preserved.

R-3. The shared reference SHALL NOT contain any zero-tolerance core section (Global Absolute Prohibition, Fail-Fast, No Unauthorized Semantic Changes, Production Data Protection, No Hardcoded Entity IDs, Data Validation at System Boundaries).

R-4. The shared reference SHALL follow the `.opencode/reference/` file conventions including the provenance header.

R-5. The condensed `090-data-integrity.md` SHALL remove the relocated procedural sections (Batch Operations, Long-Running Tasks, Serialization Integrity, Data Classification, Migration Integrity, Audit Trail, Data Retention).

R-6. The condensed `090-data-integrity.md` SHALL retain the zero-tolerance core sections (Global Absolute Prohibition, Fail-Fast, No Unauthorized Semantic Changes, Production Data Protection, No Hardcoded Entity IDs, Data Validation at System Boundaries) and the Verify Before Recommend section.

R-7. The condensed `090-data-integrity.md` SHALL link to the shared reference using the mandatory `Read [Text](path)` form.

R-8. The condensed `090-data-integrity.md` SHALL NOT use bare `See §` citations for the relocated content.

R-9. The condensed `090-data-integrity.md` SHALL achieve approximately 2,700 tokens of savings relative to the original file.

R-10. The `.opencode/opencode.jsonc` instructions array SHALL retain `.opencode/guidelines/090-data-integrity.md` as a preload entry.

R-11. The zero-tolerance data-integrity cores SHALL remain behaviorally enforceable after the condensation.

R-12. The relocated procedural rules SHALL remain reachable through the shared reference so agents follow them.

## 5. Items

Each item maps to exactly one success criterion (1:1 item-SC mapping), giving each SC its own RED/GREEN/verify/commit cycle.

### Item 1 (SC-1): Create the shared data-integrity reference file

- RED (SC-1): Enforcement test asserts `.opencode/reference/data-integrity-reference.md` does not yet exist.
- GREEN (SC-1): Create `.opencode/reference/data-integrity-reference.md` with the relocated procedural sections and provenance header.
- verify (SC-1): `file-exists` check on `.opencode/reference/data-integrity-reference.md`.
- commit (SC-1): The new reference file.

### Item 2 (SC-2): Include the Batch Operations section in the reference

- RED (SC-2): Enforcement test asserts the reference does not contain `## Batch Operations`.
- GREEN (SC-2): Add the Batch Operations section content (relocated verbatim from the original 090) to the reference.
- verify (SC-2): `grep` the reference for `## Batch Operations` and the POSTGRESQL PARAMETER LIMIT rule line.
- commit (SC-2): The reference file.

### Item 3 (SC-3): Include the Long-Running Tasks section in the reference

- RED (SC-3): Enforcement test asserts the reference does not contain `## Long-Running Tasks`.
- GREEN (SC-3): Add the Long-Running Tasks section content (relocated verbatim) to the reference.
- verify (SC-3): `grep` the reference for `## Long-Running Tasks` and the `tqdm` mandate line.
- commit (SC-3): The reference file.

### Item 4 (SC-4): Include the Serialization Integrity section in the reference

- RED (SC-4): Enforcement test asserts the reference does not contain `## Serialization Integrity`.
- GREEN (SC-4): Add the Serialization Integrity section content (relocated verbatim) to the reference.
- verify (SC-4): `grep` the reference for `## Serialization Integrity` and the VERSION ALL SERIALIZED FORMATS rule line.
- commit (SC-4): The reference file.

### Item 5 (SC-5): Include the Data Classification section in the reference

- RED (SC-5): Enforcement test asserts the reference does not contain `## Data Classification`.
- GREEN (SC-5): Add the Data Classification section content (relocated verbatim) to the reference.
- verify (SC-5): `grep` the reference for `## Data Classification` and the CLASSIFY DATA BY SENSITIVITY rule line.
- commit (SC-5): The reference file.

### Item 6 (SC-6): Include the Migration Integrity section in the reference

- RED (SC-6): Enforcement test asserts the reference does not contain `## Migration Integrity`.
- GREEN (SC-6): Add the Migration Integrity section content (relocated verbatim) to the reference.
- verify (SC-6): `grep` the reference for `## Migration Integrity` and the MAKE ALL DATA MIGRATIONS REVERSIBLE rule line.
- commit (SC-6): The reference file.

### Item 7 (SC-7): Include the Audit Trail section in the reference

- RED (SC-7): Enforcement test asserts the reference does not contain `## Audit Trail`.
- GREEN (SC-7): Add the Audit Trail section content (relocated verbatim) to the reference.
- verify (SC-7): `grep` the reference for `## Audit Trail` and the EVERY DATA MUTATION TRACEABLE rule line.
- commit (SC-7): The reference file.

### Item 8 (SC-8): Include the Data Retention section in the reference

- RED (SC-8): Enforcement test asserts the reference does not contain `## Data Retention`.
- GREEN (SC-8): Add the Data Retention section content (relocated verbatim) to the reference.
- verify (SC-8): `grep` the reference for `## Data Retention` and the DEFINE RETENTION POLICIES rule line.
- commit (SC-8): The reference file.

### Item 9 (SC-9): Exclude core sections from the reference

- RED (SC-9): Enforcement test asserts the reference contains the `## Global Absolute Prohibition` header.
- GREEN (SC-9): Ensure the reference does not contain any zero-tolerance core section header.
- verify (SC-9): `grep` confirms absence of `## Global Absolute Prohibition` in the reference.
- commit (SC-9): The reference file.

### Item 10 (SC-10): Add the provenance header to the reference

- RED (SC-10): Enforcement test asserts the reference lacks the `Provenance: AI-generated` header line.
- GREEN (SC-10): Add the provenance header line to the reference file header block.
- verify (SC-10): `grep` the reference for `Provenance: AI-generated`.
- commit (SC-10): The reference file.

### Item 11 (SC-11): Remove the Batch Operations section from 090

- RED (SC-11): Enforcement test asserts the condensed guideline still contains `## Batch Operations`.
- GREEN (SC-11): Remove the Batch Operations section from `090-data-integrity.md`.
- verify (SC-11): `grep` confirms absence of `## Batch Operations` in the condensed guideline.
- commit (SC-11): The condensed guideline.

### Item 12 (SC-12): Remove the Long-Running Tasks section from 090

- RED (SC-12): Enforcement test asserts the condensed guideline still contains `## Long-Running Tasks`.
- GREEN (SC-12): Remove the Long-Running Tasks section from `090-data-integrity.md`.
- verify (SC-12): `grep` confirms absence of `## Long-Running Tasks` in the condensed guideline.
- commit (SC-12): The condensed guideline.

### Item 13 (SC-13): Remove the Serialization Integrity section from 090

- RED (SC-13): Enforcement test asserts the condensed guideline still contains `## Serialization Integrity`.
- GREEN (SC-13): Remove the Serialization Integrity section from `090-data-integrity.md`.
- verify (SC-13): `grep` confirms absence of `## Serialization Integrity` in the condensed guideline.
- commit (SC-13): The condensed guideline.

### Item 14 (SC-14): Remove the Data Classification section from 090

- RED (SC-14): Enforcement test asserts the condensed guideline still contains `## Data Classification`.
- GREEN (SC-14): Remove the Data Classification section from `090-data-integrity.md`.
- verify (SC-14): `grep` confirms absence of `## Data Classification` in the condensed guideline.
- commit (SC-14): The condensed guideline.

### Item 15 (SC-15): Remove the Migration Integrity section from 090

- RED (SC-15): Enforcement test asserts the condensed guideline still contains `## Migration Integrity`.
- GREEN (SC-15): Remove the Migration Integrity section from `090-data-integrity.md`.
- verify (SC-15): `grep` confirms absence of `## Migration Integrity` in the condensed guideline.
- commit (SC-15): The condensed guideline.

### Item 16 (SC-16): Remove the Audit Trail section from 090

- RED (SC-16): Enforcement test asserts the condensed guideline still contains `## Audit Trail`.
- GREEN (SC-16): Remove the Audit Trail section from `090-data-integrity.md`.
- verify (SC-16): `grep` confirms absence of `## Audit Trail` in the condensed guideline.
- commit (SC-16): The condensed guideline.

### Item 17 (SC-17): Remove the Data Retention section from 090

- RED (SC-17): Enforcement test asserts the condensed guideline still contains `## Data Retention`.
- GREEN (SC-17): Remove the Data Retention section from `090-data-integrity.md`.
- verify (SC-17): `grep` confirms absence of `## Data Retention` in the condensed guideline.
- commit (SC-17): The condensed guideline.

### Item 18 (SC-18): Retain the Global Absolute Prohibition core in 090

- RED (SC-18): Enforcement test asserts the condensed guideline lacks `## Global Absolute Prohibition`.
- GREEN (SC-18): Ensure the Global Absolute Prohibition core section remains verbatim in `090-data-integrity.md`.
- verify (SC-18): `grep` the condensed guideline for `## Global Absolute Prohibition` and the NO SYNTHETIC rule line.
- commit (SC-18): The condensed guideline.

### Item 19 (SC-19): Retain the Fail-Fast core in 090

- RED (SC-19): Enforcement test asserts the condensed guideline lacks `## Fail-Fast`.
- GREEN (SC-19): Ensure the Fail-Fast core section remains verbatim in `090-data-integrity.md`.
- verify (SC-19): `grep` the condensed guideline for `## Fail-Fast`.
- commit (SC-19): The condensed guideline.

### Item 20 (SC-20): Retain the No Unauthorized Semantic Changes core in 090

- RED (SC-20): Enforcement test asserts the condensed guideline lacks `## No Unauthorized Semantic Changes`.
- GREEN (SC-20): Ensure the No Unauthorized Semantic Changes core section remains verbatim in `090-data-integrity.md`.
- verify (SC-20): `grep` the condensed guideline for `## No Unauthorized Semantic Changes`.
- commit (SC-20): The condensed guideline.

### Item 21 (SC-21): Retain the Production Data Protection core in 090

- RED (SC-21): Enforcement test asserts the condensed guideline lacks `## Production Data Protection`.
- GREEN (SC-21): Ensure the Production Data Protection core section remains verbatim in `090-data-integrity.md`.
- verify (SC-21): `grep` the condensed guideline for `## Production Data Protection`.
- commit (SC-21): The condensed guideline.

### Item 22 (SC-22): Retain the No Hardcoded Entity IDs core in 090

- RED (SC-22): Enforcement test asserts the condensed guideline lacks `## No Hardcoded Entity IDs`.
- GREEN (SC-22): Ensure the No Hardcoded Entity IDs core section remains verbatim in `090-data-integrity.md`.
- verify (SC-22): `grep` the condensed guideline for `## No Hardcoded Entity IDs`.
- commit (SC-22): The condensed guideline.

### Item 23 (SC-23): Retain the Data Validation at System Boundaries core in 090

- RED (SC-23): Enforcement test asserts the condensed guideline lacks `## Data Validation at System Boundaries`.
- GREEN (SC-23): Ensure the Data Validation at System Boundaries core section remains verbatim in `090-data-integrity.md`.
- verify (SC-23): `grep` the condensed guideline for `## Data Validation at System Boundaries`.
- commit (SC-23): The condensed guideline.

### Item 24 (SC-24): Retain the Verify Before Recommend section in 090

- RED (SC-24): Enforcement test asserts the condensed guideline lacks `## Verify Before Recommend`.
- GREEN (SC-24): Ensure the Verify Before Recommend section remains in `090-data-integrity.md`.
- verify (SC-24): `grep` the condensed guideline for `## Verify Before Recommend`.
- commit (SC-24): The condensed guideline.

### Item 25 (SC-25): Add the mandatory Read-link to the shared reference in 090

- RED (SC-25): Enforcement test asserts the condensed guideline lacks the `Read [Text](.opencode/reference/data-integrity-reference.md)` link.
- GREEN (SC-25): Add the mandatory `Read [Text](.opencode/reference/data-integrity-reference.md)` link for the relocated topics in `090-data-integrity.md`.
- verify (SC-25): `grep` the condensed guideline for the imperative `Read [Text](path)` link form.
- commit (SC-25): The condensed guideline.

### Item 26 (SC-26): Remove bare See citations from 090

- RED (SC-26): Enforcement test asserts the condensed guideline contains a bare `See §` citation for relocated content.
- GREEN (SC-26): Replace any bare `See §` citation for relocated content with the mandatory `Read [Text](path)` form in `090-data-integrity.md`.
- verify (SC-26): `grep` confirms absence of bare `See §` patterns referencing relocated content in the condensed guideline.
- commit (SC-26): The condensed guideline.

### Item 27 (SC-27): Verify the token-savings target

- RED (SC-27): Enforcement test asserts the condensed guideline's savings are below the ~2.7k target.
- GREEN (SC-27): Confirm the condensation of `090-data-integrity.md` yields approximately 2,700 tokens of savings.
- verify (SC-27): Measure the byte count (and token estimate) of the condensed guideline against the original 14,806 bytes; assert ~50% reduction.
- commit (SC-27): The measurement evidence artifact.

### Item 28 (SC-28): Verify the opencode.jsonc preload invariance

- RED (SC-28): Enforcement test asserts `.opencode/guidelines/090-data-integrity.md` is absent from the `opencode.jsonc` instructions array.
- GREEN (SC-28): Confirm the instructions array retains the 090 preload entry; no config edit is made.
- verify (SC-28): `grep`/config diff of the `instructions` array in `.opencode/opencode.jsonc`; assert the 090 entry remains present.
- commit (SC-28): The preload verification evidence artifact.

### Item 29 (SC-29): Verify behavioral enforcement of the no-synthetic-data core

- RED (SC-29): Behavioral test dispatches a synthetic-data prompt via `opencode run` and asserts the agent does NOT refuse to fabricate data (core lost).
- GREEN (SC-29): Confirm the condensed guideline still enforces the no-synthetic-data core behaviorally.
- verify (SC-29): Run `opencode run` (via `with-test-home`) with a synthetic-data prompt; assert stderr shows the agent refusing to fabricate data.
- commit (SC-29): The behavioral enforcement evidence artifact.

### Item 30 (SC-30): Verify behavioral reachability of the batch rules

- RED (SC-30): Behavioral test dispatches a batch-operations prompt via `opencode run` and asserts the agent does NOT follow batch-size/pagination rules (reference unreachable).
- GREEN (SC-30): Confirm the batch rules are reachable via the shared reference Read-link.
- verify (SC-30): Run `opencode run` (via `with-test-home`) with a batch-operations prompt; assert stderr shows the agent following the reference's batch rules.
- commit (SC-30): The behavioral reachability evidence artifact.

## 6. Dependencies

| Reference | Relationship | Status |
|-----------|--------------|--------|
| `.opencode/guidelines/090-data-integrity.md` | Source of the relocated procedural sections and the retained cores. Must be read before implementation. | Satisfied — content present in the current guideline. |
| `opencode.jsonc` preload (instructions array) | Must remain unchanged — the 090 entry stays preloaded. | Satisfied — no config change planned. |
| AGENTS.md Read-Link Cross-Reference Rule | Mandates the `Read [Text](path)` imperative link form; bare `See §` citations are defective. | Satisfied — rule is active. |
| `.opencode/reference/` reference-doc convention | The new reference must follow the existing prose reference format (cost-model-standards.md precedent). | Satisfied — convention established. |
| `.opencode/guidelines/INDEX.md` | Routing metadata for 090; trigger patterns are core-based and retained, so no edit is expected. | Satisfied — no change needed. |

## 7. Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-1 | Phase 1 |
| R-2 | SC-2, SC-3, SC-4, SC-5, SC-6, SC-7, SC-8 | Phase 1 |
| R-3 | SC-9 | Phase 1 |
| R-4 | SC-10 | Phase 1 |
| R-5 | SC-11, SC-12, SC-13, SC-14, SC-15, SC-16, SC-17 | Phase 2 |
| R-6 | SC-18, SC-19, SC-20, SC-21, SC-22, SC-23, SC-24 | Phase 2 |
| R-7 | SC-25 | Phase 3 |
| R-8 | SC-26 | Phase 3 |
| R-9 | SC-27 | Phase 4 |
| R-10 | SC-28 | Phase 4 |
| R-11 | SC-29 | Phase 4 |
| R-12 | SC-30 | Phase 4 |

## 8. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|--------------|
| `090-data-integrity.md` | guideline | `.opencode/guidelines/090-data-integrity.md` | read — current content at 14,806 bytes, 145 lines; core sections lines 9-77, procedural sections lines 78-132 |
| `data-integrity-reference.md` (planned) | reference | `.opencode/reference/data-integrity-reference.md` | to be created — target path for relocated sections |
| `opencode.jsonc` | config | `.opencode/opencode.jsonc` | read — instructions array retains 090 at line 87 |
| AGENTS.md Read-Link Cross-Reference Rule | guideline | `.opencode/AGENTS.md` | read — mandates `Read [Text](path)` |
| `INDEX.md` | guideline | `.opencode/guidelines/INDEX.md` | read — 090 entry with core trigger patterns |
| `.opencode/reference/` reference-doc convention | reference | `.opencode/reference/` | read — cost-model-standards.md precedent for prose reference format |
| `spec-structure-standards.md` | reference | `.opencode/reference/spec-structure-standards.md` | read — SC table, atomicity, and format requirements |

## 9. Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## 10. Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- **SC-1:** Verifying the reference file exists costs one file-existence check. Skipping means the shared reference is never created, leaving the procedural content stranded in the preloaded guideline and the condensation impossible.
- **SC-2, SC-3, SC-4, SC-5, SC-6, SC-7, SC-8:** Verifying each of the seven relocated sections is present in the reference costs one grep search each. Skipping means a missing section is silently lost during condensation — a content-loss defect that ships and surfaces only when a sub-agent needs the missing rule.
- **SC-9:** Verifying the reference excludes the core sections costs one grep search. Skipping means a core is accidentally relocated, removing it from preload and triggering the #497-class safety regression.
- **SC-10:** Verifying the provenance header costs one grep search. Skipping means the reference violates the repository's attribution convention.
- **SC-11, SC-12, SC-13, SC-14, SC-15, SC-16, SC-17:** Verifying each of the seven procedural sections is absent from the condensed guideline costs one grep search each. Skipping means a section remains preloaded, defeating the savings target and leaving orchestrator context inflated.
- **SC-18, SC-19, SC-20, SC-21, SC-22, SC-23, SC-24:** Verifying each retained core section remains in the condensed guideline costs one grep search each. Skipping means a zero-tolerance core is silently weakened or removed — the highest-cost defect this spec can ship.
- **SC-25:** Verifying the mandatory Read-link costs one grep search. Skipping means sub-agents never load the shared reference, and the relocated procedural content becomes unreachable — the exact defect this spec exists to prevent.
- **SC-26:** Verifying the absence of bare See citations costs one grep search. Skipping means a defective citation form (42-58% access) leaves the relocated content effectively lost.
- **SC-27:** Measuring the token savings costs one byte-count command. Skipping means the ~2.7k savings target is never confirmed and the condensation benefit is unverified.
- **SC-28:** Verifying the preload invariance costs one config diff. Skipping means an accidental removal of the 090 preload entry ships — the #497 safety regression returns.
- **SC-29:** Running the behavioral no-synthetic-data test costs minutes of execution time. Skipping means the core prohibition's enforceability after condensation is unverified — a behavioral defect that ships and costs 1000× more to rediscover in production.
- **SC-30:** Running the behavioral batch-rules reachability test costs minutes of execution time. Skipping means the relocated procedural content is unverifiably reachable — a death-spiral defect where the reference exists but is never loaded.

## 11. Edge Cases

| Condition | Expected Behavior | Resolution |
|-----------|-------------------|------------|
| **Input boundary: procedural section already partially moved** | If a prior partial change already relocated some sections, the remaining sections must still be relocated without duplication. | Diff the reference against the source; relocate only missing sections; no content is duplicated. |
| **State transition: 090 ABSENT → REFERENCE-PRESENT → CONDENSED** | The reference must exist before the guideline is condensed and linked. | Strictly sequential phases (1 → 2 → 3); SC-1 (reference exists) gates SC-11..SC-24 (condensation). |
| **Failure mode: core section accidentally relocated** | If a zero-tolerance core (e.g., Global Absolute Prohibition) is moved to the reference, it leaves preload — the #497-class safety regression. | SC-9 (reference excludes cores) and SC-18..SC-24 (090 retains cores) block the regression; revert the relocation. |
| **Failure mode: preload entry removed** | If the `opencode.jsonc` instructions array drops the 090 entry, the guideline stops loading at session start. | SC-28 preload-invariance verification detects and blocks; restore the entry. |
| **Failure mode: Read-link uses bare See form** | A bare `See §` citation (42-58% access) leaves the relocated content effectively unreachable. | SC-26 verification detects; replace with the mandatory `Read [Text](path)` form. |
| **Concurrency: parallel edits to 090 or the reference** | Concurrent agent edits to the guideline or reference could conflict. | Rebase-always hygiene; resolve conflicts per the `conflict-resolution` skill. |
| **Recovery: savings target not met** | If the condensation does not achieve ~2.7k savings, procedural content likely remains in the guideline. | SC-27 measurement detects; re-run condensation to remove remaining procedural sections. |
| **Recovery: behavioral enforcement regression** | If the no-synthetic-data core is no longer enforced after condensation. | SC-29 behavioral test detects; restore the verbatim core text in the condensed guideline. |
| **Recovery: reference unreachable** | If a batch-operations agent does not follow the reference's rules. | SC-30 behavioral test detects; verify and repair the mandatory Read-link. |

## Change Control

| Date | Change | Reason | Authorized By |
|------|--------|--------|---------------|
| 2026-08-28 | Initial creation. Decomposed the six analysis items into 30 atomic SCs (1:1 item-SC mapping): SC-1 reference existence, SC-2..SC-8 one SC per relocated section, SC-9 core-exclusion, SC-10 provenance header, SC-11..SC-17 one SC per removed section, SC-18..SC-24 one SC per retained core/section, SC-25 Read-link presence, SC-26 bare-See absence, SC-27 savings, SC-28 preload invariance, SC-29/SC-30 behavioral. | Atomicity mandate: each SC asserts exactly one independently verifiable claim; no SC bundles multiple verification targets via "and"/"or"/comma-lists. Preload invariance (SC-28) is an explicit requirement. | Spec-creation pipeline (create task) |

---

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (deepseek-v4-flash)
