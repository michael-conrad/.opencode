# .opencode#2769 — Plan: remote-tracker number as record identity anchor (identity-divergence sweep + §7 doctrine)

## Goal

Implement `.opencode#2769`'s validated spec: add the three record-identity
divergence error classes to the `local-issues` `validate-yaml` sweep
(missing/unresolvable `remote_url`, issue-number mismatch, repo-slug mismatch —
tracker-host stores only, local facts only, offline), carry the class
documentation into the CLI-mechanics reference (behavior row + taxonomy), and
extend the issues card §7 mirror-repair block with the diverged-store
reconciliation disposition (renumber-to-tracker-number) and the identity-anchor
doctrine (anti-phantom-precedent, stored-pointer-is-the-defect). The write-side
invariant (R-1/SC-1) is a preservation item: verified before the tool file is
touched and re-verified after, with no code change authored by this item.

## Execution surface

- Working repo: `michael-conrad/.opencode` (the deck repository, itself a
  submodule of the consuming root). Per the deck-consumption boundary, the
  consuming root's `.opencode/` checkout is read-only for this session: all
  deck-file edits, commits, tests, and the PR run in a dedicated
  `git worktree` of that repo (created under `/tmp/opencode/`), on feature
  branch `2769-identity-anchor` based at the verified trunk tip.
- Files: `.opencode/tools/local-issues` (sweep checks), `.opencode/tests/test_local_issues/test_validate_yaml_identity.py` (authored tests), `.opencode/skills/issues/references/local-issues-cli.md`, `.opencode/skills/issues/SKILL.md` (§7 mirror-repair block).
- Deck store artifacts (`plan.md` here, audit validation record) ride the
  `.opencode/.issues` issues-data store via the local-issues tool —
  authorization-free workspace maintenance, never part of the feature branch.
- Environment facts the items' instruments depend on: the tool runs as
  `uv run --script` (Python 3.12 managed, PyYAML only — no network use in any
  instrument); tests run via the deck's canonical `uv run pytest` in the
  worktree; tracker-host context in test sandboxes is created by
  `git init` + `git remote add origin <scp-or-https-url>` — origin URLs are
  parsed, never contacted, so every instrument runs fully offline.

## Items

### Item 1 — SC-1 (preservation, write-side invariant baseline)

- **Deliverable** — a recorded preservation verification of the R-1 invariant
  against the tool before and after Item 2 touches it: `create`'s parser
  requires `--number` and names it required in `create -h`; the #2723
  creation-time divergence warning and its fork-consequence wording sit in the
  create path's emission site; a symbol sweep of the tool source finds no
  store-state number-derivation input (`.counter`, folder-enumeration, or any
  derived default feeding `create`).
