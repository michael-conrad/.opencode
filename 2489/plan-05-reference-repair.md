# Phase 5 — Reference Repair (Tag Canon Repointing)

**Concern:** Repoint all 15 dead references to their live targets per the fixed Dead-Reference → Live-Target Mapping, in inline `Read [Text](path)` form, and consolidate the six tag rules into the canonical section.

**Files:**
- `.opencode/skills/git-workflow-branch/tasks/operating-protocol.md` (canonical "Tag Convention (Canonical)" section — SC-7 consolidation)
- `.opencode/commands/submodule-tag-prework.md` (dead refs)
- `.opencode/guidelines/000-critical-rules.md` (dead ref — Tier-1 always-loaded)
- `.opencode/skills/git-workflow-branch/tasks/provenance/trunk-push-provenance.md` (dead refs)
- `.opencode/skills/git-workflow-branch/tasks/submodule-sync.md` (dead ref)
- `.opencode/skills/git-workflow-cleanup/tasks/cleanup/branch-cleanup.md` (dead refs; note: lives under `tasks/cleanup/`)
- `.opencode/skills/git-workflow-branch/tasks/pre-work.md` (dead refs)

**SCs:** SC-7, SC-8, SC-9, SC-10

**Dependencies:** Phase 4 (SC-12 → SC-8/SC-9/SC-10 — repairs validated by the new check)

**Entry Conditions:**
- Phase 4 complete: reference-integrity check exists and passes its broken-probe gate
- Phase 4 VbC passed

**Exit Conditions:**
- All six Tag-Rule Inventory entries are present in the canonical section
- Zero references to `git-workflow/SKILL.md` §Tag Convention remain
- Zero references to the nonexistent AGENTS.md sections and the two pre-work.md dead targets remain
- Every repaired link uses inline `Read [Text](path)` form

**Code Path Coverage:** Agent-facing text paths only (component B) — no runtime behavior change.

**Cross-Cutting SCs:** agent-facing text (15 dead Read-links repaired); issue graph (#1953 draft covers the bare-§ link class — no cross-issue action required).

**Interface Boundaries:** Reference targets only — the canonical section in `operating-protocol.md` becomes the single home for all tag rules; no contract fields change.

**State Transitions:** reference graph — before: 15 links resolve to nothing (one in a Tier-1 always-loaded file); after: every link resolves to its mapped live target, validated by the reference-integrity check.

**Cost frame:** Running the reference-integrity check costs seconds-to-minutes — dead Read-links are caught before the next session loads them. Skipping costs every agent session (including Tier-1 always-loaded 000-critical-rules.md) resolving a dead link at the tag-decision point — days-to-weeks of silently wrong tag decisions.

---

- [ ] 40. **RED (**task-card**).** Consolidation RED: grep the canonical section for the six Tag-Rule Inventory entries (suffix rule, hash-permanence tag, checkpoint tag, release tag, idempotent tag-if-untagged, hash permanence replaces dependency-sync PRs) — at least one is missing (RED). **→ SC-7**
- [ ] 41. **GREEN (**task-card**).** Consolidate every tag rule into `operating-protocol.md` "Tag Convention (Canonical)" so all six inventory entries are present — including the idempotent tag-if-untagged rule currently stranded in dead-reference prose. Re-run the grep: all six present. **→ SC-7**
- [ ] 42. **Verify (**task-card**).** Verify SC-7: grep the canonical section for each of the six inventory entries — PASS requires all six present (closed list, no open-ended coverage reading). **→ SC-7**
- [ ] 43. **COMMIT (**direct**).** `git add` the canonical-section edit; commit (message: consolidate all tag rules into Tag Convention canonical section). **→ SC-7**
- [ ] 44. **RED (**task-card**).** Dead-target RED: grep for references to `git-workflow/SKILL.md` §Tag Convention — the 6 dead refs exist (commands/submodule-tag-prework.md ×2, guidelines/000-critical-rules.md, provenance/trunk-push-provenance.md, submodule-sync.md, git-workflow-cleanup branch-cleanup.md). **→ SC-8**
- [ ] 45. **GREEN (**task-card**).** Repoint all 6 references to `.opencode/skills/git-workflow-branch/tasks/operating-protocol.md` "Tag Convention (Canonical)" per the mapping table, in inline `Read [Text](path)` form. Re-run grep: zero dead-target matches. **→ SC-8, SC-10**
- [ ] 46. **Verify (**task-card**).** Verify SC-8: grep for the dead-target pattern returns zero; spot-verify each repaired link's target section exists. **→ SC-8**
- [ ] 47. **COMMIT (**direct**).** `git add` the six repaired files; commit (message: repoint Tag Convention references to canonical section). **→ SC-8**
- [ ] 48. **RED (**task-card**).** Dead-target RED: grep for the nonexistent AGENTS.md section references (§Tag Layers ×4, §Tag-Based Hash Permanence ×2, §Idempotent Tag-if-Untagged ×1) plus the two pre-work.md dead targets (§Skipping Git Pre-Check ref, `enforcement/halt-conditions.md` relative path) — all 9 exist. **→ SC-9**
- [ ] 49. **GREEN (**task-card**).** Repoint all 9 references per the mapping table: AGENTS.md-section refs → the canonical section (tag-type table); pre-work.md "Skipping Git Pre-Check" ref → `.opencode/skills/git-workflow-branch/SKILL.md` §[critical-rules-005] Skipping Git Pre-Check; pre-work.md halt-conditions ref → `.opencode/skills/git-workflow/enforcement/halt-conditions.md` "observe/ Branch Discard Enforcement". All in inline `Read [Text](path)` form. **→ SC-9, SC-10**
- [ ] 50. **Verify (**task-card**).** Verify SC-9: grep for each dead-target pattern returns zero; spot-verify each repaired link's target section exists. **→ SC-9**
- [ ] 51. **COMMIT (**direct**).** `git add` the repaired files; commit (message: repoint nonexistent AGENTS.md section references to live targets). **→ SC-9**
- [ ] 52. **Verify + VbC (**task-card**).** Verify SC-10: inspect each of the 15 repaired link sites — every one uses inline `Read [Text](path)` form (semantic evidence). Then verify SC-7, SC-8, SC-9, SC-10 verdicts are PASS with evidence artifacts on disk. **→ SC-10, SC-7, SC-8, SC-9**

#### Phase 5 Completion Block

- [ ] SC-7 verdict recorded with string evidence (six-entry inventory grep output)
- [ ] SC-8 verdict recorded with string evidence (zero-match grep output)
- [ ] SC-9 verdict recorded with string evidence (per-pattern zero-match grep outputs)
- [ ] SC-10 verdict recorded with semantic evidence (per-site inline-form inspection)

**Concern transition:** Leaving reference repair → entering integrity verification and tag-format correction. Phase 6 depends on Phase 5's SC-8/SC-9/SC-10 (SC-13 requires the repairs) and on Phase 4's SC-12.
