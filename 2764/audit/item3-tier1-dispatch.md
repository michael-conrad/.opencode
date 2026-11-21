# Item 3 — tier-1 behavioral dispatch record (SC-2, SC-4)

- **Route:** behavioral-testing card tier-1 (simple card change — one card's triage-path clause); recorded clean-room sub-agent dispatch — no harness run required for tier-1.
- **Dispatch prompt:** clean-room reviewer, no prior context, given Version A (§5 closure-rule text at trunk tip `39bff14cd`, pre-change) and Version B (§5 text at branch tip `ec45c183d`, change-carrying), unidentified as pre/post, plus a mock triage task (bug report #9001, stale local checkout) — judged the prescribed flow per version: (a) freshness sync required? (b) stale verdict without sync possible? (c) grounds state the gate ran?
- **RED verdict (Version A, pre-change):** freshness_gate_required: no; stale_verdict_without_sync: yes; grounds_state_freshness: no — "whose triage path runs directly against the local checkout state".
- **GREEN verdict (Version B, change-carrying):** freshness_gate_required: yes; stale_verdict_without_sync: no; grounds_state_freshness: yes — quoted: "Every triage path in this card — closure triage and work-entry conversion alike, self-triggered or developer-directed — is preceded by a freshness sync before the triage verdict is rendered."; "The gate pulls every session-enumerated repo to its remote trunk tip ... and runs `git submodule status` over the registered submodules, syncing each submodule checkout to its own remote trunk tip"; "The verdict is rendered against the post-sync state, and the verdict's recorded grounds state that the freshness gate ran."; "The conversion's triage runs the §5 pre-triage freshness gate".
- **Sub-agent session:** ses_e03fca979ffe7IgIZs9njh3k4R, completed 2026-11-20.

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
