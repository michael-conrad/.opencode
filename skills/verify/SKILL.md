---
name: verify
description: "Load when checking a deliverable against its stated requirements before any completion or PR-readiness claim. Dispatches exactly ONE fresh-context reviewer — never the implementor — who reads the primary artifacts (spec/SCs, the diff, actual executed test output) and flags only gaps affecting correctness or stated requirements. FAIL → remediate → one re-review → still FAIL → halt to the developer. Never proceed past an unremediated FAIL. One verdict record; no artifact chains, no re-audit loops."
license: MIT
provenance: AI-authored, .opencode#2490
---

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2490 -->

# verify — the single verification pass

1. **Dispatch one reviewer.** Fresh context, budget comparable to the
   implementor. The reviewer reads the primary artifacts directly — spec/SCs,
   the diff, the executed test output — not the implementor's summaries.
2. **The churn rule (include verbatim in the reviewer prompt):** *Flag only
   gaps that affect correctness or the stated requirements. A reviewer
   prompted to find gaps will always report some — do not chase style,
   ceremony, or imagined requirements.*
3. **Verdict.** PASS / FAIL per SC, grounded in the reviewer's findings and
   the executed evidence. Record it once — chat or PR description. No YAML
   artifact chains.
4. **FAIL path.** Remediate → one re-review. Still failing → halt to the
   developer with the specific failing SCs, the root cause, and what is needed.
   Never proceed past an unremediated FAIL.
5. **Own-test execution stays with the implementor.** Running tests and showing
   output is fact work, not review — it happens in `implement`, and the
   reviewer consumes its output.
6. **Test-value judgment lives here.** Whether a test asserts behavior the
   build tool already guarantees is intent-decidable — the reviewer judges it;
   no script decides it.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
