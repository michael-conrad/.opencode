<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: Derived from majiayu000/claude-skill-registry (MIT) -->

# Task: checklist

## Purpose

Quality gates for each TDD cycle phase. Pre-cycle readiness, RED correctness, GREEN minimality, REFACTOR safety. Timing and step-size guides prevent Too-Big Step and Forgotten Red.

## Pre-Cycle Checklist

Before starting a TDD cycle:

- [ ] Spec/requirement is clear and unambiguous
- [ ] One specific behavior identified (not a feature bundle)
- [ ] Success criterion is testable (binary PASS/FAIL)
- [ ] Correct TDD pattern selected (Straight-Red, Triangulation, Obvious Implementation, One-to-Many)
- [ ] Test file exists or creation path is known
- [ ] Test runner configured and working (`uv run pytest` or equivalent)

## RED Checklist

- [ ] Test name follows convention: `test_<function>_<behavior>_<condition>`
- [ ] One assertion per test concept
- [ ] Test makes no assumptions about implementation
- [ ] Test correctly expresses the spec (not the implementation)
- [ ] RED is a separate phase — no GREEN work started
- [ ] **RUN THE TEST — confirm FAIL or ERROR**
- [ ] Evidence of failure captured (tool call output)

## GREEN Checklist

- [ ] Minimal implementation — only what's needed to pass
- [ ] No speculative code (no "we might need this later")
- [ ] No premature optimization
- [ ] No new features beyond what the test requires
- [ ] GREEN is a separate phase — RED was completed and confirmed FAIL before GREEN began
- [ ] **RUN THE TEST — confirm PASS**
- [ ] All previously passing tests still pass (`uv run pytest test/ -v`)

## REFACTOR Checklist

- [ ] Tests stay GREEN throughout (run after each refactor step)
- [ ] One refactor at a time — don't batch changes
- [ ] No behavior changes (structure only)
- [ ] If test breaks: REVERT and try different approach
- [ ] Code smells addressed (duplication, long methods, unclear names)
- [ ] **Final run: all tests PASS**

## Timing Guide

| Phase | Target Duration | Max | Alarm |
|-------|----------------|-----|-------|
| RED | 30s - 2min | 5min | If >5min, test is too big → decompose |
| GREEN | 30s - 3min | 5min | If >5min, step is too big → smaller test |
| REFACTOR | 1 - 3min | 5min | If >5min, too many changes → one at a time |
| Full cycle | 2 - 8min | 15min | If >15min, cycle is too big → split |

## Step-Size Guide

| Step Size | RED Duration | GREEN Duration | Pattern | When Appropriate |
|-----------|-------------|----------------|---------|-----------------|
| Micro | 30s | 30s | Obvious Impl | Trivial one-liners |
| Small | 1-2min | 1-3min | Straight-Red | Most cases |
| Medium | 2-5min | 2-5min | Triangulation | Complex but decomposable |
| Large | >5min | >5min | 🚫 | **Decompose first** |

## Context Required

- Related skills: `test-driven-development` (parent skill)
- Related tasks: `red`, `green`, `refactor`, `patterns`
