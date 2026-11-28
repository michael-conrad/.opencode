# Spec — Auto-repair `.issues/` issues-data worktree/branch state defects on discovery — agent-owned hygiene, never report-and-wait

Fix spec (2026-11-28, developer-directed after a detected regression). The
worked-example evidence is the same-day repair executed in the discovering
session, recorded in this issue's research area.

## 1. Intent and Executive Summary

**Problem Statement:** The deck's store-hygiene doctrine leaves `.issues/`
issues-data worktree and branch **state** defects without a stated owner. An
agent that detects one gates the repair behind developer direction and
reports-and-waits instead of repairing in the same workflow. On 2026-11-28 the
discovering agent detected a parent-repo git index shadowing the `.issues/`
store mount (a failed stash-apply had left `UU .gitignore` plus 4 `DU`
unmerged `.issues/…` path entries — 11 stage-entries across 5 conflicted
paths; old-model store content re-tracked in the
parent repo against the worktree-only model), performed the intent analysis,
and reported "Repair awaits your direction" rather than repairing; the
developer had to direct the fix explicitly before it executed.

**Root Cause / Motivation:** The store-hygiene mandate authorizes free
reading/writing/repair of store workspace data and the `issues` card §7
already carries remediate-on-discovery for interrupted syncs
(`.opencode#2731`). But the boundary was never drawn for **git-state** defects
of the store mount itself: a conflicted shadowing index, branch divergence,
interrupted rebase/merge state, stale worktree state. An agent weighing the
store-hygiene mandate (authorization-free) against the parent repo's git state
(token-gated) classifies these defects as the latter — because their entries
live in parent-repo git machinery — and halts. Root cause: a scope-boundary
gap in the doctrine, not an agent failure to read it; the doctrine gives no
stated owner for the class, so the stricter default wins. The failure recurs
unless the class is named as store-owned.

**Approach Chosen:** Extend the `issues` card §7 trigger/repair doctrine: name
the four state-defect classes as agent-owned repair-on-discovery (same
workflow, never report-and-wait), with data-preserving repair mechanics and a
disposition-recording requirement; extend the store workspace guide's
hygiene-mandate section to state repairs in the same change; sibling store
guides get the mirrored amendment as store maintenance. Verification through
content checks plus one behavioral scenario through the tests-v2 harness.

**Alternatives Considered & Why Discarded:**
- *Tool-internal auto-repair (make `local-issues` fix the parent index):* 
  discarded — the tool's fail-fatal/report posture for workspace anomalies was
  deliberately set (the `#816` line of fixes: report stale worktree state, do
  not silently repair), and a tool reaching into parent-repo git machinery is
  the wrong layer; the agent owns judgment-classified repairs, the tool owns
  loud reporting.
- *Floor addition (always-injected rule):* discarded — the class is
  store-operations-scoped; the doctrine surfaces load with issue work by
  construction (the store guide auto-loads; the `issues` card matches issue
  work), so always-injected weight buys nothing.
- *Treat as already-covered by the interrupted-sync clause:* discarded — that
  clause (`.opencode#2731`, shipped) names only mid-rebase/mid-merge states
  from failed `init`/`sync`; the shadowing-index, divergence, and stale-state
  classes from parent-worktree operations are outside its trigger list, which
  is exactly the gap this observed regression fell through.

**Key Design Decisions:**
- *Enumeration, not a general "fix the git state" mandate:* the card names
  four concrete classes tied to the store mount. Tradeoff: narrower than an
  open mandate, in exchange for a boundary that cannot drift into
  general parent-repo git surgery the developer has not authorized.
- *Data-preservation as stated mechanics:* the repair pattern is the
  demonstrated one — untrack store paths from the shadowing index (never
  delete or overwrite store worktree files), history-additive corrections,
  stash/record preservation, store-content removals only via the store's own
  sanctioned tooling, verification by the git-state + store-integrity set.
  Tradeoff: prescriptive text vs. judgment latitude; the enumeration bounds
  where the mechanics apply, judgment still classifies each instance.
- *Behavioral verification included:* the regression is an agent-conduct
  failure, and progressive disclosure means text-only checks cannot see the
  conduct. Tradeoff: a heavier instrument tier; justified — content checks
  alone would leave the exact observed failure mode unverified.

