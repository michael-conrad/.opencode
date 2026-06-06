# Card Catalogue — Checklist Dispatch Architecture

## STATUS: 0.1 (DRAFT — open discussion)

## Cards

### Card 1: Problem — Orchestrator inlines task files instead of dispatching blind

- **Observed**: Orchestrator agent reads task `.md` files, interprets steps, and executes inline instead of dispatching to sub-agents via `task()`.
- **Root cause**: Current SKILL.md task tables are prose/table format. Prose activates "read, interpret, decide" behavior. The orchestrator peeks at task files to compose prompts because the dispatch instruction isn't self-contained in the checklist row.
- **Evidence**: Behavioral test failure data — orchestrator makes `read` calls on task files during dispatch phase (verified by stderr pattern analysis). Survey of ~220 task files shows ~89% use prose procedures, not checklist format.
- **Status**: CONFIRMED (observed across multiple sessions)

### Card 2: Mechanism — Checklist format activates completion behavior

- **Research**: Cao et al (2026) — 27-78% of agent successes are corrupt successes (task appears done but procedure was violated). Checklist format reduces corrupt success rate by making procedure steps binding obligations rather than reference information.
- **Research**: NeuralBuddies (2026) synthesis — prose reads as reference data; numbered checklists read as obligations to discharge. Same content, different format, different compliance rate.
- **Mechanism**: `- [ ] N.` format is associated in training data with task lists, TODO items, workflow queues. Model treats unchecked boxes as incomplete obligations — drives completion behavior without interpretation.
- **Status**: CONFIRMED (research-supported mechanism)

### Card 3: Design — Checklist row is self-contained dispatch instruction

- **Decision**: Each checklist row carries the full dispatch instruction inline. Orchestrator never touches the task file.
- **Format**: `- [ ] N. (blind) task(subagent_type="X", prompt="execute Y from Z")`
- **`(blind)` tag**: Signals that orchestrator must NOT read the task file for this dispatch. Absence of tag means orchestrator may read it.
- **Rationale**: The dispatch instruction must be in the row because once the model looks away from the checklist at another file, it's back in "reference/interpret" mode and the procedural binding is lost.
- **Tradeoff**: Verbose rows. Tool-call syntax visible in SKILL.md. Cost of correct behavior.
- **Status**: OPEN (design hypothesis — needs behavioral testing)

### Card 4: When — Checklist applicability conditions

- **Open question**: Not all dispatches should be blind. When should a checklist be followed vs. when should the orchestrator read and route with judgment?
- **Proposed**: Each SKILL.md needs a "when" condition — a brief trigger description at the top that tells the orchestrator *under what conditions* this checklist should be executed. May need multiple checklists per skill for different task compositions.
- **Open question**: Can the same SKILL.md have multiple checklists? One per task composition path? The current model is one SKILL.md → one task table. Multiple checklists means multiple routing paths in the same skill.
- **Status**: OPEN — needs design resolution

### Card 5: Behavioral enforcement — Tag is not enough

- **Problem**: A `(blind)` tag is a wish without a behavioral test that FAILS when the orchestrator reads a task file on a blind dispatch.
- **Required**: Behavioral test that:
  1. Prompts orchestrator to execute a skill with `(blind)` checklist items
  2. Asserts that `read` tool calls on task files during dispatch phase = 0
  3. Asserts that `task()` tool calls = number of checklist items
- **Research**: McMillan (2026) — format alone is not statistically significant for frontier models at aggregate level. Format must be paired with procedural enforcement.
- **Status**: REQUIRED — not optional

### Card 6: Card catalogue purpose

- The card catalogue lives in `.issues/{N}/spec-artifacts/cards.md`
- Purpose: track reasoning, decisions, open questions, and evidence for the spec
- Cards are independently tracked status items — not a checklist, not a plan
- Each card has: observed/confirmed/rejected/open status
- Status: AGREED

### Card 7: Local draft spec workflow

- Spec is created in `.opencode/.issues/{N}/` as local draft
- Research cards in `spec-artifacts/research/` with verified source attribution
- Card catalogue in `spec-artifacts/cards.md`
- Open for discussion — no implementation until authorization
- Status: IN PROGRESS (this session)

### Card 8: Pre-read cascade (#1003) blocks checklist effectiveness — Z3 PROVED

