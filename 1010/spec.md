# [MASTER SPEC] Checklist Dispatch Architecture — Orchestrator as Checklist-Driven Blind Dispatcher

## STATUS: 0.6 (MASTER — research complete, implementation plan defined, awaiting authorization)

**This is a PARENT TRACKING SPEC.** Sub-issues define each implementation phase. All research, design decisions, Z3 analysis, and migration planning consolidated here for session resume.

---

## 1. Problem

The orchestrator agent reads task `.md` files and inlines procedural steps instead of dispatching blind to sub-agents via `task()`. This produces poisoned work that must be discarded. Root cause is a compound defect:

| Layer | Defect | Evidence |
|-------|--------|----------|
| Session start | 45k words pre-loaded, model caches all task file content before skill() call | opencode.jsonc instructions array + 13 Tier 1 guideline files |
| Dispatch format | Prose table activates "read, interpret, decide" — not "discharge obligation" | NeuralBuddies (2026): checklist vs prose activation |
| Enforcement | No behavioral test catches when orchestrator reads task files instead of dispatching | Cao et al (2026): 27-78% corrupt-success rate |
| Tool boundary | skill() call does not flush cached task file knowledge | Z3 counterexample proof |

---

## 2. Solution Architecture

### 2.1 Checklist Dispatch Format

Every SKILL.md task table becomes a `- [ ] N.` checklist where each row carries the full dispatch instruction inline:

```
- [ ] 1. (blind) task(subagent_type="general", prompt="execute pre-work from git-workflow")
- [ ] 2. (blind) task(subagent_type="general", prompt="execute Phase-1 from executing-plans")
```

| Element | Rule |
|---------|------|
| `(blind)` | Present = orchestrator MUST NOT read task file. Absent = orchestrator MAY read |
| Dispatch instruction | Literal task() syntax in the row — self-contained, no file lookup needed |
| Max checklists per skill | 2-3. Beyond that, split the skill. Each preceded by 1-2 sentence "when" condition |
| Sub-agent context | task files are clean-room consumables for (blind) items — no orchestrator-facing preamble |

### 2.2 Session Start Architecture (after fix)

```
SESSION START (< 15k words target)
  │
  ├─ default.txt (dispatch mandate — INSTRUCTION SANDWICH BEG)
  ├─ AGENTS.md (identity, build commands)
  ├─ Tier 1 guidelines only (stubs — safety-critical)
  ├─ AGENTS.md (dispatch mandate — INSTRUCTION SANDWICH END)
  │
  ▼
SKILL() CALL (cache flush — tool change required)
  │
  ├─ Checklist is FIRST content in skill() response
  ├─ Row: - [ ] N. (blind) task(subagent_type="X", prompt="execute Y")
  ├─ Orchestrator executes task() from checklist — never reads task file
  │
  ▼
SUB-AGENT EXECUTION (task file = clean-room consumable)
  │
  ├─ Sub-agent reads task file, executes steps, writes evidence to disk
  ├─ Sub-agent may self-generate tmp/ checklist for internal decomposition
  ├─ Returns frugal result contract: {status, finding_summary, artifact_path}
  │
  ▼
ORCHESTRATOR (receives contract, advances to next checklist row)
  │
  ├─ Checks result contract status
  ├─ Advances to next checklist row
  ├─ On FINAL row: halts with structured output
```

### 2.3 Self-Generated tmp/ Checklists (Sub-Agent Layer)

Research from Zylos (2026) and TDAG (2025) confirms: explicit task decomposition improves tool-use accuracy from 72% to 94%. The hybrid pattern:

- **SKILL.md checklist** provides the verified dispatch skeleton (orchestrator layer)
- **tmp/ checklist** (self-generated in sub-agent context) provides task-specific decomposition (sub-agent layer)
- Sub-agent loads task file fresh (no pre-read contamination), generates checklists for internal execution
- tmp/ checklists are ephemeral but serve as checkpoint artifacts for long-running tasks

---

## 3. Dependencies (Z3-Proved)

### 3.1 Contract Summary

7 constraints modeled: pre-read contamination, row self-containment, tag-with-enforcement, tag-without-enforcement, pre-read dependency, clean-context+checklist working, behavioral-test-to-enforcement.

### 3.2 Theorem Proved

```
Implies(
  PRE_READ_FIXED=True,
  CHECKLIST_DEPLOYED=True,
  HAS_BEHAVIORAL_TEST=True,
  HAS_BLIND_TAG=True,
  ROW_CARRIES_DISPATCH=True,
  HAS_CACHED_KNOWLEDGE=False,
  HAS_ENFORCEMENT=True
) → BLIND_TAG_EFFECTIVE=True
```

**Result: VALID** (proved by Z3 solver)

### 3.3 Critical Counterexample

