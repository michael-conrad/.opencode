<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2744; adapted from the pre-rip reference/plan-structure-standards.md (tag pre-rip) under the #2744 reconciliation register; rewritten to current-generation doctrine -->

# Plan Structure Standards

Canonical reference defining the mandatory structure of a local `plan.md`
artifact. Both producers (the plan card's authoring flow) and validators (the
plan card's fresh-context validation dispatch) read this document via
`Read [Text](path)` directives: the writer produces this structure; the
reviewer reads it when verifying conformance — no element list is ever
hard-coded into the checker.

This standard owns structure only. Content prohibitions (scope enlargement,
status tracking, unreal instruments) are the plan card's and the plan
validation standards' property, and are not restated here.

## 1. Goal

One paragraph stating what the plan delivers: the change it implements, the
issue it answers, and the artifact surfaces it touches. A reviewer reading
only this section knows the plan's boundary.

## 2. Execution surface

The working context the items act in, stated once: the repository the work
lands in, the branch, and any environment fact the items' RED or GREEN
depends on (a clean clone, a fixture, a tool home). Named surfaces are
root-agnostic where the deck serves multiple roots — per-root facts arrive
via session-init, never hardcoded paths to a specific developer workspace.

## 3. Items — one item per success criterion

Each item carries exactly these fields, labeled in bold:

- **Deliverable** — the artifact or change this item produces.
- **RED** — the failing assertion, written against current behavior. RED
  states what fails; it never states line numbers or exact code.
- **GREEN** — the change that turns it green; the minimal change, no
  speculative additions.
- **Tier marks** — any tests the item authors state their tier(s) at
  creation per the test-discipline card's mark-on-creation vocabulary; an
  item that authors no test states the instrument class it relies on instead
  (fact check, recorded dispatch). Scratch observation stays out of test
  files.
- **Instrument** — the check the agent runs to verify; never prose recall.

Items are daisy-chained: item N's commit is item N+1's RED precondition.
Each item is atomic — one concern, independently verifiable, committable,
and revertable.

## 4. Dependency order

The items' execution order, stated explicitly with the reason each item
precedes its dependents. No cycles: an item's RED or GREEN never depends on
a later item.

## 5. Traceability

A table mapping each item to the SC(s) it implements. Every SC is covered by
at least one item; every item traces to at least one SC — an orphan in
either direction is a finding.

## 6. Verification summary

The tiers the plan relies on, stated once: which items verify through fact
checks, which through recorded dispatch evidence, which authored tests (with
tiers) exist, and which runs happen at cycle time versus PR-check time. No
authored test exists outside this summary's account.

## 7. Status boundary

The plan body carries no STATUS fields, completion markers, or progress
indicators — the plan card owns that rule; implementation state lives in the
pipeline, and the issue's validation record owns measured loop history.

## 8. Adoption posture

The standard binds new authoring and binds any revision that substantively
touches a plan (whole-artifact-on-touch). Existing store artifacts are not
retroactively converted. Retired machinery — the orchestrator step-indicator
system (the retired `(direct)`/`(task-card)` step annotations), phase tables,
per-phase files, Z3 contracts — is never reintroduced into plan structure;
the current generation sequences through per-item cycles and dispatches
through the platform's sub-agent surface.

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
