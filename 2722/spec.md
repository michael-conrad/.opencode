# gb-cli: the --web fallback's "prompts for password" premise is false — attempt authenticated routes before developer handoff

Source: converted in place from this record's filed bug report .opencode#2722 (2026-11-06, triage verdict: actionable work — deck-card factual defect). Companion defect converted separately: .opencode#2721 (git-workflow-pr §2(f) ordering statement, same incident, different card).

## Problem

The `gb-cli` card's known-gaps passage asserts that the GitBucket `--web` fallback "prompts for the GitBucket password on a terminal" (`skills/gb-cli/SKILL.md`, known-gaps item 4, provenance .opencode#2382). Agents have read that sentence as a can't-run-this-myself premise and handed web-fallback operations to the developer.

Verified observation (2026-11-06, SUDC#5 filing session, NewSRX-Tech-LLC family):

- Command: `gb pr edit 5 -R OWNER/REPO --body="$(cat prbody.md)" --web </dev/null` — stdin closed, no tty (`TERM=dumb`; the shell tool provides no tty).
- Output: `Notice: REST PR edit is unavailable on this GitBucket instance; using web fallback.` followed by `✓ Updated pull request #5`, exit 0.
- No password prompt was consumed; no credentials interaction occurred. `gb auth status` reports token-based login (`opencode-michael`).
- Deck state at observation: post-2718 V2 port, HEAD 801591ec; current trunk (2d29de644) still carries the sentence (verified 2026-11-06 by direct read).

Field effect: on the strength of the card's premise, the agent reported the web fallback as the developer's step ("gb pr edit 5 --body --web from your terminal is the remaining route"). The developer rejected the handoff; the agent then ran the identical command non-interactively and it succeeded on the first attempt. The same premise drove a near-miss later in the same session when the out-of-order parent PR needed closing (see .opencode#2721 for that ordering defect). A deck card's false factual premise stood behind a run-vs-handoff decision twice in one session.

Root cause: the card states an unqualified factual claim ("prompts for the GitBucket password on a terminal") that a verified attempt disproves for token-authenticated sessions, and the card carries no rule that a can't-run conclusion about authenticated tooling must be evidenced by an attempt rather than by a premise.

## Scope

`skills/gb-cli/SKILL.md` only — the known-gaps item 4 passage (route guidance for PR close/edit on GitBucket) and the attempt-first rule in the same card. Routed through the deck's governance path: authored upstream (`michael-conrad/.opencode`), human merge only. Consuming checkouts receive the correction by pulling upstream.

## Requirements

- R-1 (structural): the card's `--web` fallback passage SHALL (a) state the verified operating reality — with token-based stored credentials the fallback completes non-interactively in a no-tty shell (observed 2026-11-06, evidence above), (b) direct agents to attempt the command in the session's own shell first before treating it as a developer step, and (c) contain no unqualified claim that the fallback prompts for a terminal password. The existing route statements around it — `--web` closes the PR when `gb pr close` 404s; plain `gb pr edit` reports "REST PR edit is unavailable" — are preserved unchanged.
- R-2 (behavioral): the card SHALL carry the standing attempt-first rule: a premise-based can't-run conclusion about authenticated tooling is never made without a verified attempt — authenticated tooling gaps are attempted first in the session's own shell, and only an evidenced failure routes the work to the developer as report-with-halt.

Design decision resolving the report's two proposed fixes: the report offered condition-dependent prompt documentation ("say exactly when") or removal plus agent-runnable statement. The verified evidence covers exactly one condition — stored token session, no tty: non-interactive success — and no observation of a prompting configuration exists. Documenting unobserved prompting conditions would assert facts without evidence; the removal-plus-corrected-statement branch is taken, with the observed condition stated rather than a universal "never prompts" claim.

## Success criteria

| ID | Criterion | Class | Instrument |
|----|-----------|-------|------------|
| SC-1 | The known-gaps `--web` passage states the fallback's non-interactive completion under stored token credentials (a), directs attempt-first (b), and contains no unqualified terminal-password-prompt claim (c); the preserved route statements survive unchanged — `--web` closes the PR when `gb pr close` 404s, and plain `gb pr edit` without `--web` reports "REST PR edit is unavailable" (d) | structural | read `skills/gb-cli/SKILL.md`, locate the passage, check (a)/(b)/(c)/(d) |
| SC-2 | The card states the attempt-first / evidenced-failure handoff rule | structural | read `skills/gb-cli/SKILL.md`, locate the rule |
| SC-3 | An agent facing an authenticated `gb` operation whose documented route appears blocked (API 404s, close non-interactive) attempts the sanctioned command in the session's shell before concluding can't-run, and routes to the developer only on evidenced failure | behavioral | tests-v2 behavioral scenario |

## Out of scope

- Documenting prompting conditions for deployment configurations never observed (absent evidence; a future observed prompt goes through a new report).
- Changes to the API routing statements themselves (which routes 404, which succeed) — the defect is the premise sentence, not the routing.
- The §2(f) PR-ordering defect (.opencode#2721) — companion defect, separate spec.
- Floor-level restatements of the attempt-first rule — the report scopes the rule to this card, where the premise caused the miss.

## Approach

Edit known-gaps item 4 in place: replace the premise sentence with the verified non-interactive statement under token credentials and the attempt-first direction; append the attempt-first/evidenced-failure rule to the card (same card list). Deck governance path: PR against `michael-conrad/.opencode`, human merge.

## Impact

Consumers: every agent session operating `gb` against a GitBucket instance under this deck. Risk of leaving unaddressed: agents keep converting runnable authenticated-CLI steps into developer handoffs on the strength of a card premise, and handoff-averse escalation keeps replacing a one-command verification with a human round-trip; a deck card carrying a disproven fact also degrades the reliability contract of every other stated fact in the card.

> Full spec artifacts: local store `.opencode/.issues/2722/spec.md`
