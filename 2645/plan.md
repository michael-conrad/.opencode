# Plan — .opencode#2645: bound dispatch practice for short-path work

Spec: `.opencode/.issues/2645/spec.md` (validated PASS). Branch: stacked on
`feature/2639-scope-boundary-stacked-pr` (submodule `.opencode`), same PR as
#2639 — one squashed commit per issue at PR time.

## Item 1 — Amend `implement` rule 9 (SC-1, SC-2)

- Deliverable: `skills/implement/SKILL.md` rule 9 gains, after the existing
  judgment sentence, the short-path inline default (R-1): for short-path work
  (developer-specified small changes with no success-criteria machinery), the
  default is working inline in the agent's own context; a sub-agent dispatch
  for short-path work requires a scoped reason recorded in the work state.
  Both provenance lines (frontmatter and HTML comment) gain one
  `; inline-by-default for short-path, .opencode#2645` entry (R-2).
- RED (executable, fixed): grep the pre-amendment rule 9 for the provision
  markers — `short-path` and `recorded in the work state` within the
  dispatch-judgment rule. Both return empty on the trunk state; the captured
  empty output is the RED record.
- GREEN: apply the amendment.
- Verify: (1) the greps now hit inside rule 9 for both SC-1 elements;
  (2) `git diff` against trunk confines changes to rule 9's text and the two
  provenance lines (SC-2); (3) root-agnostic grep over the file returns
  nothing (`grep -E 'opencode-config|/home/'`).
- Dependency: none — independent of the #2639 items already on the branch;
  sequenced before the SC-7/SC-8 re-runs so the behavioral runs execute the
  amended card.