- **RED** — the SC-1 assertion set (help output + emission-site read + symbol
  sweep — the spec's structural instrument) executed against the untouched
  tool. This is the gap-analysis family's sanctioned preservation shape: the
  assertions currently pass, and any failure blocks the pipeline as a
  pre-existing violation rather than passing through. The recorded pass is the
  baseline.
- **GREEN** — the identical assertion set re-executed against the tool after
  Item 2's change lands; every assertion still passing records the invariant
  preserved. No code or test artifact is authored by this item.
- **Tier marks** — no authored test (the spec's instrument is a fact-check
  sweep; the preserved behavior's existing suite coverage stays untouched).
- **Instrument** — executed: `./.opencode/tools/local-issues create -h`;
  emission-site read at the #2723 warning site in the tool source;
  `git grep -n "counter\|_next_number\|derive" -- tools/local-issues`-class
  symbol sweep scoped to the create path; captured outputs.

### Item 2 — SC-2 (tool: three identity-divergence classes)

- **Deliverable** — `validate-yaml`'s sweep reports record-identity divergence
  as three new named error classes, emitted through the existing
  `<repo>/<path>: <error-class>` report form and the existing exit-code
  semantics (findings → exit 1, both scoped and unscoped modes): on a
  tracker-host store (the store repo's origin parses to `github.com`, or to a
  host-mapped tracker base per the committed `local-issues-host-maps.conf`),
  a record directory is flagged (a) `missing-remote-identity` when its issue
  mapping carries no resolvable `remote_url` (absent, empty, or unparseable as
  a tracker issue identity), (b) `remote-number-mismatch` when its
  `remote_url` parses but names an issue number other than the record's folder
  number, (c) `remote-repo-mismatch` when its `remote_url` parses but names an
  owner/repo slug other than the store repo's origin-derived owner/repo.
  Every predicate is a locally stored fact (origin URL, host-maps conf,
  record fields); no remote issues-system API contact occurs anywhere in the
  check. Non-tracker-host stores (git-init sandboxes with no origin,
  pull-only repos, unmapped hosts) skip the identity classes entirely — no
  sweep noise. The check composes with the existing shared scan machinery so
  scoped (`--number`) mode inherits it.
- **RED** — a new regression-tier test module
  (`test_validate_yaml_identity.py`, seeded-scratch-store subprocess style of
  the existing `test_validate_yaml_scoped.py` fixtures, sandbox stores with
  configured origin URLs) asserting the flagged classes; against the current
  tool the divergent records produce no error-class lines and exit 0, so every
  identity assertion fails.
- **GREEN** — the sweep implements the three checks behind the tracker-host
  predicate; the RED suite turns green; seeded consistent-record sandboxes
  (and identity-repaired seeded records) produce no identity class lines and
  exit 0; existing suite modules (`test_validate_yaml_scoped.py`,
  `test_validate_yaml_exit_codes.py`, full default run) stay green.
- **Tier marks** — authored tests: regression tier (changed area + direct
  dependents; rides the default gate). No smoke change to the existing suite;
  no pr-validation, no heavy tier. The spec's own behavioral instrument — an
  executed offline seeded scratch-store `validate-yaml` run reading emitted
  class lines and exit code — is cycle-time executed evidence, kept out of
  test files (scratch observation stays ephemeral/session-space).
- **Instrument** — `uv run pytest tests/test_local_issues/test_validate_yaml_identity.py`
  (RED first, GREEN after); the executed offline CLI run against a seeded
  scratch store on the branch checkout for the spec's SC-2 instrument; then
  `uv run pytest` (full default run) at cycle time.

### Item 3 — SC-5 (CLI-mechanics reference carries the classes)

- **Deliverable** — `.opencode/skills/issues/SKILL.md` §1 routes tool
  mechanics through `references/local-issues-cli.md`; that reference's
  `validate-yaml` behavior row and its YAML-validation taxonomy enumeration
  name the three delivered classes (`missing-remote-identity`,
  `remote-number-mismatch`, `remote-repo-mismatch`) consistent with the
  tool's delivered report form, note the tracker-host scoping and the
  local-facts-only boundary, and leave the command's flag inventory unchanged
  (`validate-yaml [--number]`).
- **RED** — grep for the three class names across the reference returns no
  matches (the row and taxonomy carry only the pre-existing
  `malformed-frontmatter` / `invalid-yaml` / `schema-violation` set).
- **GREEN** — the row and taxonomy sections are amended in place with the
  three class names and their one-line semantics; no flag added to the flag
  inventory.
- **Tier marks** — no authored test; instrument class = fact check (read/grep).
- **Instrument** — grep of `local-issues-cli.md` for each delivered class name
  in the row and taxonomy sections; read of the row confirming flag inventory
  unchanged.

### Item 4 — SC-4 (issues card §7: identity-anchor doctrine)

- **Deliverable** — the issues card §7 mirror-repair block states the
  identity-anchor doctrine (R-4): the remote-tracker-assigned number is the
  record's identity anchor; the just-created correct record is never deleted
  in favor of a stored phantom folder; a stored pointer naming a different
  folder is the defect to repair, never the precedent to follow — block-level
  provenance marker per house card style.
- **RED** — grep of §7 for the anchor statement, the anti-phantom-precedent
  prohibition, and the stored-pointer-is-the-defect rule finds none (current
  §7 names creating at the remote-assigned number but carries no anchor
  doctrine).
- **GREEN** — the doctrine sentences are added to §7's mirror-repair block
  (the block R-3/R-4 amend per spec Dependencies), extending the existing
  repair-doctrine paragraph without touching §7's other trigger clauses.
- **Tier marks** — no authored test; instrument class = fact check (read/grep).
- **Instrument** — grep of `skills/issues/SKILL.md` §7 for each doctrine
  element of R-4.

### Item 5 — SC-3 (issues card §7: diverged-store reconciliation disposition)

- **Deliverable** — the issues card §7 mirror-repair block states the
  reconciling disposition (R-3) for already-diverged stores: local folder
  numbers and in-record pointers are renumbered to the tracker-assigned number
  via the existing `renumber` command; pointer corrections (remote body via
  the platform CLI; local cross-references) are performed in the same
  reconciliation workflow; alias-keeping is not the disposition; a collision
  at the target number is resolved from the records' identities, never
  silently overwritten.
- **RED** — grep of §7 for the renumber disposition, the same-workflow pointer
  correction, the no-alias statement, and the identity-decided collision rule
  finds none.
- **GREEN** — the disposition sentences are added to §7's mirror-repair block,
  composing with Item 4's anchor doctrine in the same block; `renumber`'s
  tool behavior is untouched (spec §2: the primitive is unchanged).
- **Tier marks** — no authored test; instrument class = fact check (read/grep).
- **Instrument** — grep of `skills/issues/SKILL.md` §7 for each R-3 element.

## Dependency order

1. **Item 1 first** — the preservation baseline must be captured before Item 2
   modifies the tool file; its RED is the only pass executed against the
   untouched file. Its GREEN (re-verification) runs after Item 2.
2. **Item 2 second** — the tool change is the only code-bearing item; Items 3
   and 2 share the `validate-yaml` surface and the class names Item 2 fixes.
3. **Item 3 third** — the reference row must name exactly the classes the
   tool emits, so it depends on Item 2's delivered names and report form.
4. **Items 4 and 5** — both edit the §7 mirror-repair block; Item 4's anchor
   doctrine grounds the block and Item 5's reconciliation disposition composes
   with it, so they run in that order, sequenced after Items 2–3 (same stage)
   to keep one commit per concern on the shared branch. Item 5's RED does not
   depend on Item 4's change, only on §7's pre-change state.

No cycles: every item's RED runs against state an earlier item (or the trunk
baseline) already delivered.

## Traceability

| Item | SC(s) |
|------|-------|
| Item 1 | SC-1 |
| Item 2 | SC-2 |
| Item 3 | SC-5 |
| Item 4 | SC-4 |
| Item 5 | SC-3 |

Every SC (SC-1…SC-5) is covered by exactly one item; every item traces to one
SC. Spec §2 exclusions honored: no `#2723` warn→refuse change, no tool-side
remote-body pointer correction, no `renumber` behavior change, no root-repo
source change.

## Verification summary

- Fact-check instruments (read/grep/executed CLI reads): Items 1, 3, 4, 5 —
  outputs captured in the session record as PR Evidence.
- Executed behavioral instrument: Item 2's offline seeded scratch-store CLI
  run (spec's SC-2 instrument) — executed evidence, not a committed artifact.
- Authored tests: one module, `test_validate_yaml_identity.py`, regression
  tier, marked at creation, rides the default gate. No pr-validation or
  heavy-tier test anywhere in the plan.
- At cycle time: `uv run pytest` (full default run) green on the branch in the
  worktree; all five SC instruments re-run on the branch output before the
  fresh-context verify dispatch; the verify PASS and suite outputs feed the
  PR body's Evidence section.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
