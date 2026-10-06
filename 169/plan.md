# Implementation Plan — .opencode#169 Wiki Operations Skill Card Set

Derives entirely from `.opencode/.issues/169/spec.md` (Rev 3). One item per SC;
dependency order 1→2→3→4.

## Item 1 — SC-1 (structural): dispatchable card + routing entry

- **Deliverable:** `skills/wiki-operations/SKILL.md` (lean dispatchable card),
  detail cards under `skills/wiki-operations/references/`, a `routing.md`
  dispatch entry, and a governance-record note in the PR body. Admitted via the
  skill-creator gate (observed failure: agents produce wiki pages that render
  incorrectly and break sidebars — .opencode#169; consumer: agents editing
  GitHub/GitBucket wikis; mechanism: routing entry + card description;
  intent-decidable, no scripts; domain-native; root-agnostic; net addition —
  no existing wiki card to retire).
- **RED:** `routing.md` contains no wiki dispatch entry;
  `skills/wiki-operations/` does not exist.
- **GREEN:** create the card set and the routing entry.
- **Verification:** `reference-integrity` tool over the new card's references;
  grep of `routing.md`; inspection of the created files.

## Item 2 — SC-2 (structural): ten rule domains encoded and traceable

- **Deliverable:** the card set encodes all ten In-Scope rule domains, each
  rule traceable to the research card appendices, a cited primary source, or a
  developer direction from the 2026-10-06 design discussion.
- **RED:** card content absent → domains unencoded.
- **GREEN:** author content with per-section source annotations.
- **Verification:** content check of card facts against
  `.opencode/.issues/research-cards/wiki-operations-agent-tools-survey.md`
  (Appendices B–D) and the spec's reference list; traceability review.

## Item 3 — SC-3 (structural): no bespoke tooling

- **RED/GREEN:** n/a (invariant).
- **Verification:** `git diff --stat` — only `skills/`, `routing.md` files
  touched; no `tools/`, no MCP config, no scripts or dependencies.

## Item 4 — SC-4 (behavioral): card-equipped session performs a correct wiki edit

- **Deliverable:** behavioral run per the behavioral-testing card — an agent
  session equipped only with the card set + generic tools performs a correct
  wiki edit on the GitBucket wiki provisioned by the tests-v2 harness
  (`BEHAVIOR_NEEDS_REMOTE`, §12 `__ensure_gitbucket()`): correct link syntax,
  `_Sidebar.md` maintained, sync before edit, verified before push.
- **Two-SC pattern:** (a) artifact generation — harness run produces
  `session.yaml`; (b) clean-room evaluation — separate sub-agent reads the
  artifacts and judges against the SC.
- **Verification:** session evidence + clean-room evaluation verdict.
