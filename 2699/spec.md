## Problem

A phase's deliverables were executed and verified end to end, yet its ticket remained OPEN, and the agent responded to two direct developer follow-ups by re-explaining the closure gate instead of resolving the ticket. Concretely, in the 2026-11-02 session in the consuming repo CherokeeLanguage/cherokeelanguage-devops:

- Spec #10's deliverable set landed: PR #18 merged 2026-11-02T03:50:48Z (the phase-1 runbook + committed probe-script companion), and the runbook then executed successfully on the live host — the developer-run root probe captures dated 2026-11-02T03:23Z–03:41Z (in the issue's research folder) match the spec's success-criteria outcomes: Docker CE 29.9.2 platform with the Debian packages deinstalled, rotation config in force and demonstrated on a post-restart container, the `unless-stopped` reboot sentinel live, the unattended-upgrades origin drop-in proven by dry run, correct operator-group survival, zero exposure.
- Asked "why is #10 still open?", the agent answered with the three closure paths and waited for direction.
- Follow-up "I already told you the probe was re-run, why are you not following through?" — the agent again explained the gating and dispatched (but did not complete) a triage; still no closure or verdict.

Net effect: for completed, evidence-backed work, the pipeline's default outcome is a stalled ticket plus repeated developer round-trips. The agent recites the gate; nothing fires.

## Scope

One behavior change in the agent deck under `.opencode/`: the closure path must fire on its own trigger when work is verifiably complete — either because the evidence-backed verified-resolved triage named in the issues card runs autonomously once the completion evidence exists, or because the floor's default-scope blocklist gains a bounded exception reconciling a ticket whose deliverables are verified-resolved. The fix is deck governance (the admission/retirement gates), not a per-session prompt patch.

## Requirements

- R-1: When a ticket's deliverables are verified-resolved on dated evidence (executed instrument outputs matching the ticket's success-criteria outcomes) and the developer names that state or asks why the ticket remains open, the agent runs the evidence-backed triage and reconciles the tracker to the verdict in the same workflow. It does not re-explain the gate and wait.
- R-2: floor.md's closed-token-set/default-scope rules and the issues card's closure section must agree on what authorizes a verdict-backed closure. Today the floor blocklists all issue closure without a scope token while the issues card names the triage verdict as a closure trigger — the conflict is what produces the stall.
- R-3: The resolved rule preserves the real gate: executed evidence is the closure bar, and closure-to-tidy-up stays prohibited.

## Impact

- Consumers: every future ticket in this and sibling repos whose work completes without an explicit closure token; the developer's prompt budget (two round-trips spent per completed item above); the migration sequence holding tickets in the stalled state (the immediate instance is #10).
- Risk if unfixed: completed work strands as open tickets; the agent habituates to gate-recitation over follow-through.
- Blast radius: deck surfaces only — floor.md (authorization vocabulary / default scope), the issues card's closure section, and the deck-governance route via the skill-creator card. No repo source code, no CI.

## Session evidence trail (recorded 2026-11-02)

- PR #18 merged with "Refs #10" (no closing keyword — correct at merge time, since host work was still pending).
- Host execution evidence: seven dated probe captures 2026-11-02T03:23Z–03:41Z in the issue's research folder, matching the spec's criteria outcomes as listed above.
- Agent behavior: two gate explanations + one triage dispatch cancelled before running; no verdict, no closure.

## Analysis (agent hypothesis, for triage)

The conflict sits between two governing surfaces that disagree about the same action: the floor's default-scope blocklist ("no issue closure" without a scope-bearing token) and the issues card's closure section (an evidence-backed verified-resolved triage verdict as a legitimate closure trigger). Because nothing makes the triage path fire autonomously, the blocklist governs in practice and completed work stays open by default. The remediation belongs to deck governance — an admission-gated amendment that either makes the triage path self-triggering on completion evidence or carves the bounded reconciliation exception.


