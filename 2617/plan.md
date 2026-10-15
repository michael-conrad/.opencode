---
number: 2617
title: "Plan — retire the routing.md dispatch table; descriptions become the sole routing surface"
spec: .opencode/.issues/2617/spec.md
branch: feature/2617-retire-routing-table
base_tip: f5f82527
---

# Plan — .opencode#2617

## Provenance and authorization

- **Authorization:** "Approved for PR: .opencode#2617" (developer, 2026-10-15) — carries the
  item through spec → plan → implement → verify → PR; only merge remains human-only.
- **Branch:** `feature/2617-retire-routing-table` in the `.opencode` submodule, created from
  base tip `f5f82527` (verified = `origin/main` tip on 2026-10-15).
- **Parent pointer drift:** parent repo records gitlink `c6beaeed`; submodule checkout is at
  trunk tip `f5f82527`. This pending bump rides the SC-5 parent commit (branch card §2c) —
  no parent action before the submodule PR merges.

## Execution notes

- **Audit-first ordering** (spec Design Decision 1): the coverage audit (Item 1) gates the
  remediation (Item 3), the deletion (Item 4), and the PR.
- **Pre-change probe ordering (hard constraint):** Item 2 runs while the submodule working
  tree is clean at the pre-change commit — the harness ordered precondition cycle
  (commit → push → fetch/verify → run, tests-v2/AGENTS.md §4) tests the effective submodule
  commit as it exists on the remote. Any deck edit before the pre-change run invalidates it.
  Item 2 therefore precedes every deck edit.
