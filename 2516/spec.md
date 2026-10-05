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

### SC-6 (behavioral) — issue numbering flows remote-first through the store's tools

The regression this SC closes (observed at spec-filing time for this very
ticket, 2026-10-05): the agent derived the next issue number by listing
remote GitHub issues and then hand-created the local `{N}/` folder with
`mkdir` + direct file writes, bypassing `local-issues create`. The store's
registry never learned the issue (`update --number` failed; the `.counter`
read 2488 against store dirs reaching 2512) — store state diverged from the
remote tracker, which is the corruption mode.

Required workflow: the remote issue is filed first (`gh`/`gb`, per spec-card
item 3); the number comes from that filing, never from listing remote issues;
the local folder and metadata are created only via `local-issues create --number
repo#N --title …`, never hand-crafted; the issues-data branch is pushed and
`local-issues read` confirms the store resolves the issue.

- **Verify:** on the next spec-filing run (SC-3's `opencode run` or a live
  filing), the session log shows `gh issue create` preceding `local-issues
  create`, no manual `mkdir`/direct-write of `{N}/`, and `local-issues read
  --number repo#N` succeeding immediately after registration. Store hygiene:
  `git -C .opencode/.issues status` clean and pushed after filing.

### SC-7 (structural) — spec-filing cards carry a counter-update runbook step

The skill cards that file remote specs (`skills/spec/SKILL.md`, and any card
whose workflow files remote issues into a synced store — `issues` included)
carry a runbook step: when filing a remote issue into a synced issue store,
the store's `.counter` is updated to the filed number (max(counter, filed)) so
the store's reserve mechanism never falls behind the remote tracker. At filing
time the counter read 2488 against store dirs reaching 2512 — the drift that
made the counter unusable for reservation.

- **Verify:** read `skills/spec/SKILL.md` (and `skills/issues/SKILL.md`):
  a counter-update step exists in the filing workflow, stated as a fact-decidable
  action; a store whose counter is behind its directories is detectable by
  comparing `.counter` to the highest `{N}/` directory — remediation guidance
  (advance the counter to the highest known number) is included.

## Out of scope

- Moving the entire authorization vocabulary out of the floor (it is
  definitionally always-loaded).
- Changes to `prompts/default.txt` (audited lean).
- Re-reconciling cards (done in #2515).

---
*Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)*
