---
number: 2314
title: "[BUG] Spec-creation → implementation can bypass writing-plans pipeline when spec contains SCs and affected files"
status: open
labels: []
created: 2026-08-21T02:09:25Z
updated: 2026-08-21T02:09:25Z
remote_issue: 2314
remote_url: "https://github.com/michael-conrad/.opencode/issues/2314"
promoted_at: 2026-08-23T21:00:00Z
promotion_type: retroactive_import
last_sync: 2026-08-23T21:00:00Z
author: michael-newsrx
---

## Bug

When a spec issue body contains success criteria (SCs) and affected file paths, a sub-agent can be dispatched directly to implementation from the spec content — bypassing the mandatory writing-plans pipeline entirely.

## Root Cause

The DISPATCH_GATE in the skill deck relies on orchestrator routing discipline (professional agents follow the plan mandate). But there is no enforcement mechanism that prevents a sub-agent from receiving a spec body and implementing it directly. The spec-creation → writing-plans → implementation pipeline is documented as mandatory, but:

1. A sub-agent dispatched with "implement from this spec" has no gate to check whether a plan exists
2. The orchestrator can skip tasks/writing-plans/SKILL.md entirely and still produce working code
3. The only enforcement is the orchestrator's own discipline — which failed in this session (see below)

## Evidence

During a session for the Butter repo (NewSRX-Tech-LLC/Butter), a spec for issue #260 (import rewires) was dispatched directly to a clean-room sub-agent as "implement issue #260 from the spec" without going through writing-plans — skipping plan creation, artifact generation, Z3 solving, and plan validation.

The user identified the bypass: "there is no path to not have a plan" and flagged it as a deck bug.

## Fix

Add an enforcement gate at the spec-creation → implementation boundary that checks whether a local plan.md file exists before allowing implementation dispatch. If no plan exists, the dispatch MUST be BLOCKED with PLAN_MISSING.

## Severity

Process-integrity defect. Bypassing plan creation means phase decomposition, dependency DAG analysis, Z3 constraint solving, and SC-coverage validation are all skipped — increasing defect-discovery-latency.
