<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2744; adapted from the pre-rip reference/spec-structure-standards.md (tag pre-rip) under the #2744 reconciliation register; rewritten to current-generation doctrine -->

# Spec Structure Standards

Canonical reference defining the mandatory section structure of a local
`spec.md` artifact. Both producers (the spec card's authoring flow) and
validators (the spec card's fresh-context validation dispatch) read this
document via `Read [Text](path)` directives: the writer produces this
structure; the reviewer reads it when verifying conformance — no section list
is ever hard-coded into the checker.

This standard owns structure only. Content prohibitions (invented
requirements, status language, reduction-threshold targets, tracking markers)
are the validation standards' property and are not restated here.

## 1. Intent and Executive Summary

Every spec opens with a preamble carrying exactly these six fields, in this
order, each labeled in bold:

1. **Problem Statement** — what is wrong or missing, stated specifically
   enough that the requirements can aim at it.
2. **Root Cause / Motivation** — why the problem exists and why it must be
   solved now; distinguishes symptom from cause.
3. **Approach Chosen** — the selected solution path at a level concrete
   enough to evaluate.
4. **Alternatives Considered & Why Discarded** — each alternative weighed
   with its rejection ground; "not applicable" is not an entry. This field
   is the research-adequacy record.
5. **Key Design Decisions** — the choices that constrain implementation, each
   naming its tradeoff.
6. **User Intent / Original Prompt** — the developer statements and observed
   failures the spec derives from, quoted verbatim and dated. This field is
   the provenance anchor: the validation dispatch's traceability check reads
   it.

## 2. Not Included

The spec names every exclusion with a one-line rationale. When nothing is
excluded the section states "Nothing is explicitly excluded" — it is never
omitted. The intent preamble's scope claims and this section agree.

## 3. Requirements

Numbered `R-1, R-2, …` statements using RFC 2119 vocabulary: SHALL for
mandates, SHOULD for recommendations, MAY for options. Each requirement is
testable independently, and every requirement traces to the developer
statement or observed failure it derives from — the scope-creep guard the
spec card rule 1 states.

## 4. Success criteria

A table with exactly these columns: **ID / Criterion / Class / Instrument**.
Class vocabulary is the spec card rule 4's: `behavioral` or `structural` —
every SC asserts the deliverable's behavior or its content, never what the
toolchain already guarantees. Each instrument is a check the agent can run —
never prose recall — and observes the failure the criterion guards against.
Each criterion is atomic: one requirement, binary verifiable, no bundling.

## 5. Dependencies

Prerequisites the work needs before it can proceed. Each entry carries
**Reference** (issue number, file path, or skill name), **Relationship** (how
the work depends on it), and **Status** (satisfied or pending, decided at
write time).

## 6. Traceability

A table mapping every requirement to the success criteria that verify it.
Every requirement traces to at least one SC; every SC traces to at least one
requirement — orphan rows in either direction are findings. The
plan-to-SC mapping lives in the plan artifact; this table never carries
implementation state.

## 7. Documentation Sources

Every external source a load-bearing claim cites — document, code, API,
dataset — carries a row: **Source / Type / Location / Verification** (how the
claim was verified, stated concretely: read, grep, live call, dated). A
claim the writer could not verify at write time is a finding regardless of
its truth.

## 8. Cost Frame

Per-SC statement of the verification economics: acting on the verification
costs what, skipping it costs what. Cost frames anchor reasoning; they never
become reduction targets — a numeric threshold is never a pass condition.

## 9. Edge Cases

Boundary conditions and failure modes the criteria must exercise, in the gap
analysis family's shape. Categories follow the change's nature (input
boundaries, state transitions, failure and recovery, concurrency where the
deliverable owns concurrency); each entry states **Condition**,
**Expected behavior**, and, where applicable, **Resolution**. Categories are
exemplary — the stated problem decides which apply.

## 10. Completion gate

The spec closes with the all-or-nothing statement: every success criterion
passes before the deliverable is complete; partial implementation is not
permitted. The statement is spec content, not a tracking marker; the issue's
validation record (`.issues/{N}/audit/validation.yaml`) owns the loop
history and no other section carries it.

## 11. Adoption posture

The standard binds new authoring and binds any revision that substantively
touches a spec (whole-artifact-on-touch: a substantive write converts the
entire artifact's layout, not just the touched passage). Existing store
artifacts are not retroactively converted. The body footer allowlist and the
self-containment rule are the spec card rule 6's property — this standard
adds layout, never exceptions.

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
