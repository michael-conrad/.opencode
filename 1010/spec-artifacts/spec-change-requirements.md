# Spec Change Requirements — Checklist Dispatch Architecture Migration

## STATUS: Final

Derived from migration evaluation at `migration-evaluation.md`. Documents every spec change needed, in dependency order.

---

## Phase 1 Dependencies

### #1003 (Pre-read cascade fix) — .opencode repo, approved-for-implementation

Three additions needed to the existing spec:

| Addition | Detail | Research backing |
|----------|--------|-----------------|
| Instruction sandwich for dispatch mandate | Dispatch mandate text must appear at both beginning of default.txt (lines 1-3) AND end of AGENTS.md (before build commands). Currently only removes line 146 — doesn't exploit primacy+recency | Tian Pan (2026): 73% compliance at beginning, instruction sandwich improves both |
| Positional sensitivity gate | CI test: verify dispatch mandate stays in first 5% of system prompt tokens after every change. If position exceeds 10%, BLOCK | Tian Pan (2026): "position sensitivity is a CI failure mode" |
| Word count target | 5k-8k target (not just "<15k"). 200-300 token base + conditional additions per task type | Valbuena (2025): "5-10% of total window for system prompt"; Chroma (2025): degradation starts well before 15k |

**Z3 dependency**: Phase 1 is proved prerequisite — checklist fails without pre-read fix.

---

### New: skill() cache flush — opencode CLI tool change (external dep)

Does not exist. SPEC-FIX for anomalyco/opencode repo.

| Aspect | Detail |
|--------|--------|
| Problem | After `skill()` call, model retains cached task file knowledge from session-start pre-read. Checklist arrives after cached content — model has conflicting sources of truth, chooses cache (inline) over checklist (dispatch) |
| Required behavior | `skill()` response content must dominate model's local context for that skill's domain. Checklist must be FIRST content in `skill()` response |
| Scope | opencode CLI tool change (`skill()` MCP tool response formatting) — not config, not guidelines |
| Z3 proof | Counterexample proved: even with pre-read fix + checklist deployed, if `HAS_CACHED_KNOWLEDGE=True` and `SKILL_RESETS_CONTAMINATION=False`, dispatch still fails |
| Files affected | opencode CLI source (external repo) |

---

## Phase 2 Dependencies

### #958 (Checklist format on all skill cards) — .opencode repo, open

Existing spec is a single paragraph with 3 SCs. Needs full rewrite:

| Addition | Detail |
|----------|--------|
| Row format | `- [ ] N. (blind) task(subagent_type="X", prompt="execute Y from Z")` — self-contained dispatch instruction in each row. No prose table, no separate lookup |
| (blind) tag semantics | Present = orchestrator MUST NOT read task file. Absent = orchestrator MAY read task file. Meaningful because both modes exist |
| Max checklists per skill | 2-3 maximum. Beyond that, split skill. Each checklist preceded by 1-2 sentence "when" condition |
| Task file role | For (blind) items: task files drop all orchestrator-facing preamble. Pure sub-agent consumable with execution steps, entry/exit criteria, and result contract format |
| Dependency declaration | Must note checklist conversion is ineffective without pre-read fix first. Z3 proved this |
| Behavioral test assertion | SC: count `read` calls on `tasks/*.md` during dispatch window for (blind) items. >0 = FAIL. Also assert `task()` count ≥ checklist item count |
| Migration order | Start with one reference skill (e.g., research or changelog-generator). Write behavioral test RED. Convert. GREEN. Validate. Batch migrate remaining 38 |

---

### #863 (Remove task() from task files) — .opencode repo, completed

No structural change needed. One addition:

| Addition | Detail |
|----------|--------|
| Cross-reference integrity test | Content-verification test that checklist row dispatch target matches orchestrator-routing marker in corresponding task file. If checklist says "dispatch X" but task file says "orchestrator dispatches Y," they contradict. FAIL |

---

### #909 (14-step orchestrator-serial pipeline) — .opencode repo, open

Existing dispatch table is prose format. Reform to checklist:

| Current | Target |
|---------|--------|
| Prose table: 3 columns, 14 rows | Checklist: `- [ ] N. (blind) task(...)` with dispatch instruction inline |
| Orchestrator reads table + references separate task specs | Orchestrator executes directly from checklist row |
| All steps treated equally | Some steps get `(blind)` tag (sc-coherence-gate, red-phase, green-phase, checkpoint-commit, structural-checks, exec-summary). Steps requiring orchestrator judgment (remediation-scope routing, cross-validate) do NOT get `(blind)` |

