---
name: plan
description: "Load when writing an implementation plan from an approved spec — per-SC items with RED/GREEN cycles, dependency ordering, verification instruments. Plans derive entirely from the spec: a plan item without a spec source is scope creep. Plans state how to implement; implementation status lives in pipeline state, never in the plan body."
license: MIT
provenance: AI-authored, .opencode#2490
---

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2490; #2550 consume-validated-specs mandate; #2557 language/tool call out -->

# plan — implementation planning

1. **One item per SC.** Each item states: deliverable, RED (the failing
   assertion, written against current behavior), GREEN (the change), and the
   verification instrument (a check the agent can run — never prose recall).
2. **Load the cards in scope.** Identify the languages and build tools the
   plan's items touch and load their cards (where cards exist), and load
   `programming-principles` for the engineering-principles layer — conventions
   and packaging expectations shape item decomposition and per-item
   verification.
3. **Dependency order.** Sequence items so each RED/GREEN cycle builds on
   verified prior state. Needs-based sizing: no padding items, no filler.
4. **Derivation guard.** Every item traces to an SC. Untraceable items are
   removed, not justified.
5. **No status tracking in the body** — no STATUS fields, completion markers,
   or progress indicators. State lives in the pipeline, not the plan.
6. **Consume validated specs only.** Plan items trace to the spec's SCs.
   Before planning, judge each SC against
   [the validation standards](../spec/references/validation-standards.md)
   defect
   classes — reviewer judgment, never pattern matching. A defective or
   ambiguous criterion produces BLOCKED naming the criterion and the defect;
   the plan never routes around a defective criterion and never reinterprets
   it to make it plannable.
7. Plans wait for the developer's authorization before `implement` when the
   scope requires it; short-path changes execute directly under `work`. A
   terminal-stage approval (`approved for pr`, `approved for
   implementation`, …) from the vocabulary in `floor.md` carries the item
   through plan into implement — the stage is not re-asked.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
