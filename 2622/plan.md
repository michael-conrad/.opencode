# Plan — Deck: restore remote-body format, blockquoted artifacts link, `{N}/` record-set mandates

Resolves `.opencode#2622` (remediation of `.opencode#2620`). Consumes `.opencode/.issues/2622/spec.md`.

## Items

### Item 1 — Shared reference `skills/spec/references/remote-body-format.md` (SC-1, SC-2, SC-3, SC-4)

- **Deliverable:** new deck reference defining, for every remote issue with a matching issues-data `{N}/` folder:
  - **Trigger rule (SC-2):** the body mandate binds to every remote issue that has a matching `{N}/` folder and to no remote issue without one; issues filed first gain the mandate at reconciliation when their folder comes to exist.
  - **Universal minimum (SC-1):** Problem; Scope (what the change requires); Requirements as R-x SHALL statements; Impact.
  - **Spec-filing extension (SC-1):** success criteria classified behavioral/structural, each carrying a verification instrument; success-criteria table; Out of scope; Approach; plan-shaped sections — Items RED/GREEN, Dependencies, Traceability, Documentation Sources, Enforcement Gate, Cost Frame, Edge Cases, Not Included — required once a plan exists.
  - **Blockquote convention (SC-3):** closing blockquoted artifacts link `> Full spec and plan artifacts: <url>` built via `local-issues url --number repo#N --artifacts` (manual platform-URL derivation as fallback — the #2623 companion), present at filing and reconciled on every remote-body edit; the AI-facing relative-path artifacts pointer line adjacent; the no-hardcoded-file-lists rule (agents glob `{issues_prefix}{N}/`).
  - **Sizing doctrine + record set (SC-4):** a developer reading only the remote body can understand and judge the spec; full agent-ingest detail stays local-authoritative; the `{N}/` record set is `spec.md` plus `issue.yaml`, `comments.yaml`, `links.yaml`, artifact subdirectories (cross-checked against `local-issues-cli.md` store semantics).
- **RED:** `skills/spec/references/` contains only `validation-standards.md`; no deck text states the format.
- **GREEN:** author the reference (skill-creator gate: admission evidence = #2620 defect record + NewsRxUI#64/ProcessFinishedNotify#36 verdicts + stranded-guide-verbiage finding; root-agnostic; card-level, not always-loaded).
- **Instrument:** read the file; cross-check the record set against `local-issues-cli.md`.

### Item 2 — Card pointers replace weak rules (SC-5)

- **Deliverable:** `spec/SKILL.md` item 4 and `issues/SKILL.md` item 2 replace their "detailed exec summary" sentences with pointers to `references/remote-body-format.md`, preserving each site's local-authoritative doctrine.
- **RED:** `grep -rn "exec summary" .opencode/skills/` matches both cards (spec/SKILL.md:30, issues/SKILL.md:27).
- **GREEN:** edit both sentences; after the edit the grep matches only the reference file; both cards contain the pointer.
- **Instrument:** the grep + pointer check.

### Item 3 — session-init doctrine string (SC-7)

- **Deliverable:** `.opencode/tools/session-init` line ~730 store-first note drops "condensed exec summary only" and states the new sizing doctrine (remote body carries the structured summary; the store holds the full spec).
- **RED:** grep "condensed exec summary" in the tool matches line 730.
- **GREEN:** edit the one string; grep returns no match.
- **Instrument:** source read + grep.

### Item 4a — Deck workspace guide stripped (SC-6, deck side)

- **Deliverable:** `.opencode/.issues/AGENTS.md` loses its operational "GitHub URL Convention for Remote Issue Body" section and exec-summary doctrine phrasing — normative content relocated into the reference — keeping layout/tooling description plus a pointer to the deck reference.
- **RED:** the deck guide currently carries the operational section and phrasing.
- **GREEN:** strip and re-point the deck guide.
- **Commit mechanics:** deck-submodule file on the `issues-data` orphan branch of the deck repo — edited directly and committed via `git -C .opencode/.issues` on that branch (issues-data hygiene path); it does NOT ride the feature branch or the PR diff. The deck-side PR body (Item 5) records this edit in its narrative.
- **Instrument:** read the deck guide in full (post-edit state in the deck worktree).

### Item 4b — Parent workspace guide re-pointed (SC-6, parent side)

- **Deliverable:** `.issues/AGENTS.md`'s pointer description cites the deck reference for format rules instead of the weak "detailed exec summary" phrasing.
- **RED:** the parent guide's pointer description currently embeds the weak phrasing.
- **GREEN:** re-point the parent guide description at the deck reference.
- **Commit mechanics:** parent repo's issues-data worktree — hygiene path via `git -C .issues`; an authorization-free issues-data hygiene write per the store guide, independent of the deck-side branch and PR.
- **Instrument:** read the parent guide in full (post-edit state in the parent worktree).

### Item 5 — Admission evidence with the change (SC-8)

- **Deliverable:** the skill-creator-gated change record — commit message and PR body — cites the #2620 defect record, the NewsRxUI#64 and ProcessFinishedNotify#36 verdicts, and the stranded-guide-verbiage finding.
- **RED:** no such record exists pre-change.
- **GREEN:** evidence cited in the per-issue commit and PR body at PR creation.
- **Instrument:** read the commit message + PR body.

### Item 6 — Behavioral composition check (SC-9)

- **Deliverable:** a tier-1 clean-room dispatch: a fresh-context agent routing `spec`/`issues` by description alone, loading only the changed cards plus the new reference, composes the remote body for a stated folder-backed defect and returns the body; the orchestrator inspects the returned body for the universal-minimum sections, the spec extension, and the closing blockquote, and persists the prompt plus verdict into the issue artifact area. The reference's manual platform-URL derivation is the fallback build mechanic, so this does not block on #2623.
- **RED (verified pre-change, 2026-10-15):** the deck as-written produces the thin "## Why / ## What" body — the recorded defect behavior (NewsRxUI#64, ProcessFinishedNotify#36). The dispatch is authored against that pre-change deck; after Items 1–3 plus 4a land, the GREEN assertion is that the dispatch now produces the mandated body shape.
- **GREEN:** with the deck changes (Items 1–3 plus 4a), the dispatch produces the mandated body shape.
- **Instrument:** tier-1 clean-room dispatch record (prompt, returned body, verdict) in the issue artifact area; inspect the returned body.

## Dependencies

Item 1 → Item 2 → Items 3, 4a (pointers must exist before the sites referencing them are rewritten); Item 4b proceeds independently on the parent hygiene path; Item 5 rides the commit/PR; Item 6 runs after Items 1–3 plus 4a are complete (branch-landed items on the branch, 4a in the deck worktree).

## Traceability

- Item 1 → SC-1–SC-4; Item 2 → SC-5; Item 3 → SC-7; Items 4a + 4b → SC-6; Item 5 → SC-8; Item 6 → SC-9. All nine SCs covered; no untraceable items.

## Verification instruments

- Structural: file reads and greps named per item.
- Behavioral: tier-1 clean-room dispatch record (Item 6), per the behavioral-testing card.
