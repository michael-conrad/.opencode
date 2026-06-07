# SC Table Column References

## Rendering Note

For multi-column tables exceeding 8 columns, split into a core table (ID + Criterion + Verification Method + Remediation) with a companion metadata table cross-referenced by SC ID.

## Column Header Definitions

- **Pipeline Step Binding**: Mandatory — all tiers. Specifies which pipeline step validates this SC.
- **Artifact Path**: Mandatory — all tiers. Uses `./tmp/{issue-N}/` convention for artifact storage.
- **Requirement Traceability**: Mandatory — all tiers. MUST language linking SC to requirements.
- **Phase Binding**: Multi-phase only. Conditionally annotated with phase identifier.
- **Verification Gate**: 3 tiers (red-green, pre-commit, ci). Each tier has specific semantics:
  - red-green: verified during TDD RED/GREEN cycle
  - pre-commit: verified in pre-commit hooks
  - ci: verified in CI pipeline
- **Integration Mode**: Required when Gate=ci, optional otherwise.
- **Affinity Group**: Optional. Use-case examples for grouping related SCs.
- **Re-Entry Step**: All tiers — MUST. Specifies re-entry point on verification failure.