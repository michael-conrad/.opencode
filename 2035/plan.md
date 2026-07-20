# Implementation Plan — [#2035](.opencode/.issues/2035/spec.md) — Prefer Built-ins Mandate

- **Goal:** Add a "Prefer Built-ins" mandate to AGENTS.md, 080-code-standards.md, and 060-tool-usage.md requiring the agent to prefer opencode built-in tools, MCP servers, standard libraries, and add-ons over bespoke code.
- **Architecture:** Documentation-only change — 3 files modified with insertions only. No code changes. Forward-looking mandate that grandfathers existing bespoke code.
- **Files:** `.opencode/AGENTS.md`, `.opencode/guidelines/080-code-standards.md`, `.opencode/guidelines/060-tool-usage.md`
- **Dispatch:** `writing-plans` → `implementation-pipeline` → `verification-before-completion` → `finishing-a-development-branch` → `git-workflow`

## Blast Radius

- `.opencode/AGENTS.md` — new section near "Build / Lint / Test Commands" heading
- `.opencode/guidelines/080-code-standards.md` — new top-level section
- `.opencode/guidelines/060-tool-usage.md` — new subsection under "Tool Priority Hierarchy"
- No code files affected. No behavioral changes to existing agent behavior. Grandfather clause protects existing bespoke code.

## Concern Map Reference

| Concern | Phase | Files |
|---------|-------|-------|
| Add "Prefer Built-ins" mandate | Phase 1 | AGENTS.md, 080-code-standards.md, 060-tool-usage.md |

> **Compliance requirement:** This plan MUST be followed step-by-step. Every step MUST be completed in order. No step may be skipped, reordered, or combined. Each step's dispatch indicator MUST be respected — `(**sub-agent**)` steps MUST dispatch a sub-agent via `task()`, `(**clean-room**)` steps MUST dispatch with routing metadata only, `(**inline**)` steps MUST execute directly. Violating step ordering or dispatch discipline is a process-integrity failure.

> **One-step-at-a-time protocol:** Execute exactly one step at a time. After each step, verify the output before proceeding. Do not batch, combine, or parallelize steps. Each step produces a discrete deliverable that the next step consumes. Skipping ahead produces defective work that must be discarded.

> **Step Status instruction:** Every step MUST be tracked with `todowrite` — status transitions: `pending` → `in_progress` → `completed`. After the final step, call `todowrite(todos=[])` to clear state. Never leave stale `todowrite` state.

## Phase Table

| Phase | Name | Concern | SCs | Dependencies | Step Range | Dispatch |
|-------|------|---------|-----|--------------|------------|----------|
| 1 | Prefer Built-ins Mandate | Add mandate text to 3 files | SC-1, SC-2, SC-3, SC-4, SC-5, SC-6 | None | 1–19 | `writing-plans` → `implementation-pipeline` |

---

## Phase 1 — Prefer Built-ins Mandate

**Concern:** Add "Prefer Built-ins" mandate text to 3 files. All SCs are `string` evidence type — verified via grep.

**Files:** `.opencode/AGENTS.md`, `.opencode/guidelines/080-code-standards.md`, `.opencode/guidelines/060-tool-usage.md`

**SCs:** SC-1, SC-2, SC-3, SC-4, SC-5, SC-6

**Dependencies:** None

**Entry conditions:** Plan approved, feature branch created, work state initialized.

**Exit conditions:** All 6 SCs verified PASS via grep (string evidence). Phase VbC complete.

### Code Path Coverage

No code paths — documentation-only change. Three target insertion points:
- AGENTS.md: after "Build / Lint / Test Commands" section (line ~87)
- 080-code-standards.md: as new top-level section (after line ~821)
- 060-tool-usage.md: as subsection under "Tool Priority Hierarchy" (after line ~30)

### Cross-Cutting SCs

None — all 6 SCs are phase-specific.

### Interface Boundaries

No interfaces affected — documentation-only.

### State Transitions

No state transitions — documentation-only.

### Step-by-step

