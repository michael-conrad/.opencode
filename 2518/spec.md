# [BUG] Verify-bar invariance + pipeline continuation on terminal authorization

**Repo**: michael-conrad/.opencode · **Scope**: `skills/verify/SKILL.md`, `skills/work/SKILL.md`, `floor.md` · **Remote**: https://github.com/michael-conrad/.opencode/issues/2518 · stacked fix for https://github.com/michael-conrad/.opencode/issues/2525

## Problem Statement

Two deck-regression defects from the same session chain (post-rewrite, `.opencode#2490` provenance), stacked into one PR per the developer's directive:

1. **#2518 — verdict-shopping via dispatch-time bar authoring.** In the #1379 spec-audit session (2026-10-05), after a correct FAIL→revise→PASS cycle, the agent accepted a threshold directive ("any note or comment is an audit fail") and dispatched a new re-audit whose prompt *authored the pass condition at dispatch time*. A bar re-authored per-dispatch can manufacture any verdict — including a PASS — and the loop machinery (revision + re-audit) then launders the manufactured verdict into a clean record. The churn rule was also inverted: repurposed to suppress recorded observations instead of stopping noise-chasing. The `verify` card states the loop and the churn rule but nothing forbids re-authoring the bar.

2. **#2525 — terminal authorization halts instead of running the pipeline (regression of #2505/#2502).** Session 2026-10-06 (`opencode-config` repo): the developer issued `.opencode#2518 approved for PR` at stage 0. The agent loaded only `git-workflow-pr`, observed no prior work existed, and halted with a clarification request instead of routing through `work` and running spec → plan → implement → PR. The floor vocabulary already states intermediate stages are implied; the missing piece is the `work`-card statement that missing upstream artifacts trigger the pipeline, never a clarification about the authorization itself.

## Success Criteria

- **SC-1 — Criteria-invariance clause (structural).** `skills/verify/SKILL.md` states: every audit and re-audit runs on the same declared criteria set; re-audit prompts restate it verbatim; the pass condition is never re-authored at dispatch time; post-verdict notes and directives feed the loop's revision step (fix the artifact), not a new bar; changing the bar itself is deck governance, never a per-dispatch prompt edit. Instrument: grep/read the card; the clause is present and states each element.
- **SC-2 — Halt-and-clarify trigger (behavioral).** A directive that redefines the audit bar at dispatch time is a halt-and-clarify trigger for the agent, not a re-dispatch trigger. Instrument: `opencode run` scenario — mid-stream bar-redefinition directive must produce a halt-and-clarify response, never a re-audit dispatch on the re-authored bar.
- **SC-3 — Pipeline continuation (behavioral).** A terminal-stage authorization (`approved for pr`, `approved for implementation`, etc.) on a ticket with missing upstream artifacts runs the pipeline from the earliest missing stage under the granted authorization; `git-workflow-pr`'s readiness gate (verify PASS) is reached by running the pipeline, not halted at. Halt only on genuine ambiguity about the authorization's meaning, never on missing prior artifacts. Instrument: `opencode run` scenario — stage-0 ticket + `approved for pr` must produce pipeline work (branch creation / spec drafting), never a clarification request about the authorization.
- **SC-4 — Floor discipline (structural).** Any floor edit is a one-line semantic anchor; card text is canonical; no text shared verbatim between floor and card; no repo names or absolute paths in deck edits. Instrument: diff of floor.md on this branch (≤ 1 semantic line per fix); grep for verbatim duplication.
- **SC-5 — Scope discipline (structural).** The edit touches only `skills/verify/SKILL.md`, `skills/work/SKILL.md`, and `floor.md`; provenance lines updated to cite the driving issues. Instrument: diff of this branch's commits.

## Requirements

1. **REQ-1 (#2518)**: Add the criteria-invariance clause to the `verify` card's audit-loop content — bar invariant across iterations; notes feed revision, not a new bar; bar changes are deck governance; bar-redefinition directives are halt-and-clarify triggers.
2. **REQ-2 (#2525)**: Add to the `work` card the continuation rule: a terminal-stage authorization with missing upstream artifacts starts the pipeline at the earliest missing stage; downstream card gates (e.g. PR readiness) are satisfied by running the pipeline, not reasons to halt.
3. **REQ-3**: Floor receives at most one-line anchors (citing the cards), never duplicated card text — per the #2516 floor-fattening ruling.

## Non-Goals

- No change to the loop shape itself: audit → (revision + re-audit)* until PASS is by design; re-auditing after PASS is correct.
- No change to `git-workflow-pr` content (its readiness gate is correct; the defect is that `work` wasn't consulted before it).
- No mechanical/scripted enforcement — these are intent-decidable behaviors; card text is the mechanism.

## Admission gate (deck governance)

- **Observed failures**: #1379 audit session 2026-10-05 (#2518); session 2026-10-06 in `opencode-config` (#2525) + developer correction.
- **Consumers**: agents dispatching re-audits (`verify`); agents receiving terminal-stage authorizations (`work`).
- **Mechanism**: card text loaded at the failure point (routed from `routing.md`).
- **Predicate classification**: intent-decidable (bar authorship judgment; stage-continuation judgment) — no scripted enforcement proposed.
- **Root-agnostic**: yes — no repo names or absolute paths in card text.
- **What it replaces**: `verify` gains a missing invariant; `work` gains the continuation rule the #2502/#2505 floor fix implied but never carried into the card; floor gains at most one anchor line each. Net wording changes, no new artifacts.

## Traceability

| Requirement | SCs | Source |
|---|---|---|
| REQ-1 | SC-1, SC-2, SC-4 | #2518 issue body (suggested fix) + developer correction: bar can't be re-authored to manufacture a PASS |
| REQ-2 | SC-3, SC-4 | #2525 issue body (where-to-fix candidates) |
| REQ-3 | SC-4 | #2516 ruling; SC-PD of #2519 |
| — | SC-5 | Deck card standards |

> **Full spec and artifacts**: `.opencode/.issues/2518/` — this file is the authoritative spec. Stacked issue: `.opencode/.issues/2525/`.