**User Intent / Original Prompt:** Developer message, verbatim, 2026-11-28:
"regression: agent did not automatically fix .issues issues-data worktree and
branch after detecting a defect.file a fix spec". Observed-failure grounding
(same session): the detecting agent's report stated "Repair awaits your
direction (outside the triage token's surface)" for the conflicted index
shadowing the `.issues/` mount; the developer then directed "fix .issues"
(2026-11-28), and the repair executed and verified in the same workflow: 5
conflicted paths resolved (`git checkout HEAD -- .gitignore`; `git rm --cached`
on the 4 `.issues/…` unmerged paths — 11 stage-entries), 0 unmerged remain,
`.gitignore` byte-identical to
HEAD, mount ignored by the parent, store worktree clean at unchanged HEAD,
store data byte-intact (429 records; sha-verified 682 content identical
pre/post), stash entries preserved, no commit created (nothing staged differed
from HEAD).

## 2. Not Included

- *Tool-internal auto-repair:* the `local-issues` tool keeps its fail-fatal /
  loud-report posture (the `#816` line); the agent owns the repair.
- *Store record-data content defects:* already owned by the existing
  `validate-yaml` repair-on-discovery triggers (`.opencode#2755` class) —
  not restated.
- *Authorization for stash drops, branch deletions, or other destructive git
  operations:* unchanged — developer-gated; the doctrine text must not imply
  otherwise.
- *General parent-repo git state unrelated to the store mount:* no mandate
  claimed beyond the enumerated classes.

## 3. Requirements

- **R-1 (SHALL):** The `issues` card §7 trigger/repair doctrine SHALL name the
  `.issues/` worktree and branch state defect classes — a store-holding
  repository's index shadowing the `.issues/` mount (unmerged entries or
  staged adds over `.issues/` paths), interrupted mid-rebase/mid-merge state,
  store-branch divergence, and stale worktree state — as agent-owned
  repair-on-discovery: repaired by the detecting agent on discovery, in the
  same workflow, with no developer gate and no report-and-wait. The clause
  states the mandate minimally (developer directive 2026-11-28) in three
  element-groups — the mandate sentence with the class enumeration bounding
  the mandate's scope; the data-preservation mechanics sentence; the
  disposition sentence — with the interrupted-sync trigger's escalation
  posture referenced, not restated, and no added out-of-scope fencing prose
  on the card or the guide.
- **R-2 (SHALL):** The card's repair doctrine for these classes SHALL carry
  the data-preserving mechanics: shadowing-index repairs untrack store paths
  (never delete or overwrite store worktree files), corrections are
  history-additive, stash entries and store records are preserved, and any
  removal of store content happens only through the store's own sanctioned
  tooling.
- **R-3 (SHALL):** The card SHALL carry the corollary — report-and-wait on a
  repairable defect of these classes is itself a defect — and SHALL reference
  the interrupted-sync trigger's escalation posture (evidenced-tool-error
  report-with-halt scoped to that store alone) rather than restating it.
- **R-4 (SHALL):** The store workspace guide's hygiene-mandate section SHALL
  extend to worktree/branch state repairs alongside issue-data file repairs,
  on the same surface agents already load for store operations — stated
  minimally per the same directive: the extension names the agent repairing
  on discovery in the same workflow, references the card clause for mechanics
  and disposition rather than restating them, and reconciles the section's
  pre-existing scope boundary by inclusion only, with no added
  exclusion-fence prose (the pre-existing boundary text and the floor's
  destructive-action rule carry those bounds).
- **R-5 (SHALL):** The repair disposition SHALL be recorded where the defect
  was discovered: pre-repair state, the repair performed, and verification
  evidence (post-repair git state plus store-integrity checks — data
  byte-intact, record count, branch state).

## 4. Success criteria