- [ ] 1. **Pre-RED: Assemble work (**clean-room**).** Read plan, verify dispatch indicators, create work state file at `tmp/2035/work.md`. **→ SC-1, SC-2, SC-3, SC-4, SC-5, SC-6**
- [ ] 2. **Pre-RED: SC coherence gate (**clean-room**).** Dispatch audit coherence-extraction — verify all 6 SCs are coherent, non-overlapping, and verifiable via grep. **→ SC-1, SC-2, SC-3, SC-4, SC-5, SC-6**
- [ ] 3. **Pre-RED: Pre-red baseline (**clean-room**).** Run `grep` for each SC pattern on current files to confirm all 6 SCs FAIL before changes. Record baseline in work state. **→ SC-1, SC-2, SC-3, SC-4, SC-5, SC-6**
- [ ] 4. **RED: Write failing grep tests (**sub-agent**).** Write a test script at `tmp/2035/test-prebuilt.sh` that greps for each SC pattern and exits non-zero if any pattern is missing. Run it — confirm it FAILS (exit non-zero). **→ SC-1, SC-2, SC-3, SC-4, SC-5, SC-6**
- [ ] 5. **RED doublecheck (**clean-room**).** Verify RED test fails — confirm `tmp/2035/test-prebuilt.sh` exits non-zero against current (unchanged) files. **→ SC-1, SC-2, SC-3, SC-4, SC-5, SC-6**
- [ ] 6. **GREEN: Insert mandate into AGENTS.md (**sub-agent**).** Add a "Prefer Built-ins" section near the "Build / Lint / Test Commands" section in `.opencode/AGENTS.md`. The section must state the global mandate (SC-4), list preferred alternatives (SC-5), and require feasibility justification (SC-6). **→ SC-1, SC-4, SC-5, SC-6**
- [ ] 7. **GREEN doublecheck: AGENTS.md (**clean-room**).** Verify SC-1, SC-4, SC-5, SC-6 patterns exist in AGENTS.md via grep. **→ SC-1, SC-4, SC-5, SC-6**
- [ ] 8. **Checkpoint commit (**inline**).** `git add .opencode/AGENTS.md && git commit -m "feat: add Prefer Built-ins mandate to AGENTS.md"`. Create checkpoint tag. **→ SC-1**
- [ ] 9. **GREEN: Insert mandate into 080-code-standards.md (**sub-agent**).** Add a "Prefer Built-ins" top-level section to `.opencode/guidelines/080-code-standards.md`. The section must state the global mandate (SC-4), list preferred alternatives (SC-5), and require feasibility justification (SC-6). **→ SC-2, SC-4, SC-5, SC-6**
- [ ] 10. **GREEN doublecheck: 080-code-standards.md (**clean-room**).** Verify SC-2, SC-4, SC-5, SC-6 patterns exist in 080-code-standards.md via grep. **→ SC-2, SC-4, SC-5, SC-6**
- [ ] 11. **Checkpoint commit (**inline**).** `git add .opencode/guidelines/080-code-standards.md && git commit -m "feat: add Prefer Built-ins mandate to 080-code-standards.md"`. Create checkpoint tag. **→ SC-2**
- [ ] 12. **GREEN: Insert mandate into 060-tool-usage.md (**sub-agent**).** Add a "Prefer Built-ins" subsection under the "Tool Priority Hierarchy" section in `.opencode/guidelines/060-tool-usage.md`. The subsection must reference the global mandate and state that Tier 1-3 tools MUST be preferred over bespoke code (SC-3). **→ SC-3, SC-4, SC-5, SC-6**
- [ ] 13. **GREEN doublecheck: 060-tool-usage.md (**clean-room**).** Verify SC-3, SC-4, SC-5, SC-6 patterns exist in 060-tool-usage.md via grep. **→ SC-3, SC-4, SC-5, SC-6**
- [ ] 14. **Checkpoint commit (**inline**).** `git add .opencode/guidelines/060-tool-usage.md && git commit -m "feat: add Prefer Built-ins mandate to 060-tool-usage.md"`. Create checkpoint tag. **→ SC-3**
- [ ] 15. **Post-GREEN: VbC — all SCs (**clean-room**).** Run `tmp/2035/test-prebuilt.sh` — confirm it exits 0 (all 6 SC patterns present). Record PASS verdicts per SC in work state. **→ SC-1, SC-2, SC-3, SC-4, SC-5, SC-6**
- [ ] 16. **Post-GREEN: SC count gate (**clean-room**).** Verify all 6 SCs have PASS verdicts. No FAIL or UNVERIFIED. **→ SC-1, SC-2, SC-3, SC-4, SC-5, SC-6**
- [ ] 17. **Post-GREEN: Pre-PR gate (**clean-room**).** Verify no FAIL verdicts exist. All SCs PASS. **→ SC-1, SC-2, SC-3, SC-4, SC-5, SC-6**
- [ ] 18. **Post-GREEN: Audit (**clean-room**).** Dispatch verification-audit + cross-validate. Confirm all 6 SCs verified with correct evidence type (string). **→ SC-1, SC-2, SC-3, SC-4, SC-5, SC-6**
- [ ] 19. **Post-GREEN: Regression check (**clean-room**).** Run `ruff check`, `ruff format --check`, `pyright`, `pymarkdownlnt scan`, `mdformat --check` on changed files. **→ SC-1, SC-2, SC-3, SC-4, SC-5, SC-6**
- [ ] 20. **Post-GREEN: Review prep (**sub-agent**).** Prepare PR body with summary, outcome, fixes reference. **→ SC-1, SC-2, SC-3, SC-4, SC-5, SC-6**
- [ ] 21. **Post-GREEN: Create PR (**sub-agent**).** Create pull request. **→ SC-1, SC-2, SC-3, SC-4, SC-5, SC-6**
- [ ] 22. **Post-GREEN: Executive summary (**inline**).** Report final status — all 6 SCs PASS, PR created, files modified. **→ SC-1, SC-2, SC-3, SC-4, SC-5, SC-6**

