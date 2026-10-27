# Plan — .opencode#2665 per-issue squash on a published branch

Derived entirely from `.opencode/.issues/2665/spec.md`. One item per SC.
All paths deck-relative (`/home/muksihs/git/opencode-config/.opencode/`).

## Approach

The `git-workflow-pr` card §3 (Shape) gains the push mode and the three-condition
scope guard; `floor.md`'s destructive-action gate gains the one-clause carve-out;
two tier-2 behavioral scenarios + fixtures verify both branches at runtime.
No enforcement mechanism; the three conditions are agent judgment.

## Items

### Item 1 — card rule: squash + lease push + no-solicit + PR-body report (SC-1)

- **Deliverable:** `skills/git-workflow-pr/SKILL.md` §3 carries the per-issue
  squash rule stating: the producing agent performs the squash itself, pushes the
  rewritten branch with `git push --force-with-lease`, does not solicit a
  developer's force-push decision, and states the rewrite in the PR body.
- **RED:** grep the card for `force-with-lease`, "solicit", and the PR-body
  report clause — none present; an assertion script (like SC-1's instrument)
  fails.
- **GREEN:** insert the clauses into §3 after the existing squash sentences
  ("**Scoped branch rewrite (agent-owned):** the producing agent …").
- **Instrument:** `grep -c "force-with-lease" skills/git-workflow-pr/SKILL.md`
  ≥ 1 plus assertion of the no-solicit and PR-body report clauses by read;
  recorded as executed output.

### Item 2 — card rule: three-condition scope guard + fallback (SC-2)

- **Deliverable:** the same rule names the three conditions (created by this
  agent for this work; unmerged into the trunk; no other party holds the
  branch — created by, commits to, or works from it, and the producing agent's
  own push to the origin remote to carry the PR is not a hold), states the
  agent establishes each before the push, and states a branch failing any one
  condition falls under the floor's general gate.
- **RED:** read §3 for the three conditions — absent; assertion fails.
- **GREEN:** extend the rule of Item 1 with the condition list, the
  verify-before-push statement, the third condition's operative content, and
  the fallback clause.
- **Instrument:** read §3; assert each condition, the operative content, the
  establishment statement, and the fallback named (SC-2's instrument).

### Item 3 — card rule: lease-only scope; unleased push gated (SC-4)

- **Deliverable:** the rule states the agent-owned authorization covers
  `--force-with-lease` only and that an unleased `git push --force` proceeds
  only under the floor's general gate.
- **RED:** read §3 for the lease-only scope statement and the unleased routing
  — absent; assertion fails.
- **GREEN:** append the lease-only scope sentence and the unleased routing
  clause.
- **Instrument:** read §3; assert both clauses present (SC-4's instrument).

### Item 4 — floor carve-out + whole-card discipline conversion (SC-3)

- **Deliverable:** `floor.md`'s destructive-action gate names the carve-out and
  its three-condition scope; the whole card's normative prose returns under
  [guidelines/ainglish-writing-discipline.md](guidelines/ainglish-writing-discipline.md)
  (whole-card-on-touch) with no rule's operative content altered.
- **RED:** read the floor's gate — no carve-out; assertion fails.
- **GREEN:** extend the third bullet of §Dispatched sub-agent scope with the
  carve-out clause ("exception: the agent's own feature branch, created by this
  agent for the work in hand, unmerged into the trunk, and held by no other
  party, whose per-issue squash at the PR boundary rewrites its own history with
  `git push --force-with-lease` — per the `git-workflow-pr` card"),
  then convert the card's normative prose per the discipline plain-English
  precision rules (actor binding, referent binding — constructs optional).
- **Instrument:** diff `floor.md` against pre-change state (git); assert the
  carve-out clause and three-condition scope present and every other rule's
  operative content unchanged (SC-3's instrument).

### Item 5 — tier-2 behavioral scenario for the carve-out branch (SC-5)

- **Deliverable:** `tests-v2/behaviors/2665-sc5-squash-lease-push-own-branch.sh`
  plus `fixtures/setup/2665-sc5-squash-lease-push-own-branch.sh` staging a
  fixture repo whose agent feature branch — created by the agent, unmerged,
  held by no other party — is already pushed to the fixture origin as the open
  PR's head and carries several unsquashed commits, driving the agent to the
  PR boundary pre-scoped per the re-scope-on-need rule: the fixture
  pre-supplies the completed pre-create facts (`tmp/checks/`), the scenario
  declares its goal condition (`pr-body.md` + required pattern), and the task
  shape keeps the run agent's generation inside its bounded budget.
  Artifact-only generator per the harness AGENTS.md; clean-room
  reviewer at evaluation time.
- **RED:** the scenario script absent — the harness's file listing fails.
- **GREEN:** author the script + fixture per §3 of `tests-v2/AGENTS.md`
  (cross-reference header, artifact-only, exit 0).
- **Instrument:** harness run produces `session.yaml` + `manifest.yaml`
  (exit 0), then clean-room evaluation PASS on the four PASS conditions.

### Item 6 — tier-2 behavioral scenario for the gated branch (SC-6)

- **Deliverable:** `tests-v2/behaviors/2665-sc6-squash-holds-anothers-branch.sh`
  plus `fixtures/setup/2665-sc6-squash-holds-anothers-branch.sh` staging a
  branch another party holds (other party created it / commits to it), driving
  the agent to the same PR boundary. Artifact-only; same form as Item 5.
- **RED:** the scenario script absent — file listing fails.
- **GREEN:** author the script + fixture.
- **Instrument:** harness run artifacts + clean-room evaluation PASS
  (no force-push of the rewrite; the developer's authorization sought instead).

### Item 7 — surface check (SC-7)

- **Deliverable:** unchanged (a check, not a file — the instrument runs
  against the working branch's accumulated diff after Items 1–6 and 8, and
  again as the PR-prep final check).
- **RED:** after Items 1–6 and 8, run the diff check on the working tree; it
  fails if any rule-bearing file beyond `skills/git-workflow-pr/SKILL.md`,
  `floor.md`, `tests-v2/AGENTS.md` (per the 2026-10-27 revision), and the
  `tests-v2/` scenario/fixture files appears in the diff, or if the
  wiki-operations / git-workflow-cleanup cards were touched under another
  surface's edit.
- **GREEN:** the executed diff itself asserts the criterion — no remediation
  beyond not making violations (an accidental stray edit is reverted; the
  re-run passes).
- **Instrument:** the change's diff — assert it touches no rule-bearing file
  beyond the three named rule surfaces plus the scenario/fixture files (which
  carry no rule-bearing content per the spec), and `git diff --stat` shows the
  wiki-operations and git-workflow-cleanup cards untouched.

### Item 8 — harness-spec re-scope-on-need rule (SC-8)

- **Deliverable:** `tests-v2/AGENTS.md` §3a (the pre-supplied-environment
  mandate's home) gains a "Re-scope on need" statement under the
  §3a corollaries: triggers (a run agent that never reaches its action
  sequence under the harness's bounded model constraints — exit at a
  bounded-generation turn or stall in re-planning), the re-scope surfaces
  (fixture, prompt, declared goal condition, staged boundary state), the
  record-in-scenario-file requirement, and blind retry /
  escalate-without-re-scope named as the replaced failure forms
  (.opencode#2665 run record as the provenance).
- **RED:** grep `tests-v2/AGENTS.md` for "re-scope on need"/"rescope" — absent.
- **GREEN:** add the rule to §3a as corollary 4.
- **Instrument:** read §3a; assert trigger, surfaces, record requirement, and
  both replaced failure forms named (SC-8's instrument).

## Dependencies

4 ← 1..3 (floor carve-out names the rule the card statement completes; run
1→3 first). 5 ← 1..3; 6 ← 1..3 (scenarios exercise the rule as written).
7 ← all (the surface check reads the whole diff; its exception set now
includes `tests-v2/AGENTS.md` per the 2026-10-27 revision). 8 ← 5, 6 (the
rule codifies the re-scope those scenarios' revision performed).
1→2→3 sequence in one file;
each GREEN extends the rule without rewriting prior clauses.

## Traceability

Item 1→SC-1, Item 2→SC-2, Item 3→SC-4, Item 4→SC-3, Item 5→SC-5,
Item 6→SC-6, Item 7→SC-7, Item 8→SC-8 (provenance: developer directive
2026-10-27). All eight SCs covered; no orphan item.

## Documentation Sources

- [skills/spec/references/validation-standards.md](../skills/spec/references/validation-standards.md)
- [skills/git-workflow-pr/SKILL.md](../skills/git-workflow-pr/SKILL.md) §3
- [floor.md](../floor.md) §Dispatched sub-agent scope
- attic reference form:
  [attic/skills/finishing-a-development-branch/tasks/checklist.md](../attic/skills/finishing-a-development-branch/tasks/checklist.md),
  [attic/skills/git-workflow-pr/tasks/pr-creation/squash-push.md](../attic/skills/git-workflow-pr/tasks/pr-creation/squash-push.md)
- [guidelines/ainglish-writing-discipline.md](../guidelines/ainglish-writing-discipline.md)
- [tests-v2/AGENTS.md](../tests-v2/AGENTS.md) §1, §3, §4

## Enforcement Gate

No mechanism (per spec Out of scope): the three conditions are agent judgment;
Items 5–6 are tier-2 verification surfaces only.

## Cost Frame

Items 1–4: two-file rule edits, minutes each. Item 5–6: harness scripts +
fixtures, the change's dominant cost (behavioral runtime bounded by the
harness's standard run). Item 7: one diff command.

## Edge Cases

- Branch pushed to origin but later merged into trunk before squash → Item 2's
  condition 2 fails → floor gate; SC-6 covers the gated form, not this exact
  composition — the card's fallback clause (Item 2) covers it textually.
- Remote ref moved between last fetch and the lease push → `--force-with-lease`
  fails by its own semantics (spec Impact bounds this).
- Fixture branch naming collisions with harness defaults → both fixtures use
  the `2665-` prefix names above.

## Not Included

Everything in the spec's Out of scope section: wiki-operations and
git-workflow-cleanup rules, attic edits, general published-branch rewrite
permission, and any enforcement mechanism. The 2026-10-27 revision adds
`tests-v2/AGENTS.md` as the third rule surface (SC-8) and widens SC-7's
exception set accordingly.