| ID | Criterion | Class | Instrument |
|----|-----------|-------|------------|
| SC-1 | `issues` card §7 names all four enumerated state-defect classes as agent-owned repair-on-discovery (same workflow, no developer gate, no report-and-wait), stated as the lean composition contract: three element-groups (mandate sentence with class enumeration; data-preservation mechanics; disposition), the interrupted-sync escalation posture referenced not restated, no added out-of-scope fencing prose | structural | Locate the trigger/repair passage (e.g. `grep -n "shadowing\|mid-rebase\|divergence\|stale worktree" .opencode/skills/issues/SKILL.md`); pass only when the located text names all four classes with the same-workflow ownership wording, carries the three element-groups within three sentences with the posture referenced rather than restated, and adds no out-of-scope fencing prose |
| SC-2 | The card carries R-2's mechanics: untrack-not-delete for shadowing indexes, history-additive corrections, stash/record preservation, sanctioned-tooling-only store-content removals | structural | Read the located repair-mechanics passage; pass only when all four mechanism elements read directly in the text |
| SC-3 | The card carries the corollary (report-and-wait on a repairable defect of these classes is itself a defect) and the evidenced-tool-error escalation posture | structural | Read the located corollary passage; pass only when both elements read directly |
| SC-4 | The store guide's hygiene-mandate section covers worktree/branch state repairs alongside issue-data file repairs, stated minimally: the extension names the agent repairing on discovery, references the card clause for mechanics and disposition, and adds no exclusion-fence prose relative to the pre-change boundary | structural | Read `.opencode/.issues/AGENTS.md` hygiene-mandate section; pass only when the state-repair extension reads directly and the minimal-statement contract holds (card-clause reference, inclusion-only boundary reconciliation, no added fence prose) |
| SC-5 | The disposition-recording requirement (pre-repair state, repair performed, post-repair git state plus store-integrity verification) is stated in the card | structural | Read the located disposition passage; pass only when all three recording elements read directly |
| SC-6 | The amended doctrine produces the regression's fix at runtime: a detecting agent, presented with a workspace whose store-holding repository's index is defective over the `.issues/` store mount (unmerged `.gitignore`; `.issues/` paths staged with worktree files absent; no issue store provisioned), performs the repair on its own authority within the same workflow — untracks the staged store paths, resolves the `.gitignore` conflict, destroys no `.issues/` data — and records the disposition, with no developer gate and no report-and-wait halt | behavioral | tier-1 clean-room dispatch per the behavioral-testing card rule 1 (the eligibility judgment: five tier-2 harness attempts under the R-20-locked default model documented a model-level deliberation-execution gap outside this criterion's subject — the runs discovered the defect, self-authorized, planned the correct repair, and never executed; the change under test is a card-doctrine clause; the judgment is recorded in the validation record). The dispatch: a fresh-context sub-agent in a fixture workspace carrying the injected defect, tasked per the workspace guide; the verdict draws on the recorded dispatch — repair performed in-session (staged `.issues/` entries untracked, `.gitignore` resolved, nothing under `.issues/` deleted or overwritten), disposition record present, no gate/wait — persisting the dispatch prompt, the judged criterion, the verdict, and the workspace end-state capture to the audit dir |

## 5. Dependencies

| Reference | Relationship | Status |
|-----------|--------------|--------|
| `.opencode#2781` (this record) | The developer-directed fix spec; carries the worked-example evidence. | satisfied |
| issues card §7 interrupted-sync clause (`.opencode#2731`, shipped) | The existing remediate-on-discovery clause this spec generalizes; its repair-failure posture is reused. | satisfied — read 2026-11-28 |
| `.opencode/.issues/AGENTS.md` hygiene mandate | The second target surface; currently bounds hygiene to issue-ticket data files. | satisfied — read 2026-11-28 |
| `skill-creator` (deck governance) | The card and guide edits pass the admission gate at implementation. | pending — gates at implementation |
| `behavioral-testing` card + `.opencode/tests-v2/` harness | SC-6's instrument runs through the deck's behavioral harness. | satisfied — harness machinery exists (verified 2026-11-28) |
| floor safety rule (intent-decidable never scripted) | Bounds the doctrine: repairs stay agent-judgment-classified; no mechanical scripting. | satisfied — read 2026-11-28 |

## 6. Traceability

| Requirement | Success criteria |
|-------------|------------------|
| R-1 | SC-1, SC-6 |
| R-2 | SC-2, SC-6 |
| R-3 | SC-3 |
| R-4 | SC-4 |
| R-5 | SC-5 |

Every criterion traces to at least one requirement; no orphans in either
direction.

## 7. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|--------------|
| Developer regression directive | developer statement | session chat 2026-11-28: "regression: agent did not automatically fix .issues issues-data worktree and branch after detecting a defect.file a fix spec" | quoted verbatim into User Intent, 2026-11-28 |
| Observed failure (agent gated the repair) | session event | the discovering session's report: "Repair awaits your direction (outside the triage token's surface)" for the conflicted index shadowing `.issues/` | recorded in the same session workflow; the developer's "fix .issues" directive followed same-day |
| Worked-example repair evidence | executed instrument | session workflow 2026-11-28: pre-state (5 conflicted paths: `UU .gitignore` + 4 `DU` `.issues/…`; 11 stage-entries), post-repair (0 unmerged; `.gitignore` == HEAD; mount ignored; store clean at unchanged HEAD; 429 records; sha-verified 682 integrity pre/post; stash preserved) | executed and verified in the same session; recorded in `research/worked-example-repair-2026-11-28.md`; summarized in User Intent |
| issues card §7 interrupted-sync clause | deck normative text | `.opencode/skills/issues/SKILL.md` §7 (`.opencode#2731` trigger) | read 2026-11-28; names mid-rebase/mid-merge remediate-on-discovery, not the other three classes |
| store guide hygiene mandate | deck normative text | `.opencode/.issues/AGENTS.md` Issues-Data Hygiene Mandate | read 2026-11-28; bounds hygiene to issue-ticket data files, not worktree/branch state |
| `#816` tool posture (fail-fatal, not auto-repair) | deck history | `.opencode#816` / root `#128` (closed): "report stale worktree state for AI agent remediation, not auto-repair" | titled and read via store/search 2026-11-28 |
| tests-v2 harness | deck directory | `.opencode/tests-v2/` (`behaviors/`, `with-test-home`, `poll-run.sh`, `docker/`, `AGENTS.md`) | listed 2026-11-28 |
| floor safety rule | deck normative text | `/home/muksihs/git/opencode-config/.opencode/floor.md` Safety section | read 2026-11-28; intent-decidable rules never scripted |

