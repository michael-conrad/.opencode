# PLAN: Connector-card reload semantics (`.opencode#2547`)

Date: 2026-10-14 · Spec: `.opencode/.issues/2547/spec.md` (validated PASS,
zero findings, 2026-10-14) · Target: `.opencode` submodule, feature branch →
submodule PR. Changes C1 (two frontmatter descriptions) and C2 (one
deck-debt ledger entry in `.opencode#2534`); SC-4 carries a behavioral
instrument on the tests-v2 harness.

Implementation language surface: markdown prose in deck card frontmatter —
no code. Governing cards: `skill-creator` (deck content standards bind the
written text), `behavioral-testing` (SC-4 instrument). No language card
applies; `programming-principles` has no bearing on prose-only frontmatter
edits (no module, service, or abstraction is created).

Cards in force for execution: `git-workflow-branch` (branch before first
file modification), `git-workflow-commit` (atomic commits), `implement`
(workflow reference), `git-workflow-pr` (PR boundary).

---

## Item 0 — Harness remote-wiring contract completion (R-18 fix fold-in; serves SC-4 instrument feasibility)

- **Provenance:** observed during Item 1's first RED attempt (2026-10-14, aborted
  run-fatal). `behavior_run()` sources the per-scenario setup fixture
  (helpers.sh ~1752) BEFORE the GitBucket remote wiring (~1821), and the wiring
  itself no-ops silently: `git remote add origin <gitbucket-url> || true`
  fails on the clone's pre-existing origin (production GitHub) and is
  swallowed. Net effect: for every `BEHAVIOR_NEEDS_REMOTE` scenario, the test
  project's origin remains the production remote for the whole run, and the
  harness's own `push -u origin HEAD` pushes the workdir to production. The
  `BEHAVIOR_SET_BARE_REMOTE` block (~1810) carries the identical
  `remote add || true` pattern. This completes the documented §13 contract
  ("wire its test repo as the test project's origin remote") — an
  infrastructure-maintenance fix per tests-v2 §4, not an isolation-contract
  change.
- **Deliverable:** in `behaviors/helpers.sh`: (a) move the GitBucket remote
  wiring block BEFORE the per-scenario fixture sourcing; (b) wire with
  `remote set-url origin` (fallback `remote add` when no origin exists);
  (c) drop `|| true` from the wiring steps — a wiring failure is fatal with a
  `HARNESS_FAILURE:` message naming the remediation; (d) apply the same
  set-url + fail-loud correction to the `BEHAVIOR_SET_BARE_REMOTE` block;
  `__assert_not_live_root` guard retained.
- **RED:** the first RED attempt's evidence (abort-diagnosis artifact) is the
  failing state: fixture push landed on production and the GitBucket repo had
  zero branches. Fact check on current code: wiring block sits after fixture
  sourcing; `remote add || true` pattern present in both blocks.
- **GREEN:** the reordering + set-url + fail-loud edits.
- **Verification instrument:** the Item 1 RED re-run — the fixture records
  `git remote get-url origin` into the pre-run state file; the evaluator sees
  the origin URL pointing at the GitBucket container (localhost:
  $GITBUCKET_PORT), and the production remote carries no new refs after the
  run (checked post-run from the orchestrator side).

## Item 1 — RED evidence: author and run the reload scenario against the pre-change deck (SC-4 RED)

- **Deliverable:** a tests-v2 behavioral scenario that reproduces the
  incident's shape — one session in which the agent legitimately loads
  `gb-cli` for PR-class GitBucket contacts, then makes issue-class GitBucket
  contacts — plus its RED-run artifact set and clean-room evaluation record
  showing the SC-4 criterion FAILS on the pre-change deck.
