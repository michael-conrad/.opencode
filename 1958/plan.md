# Implementation Plan — [#1958](https://github.com/michael-conrad/.opencode/issues/1958) — Canonical cross-reference format rollout

**Goal:** Replace all non-conforming cross-references in `.opencode/` with the canonical `Load [descriptive text](relative/path.md)` form.

**Files:**
- `.opencode/.issues/1958/plan.md` — This index
- `.opencode/.issues/1958/plan-01-discovery.md` — Phase 1: Discovery and inventory
- `.opencode/.issues/1958/plan-02-replacement.md` — Phase 2: Replace all non-conforming references
- `.opencode/.issues/1958/plan-03-close.md` — Phase 3: Close and inform
- `.opencode/.issues/1958/data/cross-reference-inventory.yaml` — Phase 1 output

## Blast Radius

- `.opencode/guidelines/*.md` — All 34 guideline files
- `.opencode/skills/*/SKILL.md` — All 59 SKILL.md files
- `.opencode/skills/*/tasks/*.md` — All task files
- `.opencode/prompts/default.txt` — Cross-reference directive
- `.opencode/scripts/*.py` — May contain cross-references in docstrings

## Phase Table

| Phase | Name | Concern | SCs | Dependencies | Step Range | Dispatch |
|-------|------|---------|-----|-------------|------------|----------|
| 1 | Discovery and Inventory | Scan all files, classify cross-references, output inventory YAML | SC-1 | None | 1.1–1.5 | Inline sub-agent |
| 2 | Replace All Non-Conforming References | Convert every reference to canonical Load[text](path) form | SC-2, SC-3, SC-4, SC-5, SC-6, SC-7 | Phase 1 complete | 2.1–2.7 | Inline sub-agent |
| 3 | Close and Inform | Close #1953, comment on #1925 and #1926 | SC-8, SC-9 | Phase 2 complete | 3.1–3.3 | Inline sub-agent |

## SC-to-Step Traceability

| SC ID | Criterion | Phase | Step(s) |
|-------|-----------|-------|---------|
| SC-1 | Cross-reference inventory produced | 1 | 1.5 |
| SC-2 | 000-critical-rules.md updated to Load[Text](path) | 2 | 2.1 |
| SC-3 | No See[ or Read[ in any SKILL.md | 2 | 2.2 |
| SC-4 | No See[ or Read[ in any guideline | 2 | 2.3 |
| SC-5 | No §N or §Name bare references in any SKILL.md | 2 | 2.4 |
| SC-6 | No resolution table patterns in any SKILL.md | 2 | 2.5 |
| SC-7 | No non-linked text references in any SKILL.md | 2 | 2.6 |
| SC-8 | #1953 closed as superseded | 3 | 3.1 |
| SC-9 | #1925 and #1926 have comments linking to this spec | 3 | 3.2, 3.3 |

## Safety/Rollback Considerations

**Phase 1 — Safety/Rollback:**
- Destructive operations: None (read-only scan)
- Rollback plan: N/A
- Data loss risk: None

**Phase 2 — Safety/Rollback:**
- Destructive operations: File edits to guidelines, SKILL.md, task files, default.txt
- Rollback plan: `git checkout .opencode/guidelines/ .opencode/skills/ .opencode/prompts/` to restore originals
- Data loss risk: Low (all changes are text replacements; git preserves history)

**Phase 3 — Safety/Rollback:**
- Destructive operations: Issue closure (irreversible)
- Rollback plan: Reopen #1953 if closed in error
- Data loss risk: Low

## Feasibility Verification

| Step | Reference | Verified? | Evidence |
|------|-----------|-----------|----------|
| 1.1 | `.opencode/guidelines/` directory | ✅ | `ls` |
| 1.2 | `.opencode/skills/*/SKILL.md` files | ✅ | `find` |
| 1.3 | `.opencode/skills/*/tasks/*.md` files | ✅ | `find` |
| 1.4 | `.opencode/prompts/default.txt` | ✅ | `ls` |
| 2.1 | `000-critical-rules.md` | ✅ | `ls` |
| 2.2 | SKILL.md files | ✅ | `find` |
| 2.3 | Guideline files | ✅ | `ls` |
| 2.4 | Task files | ✅ | `find` |
| 2.5 | `default.txt` | ✅ | `ls` |
| 3.1 | Issue #1953 | ✅ | GitHub API |
| 3.2 | Issue #1925 | ✅ | GitHub API |
| 3.3 | Issue #1926 | ✅ | GitHub API |

## Evidence/Provenance

| Claim | Evidence Source | Verified? |
|-------|----------------|----------|
| 34 guideline files exist | `find .opencode/guidelines/ -name '*.md' \| wc -l` | ✅ |
| 59 SKILL.md files exist | `find .opencode/skills/ -name 'SKILL.md' \| wc -l` | ✅ |
| Task files exist | `find .opencode/skills/ -path '*/tasks/*.md' \| wc -l` | ✅ |
| default.txt exists | `ls .opencode/prompts/default.txt` | ✅ |
| #1953 exists | `github_issue_read` | ✅ |
| #1925 exists | `github_issue_read` | ✅ |
| #1926 exists | `github_issue_read` | ✅ |

## Exit Criteria

- [ ] C1: Phase 1 complete — cross-reference inventory produced at `.opencode/.issues/1958/data/cross-reference-inventory.yaml`
- [ ] C2: Phase 2 complete — all non-conforming references replaced with canonical `Load [text](path)` form
- [ ] C3: Phase 3 complete — #1953 closed, #1925 and #1926 have comments
- [ ] C4: All SCs verified PASS
- [ ] C5: No SC weakened, deferred, or reclassified
- [ ] C6: Behavioral enforcement tests written and confirmed RED before implementation changes
