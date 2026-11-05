<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->

# Plan — SC subject-matter discipline (.opencode#2713)

Derived entirely from `.opencode/.issues/2713/spec.md` (all 7 SCs). Every SC
is structural (read checks + one deck-lint run); the branch is
`feature/2713-sc-subject-matter-discipline` in the `.opencode` submodule,
based on trunk tip `369d9409b` (verified = origin/main, 2026-11-05).

## Item 1 — SC-1..SC-3: rule 3 subject-matter constraint (spec card)

- Deliverable: `skills/spec/SKILL.md` rule 3 carries the subject-matter
  constraint (SC-1), the toolchain prohibition (SC-2), and the byte-exactness
  reservation with its three never-clauses (SC-3).
- RED: read rule 3 as it stands — none of the three clauses exists.
- GREEN: rewrite rule 3 stating: every SC asserts the deliverable's behavior
  (a runtime effect the deliverable owns) or its content (what the
  deliverable states or contains) and nothing else; what the build system or
  toolchain already guarantees is never an SC subject; byte-exact instruments
  are reserved for criteria whose stated requirement is itself identity or
  preservation, and a byte-exact check never substitutes for a behavioral or
  content criterion, never serves as a reduction target, never restates the
  change's declared scope.
- Verify: read rule 3; each clause present (SC-1, SC-2, SC-3).
- Edge-case fidelity (spec §9): artifact-content claims stay valid; same-file
  section guards stay legitimate; test-suite-green is not widened into the
  toolchain clause.

## Item 2 — SC-4: validator-side shapes (validation reference)

- Deliverable: `skills/spec/references/validation-standards.md` names the
  five observed shapes as judgment descriptions inside the existing
  defect-class structure, each with its ground and the identity/preservation
  carve-out: toolchain-guarantee criterion (incapable instrument);
  count/byte/percentage reduction-threshold target (incapable instrument);
  scope-restatement byte guard (trivially-true restatement); byte-equality as
  drift control where a content or link check answers the question
  (trivially-true restatement); manufactured RED (incapable instrument).
- RED: the defect classes name none of the five shapes.
- GREEN: fold the shapes into classes 5 and 7 as described judgment classes —
  no keyword list, no trigger-word table, the page's constitution intact.
- Verify: read the defect classes; each shape present with its ground and the
  carve-out (SC-4).

## Item 3 — SC-5, SC-6, SC-7: post-conditions

- SC-5: search `skills/` for the operative phrasing — matches only in the two
  owning files; `implement/SKILL.md` carries no new copy (its rule 7 is
  neither duplicated nor modified).
- SC-6: end-to-end read of both edited files; the whole-card-on-touch
  conversion holds across each file's entire normative prose.
- SC-7: `./.opencode/tools/skildeck lint` exits 0.

Dependency order: Item 1 and Item 2 are independent; Item 3 runs after both.

## Traceability

Item 1 ← SC-1/SC-2/SC-3 ← R-1/R-2/R-3. Item 2 ← SC-4 ← R-4. Item 3 ←
SC-5/SC-6/SC-7 ← R-5/R-6. No untraceable items; the plan adds nothing the
spec does not state.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