- **Measurement vehicles live outside the submodule:** the scenario script and MCP-client
  vehicles are authored under `{project_root}/tmp/2617/` — outside the submodule, keeping its
  tree clean for the harness git-state gate, with identical bytes across both probe runs
  (SC-8's only-differing-input requirement). Harness placement/tier mechanics are governed by
  the `behavioral-testing` card — the named owner for those decisions.
- **Ledger issue is closed:** `.opencode#2534` was closed not_planned by the #2610 purge
  (2026-10-14, before this spec was authored). The spec targets the closed issue's comments as
  the record location (SC-6); Item 7 posts the entry without reopening.
- **No CHANGELOG entry:** repo convention records routine deck changes in commit messages;
  the release trio owns CHANGELOG at release time (precedent: #2610, #2615 skill-edit commits
  touched no CHANGELOG). Spec §3 leaves this to the plan; decision recorded here.
- **Commit strategy:** Items 3–4 land as atomic deck-edit commits on the feature branch
  (Item 4's deletion and its `opencode.jsonc` conformance are one commit — a dangling
  instruction path breaks every session's config load). Squash to one per-issue commit happens
  at PR creation (git-workflow-pr §3).
- **Verification loop:** Item 9 is the verify-card dispatch — spin-bounded per .opencode#2606.

## Items

### Item 1 — Coverage-audit dispatch and artifact (SC-4)

- **Deliverable:** `.opencode/.issues/2617/audit/coverage-map.md` — the fresh audit's
  row→surface map for all 28 enumerated rows (R1–R27 plus the card-origins footer, the
  audit's fixed criteria set), the audit verdict, and remediation decisions with grounds.
- **RED:** the artifact does not exist; no zero-uncovered-rows verdict is recorded in the
  issue folder. (`test ! -e .opencode/.issues/2617/audit/coverage-map.md` currently holds.)
- **GREEN:** dispatch ONE fresh-context sub-agent that receives (a) the pre-removal
  `routing.md` row enumeration (row intent → target card, as criteria) and (b) instruction to
  derive each row's post-removal dispatch surface from the live deck — card frontmatter
  descriptions and `floor.md` — and receives none of the spec's §2 preliminary destinations
  or verdicts. The dispatch reports its derivation, uncovered rows, and under-trigger
  candidates. The orchestrator reconciles the fresh derivation against §2's preliminary map;
  every disagreement is adjudicated on live-deck evidence and recorded. The artifact records
  the final map, the verdict, and remediation decisions.
- **Instrument:** artifact exists; each of the 28 rows carries a named live destination (card
  description and/or floor content); the verdict is stated; deviations from §2 are listed
  with grounds. Mechanical part: `test -e` plus content inspection against the §2 enumeration.

### Item 2 — Pre-change hello-probe run (SC-8, first session)

- **Deliverable:** pre-change harness session artifact under
  `{project_root}/tmp/2617/artifacts/pre/` — manifest, `session.yaml` with the session's
  prompt-token accounting, scenario record.
- **RED:** the artifact directory is absent — no pre-change session with prompt-token
  accounting exists.
- **GREEN:** one tests-v2 harness session driven by the scenario script (authored under
  `{project_root}/tmp/2617/`) with a trivial hello-style prompt, model resolved by
  `tests-v2/default-model.sh` (`DEFAULT_TEST_MODEL`, no model-shopping), executed at effective
  submodule commit `f5f82527` (clean tree, remote-contained — the harness gate verifies
  mechanically). The artifact exports the session's prompt-token accounting.
- **Instrument:** artifacts present; the prompt-token count is extractable from
  `session.yaml`; the manifest records scenario/model/prompt/commit. Governed end-to-end by
  the `behavioral-testing` card.
- **Sequencing:** MUST complete before Item 3's first deck edit.

### Item 3 — Description remediations the audit flags (SC-4, remediation element)

- **Deliverable:** frontmatter description edits to each card the audit found under-triggering
  its row's intent (§2 preliminary candidates: `skills/verify/SKILL.md` — the on-demand-audit
  trigger; `skills/wiki-operations/SKILL.md` — the wiki submodule-conversion element), through
  skill-creator governance (developer-directed carve-out applies; the content standards bind —
  both abstraction levels, deliberately pushy, never user-phrase matching).
- **RED (verified live at `f5f82527`):** `verify`'s description states the completion-claim
  trigger but no on-demand-audit trigger; `wiki-operations`'s description covers
  edit/creation/sync, the `.wiki.git` checkout, sidebar/footer, provisioning, publishing, and
  recovery — but not the submodule-conversion element.
- **GREEN:** each flagged description states its missing element while keeping every existing
  trigger. Where the audit adjudicates a candidate as adequately covered, the coverage-map
  artifact records that decision with grounds and no edit is made for that candidate — the
  spec gives the fresh audit the decision ("the fresh audit decides whether the description
  gains the audit trigger", §2 R7).
- **Instrument:** read the live frontmatter descriptions — each remediated element present, no
  trigger removed; unremediated candidates have a recorded grounds decision in the artifact;
  `./.opencode/tools/skildeck lint` clean.

### Item 4 — Delete `routing.md` and conform every live reference (SC-1, SC-2, SC-3)

- **Deliverable:** `.opencode/routing.md` deleted; the seven submodule edit sites conformed
  (blast radius verified by grep at `f5f82527` — no other live hits exist outside the declared
  non-live surfaces):
  1. `opencode.jsonc` line 5 — instructions array drops the `.opencode/routing.md` entry
     (retains `.opencode/floor.md` only).
  2. `prompts/default.txt` line 3 — read directive names `floor.md` only; the
     description-matching clause is retained (e.g. "read .opencode/floor.md before acting,
     and match your intent against skill descriptions before dispatching").
  3. `floor.md` line 8 — loading-on-demand paragraph drops the `.opencode/routing.md` clause
     while retaining the directive: match current intent against the skill descriptions the
     platform presents and load only what matches (SC-3).
  4. `floor.md` line 106 — deck-governance line drops the ", or the routing index" clause.
  5. `.opencode/AGENTS.md` lines 7–8 — pointer text names `floor.md` only.
  6. `skills/skill-creator/SKILL.md` line 3 — frontmatter description's file list drops the
     routing.md clause ("under skills/, guidelines/, or floor.md").
  7. `skills/skill-creator/SKILL.md` line 23 — admission-gate item 3 no longer names
     "a routing entry"; the mechanism types become a skill-description trigger or a
     fact-decidable enforcement point (the spec's two-type end state — the live text's
     "a skill reference" middle type does not survive).
- **RED (all verified live):** every site above currently references `routing.md`;
  `routing.md` exists (44 lines at `f5f82527`).
- **GREEN:** the per-site conformance above; `routing.md` absent.
- **Instrument:** SC-1 `test ! -e .opencode/routing.md` at the submodule branch HEAD; SC-2
  grep `routing\.md` run from the submodule root with the declared exclusions (`attic/`,
  `CHANGELOG.md`, `node_modules/`, `.issues/` worktrees, `vector_db/`, tool caches,
  `test-artifacts/`, `tmp/`, `.git/`) returning zero hits — this item achieves the
  submodule-side zero; the parent-rooted zero-hit check completes SC-2 at Item 10 (the parent
  `AGENTS.md` stays non-conformed until the post-merge commit, so a parent-rooted grep cannot
  be zero at this item's position); each enumerated submodule point inspected for conformance
  (SC-2); `floor.md`'s loading-on-demand paragraph inspected for the retained directive
  (SC-3). Any additional live hit the submodule-rooted grep reveals is conformed before
  GREEN. (Mechanical note: a plain recursive grep from the parent root DOES descend into the
  submodule checkout — the parent-rooted search at Item 10 excludes `.opencode/` to realize
  the spec's "does not traverse the submodule" intent.)
- **Safety:** the deletion and the `opencode.jsonc` conformance land in one atomic commit.

### Item 5 — Post-change hello-probe run (SC-8, second session)

- **Deliverable:** post-change harness session artifact under
  `{project_root}/tmp/2617/artifacts/post/` — same requirements as Item 2.
- **RED:** the artifact directory is absent.
- **GREEN:** one harness session with the scenario script bytes identical to Item 2's
  (sha256 recorded in both manifests and matching), same model resolution, same prompt,
  executed at effective submodule commit = the feature-branch HEAD carrying Items 3–4,
  committed and pushed (harness ordered precondition cycle).
- **Instrument:** as Item 2, plus the recorded scenario-script hash equality across the two
  runs and distinct effective-commit values (`f5f82527` vs post-change HEAD) — the deck
  commit is the only differing input.

### Item 6 — Clean-room token-evaluation verdict (SC-9)

- **Deliverable:** a verdict record in `{project_root}/tmp/2617/artifacts/` produced by a
  separate fresh-context dispatch that reads ONLY the artifact directory and the SC-8/SC-9
  criteria text — not the spec body, not session context.
- **RED:** no evaluation verdict record exists in the artifact directory.
- **GREEN:** the verdict record states the pre-change prompt-token count, the post-change
  count, and the delta, and records the comparison outcome (post-change < pre-change holds or
  does not).
- **Instrument:** the record exists in the artifact directory, states both counts and the
  delta, and names the outcome. (SC-9 is behavioral — the instrument is the evaluation
  dispatch, not a file assertion.)

### Item 7 — Retirement-decision ledger entry (SC-6; after Item 1)

- **Deliverable:** a comment on `.opencode#2534` (via `local-issues comment`) recording: what
  was retired (the `routing.md` dispatch table), why (duplicate dispatch surface; descriptions
  are the router per skill-creator card standards; demonstrated drift — dead vendor-hf
  reference, notebooks mapping to a nonexistent connector card, unnamed release-trio cards),
  the developer ruling of 2026-10-15 as the authorization anchor ("the table is a danger"),
  and the coverage-audit outcome (zero uncovered rows post-remediation). The audit-outcome
  element requires Item 1's artifact to exist first.
- **RED:** `.opencode#2534`'s comments contain no #2617 retirement entry.
- **GREEN:** the entry is present on the closed ledger issue (comment only — no reopen).
- **Instrument:** `./.opencode/tools/local-issues read --number .opencode#2534 --type comments`
  shows the entry.

### Item 8 — Retrieval-index refresh (SC-7)

- **Deliverable:** the `opencode_deck` collection reindexed against the post-change deck;
  zero `routing.md`-derived chunks.
- **RED (verified 2026-10-15):** the collection is stale — it indexes neither `routing.md`
  nor `floor.md` (both created by the #2490 re-rip; the index predates them; 5770 chunks over
  445 paths; DB mtime 09:07:52 today with no watch server running). No completed reindex
  against any post-change state exists.
- **GREEN:** `reindex(source_name='.opencode-deck')` runs against the post-change working
  tree; afterwards the collection holds zero chunks with `rel_path == 'routing.md'` and
  non-zero chunks for `floor.md` (freshness witness proving the reindex ingested current
  root-level files — guards against a vacuous zero).
- **Instrument:** a minimal MCP stdio client script (authored under `{project_root}/tmp/2617/`)
  spawning `uvx --with "mcp<2" ragsync --config .opencode/ragsync-config.yaml` and calling the
  `reindex` tool (server tool surface verified live: `search`, `list_sources`, `get_document`,
  `get_index_status`, `reindex`); then
  `uv run --with chromadb python -c "import chromadb; c=chromadb.PersistentClient(path='vector_db'); col=c.get_collection('opencode_deck'); print(len(col.get(where={'rel_path': 'routing.md'})['ids']))"`
  → `0` (query mechanics validated live this session).

### Item 9 — Fresh-context verification and suite (SC-4 confirmation clause; supports all SCs)

- **Deliverable:** the verify-card dispatch — ONE fresh-context reviewer reading the spec's
  SCs, the diff against `f5f82527`, the executed test output, and the audit/probe/evaluation
  artifacts; independently re-derives the row→surface map against the live deck (SC-4's
  "fresh-context reviewer re-derives… and confirms zero uncovered rows") and returns a
  verdict; findings remediated and re-reviewed until zero findings.
- **RED:** no verdict exists for this deliverable.
- **GREEN:** a zero-finding verdict is recorded; the suite is green with captured output.
- **Instrument:** the verify dispatch; plus the structural suite with captured output —
  `./.opencode/tools/skildeck lint`, `./.opencode/tools/reference-integrity`, the tracked
  content-verification suite (`pytest tests/` in the submodule), and the harness default tier
  per the test-tier discipline (#2541: smoke + regression default, full suite non-default;
  the Item 2/Item 5 runs are the smoke-level harness evidence for this item).

### Item 10 — Parent-repo conformance commit and parent PR (SC-5; post-merge)

- **Precondition (ordering gate, git-workflow-pr §2f):** the submodule PR for #2617 has
  merged. This item does not start before that gate clears.
- **Deliverable:** parent branch `2617-retire-routing-table` from the parent trunk tip; ONE
  commit carrying (a) the parent `AGENTS.md` conformance — pointer text (lines 11–12: the
  "routing is [.opencode/routing.md]" clause dropped) and the reference-files table row
  (line 38: the `.opencode/routing.md` row dropped) — and (b) the `.opencode` submodule
  pointer bump to the merged deck trunk tip. No pointer-only commit. Then the parent PR via
  `gh pr create`.
- **RED (at item start):** parent `AGENTS.md` still references `routing.md` (verified live
  2026-10-15: lines 11–12 and 38); the gitlink points at the pre-change commit.
- **GREEN:** the single commit carries both changes; the gitlink resolves to the merged deck
  commit satisfying SC-1–SC-4.
- **Instrument:** at the parent branch HEAD: `git ls-tree HEAD .opencode` resolves to the
  merged deck tip; the parent-rooted SC-2 grep (`grep -rn "routing\.md"` from the parent root
  excluding the declared non-live surfaces and `.opencode/` — completing the parent-side half
  of SC-2 that Item 4 deferred) returns zero hits; the same commit contains the `AGENTS.md`
  edit (`git show --stat HEAD`).

## Pipeline boundary

After Item 9: run the git-workflow-pr checklist (every item committed or N/A; suite green
with captured output this session; verify PASS recorded; no pointer-only parent PR; parent PR
blocked while the submodule PR is pending), squash to one commit closing #2617, create the
submodule PR via `gh pr create`, and HALT — merge is human-only. Item 10 executes after the
merge is confirmed.
