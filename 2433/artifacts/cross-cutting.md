# Preliminary Cross-Cutting Matrix — Dispatch Discipline Remediation

| Concern | Guidelines | Prompts | Skill cards | Task cards | Reference | Enforcement | Tests | Plans |
|---------|-----------|---------|-------------|------------|-----------|-------------|-------|-------|
| Orchestrator executes workflows directly | X (022, 000) | X (default.txt) | X (all 51 TDTs) | — | X (both standards cards) | ? (skildeck) | X (tests-v2 behaviors) | — |
| Task-card-only dispatch | X | X | X (284 strings) | X (leaf discipline) | X | — | — | X (#1210 gate table) |
| Plan steps executed by orchestrator | — | X ("via sub-agent") | X (executing-plans) | — | — | — | — | X (all plan files) |
| inline vocabulary | X (022 HALT) | — | X (46 cards, 3 contradictions) | — | X | — | — | X ("orchestrator inline" gates) |
| Leaf-node pre-flight guard | — | — | X (51/51) | — | — | — | — | MISSING for plans |
| Vocabulary: sub-task vs task vs inline vs orchestrator routes | X | X | X | X | X | — | — | X |

## Cross-cutting items requiring synchronized changes

1. **Vocabulary single-source.** Every layer uses different terms for the same concepts:
   - TDT: `sub-task` / `inline` / `blind sub-task`
   - 022: `clean-room sub-agent` / `inline work` / `pure router`
   - 000-critical-rules: `task card` / `skill card` / `routing-bypass`
   - #1210 plans: `orchestrator routes to general` / `orchestrator inline`
   - Target model needs ONE canonical vocabulary table referenced by all layers.

2. **The word "inline" is contaminated.** It currently means BOTH "orchestrator does directly" (022, pejorative) AND "a sanctioned execution mode" (TDT rows, plan gates). Any spec must either retire the term or redefine it precisely.

3. **HALT-on-inline is enforcement machinery pointed at the wrong thing.** 022's inline-work-HALT would fire on the TARGET model's orchestrator executing workflows directly. This machinery must be re-pointed (halt on whole-card/whole-plan forwarding instead) or retired with replacement.

4. **Skill cards are read in orchestrator context by design** (`skill()` auto-loads). Any rule that says "reading files inline is forbidden" collides with this unless the skill-routing-metadata exception is preserved — it exists in 022 but contradicts the neighboring "orchestrator reads files inline → HALT" rows.

5. **Plan format needs a dispatch-mode column.** Plans currently mix step prose with dispatch tables (#1210's gate table). A canonical plan step schema (step → execute directly / dispatch via task()) is cross-cutting across writing-plans templates, executing-plans, and all future plans.

6. **Tests encode the old model.** tests-v2 behavioral scenarios assert current dispatch behavior; changes here cascade into test expectations.

7. **Open specs overlap.** #1208/#1210 (TDT format across 39+ cards) shares files with this remediation. Sequencing must be decided: this spec supersedes the dispatch-semantics parts, or coordinates as a dependency.