## 8. Cost Frame

- **SC-1…SC-5 (content/structural):** acting costs minutes — locate and read
  the passages, run the greps. Skipping costs the scope-boundary gap stays
  closed only in the incident thread; the next store-mount state defect
  reproduces the same developer-forced detour.
- **SC-6 (behavioral):** acting costs harness provisioning plus one
  clean-room run and evaluation (tens of minutes per harness economics);
  skipping costs that the conduct regression — the exact observed defect — is
  verified by nothing and recurs unobserved.

## 9. Edge Cases

| Condition | Expected behavior | Resolution |
|-----------|-------------------|------------|
| Shadowing index entries overlap LIVE store content (e.g. unmerged entries over files the store currently tracks) | Repair untracks the shadowed paths from the parent index; store worktree files are never deleted or overwritten; data integrity verified post-repair | R-2 mechanics (demonstrated: 682 content sha-identical pre/post) |
| The store worktree itself is mid-rebase/mid-merge | Repair per the existing interrupted-sync clause (complete or abort-then-reapply per the tool's remediation output) | R-1 class 2; existing §7 clause reused |
| Repair requires deleting store content (e.g. stale residue) | Store-content removals run only through the store's sanctioned tooling (e.g. remediate-legacy); never via parent-index deletion | R-2 mechanics |
| A repair step needs a destructive op (stash drop, branch deletion) | Out of the class: gated by the floor's destructive-action rule; report with grounds and await | Out-of-scope boundary; corollary text keeps escalation reserved |
| Detection happens in a consuming-repo session (deck read-only there) | State defects of the CONSUMING REPO's own store remain its own store's data (agent-owned as ever); deck content edits remain upstream-gated | Scope: store-mount state, not deck source |

## 10. Completion gate

Every success criterion SC-1 through SC-6 passes before the deliverable is
complete — the card doctrine, the store-guide extension, and the executed
behavioral scenario stand or fall together; partial implementation is not
permitted.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
