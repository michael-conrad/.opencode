---
trigger_on: authority, authoritative, source of truth, code over doc
tier: 1
load_when: sub-agent
---

# Guideline 10: Dual Authority — Spec for Intent, Code for State

## Principle

The spec is authoritative for intent — what the system should do. The spec defines requirements, success criteria, and behavior. The code is authoritative for current state — what the system actually does. The code is the implementation of the spec. Neither wins absolutely. When spec and code diverge, they converge through revision: the spec is revised to match reality when it misstates current behavior, and the code is revised to implement the spec's intent when it falls short.

## Rules

1. **Spec for intent, code for state**: The spec is authoritative for intent — what the system should do. The code is authoritative for current state — what the system actually does. When a spec makes an incorrect claim about current code behavior, revise the spec to match reality. When code fails to implement the spec's intent, fix the code. When spec and code diverge on matters of fact, the spec is updated to match reality.

2. **Spec before code**: The spec-before-code mandate is a Tier 1 requirement enforced by the approval gate: every code change requires an approved spec. The spec defines what to build; the code implements it.

3. **Documentation Drift Protocol**: When spec and code diverge on matters of fact — the spec describes behavior the code does not have, or the code has behavior the spec does not describe — update the spec to reflect current state. Updating the spec to match code state is an administrative sync, not a code change. After syncing the spec, STOP and report the synchronization.

4. **Spec revision revokes plan approval**: The principle is that spec revision revokes plan approval — a substantive spec revision revokes linked plan approvals. If a spec is revised (substantive change to intent), linked plan approvals are revoked per approval-gate-006.

5. **Suppression of Reactive Remediation**: Do not change code to match a spec that is wrong about current state. Code must not be changed to match a spec that is wrong about current state. Fix the spec first, then decide if the code needs changing. Remediation must be driven by technical bugs, explicit architectural requests, or approved feature additions — never by documentation drift.

6. **Verification against spec**: Before claiming completion, verify the code implements the spec's success criteria. The spec is the benchmark; the code is measured against it.

### [critical-rules-010] Implementing Stale or Superseded Specs
Professional engineers check for superseding open issues before implementing — stale specs produce wasted work. Amateurs implement whatever spec they find first — then wonder why their output is obsolete before the PR is opened.

---

*Co-authored with AI: OpenCode (deepseek-v4-flash)*
