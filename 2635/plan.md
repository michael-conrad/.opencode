# Plan — .opencode#2635

Source spec: `.opencode/.issues/2635/spec.md` (read from the local store, the
primary record). All SCs are structural with mechanical instruments; judged
against the plan card's validation standards — each names one verifiable
property and a runnable instrument, none is reviewer-judgment-only, none
reinterprets an observable failure. Consumable as written.

## Items

### Item 1 — Delete the three non-survivor routing scripts (→ SC-2, R-2)

- **Deliverable**: `tests-v2/behaviors/issue-ops-comments-routing.sh`,
  `tests-v2/behaviors/issue-ops-sub-issues-routing.sh`, and
  `tests-v2/behaviors/issue-ops-sync-routing.sh` no longer exist in the
  `.opencode` submodule working tree.
- **RED**: file-presence probe — all three paths exist under
  `tests-v2/behaviors/` today, so the SC-2 absence assertion fails against
  current state.
- **GREEN**: `git rm` the three paths inside the `.opencode` submodule, on the
  feature branch. No other file references these scenario names (verified
  2026-10-17: repo-wide grep for the four scenario names hits only the scripts
  themselves; `test-enforcement.sh`'s `FILE_SCENARIO_MAP` carries no entry for
  any of the four — no bookkeeping rides with the deletion).
- **Instrument**: file-absence check — `test ! -e` on each of the three paths
  from the submodule root; all three must report absent.

### Item 2 — Rewrite and rename the surviving scenario (→ SC-3, R-3)

- **Deliverable**: `tests-v2/behaviors/issue-creation-routing.sh` (renamed
  from `issue-ops-core-routing.sh`) whose mandatory cross-reference header
  (lines 1–4) and `SCENARIO_TIER="2"` are preserved, whose `SCENARIO_PROMPT`
  is byte-identical to the current value, whose `SCENARIO_NAME` equals the
  new file stem `issue-creation-routing`, and whose SC comment block states
  the live routing surface: an undirected issue-creation request routes to
  the `issues` card (`.opencode/skills/issues/SKILL.md`, live deck path —
  existence-verified 2026-10-17), and issue operations use the sanctioned
  tooling — `local-issues` with qualified `repo#N` names for local stores,
  `gh`/`gb` CLIs for remote operations — never raw API scripts; plus the §6a
  clean-room evaluation pairing (tests-v2/AGENTS.md §6a, live): this script
  generates artifacts only; a separate clean-room sub-agent evaluates
  `session.yaml` for the card load and tool routing.
- **RED**: residue probe against current state — the file name and
  `SCENARIO_NAME` carry the retired abbreviation (`issue-ops-core-routing`
  contains `issue-ops`, the "core" naming the retired sub-skill), and the SC
  header routes to `issue-operations-core` while stating neither the live
  `issues` card surface, the sanctioned tooling, nor the §6a pairing — so the
  SC-3 assertions fail against current state.
- **GREEN**: rewrite the SC comment block in place, `git mv` the file to
  `issue-creation-routing.sh`, set `SCENARIO_NAME="issue-creation-routing"`.
- **Instrument**: (1) stem/`SCENARIO_NAME` agreement check — `basename` of the
  file compared to the `SCENARIO_NAME=` line; (2) retired-name substring check
  on file name and `SCENARIO_NAME` for `issue-operations` and `issue-ops` —
  zero hits; (3) prompt-verbatim check — `diff` of the `SCENARIO_PROMPT=` line
  against `git show HEAD:tests-v2/behaviors/issue-ops-core-routing.sh`'s
  corresponding line — zero diff; (4) header inspection against the
  deliverable's stated content — `issues` card, `local-issues` qualified
  names, `gh`/`gb` CLIs, never raw API scripts, §6a pairing all present.

### Item 3 — Fix the R-6 directive and run the zero-hit sweep (→ SC-1, R-1)

- **Deliverable**: `tests-v2/AGENTS.md` line 15 routes skill-deck defects
  "via the `issues` card" (substituted for "via issue-operations"); the whole
  R-1 scope — top-level `tests-v2/behaviors/*.sh` (non-recursive) plus
  `tests-v2/AGENTS.md` — greps clean for both retired-name forms.
- **RED**: current grep over the scope returns hits — the four routing
  scripts (five `issue-operations` lines, eight `issue-ops` lines) and
  `tests-v2/AGENTS.md:15` — so the SC-1 zero-hit assertion fails against
  current state.
- **GREEN**: single-wording edit to the R-6 line only; depends on Items 1 and
  2 having removed the script-side hits.
- **Instrument**: `grep -rn -e 'issue-operations' -e 'issue-ops'
  tests-v2/behaviors/*.sh tests-v2/AGENTS.md` from the submodule root — zero
  hits (grep exits 1); plus `./.opencode/tools/reference-integrity
  tests-v2/AGENTS.md` — exit 0 (the §6c mandate: the check runs before
  committing any change to agent-facing markdown).

## Dependency order

Item 1 → Item 2 → Item 3. Item 3's zero-hit sweep is only meaningful after
Items 1–2 have removed the script-side references; Items 1 and 2 touch
disjoint files and each verifies independently.

## Derivation guard

Every item traces to exactly one SC (noted per item); the spec's affected
surface — three deleted scripts, one rewritten-and-renamed script, one doc
line — is covered exactly, with no undeclared files touched. Fixtures,
`test-enforcement.sh`'s dead `FILE_SCENARIO_MAP` keys, `README.md` skill
tables, and `vector_db/` are spec-excluded and untouched. Deletions are
git-tracked and recoverable; no destructive step lacks rollback.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
