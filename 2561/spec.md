---
number: 2561
title: "[REGRESSION] verified-resolved issues stay open — agent defers remote-mirror closure pending explicit instruction"
state: OPEN
labels: [bug]
---

## Problem Statement

When triage conclusively verifies an issue's defect no longer exists — an
evidence-backed moot verdict — the agent updates the local store to closed
but leaves the remote tracker issue OPEN, treating remote closure as a
named-destructive action requiring explicit instruction. The developer must
repeat the dispatch before realizing the work is done; the open remote reads
as pending work. Verified-resolved state must terminate in closure, not in a
report-and-wait loop.

## Success Criteria

### SC-1 — Verified-resolved verdict authorizes full closure (behavioral)

Given an issue triaged with an evidence-backed verified-resolved/moot verdict
(e.g. CLOSE-MOOT with live behavioral evidence recorded in the store), when
the triage completes, then the agent closes the issue in the local store AND
reconciles the remote tracker to the same closed state in the same workflow —
without requiring a separate explicit closure instruction from the developer.

Evidence: behavioral — agent run on a scenario with a pre-verified moot
issue; session record shows both local and remote closed at triage completion.

### SC-2 — Mirror reconciliation is sync, not re-authorization (behavioral)

Given local store status closed and remote tracker still OPEN (drift), when
the agent performs the issues sync/reconciliation step, then the remote state
is reconciled to match the authoritative local status without the agent
requesting fresh authorization — provided the local closure carries a
recorded verdict/evidence, not an unexplained status flip.

Evidence: behavioral — drifted-record scenario; session record shows remote
reconciled during sync, with the local verdict cited as the authority.

### SC-3 — Unverified/undecided closures still gated (behavioral)

Given an issue with NO verified-resolved verdict and no developer closure
instruction, when the agent considers closure, then the existing gate holds:
closure is not performed (never closure to tidy up). The new authorization
path applies only to evidence-backed verified-resolved/moot verdicts.

Evidence: behavioral — negative scenario; session record shows agent halts
or reports rather than closing an unverified issue.

### Verification-cost note (revised 2026-10-09, developer-directed)

Each full agent run costs 30-40 minutes (27b local model). The SC-1 and
SC-2/SC-3 scenarios share one issue-store shape, so coverage is produced
with TWO runs, not three: SC-1 runs standalone; one combined run carries a
store containing both a drifted verdict-backed record (SC-2) and a
genuinely-open record (SC-3) — the same session must reconcile the former
without re-authorization and leave the latter open. SC-3's evidence comes
from the combined run's session record (no closure of the open ticket,
local or remote).

### SC-4 — floor.md untouched (structural)

The remediation modifies only card-level content (issues card, its
references, and any triage-path card wording). `floor.md` is not modified.

Evidence: structural — diff of the remediation PR touches no always-injected
files.

## Affected Skill Cards (remediation targets)

| Card | Change |
|---|---|
| `.opencode/skills/issues/SKILL.md` §5 Closure | Add verified-resolved/moot triage verdict as an authorized closure trigger; state that closure includes reconciling the remote mirror in the same workflow; keep "never closure to tidy up" for unverified cases. |
| `.opencode/skills/issues/references/sync-mirroring.md` | Define remote-state reconciliation: local store is authoritative; local-closed/remote-open drift with a recorded verdict is repaired on sync without re-authorization. |
| `verify` card (candidate) | A CLOSE-* triage verdict carries a disposition step — closure is part of the verdict, not a follow-on request. Include only if consistent with the card's single-verdict discipline. |
| `work` card (candidate) | Triage path for existing issues terminates in closure when verification resolves the issue, rather than report-and-wait. Include only if wording stays lean. |

## Predicate Classification

The new authorization path is **intent-decidable**: "verified-resolved" is a
judgment (evidence sufficiency, verdict validity). No scriptable check is
permitted; mechanisms may verify only facts (e.g. a verdict field exists in
the local record).

## Admission-Gate Record (skill-creator)

1. **Observed failure:** session 2026-10-09, `.opencode#1205` loop — four
   repeated dispatches while remote stayed OPEN despite local CLOSE-MOOT.
2. **Consumer:** the agent performing issue triage, closure, and sync.
3. **Mechanism:** closure rule in the `issues` card + reconciliation rule in
   its sync-mirroring reference.
4. **Predicate classification:** intent-decidable (above).
5. **Domain match:** n/a — deck-native process rule.
6. **Root-agnostic:** no repo names or absolute paths in the rule text.
7. **What it replaces:** amends `issues` §5 Closure and
   `sync-mirroring.md` drift handling — no net deck growth; candidate items
   included only if they replace, not add, surface.
8. **Surface discipline:** card-level only; floor.md explicitly excluded.

## Provenance

- Filed from session 2026-10-09 after the `.opencode#1205` triage deadlock.
- Related: `.opencode#1205` (the moot issue whose remote mirror stayed OPEN).

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
