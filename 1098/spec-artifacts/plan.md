# Plan: local-issues: print available repo qualifiers

**Spec:** #1098
**Status:** IMPLEMENTED
**Deployed at:** dev commit `62f642c6`

## Items

1. `_print_available_repos()` helper — added at `tools/local-issues:1183`
2. Wire into `_require_qualified()` — added at `tools/local-issues:789-790`
3. Wire into `_ensure_repo()` — added at `tools/local-issues:815-816`
4. Wire into `_resolve_qualified()` — added at `tools/local-issues:839-840`

## SC Verification

All 6 SCs verified PASS (behavioral string check for SC1-5, behavioral exit code check for SC6).
