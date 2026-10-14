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
    — seeds the GitBucket test repo (`root/test-repo`) with: a PR (branch with
    a real commit, merged via the GitBucket merge API — verified live against
    the provisioned container at authoring time; if the merge endpoint is
    unsupported, fall back to an open PR and a "review-ready" first-class
    task, recorded in the scenario header comment) and one open issue whose
    claim is verifiable against the code. Also records pre-run remote state
    for the evaluator (pattern: `2561-sc1` fixture).
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

## Item 2 — gb-cli description edit (SC-1, SC-2)

- **Deliverable:** `skills/gb-cli/SKILL.md` frontmatter `description`
  extended additively with both reload semantics: (a) once loaded, the card
  stays in force for the rest of the session; (b) a new operation class under
  the same utility (issues vs PRs vs API passthrough) is a fresh trigger —
  reload before the first use of each class. Pushy phrasing per card
  standards; no user-phrase matching; no existing clause removed, weakened,
  or re-ordered.
- **RED:** run SC-1's instrument against the current description — read the
  frontmatter; neither semantics is stated (verified 2026-10-14, F2 of the
  spec). The check fails on current text.
- **GREEN:** the additive extension described above.
- **Verification instrument:** SC-1 (read; both semantics stated) and SC-2
  (read; every F2-baseline clause still present) — plus
  `./.opencode/tools/skildeck lint` exits clean for the edited file and
  `./.opencode/tools/reference-integrity skills/gb-cli/SKILL.md` exits 0.

## Item 3 — gh-cli description edit (SC-1, SC-2)

- **Deliverable:** `skills/gh-cli/SKILL.md` frontmatter `description`
  extended with the identical semantics, same constraints as Item 2.
- **RED:** SC-1's instrument against the current gh-cli description — both
  semantics absent (verified 2026-10-14).
- **GREEN:** the additive extension.
- **Verification instrument:** SC-1 and SC-2 against the gh-cli F2 baseline;
  `./.opencode/tools/skildeck lint` clean;
  `./.opencode/tools/reference-integrity skills/gh-cli/SKILL.md` exits 0.

## Item 4 — GREEN evidence: run the scenario against the fixed deck (SC-4 GREEN)

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

1 → 2, 3 (parallel) → 4 → 5. Item 1's RED run must complete before Items
2–3 are committed and pushed: the harness tests the pushed effective commit,
so the pre-change RED evidence requires the submodule HEAD to still carry the
unmodified descriptions when the RED run executes (the scenario-script commit
itself is test-infrastructure and rides the same feature branch ahead of the
description commits). Item 4's GREEN run requires Items 2–3 pushed. Item 5
follows 4 so the entry can record verified outcomes; the PR link is filled at
PR creation.

## Final verification

All four SCs checked with their spec instruments after Item 5; the verify
card dispatches one fresh-context reviewer over the spec, the diff, and the
executed test output before the PR boundary.
