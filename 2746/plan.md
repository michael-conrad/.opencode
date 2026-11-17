# Plan: .opencode#2746 — Playwright browser-session defaults (msedge + durable profile); research browser-first

Spec: `.opencode/.issues/2746/spec.md` (validated rounds 1–3, zero findings).
Deck surfaces: `skills/playwright-cli/SKILL.md`, `skills/playwright-cli/references/install.md`, `skills/research/SKILL.md` in the `michael-conrad/.opencode` repository (`/home/muksihs/git/opencode-config/.opencode` checkout — the deck's own repo; work lands on its feature branch, human-merged PR).

## Preconditions (verified)

- 2026-11-16 executed evidence: bare `open` → chrome channel missing; headless/ephemeral chromium blocked by Cloudflare/JSTOR; msedge + `~/.cache/ms-playwright/daemon/ud-bl-persist` passed Google OAuth check and cleared JSTOR; profile cookie store holds Google + archive.org rows.
- All three deck files carry none of R-1..R-3 today (read at cycle start, this session) — the structural REDs below re-confirm in their own cycle.
- Deck-governance carve-out applies: the card edits are developer-directed (2026-11-16 directives quoted verbatim in spec §1); admission-gate content standards (frontmatter, root-agnostic discipline) still hold.

## Items

### Item 1 — SC-1: default-pairing doctrine in `skills/playwright-cli/SKILL.md`

- **Deliverable.** A new doctrine passage in the card body stating, as one unit: default launch = `--browser msedge --persistent --profile ~/.cache/ms-playwright/daemon/ud-bl-persist`, headed for interactive web surfaces; headless/throwaway launches named only as explicit non-default fallbacks for API-clean checks; the per-site channel exception (msedge is the default, not a per-site mandate — a site demonstrably better under another browser is served by that browser, site-scoped and observation-bound). Cross-reference to the runbook in `references/` for provisioning and login-once (deck-relative `Read [Text](path)` form).
- **RED.** Run the SC-1 instrument against today's card: read `skills/playwright-cli/SKILL.md`, attempt to quote the default-launch passage and the per-site exception passage — both absent (item 4's storage-state line is generic, names no channel/profile). Confirmed failing at cycle start.
- **GREEN.** The passage above, added to the card body; frontmatter description unchanged (router already covers browser automation; no trigger change needed).
- **Verify.** SC-1 instrument (spec §5): quote the default-launch passage and the exception passage from the edited card; confirm fallback framing present and default unambiguous.
- **Tier note.** No tests authored; verification instrument is the spec's structural read-and-quote. No test files exist or are created (heavy tiers: N/A).

### Item 2 — SC-2: four R-2 elements in `skills/playwright-cli/references/install.md`

- **Deliverable.** Runbook sections carrying: (a) msedge-presence check (e.g. check `/opt/microsoft/msedge/msedge` or `command -v msedge`); (b) the default launch command exactly as the card's doctrine states it (single-sourced: the runbook shows the command and points at the card for the doctrine, it does not restate variants); (c) login-once flow (headed window on target site, developer signs in, cookies land in the durable profile, persist across sessions — no credential text, developer-performed); (d) absent-channel path: provision a vendor browser build into the gitignored `.tools/` tree (mirroring the vendored-Node pattern already in this runbook) and point the channel at it — never an improvised alternate channel, never a system-package install; absence triggers provisioning, and the R-1 per-site exception answers observed site function, not channel absence.
- **RED.** Read today's runbook: contains vendored-Node CLI provisioning only — no msedge check, no default launch command, no login-once flow, no absent-channel browser recipe. Confirmed failing at cycle start.
- **GREEN.** New sections adding the four elements; existing vendored-Node content retained unchanged.
- **Verify.** SC-2 instrument: quote each of the four elements from the edited runbook.
- **Tier note.** No tests authored; structural read-and-quote instrument.

### Item 3 — SC-3: browser-first posture in `skills/research/SKILL.md`

- **Deliverable.** Amend the research card's web-research guidance to state the R-3 posture: playwright browser sessions per the R-1 channel-and-profile doctrine (default pairing + per-site channel exception) are used as needed for web research and assumed in preference to curl/raw page fetches for most sites; direct API calls remain appropriate for clean JSON endpoints. Reference the playwright-cli card in the deck-relative `Read [Text](path)` form. The disposition lives in one place — this item's wording; the card's existing item 2 mention of browser rendering stays consistent (no contradiction).
- **RED.** Read today's research card: browser use appears only as a JS-rendered-page rendering note; no browser-first preference over curl, no default-channel doctrine reference. Confirmed failing at cycle start.
- **GREEN.** The posture sentence set in the card's numbered guidance.
- **Verify.** SC-3 instrument: quote the posture sentence(s); confirm no contradiction of the playwright card's default-and-exception doctrine.
- **Tier note.** No tests authored; structural read-and-quote instrument.

### Item 4 — SC-4: behavioral — execute the documented default launch

- **Deliverable.** Executed evidence that the launch command as documented (from the consuming repo, per playwright-cli invocation PATH-prefix convention) opens an msedge session backed by the durable profile: daemon session record (`browser.launchOptions`, persistent-profile fields) and the binary actually launched.
- **RED.** SC-4 instrument not yet executed this cycle — no session record exists at `2746/research/` for the documented command against the post-edit doctrine; the 2026-11-16 evidence predates the deliverable and is precondition, not instrument output.
- **GREEN.** Run the documented default launch through vendored playwright-cli; capture the daemon session record to `2746/research/` (issue store); record the binary path (`/opt/microsoft/msedge/msedge`).
- **Verify.** The captured record shows msedge channel + the durable profile; output file is the evidence.
- **Tier note.** Ephemeral executed observation recorded to the issue store's `2746/research/` — not an authored test artifact; no test files created.

### Item 5 — SC-5: behavioral — login reuse across close/reopen

- **Deliverable.** Two-cycle executed check: launch per the documented default → assert archive.org authenticated state on the page (authenticated markers present, login control absent) → clean `close` → relaunch per the documented default → assert authenticated state again. Both cycles' evaluated page markers recorded to `2746/research/`.
- **RED.** SC-5 instrument not yet executed for the deliverable; precondition (planted 2026-11-16 sessions) verified in the profile, but the two-cycle close/reopen reuse check has not run as instrument output.
- **GREEN.** Execute the two cycles via the managed browser sessions (playwright-cli open/snapshot/close), record markers.
- **Verify.** Both cycle records show authenticated markers; the issue-store research records are the evidence.
- **Tier note.** Ephemeral executed observation; no test files created. Precondition: the live profile holds the planted logins (verified 2026-11-16; re-checked via profile cookie store before running if the cycle requires).

## Dependency order

Items 1–2 independent, run first (the doctrine single-sourced in the card; runbook references it) — item 3 next (references the R-1 doctrine), then items 4–5 (execute the documented commands; depend on items 1–2 being delivered so what is executed is what is documented). Item 5 needs item 4's launch path.

## Workflow notes (not items)

- Work happens on a feature branch of the `michael-conrad/.opencode` checkout (`2746-playwright-default-doctrine`), trunk-freshness verified per the branch card before the first file modification; PR to `michael-conrad/.opencode` per `git-workflow-pr`; human merge.
- SC-4/5 evidence lands in the issue store (`.opencode/.issues/2746/research/`) via `local-issues sync-file` — not in the deck branch.
- Implementation consumes only validated spec criteria; any discovered flaw routes per the implement card's mid-cycle rule.