- **Files:**
  - `tests-v2/behaviors/2547-sc1-gb-cli-reload-on-class-change.sh` — copied
    from `template.sh`; `SCENARIO_TIER="3"` (tier-3 host harness — the proven
    pattern for gb-contacting scenarios, e.g. `2561-sc1-*`), `BEHAVIOR_NEEDS_REMOTE=1`,
    artifact-only generator, `exit 0`.
  - `tests-v2/behaviors/fixtures/setup/2547-sc1-gb-cli-reload-on-class-change.sh`
    — seeds the GitBucket test repo (`root/test-repo`) via the workdir's
    origin (wired to the container by Item 0's harness fix): pushes the
    default branch and a feature branch carrying `docs/notes.md` (with a
    changelog section), opens a PR (base main) that stays open by design —
    no GitBucket merge-API dependence (recorded in the scenario header) — and
    creates one open issue whose claim is verifiably false against
    `docs/notes.md`. Records pre-run remote state AND the workdir's origin
    URL for the evaluator (pattern: `2561-sc1` fixture).
- **Scenario prompt** (real-domain task, §11 — no leading questions, no
  interview; bounded like `2561-sc1`): directs the agent to do the post-merge
  work for the merged PR as its workflow requires, then reconcile the open
  issue against the delivered code (verify claim, update issue, close if
  resolved), notes the remote tracker is reachable with the gb CLI, and
  bounds the scope (no push, no new PRs).
- **RED:** with the scenario absent, SC-4's instrument does not exist — the
  failing state is the missing instrument; after authoring, the RED run
  demonstrates the defect: the evaluator finds NO gb-cli Skill-load event
  between the class transition and the first issue-class gb contact.
- **GREEN:** the ordered precondition cycle (commit → push → fetch/verify →
  run) on the pre-change submodule HEAD, `BEHAVIOR_PHASE=RED`, bash tool
  timeout ≥ 600000 ms, supervised per the 60-second poll cycle with text
  updates (§14 / behavioral-testing rule 9, verdict-confirmed conclusion);
  then the clean-room evaluator dispatch (two-SC pattern: evaluator receives
  ONLY the artifact directory path and the SC-4 criterion text) reading
  `session.yaml` as primary source.
- **Verification instrument:** artifact directory
  `tmp/behavioral-evidence-2547-sc1-gb-cli-reload-on-class-change-RED-<model>/`
  contains `manifest.yaml`, `session.yaml`, `stdout.log`, `stderr.log`,
  `exit_code`; evaluation record in the artifact directory; monitor.log /
  poll-log evidence recorded alongside.

## Item 2 — gb-cli description edit (SC-1, SC-2) — revised per spec revision 2

- **Deliverable:** `skills/gb-cli/SKILL.md` — (a) frontmatter `description`
  gains the agent-addressed reload directive replacing the revision-1
  sentence: "One load does not carry across operation classes: before your
  first GitBucket contact in a new class (issues ↔ pull requests ↔ API
  passthrough), load this card again — even though it is already in
  context." ("stays in force" phrasing absent, per SC-1.); (b) the card
  body's numbered "Construct carefully" rule carries the three-line
  class-check checklist (last class contacted / class of the command about
  to run / different class → load this card again first), no rule
  renumbering (SC-8). No existing clause removed, weakened, or re-ordered.
- **RED:** SC-1's instrument against the current text — the revision-1
  wording is present and the revision-2 directive is absent; the check
  fails. SC-8's instrument fails (no checklist in the body).
- **GREEN:** the revised description sentence and the body checklist.
- **Verification instrument:** SC-1, SC-2, SC-8 (read-based), plus
  `./.opencode/tools/skildeck lint` clean and
  `./.opencode/tools/reference-integrity skills/gb-cli/SKILL.md` exit 0.

## Item 3 — gh-cli description edit (SC-1, SC-2) — revised per spec revision 2

- **Deliverable:** `skills/gh-cli/SKILL.md` — identical revision: the
  agent-addressed directive (GitHub contact) replaces the revision-1
  sentence, and the body checklist lands in the "Construct carefully" rule.
- **RED:** SC-1/SC-8 instruments fail against the current text.
- **GREEN:** the revised sentence and the body checklist.
- **Verification instrument:** SC-1, SC-2, SC-8; skildeck lint;
  reference-integrity on the file.

## Item 4 — GREEN evidence: run the scenario against the fixed deck (SC-4 GREEN)

(Re-run sanctioned: the first GREEN run, commit `d0449688`, was clean-room-
evaluated VIOLATED — spec revision 2's recorded observed failure. This item's
re-run follows the revision-2 implementation, per the verified-FAIL
remediation path.)

- **Deliverable:** GREEN-run artifact set + clean-room evaluation record
  showing the SC-4 criterion HOLDS: the evaluator finds a gb-cli Skill-load
  event positioned between the class transition and the first issue-class gb
  contact.
- **Depends on:** Items 1–3 (the description commits must be on the pushed
  effective commit the harness checks out; the scenario exists from Item 1).
- **RED:** n/a for this item — the RED half of SC-4's cycle is Item 1's run;
  this item's assertion would pass only against the fixed deck (its check
  fails if run before Items 2–3, which is the point of the ordering).
- **GREEN:** description commits on the feature branch; ordered precondition
  cycle (commit → push → fetch/verify → run); `BEHAVIOR_PHASE=GREEN` run with
  the same supervision mandate; clean-room evaluator dispatch with the same
  isolation contract as Item 1.
- **Verification instrument:** artifact directory
  `tmp/behavioral-evidence-2547-sc1-gb-cli-reload-on-class-change-GREEN-<model>/`
  complete; evaluation record shows the Skill-load event ordering satisfying
  SC-4; monitor/poll-log evidence recorded alongside.

## Item 5 — deck-debt ledger entry (SC-3)

- **Deliverable:** one entry appended to `.opencode#2534`'s record (body
  `## Entries` section, the ledger's current append pattern) in the ledger's
  entry format: the 2026-10-07 incident as the admission-gate observed
  failure, the decision (reload semantics admitted into both connector
  descriptions), the reference to `.opencode#2547`, and
  `PR: to be linked on PR creation for #2547` placeholder (the link is filled
  when the submodule PR is opened).
- **Depends on:** Items 2–3 (the entry records their outcome).
- **RED:** read the #2534 record — no entry references `.opencode#2547`
  (verified 2026-10-14). The check fails on current state.
- **GREEN:** the entry, appended via
  `./.opencode/tools/local-issues update --number .opencode#2534 --body-file <staged body>`
  (body-append mutation; auto-commits and auto-pushes the store branch).
- **Verification instrument:** read the #2534 issue record; the entry carries
  all three elements (incident, decision, #2547 reference).

---

## Ordering

0 → 1 → 2, 3 (parallel) → 4 → 5. Item 0 (harness fix) precedes Item 1's RED
run — the scenario's fixture depends on a correctly wired origin, and the RED
run must execute with the submodule HEAD still carrying unmodified
descriptions (the scenario+fixture+harness commit is test-infrastructure and
rides the same feature branch ahead of the description commits). Item 4's
GREEN run requires Items 2–3 pushed. Item 5 follows 4 so the entry can record
verified outcomes; the PR link is filled at PR creation.

## Final verification

All four SCs checked with their spec instruments after Item 5; the verify
card dispatches one fresh-context reviewer over the spec, the diff, and the
executed test output before the PR boundary.