Steps requiring `(blind)`:
- sc-coherence-gate
- pre-red-baseline
- red-phase
- red-doublecheck
- green-phase
- checkpoint-commit
- structural-checks
- green-doublecheck
- green-vbc
- regression-check
- exec-summary

Steps NOT requiring `(blind)` (orchestrator may read):
- adversarial-audit (orchestrator should understand auditor selection)
- cross-validate (orchestrator should understand evidence type gating)
- review-prep (orchestrator should see format requirements)

---

### #911 (Two-role context cost model) — .opencode repo, completed

No changes needed. Cost model validated by migration evaluation.

---

## Phase 3 Dependencies

### #1008 (review-prep format lost) — .opencode repo, open bug

Fix is checklist format itself — no separate fix needed for this bug.

| Aspect | Detail |
|--------|--------|
| Root cause | Content moved to sub-task file, orchestrator skips reading, sub-agent doesn't produce chat output — format falls through crack |
| How checklist fixes it | Self-contained row spells out orchestrator's responsibility. Orchestrator dispatches exactly what row says. Sub-agent returns contract. No "both agents skip it" gap. The format requirement that #1008 describes becomes part of a non-blind checklist row |
| Action | Close #1008 as fixed-by-checklist-format after Phase 2 migration |

---

### New: Positional sensitivity CI gate — .opencode or opencode-config repo

Does not exist. New spec required.

| Aspect | Detail |
|--------|--------|
| Problem | Every guideline edit shifts dispatch mandate's position in system prompt. Tian Pan (2026): "A change that adds 200 tokens changes position of every instruction that follows it... compliance drops 30-50% without anyone touching rule text" |
| Required | CI test runs after every guideline/skill/config change: (1) measures token position of dispatch mandate in full system prompt; (2) verifies it stays within first 5% of tokens (exploiting primacy); (3) if position exceeds threshold or variance >15%, BLOCK |
| Additional | Test verifies instruction sandwich: dispatch mandate appears at both BOT (first 5%) and EOT (last 5%) of system prompt. Both copies must be in acceptable positions |
| Enforcement | BLOCK on CI. Not a warning. Not advisory. Position sensitivity is structural invariant |
| Research | Tian Pan (2026): "If any instruction shows more than 15% compliance variance across positions, treat as structural issue requiring prompt architecture changes, not prompt wording changes" |

---

### #1010 (current — Checklist Dispatch Architecture spec) — .opencode repo, current

Update to STATUS 0.6.

| Addition | Detail |
|----------|--------|
| Implementation plan | Replace "open questions" with the 5-phase plan from migration evaluation as the formal implementation plan |
| SC table | Success criteria for each phase: SC-1 through SC-20 covering pre-read fix, cache flush, checklist conversion, enforcement tests, regression verification |
| Dependency graph | Z3-proved ordering with phase dependency arrows |
| External dependency | Document skill() cache flush as opencode CLI tool change — we don't control this schedule |
| Current issue linking | Map each phase to its target spec number |

---

## Dependency Graph

```
Phase 1a: #1003 (pre-read cascade fix)
                │
Phase 1b: skill() cache flush (NEW — opencode CLI tool) 
                │
                ▼
Phase 2: #958 (checklist format) + #863 (cross-ref integrity) + #909 (reformat)
                │
                ▼
Phase 3: Positional sensitivity CI gate (NEW) + #1008 (close) + #1010 (finalize)
                │
                ▼
Phase 4: Behavioral regression suite
```

**Z3-proved**: Phases 1a+1b must complete before Phase 2 can be effective. Phase 2 must complete before Phase 3 enforcement can detect violations. Phase 4 validates everything.

---

## Files Referenced

| File | Location | Purpose |
|------|----------|---------|
| migration-evaluation.md | `1010/spec-artifacts/` | Full 5-part analysis with research, risks, diagram |
| spec-change-requirements.md | `1010/spec-artifacts/` | This file — actionable spec change list |
| cards.md | `1010/spec-artifacts/` | 12 tracked cards including all findings |
| z3/ | `1010/spec-artifacts/z3/` | Z3 contract + state artifacts |
| research/ | `1010/spec-artifacts/research/` | 3 research cards with verified citations |

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)