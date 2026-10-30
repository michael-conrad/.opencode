<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->

# [PLAN] Closing-keyword contract — .opencode#2658

Consumes `.opencode/.issues/2658/spec.md` (validation PASS, round 2, 2026-10-30).
All deliverables are card-prose replacements in the deck's three cards; every
verification instrument is a mechanical check run in-session (grep, full-card
read, `reference-integrity`). No code, no test surface.

## Items

### P-1 — `git-workflow-pr` §4 closing-lines rewrite (SC-1, SC-2, SC-3, SC-4)
- **Deliverable:** In `skills/git-workflow-pr/SKILL.md` §4's **Closing lines**
  bullet: state the form-selection rule (same repo → `Closes #N`; different
  repo → `Closes owner/repo#N`, always owner-qualified); state the
  default-branch condition and the per-(platform × form) class (GitHub both
  forms; GitBucket same-repo only; cross-repo on GitBucket nothing); state
  that the developer's merge fires the close; prohibit the bare-keywordless
  `#N` and the owner-less `repo#N`, affirming the owner-qualified form is a
  distinct form that closes on GitHub; add a canonical
  `Read [text](../git-workflow-cleanup/SKILL.md)` pointer for the cases the
  keywords leave open — link text containing the target card's name so
  `reference-integrity` resolves it against the target's `git-workflow-cleanup`
  heading. Keep the uniform `Closes` keyword, `Refs #N` semantics, body-top
  placement, and the cleanup verify-and-sync sentence. No merge instruction
  (SC-8).
- **RED:** `grep -cF "GitBucket has no closing-keyword auto-close"
  .opencode/skills/git-workflow-pr/SKILL.md` counts 1 today (the false
  clause the spec's R-2 removes is present) and counts 0 after GREEN — the
  absent platform-class statement is the facet SC-3 adds; the default-branch
  condition is already on the card and is asserted unchanged, not newly
  added.
- **GREEN:** edit the bullet.
- **Verify:** full-card read asserts SC-1..SC-4; `.opencode/tools/reference-integrity`
  on the file exits 0. (The no-merge-instruction assertion is P-6's whole-
  change instrument; P-1 adds no merge instruction — any added imperative
  names closing keywords, not merging.)

### P-2 — `git-workflow-cleanup` item 1 closed-vs-merged (SC-5)
- **Deliverable:** In item 1's **Verify the merge** paragraph, append the
  distinction: a closed pull request is not a merged one; read the merge
  state, not the open/closed flag.
- **RED:** `grep -c "not a merged" .opencode/skills/git-workflow-cleanup/SKILL.md`
  fails.
- **GREEN:** edit item 1.
- **Verify:** full-card read of item 1 asserts, one by one: (a) the closed-
  versus-merged distinction statement is present in item 1's body; (b) the
  statement requires reading the merge state; (c) the statement requires the
  merge state, not the open/closed flag, as what is read. All three asserted
  explicitly by quoting the added sentence and matching each half.

### P-3 — `git-workflow-cleanup` item 3 rewrite (SC-6, SC-9)
- **Deliverable:** Replace the whole item-3 closing-keyword sentence(s):
  the three per-platform class phrases ("on platforms that support it",
  "on platforms without closing-keyword support", "names which platforms
  fall in which class") are removed; name the two open cases (cross-repo
  form on GitBucket; merge into a non-default base branch) with the
  base-branch condition governing first; scope the remit statement to
  closure only; retain the general fallback (closure in this workflow or on
  explicit developer instruction) in substance; retain the no-double-close
  rule verbatim; add the canonical `Read [text](../git-workflow-pr/SKILL.md)`
  pointer to the per-(platform × form) statement.
- **RED:** `grep -cE "platforms that support it|platforms without closing-keyword support"`
  on the file counts 2+ (phrases present) — confirms RED.
- **GREEN:** edit item 3.
- **Verify (SC-9, executed in full):**
  1. `grep -cF "on platforms that support it" <file>` counts 0;
  2. `grep -cF "platforms without closing-keyword support" <file>` counts 0;
  3. `grep -cFi "which platforms fall in which class" <file>` counts 0
     (third phrase — the tool's link check passes vacuously without a link,
     so absence and presence are asserted mechanically, not by the tool);
  4. `grep -cF "Read [" <file>` counts ≥1 and the matched line contains
     `../git-workflow-pr/SKILL.md` (pointer presence asserted directly);
  5. `.opencode/tools/reference-integrity` on the file exits 0 (pointer
     resolves).
  Full-card read additionally asserts SC-6's parts (two cases named,
  precedence, closure-scoped remit, general fallback in substance,
  no-double-close retained).

### P-4 — `gb-cli` §4 additions (SC-7)
- **Deliverable:** In `skills/gb-cli/SKILL.md` item 4, append three
  statements: the merge is a human gate (no agent merge); the raw
  `PATCH .../pulls/{n}` with `state: closed` closes without merging and
  produces no closing-keyword closure; GitBucket's issue API reports `state`
  but not `closed_at`.
- **RED:** `grep -c "closed_at" .opencode/skills/gb-cli/SKILL.md` counts 0.
- **GREEN:** edit item 4.
- **Verify:** full-card read asserts SC-7.

### P-5 — Provenance anchors (SC-10)
- **Deliverable:** Append `; closing-keyword contract, .opencode#2658` to both
  provenance surfaces (frontmatter `provenance:` and the `<!-- Provenance: … -->`
  comment) of each of the three cards.
- **RED:** `grep -c 2658` on each card counts 0 (established in session).
- **GREEN:** edit both surfaces.
- **Verify:** `grep -c 2658` counts 2 per card (SC-10).

### P-6 — Global gates (SC-8)
- **Verify (whole-change):** grep `skills/` and `floor.md` for the human-merge-gate
  statement — present in `git-workflow-pr` §6 and `floor.md` `## Pipeline`,
  unmodified (`git diff` shows no change to those lines); diff the three
  cards and assert no added line instructs the agent to merge (the added
  lines are read from
  `git -C .opencode diff main -- skills/git-workflow-pr/SKILL.md skills/git-workflow-cleanup/SKILL.md skills/gb-cli/SKILL.md`
  and checked by hand: added imperatives name closing-keyword forms, never
  merging); `.opencode/tools/reference-integrity --scan` exits 0
  (bare `--scan`; the tool accepts a file/directory list or the bare flag —
  no other flag combination exists).

## Traceability
P-1→SC-1/2/3/4, P-2→SC-5, P-3→SC-6/9, P-4→SC-7, P-5→SC-10, P-6→SC-8.
Every SC covered; no item without an SC source.