**Defects:** D2=FAIL, D3=INCOMPLETE — RESOLVED

TDT has provenance/submodule-sync; desc now includes them.

**Fix:** Added `trunk-push-provenance` and `submodule-sync` dispatch conditions to the git-workflow description field. Removed `promotion-provenance` (eliminated under trunk-based development — no dev→main promotion). Removed release PR promotion and promote-to-main/dev-to-main trigger phrases.

**Related:** #1556 — provenance task set change (rename `dev-push-provenance`→`trunk-push-provenance`, delete `promotion-provenance`)

**PR:** https://github.com/michael-conrad/.opencode/pull/1668

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)