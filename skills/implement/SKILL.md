---
name: implement
description: "Load when executing an approved plan or making any change during the implementation work cycle — before starting work and before every mid-cycle change. Loads the implementation-workflow reference first (pre-implementation checklist, RED/GREEN chain, post-implementation gates). Run tests and show real output as evidence; use the project's connectors, libraries, and test frameworks from the floor inventory — bespoke reimplementation of what a library provides is a defect."
license: MIT
provenance: AI-authored, .opencode#2490
---

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2490 -->

# implement — executing the work

1. **Read [the implementation-workflow reference](references/implementation-workflow.md)
   first** — at cycle start and again before any mid-cycle change.
2. **Per item: RED → GREEN → verify → commit.**
   - RED: write or run the failing assertion; confirm it fails for the stated
     reason.
   - GREEN: the minimal change that turns it green — no speculative additions.
   - Verify: run the check; the output itself is the evidence. Never assert
     success without an executed check.
3. **Mid-cycle changes.** Re-consult the workflow reference first. A change
   beyond the current plan item's scope stops the cycle: report and get
   direction rather than expand silently.
4. **Library-first.** Check the floor's external-access inventory and the
   project's own frameworks before writing anything bespoke — connectors,
   official clients, and built-in credential handling replace hand-rolled
   equivalents.
5. **Test value.** Tests assert behavior, are insensitive to internal
   structure, and cost less to write than the code under test warrants. Never
   test an artifact the build system already guarantees.
6. **Sub-agents are judgment, not ritual.** Dispatch one when a scoped task
   genuinely benefits; work inline when that is simply better. Dispatched work
   gets a clean-room prompt and a result back — no chain theater.
7. **Behavioral evidence goes through the harness.** Evidence for a behavioral
   SC is produced only by the `tests-v2` behavioral harness
   (`tests-v2/AGENTS.md` — `with-test-home` + `behavior_run`, artifact +
   clean-room evaluation). An ad-hoc `opencode run` is not behavioral
   evidence.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
