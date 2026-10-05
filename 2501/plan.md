# Plan — Deck rip-and-replace (.opencode#2490)

**Branch strategy**: single feature branch on the .opencode submodule (stacked); each stage below is a commit; every stage is followed by a fresh-session behavioral acceptance via `with-test-home` on the branch (merge is not the acceptance gate — the harness runs branch state). **Merge point: end of Stage 3** — the first merged state must be self-consistent (floor + routing + every card the routing index references). The developer's restart after merge begins the real-use soak; Stages 4–5 follow as the soak passes. The RED state for SC-1..SC-7 is the current deck itself — each acceptance assertion is written against the recorded failure evidence, confirmed failing before the stage's GREEN.

## Stage 1 — Injection surface (PR-1 content) — SC-1, SC-6, SC-8 partial

- **RED (evidence exists)**: fresh-session loaded-prompt inspection shows 14 instruction files (~49K tokens), 16KB `prompts/default.txt`, vibeguard plugin active.
- **GREEN**:
  1. Author `.opencode/floor.md` (charter: identity, external-access inventory, authorization vocabulary whitelist, pipeline sentence, deck-governance line, safety rules) and `.opencode/routing.md` (intent-phrased routing index). Zero cargo-culting: written from the spec, not edited from old files.
  2. `git mv` `skills/`, `guidelines/`, old `prompts/` content to `attic/`; tag `pre-rip`.
  3. `.opencode/AGENTS.md` → stub pointer to floor.md.
  4. `opencode.jsonc`: instructions array → `[floor.md, routing.md]`; remove `opencode-vibeguard` plugin; ragsync config path → deck-relative.
  5. `prompts/default.txt` → role definition + floor pointer.
  6. Delete `skills/**/__pycache__`.
- **Verify (behavioral)**: fresh session shows floor-only injection; vocabulary grammar present; no root-repo names in loaded content.

## Stage 2 — Skill layer (PR-2 content) — SC-2, SC-5 partial

- **RED (evidence exists)**: dispatched-with baselines — commit 19%, release 21%, deck-edit 0.5%; phrase machinery present in TDTs/frontmatter.
- **GREEN**: author the ~18–20 cards from the disposition table with two-level intent descriptions (domain + implementation framings); single `task()` contract reference; implementation-workflow content restored as the `implement` card core reference; vendor-card slot documented in governance card.
- **Verify (behavioral)**: fresh-session dispatch probes for commit, release, deck-edit, connector-use intents.

## Stage 3 — Governance + verify (PR-3 content) — SC-3, SC-7

- **RED (evidence exists)**: 5 re-verification loops + DiMo chain in current pipeline; zero governance dispatch on deck edits.
- **GREEN**: `work`/`implement`/`verify` cards (needs-scaled stages; single fresh-context reviewer, churn rule, bounded loop); `skill-creator` governance extension (admission gate, retirement gate, deck-debt ledger, predicate classification, domain-match rule, root-agnostic rule, vendor-card boundary).
- **Verify (behavioral)**: pipeline run on a small feature completes with single verification pass; deck-edit probe routes through governance.

## Stage 4 — Tests, hooks, agnostic remediation (PR-4 content) — SC-4, SC-6, SC-8

- **RED (evidence exists)**: tests-v2 contains prose-recall/structural-only tests (#918/#800); 5 hooks installed; root names/absolute paths in prose (66→15 non-SPDX hits measured).
- **GREEN**: harvest outcome-asserting behavioral tests into the new corpus; retire the rest with the attic; trunk-only hook (pre-commit + pre-push branch check; session-init verifies presence report-only); placeholder-ize examples; property-based conditions replace repo-name branching; fold `skills/reference/` into governance.
- **Verify**: corpus run (tests_run > 0, all passed); hook inventory = trunk check only; fact-decidable grep clean.

## Stage 5 — Soak + attic deletion (PR completion) — closes all SCs

- **GREEN**: soak period with attic consultable-but-unloaded; on pass, delete `attic/`; final acceptance run across SC-1..SC-8 in fresh sessions; PR ready for human merge.
- **Verify (behavioral)**: full fresh-session acceptance suite; evidence artifacts preserved until merge cleanup.

## Dependency order

1 → 2 → 3 → 4 → 5 strictly (each stage's acceptance gates the next). Parent-repo submodule-pointer update rides with the next real parent-repo change; root `AGENTS.md` slimming is a parent-repo change staged with it.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)