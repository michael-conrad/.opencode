# Fragment: SC Enforcement Gate

**🚫 ALL-OR-NOTHING GATE: ALL success criteria MUST pass for implementation to be considered complete.**

| Rule | Description |
| -- | -- |
| ALL pass | Implementation is complete — proceed to next pipeline step |
| Any SKIPPED | Treated as FAIL — skipped SCs must be explicitly documented as superseded or out of scope with rationale |
| Any FAILED | Triggers autonomous remediation by the producing agent. Gate holds position (does not pass) until remediation is verified. If re-verification also fails (double-failure), HALT with blocker report. The agent MUST attempt remediation before any escalation. |
| Remediated SC | Re-verified independently — same PASS/FAIL gate applies; no carryover credit from prior passes |
| Re-verification | Repeat the verification command/assertion; confirm PASS before claiming remediation complete |

**SC Table Format (4-column):**

| ID | Criterion | Verification Method | Remediation |
| -- | -- | -- | -- |
| SC-1 | ... | Executable command/assertion producing deterministic PASS/FAIL | What corrective action is required on FAIL, including re-verification procedure |

**The Verification Method column MUST specify an executable command or assertion producing deterministic PASS/FAIL. The Remediation column MUST specify what corrective action is required on FAIL and how re-verification is performed.**
