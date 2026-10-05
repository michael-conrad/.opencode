---
name: sre-runbook
description: "Load when documenting an operational runbook, incident response procedure, or recovery playbook — or when working through one during an incident. Runbooks are written for the responder under stress: exact commands, expected outputs, decision points, and rollback steps in execution order."
license: MIT
provenance: AI-authored, .opencode#2490
---

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2490 -->

# sre-runbook

1. **Structure:** symptom → diagnosis (exact commands, expected output) →
   remediation → verification → rollback. Every step executable as written.
2. **Exactness.** Real commands with real flags; no "adjust as appropriate".
   State prerequisites and blast radius up front.
3. **Decision points** are explicit: condition → branch, with the evidence
   that decides it.
4. **Rollback before remediation.** State how to undo the procedure before
   describing how to perform it.
5. **Derived from observed incidents** where possible — a runbook for a
   failure that never happened is a hypothesis, labeled as such.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
