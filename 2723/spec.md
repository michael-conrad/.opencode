# local-issues create: creation-time warning for local-only registration in live-tracker stores

Source: converted in place from this record's filed bug report .opencode#2723 (2026-11-06, triage verdict: actionable work — creation-time enforcement gap).

## Problem

The issues card's creation rule (§2) is remote-first: "file the remote issue to reserve the number before any local folder setup — every issue type." The rule text exists; nothing enforces it at creation time. On 2026-11-06, two issues in Scraper-Us-Defense-Contracts (GitBucket, `NewSRX-Tech-LLC/Scraper-Us-Defense-Contracts`) were registered in that repo's `.issues` store as local-only records — SUDC#5 (created 15:05Z) and SUDC#6 (created 15:31Z) — each with no `github_url`/`remote_url` metadata and no matching remote ticket (`gb issue list --state all` shows only #1 and #2, both closed), while the store demonstrably has a live tracker (SUDC#1/SUDC#2 carry GitBucket tracking URLs). The creating sessions satisfied neither §2 nor any guard surfacing the divergence — the deck's creation flow permitted local-only registration silently.

Consequences observed: stakeholder invisibility — open pipeline work had no remote ticket, so the remote body (structured summary + artifacts pointer) existed nowhere. Number-space divergence was the repair risk, and the deck's §2 guard held only by compliance: the tracker's issue sequence carries a gap over numbers 3–5 (consumed, no longer listed), so "next free" derived from `issue list` would have said 3; because the repair filed remotely first, the assigned number for SUDC#6 was 6 and coincided with the local record — no renumbering needed. Had local-first been treated as authoritative, repair would have renumbered or pointed artifacts at a wrong number.

Root cause: creation-time enforcement gap, not a rule-text gap. `cmd_create` in `tools/local-issues` guards dual-branch divergence, pull-only repos, non-store-hosts, and duplicate local records — but after host classification no check or warning keys on the store's origin carrying a live remote tracker; local-only registration is silently reachable. The creating sessions followed the tool's permissive path.

## Scope

Two surfaces in this repository:

- `tools/local-issues` — `cmd_create` gains the creation-time divergence warning for tracker-platform store-hosts (detail under Requirements).
- `skills/issues/SKILL.md` — the local-issues operating contract documents the warning behavior, single-sourced, naming §2 as the rule enforced.

Routed through the deck repository's PR process (the card-surface edit under the governance card); upstream `michael-conrad/.opencode`, human merge.

## Requirements

- R-1 (behavior): `cmd_create` SHALL emit a stderr warning, at create time before the local record is written, when the target repo is a store-host whose origin resolves to a remote-tracker platform (host `github.com`, or a host-mapped GitBucket base per the tool's committed `local-issues-host-maps.conf` / origin-URL browser-base derivation the tool already performs for `url`). The warning SHALL name the violated creation rule (issues card §2 — remote-first reservation; never derive the number by listing remote issues) and state that local-only registration forks the number space and stakeholder visibility. The create proceeds — the silent path is what must not exist.
- R-2 (structural): the issues card's local-issues operating contract SHALL document the creation-time divergence warning for tracker-platform store-hosts, naming issues §2 as the rule it enforces.

Design decision resolving the report's "refuses/warns" alternative: a hard refusal is rejected because `create --number repo#N` is the sanctioned mirror-repair mechanism (issues card §7 — registering a local record for a remote issue whose record is absent), so refusal would break sanctioned repair; and the tool never contacts a remote issues-system API (operating-contract boundary), so the tool cannot itself verify remote reservation — refusal would rest on absence of evidence at a boundary the tool may not probe. The enforceable creation-time surface is the loud warning: divergence becomes visible at the exact step it occurs, on evidence the tool already holds (origin URL).

Platform detection is feasible with existing tool capability: `_remote_browser_base` already parses the origin URL and resolves the host (host-maps conf covers GitBucket instances whose SSH host differs from the web face; `github.com` is read directly from the origin). No new remote contact is required or permitted.

## Success criteria

| ID | Criterion | Class | Instrument |
|----|-----------|-------|------------|
| SC-1 | Running `create --number <repo>#N` for a store-host whose origin resolves to a tracker platform emits a stderr warning naming issues §2's creation rule; the create completes and the record exists as the same run's observable effect — this is the same end-to-end create path the issues-card §7 mirror-repair registers a local record with, so repair stays unbroken | behavioral | tests-v2 behavioral scenario — executed `create` run in a fixture store-host (sandbox git repo carrying a tracker-platform origin URL), stderr captured and checked; scenario harness per the tests-v2 route |
| SC-2 | The warning covers the `cmd_create` path for tracker-platform store-hosts — no create path for such a store proceeds without it | structural | read `tools/local-issues`, locate the warning in `cmd_create` after host classification and before record creation |
| SC-3 | The local-issues operating contract documents the creation-time warning, naming issues §2 | structural | read `skills/issues/SKILL.md`, locate the operating-contract line |

## Out of scope

- Repair of the SUDC#5 local-only record — remediation in the Scraper-Us-Defense-Contracts repository's own store (SUDC#6 is already repaired per the report), separate from this deck fix.
- Any remote-API contact from `local-issues` (the tool never contacts a remote issues-system API — operating-contract boundary).
- Hard-fail design for `create` (breaks the sanctioned mirror-repair path; see design decision).
- Retroactive divergence sweeps via `doctor` or `validate-yaml` — not requested by the report; SUDC#5's record is the known remaining instance and is routed above.
- Store-host classification restructuring (pull-only / non-host adoption rules) — the warning composes with the existing classification, changes none of it.

## Approach

Add the warning to `cmd_create` after the existing host classification (`_reject_pull_only` / `_reject_non_store_host`) and before record creation, deriving the platform from the origin URL the tool already parses (`_remote_browser_base` — host `github.com` or a host-maps-resolved GitBucket base). Document the behavior in the issues card's operating contract beside the existing tool-path rules. One upstream PR carrying both surfaces; human merge.

## Impact

Consumers: every family-repo issue store with a live remote tracker (deck-wide surface — the store-host classification and `create` path are shared tooling), and every developer relying on §2 to keep local store and remote tracker in one number space. Risk of leaving unaddressed: the permissive create path keeps producing silent local-only records whose repair then depends on the agent's own discipline rather than a surfaced signal; each undetected instance costs a repair session and risks renumbering.

> Full spec artifacts: local store `.opencode/.issues/2723/spec.md`
