# Plan — .opencode#2751 (gb-cli card: GitBucket label routes + cross-class attempt-first)

## 1. Goal

Deliver the `.opencode#2751` spec (`.opencode/.issues/2751/spec.md`): a card-only correction to `skills/gb-cli/SKILL.md` in the deck repository (michael-conrad/.opencode) — adding the evidenced working GitBucket issue-label REST routes to the known-gaps passage (R-1) and extending the attempt-first rule to name cross-endpoint-class capability conclusions (R-2), while preserving the enumerated existing statements byte-for-byte (R-3). The change is a single-file card edit plus its verification instruments; it ships through the deck's governance PR process.

## 2. Execution surface

Working repo: the deck repository (michael-conrad/.opencode, checked out as a submodule of the consuming workspace). Branch: `feature/2751-gbcli-label-routes`, created from verified trunk tip `f486caae1` (verified at-tip 2026-11-19). Single file touched: `skills/gb-cli/SKILL.md`. The issue store (`.issues/` worktree, `issues-data` orphan branch) holds the spec and this plan; it is not part of the deliverable PR.

## 3. Items

### Item 1 — Working-routes statement in the known-gaps passage (SC-1)

**Deliverable:** A prose statement inside the Platform-awareness known-gaps passage of `skills/gb-cli/SKILL.md` carrying exactly the four content elements the SC enumerates: (a) the evidenced working label endpoints — `PUT repos/{owner}/{repo}/issues/{n}/labels` for label replacement via the `--input` JSON payload pattern and `GET repos/{owner}/{repo}/issues/{n}/labels` for label listing, both through the `gb api` passthrough; (b) the distinction against the unavailable `PATCH .../issues/{n}` plain-issue state mutation; (c) sibling label-endpoint methods (e.g. `POST .../labels`) framed only as attempt-first subjects, never as asserted-working routes; (d) the evidence date 2026-11-18 (NewSRX-Tech-LLC/CrossrefAbstracts#78).

**RED:** With the card at its current state, a content check over the known-gaps passage finds no statement naming the label endpoints as evidenced-working — the check fails on element (a) and no date is present.

**GREEN:** Insert the statement as an addition to rule 4's known-gaps prose, after the `gb pr edit` sentence group and before the merge-gate sentences, worded as prose (the spec's design decision: the required "row" binds content, not layout, and no element of the surrounding text is altered).

**Tier marks:** No authored test; this item's verification class is a fact check over a deck prose surface (structural).

**Instrument:** Read `skills/gb-cli/SKILL.md`; locate the added statement inside the known-gaps passage; verify one-by-one that the four content elements are present and that no endpoint outside `PUT`/`GET` against the labels route is stated as working.

### Item 2 — Cross-endpoint-class sentence in the attempt-first rule (SC-2)

**Deliverable:** A sentence appended to rule 7 (Attempt-first) stating that a capability conclusion about an endpoint class different from the one that failed (or whose web fallback reported failure) requires an attempted `gb api` passthrough call in the session's own shell before any "unsupported"/"cannot edit" report — naming the one-unavailable-endpoint-to-sibling-endpoints generalization as the observed fabrication shape.

**RED:** With the card at its current state (post Item 1), a content check over the attempt-first rule finds no sentence naming cross-endpoint-class probes — the check fails.

**GREEN:** Append the sentence at the end of rule 7, after the existing parenthetical precedent citation, keeping the rule's existing sentences untouched byte-for-byte.

**Tier marks:** No authored test; fact check over deck prose (structural), with the SC-4 byte-exact guard as the preservation instrument.

**Instrument:** Read `skills/gb-cli/SKILL.md`; locate the appended sentence in rule 7; confirm it names the different-endpoint-class probe requirement and the pre-report attempt duty.

### Item 3 — Preservation guard over the enumerated passages (SC-4, R-3)

**Deliverable:** Executed byte-exact diff check over `skills/gb-cli/SKILL.md` scoped to the four passage groups R-3 preserves: (1) the plain-issue state-mutation gap sentence (`PATCH .../issues/{n}` → 404); (2) the PR-state mutation guidance (`gb pr close` 404s; `gb pr edit <N> --state closed --web` as the agent-runnable route; plain `gb pr edit` reporting "REST PR edit is unavailable"); (3) the non-interactive issue-state comments route (rule 5); (4) the attempt-first rule's existing general sentences (rule 7, apart from the appended sentence).