#### Phase 1 VbC

- [ ] 23. **VbC (**clean-room**).** Verify all 6 SCs via grep on all 3 files. Confirm SC-1 (AGENTS.md "Prefer Built-ins"), SC-2 (080-code-standards.md "Prefer Built-ins"), SC-3 (060-tool-usage.md "bespoke"), SC-4 ("all work" or "global"), SC-5 (≥4 preferred alternatives listed), SC-6 ("feasibility" or "justification"). **→ SC-1, SC-2, SC-3, SC-4, SC-5, SC-6**

**Concern transition:** Single phase — no transition. Plan complete.

---

> **Compliance requirement:** This plan MUST be followed step-by-step. Every step MUST be completed in order. No step may be skipped, reordered, or combined. Each step's dispatch indicator MUST be respected — `(**sub-agent**)` steps MUST dispatch a sub-agent via `task()`, `(**clean-room**)` steps MUST dispatch with routing metadata only, `(**inline**)` steps MUST execute directly. Violating step ordering or dispatch discipline is a process-integrity failure.

> **Self-remediation protocol:** If any step fails, the agent MUST remediate before proceeding. Discard the failed step's output, diagnose root cause, fix, and re-execute. Do NOT skip the failed step or reclassify FAIL as PASS. If remediation fails after 2 attempts, report BLOCKED with root cause and HALT.

## Exit Criteria

- [ ] C1. SC-1 verified PASS — AGENTS.md contains "Prefer Built-ins" section with global mandate
- [ ] C2. SC-2 verified PASS — 080-code-standards.md contains "Prefer Built-ins" section with global mandate
- [ ] C3. SC-3 verified PASS — 060-tool-usage.md references "bespoke" in mandate context
- [ ] C4. SC-4 verified PASS — Mandate text applies globally ("all work" or "global")
- [ ] C5. SC-5 verified PASS — Mandate lists ≥4 preferred alternatives
- [ ] C6. SC-6 verified PASS — Mandate requires feasibility justification for new bespoke code
