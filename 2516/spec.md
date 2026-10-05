# Spec: .opencode#2516 — Floor fattening: always-loaded surface discipline

Provenance: developer directive 2026-10-05 — "each little slip doesn't add up.
fix the deck docs so that you don't keep repeating this error over and over
effectively undoing all this work. file the spec to fix the floor.md. test with
opencode run."

## Problem

The #2505 fix added card-level content to `floor.md`'s authorization
vocabulary: a worked pipeline example and a halt mandate. The halt mandate
("Halt only on genuine ambiguity, never on absent intermediate stages")
belongs to the `work` gate, which already carries equivalent reconciliation
text (PR #2515). No deck-governance rule distinguishes always-loaded content
from card-level content, so nothing flags this class of growth at admission
time — the error can recur indefinitely.

## Success criteria

### SC-1 (structural) — floor vocabulary carries only semantics

The `approved for <phase>` bullet in `floor.md` states the definition
(authorization carries the item through all pipeline phases up to and
including the named phase; intermediate authorizations are implied) and no
worked pipeline walkthrough or halt directive.

- **Verify:** read `floor.md`; the bullet contains the definition; the strings
  "plan → implement → verify → PR" and "Halt only on genuine ambiguity" do not
  appear in `floor.md`.

### SC-2 (behavioral) — halt mandate lives where it is consumed

The `work` card's boundary text states when to halt (genuine ambiguity only,
never absent intermediate stages) such that an agent holding a terminal-stage
approval on a stage-0 ticket proceeds without halting.

- **Verify:** read `skills/work/SKILL.md`; the boundary item covers both the
  carry-through and the halt condition. Covered by SC-3's runtime test.

### SC-3 (behavioral) — terminal-stage approval drives the pipeline via `opencode run`

An agent given `#N approved for pr` on a stage-0 ticket (no branch, no spec,
no plan) proceeds: creates the feature branch and runs the pipeline to PR
creation, without an intermediate clarification request about missing upstream
stages.

- **Verify:** `opencode run` in a scratch context with the updated deck; the
  session log shows branch creation (or pipeline entry) rather than a halt.
  The run must not touch a real repository's issues or open real PRs — use a
  prompt that stops short of PR creation but demonstrates non-halt at stage 0.

### SC-4 (structural) — governance gate prevents recurrence

The deck-governance card (`skill-creator`) carries an always-loaded-surface
criterion: content enters `floor.md` (or any always-injected file) only if it
must be visible before any card dispatch; everything else is card-level.

- **Verify:** read `skills/skill-creator/SKILL.md`; the criterion exists as
  part of the admission gate.

### SC-5 (structural) — no net floor growth

`floor.md` after the change is not longer than before (81 lines at filing).

- **Verify:** `wc -l .opencode/floor.md` ≤ 81.

## Out of scope

- Moving the entire authorization vocabulary out of the floor (it is
  definitionally always-loaded).
- Changes to `prompts/default.txt` (audited lean).
- Re-reconciling cards (done in #2515).

---
*Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)*