Even with `PRE_READ_FIXED=True` and `CHECKLIST_DEPLOYED=True`:
- If `HAS_CACHED_KNOWLEDGE=True` and `SKILL_RESETS_CONTAMINATION=False` → dispatch still fails
- **skill() must actively flush/override cached task file content** — opencode tool implementation requirement

### 3.4 Phase Dependency Order

```
Phase 1a: #1003 (pre-read cascade fix)
         │
Phase 1b: skill() cache flush (NEW — opencode CLI)
         │
         ▼
Phase 2: #958 (checklist format) + #863 cross-ref + #909 reformat
         │
         ▼
Phase 3: Positional sensitivity CI gate + #1008 close + behavioral tests
         │
         ▼
Phase 4: Full regression verification suite
```

Prerequisite chain is strict: each phase requires all prior phases.

---

## 4. Research Index

All research evidence in `spec-artifacts/research/`:

| File | Source | Key Finding |
|------|--------|-------------|
| `corrupt-success.md` | Cao et al (Mar 2026) arXiv:2603.03116 | 27-78% agent successes are corrupt successes — procedure violated, output looks fine |
| `format-compliance.md` | McMillan (Feb 2026) arXiv:2602.05447 | Format alone not significant for frontier models; must pair with enforcement |
| `checklist-format.md` | NeuralBuddies (May 2026) synthesis | Prose = reference data, checklist = obligation to discharge |
| `context-rot.md` | Chroma (2025) 18-model eval | Performance degrades non-uniformly with input length; distractors compound at longer lengths |
| `instruction-position.md` | Tian Pan (Apr 2026) | 61.8% compliance variance from position alone; instruction sandwich required; positional sensitivity is CI failure mode |
| `sub-agent-patterns.md` | Martin Uke (2025) | Sub-agent architecture is proven canonical pattern; non-dispatch is the defect |
| `orchestration-patterns.md` | Azure Architecture Center (2026) | Sequential pipeline validated for multi-step implementation work |
| `corrupt-success-pae.md` | Cao et al PAE framework | Multi-dimensional gating (Utility, Efficiency, Interaction Quality, Procedural Integrity) |
| `self-generated-checklist.md` | Zylos (2026), TDAG (2025) synthesis | Hybrid pattern: pre-authored skeleton + self-generated tmp/ decomposition by sub-agent |

---

## 5. Implementation Plan (5 Phases)

### Phase 1a: Fix Pre-Read Cascade (#1003)

| Step | Action | Target |
|------|--------|--------|
| 1.1 | Delete default.txt line 146 | Remove pre-read authorization |
| 1.2 | Add startup mode identity | DISCUSSION vs EXECUTION mode persona |
| 1.3 | Trim 13 guideline files | Retain Tier 1 safety-critical (<200 words/rule), move Tier 2/3 to skill cards |
| 1.4 | Rename investigate/ → observe/ | Avoid reverse-engineering reflex |
| 1.5 | Implement instruction sandwich | Dispatch mandate at BEGIN (default.txt) + END (AGENTS.md) of system prompt |
| 1.6 | Set word count target | 5k-8k session-start (from 45k) |
| 1.7 | Add positional sensitivity gate | CI test: dispatch mandate variance <15% across 3 positions |

**Dependency**: Z3-proved prerequisite. **Auth status**: approved-for-implementation.

### Phase 1b: skill() Cache Flush (NEW — opencode CLI)

| Step | Action | Target |
|------|--------|--------|
| 2.1 | File SPEC-FIX in anomalyco/opencode | skill() MCP tool response must flush cached task file knowledge |
| 2.2 | Implement: skill() response checklist FIRST | Checklist content dominates local context over cached task files |

**Dependency**: Z3 counterexample proved required. **Auth status**: Not yet created.

### Phase 2: Checklist Format Conversion

| Step | Action | Spec | Target |
|------|--------|------|--------|
| 3.1 | Rewrite #958 with full design | #958 | Row format, (blind) semantics, max 2-3 checklists, behavioral test assertion |
| 3.2 | Convert one reference skill (pilot) | #958 | Small skill (research or changelog-generator): RED→GREEN behavioral test |
| 3.3 | Add cross-reference integrity test | #863 | Checklist row target matches task file routing marker |
| 3.4 | Reform #909 dispatch table | #909 | 14-step prose table → checklist format |
| 3.5 | Batch migrate remaining 38 skills | #958 | Standardized conversion across all skills |

### Phase 3: Enforcement

| Step | Action | Spec | Target |
|------|--------|------|--------|
| 4.1 | Corrupt-success behavioral test | #958 + new | Zero read() calls on tasks/*.md during dispatch window |
| 4.2 | Positional sensitivity CI gate | NEW | BLOCK on >15% variance after any guideline change |
| 4.3 | Close #1008 | #1008 | Fixed by checklist format — self-contained row prevents decomposition gap |

### Phase 4: Regression

| Step | Action | Target |
|------|--------|--------|
| 5.1 | Run full behavioral suite | Compare checklist vs prose baseline |
| 5.2 | Verify all prior tests pass | Nothing previously working is broken |
| 5.3 | Document improvement metrics | Inline violations, skip-step rate, corrupt-success rate |

