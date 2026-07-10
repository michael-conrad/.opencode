**STATUS:** DRAFT

**CREATED:** 2026-07-09

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Intent and Executive Summary

| Field | Value |
|-------|-------|
| Problem Statement | The spec-creation skill and its task files are missing several critical quality mandates that cause downstream defects: no research card consultation mandate, no live documentation URL verification, no interdependency checking, weak SC-fail cascading language, no anti-lobotomization language in the spec body template, a "simple specs may skip" escape hatch, contract file naming drift, and missing #1063 pipeline enforcement gates. |
| Root Cause / Motivation | These gaps were introduced incrementally as the spec-creation skill evolved. Each gap represents a quality gate that was never formalized as a mandatory pipeline step. The cumulative effect is that agents produce specs with unverified claims, conflicting interdependencies, and no protection against test lobotomization. |
| Approach Chosen | Mandate all nine fixes as mandatory pipeline gates with behavioral enforcement. Each fix is a discrete phase with its own success criteria. The spec body template in create.md is the primary target — it receives new mandatory preamble sections, a mandatory interdependency section, and mandatory live documentation URL verification. |
| Alternatives Considered & Why Discarded | (1) Fix only the escape hatch and defer the rest — discarded because the gaps are interdependent; fixing one without the others leaves quality holes. (2) Create separate specs for each gap — discarded because the changes all touch the same files and would create merge conflicts if implemented independently. |
| Key Design Decisions | All sections mandatory (no tier-based skipping). Research card consultation is a pipeline gate. Live documentation URLs are verified. Interdependency marking is bidirectional. SC-fail cascading and anti-lobotomization are preamble sections in every generated spec. Contract files renamed to match task name. |

## Problem

The spec-creation skill and its task files are missing several critical quality mandates that cause downstream defects:

