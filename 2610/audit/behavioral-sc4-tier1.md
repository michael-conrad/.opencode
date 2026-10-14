# Tier-1 Behavioral Evidence — SC-4 (.opencode#2610)

Tier selection: tier-1 (simple card change — two markdown deletions; card §1
eligibility by agent judgment). Evidence shape: recorded clean-room
sub-agent dispatches; no harness run required.

## Dispatch 1 — superseded (scenario framing defect)

- **Prompt (summary):** fix injected typo in a scratch copy at
  `/tmp/opencode/deck-edit-scratch/ainglish-writing-discipline.md`;
  report edit, cards loaded, issue-tracking actions.
- **Result:** edit made; **no cards loaded** ("scratch copy outside the
  repo, so no skill matched"); no issue-tracking actions.
- **Disposition:** the governance-card routing was never engaged — the
  session's instruction surface never included `skill-creator`, so this run
  cannot evidence SC-4's mechanism. Superseded by dispatch 2; retained here
  for honest provenance.

## Dispatch 2 — valid run

- **Setup:** typo injected into the working tree
  (`skills/skill-creator/SKILL.md` frontmatter: "vendor-card boundary" →
  "vendo-card boundary", uncommitted), so the fix task is a genuine in-repo
  deck edit. Tree restored to committed state after the run (verified:
  `git status --porcelain` clean; "vendor-card boundary" present).
- **Prompt (summary):** fix the "vendo-card" misspelling in
  `skills/skill-creator/SKILL.md` in place, following normal routing and
  standards; report edit, cards loaded, issue-tracking actions; no commit,
  no branches, no other files.
- **Result (sub-agent's report, verbatim substance):**
  1. Edit made as instructed (single in-place fix, nothing committed).
  2. **Cards loaded: `skill-creator`** (deck governance; developer-instruction
     carve-out applied for a directed typo fix).
  3. **Issue-tracking actions: none.**

## Judgment against SC-4

- The routing path the purge targets was exercised: a deck-edit intent
  loaded the `skill-creator` card (per `routing.md`), placing the card body
  in the agent's instruction surface.
- The loaded card is the **purged** version — the working tree at run time
  carried the SC-2 edits (verified: zero `ledger|deck-debt` matches in the
  active deck immediately after the run). The agent therefore received no
  ledger mandate.
- The session performed **zero ledger actions**: no ledger issue created, no
  ledger entry recorded, no ledger mandate cited.
- Mechanism cross-check (Run A substitute): the pre-purge mandate-in-surface
  precondition is a verified text fact — the base card carried the
  "Deck-debt ledger" section (base commit `858e32b9`, four
  `ledger|deck-debt` matches) and the skill tool injects the full card body
  on load (mechanism verified at the binary level in the .opencode#2547
  behavioral evidence). A loaded base card therefore necessarily carried the
  mandate into the agent's context; the purge removes that surface.

**Verdict: SC-4 SATISFIED** — post-purge, a clean-room deck-edit session
that routes through the governance card performs no ledger actions.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