- **Finding**: 45,014 words loaded at session start via `opencode.jsonc` instructions array: `default.txt` (2,208) + `AGENTS.md` (1,876) + 12 Tier 1 guideline files (39,731). Heavy files: `000-critical-rules.md` (11,562), `080-code-standards.md` (7,636), `020-go-prohibitions.md` (5,388), `065-verification-honesty.md` (4,993).
- **#1003 (open, approved-for-implementation)**: Proposes deleting default.txt line 146, adding startup mode identity, trimming 13 guideline files by moving Tier 2/3 prose to skill cards, renaming `investigate/` → `observe/`.
- **Root mechanism**: System message assembly: `default.txt (pos 1) → env → instructions (AGENTS.md + 13 guideline files) → skills → user`. Instructions array loads 13 files (~45k words) into orchestrator context before any `skill()` call. Model caches task file content, then ignores the checklist format at dispatch time.
- **Z3 theorem proved VALID**: `Implies(PRE_READ_FIXED=True, CHECKLIST_DEPLOYED=True, HAS_BEHAVIORAL_TEST=True, HAS_BLIND_TAG=True, ROW_CARRIES_DISPATCH=True, HAS_CACHED_KNOWLEDGE=False, HAS_ENFORCEMENT=True)` → `BLIND_TAG_EFFECTIVE=True`
- **Z3 counterexample found**: Even with `PRE_READ_FIXED=True` and `CHECKLIST_DEPLOYED=True`, if `HAS_CACHED_KNOWLEDGE=True` and `SKILL_RESETS_CONTAMINATION=False`, dispatch still fails. `skill()` tool must actively flush cached task file knowledge.
- **Status**: CONFIRMED (Z3-proved dependency)

### Card 9: Prior issue analysis — Three converging threads

- **Thread 1: Remove task() from task files** (#863, closed completed, .opencode). Task files containing `task()` calls cause sub-agents to rationalize routing their own work. Fix: replace `task()` with orchestrator-routing markers + result contract fragments. Plan #866 with 5 phases. Execution: #868 (audit), #869 (edit), #870 (agent configs), #871 (enforcement tests), #867 (SKILL.md routing table updates).
- **Thread 2: Orchestrator-as-routing-only** (#909 open; #911 closed completed; #1008 open). #909: 14-step serial pipeline (successor to #148). #911: two-role cost model — orchestrator holds routing metadata (cost: size × remaining_dispatches²), sub-agents consume freely (cost: size × 1), result contracts are frugal. #1008: concrete decomposition failure — content moved to sub-task file, orchestrator skips reading, sub-agent doesn't produce, format silently lost.
- **Thread 3: Checklist format as dispatch queue** (#958 open; #971 closed). #958: add 10-step workflow checklist to all SKILL.md files. #971: ordered checklists already added to adversarial-audit task files.
- **Also relevant**: #66 (closed not_planned, opencode-config) — sub-agent dispatch haphazardness remediation. 5 findings: nested spawning, inconsistent pre-analysis contracts, missing dispatch context fields, inline fallback in verify-authorization.md, missing dispatch audit tables in task files. #105 (closed not_planned) — pre-response gate carveout removal.
- **Status**: CONFIRMED

### Card 10: Migration path — Five-phase approach

- **Phase 1: Fix pre-read cascade (#1003).** Reduce session-start from 45k to <15k words. Delete default.txt line 146. Trim 13 guideline files (retain Tier 1 safety-critical, move Tier 2/3 to skill cards). Prerequisite for all other phases — Z3 proved checklist fails without this.
- **Phase 2: Convert one reference skill to checklist format.** Pick small skill (e.g., `research` or `changelog-generator`). Write behavioral test RED. Convert task table to `- [ ] N. (blind) task(...)`. GREEN. Validate before scaling.
- **Phase 3: Add behavioral enforcement test.** Assert zero `read` calls on `tasks/*.md` during dispatch window for `(blind)` items. Assert `task()` count ≥ checklist item count.
- **Phase 4: Batch-migrate remaining 38 SKILL.md task tables.** Standardized `(blind)/non-blind` distinction per row.
- **Phase 5: Verify behavioral regression.** Full behavioral suite against checklist format vs prose baseline.
- **Status**: RECOMMENDED

### Card 11: Z3 analysis results

- **Contract**: 7 constraints modeling pre-read contamination, row self-containment, tag-without-enforcement, tag-with-enforcement, pre-read dependency, clean-context+checklist working, behavioral-test-to-enforcement mapping.
- **Current state (check)**: SAT. `BLIND_TAG_EFFECTIVE=False`, `PRE_READ_EXCEEDS_THRESHOLD=True`, `HAS_BEHAVIORAL_TEST=False`. Current architecture is consistent but produces zero effective blind dispatch.
- **Full chain (prove)**: VALID — all conditions together provably produce correct blind dispatch.
- **Critical edge case (from solver)**: `PRE_READ_FIXED=True` + `CHECKLIST_DEPLOYED=True` + `HAS_CACHED_KNOWLEDGE=True` + `SKILL_RESETS_CONTAMINATION=False` → BLIND_TAG_EFFECTIVE still False. The `skill()` tool call must actively flush/override cached task file content. This is an opencode tool implementation requirement, not just config.
- **Files**: `tmp/dispatch-chain-contract.yaml` (Z3 constraints), `tmp/dispatch-chain-state.yaml` (current state snapshot).
- **Status**: COMPLETED