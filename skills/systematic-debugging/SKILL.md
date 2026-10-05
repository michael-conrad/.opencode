<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2490 -->
---
name: systematic-debugging
description: Load when encountering a bug, error, unexpected behavior, or failing test — or before changing any code to fix an issue. Root cause comes from evidence, not guesses: reproduce first, form hypotheses, test them, and fix the cause rather than the symptom. Also load when a fix "works" but the cause is unexplained.
license: MIT
provenance: AI-authored, .opencode#2490
---

# systematic-debugging

1. **Reproduce.** Establish a reliable reproduction before theorizing — an
   unreproducible bug cannot be verified fixed.
2. **Evidence over hypothesis.** Read the actual error, logs, and state;
   trace the failure to its origin. Never claim a root cause without evidence
   pointing at it.
3. **Hypothesis → test.** One hypothesis at a time, each with a test that
   could falsify it. Instrument when observation is cheaper than inference.
4. **Fix the cause.** Symptom patches are defects wearing a fix's clothes.
   The fix explains why the symptom existed.
5. **Regression-proof.** Add the failing case as a behavioral test; verify the
   fix against the full suite, not just the repro.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
