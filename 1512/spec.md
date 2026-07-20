**Defects:** D2=FAIL, D3=INCOMPLETE, D4=FAIL

Current desc covers push/URL/exec but omits *when* to dispatch. No mandatory language.

**Fix:** "Use when signaling workflow completion: pushing branches, generating URLs, or appending lifecycle events. Dispatch via skill() + task() — always required."