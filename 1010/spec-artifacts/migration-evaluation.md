# Migration Evaluation: Checklist Dispatch Architecture

## Evaluating the holistic best path to the target architecture

Synthesizing published research (Cao 2026, McMillan 2026, Chroma 2025, Tian Pan 2026), prior issue analysis (11 issues across 2 repos), Z3 constraint modeling, and industry best-practice evidence.

---

## Part 1: The Constraints (what research proves)

### Constraint A: Context saturation destroys procedural compliance

**Chroma Research (2025)** — "Context Rot: How Increasing Input Tokens Impacts LLM Performance." 18 models tested across controlled experiments holding task complexity constant while varying input length.

- Model performance degrades non-uniformly as input length increases — even on simple tasks
- Distractors (topically related but irrelevant content) compound degradation, especially at longer input lengths
- Lower needle-question similarity (semantic ambiguity) increases the rate of performance degradation
- **Relevance**: 45,014 words of session-start instructions is the "haystack." The dispatcher's `- [ ] N. task(...)` instruction is the "needle." Lower semantic similarity between the checklist instruction and surrounding guideline prose increases the likelihood the model will fail to follow the checklist.

**Tian Pan (Apr 2026)** — "The Instruction Position Problem." Systematic analysis of position bias in instruction following.

- U-shaped attention curve: tokens at beginning and end of prompt receive up to 73% compliance; tokens in middle degrade 30-50%
- Behavioral constraints (rules about what the model must never do) are most position-sensitive
- Compliance varies up to 61.8% when instructions are repositioned, even with identical wording
- **Critical finding**: "Instruction sandwich" pattern — place critical instructions at both beginning AND end of the system prompt — exploits primacy and recency simultaneously
- **Relevance**: In the current architecture, the dispatch mandate sits at position 45 (default.txt lines 45-60). The 45k words of guidelines follow. The dispatch mandate is "lost in the middle" of the overall system prompt. The model attends to the beginning (tool capabilities, examples) and the end (latest AGENTS.md content), but the dispatch mandate — the instruction we most need followed — sits in the attention valley.

### Constraint B: The sub-agent architecture is proven; non-dispatch is the defect

**Martin Uke (2025)** — "Sub-Agents in LLM Systems: Architecture, Execution Model, and Design Patterns."

- Sub-agents are the canonical scaling strategy for complex LLM systems
- Context isolation per sub-agent is the primary benefit — "reduced hallucinations, lower token usage, higher determinism"
- Planner → Executor pattern is standard; critic/reviewer sub-agent pattern is proven for correction loops
- **When NOT to use sub-agents**: "Task is short and linear, latency is critical, compute budget is tight, determinism is mandatory"
- **Relevance**: Implementation pipeline work is NOT short/linear — it's multi-step with verification gates. The current architecture fails its own sub-agent discipline because the orchestrator inlines instead of dispatching. The sub-agent architecture itself is correct. The defect is in the dispatch mechanism.

**Azure Architecture Center (2026)** — AI Agent Orchestration Patterns.

