---
title: Implementation Plan — Replace Research-First Mandate with Pre-Response Factual Claim Gate
issue: 1910
status: draft
created: 2026-07-12
license: MIT
provenance: AI-generated
---

## Overview

Replace two sections in `065-verification-honesty.md` with a single Pre-Response Factual Claim Gate procedure. Update anchor in `000-critical-rules.md`. Update content-verification test patterns in `test-verification-honesty.sh`.

**Authorization scope:** `for_pr` — plan auto-approved via cascade.

## Phase 1 — Text Replacement in 065-verification-honesty.md

| Step | Action | SC | Feasibility |
|------|--------|----|-------------|
| 1.1 | Replace lines 119-141 (Pre-Response Factual Claim Gate) with spec-defined replacement content | SC-1 | ✅ File exists at `.opencode/guidelines/065-verification-honesty.md` |
| 1.2 | Replace lines 202-204 (Proactive Verification section) with short cross-reference | SC-2 | ✅ Same file, verified by grep |

**Safety/Rollback:** No destructive operations — text replacement only. Rollback: `git checkout -- .opencode/guidelines/065-verification-honesty.md`.

## Phase 2 — Anchor Update in 000-critical-rules.md

| Step | Action | SC | Feasibility |
|------|--------|----|-------------|
| 2.1 | Update line 251 anchor from `"Proactive Verification"` to `"Pre-Response Factual Claim Gate"` | SC-3 | ✅ File exists at `.opencode/guidelines/000-critical-rules.md`; verified grep match at line 251 |

**Safety/Rollback:** No destructive operations. Rollback: `git checkout -- .opencode/guidelines/000-critical-rules.md`.

## Phase 3 — Test Pattern Updates

| Step | Action | SC | Feasibility |
|------|--------|----|-------------|
| 3.1 | Update `SC-003` grep pattern: `Research-First Mandate` → `Pre-Response Factual Claim Gate` | SC-4 | ✅ File exists at `.opencode/tests/test-verification-honesty.sh` |
| 3.2 | Update `SC-004` grep pattern: `Suggest-After-Research Fallback` → `Session-Scoped Verification` | SC-4 | ✅ Same file |
| 3.3 | Update `SC-005` grep pattern: `Standing Preference` → `Halt Condition` | SC-4 | ✅ Same file |
| 3.4 | Update `SC-006` grep patterns: `Research-First` → `Pre-Response Factual Claim Gate` (plugin checks) | SC-4 | ✅ Same file |
| 3.5 | Update `SC-007` grep patterns: `RESEARCH-FIRST RULE` → `Pre-Response Factual Claim Gate`; `suggest-after-research` → `Session-Scoped Verification` | SC-4 | ✅ Same file |
| 3.6 | Update `SC-008` grep patterns: `suggest-after-research` → `Session-Scoped Verification`; `exhaustive research` → `Pre-Response Factual Claim Gate` | SC-4 | ✅ Same file |
| 3.7 | Update behavioral scenario names and prompts to reference new section headers | SC-4 | ✅ Same file |

**Safety/Rollback:** No destructive operations. Rollback: `git checkout -- .opencode/tests/test-verification-honesty.sh`.

## SC-to-Step Traceability

| SC ID | Criterion | Phase | Step(s) |
|-------|-----------|-------|---------|
| SC-1 | Research-First Mandate replaced with Pre-Response Factual Claim Gate | 1 | 1.1 |
| SC-2 | Proactive Verification replaced with cross-reference | 1 | 1.2 |
| SC-3 | `000-critical-rules.md` anchor updated | 2 | 2.1 |
| SC-4 | Content-verification test patterns updated | 3 | 3.1–3.7 |
| SC-5 | No SC weakened or reclassified | All | N/A (anti-lobotomization invariant) |
| SC-6 | Plan file exists at `.opencode/.issues/1910/plan.md` | Pre | This file |

## Feasibility Verification

| Step | Reference | Verified? | Evidence |
|------|-----------|-----------|----------|
| 1.1 | `.opencode/guidelines/065-verification-honesty.md` | ✅ | `read` at offset 119 |
| 1.2 | `.opencode/guidelines/065-verification-honesty.md` line 202 | ✅ | `grep` for "Proactive Verification" |
| 2.1 | `.opencode/guidelines/000-critical-rules.md` line 251 | ✅ | `grep` for `065-verification-honesty.md` → "Proactive Verification" |
| 3.1–3.7 | `.opencode/tests/test-verification-honesty.sh` | ✅ | `glob` found file; `read` confirmed patterns |

## Post-Implementation Verification

- [ ] `grep -n "## Pre-Response Factual Claim Gate" .opencode/guidelines/065-verification-honesty.md` — returns line number
- [ ] `grep -n "Pre-Response Factual Claim Gate (above)" .opencode/guidelines/065-verification-honesty.md` — returns line number
- [ ] `grep -n "Pre-Response Factual Claim Gate" .opencode/guidelines/000-critical-rules.md` — returns line number
- [ ] `grep -n "Pre-Response Factual Claim Gate\|Session-Scoped Verification\|Halt Condition" .opencode/tests/test-verification-honesty.sh` — matches expected patterns
- [ ] `bash .opencode/tests/test-verification-honesty.sh --scenario guideline-no-unverified-tag` — passes