1. **No research card consultation mandate** — Agents write specs without checking existing research findings, producing specs that duplicate or contradict known information
2. **No live documentation URL verification** — "Documentation Sources" is a template, not a mandatory verification step; URLs may be stale or broken
3. **No interdependency checking** — Agents don't check for overlapping/conflicting open specs before writing, producing specs that conflict with in-flight work
4. **SC-fail cascading statement is too weak** — Current "all-or-nothing gate" lacks the strong language needed to prevent agents from soft-passing failures
5. **No anti-lobotomization language in spec body template** — Agents can weaken tests without the spec explicitly forbidding it
6. **"Simple specs may skip" escape hatch still present (issue #1552)** — Allows agents to skip quality gates
7. **Contract file naming drift** — Task renamed to `create` but contract files still use `write-` prefix (issue #1703 gap)
8. **Missing #1063 pipeline enforcement gates** — Anti-merge gates, doc-source-currency check, SC-ID traceability not implemented
9. **Issues #1229 and #1064 appear fully implemented but remain OPEN** — Need verification and closure

## Scope

**In scope:**
- Remove "simple specs may skip" language from create.md and replace with mandatory-all-sections
- Add research card consultation step to operating-protocol.md and requirements.md
- Add live documentation URL verification to create.md
- Add interdependency checking and marking to operating-protocol.md and create.md
- Strengthen SC-fail cascading statement in create.md spec body template
- Add anti-lobotomization language to create.md spec body template
- Rename contract files from write-* to create-* and update all references
- Add anti-merge gate, doc-source-currency check, and SC-ID traceability to create.md
- Verify and close #1229 and #1064
- Create research card for spec-creation skill state

**Out of scope:**
- Changes to other skills' task files
- Changes to guideline files outside the spec-creation skill
- New behavioral enforcement tests (these are written during implementation, per the post-approval spec mandate)

## Approach

This spec mandates nine fixes to the spec-creation skill as mandatory pipeline gates. Each fix is a discrete phase with its own success criteria. The fixes are applied to the task files (create.md, operating-protocol.md, requirements.md), contract files, and SKILL.md. The spec body template in create.md is the primary target — it receives new mandatory preamble sections (SC-fail cascading, anti-lobotomization), a mandatory interdependency section, and mandatory live documentation URL verification. The "simple specs may skip" escape hatch is removed entirely. Contract files are renamed to match the task name. Stale open issues are verified and closed.

## Affected Files

| File | Change |
|------|--------|
| `.opencode/skills/spec-creation/tasks/create.md` | Primary target — remove escape hatch, add preamble sections, add interdependency section, add live URL verification, add #1063 gates |
| `.opencode/skills/spec-creation/tasks/operating-protocol.md` | Add research card consultation step, add interdependency checking step, update contract references |
| `.opencode/skills/spec-creation/tasks/requirements.md` | Add research card check |
| `.opencode/skills/spec-creation/contracts/write-input-template.yaml` | Rename to create-input-template.yaml |
| `.opencode/skills/spec-creation/contracts/write-output-template.yaml` | Rename to create-output-template.yaml |
| `.opencode/skills/spec-creation/SKILL.md` | Update contract references |
| `.opencode/.issues/research-cards/spec-creation-state.md` | Create new research card |

## Interdependency

| Issue | Classification | Description |
|-------|---------------|-------------|
| [#1552](https://github.com/michael-conrad/.opencode/issues/1552) | SUPERSEDES | Remove 'simple specs may skip' complexity classification escape hatch — subsumed by Phase 1 |
| [#1229](https://github.com/michael-conrad/.opencode/issues/1229) | SUPERSEDES | Post-SC uplift check — verify completeness, close if done — subsumed by Phase 9 |
| [#1063](https://github.com/michael-conrad/.opencode/issues/1063) | SUPERSEDES | Anti-merge gates, doc-source-currency, SC-ID traceability — subsumed by Phase 8 |
| [#1703](https://github.com/michael-conrad/.opencode/issues/1703) | SUPERSEDES | Contract file naming drift (write→create) — subsumed by Phase 7 |
| [#1673](https://github.com/michael-conrad/.opencode/issues/1673) | RELATED | Foundation already shipped (trigger phrases, dispatch table, create task, uplift check) |
| [#1605](https://github.com/michael-conrad/.opencode/issues/1605) | RELATED | Pipeline-readiness-gate already positioned |
| [#1060](https://github.com/michael-conrad/.opencode/issues/1060) | RELATED | SC table columns, preamble sections already implemented |
| [#1061](https://github.com/michael-conrad/.opencode/issues/1061) | RELATED | Artifact infrastructure already implemented |
| [#1062](https://github.com/michael-conrad/.opencode/issues/1062) | RELATED | Handoff gates already implemented |
| [#1064](https://github.com/michael-conrad/.opencode/issues/1064) | RELATED | Writing-plans consumer awareness — appears implemented, verify and close (Phase 9) |
| [#850](https://github.com/michael-conrad/.opencode/issues/850) | RELATED | Parent coordination (dependency chain ordering) |

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Direct source search | `srclight_search_symbols("spec-creation")` | Identify spec-creation skill structure |
| Direct source search | Read `.opencode/skills/spec-creation/tasks/create.md` | Understand current spec body template and pipeline steps |
| Direct source search | Read `.opencode/skills/spec-creation/tasks/operating-protocol.md` | Understand pipeline step ordering and contract paths |
| Direct source search | Read `.opencode/skills/spec-creation/SKILL.md` | Understand skill dispatch table and invocation |
| Documentation URLs | [080-code-standards.md](https://github.com/michael-conrad/.opencode/blob/main/guidelines/080-code-standards.md) | Reference Test Integrity Mandate and Evidence Type Taxonomy |
| Documentation URLs | [065-verification-honesty.md](https://github.com/michael-conrad/.opencode/blob/main/guidelines/065-verification-honesty.md) | Reference Cost Model and Hard Failure Discipline |
| Documentation URLs | [020-go-prohibitions.md](https://github.com/michael-conrad/.opencode/blob/main/guidelines/020-go-prohibitions.md) | Reference research card catalogue mandate |
| Live verification | `github_issue_read(method=get, issue_number=1552)` | Verify #1552 is open and describes escape hatch |
| Live verification | `github_issue_read(method=get, issue_number=1229)` | Verify #1229 state for Phase 9 closure |
| Live verification | `github_issue_read(method=get, issue_number=1064)` | Verify #1064 state for Phase 9 closure |

## Phases

### Phase 1: Remove Complexity Escape Hatch (#1552)
- Remove "Simple specs may skip this section" language from create.md
- Remove minimal/standard/complex tiered structure
- Replace with: all sections are mandatory, no tier-based skipping
- Remove "Skip areas that don't apply to simple specs" language

### Phase 2: Add Research Card Consultation Mandate
- Add step to operating-protocol.md: before requirements extraction, consult `.issues/research-cards/`
- Add step to requirements.md: check research cards for existing findings on the topic
- Add step to create.md: include research card references in spec body
- Create a research card for spec-creation itself documenting current state

### Phase 3: Add Live Documentation URL Verification
- Add mandatory step to create.md: verify all documentation source URLs are live
- Add to spec body template: Documentation Sources section must include verified live URLs
- Add verification substep: each URL must be confirmed reachable before spec is complete
- Prefer online (live) documentation over local; local is fallback only

### Phase 4: Add Interdependency Checking and Marking
- Add step to operating-protocol.md: before create, check for overlapping/conflicting open specs
- Add to create.md: Interdependency section in spec body listing related issues with classification
- Classification: BLOCKS, BLOCKED_BY, RELATED, SUPERSEDES, SUPERSEDED_BY
- Mark interdependencies explicitly in both this spec and the interdependent issues

### Phase 5: Strengthen SC-Fail Cascading Statement
- Replace current "all-or-nothing gate" with stronger language in create.md spec body template
- Exact language: "Any SC that is skipped, deferred, weakened, or otherwise bypassed marks ALL SCs as FAIL. A PR containing any such bypass MUST be immediately rejected and trashed as defective and unusable. There is no partial credit. There is no 'close enough.' 100% clean PASS on ALL SCs is the only acceptable outcome."
- Add this as a mandatory preamble section in every generated spec

### Phase 6: Add Anti-Lobotomization Language
- Add to create.md spec body template: explicit anti-lobotomization section
- Reference `080-code-standards.md` Test Integrity Mandate
- Language: "Tests MUST NOT be lobotomized. Removing or weakening a behavioral test assertion to work around a timeout, failure, or infrastructure issue is a CRITICAL VIOLATION. SCs must achieve 100% clean PASS. No SC may be weakened, deferred, or reclassified to a lower evidence type to evade implementation."
- Add SC in every spec that explicitly forbids test lobotomization

### Phase 7: Fix Contract File Naming Drift
- Rename `contracts/write-input-template.yaml` → `contracts/create-input-template.yaml`
- Rename `contracts/write-output-template.yaml` → `contracts/create-output-template.yaml`
- Update all references in operating-protocol.md, create.md, and SKILL.md

### Phase 8: Add Missing #1063 Pipeline Enforcement Gates
- Add anti-merge gate to create.md: verify no SC conflicts with already-merged specs
- Add doc-source-currency check: verify all documentation sources are current (not stale)
- Add SC-ID traceability: verify every SC ID maps to a unique, traceable requirement

### Phase 9: Verify and Close Stale Open Issues
- Verify #1229 implementation is complete → close if so
- Verify #1064 implementation is complete → close if so
- Document verification evidence

### Phase 10: Create Research Card
- Create `.opencode/.issues/research-cards/spec-creation-state.md` documenting:
  - Current state of spec-creation skill
  - Known defects and their status
  - Interdependency map
  - This fix spec's scope

## Key Design Decisions

| DEC-ID | Decision | Rationale | Requirement Key | Affected SCs |
|--------|----------|-----------|-----------------|--------------|
| DEC-1 | All sections in spec body template become mandatory | No tier-based skipping — every section is required regardless of spec complexity | MUST | SC-1, SC-2 |
| DEC-2 | Research card consultation is a pipeline gate | Not optional — agents MUST check research cards before writing specs | MUST | SC-3, SC-4 |
| DEC-3 | Live documentation URLs are verified, not just listed | Each URL must be confirmed reachable; local docs are fallback only | MUST | SC-5, SC-6 |
| DEC-4 | Interdependency marking is bidirectional | Both this spec and interdependent issues are marked | MUST | SC-7, SC-8 |
| DEC-5 | SC-fail cascading is a preamble section in every generated spec | Embedded in every generated spec, not just a task file instruction | MUST | SC-9 |
| DEC-6 | Anti-lobotomization is a preamble section in every generated spec | Embedded in every generated spec with an SC that explicitly forbids test lobotomization | MUST | SC-10, SC-11 |
| DEC-7 | Contract files renamed to match task name | write-* → create-* to eliminate naming drift | MUST | SC-12 |

## Regression Invariants

- [ ] 1. Existing spec-creation pipeline steps MUST continue to function after changes
- [ ] 2. Existing contract file consumers MUST be updated to reference new names
- [ ] 3. Existing specs created before this change MUST remain valid and readable
- [ ] 4. The `issue-operations` integration MUST continue to work unchanged

## Success Criteria

**SC-Fail Cascading Preamble:** Any SC that is skipped, deferred, weakened, or otherwise bypassed marks ALL SCs as FAIL. A PR containing any such bypass MUST be immediately rejected and trashed as defective and unusable. There is no partial credit. There is no 'close enough.' 100% clean PASS on ALL SCs is the only acceptable outcome.

**Anti-Lobotomization Preamble:** Tests MUST NOT be lobotomized. Removing or weakening a behavioral test assertion to work around a timeout, failure, or infrastructure issue is a CRITICAL VIOLATION. SCs must achieve 100% clean PASS. No SC may be weakened, deferred, or reclassified to a lower evidence type to evade implementation. See `080-code-standards.md` Test Integrity Mandate.

| ID | Criterion | Evidence Type | Verification Method | Remediation | Pipeline Step Binding | Artifact Path | Requirement Traceability | Phase Binding | Verification Gate | Integration Mode | Affinity Group | Re-Entry Step | Test File | Phase Mapping |
|----|-----------|--------------|---------------------|-------------|----------------------|--------------|-------------------------|--------------|-----------------|----------------|--------------|-------------|-----------|--------------|
| SC-1 | "Simple specs may skip" language removed from create.md; all sections mandatory | `string` | `grep -r "simple specs may skip\|Skip areas that don't apply" .opencode/skills/spec-creation/tasks/create.md` returns no matches | Restore removal if grep finds matches | create | `.issues/1834/` | Phase 1 — Remove escape hatch | Phase 1 | pre-commit | standalone | phase-1 | create | — | Phase 1 |
| SC-2 | No minimal/standard/complex tiered structure remains in create.md | `string` | `grep -r "Minimal specs\|Standard specs\|Complex specs" .opencode/skills/spec-creation/tasks/create.md` returns no matches | Restore removal if grep finds matches | create | `.issues/1834/` | Phase 1 — Remove tiered structure | Phase 1 | pre-commit | standalone | phase-1 | create | — | Phase 1 |
| SC-3 | Research card consultation step added to operating-protocol.md before requirements extraction | `string` | `grep "research-cards\|research card" .opencode/skills/spec-creation/tasks/operating-protocol.md` returns matches | Add step if missing | create | `.issues/1834/` | Phase 2 — Research card in operating protocol | Phase 2 | pre-commit | standalone | phase-2 | create | — | Phase 2 |
| SC-4 | Research card check added to requirements.md | `string` | `grep "research-cards\|research card" .opencode/skills/spec-creation/tasks/requirements.md` returns matches | Add check if missing | create | `.issues/1834/` | Phase 2 — Research card in requirements | Phase 2 | pre-commit | standalone | phase-2 | create | — | Phase 2 |
| SC-5 | Live documentation URL verification step added to create.md | `string` | `grep "verify.*URL.*live\|URL.*reachable\|live.*documentation" .opencode/skills/spec-creation/tasks/create.md` returns matches | Add step if missing | create | `.issues/1834/` | Phase 3 — Live URL verification | Phase 3 | pre-commit | standalone | phase-3 | create | — | Phase 3 |
| SC-6 | Documentation Sources section in spec body template mandates verified live URLs | `string` | `grep "verified live URL\|URL must be confirmed reachable\|prefer online" .opencode/skills/spec-creation/tasks/create.md` returns matches | Add mandate if missing | create | `.issues/1834/` | Phase 3 — Live URL mandate in template | Phase 3 | pre-commit | standalone | phase-3 | create | — | Phase 3 |
| SC-7 | Interdependency checking step added to operating-protocol.md before create | `string` | `grep "interdependency\|overlapping\|conflicting.*spec" .opencode/skills/spec-creation/tasks/operating-protocol.md` returns matches | Add step if missing | create | `.issues/1834/` | Phase 4 — Interdependency in operating protocol | Phase 4 | pre-commit | standalone | phase-4 | create | — | Phase 4 |
| SC-8 | Interdependency section with classification (BLOCKS, BLOCKED_BY, RELATED, SUPERSEDES, SUPERSEDED_BY) added to create.md spec body template | `string` | `grep "BLOCKS\|BLOCKED_BY\|SUPERSEDES\|SUPERSEDED_BY\|Interdependency" .opencode/skills/spec-creation/tasks/create.md` returns matches | Add section if missing | create | `.issues/1834/` | Phase 4 — Interdependency in spec template | Phase 4 | pre-commit | standalone | phase-4 | create | — | Phase 4 |
| SC-9 | SC-fail cascading preamble with exact strong language added to create.md spec body template | `string` | `grep "Any SC that is skipped, deferred, weakened.*marks ALL SCs as FAIL" .opencode/skills/spec-creation/tasks/create.md` returns matches | Add preamble if missing | create | `.issues/1834/` | Phase 5 — SC-fail cascading preamble | Phase 5 | pre-commit | standalone | phase-5 | create | — | Phase 5 |
| SC-10 | Anti-lobotomization preamble section added to create.md spec body template | `string` | `grep "Tests MUST NOT be lobotomized\|CRITICAL VIOLATION.*lobotomiz" .opencode/skills/spec-creation/tasks/create.md` returns matches | Add preamble if missing | create | `.issues/1834/` | Phase 6 — Anti-lobotomization preamble | Phase 6 | pre-commit | standalone | phase-6 | create | — | Phase 6 |
| SC-11 | Anti-lobotomization SC added to spec body template that explicitly forbids test lobotomization | `string` | `grep "SC.*lobotom\|anti-lobotomization SC\|forbids test lobotomization" .opencode/skills/spec-creation/tasks/create.md` returns matches | Add SC if missing | create | `.issues/1834/` | Phase 6 — Anti-lobotomization SC in template | Phase 6 | pre-commit | standalone | phase-6 | create | — | Phase 6 |
| SC-12 | Contract files renamed from write-* to create-* and all references updated | `string` | `ls .opencode/skills/spec-creation/contracts/create-input-template.yaml` exists AND `ls .opencode/skills/spec-creation/contracts/create-output-template.yaml` exists AND `grep "write-input-template\|write-output-template" .opencode/skills/spec-creation/` returns no matches | Rename files and update references if mismatch | create | `.issues/1834/` | Phase 7 — Contract file rename | Phase 7 | pre-commit | standalone | phase-7 | create | — | Phase 7 |
| SC-13 | Anti-merge gate added to create.md: verify no SC conflicts with already-merged specs | `string` | `grep "anti-merge\|merged.*spec.*conflict\|SC.*conflict.*merged" .opencode/skills/spec-creation/tasks/create.md` returns matches | Add gate if missing | create | `.issues/1834/` | Phase 8 — Anti-merge gate | Phase 8 | pre-commit | standalone | phase-8 | create | — | Phase 8 |
| SC-14 | Doc-source-currency check added to create.md: verify all documentation sources are current | `string` | `grep "doc-source-currency\|documentation.*source.*current\|source.*currency\|stale.*documentation" .opencode/skills/spec-creation/tasks/create.md` returns matches | Add check if missing | create | `.issues/1834/` | Phase 8 — Doc-source-currency | Phase 8 | pre-commit | standalone | phase-8 | create | — | Phase 8 |
| SC-15 | SC-ID traceability added to create.md: verify every SC ID maps to a unique, traceable requirement | `string` | `grep "SC-ID.*traceability\|SC.*ID.*unique\|traceable.*requirement" .opencode/skills/spec-creation/tasks/create.md` returns matches | Add traceability if missing | create | `.issues/1834/` | Phase 8 — SC-ID traceability | Phase 8 | pre-commit | standalone | phase-8 | create | — | Phase 8 |
| SC-16 | #1229 verified as fully implemented and closed | `behavioral` | `github_issue_read(method=get, issue_number=1229)` → verify state is closed AND implementation evidence exists in issue body/comments | Re-verify and document evidence if still open | create | `.issues/1834/` | Phase 9 — Verify #1229 | Phase 9 | pre-approval-gate | standalone | phase-9 | create | — | Phase 9 |
| SC-17 | #1064 verified as fully implemented and closed | `behavioral` | `github_issue_read(method=get, issue_number=1064)` → verify state is closed AND implementation evidence exists in issue body/comments | Re-verify and document evidence if still open | create | `.issues/1834/` | Phase 9 — Verify #1064 | Phase 9 | pre-approval-gate | standalone | phase-9 | create | — | Phase 9 |
| SC-18 | Research card created at `.opencode/.issues/research-cards/spec-creation-state.md` with current state, known defects, interdependency map, and fix spec scope | `string` | `ls .opencode/.issues/research-cards/spec-creation-state.md` exists AND file is non-empty | Create card if missing | create | `.issues/1834/` | Phase 10 — Research card | Phase 10 | pre-commit | standalone | phase-10 | create | — | Phase 10 |
| SC-19 | Before any implementation, write behavioral enforcement tests in `.opencode/tests/behaviors/` that verify the new rules; confirm RED state (test fails before change) | `behavioral` | `bash .opencode/tests/behaviors/<scenario>.sh` → FAIL before implementation, PASS after | Re-create tests if missing from working tree | create | `.issues/1834/behavioral/` | Behavioral test mandate | All phases | pre-red | standalone | cross-cutting | pre-red | — | All phases |
| SC-20 | No SC may be weakened, deferred, or reclassified to a lower evidence type to evade implementation | `behavioral` | Spec-auditor SC-DET check → no SC has evidence type lower than substrate classification requires | Remediate misclassified SCs | create | `.issues/1834/` | Anti-lobotomization enforcement | All phases | pre-approval-gate | standalone | cross-cutting | create | — | All phases |

**Cross-Cutting SCs:** SC-19, SC-20
— Verified once in Phase 1, applies to all subsequent phases.

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

After this spec is approved, invoke `writing-plans` to create `.issues/1834/plan.md` before implementation begins.

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)
