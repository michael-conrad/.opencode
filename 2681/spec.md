<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored. Revised from the 2026-10-28 DEFECT filing (#2681)
     into this specification under the developer's directives of 2026-10-28:
     (D-1) "regression: .opencode#2681 - the agent is supposed to auto-remediate
     yaml files in .issues/" and (D-2) "revise this issue to spec to fix the
     underlying issue". Triage evidence: research/triage-2026-10-28.md. -->

# [SPEC] Issues-data hygiene — store defects are repaired in place, not ticketed

## Problem

During the #2664 PR pre-create checklist on 2026-10-28, the structural gate
`local-issues validate-yaml` exited 1. The producing agent dispositioned the
red output by filing a fix issue (#2681) instead of repairing the issue store,
although issue-store repairs are agent-owned, authorization-free hygiene under
the store's own workspace guide (`.opencode/.issues/AGENTS.md`, 2026-09-17
developer directive): "It is the agent's responsibility to repair, remediate,
and revise as needed ALL issue-ticket data files in the issues-data branches…
An agent that encounters drift or defects in issues-data records and leaves
them unrepaired (or halts awaiting authorization or a spec) has failed its
hygiene duty." The #2682 PR merged over the dispositioned finding; the store
stayed red. The developer corrected on 2026-10-28 (D-1) and directed this
revision (D-2).

Observed failures (triage record: `research/triage-2026-10-28.md`, verified
2026-10-28 against live surfaces):

- **O-1 — the defect population is 273 files, not 2.** Unscoped
  `./tools/local-issues validate-yaml`, run with cwd = the `.opencode`
  repository, exits 1 with 273 `invalid-yaml` report lines across the
  `.opencode/.issues` store — including both files the #2681 filing named
  (`980/spec-artifacts/phase-state.yaml`,
  `_legacy/1156-remove-slug-padding/spec-artifacts/vbc-artifact.yaml`). The
  filing's "two malformed YAML data files" output basis is not reproducible
  against the filing-time store (sampling at the pre-filing commit `eeb982fd7`
  shows the wider population already present); the validator's own code is
  byte-identical between the filing-time tip `32566bc9d` and current `HEAD`.
- **O-2 — the agent dispositioned instead of repaired.** The #2682 PR body
  records the route: "Pre-existing failure dispositioned: `validate-yaml` exit
  1 on 2 invalid-YAML files predating this change → filed
  michael-conrad/.opencode#2681 (fix issue), not a pass-through." Both named
  files still fail YAML parsing today; the repair never happened and never
  waited on anything — it is authorization-free.
- **O-3 — the deck offers disposition where repair is in scope.** Two live
  surfaces carry the clause family "remediated or dispositioned via a filed
  fix issue" with no issues-data carve-out: the `git-workflow-pr` card's
  pre-create checklist ("red output blocks PR creation until every failure is
  remediated or dispositioned via a filed fix issue; 'the failures
  pre-existed' is a defect to file, never a pass-through (#2553)") and the
  `implement` card's implementation-workflow suite-green gate ("every failure
  is remediated or dispositioned via a filed fix — never passed through as
  'pre-existing' (#2553)"). For a failure whose remedy is issue-store hygiene,
  both surfaces read as licensing the filed-ticket branch over the free,
  in-scope repair.
- **O-4 — the floor's scope doctrine gives the store guides no standing.** The
  floor defaults an untokened session to "reading, searching, and reporting
  only — no branch creation, no file modification, no PR creation, no issue
  closure" and bounds a dispatched sub-agent to "no action beyond those the
  dispatch prompt requests". The store guides' authorization-free `.issues/`
  writes and hygiene duty collide with both clauses as written, so an agent
  honoring the floor's always-injected surface halts on — or tickets — the
  repair the guides mandate.
- **O-5 — the record itself is damaged.** #2681's title and body assert the
  2-file fact base; its `needs-approval` label contradicts the repair's
  authorization-free class — and that contradiction is live on both surfaces,
  local and remote, which carry the identical label set
  (`needs-approval`, `spec-fix`).

Root causes covered:

- **RC-1 (→ O-1)** — the store's hygiene state: 273 issue-store YAML data
  files predate and outlive the filing, unrepaired.
- **RC-2 (→ O-2, O-3)** — the deck's failure-handling rules route
  hygiene-reparable failures into filed tickets; the rule text never names the
  issues-data class, so its "the failures pre-existed" filing clause reads as
  the whole action.
- **RC-3 (→ O-2, O-4)** — the floor's default read-only scope and dispatch
  scope-bounding have no exception for store-guided operations, so the
  always-injected surface contradicts the store guides on the exact action the
  guides mandate.
- **RC-4 (→ O-5)** — the filed record froze the misroute: the ticket carries
  the 2-of-273 fact base and a `needs-approval` label on an authorization-free
  repair class, live identically on both surfaces — damage that rides the
  same filing the ticket documents and that outlives the work.

## Scope

Deck surfaces of the `.opencode` repository, plus issue-store data:

- The `.opencode` repo's issue store (`.opencode/.issues`, its `issues-data`
  branch) — all 273 invalid-YAML files repaired to parse-valid YAML
  (`_legacy/` subtrees included; archived content is repaired for validity,
  never restructured or re-interpreted).
- `skills/git-workflow-pr/SKILL.md` — the pre-create checklist's
  failure-handling rule gains the issues-data remediation-first clause and its
  boundary.
- `skills/implement/references/implementation-workflow.md` — the suite-green
  gate row reconciled to the same rule.
- `floor.md` — the scope doctrine gains the issues-data exception, so the
  always-injected surface stops contradicting the store guides.
- `tests-v2/` — one behavioral scenario reproducing the observed failure and
  one companion proving no over-reach.
- The `.opencode#2681` record — title, body, and labels reconciled to the
  corrected fact base on both surfaces (record maintenance inside this
  revision's flow; SC-7 decides the end state).

Deck text edits ride deck governance: the `skill-creator` admission gate
applies at implementation. A substantive write to `floor.md` triggers the
whole-card-on-touch conversion rule — the floor is already
writing-discipline-converted (#2664/#2665), so the edit retains that
conformance across the whole floor's normative prose rather than re-converts.

## Requirements

- **R-1 — store repair (O-1).** The `.opencode` repo's issue store SHALL be
  parse-clean: unscoped `local-issues validate-yaml`, run with cwd = the
  `.opencode` repository, exits 0 printing zero `invalid-yaml` lines. Repairs
  touch YAML validity only — a repair preserves each file's semantic content,
  changing nothing beyond what validity requires. Where validity admits more
  than one reading, the repair names the chosen reading and its ground in
  `.opencode/.issues/2681/research/repair-log.md` (file, chosen reading,
  ground) before the store sync — a multi-reading repair with no matching log
  entry violates this requirement. Repairs ride the store's
  `issues-data` branch via the store's own tooling (`local-issues`; plain
  file edits plus the tool's sync), never a feature branch.
- **R-2 — remediation-first routing in the deck (O-2, O-3).** The deck's
  failure-handling rules — the `git-workflow-pr` pre-create checklist clause
  and the `implement` implementation-workflow suite-green gate row — SHALL
  classify a failure whose remedy is issue-store hygiene (workspace-local
  repair of issue-store data on the store's `issues-data` branch: YAML
  validity, record fields, store metadata — a repair the store's workspace
  guide already authorizes as agent-owned and authorization-free) as
  remediate-in-place: the producing agent repairs the store in the same
  working session, and the blocked gate proceeds on that repair. Each failure
  routes independently by its own remedy class; the filed-fix-issue
  disposition branch remains the route for failures whose remedy requires
  implementation authorization — any change outside the issue stores (source
  code, tests, deck content, build configuration). Filing a fix issue never
  substitutes for an available, in-scope hygiene repair; the "pre-existing
  failures are a defect to file, never a pass-through" clause keeps applying
  to implementation-remedy failures untouched.
- **R-3 — the floor's issues-data exception (O-2, O-4).** The floor's scope
  doctrine SHALL name the exception: operations an issue store's own workspace
  guide authorizes — reading, writing, and repairing workspace-local
  issue-store data on the store's `issues-data` branch via the store's own
  tooling, including hygiene repairs and the session-start `init`/`sync`
  sequence — are agent-owned workspace maintenance: they sit outside the
  default read-only scope's file-modification blocklist and outside a
  dispatched session's scope-bounding, and they require no scope-bearing
  token. The exception covers issue-store data only; source code, deck
  content, feature branches, and PRs stay inside the existing gates.
- **R-4 — record truth (O-5).** The `.opencode#2681` record SHALL read
  consistently across its surfaces: the GitHub tracker and the local store
  folder agree on title and labels; the remote body carries the corrected
  fact base as a structured summary closing with a resolvable artifacts
  pointer; `.opencode/.issues/2681/spec.md` is the single authoritative spec.
- **R-5 — behavioral restoration and boundary (O-2 regression-proofing).**
  The behavioral harness (`tests-v2/`) SHALL carry (a) a scenario reproducing
  the observed failure — in a PR-prep session whose `validate-yaml` gate exits
  1 on issue-store data, the agent repairs the store in place via the store's
  tooling and files no disposition ticket — and (b) a companion scenario
  proving the boundary — a failure whose remedy requires implementation
  authorization still routes to the filed-fix-issue disposition and blocks the
  gate until dispositioned.
- **R-6 — no mechanism (standing ruling, #2664 spec Approach).** The change
  adds no tool command, no wrapper, no enforcement hook, and no script
  outside the `tests-v2/` harness scenarios this spec orders — deck rule
  text, store data repair, and harness scenarios only.

## Success criteria

- **SC-1 (structural) (→ R-1).** Unscoped `local-issues validate-yaml`, cwd = the
  `.opencode` repository, exits 0 with zero `invalid-yaml` lines.
  *Instrument:* executed command; captured output.
- **SC-2 (structural) (→ R-1).** Repair minimality and disclosure: the
  store-branch diff alters no file outside the issue store, and no YAML file
  beyond what validity requires — and every changed file the review
  classifies as admitting more than one valid reading carries a matching
  choice entry (file, chosen reading, ground) in
  `.opencode/.issues/2681/research/repair-log.md`. *Instrument:* recorded
  fresh-context diff review of the hygiene commits cross-checking the diff
  against that repair log — zero findings, or findings remediated before
  re-review; the verdict and findings live in the record.
- **SC-3 (structural) (→ R-2).** Both rule surfaces carry the clause. *Instrument:*
  grep in `skills/git-workflow-pr/SKILL.md` and
  `skills/implement/references/implementation-workflow.md` for the issues-data
  remediation-first clause; read-back confirms the actor named (the producing
  agent), the class named (issue-store hygiene), and the boundary stated
  (implementation-remedy failures keep the filed-fix-issue route).
- **SC-4 (structural) (→ R-3).** The floor carries the exception. *Instrument:* grep
  in `floor.md` for the issues-data exception (issue store, issues-data,
  no scope-bearing token); read-back confirms the bounds (issue-store data
  only; source, deck content, branches, PRs excluded).
- **SC-5 (behavioral) (→ R-5a).** Scenario (a) passes — the reproduced-failure
  scenario. *Instrument:* a scenario script under `tests-v2/behaviors/`
  executed through the harness (`bash tests-v2/with-test-home opencode run`,
  per the `behavioral-testing` card — no grep or static-analysis substitute);
  clean-room evaluation asserts: the store was repaired, no disposition
  ticket was filed.
- **SC-6 (behavioral) (→ R-5b).** Scenario (b) passes — the companion boundary
  scenario, same instrument family; asserts the implementation-remedy failure
  still blocks the gate and routes to a filed disposition.
- **SC-7 (structural) (→ R-4).** Record consistency. *Instrument:* read-back of
  GitHub #2681 and `.opencode/.issues/2681/` — titles equal, labels equal,
  the remote body carries the corrected fact base (the 273-file store
  population, and the filing's 2-file counting named as non-reproducible
  damage rather than as output) verified by reading the fetched body, the
  body's artifacts pointer resolves to `.opencode/.issues/2681/`, the local
  store body mirrors the remote body, and `spec.md` is present and
  store-authoritative.
- **SC-8 (structural) (→ R-6).** No mechanism added. *Instrument:* the change's file
  list against its base tip adds or modifies nothing under `tools/`, `hooks/`,
  or `plugins/`, and adds no script outside the `tests-v2/` scenario set.
- **SC-9 (structural) (→ dependent-behavior preservation).** Test-contract
  currency: the structural suites that assert the amended surfaces still
  pass when the rule text changes under them. *Instrument:* executed
  `tests-v2/test-cleanroom-eval-contract.sh`, `tests-v2/test-skill-deck-completeness.sh`,
  and `tests-v2/test-trunk-hook.sh`, captured output.

## Out of scope

- `local-issues validate-yaml` behavior — including the cwd-scoped walk that
  leaves a parent-root run blind to the `.opencode` store (`cmd_validate_yaml`
  resolves the store relative to the process cwd). A tool change needs its own
  spec'd issue; the original filing's validator boundary carries over.
- The parent repository's own issue store (the root `.issues`): scans clean as
  of 2026-10-28 (exit 0). The restored rules apply to it deck-wide; it needs
  no repair work.
- Deck governance mechanics — the `skill-creator` admission gate is exercised
  at implementation, never changed by this work.
- Re-classification of earlier issues' specs or comments under the restored
  rules (developer-side cleanup, per the #2664 precedent).
- A hygiene restatement in the `issues` skill card — the store guides carry
  the duty and inject on store contact; the restored surfaces cover the
  observed failure route without widening deck surface.
- Any hook, wrapper, script, or threshold (R-6).
- Closure logistics for #2681 itself — the ticket closes after the work
  merges, per the issues card's post-merge cleanup; the closure workflow is
  not a spec deliverable counted here.

## Approach

1. **Store repair first (R-1).** Bulk parse repair of the 273 files on the
   `issues-data` branch via the store's tooling; repairs stay minimal, and any
   multi-reading choice is logged per SC-2. Doing this before the deck text
   lands also makes this change's own PR checklist run the `validate-yaml`
   gate genuinely green rather than dispositioned.
2. **Record reconciliation (R-4, O-5).** The #2681 record — title, labels,
   and body — is reconciled on both surfaces (the local store folder and the
   GitHub tracker) as part of this revision flow, before implementation work
   starts; SC-7 decides the reconciled end state.
3. **Deck text (R-2, R-3).** Amend the two rule surfaces and the floor's
   scope doctrine; the floor edit keeps whole-card writing-discipline
   conformance. The rule text follows the store guides' own vocabulary
   (agent-owned, authorization-free, issues-data branch) so the
   always-injected surface and the conditional guides state one doctrine.
4. **Behavioral scenarios (R-5).** RED/GREEN per the `behavioral-testing`
   card's harness path: scenario (a) fails against the un-amended surfaces
   because the agent tickets instead of repairs; scenario (b) fails if the
   carve-out is written broad enough to swallow implementation-remedy
   failures.
5. **Verify and ship.** Fresh-context `verify` dispatch against these SCs,
   then the PR per `git-workflow-pr` (one PR for the issue; the store repairs
   ride `issues-data`, not the PR branch). After merge, #2681 closes as
   verified-resolved per the issues card.

Discarded alternative — an enforcement hook or wrapper that blocks filing a
disposition ticket when a hygiene repair is available: the deck surfaces that
get scripted get trashed and replaced (the developer's standing ruling in the
#2664 spec's Approach), and the failing agent in O-2 quoted the correct rule
text — the defect is a rule conflict, not a missing interlock.

## Impact

- **Consumers:** every agent session the deck serves — the failure-handling
  route changes at two rule surfaces and the floor's scope doctrine; agents
  working the `.opencode` repo's issue store gain a parse-clean store.
- **Risk — over-reach:** the hygiene class read broadly enough to swallow
  implementation-remedy failures into in-place repair. Bounded by R-2's
  boundary ("outside the issue stores") and by SC-6's companion scenario.
- **Risk — over-repair:** a store repair that rewrites content it should only
  re-validate. Bounded by R-1's preservation clause and SC-2's minimality
  review.
- **Blast radius:** `skills/git-workflow-pr/SKILL.md`,
  `skills/implement/references/implementation-workflow.md`, `floor.md`, the
  `tests-v2/` scenario set, 273 store data files, the #2681 record. No tool,
  hook, script, or other card changes.
- **Dependent tests:** structural suites asserting the amended surfaces
  (SC-9); behavioral fixtures asserting checklist behavior re-scope per the
  same SOP #2664/#2665 used, if their scripts assert the old disposition
  route.
- **Recovery:** deck edits are text; store repairs ride `issues-data`
  commits — every element reverses through branch history.

> Full spec and plan artifacts: https://github.com/michael-conrad/.opencode/tree/issues-data/2681/

Artifacts for agents: `.opencode/.issues/2681/`.