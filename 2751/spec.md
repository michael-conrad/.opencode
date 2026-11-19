# gb-cli: document working GitBucket issue-label REST routes; class-scoped attempt-first for capability conclusions

## 1. Intent and Executive Summary

**Problem Statement.** A session operating a GitBucket-hosted issue store reported — and repeated to the developer — that issue labels could not be changed on GitBucket: "REST issue edit is unavailable on this GitBucket instance; using web fallback … GitBucket issue-label editing is unsupported on this instance". The claim was fabricated: the REST label routes work on the observed instance (2026-11-18, NewSRX-Tech-LLC/CrossrefAbstracts#78 — `PUT repos/NewSRX-Tech-LLC/CrossrefAbstracts/issues/78/labels` replaced the label set; `GET .../labels` confirmed `["spec"]`). Labels are part of the triage→spec conversion surface, so the fabricated limitation left record labels un-synced until the developer corrected it (2026-11-18).

**Root Cause / Motivation.** Two causes, both verified 2026-11-19 against current state:

1. The `gb-cli` card's known-gaps passage documents the unavailable endpoint classes — plain-issue state mutation (`PATCH .../issues/{n}` → 404) and conditional PR state mutation — but carries no statement for the working issue-label endpoints (`GET/PUT/POST repos/{owner}/{repo}/issues/{n}/labels`). A session that hits the `gb issue edit --add-label` web-fallback failure has no card grounding for the next route and — as observed — invents a platform limitation instead of attempting the `gb api` passthrough.
2. The `gb` CLI's web-fallback error string — "This GitBucket instance does not support editing issue labels through the web fallback; the web fallback cannot edit labels. Retry against an instance with REST issue edit support, or update title/body/assignees/milestone/state only." — asserts that the *instance* lacks label-editing support, which is false on the observed instance, and reads as a can't-run verdict instead of a route hint to `gb api`. The card's attempt-first rule (.opencode#2722) forbids premise-based can't-run conclusions generally; it does not name the observed fabrication shape — a capability conclusion about a *different endpoint class* generalized from one unavailable endpoint's documented gap and the fallback's error string.

**Approach Chosen.** Card-only correction in `skills/gb-cli/SKILL.md`: add the working-routes statement (with its evidence date) to the known-gaps passage, and extend the attempt-first rule to name cross-endpoint-class capability conclusions as requiring an attempted `gb api` passthrough call before any "unsupported"/"cannot edit" report. No tooling change: the corrected card statement supersedes the misleading fallback string in practice by naming the exact working routes an agent should attempt.

**Alternatives Considered & Why Discarded.**
- Correct the `gb` CLI's web-fallback error string — vendor-owned binary outside every repository this deck governs; the deck owns no surface of that binary. Discarded as a deliverable; the string's observed wording is recorded as evidence.
- Deck-wide sweep for similar endpoint-generalization defects in other cards — the filed report's out-of-scope clause excludes it; wider deck work is deck governance, not this finding's remediation.
- Document a per-instance/per-version capability matrix for GitBucket REST support — no evidence of per-version variance exists beyond the one observed instance; asserting unobserved instance states would repeat the fabricated-premise defect shape this spec corrects. The attempt-first rule's attempt-then-evidence path covers residual uncertainty.

**Key Design Decisions.**
- Route classes, not instance claims: the new known-gaps statement distinguishes endpoint classes (working label endpoints vs. unavailable issue-state mutation) without asserting instance-wide guarantees; the attempt-first rule, extended, decides remaining cases by attempt and evidence.
- The known-gaps content is prose, not a literal table: the required "row" binds content — a statement within the passage carrying the three content elements R-1 names — never a specific layout form.
- The attempt-first extension is scoped to capability conclusions about a *different endpoint class* than the one that failed; the rule's existing general sentences are preserved unchanged (verified by a byte-exact guard, SC-4).
- Evidence date carried in the passage (2026-11-18), matching the card's provenance convention for observed gaps (.opencode#2382, .opencode#2722 style).

**User Intent / Original Prompt.**
- Developer, 2026-11-19 (this session, dispatching triage): "triage .opencode#2751".
- Filed regression report .opencode#2751 (remote body, filed 2026-11-19), "Spec (required fix)", quoted verbatim: "**R-1:** The `gb-cli` card's known-gaps table SHALL carry a row distinguishing the *working* GitBucket label routes (`GET/PUT/POST repos/{owner}/{repo}/issues/{n}/labels` REST passthrough) from the unavailable ones (`PATCH .../issues/{n}` issue-state mutation), with the evidence date — so a label capability conclusion is never invented from the state-mutation gap." / "**R-2:** The card's attempt-first rule SHALL explicitly name capability probes for a *different endpoint class* as requiring an attempted passthrough call before any \"unsupported\" report — the generalization from one unavailable endpoint to its sibling endpoints is the observed fabrication shape." / "(Optional, tooling-owned) The web fallback's label error string should point at the working passthrough route rather than implying a platform limit."

## 2. Not Included

- Changes to the `gb` CLI binary or its web-fallback error string — vendor-owned tooling outside every repository this deck governs; the deck's deliverable is card content, and the corrected statement removes the practical harm by naming the working routes.
- Any change to issue-store data — the CrossrefAbstracts#78 labels were remediated in-session via the working route (2026-11-18).
- Deck wording outside `skills/gb-cli/SKILL.md` — the report's out-of-scope clause excludes it: load only what the finding names; wider sweeps are governance work.
- New scripts or tools under the deck's tooling directory — the fix needs none; the routes already exist behind `gb api`.
- Change to the attempt-first rule's application beyond capability conclusions — its general form already governs all authenticated-tooling can't-run conclusions; this spec adds only the named fabrication shape.

## 3. Requirements

- **R-1:** The `gb-cli` card's known-gaps passage SHALL carry the distinguishing statement — the working GitBucket issue-label endpoints (`GET`, `PUT`, and `POST repos/{owner}/{repo}/issues/{n}/labels`, reached via the `gb api` passthrough, including the `--input` JSON-payload pattern `PUT` requires) set against the unavailable plain-issue state mutation (`PATCH .../issues/{n}` → 404) — and SHALL carry the evidence date (2026-11-18, NewSRX-Tech-LLC/CrossrefAbstracts#78), so a label capability conclusion is never invented from the state-mutation gap.
- **R-2:** The card's attempt-first rule SHALL explicitly name capability conclusions about a different endpoint class as requiring an attempted passthrough call in the session's own shell before any "unsupported"/"cannot edit" report — the generalization from one unavailable endpoint (or its web-fallback failure) to sibling endpoints is the observed fabrication shape.
- **R-3:** The edit SHALL preserve the passage's existing statements unchanged — the plain-issue state-mutation gap (`PATCH .../issues/{n}` → 404), the PR-state mutation guidance (`gb pr close` 404; `gb pr edit --state closed --web` as the agent-runnable route; plain `gb pr edit` reporting "REST PR edit is unavailable"), the non-interactive issue-state comments route, and the attempt-first rule's existing general sentences.

## 4. Success criteria

| ID | Criterion | Class | Instrument |
|----|-----------|-------|------------|
| SC-1 | The known-gaps passage states the working GitBucket issue-label endpoints (`GET`/`PUT`/`POST repos/{owner}/{repo}/issues/{n}/labels` via `gb api` passthrough), sets them against the unavailable `PATCH .../issues/{n}` issue-state mutation, and carries the evidence date 2026-11-18 | structural | read `skills/gb-cli/SKILL.md`, locate the added statement, and check its three content elements: endpoints named, distinction stated, evidence date present — one binary check of the statement's required content |
| SC-2 | The attempt-first rule states that a capability conclusion about a different endpoint class requires an attempted passthrough call in the session's own shell before any "unsupported"/"cannot edit" report | structural | read `skills/gb-cli/SKILL.md`, locate the attempt-first rule's added sentence, check it names the cross-endpoint-class probe requirement |
| SC-3 | A session facing the `gb` web fallback's label-refusal attempts the REST label passthrough (`gb api` against the label endpoints) before reporting any label-editing limitation, and reports a limitation only on evidenced failure of that attempt | behavioral | tests-v2 behavioral scenario exercising the label-edit flow against the harness's GitBucket container (§12), asserting the passthrough attempt precedes any limitation report |
| SC-4 | The preserved statements of R-3 survive the edit byte-for-byte | structural | `git diff` of `skills/gb-cli/SKILL.md` scoped to the three preserved passages (plain-issue gap, PR-state guidance, attempt-first general sentences) — byte-exact, a same-file section guard over passages the change edits around |

## 5. Dependencies

| Reference | Relationship | Status |
|-----------|--------------|--------|
| `skills/gb-cli/SKILL.md` (michael-conrad/.opencode) | the edit target; its current passage and attempt-first rule are R-1/R-2/R-3's anchor text | satisfied — present, verified by direct read 2026-11-19 |
| Attempt-first rule provenance .opencode#2722 | R-2 extends the rule this precedent added; its conversion shape is this conversion's precedent | satisfied — rule present in card; precedent record read 2026-11-19 |
| GitBucket label evidence, NewSRX-Tech-LLC/CrossrefAbstracts#78 (2026-11-18) | supplies the evidence date and the working/failed command pair R-1's statement carries | satisfied — recorded in the filed report; not re-executed from this session (production data) |
| Deck governance path (skill-creator card, PR process) | the changeset routes through the deck repository's governance and human-merged PR | available — governance card present in deck |

## 6. Traceability

| Requirement | Success criteria |
|-------------|------------------|
| R-1 | SC-1 |
| R-2 | SC-2, SC-3 |
| R-3 | SC-4 |

Root-cause coverage: cause 1 (missing card grounding for the next route) → R-1/SC-1; cause 2 (fallback string's can't-run framing plus the unnamed cross-class generalization shape) → R-2/SC-2, SC-3. The observed failure (a fabricated limitation reported without attempting) is the failure SC-3 exercises. The change's blast radius on existing card content is guarded by R-3/SC-4; no stated root cause is uncovered.

## 7. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|--------------|
| .opencode#2751 remote body | filed regression report | github.com/michael-conrad/.opencode#2751 | read 2026-11-19 (`gh issue view`) |
| `gb-cli` card current text | deck card | skills/gb-cli/SKILL.md | direct read 2026-11-19: no label-endpoint statement; PATCH-404 gap, PR guidance, and attempt-first rule present as described |
| `gb` web-fallback error string | vendor binary | /home/muksihs/.local/bin/gb (gb 0.6.1) | `strings` grep 2026-11-19: exact string present |
| Label-route evidence (2026-11-18) | session evidence, quoted commands/outputs | .opencode#2751 evidence section; filing-session transcript | quoted in the filed report and not re-executed from this session (another host's production issue data); corroboration at write time is the string-level check above |
| .opencode#2722 converted spec | precedent record | .opencode/.issues/2722/spec.md | read 2026-11-19 |

## 8. Cost Frame

- SC-1, SC-2, SC-4: acting on the verification costs seconds (read the card; run a scoped diff); skipping costs exactly the observed defect — a fabricated platform limitation repeated to the developer and record labels left un-synced, requiring developer correction (observed 2026-11-18).
- SC-3: acting costs a tests-v2 behavioral scenario run (GitBucket container provisioning time); skipping leaves the fabrication shape unverified at runtime, so recurrence would surface only through another developer correction.

## 9. Edge Cases

| Condition | Expected behavior | Resolution |
|-----------|-------------------|------------|
| An instance (state or version unobserved) where the label REST route fails | the attempt-first rule's evidenced-failure branch governs: the attempt is made, and only the evidenced failure routes the work to the developer — the dated statement never overrides an attempt's evidence | R-1 wording states dated evidence, not an instance-universal guarantee; R-2 requires the attempt |
| GitHub-hosted stores reached with `gh` | the card's GitBucket-scoped passage must not imply any change to GitHub routing | SC-4 preserves the passage's framing; the statement stays inside the platform-awareness context |
| Web fallback's partial scope (title/body/assignees/milestone/state remain web-editable per the error string's own final clause) | the new statement does not claim the fallback edits nothing; it distinguishes label scope only | SC-1's content check ties the statement to the label endpoints; R-3 preserves surrounding text |
| A capability conclusion about a sibling endpoint class with no documented gap available (nothing yet attempted or documented) | the cross-class rule directs an attempted `gb api` call before any unsupported report — premise-free conclusions about unattempted endpoints are never made | R-2; the general attempt-first sentences (preserved, SC-4) remain the parent rule |

## 10. Completion gate

Every success criterion in §4 passes before the deliverable is complete; partial implementation is not permitted — the deliverable is incomplete if any criterion's instrument fails, including the byte-exact preservation guard.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