**RED:** None as a code assertion — this is a guard instrument over the already-committed Items 1–2 diff: the failure shape is a diff hunk that touches any preserved passage.

**GREEN:** No change; on a finding, the implicated Item 1 or 2 edit is re-scoped so no preserved passage is touched, and the guard re-runs.

**Tier marks:** No authored test; fact check (structural, executed `git diff`).

**Instrument:** `git diff main...HEAD -- skills/gb-cli/SKILL.md` (the working diff against the branch point); every added line must fall within the rule 4 known-gaps insertion region or the rule 7 appended sentence; zero hunks touch the four preserved groups.

### Item 4 — Behavioral scenario: passthrough attempt precedes limitation report (SC-3)

**Deliverable:** A tests-v2 behavioral scenario exercising the label-edit flow against the harness's GitBucket container (§12 provisioning), asserting that a session facing the `gb` web fallback's label refusal attempts the REST label passthrough (`gb api` against the label endpoints) before reporting any label-editing limitation, and reports a limitation only on evidenced failure of that attempt.

**RED:** The scenario's session evidence shows a limitation report (or refusal) with no preceding `gb api` label-endpoint attempt in the recorded session timeline — the assertion fails against current card behavior (the card, pre-correction, carries no directive forcing the attempt).

**GREEN:** The corrected card (Items 1–2) grounds the attempt; the scenario re-run shows the passthrough attempt preceding any limitation report. This item is behavioral-tier and heavy: it runs on-demand at cycle time through the behavioral harness, never as a default-run unit test.

**Tier marks:** Authored behavioral test (behavioral tier, heavy — on-demand dispatch through the tests-v2 behavioral harness only).

**Instrument:** The behavioral harness run output — the executed scenario's session timeline (via the session-to-timeline instrument) showing the ordered evidence: attempt, then either success or an evidenced-failure limitation report; recorded in the issue's audit area (`audit/behavioral-sc-3.md`).

### Item 5 — Cycle-time verification wrap-up (verify dispatch)

**Deliverable:** One fresh-context verify dispatch reading the spec, this plan, and the executed instrument outputs, returning PASS/FAIL on the SC set; on PASS, the record lands in `audit/verify-<date>.yaml` per store convention.

**RED:** N/A — process gate, not a code assertion.

**GREEN:** Zero-finding verdict recorded.

**Tier marks:** Recorded dispatch (verify card), not a test.

**Instrument:** The verify card's dispatch and its recorded verdict.

## 4. Dependency order

Items 1 and 2 are independent edits to adjacent rules of the same file — executed 1 then 2 so the file never carries a half-scoped diff mid-item; Item 3 executes strictly after both (it guards their committed diff). Item 4's GREEN depends on Items 1–2 (the card content under test); its scenario authorship may proceed in parallel, but its green run executes after Item 3 passes. Item 5 executes last, after all instrument outputs exist. No cycles.

## 5. Traceability

| Item | SC(s) |
|------|-------|
| 1 | SC-1 |
| 2 | SC-2 |
| 3 | SC-4 |
| 4 | SC-3 |
| 5 | (gate — all SCs) |

Spec coverage check: R-1 → Item 1 (SC-1); R-2 → Items 2 and 4 (SC-2, SC-3); R-3 → Item 3 (SC-4). No orphan items or SCs.

## 6. Verification summary

- Items 1–3 verify through executed fact checks (card read + one-by-one content element check; scoped `git diff` byte-exact guard) — run at cycle time, output captured to the issue's audit area.
- Item 4 authors one behavioral-tier heavy test (tests-v2 scenario); it runs on-demand through the behavioral harness at cycle time, never as a default run; the session-timeline evidence is its recorded artifact.
- Item 5 is the verify card's fresh-context dispatch; its verdict is the PR-boundary artifact.
- No unit-test file exists outside this account; the deliverable is a docs-only card edit, so no build/lint beyond the deck's reference-integrity check applies if the deck carries one — reference-integrity is run if the touched card's cross-references change (they do not; no links added).

## 7. Status boundary

No status fields or progress markers appear in this plan; implementation state lives in the pipeline, and the issue's audit records own measured history.
