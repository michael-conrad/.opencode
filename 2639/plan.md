# Plan — .opencode#2639: authorization-scope boundary for stacked-PR shape

Spec: `.opencode/.issues/2639/spec.md` (validated). Branch:
`feature/2639-scope-boundary-stacked-pr` (submodule `.opencode`), base tip
`dc88640a`.

## Execution order

Items 1–2b strictly precede Items 3–4: the behavioral runs execute the
amended deck, and `behavior_run()`'s pre-flight git-state gate requires the
submodule working tree clean and the effective commit pushed — so the
card amendments (Items 1, 2, 2b) are committed and pushed before any
scenario run (Items 3–4). Item 3 precedes Item 4 only in reporting; both
depend on the same amended-deck state.

## Item 1 — Amend `git-workflow-pr` rule 3 (SC-1, SC-2, SC-3, SC-4, SC-6 part)

- Deliverable: `skills/git-workflow-pr/SKILL.md` rule 3 gains, after the
  "N branches / N PRs … is the violation" sentence, a scope-boundary provision
  covering: (a) scope = the developer directive that produced the work, the
  single message covering it, never a per-item decomposition (SC-1); (b) a
  later message adding work while that scope's PR is open extends the scope —
  commits ride the open branch and PR, never a second branch or PR (SC-2);
  (c) a commit with no issue ticket rides in the scope's stacked PR and never
  justifies its own PR (SC-3); (d) default is one PR; splitting requires the
  developer to have named the split (SC-4). The front-matter and HTML-comment
  provenance lines each gain one `; scope-boundary provision, .opencode#2639`
  entry (SC-6 provenance half).
- RED (executable, fixed): grep the pre-amendment rule 3 for the four
  provision markers — `directive that produced`, `extends that scope`,
  `no issue ticket`, `named the split`. All four return empty on the trunk
  state; the captured empty output is the RED record.
- GREEN: apply the amendment as above.
- Verify: (1) the same grep now hits inside rule 3 for all four provisions;
  (2) `git diff` against trunk confines removed/rewritten lines to rule 3's
  scope provision; every other clause appears unchanged in the diff context;
  (3) amended text contains no repo names and no absolute paths
  (`grep -E 'algonquian|/home/'` over the file returns nothing).

## Item 2 — Amend `git-workflow-branch` rule 1 (SC-5, SC-6 part)

- Deliverable: `skills/git-workflow-branch/SKILL.md` rule 1's one-branch
  sentence extended with the same scope definition and extension rule as
  Item 1's (a) and (b) — the branch boundary and PR boundary are one rule:
  directive-as-scope with decomposition excluded, and a later message on an
  open, unfinished scope extends that branch — no new branch opens.
  Provenance lines gain one `; scope-boundary provision, .opencode#2639`
  entry each (SC-6 provenance half).
- RED (executable, fixed): the same grep family as Item 1 run against this
  file's rule 1 pre-amendment; all markers return empty on trunk state.
- GREEN: apply the amendment.
- Verify: same three-step instrument as Item 1 (SC-5 assertion + SC-6
  confinement + root-agnostic grep), diff scoped to rule 1's one-branch
  sentence.

## Item 2b — Amend `git-workflow-branch` rule 2 (SC-9, SC-6 part)

- Deliverable: `skills/git-workflow-branch/SKILL.md` rule 2 gains, appended
  after its existing verification clauses, the bounded-verification provision
  (R-7): trunk-freshness verification is bounded and read-only — verify the
  working repo's trunk tip against its remote (fetch and compare) and proceed
  to the branch decision on that evidence; a submodule-pointer or store sync
  failure encountered during the same pass is recorded, not remediated, and
  does not block the branch decision; an unreachable working-repo remote is
  recorded and the branch decision halts for developer direction. The
  provenance lines gain the same `.opencode#2639` entry (single entry per
  line — SC-6's "exactly one new entry" is per provenance line, already
  satisfied by Items 2/2b sharing one entry).
- RED (executable, fixed): grep the pre-amendment rule 2 for the provision
  markers — `bounded and read-only`, `recorded, not remediated`,
  `halts the branch decision` (or equivalent unreachable-own-remote
  language). All return empty on the pre-amendment state; the captured empty
  output is the RED record.
- GREEN: apply the amendment.
- Verify: (1) the greps now hit inside rule 2 for all four SC-9 elements;
  (2) `git diff` against trunk confines rule-2 changes to the appended
  provision; (3) root-agnostic grep over the file returns nothing.

## Item 3 — Behavioral SC-7 via the two-SC pattern (SC-7)

- Deliverable (artifact-generation SC-N):
  `tests-v2/behaviors/2639-sc7-one-branch-one-pr.sh` — a single developer
  directive covering at least two issues plus one no-issue item in one
  opencode session against the harness-provisioned GitBucket container
  (`BEHAVIOR_NEEDS_REMOTE=1`); artifact-only generator per tests-v2 AGENTS.md
  (cross-reference header, `behavior_run`, `manifest.yaml`, exit 0, no
  assertion helpers).
- RED (executable, fixed): the Item 1/Item 2 RED grep outputs (empty hits on
  the pre-amendment deck) establish the deck state the incident record
  (spec Evidence: PRs #55/#56/#57/#59 from one directive) documents as the
  observed failure — the recorded pre-amendment deck state and the incident
  are jointly the RED basis; the scenario script itself is validated to
  generate-and-exit-0 (harness smoke) independent of evaluation.
- GREEN: post-amendment harness run produces `session.yaml` artifacts.
- Evaluation (clean-room evaluation SC-N+1, separate dispatch per tests-v2
  §6a — never merged into the artifact-generation dispatch): a clean-room
  sub-agent receives ONLY the artifact path and the SC-7 criterion, reads
  `session.yaml`, and judges from the session store (and the recorded
  container API state the run captured) that exactly one branch and one PR
  exist post-run, with one squashed commit per stacked issue — never a PR
  per item. The evaluation sub-agent receives no orchestrator context, no
  expected outcomes.
- Verify: artifact directory under `tests-v2/tmp/` with `manifest.yaml` +
  `session.yaml`; the clean-room evaluation verdict recorded in the work
  record.

## Item 4 — Behavioral SC-8 via the two-SC pattern (SC-8)

- Deliverable (artifact-generation SC-N):
  `tests-v2/behaviors/2639-sc8-second-directive-rides-open-pr.sh` — one
  session, two sequential directives: the first directive's work opens a
  scope's PR; while it is open, the second directive adds work. The second
  directive is injected in the SAME session via the harness resumption
  mechanism — `with-test-home --resume-home <prior-test-home>` with
  `opencode run --continue` (tests-v2 AGENTS.md §10.7 / cross-invocation
  resumption) — not via a fresh home, so both directives reach one session
  store.
- RED: same basis as Item 3 (Item 1/Item 2 RED greps + spec incident record,
  which includes the D3 recurrence — PR #59 opened from a follow-up directive
  while the sweep PR was open).
- GREEN: post-amendment run produces `session.yaml` artifacts covering both
  directives.
- Evaluation (clean-room evaluation SC-N+1, separate dispatch per §6a): the
  sub-agent judges from `session.yaml` that the second directive's work lands
  as commits on the first scope's branch and PR and that no second branch or
  PR exists anywhere in the session record or recorded container state.
- Verify: same as Item 3.
