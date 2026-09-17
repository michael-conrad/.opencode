# Plan Input Verification Ledger — .opencode#2451

Verified once 2026-09-17 (create task). All subsequent plan-composition steps read THIS ledger, not the sources.

## Issue state + labels (from issue.yaml)

- title: `[SPEC] One-dispatch-one-step gate — prohibit combined dispatches for discrete steps`
- status: open
- labels (current): `approved-for-pr`
- created 2026-09-17; updated 2026-09-17
- remote: https://github.com/michael-conrad/.opencode/issues/2451

## SC list with evidence types (from spec.md §3)

| SC | Criterion (condensed) | Evidence Type |
|----|----------------------|---------------|
| SC-1 | 257 contains p-dis-007 "One-Dispatch-One-Step Gate" per §11 add-pattern procedure (catalog row, selection matrix, canonical formula, co-application 250/255, auto-detection, version tracking, research basis); bright-line + no-matter-the-reasoning clause | string |
| SC-2 | 091 extends "Batching items" anti-pattern to dispatch level with no-exceptions clause + Read-link to 257 p-dis-007; Tier 1 (always loaded) | string |
| SC-3 | 022 extends critical-rules-034 to ALL dispatch-level combined shapes + no-matter-the-reasoning clause + Read-link; existing sub-agent-internal coverage preserved | string |
| SC-4 | tests-v2/AGENTS.md §15 cannot-combine clarification + §6a separate-dispatch sentence | string |
| SC-5 | Behavioral artifact-generation scenario in `.opencode/tests-v2/behaviors/`; real-model run vs multi-step-plan prompt; RED = observed 22 combined dispatches in `ses_f5aa152f7ffeeEzOm66Lr2Gbs6` (preserved, not fabricated) | behavioral |
| SC-6 | Separate clean-room evaluation dispatch reads session.yaml; semantic judgment (every discrete step received its own dispatch); only criterion + session.yaml as inputs; no markers/static gates | behavioral |
| SC-7 | Content-verification scenario asserting placement (257 p-dis-007, 091 bright-line, 022 extension) + absence of multi-step dispatch template text in task cards | string |

## Structure artifact mappings

- Phases: 1 = Rule-text authoring (SC-1..SC-4, items 1-4, files: 257, 091, 022, tests-v2/AGENTS.md); 2 = Behavioral scenario (SC-5, SC-6, items 5-6, files: behaviors/ new scenarios); 3 = Content-verification (SC-7, item 7).
- DAG: Phase 1 → Phase 2 (items 1-4 committed+pushed, fresh-fetch containment before behavioral run); Phase 1 → Phase 3 (items 1-3 → item 7). Item 1 → items 2, 3 (Read-link target must exist). Item 5 → item 6 (separate dispatch).
- Triplet colocation PASS; cross-phase dependency PASS (no backward edges).

## CLI surface flags needed

- Label write (local canonical, replaces entire labels array): `./.opencode/tools/local-issues update .opencode#2451 --labels approved-for-pr,spec-cleared` (must retain existing `approved-for-pr`).
- Test surface: `bash .opencode/tests-v2/test-enforcement.sh --scenario <name>`; `bash .opencode/tests-v2/with-test-home opencode run '<prompt>'` (>=600s timeout for behavioral).

## Requirements anchors (from spec.md §4)

R-1..R-12 as listed in spec; key preserved semantics: R-10 discrete-step definition (task-card plan step or workflow-marked sub-task dispatch), R-11 Architecture B preserved, R-12 decompose-and-re-dispatch corrective action, R-7 no static gates, R-8 observed RED preserved.
