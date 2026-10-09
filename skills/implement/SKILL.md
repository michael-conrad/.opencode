---
name: implement
description: "Load when executing an approved plan or making any change during the implementation work cycle — before starting work and before every mid-cycle change. Loads the implementation-workflow reference first (pre-implementation checklist, RED/GREEN chain, post-implementation gates). Run tests and show real output as evidence; use the project's connectors, libraries, and test frameworks from the floor inventory — bespoke reimplementation of what a library provides is a defect."
license: MIT
provenance: AI-authored, .opencode#2490
---

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2490; #582 yaml-contract-format convention; #2550 SC-fidelity mandate; #2557 language/tool call out -->

# implement — executing the work

1. **Read [the implementation-workflow reference](references/implementation-workflow.md)
   first** — at cycle start and again before any mid-cycle change.
2. **Load the cards in scope before any code is written.** Identify the
   languages and build tools the files about to be modified belong to and load
   their cards (where cards exist), and load `programming-principles` for the
   engineering-principles layer — the load happens before the first code
   modification, not after the first defect.
3. **Per item: RED → GREEN → verify → commit.**
   - RED: write or run the failing assertion; confirm it fails for the stated
     reason.
   - GREEN: the minimal change that turns it green — no speculative additions.
   - Verify: run the check; the output itself is the evidence. Never assert
     success without an executed check.
4. **Mid-cycle changes.** Re-consult the workflow reference first. A change
   beyond the current plan item's scope stops the cycle: report and get
   direction rather than expand silently.
5. **Library-first.** Check the floor's external-access inventory and the
   project's own frameworks before writing anything bespoke — connectors,
   official clients, and built-in credential handling replace hand-rolled
   equivalents.
6. **Test value.** Tests assert behavior, are insensitive to internal
   structure, and cost less to write than the code under test warrants. Never
   test an artifact the build system already guarantees.
7. **Sub-agents are judgment, not ritual.** Dispatch one when a scoped task
   genuinely benefits; work inline when that is simply better. Dispatched work
   gets a clean-room prompt and a result back (YAML) — no chain theater.
8. **SC fidelity.** Implementation satisfies each criterion as written — no
   weakening, skipping, deferring, or reinterpreting a criterion to make it
   passable. An unimplementable criterion produces BLOCKED with the root
   cause; the criterion itself is never modified to admit the implementation.
9. **Behavioral evidence goes through the harness.** Evidence for a behavioral
   SC is produced only by the `tests-v2` behavioral harness
   (`tests-v2/AGENTS.md` — `with-test-home` + `behavior_run`, artifact +
   clean-room evaluation). An ad-hoc `opencode run` is not behavioral
   evidence.

**Agent-to-agent format:** structured data one agent creates for another — or
ingests from another — defaults to YAML, marked by the bare `(YAML)` token at
each reference; tool I/O, CLI output, and external configuration keep their
native format; chat prose carries no token.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
