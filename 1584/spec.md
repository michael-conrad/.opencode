## Purpose

Non-blocking reference map of file overlaps and ordering concerns between open `.opencode` issues. This is analysis only — no spec depends on another. Merge conflicts are resolved at implementation time.

## Closed (removed from open set)

| Issue | Reason | Superseded By |
|-------|--------|---------------|
| #1545 | Duplicate of #1544 | #1544 |
| #1469 | Superseded by SPEC-FIX | #1512 |
| #1405 | Superseded by BUG report | #1401 |
| #1548 | Superseded by broader SKILL-FIX | #1565 |
| #1375 | Superseded by comprehensive SPEC-FIX | #1394 |

## File-Overlap Groups (same files, different concerns)

### Group A: SKILL.md dispatch gate enforcement

| Issue | Concern | Files Touched |
|-------|---------|---------------|
| #1561 | Remove dead `unless` clause from 37 SKILL.md files | 37 SKILL.md files (text-only) |
| #1407 | Restructure SKILL.md to routing-only (Phase 2: audit all 39) | All 39 SKILL.md files |
| #1406 | Add runtime watchdog + pre-commit hook for inline-work detection | session-enforcement.ts, pre-commit hook, auto-dispatch.md |

**Overlap:** #1561 and #1407 both modify the same 37 SKILL.md files. #1561 is text-only (remove a clause). #1407 is structural (move procedure content to tasks/). These are independent edits — merge conflicts are normal and resolvable.

### Group B: Skill restructuring trio

| Issue | Concern | Files Touched |
|-------|---------|---------------|
| #1560 | Restructure spec-creation skill | spec-creation/SKILL.md + its task files |
| #1559 | Restructure implementation-pipeline skill | implementation-pipeline/SKILL.md + its task files |
| #1558 | Restructure writing-plans skill | writing-plans/SKILL.md + its task files |

**Overlap:** None — each modifies a different skill directory. No shared files.

### Group C: writing-plans contract references

| Issue | Concern | Files Touched |
|-------|---------|---------------|
| #1565 | Verify all 24 contract templates resolve | writing-plans/tasks/ (verification only) |
| #1564 | Add missing dispatch table entries | writing-plans/SKILL.md |
| #1562 | Restructure 21-step pipeline for hard limit | writing-plans/tasks/ |

**Overlap:** All three touch writing-plans files. #1565 is verification-only (no edits). #1564 and #1562 modify different sections (SKILL.md vs task files).

### Group D: Escape hatch removal series

| Issue | Concern |
|-------|---------|
| #1556 | Remove provenance degradation escape hatch in git-workflow |
| #1555 | Remove auditor-unavailable bypass in adversarial-audit |
| #1554 | Remove RED-phase bypass escape hatch |
| #1553 | Remove git hook bypass in critical-rules |
| #1552 | Remove complexity-classification escape hatch in spec-creation |
| #1551 | Remove documentation-sources escape hatch in verification-enforcement |
| #1550 | Remove simple-fixes escape hatch in brainstorming |
| #1549 | Remove issue-operations routing bypass fallback |

**Overlap:** Each modifies a different skill. No shared files.

### Group E: Skill description compliance (19 issues)

| Issue | Skill |
|-------|-------|
| #1535 | writing-plans |
| #1534 | verification |
| #1533 | verification-enforcement |
| #1532 | verification-before-completion |
| #1531 | test-driven-development |
| #1530 | systematic-debugging |
| #1529 | sync-guidelines |
| #1528 | sre-runbook |
| #1527 | spec-creation |
| #1526 | solve |
| #1525 | skill-creator |
| #1524 | research |
| #1523 | researcher |
| #1522 | pre-analysis |
| #1521 | pr-creation-workflow |
| #1520 | playwright-cli |
| #1519 | issue-review |
| #1518 | issue-operations |
| #1517 | implementation-pipeline |

**Overlap:** Each modifies a different SKILL.md description. No shared files.

## Independent Issues (no file overlap with any other open issue)

- #1582 — spec-creation/plan-writer/auditor skills (systemic defects)
- #1580 — release PR routing bug
- #1579 — plan writer step status injection
- #1578 — playwright-cli YAML parse error
- #1577 — pre-commit Gate 2a blocks commits
- #1576 — local-issues link --help error
- #1575 — solve tool missing
- #1574 — local-issues create flags ignored
- #1573 — writing-plans missing task files
- #1572 — playwright-cli YAML frontmatter
- #1571 — content-verification checks MISSING
- #1570 — skill-invocation scenarios fail
- #1569 — EXPECTED_SKILLS array missing scenarios
- #1568 — mandatory bug reports for regression failures
- #1567 — cross-validate evidence type gate false-positive
- #1563 — fix critical-rules-044 symbolic conditions
- #1561 — remove dead unless clause (see Group A)
- #1560, #1559, #1558 — skill restructuring (see Group B)
- #1556–#1549 — escape hatch removal (see Group D)
- #1540 — single-path branch workflow
- #1539 — SearXNG MCP investigation
- #1538 — missing label application
- #1537 — submodule pointer bumps
- #1535–#1517 — skill description compliance (see Group E)
- #1516 — local: NO_TDT
- #1515 — github-mcp: NO_TDT
- #1514 — gitbucket-api: NO_TDT
- #1513 — git-workflow: description omits TDT items
- #1512 — completion-core description fix
- #1462 — writing-plans plan tool domain boundaries
- #1461 — writing-plans Z3 contract verification
- #1460 — solve tool --output json
- #1459 — writing-plans format compliance
- #1458 — artifact URL worktree path
- #1453 — phantom Z3 check steps
- #1452 — clean-room plan generator overwrite
- #1450 — update default model
- #1448 — orchestrator bypasses cross-validate FAIL
- #1447 — plan phase structure inconsistency
- #1445 — git-workflow submodule sync verification
- #1444 — Phase 2: create.md Z3 enforcement
- #1443 — Phase 1: auditor task file template fixes
- #1441 — git cleanup hard-gate dependency
- #1440 — implementation pipeline submodule sync
- #1439 — local-issues spec_path wrong
- #1436 — plan-fidelity auditor hard-codes criteria
- #1432 — mandatory spec-provenance gate
- #1421 — gap-fill cascade state-verification
- #1417 — self-detection gate
- #1415 — verify-already-implemented gate
- #1411 — flock timeout + dead docs
- #1408 — skill-creator validation
- #1407 — structural dispatch-gate enforcement (see Group A)
- #1406 — orchestrator bypass prevention (see Group A)
- #1401 — verification-audit pre-flight gate
- #1399 — remove skip/optional language
- #1398 — fix spec-creation SKILL.md
- #1395 — remove dead JSONC configs
- #1394 — deny glob tool (see Group A)
- #1384 — skill card description audit
- #1379 — implementation-pipeline prose exception
- #1378 — evidence type classification gate
- #1374 — writing-plans hardcodes step sequence
- #1370 — env-loader named export

---

🤖 OpenCode (deepseek-v4-flash) ✅ analysis preserved