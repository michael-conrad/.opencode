# Implementation Plan — .opencode#2561

Spec: `spec.md` (this folder). Branch: `2561-verified-resolved-closure` (submodule `.opencode`). Base tip: `edf31255` (== origin/main, verified fresh).

## Dependency order

1. Item 1 (card text: issues §5 Closure) → 2. Item 2 (sync-mirroring reconciliation) — item 2 references item 1's trigger, so ordered.
3. Items 3–4 (candidate cards `verify`/`work`) — independent, judged after 1–2 against the replace-not-add gate.
4. Verification + PR.

## Items

### Item 1 — `skills/issues/SKILL.md` §5 Closure (SC-1, SC-3)

- RED: current text authorizes closure only via "delivered work (post-merge cleanup) or explicit developer instruction" — a verified-resolved verdict has no path (observed: #1205 session loop). Recorded evidence in store.
- GREEN: add the evidence-backed verified-resolved/moot verdict as an authorized closure trigger; closure includes reconciling the remote mirror in the same workflow; keep the tidy-up prohibition for unverified issues. Lean wording, root-agnostic.
- Verify: textual check that the rule and its intent-decidable boundary are present; no scriptable "verified" check introduced.

### Item 2 — `skills/issues/references/sync-mirroring.md` (SC-2)

- RED: no remote-state reconciliation rule — local-closed/remote-open drift persists indefinitely (observed: #1205 mirror divergence).
- GREEN: define reconciliation — local store is authoritative; drift with a recorded verdict/evidence is repaired on sync without re-authorization.
- Verify: textual check; consistency with the sync command sequence already documented.

### Items 3–4 — candidate `verify` / `work` wording (replace-not-add gate)

- Judgment pass after items 1–2: include only if a disposition line replaces existing surface without fattening the card; otherwise record the exclusion decision in cards.md.

### Item 5 — Verification (SC-1..SC-3 behavioral, SC-4 structural)

- SC-1/2/3: behavioral evidence via the `tests-v2` harness (`with-test-home` + `behavior_run`), scenarios: verified-moot closure closes both mirrors; drifted record reconciles on sync; unverified issue is not closed.
- SC-4: structural — diff touches no `floor.md`/always-injected files.

### Item 6 — PR (`git-workflow-pr`), then HALT for human merge.
