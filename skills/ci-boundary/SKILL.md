---
name: ci-boundary
description: "Load before creating or modifying CI for ANY repository — pipelines, runners, workflows, or submodule checkout configuration — in any repo, with or without submodules. Owns the CI repo boundary: checkout is consumption; CI execution is responsibility."
license: MIT
provenance: AI-authored, .opencode#2496
---

# ci-boundary — CI repo boundaries

Checkout is consumption; CI execution is responsibility.

1. **Checkout.** A repo's CI checks out its submodules — mandatory, pinned to
   the recorded pointer, boundary-clean: submodule content is part of the
   parent's own build surface. Never treat checkout as a cross-repo CI issue.
2. **Execution.** A repo's CI runs its OWN verification machinery and no one
   else's. Running a submodule's test framework, gates, or quality bars from
   a parent's pipeline crosses the boundary: a foreign runner enforces (or
   silently skips) standards it does not own, failure attribution blurs, and
   the submodule can no longer evolve its CI without negotiating with the
   parent's pipeline.
3. **Submodule CI is the submodule's responsibility** — its own runner,
   triggers, and gates, visible on the submodule's own PRs. The parent may
   read that outcome; it never runs it.
4. **Failure isolation.** A red submodule pipeline never blocks a parent run
   except through the pointer not advancing.
5. **Anti-pattern:** one pipeline, one green checkmark spanning multiple
   repos — the convenience is the coupling.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
