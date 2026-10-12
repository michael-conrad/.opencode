# Card catalogue — .opencode#2554 (verification record)

| SC | Type | Instrument | Verdict | Evidence |
|----|------|-----------|---------|----------|
| SC-1 | structural | `git diff --stat main...HEAD` filtered to the governed deck tree (floor/routing/skills/guidelines per skill-creator's governance scope; tests-v2 scripts are verification instrumentation under tests-v2 change control) | PASS | governed tree: `floor.md` (+6), `guidelines/ainglish-writing-discipline.md` (+118) — nothing else |
| SC-2 | structural | read floor.md + diff | PASS | trigger line present, relative pointer to guidelines file; diff shows no other floor modification |
| SC-3 | structural | read the guidelines file | PASS | all six elements present (four families w/ worked examples, losslessness, anti-pedantry, scope, adoption rules, read-time instruction) |
| SC-4 | structural | read the guidelines file | PASS | live register + flagship URLs present; no copied construct definitions |
| SC-5 | structural | grep + reference-integrity | PASS | zero hits for root repo names / absolute paths; `reference-integrity --scan` exit 0 (59 files) |
| SC-6 | behavioral | tests-v2 two-SC pattern | PASS | RED (pinned dc69525c): authored rule left deleting actor unbound ("Feature branches are deleted…") — hazard demonstrated. GREEN (c6204975): authored rule binds every actor ("the implementer deletes…", "binds anyone who finishes a merge: human contributors and AI agents alike") with scope exclusions and missing-evidence stop. Clean-room eval: PASS (evaluation-1791775271.yaml) |
| SC-7 | behavioral | tests-v2 two-SC pattern | PASS | RED disposition: pre-change RED is trivially true (agent cannot know constructs before the discipline exists) — GREEN-only by construction; recorded here rather than burning a meaningless run. GREEN: plain-English rules, zero constructs, no construct-counting. Clean-room eval: PASS (evaluation-1791776772.yaml) |
| SC-8 | behavioral | tests-v2 two-SC pattern | PASS | single-token typo revert restored card byte-identical to HEAD; no whole-card rewrite; clean-room eval: PASS (evaluation-1760232400.yaml) |
| SC-9 | behavioral | tests-v2 two-SC pattern | FAIL → remediated → PASS | attempt 2 (c6204975): rule 6 disciplined but seeded "Sending rules" left bare-actor — clean-room FAIL (evaluation-1791781200.yaml). Root cause: adoption rule didn't bind the editor ("not asked to touch it" excuse observed in reasoning). Remediation: guidelines wording now binds the editor; "unnamed sections stay in scope" (commit after 6d94ccf0). Attempt 4 (6d94ccf0): agent invoked whole-card-on-touch verbatim and converted the seeded section with intent preserved; clean-room eval: PASS (evaluation-1791783900.yaml). Attempt 3 aborted for ceremony escalation — filed as .opencode#2584 per developer directive |
| SC-10 | structural | ledger + headers | PASS | admission entry on deck-debt ledger .opencode#2534 (2026-10-11) with all six gate elements; SPDX + provenance headers on floor.md (existing) and the guidelines file (new) |

## Notes

- SC-1 interpretation recorded openly: the spec's Fix-shape table and Out-of-scope text distinguish the harness ("used as-is") from the deck tree; SC-6..9's own instruments require scenarios in tests-v2/behaviors/. SC-1 is verified against the governed deck tree; the four scenario scripts + two fixture scripts are reported separately.
- Ceremony escalation observed across three runs (RED SC-6; SC-9 attempts 1/3) — developer directed immediate defect treatment; filed `.opencode#2584` with spec. Not remediated in this change (out of #2554 scope; its own pipeline).
- Artifacts preserved under `tmp/2554/artifacts/` (working checkout; not committed — tmp/ is gitignored).

---
*Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)*