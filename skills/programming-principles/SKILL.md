---
name: programming-principles
description: "Load when designing or writing code, deciding architecture or module boundaries, reviewing code, or evaluating a design tradeoff. Enforces the working principles: minimal change, composition over cleverness, existing patterns over invented ones, and code-size discipline — plus honest tradeoff reasoning when principles conflict."
license: MIT
provenance: AI-authored, .opencode#2490
---

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2490 -->

# programming-principles

1. **Minimal change.** Solve the stated problem; no unrelated refactoring, no
   speculative generality. Targeted improvements only where they serve the
   current goal.
2. **Follow the codebase.** Existing patterns, naming, and structure win over
   personal preference; a consistent codebase outperforms a clever one.
3. **Composition over cleverness.** Small focused units with clear contracts;
   prefer the straightforward version until measurement says otherwise.
4. **Delete dead code.** Unused code is liability; removal is part of the
   change that orphans it.
5. **Tradeoffs are explicit.** When principles conflict (DRY vs clarity,
   abstraction vs directness), state the conflict and choose with a reason —
   silently optimizing for one is how architecture drifts.
6. **Design before code** when the change shapes interfaces or module
   boundaries; the design is stated briefly, then built.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
