> Full spec and plan artifacts: https://github.com/michael-conrad/.opencode/tree/issues-data/.issues/2706/

# SPEC-FIX: Registration-on-demand for remote-first issues — audit and pipeline stages get a defined subject

## Intent and Executive Summary

- **Problem Statement:** An issue filed remote-first (GitHub API, no local `{N}/` record — the protocol `#2447`'s remediation established and issue #2704's filing applied on 2026-11-02) cannot enter the pipeline's later stages. The `verify` card's artifact-presence gate (§10) requires the audited artifact "present at a verified local path" and routes only *local absence of an existing artifact* through mirror-repair; the store guide makes `.issues/{N}/` the primary spec store and forbids treating the remote body as authoritative; and no card mandates registering a local record when work on such an issue begins. Observed live on 2026-11-02: `spec audit .opencode#2704` dead-ended in an agent halt after exhaustive verification that no spec artifact exists on any surface (SHA-verified store currency `6ddce945` == origin `refs/heads/issues-data`; tracker body, comments, sub-issues, cross-references, and sibling issues all checked) — a halt that reads from the developer's seat as a fabricated block. Filed as #2706.
- **Root Cause / Motivation:** Two deck rules from different eras compose into a dead end: the 2026-09-19 conditional GitHub-API-only filing protocol (#2447) leaves remote-first issues with no local record, while the conversion-era verify gate (#2597) presumes a local artifact and defines no outcome for "artifact never produced". The composition leaves the audit — and by extension any pipeline stage that needs a store target — structurally unreachable for the decided filing protocol. This is the same conversion-era composition-defect class #2704 records for the triage→spec path, observed one stage later.
- **Approach Chosen:** Extend the `issues` card's mirror-repair scope with a **registration-on-demand** mandate: pipeline work targeting an issue whose local record is absent begins by registering the record at the remote-assigned number. Extend the `verify` card's artifact-presence gate to register the record first when it is absent, and to resolve a still-absent artifact to a **defined no-artifact outcome** — the report names the missing artifact and the stage that produces it; no verdict issues against a nonexistent artifact, and the outcome is a defined result of the audit, never an ad-hoc halt.
- **Alternatives Considered & Why Discarded:** (1) Route the audit against the API-held issue body — discarded: the store guide forbids treating the remote body as authoritative, and a bug-report body is not a spec document; auditing it against the spec standards would audit the wrong artifact against the right bar. (2) Require a pre-existing spec and fail the dispatch with an error — discarded as the sole mechanism: it formalizes the dead end without giving remote-first issues a route into the pipeline; retained *inside* the chosen approach as the defined no-artifact outcome after registration. (3) Change the store guide's authority rule — discarded: out of scope for a deck PR (store-guide content lives on the `issues-data` branch) and unnecessary once registration gives the store the authoritative artifact.
- **Key Design Decisions:** The fix is card-text only (two skill cards); no `floor.md` growth — the change is card-scoped and needs no before-dispatch visibility. The trigger is fact-decidable (record/folder existence, checkable via the store tooling). The registration mandate composes with the remote-body-format reference, which already anticipates late-arriving folders ("Issues filed first gain the mandate at reconciliation, when their folder comes to exist") — registration triggers that reconciliation on the next remote-body edit, not retroactively.
- **User Intent / Original Prompt:** Developer dispatch `spec audit .opencode#2704` (2026-11-02), which dead-ended; developer reaction "what is this fabricated block? file a regression bug report" (#2706, filed 2026-11-02); then `approved for pr` carrying the fix through the pipeline to the PR boundary.

## Deck-Governance Admission (skill-creator gate)

| Gate item | This change |
|---|---|
| Observed failure | 2026-11-02 `spec audit .opencode#2704` dead-end; dated evidence in #2706 (SHA-verified store currency, tracker enumeration) |
| Consumer | Agents dispatching audits or pipeline work (spec creation, plan, implementation) on remote-first-filed issues |
| Mechanism / trigger | Fact-decidable: local record absence at work start, checkable via the store tooling |
| Predicate classification | Fact-decidable (record existence) — no intent-decidable predicate is scripted |
| Domain match | Not an adopted external protocol |
| Root-agnostic | Card text names no repository, owner, or absolute path; per-root facts arrive via session-init |
| What it replaces | Retires the undefined dead-end outcome in `verify` §10 (replaced by the defined no-artifact outcome); `issues` §7's registration mandate makes its existing create-on-discovery operation explicit for pipeline work — a small, justified clarification |
| Always-loaded discipline | Card-level only; nothing enters `floor.md` or any always-injected surface |

## Not Included

- **The triage→spec conversion mandate** (#2704's subject) — restoring the retired `analyze-and-spec` path is #2704's scope; this fix gives remote-first issues a store target so that work *can* proceed, but does not restore any triage-era mandate.
- **The `.opencode/.issues/AGENTS.md` store guide** — its content lives on the `issues-data` branch, not the deck branch this PR changes; no store-guide line contradicts this fix once registration supplies the authoritative artifact.
- **Retroactive remote-body reconciliation of #2703–#2706's bodies** — the format mandate binds at reconciliation on the next remote-body edit per the remote-body-format trigger rule; bulk retroactive edits are separate store hygiene.
- **Push-access or tracker-permission remediation** — access-control facts, not deck defects.

## Success Criteria

| ID | Criterion | Class | Verification instrument |
|----|-----------|-------|------------------------|
| SC-1 | `skills/issues/SKILL.md` states the registration-on-demand mandate: pipeline work targeting an issue — spec creation, plan, implementation, or an audit dispatch — whose local record is absent begins by registering the record at the remote-assigned number via the store tool's create command before any other store work on that issue. | structural | grep asserts the mandate text (trigger: record absence at work start; action: register via create with the remote-assigned number) is present; clean-room read confirms it is unambiguous. |
| SC-2 | `skills/verify/SKILL.md` §10 states that when the audited issue has no local record, the auditor registers one per the `issues` card before the presence check, and that an audited artifact still absent after registration resolves to a defined no-artifact outcome — the report names the missing artifact and its producing stage; no verdict issues against a nonexistent artifact; the outcome is a defined result, never an ad-hoc halt. | structural | grep asserts both clauses; clean-room read confirms the outcome is deterministic (named artifact + producing stage) and the "never an ad-hoc halt" sentence is present. |
| SC-3 | The two rules compose: a clean-room reader walking the scenario "audit dispatched on a remote-first issue with no spec anywhere" reaches a defined outcome (register record → presence check → no-artifact outcome naming `spec.md` and the spec stage) without an undefined halt or an invented artifact. | semantic | Clean-room sub-agent walks the scenario from the two cards' text alone and reports the reached outcome; judged unambiguous and complete. |
| SC-4 | Every agent-facing cross-reference added or touched by this change resolves (`Read [Text](path)` canonical form; no dead links introduced). | structural | `./.opencode/tools/reference-integrity` run on the deck passes with the change applied. |
| SC-5 | The change adds no root-repo name, owner, or absolute path to any card text (root-agnostic discipline holds). | structural | grep of the diff for `.opencode`-specific and absolute-path additions beyond pre-existing text returns nothing new. |

## Requirements

- R-1. When pipeline work targeting an issue begins and the issue's local record is absent, the agent SHALL register the record at the remote-assigned number via the store tooling before any other store work on that issue.
- R-2. When an audit's audited issue has no local record, the auditor SHALL register the record before the artifact-presence check.
- R-3. When the audited artifact does not exist after registration, the audit SHALL resolve to a defined no-artifact outcome that names the missing artifact and the stage that produces it; no verdict SHALL issue against a nonexistent artifact; the outcome SHALL be a defined result of the audit, never an ad-hoc halt.
- R-4. The added card text SHALL be root-agnostic (no repository names, owners, or absolute paths).

## Items

### Item 1 (SC-1): Registration-on-demand mandate in the `issues` card §7

- RED: grep of `skills/issues/SKILL.md` for the registration-on-demand trigger phrase ("pipeline work ... record is absent ... register") — absent before the change.
- GREEN: Extend §7 (mirror-repair) with the registration-on-demand sentence per R-1, placed beside the existing repair-on-discovery rule it operationalizes.
- verify: grep passes; clean-room read confirms unambiguity (SC-1).
- commit: one commit on the deck feature branch scoped to `skills/issues/SKILL.md`.

### Item 2 (SC-2): Artifact-presence gate extension in the `verify` card §10

- RED: grep of `skills/verify/SKILL.md` §10 for the registration-first clause and the defined no-artifact outcome — absent before the change.
- GREEN: Extend §10 with the registration-first sentence and the defined no-artifact outcome per R-2/R-3, placed after the existing mirror-repair sentence.
- verify: grep passes; clean-room read confirms determinism (SC-2).
- commit: one commit on the deck feature branch scoped to `skills/verify/SKILL.md`.

### Item 3 (SC-3): Composition walkthrough

- RED: clean-room sub-agent, given only the two cards' current text, cannot reach a defined outcome for the remote-first audit scenario — reports the dead end (SC-3) — fails before the change.
- GREEN: With Items 1–2 applied, the same walkthrough reaches the defined outcome (SC-3).
- verify: fresh clean-room sub-agent walkthrough; judged unambiguous and complete.
- commit: no additional commit (verification of Items 1–2's text).

### Item 4 (SC-4 + SC-5): Reference integrity and root-agnostic sweep

- RED: reference-integrity and root-agnostic greps run on the changed files — new links absent before the change (SC-4 trivially pending); SC-5 greps pass vacuously before the change and become the regression guard.
- GREEN: Apply the edits with canonical `Read [Text](path)` cross-references (the `verify` §10 sentence references the `issues` card's rule in canonical form); run `./.opencode/tools/reference-integrity` and the SC-5 greps.
- verify: both instruments pass with the change applied (SC-4, SC-5).
- commit: rides with Items 1–2's commits (no separate commit; the checks gate them).

## Dependencies

- **Reference:** `skills/verify/SKILL.md` §10 — Relationship: the gate this change extends; Status: present on trunk.
- **Reference:** `skills/issues/SKILL.md` §7 (mirror-repair) — Relationship: the rule this change operationalizes; Status: present on trunk.
- **Reference:** `skills/spec/references/remote-body-format.md` trigger rule — Relationship: composes with registration (late-arriving folders gain the mandate at reconciliation); Status: present on trunk, unchanged.
- **Reference:** #2447's conditional GitHub-API-only protocol — Relationship: the filing protocol whose composition with the gate dead-ends; Status: unchanged by this fix (the fix makes the protocol composable, it does not retire the protocol).
- **Reference:** #2704 — Relationship: sibling conversion-era composition defect (triage→spec path); Status: open, separate scope.

## Traceability

| Requirement | SC | Item | Source |
|---|---|---|---|
| R-1 | SC-1 | Item 1 | #2706 Observed/Regression ground |
| R-2, R-3 | SC-2, SC-3 | Item 2, Item 3 | #2706 Expected behavior (candidate shapes a+c composed) |
| R-4 | SC-5 | Item 4 | skill-creator root-agnostic gate |

## Documentation Sources

- `skills/verify/SKILL.md` §10 (current text, as of 2026-11-02 trunk)
- `skills/issues/SKILL.md` §1, §2, §7 (current text)
- `.opencode/.issues/AGENTS.md` — store-authoritative rule and workspace guide
- `skills/spec/references/remote-body-format.md` — trigger rule
- `skills/skill-creator/SKILL.md` — admission gate applied above

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
