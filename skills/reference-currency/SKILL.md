---
name: reference-currency
description: "Load before authoring any plan or spec that references deck paths or task-card dispatch strings, and before dispatching on any embedded routing reference, in any repo. Owns routing-reference currency: references track the deck copy available to the holding repo; dead references are remediated before dependent work continues — never silently."
license: MIT
provenance: AI-authored, .opencode#2499
---

# reference-currency — routing references track the live deck

Plans and specs embed routing metadata — skill paths and task-card dispatch
strings into the deck. Deck reorganizations cannot reach the repos that hold
those references, so the consuming side owns their currency.

1. **Authoring time.** When writing a plan or spec, conform every deck-path
   and dispatch reference to the deck copy available to the repo that will
   hold the document — not to memory, not to another deployment's deck.
2. **Use time.** Before acting on an embedded routing reference, existence-
   check it against the holding repo's deck copy. A dead reference is
   remediated before the work that depends on it continues.
3. **Remediation.** Re-conform the reference to the live deck path, or to its
   preserved governing copy when the live deck no longer carries it. Report
   every remediation — silent substitution is the defect this card exists to
   stop. Improvised per-dispatch substitution (attic copies, untracked
   sources) is not remediation.
4. **Fail-loud is reserved.** Halt only when remediation is impossible — no
   live or preserved copy exists. Everything else is remediate-then-continue.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
