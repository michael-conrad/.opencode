---
number: 701
title: "[SPEC] SC Enforcement Gate for Spec Writer, Plan Writer, and Auditors"
status: "open"
labels: [spec, needs-approval]
created: "2026-05-20T19:25:24.767847Z"
updated: "2026-05-20T19:29:33.743681Z"
github_issue: 673
author: "Michael Conrad"
github_url: "https://github.com/michael-conrad/.opencode/issues/673"
promoted_at: "2026-05-20T19:20:19Z"
remote_issue: "673"
remote_url: "https://github.com/michael-conrad/.opencode/issues/673"
---

## Intent and Executive Summary

**Problem Statement:** The spec writer (`spec-creation/tasks/write.md`) and plan writer (`writing-plans/tasks/create/plan-structure.md`) define Success Criteria sections but lack enforcement language. The SC sections do not state that ALL SCs must pass, skipped SCs are failures, and failed SCs require documented remediation. The spec auditor and plan fidelity auditor also lack criteria checking for the presence of this enforcement language.

**Root Cause:** The verification consumers (`verification-before-completion/tasks/verify.md`, `cross-validate.md`) already have strong all-or-nothing gates, but the **producers** (spec writer, plan writer) never inject the gate language into the artifacts they create, and the **checkers** (spec auditor, plan fidelity auditor) never verify the gate language exists.

**Approach Chosen:** Create a fragment master for SC enforcement gate text, inject it into spec writer, plan writer, and auditor task files. Add 4 behavioral enforcement tests.

**Amendment from #763 (Accountability/Remediation Ownership Model):** The gate language is amended so that "FAIL triggers autonomous remediation by the producing agent, not pipeline halt." The gate holds its position (does not pass) until remediation is verified or double-failure occurs. The agent remedies in-place without escalating to the developer.

---

## Fragment Master

Create `.opencode/.guidelines/sc-enforcement-gate.md`:

```markdown
# Fragment: SC Enforcement Gate

**🚫 ALL-OR-NOTHING GATE: ALL success criteria MUST pass for implementation to be considered complete.**

| Rule | Description |
|------|-------------|
| ALL pass | Implementation is complete — proceed to next pipeline step |
| Any SKIPPED | Treated as FAIL — skipped SCs must be explicitly documented as superseded or out of scope with rationale |
| Any FAILED | Triggers autonomous remediation by the producing agent. Gate holds position (does not pass) until remediation is verified. If re-verification also fails (double-failure), HALT with blocker report. The agent MUST attempt remediation before any escalation. |
| Remediated SC | Re-verified independently — same PASS/FAIL gate applies; no carryover credit from prior passes |
| Re-verification | Repeat the verification command/assertion; confirm PASS before claiming remediation complete |

**SC Table Format (4-column):**

| ID | Criterion | Verification Method | Remediation |
|----|-----------|-------------------|-------------|
| SC-1 | ... | Executable command/assertion producing deterministic PASS/FAIL | What corrective action is required on FAIL, including re-verification procedure |

**The Verification Method column MUST specify an executable command or assertion producing deterministic PASS/FAIL. The Remediation column MUST specify what corrective action is required on FAIL and how re-verification is performed. The Remediation column accepts prose (not a strict enum).**
```

---

## Changes by File

### 1. spec-creation/tasks/write.md — Step 3 (Define Acceptance Criteria)

Add the fragment content as the authoritative format for the SC section.

### 2. spec-creation/tasks/write.md — Step 4 (Determinism Gate)

Add a sub-check: "Verify the all-or-nothing gate statement is present in the assembled spec body. If absent → STRUCTURE-VIOLATION requiring rewrite before submission."

### 3. writing-plans/tasks/create/plan-structure.md — Step 1 (Read Approved Spec)

After "Extract objectives, constraints, success criteria", add SC gate extraction and SPEC_GAP flag.

### 4. adversarial-audit/tasks/spec-audit.md — Step 2 (Build Evaluation Criteria)

Add criterion SC-12.

### 5. adversarial-audit/tasks/plan-fidelity.md — Step 3 (Build Evaluation Criteria)

Update PF-3 description and add criterion PF-7.

### 6. registry.yaml

Register fragment with id `sc-enforcement-gate`.

### 7. Behavioral Enforcement Tests (4 files)

See full spec on GitHub for test details.

---

## Success Criteria

| ID | Criterion | Verification Method | Remediation |
|----|-----------|-------------------|-------------|
| SC-1 | Fragment master exists with correct format including remediation-first language | `test -f .opencode/.guidelines/sc-enforcement-gate.md && grep -q "Fragment ID: sc-enforcement-gate"` | Create file, verify format |
| SC-2 | Registry entry exists with master path and 4 destinations | `grep -c "sc-enforcement-gate" .opencode/.guidelines/registry.yaml` must return ≥1 | Register entry, verify yaml syntax |
| SC-3 | write.md Step 3 embeds fragment format as SC structure | Verify Step 3 content references all-or-nothing gate + 4-column table format | Update Step 3 prose, run behavioral test 1 |
| SC-4 | write.md Step 4 includes gate-presence sub-check | grep for "gate statement" or "STRUCTURE-VIOLATION" in write.md Step 4 | Add sub-check, verify behavioral test 1 still passes |
| SC-5 | plan-structure.md Step 1 extracts gate from spec and flags missing | grep for "gate" + "SPEC_GAP" in plan-structure.md Step 1 | Add extraction + flag logic, run behavioral test 2 |
| SC-6 | spec-audit.md has SC-12 criterion | `grep "SC-12" .opencode/skills/adversarial-audit/tasks/spec-audit.md` returns match | Add SC-12 row, run behavioral test 3 |
| SC-7 | plan-fidelity.md has PF-7 and updated PF-3 | `grep "PF-7" .opencode/skills/adversarial-audit/tasks/plan-fidelity.md` returns match; PF-3 says "ALL" | Add PF-7, update PF-3, run behavioral test 4 |
| SC-8 | 4 behavioral test scripts exist | `ls .opencode/tests/behaviors/sc-enforcement-gate-*.sh` returns 4 files | Create scripts, verify bash syntax |
| SC-9 | Each behavioral test is RED before implementation | Run each test; OVERALL_RESULT ≠ 0 | Document pre-implementation RED state |
| SC-10 | Each destination file has fragment reference comment | `grep -q "Fragment ID: sc-enforcement-gate"` in all 4 destination files | Add HTML comment trailer to inserted content |

---

## Accountability Model Alignment (per #763)

This spec is a **blocking dependency** of #763 (Accountability/Remediation Ownership Model). #763 cannot be implemented until this issue merges.

**Principle P1 alignment (audit fail is fail):** Fully aligned.

**Principle P7 alignment (remediate autonomously, not escalate):** REQUIRES AMENDMENT — FAIL triggers remediation, not halt.

---

## Change Control

| Version | Date | Change | Author |
|---------|------|--------|--------|
| 1.0 | 2026-05-17 | Initial spec — SC Enforcement Gate | |
| 1.1 | 2026-05-20 | Embed #763 amendments: FAIL triggers remediation (not halt), remediation-first language in fragment gate | |

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