- Sequential (pipeline) pattern recommended when "stages have clear linear dependencies"
- Concurrent (fan-out) pattern recommended for independent analysis
- "Start with the right level of complexity — use the lowest level that reliably meets requirements"
- **Relevance**: Serial pipeline (#909's 14-step model) is the validated pattern for implementation work. The question isn't whether to use sub-agents — it's whether the orchestrator actually dispatches them.

### Constraint C: Format matters, but context contamination dominates

**McMillan (Feb 2026)** — "Structured Context Engineering." 9,649 experiments across 11 models.

- No statistically significant format effect at aggregate level for frontier models (chi-squared 2.45, p=0.484)
- Format structure measurably affects procedural compliance for smaller/open-source models
- Model capability dwarfs format choice (21 percentage-point accuracy gap)
- **Relevance**: The checklist format alone cannot fix the problem for frontier models. It must be paired with procedural enforcement (behavioral tests that FAIL when format is violated).

**Cao, Driouich, Thomas (Mar 2026)** — "Beyond Task Completion: Revealing Corrupt Success in LLM Agents through Procedure-Aware Evaluation."

- 27-78% of benchmark-reported successes are corrupt successes — agent "completes" task but violates procedure
- **This is the same pattern observed**: the orchestrator appears to produce output, but the process (dispatch via task()) was bypassed
- PAE framework: multi-dimensional gating (Utility, Efficiency, Interaction Quality, Procedural Integrity)
- **"Corrupt success" is the failure mode our behavioral tests must detect**: output exists, task appears done, but procedure was violated

### Constraint D: Position sensitivity is a CI failure mode

**Tian Pan (2026)** — "Position Sensitivity Is a CI Failure Mode."

- "A change that adds 200 tokens of context to your system prompt changes the position of every instruction that follows it. The instructions didn't change. Their position did."
- If compliance-critical rules were in the second quartile, they're now in the third — compliance drops 30-50% without anyone touching the rule text
- **Required**: positional sensitivity testing in CI — test each critical instruction at 3 positions (0-20%, 40-60%, 80-100%), flag >15% variance
- **Relevance**: Every guideline change, every new rule, every spec addition shifts the position of the dispatch mandate relative to the model's attention curve. We need a test that catches when the dispatch instruction moves into the attention valley.

---

## Part 2: The Dependencies (Z3-proved ordering)

From the Z3 analysis (contract + state at `spec-artifacts/z3/`):

### Proper: PRE_READ_FIXED → CHECKLIST_DEPLOYED → ENFORCEMENT_ADDED

1. **Fix pre-read cascade first** — 45k words must be reduced to <15k. Without this, the checklist format is cosmetic because contamination already happened at session start. The model has cached all task file content before ever seeing the checklist.

2. **Deploy checklist format** — convert prose task tables to `- [ ] N. (blind) task(...)` format. The row must be self-contained (carries full dispatch instruction). Without this, the orchestrator has no procedural obligation signal.

3. **Add behavioral enforcement** — test that FAILS when orchestrator reads `tasks/*.md` on `(blind)` items. Without this, the tag is a wish.

### Counterexample the solver found

Even with `PRE_READ_FIXED=True` and `CHECKLIST_DEPLOYED=True`, if `HAS_CACHED_KNOWLEDGE=True` and `SKILL_RESETS_CONTAMINATION=False`, dispatch still fails. `skill()` must actively flush/override cached task file knowledge at invocation time — this is an opencode tool implementation requirement, not just a config change.

---

## Part 3: The Five-Phase Migration Path (Holistic)

### Phase 1: Fix Pre-Read Cascade (depends on #1003)

**Goal**: Reduce session-start load from 45k to <15k words. Eliminate the contamination that precedes the skill() call.

**Actions**:
- Delete default.txt line 146 (the authorization to pre-read)
- Add startup mode identity (DISCUSSION vs EXECUTION)
- Trim 13 guideline files: retain Tier 1 safety-critical prose (<200 words per rule), move Tier 2/3 operational prose to skill cards where they fire on trigger, not at session start
- Rename `investigate/` → `observe/` to avoid triggering reverse-engineering reflex
- Implement "instruction sandwich" for the dispatch mandate: place it at BOTH the beginning of default.txt (position 1-3 of the file) AND reinforce it at the end of AGENTS.md before the build commands section
- Positional sensitivity test: verify dispatch mandate compliance does not vary >15% when guideline content shifts

**Research backing**: Chroma (2025) — performance degrades non-uniformly with input length. Tian Pan (2026) — instruction sandwich pattern exploits primacy + recency. Every trimmed word that moves to skill context is a word the orchestrator doesn't have to process as "haystack."

**Z3 dependency**: PROVED — checklist fails without this.

**Evidence of success**: Session-start word count < 15,000. Positional sensitivity test PASS (dispatch mandate compliance variance <15%). Agent does NOT pre-read tool source before behavioral observation (SC-4 of #1003).

### Phase 2: Skill() Cache Flush (opencode tool change)

**Goal**: When `skill({name: "..."})` is called, the model's cached knowledge of task file contents is actively reset/overridden. The skill call is a context boundary that the model treats as "I loaded new instructions, discard what I thought I knew."

**Actions**:
- Implement cache flush in the `skill()` tool — the response from `skill()` should dominate the model's local context for that skill's domain
- The `skill()` response should include the checklist prominently so the model processes it as the primary instruction for the next dispatch phase
- This is an opencode CLI implementation change, not a config change

**Research backing**: Martin Uke (2025) — "Context isolation per sub-agent is the primary benefit." The `skill()` call should trigger a similar isolation boundary in the orchestrator's context processing.

**Z3 counterexample**: Even with pre-read fix and checklist deployed, if `HAS_CACHED_KNOWLEDGE=True` and `SKILL_RESETS_CONTAMINATION=False`, dispatch still fails. This closure is required.

### Phase 3: Convert Task Tables to Checklist Format (depends on #958)

**Goal**: All SKILL.md task tables converted to `- [ ] N. (blind) task(...)` format. Row is self-contained.

**Actions**:
- Start with one reference skill (e.g., `research` or `changelog-generator`) — small, clear dispatch pattern
- Write behavioral test RED: assertion that orchestrator makes zero `read` calls on `tasks/*.md` during dispatch window
- Convert target skill's task table to checklist format
- GREEN the behavioral test
- Validate effectiveness before scaling: does the checklist format actually reduce inline/peek violations?
- Batch migrate remaining 38 skills
- Each checklist row carries the full `task()` instruction inline — no need to peek at task files

**Research backing**: McMillan (2026) — format alone not statistically significant for frontier models, but the research tested format at the *prompt level*, not as a *dispatch interface*. The checklist format is not a prompt — it's a routing table that the model executes against. Tian Pan (2026) — placing the dispatch instruction at the beginning of each checklist item (position 0% of that interaction) exploits primacy within the local context window.

**Design decisions (resolved in brainstorming)**:
- Max 2-3 checklists per skill. Beyond that, split the skill.
- `(blind)` tag present = orchestrator MUST NOT read task file. Absent = orchestrator MAY read.
- "when" condition (1-2 sentences) precedes each checklist for routing selection.
- Task files become pure sub-agent consumables for `(blind)` items — no orchestrator-facing preamble.

### Phase 4: Behavioral Enforcement Tests

**Goal**: Tests that FAIL when the orchestrator violates the dispatch protocol.

**Actions**:
- **Corrupt-success test**: Prompt orchestrator with a skill that has `(blind)` checklist items. Assert:
  - Zero `read` tool calls on `tasks/*.md` paths during dispatch window
  - `task()` call count ≥ checklist item count
  - Each `task()` call has the parameters specified in the checklist row
  - Actual agent output exists (behavioral semantic inspection)
- **Positional sensitivity test**: Same critical instruction (dispatch mandate) at 3 positions in a representative prompt. Verify compliance variance <15%.
- **Format regression test**: After any guideline/skill change, verify the dispatch mandate hasn't moved into a lower-attention position.

**Research backing**: Cao et al (2026) — 27-78% of successes are corrupt successes. Traditional benchmarks miss this because they measure output, not procedure. The behavioral test must catch corrupt success — output looks fine but procedure was violated. Tian Pan (2026) — positional sensitivity testing in CI is a non-negotiable requirement.

### Phase 5: Full Regression Verification

**Goal**: Confirm the complete architecture produces correct, reliable blind dispatch.

**Actions**:
- Run full behavioral suite against checklist format vs prose baseline
- Compare inline violations, skip-step violations, and corrupt-success rates
- Verify all prior behavioral tests still pass (nothing previously working is now broken)
- Document findings in the card catalogue

---

## Part 4: Risk Analysis

### Risk 1: Phase 2 (skill() cache flush) is an opencode tool change — external dependency

**Likelihood**: High (we don't control the opencode CLI)
**Impact**: Critical — Z3 proved this is required; without it, the architecture can't guarantee correct dispatch even with all other changes in place
**Mitigation**: 
- In the interim, ensure the `skill()` response content is dominant enough to override cached content. The checklist format should be the FIRST thing in the `skill()` response, exploiting primacy.
- Behavioral test with `HAS_CACHED_KNOWLEDGE=True` scenario to measure actual contamination level
- If the tool can't be changed, the checklist format + enforcement + pre-read fix may still produce measurable improvement even if not provably complete

### Risk 2: Phase 1 guideline trims conflict with safety-critical Tier 1 protections

**Likelihood**: Low (well-specified in #1003 — retain Tier 1, move Tier 2/3)
**Impact**: High if wrong — removing a safety-critical rule from session context could let the agent merge PRs, push to main, etc.
**Mitigation**:
- #1003 explicitly retains Tier 1 safety-critical rules in guideline files
- The semantic filter is documented: "must fire every session unconditionally" stays; "fires when specific trigger occurs" moves
- Z3 check with safety-critical retention invariant to verify no Tier 1 rule was lost

### Risk 3: Behavioral enforcement tests flake on model variance

**Likelihood**: Medium
**Impact**: High — if tests consistently fail from model randomness, they get disabled and enforcement is lost
**Mitigation**:
- Use `assert_semantic` with clean-room AI inspector (not grep on prose)
- Set appropriate timeouts (BEHAVIOR_TIMEOUT)
- Model-aware clean-room task() for behavioral testing (per 080-code-standards.md)
- If a specific model doesn't support the pattern, document and skip, don't remove the test

### Risk 4: Positional sensitivity changes silently on guideline updates

**Likelihood**: Medium (any edit to any guideline file shifts every instruction's position)
**Impact**: Medium — dispatch compliance degrades without anyone noticing
**Mitigation**:
- CI gate: after any guideline/skill change, run positional sensitivity test
- If dispatch mandate variance >15%, BLOCK the change until the dispatch mandate is restored to the instruction sandwich (beginning + end of system prompt)

---

## Part 5: Architectural Diagram

```
SESSION START (Phase 1: < 15k words)
  │
  ├─ default.txt (pos 1: dispatch mandate instruction sandwich — BEG)
  ├─ AGENTS.md (pos 1-2: identity, build commands)
  ├─ Tier 1 guidelines ONLY (000, 010, 020 stubs — pos 3-5)
  ├─ AGENTS.md (pos N: dispatch mandate instruction sandwich — END)
  │
  ▼
SKILL() CALL (Phase 2: cache flush)
  │
  ├─ skill() response contains CHECKLIST as first content
  ├─ Checklist row: - [ ] N. (blind) task(subagent_type="X", prompt="execute Y")
  ├─ Orchestrator executes task() from checklist row — never reads task file
  │
  ▼
SUB-AGENT EXECUTION (task file is clean-room consumable)
  │
  ├─ Sub-agent reads task file fully
  ├─ Sub-agent executes steps, writes evidence to disk
  ├─ Sub-agent returns frugal result contract {status, finding_summary, artifact_path}
  │
  ▼
ORCHESTRATOR RECEIVES CONTRACT
  │
  ├─ Checks result contract
  ├─ Moves to next checklist item
  ├─ If FINAL item: halts with structured output
  │
  ▼
ENFORCEMENT (Phase 4: behavioral tests)
  │
  ├─ Behavioral test FAILS if orchestrator reads tasks/*.md during dispatch
  ├─ Positional sensitivity test FAILS if dispatch mandate position shifts >15%
  └─ Corrupt success test FAILS if output exists but procedure was violated
```

---

## Summary: The answer to "what's the holistic best way?"

**The holistic best way is the Z3-proved dependency order with no shortcuts:**

1. Fix pre-read cascade (#1003) — 45k→15k words at session start, instruction sandwich for dispatch mandate
2. Implement skill() cache flush — opencode tool change to reset cached task file knowledge at skill invocation
3. Convert task tables to checklists — SKILL.md `- [ ] N. (blind) task(...)` format
4. Add behavioral enforcement — corrupt-success test, positional sensitivity test
5. Full regression — verify nothing broken, measure improvement

**Phase 1 is the only phase with an existing approved spec (#1003).** Phase 2 is the only phase requiring opencode CLI changes (external dependency). Phases 3-5 are within our control once 1 and 2 are complete.

**The architecture is correct.** The sub-agent pattern (Martin Uke 2025, Azure 2026) is industry-standard. The defect is solely in the dispatch mechanism: 45k words of context contamination prevents the orchestrator from following the dispatch protocol it already has. Fix the context, and the checklist format has a clean surface to bind against.

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)