---

## 6. Spec Change Requirements (All Specs Affected)

See `spec-artifacts/spec-change-requirements.md` for the complete actionable change list.

| Spec | Repo | Status | Change Needed |
|------|------|--------|---------------|
| #1003 | .opencode | approved-for-implementation | +3: instruction sandwich, positional sensitivity gate, word count target |
| #958 | .opencode | open | Full rewrite: row format, (blind) semantics, max 2-3 checklists, task file role, dependency on #1003, behavioral test assertion |
| #863 | .opencode | completed | +1: cross-reference integrity test |
| #909 | .opencode | open | Reform 14-step prose table to checklist format with (blind)/non-blind per-step |
| #911 | .opencode | completed | No change needed |
| #1008 | .opencode | open bug | Close as fixed-by-checklist-format after Phase 2 |
| (new) skill() cache flush | anomalyco/opencode | does not exist | SPEC-FIX: skill() response must flush cached task knowledge |
| (new) Positional sensitivity CI gate | .opencode or opencode-config | does not exist | New spec: CI gate blocks guideline edits pushing dispatch into attention valley |
| #1010 | .opencode | current (this spec) | Update to master tracking spec (done — this revision) |

---

## 7. Migration Evaluation

Full 5-part analysis at `spec-artifacts/migration-evaluation.md`:

| Part | Content |
|------|---------|
| 1 | Published research constraints (6 sources) |
| 2 | Z3-proved dependency ordering |
| 3 | Five-phase migration path with detailed actions |
| 4 | Risk analysis (4 risks with mitigations) |
| 5 | Architectural diagram (session start → enforcement) |

---

## 8. Card Catalogue

12 tracked cards at `spec-artifacts/cards.md`:

| Card | Status |
|------|--------|
| 1: Problem — orchestrator inlines | CONFIRMED |
| 2: Mechanism — checklist format | CONFIRMED |
| 3: Design — self-contained row | OPEN (needs behavioral test) |
| 4: When — applicability conditions | OPEN |
| 5: Behavioral enforcement | REQUIRED |
| 6: Card catalogue purpose | AGREED |
| 7: Local draft spec workflow | AGREED |
| 8: Pre-read cascade blocks checklist | CONFIRMED (Z3-proved) |
| 9: Prior issue analysis | CONFIRMED |
| 10: Migration path | RECOMMENDED |
| 11: Z3 analysis results | COMPLETED |
| 12: Holistic migration evaluation | COMPLETED |

---

## 9. Related Issues

| Issue | Repo | State | Relevance |
|-------|------|-------|-----------|
| #148 | opencode-config | closed not_planned | Predecessor — orchestrator-serial pipeline |
| #622 | .opencode | closed completed | Confirmshaming weave routing layer |
| #1003 | .opencode | open approved-for-implementation | Pre-read cascade root cause fix — Phase 1a |
| #863 | .opencode | closed completed | Remove task() from task files — Phase 2 component |
| #909 | .opencode | open | 14-step orchestrator-serial pipeline — Phase 2 conversion |
| #911 | .opencode | closed completed | Two-role context cost model — validated |
| #958 | .opencode | open | Add workflow checklists to all skill cards — Phase 2 |
| #1008 | .opencode | open bug | review-prep format lost — to close post-Phase 2 |
| #66 | opencode-config | closed not_planned | Sub-agent dispatch haphazardness — context |
| #105 | opencode-config | closed not_planned | Pre-response gate carveout removal — context |

---

## 10. Files

```
.opencode/.issues/1010/
├── spec.md                                         ← This file (master tracking spec)
├── spec-artifacts/
│   ├── cards.md                                    ← 12 tracked cards
│   ├── migration-evaluation.md                     ← Full 5-part research+plan
│   ├── spec-change-requirements.md                 ← All specs, what to change
│   ├── research/
│   │   ├── corrupt-success.md                      ← Cao et al (2026)
│   │   ├── format-compliance.md                    ← McMillan (2026)
│   │   ├── checklist-format.md                     ← NeuralBuddies (2026)
│   │   ├── self-generated-checklist.md             ← Zylos/TDAG (2025-2026)
│   │   └── (context-rot.md, instruction-position.md, sub-agent-patterns.md,
│   │        orchestration-patterns.md, corrupt-success-pae.md — synthesized
│   │        in migration-evaluation.md)
│   └── z3/
│       ├── dispatch-chain-contract.yaml            ← Z3 constraints (7)
│       └── dispatch-chain-state.yaml               ← Current state snapshot
```

---

## 11. Session Resume

To resume work on this spec in a future session: load this file, read the card catalogue (cards.md) to understand what's been decided and what's open, and check the research index (Section 4 above) for evidence backing. The implementation plan (Section 5) defines the dependency-ordered work queue.

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)