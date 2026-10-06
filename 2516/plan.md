# Plan: .opencode#2516 — floor fattening / always-loaded surface discipline

Source: `.opencode/.issues/2516/spec.md` (SCs 1–7). Docs-only deck change; no
RED/GREEN code cycles — RED is a failing text/behavior check against current
state, GREEN is the edit.

## Item 1 — SC-4: always-loaded-surface criterion in skill-creator (do first)

- **Deliverable:** an admission-gate criterion in `skills/skill-creator/SKILL.md`
  (numbered within the admission gate list, or as an adjacent clause): content
  enters `floor.md` / any always-injected file only if it must be visible
  before any card dispatch; everything else is card-level. Include remediation
  wording direction for drifted counters is NOT here (that's item 4) — keep
  this item to the criterion.
- **RED:** `grep -c "always" .opencode/skills/skill-creator/SKILL.md` shows no
  always-loaded-surface criterion (currently absent).
- **GREEN:** add the criterion (2–3 lines, lean body standard).
- **Verify:** grep confirms the criterion text exists.

## Item 2 — SC-1 + SC-2 + SC-5: slim floor.md vocabulary bullet

- **Deliverable:** `approved for <phase>` bullet in `floor.md` compressed to
  the definition only; remove the worked pipeline walkthrough ("plan →
  implement → verify → PR are all covered by `approved for pr`") and the halt
  mandate ("Halt only on genuine ambiguity, never on absent intermediate
  stages"). The halt condition moves into `skills/work/SKILL.md` boundary item
  4 (which already carries carry-through semantics — add the halt condition
  sentence there if not already present).
- **RED:** `grep -n "Halt only on genuine ambiguity" .opencode/floor.md`
  currently matches; `wc -l` = 81.
- **GREEN:** edit `floor.md` bullet; verify `work` boundary item states the
  halt condition; if missing, add one sentence.
- **Verify (SC-1):** both strings absent from `floor.md`; definition present.
- **Verify (SC-2):** `work` card states halt-on-genuine-ambiguity-only.
- **Verify (SC-5):** `wc -l .opencode/floor.md` ≤ 81.

## Item 3 — SC-7: counter-update runbook step in spec (and issues) cards

- **Deliverable:** `skills/spec/SKILL.md` item 3 gains the counter rule:
  when filing a remote issue into a synced store, update `.counter` to
  max(counter, filed number); drifted-counter remediation (advance to highest
  known `{N}/`). `skills/issues/SKILL.md` gets the same step where its filing
  workflow is stated.
- **RED:** `grep -n "counter" .opencode/skills/spec/SKILL.md` currently empty.
- **GREEN:** add one runbook sentence to each card (fact-decidable action).
- **Verify:** grep confirms counter step present in both cards.

## Item 4 — SC-6: remediate this ticket's bypassed registration (runbook execution)

- **Deliverable:** the store's `.counter` is advanced to the highest known
  issue number (2516 or higher if the tracker moved), and store hygiene is
  clean/pushed. The 2516 folder itself is registered and readable (verified
  during filing); the remediation is the counter drift.
- **RED:** `cat .opencode/.issues/.counter` → 2488 < highest dir 2516.
- **GREEN:** update `.counter` via direct file write inside the issues worktree
  (counter is store-internal state, updated with an issues-data commit), push.
- **Verify:** counter ≥ highest `{N}/`; `git -C .opencode/.issues status`
  clean; pushed.

## Item 5 — SC-3: behavioral test via `opencode run`

- **Deliverable:** evidence that an agent, given `#N approved for pr` on a
  stage-0 ticket, proceeds to pipeline entry (branch creation) instead of
  halting with a clarification request.
- **Method:** run `opencode run` with a prompt presenting a fabricated
  terminal-stage approval for a fictitious stage-0 ticket, scoped so the run
  must not touch real issues/PRs (instruct the agent to halt after branch
  creation decision, in a disposable scratch directory so no real repo state
  changes). Inspect the session output for: no stage-0 clarification request;
  pipeline entry language (branch creation).
- **RED:** current deck state (before items 1–2 land in the run's injected
  floor) is the pre-fix state; the post-edit run is the GREEN evidence.
- **Verify:** run output shows proceed-not-halt; paste real output as PR
  evidence. If `opencode run` cannot run headlessly in this environment,
  record the blocker and fall back to a documented manual-check note in the PR
  (flagged as an instrument limitation, not a PASS).

## Item 6 — commit, push, PR

- Single commit on `feature/2516-floor-surface-discipline` (branch off fresh
  `origin/main`), body referencing #2516, evidence from items 1–5, then `gh
  pr create` and HALT.
