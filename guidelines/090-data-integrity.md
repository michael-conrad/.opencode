---
trigger_on: data integrity, mutable, mutation, database, production data
tier: 1
load_when: sub-agent
---

# Data Integrity

## Global Absolute Prohibition

- **NO SYNTHETIC / IMAGINARY / FABRICATED DATA — PERIOD, NO EXCEPTIONS**: Across all code, notebooks, reports, plans, analyses, validation vocabularies, examples used as evidence, and recommendations, only real, verifiable data from real sources is allowed. Synthetic, placeholder, invented, proxy, mock-as-real, or guessed data is globally forbidden with no carve-outs.

## Fail-Fast

- Raise contextual errors immediately; never swallow exceptions.

- **NO FALSE DATA**: Never use proxy/fallback/synthetic data (e.g., `date.today()` for missing historical metadata,
  cross-field assignments like `journal_pub_date = received_date`). If metadata is missing, ambiguous, or unexpected (
  `None`, `0`), fail immediately and ask user.

- **NO DEFAULT DATA**: Never assign defaults to fill missing DB fields.

- **NO INVALID DEFAULTS**: Never default parameters that drive deterministic logic (e.g., `processing_date`). Caller
  must provide explicitly.

- **HARD FAIL ON MISSING REQUIRED DATA**: If data required for analysis or downstream processing is missing from a
  source record (e.g., `received_date` absent from an XML record), the process MUST raise immediately — never skip,
  suppress, or continue. Missing required data is a data integrity defect, not a filter condition. All fields referenced by the current logic are **required** by default. Any field that is genuinely optional (i.e., its absence is expected and documented in the schema) must be explicitly handled by the logic; otherwise, its absence MUST trigger a hard fail. **The agent is prohibited from using a default placeholder (e.g., '—') to mask a missing field that it has not explicitly confirmed as optional.**

## Verify Before Recommend

- Never recommend backfills/schema changes based on assumptions. Verify presence and distribution of source data with a
  robust sample before proposing solutions.
- **NO SYNTHETIC/IMAGINARY ANALYSIS VOCABULARIES**: In notebooks, reports, or analysis pipelines, do not invent
  placeholder term sets (e.g., "optional seed" dictionaries). Use only verifiable terms from real authorities and
  document the source in the artifact. If no real source is available, leave the vocabulary empty and block/flag
  validation rather than fabricating terms.
- **MANDATORY SOURCE TRACEABILITY FOR VALIDATION DATA**: Any reference data used to validate user-supplied artifacts
  (e.g., reference dictionaries, code lists, taxonomies) must include a real source of record (official API, release file,
  or documented curated dataset) and version/date when available. Unverifiable inline constants are prohibited for
  pass/fail validation logic.
- **Robust Sampling Required**: When analyzing or remediating data formats, behavior, or patterns, you MUST compare
  across multiple samples (minimum 5-10 distinct records) from different categories/topics. Never assume a single
  example is representative of a set or format.
- **Exhaustive Automated Analysis**: When a large archived dataset is available (e.g., an archived dataset snapshot), you MUST
  generate and run an automated script to scan the ENTIRE archive for frequency analysis of headers, fields, and
  formatting patterns. Relying on manual sampling for large datasets is strictly prohibited. A dataset is considered
  **large** for this rule if it contains more than 1,000 records or files.
- **Evidence-Based Remediation**: All remediation plans MUST be based on findings verified through exhaustive
  automated analysis or robust multi-sample sets.
- **NO UNAUTHORIZED FORMAT CHANGES**: You are strictly prohibited from adding, removing, or altering data fields,
  headers, or formatting styles (e.g., Markdown structure) without explicit, documented authorization. Any deviation
  from the established "Ground Truth" (e.g., archived dataset snapshots) is a data integrity violation.
  Authorization is established by an explicit user instruction in the current session (chat or approved plan). A GO on
  a plan that includes the format change constitutes documented authorization.
- **MANDATORY AUDIT LOGGING**: Any proposed change to a data format MUST be accompanied by an automated audit report
  proving fidelity to the source or historical archive. "Speculative" or "unannounced" format improvements are
  forbidden.

## No Unauthorized Semantic Changes

- **NEVER ALTER SEMANTIC MEANING WITHOUT EXPLICIT PERMISSION**: You are strictly prohibited from changing the semantic meaning of any artifact — including queries, logic, data transformations, prompts, configurations, code, data structures, or any other artifact — without explicit user permission. This applies to all translation, refactoring, reformulation, and implementation tasks.
- **NO EQUIVALENCE CLAIMS WITHOUT PROOF**: Claiming that a transformed or translated artifact is "equivalent" or "semantically identical" to the original is forbidden unless you can formally prove the equivalence. If you cannot prove equivalence, you must explicitly state the discrepancy.
- **STOP AND REPORT ON SEMANTIC LOSS**: If a task (e.g., translating a query to a different syntax, refactoring logic, reformulating a prompt) cannot be completed while preserving exact semantics, you MUST stop immediately and report the discrepancy to the user before proceeding. Never silently approximate.

## Production Data Protection

- **ABSOLUTE PROHIBITION**: Strictly follow the production data protection rules in `070-environment.md`. Never run code against production data or databases without explicit user instruction in the current session.
- **NO TESTS AGAINST PRODUCTION**: Tests must NEVER run against production or live data. Always use isolated test fixtures with dedicated test databases. Running tests against production data is prohibited regardless of whether the test is read-only, verification, or diagnostic.

## No Hardcoded Entity IDs

- Hardcoding domain-specific entity IDs (e.g., PMIDs, database record IDs, foreign keys) in source code or notebooks is **absolutely forbidden**.
- Such values are tightly coupled to a specific database snapshot and will silently break or produce incorrect results when the database is updated or rebuilt.
- All entity IDs used in logic must be derived dynamically at runtime (e.g., via query, ranking, or configuration) — never cherry-picked and embedded in code.
- Existing violations (e.g., hardcoded entity ID constants) must be removed and replaced with dynamic derivation.

## Batch Operations

- For datasets exceeding 1,000 rows: use pagination (offset/keyset) for reads and batched commits for writes.
- **CORRECTNESS OVER PERFORMANCE**: Always prioritize correct operation over insertion speeds or other optimizations. A smaller batch size that works reliably is better than a larger batch size that fails.
- **POSTGRESQL PARAMETER LIMIT**: Batch operations using parameterized queries must stay under PostgreSQL's 65,535 parameter limit. With N columns per row, batch size must satisfy: `batch_size × N < 65535`. For 10-column inserts, maximum safe batch size is ≈6,500 (use 5,000 for safety margin).
- **ESTABLISH WORKING BATCH SIZES FIRST**: Start with conservative batch sizes (500-1,000 rows). Only increase after verifying correctness at scale. Never assume large batch sizes work without testing.
- **VALIDATE BATCH CONTENTS**: Before upserting a batch, validate that data structures match schema expectations. Catch errors early rather than mid-transaction.

## Long-Running Tasks

- All batch/long-running tasks MUST use `tqdm`. Update progress per individual item (`pbar.update(1)`), not per batch.

## Data Validation at System Boundaries

A **system boundary** is any point at which data enters or exits the application's processing logic: a file ingest, an API request/response, a database read/write, a serialization/deserialization step, or an external service interaction. The integrity rule applies at every such crossing point: no unvalidated data crosses a system boundary.

- **NO UNVALIDATED DATA CROSSES A BOUNDARY**: Validate structure, types, and constraints at every point where data enters or exits the system. Data that has not been validated MUST NOT proceed into or out of processing logic.
- **VALIDATE STRUCTURE**: Confirm the data has the expected shape — required fields present, expected nesting, correct collection types — before it is accepted. Reject malformed structure at the boundary.
- **VALIDATE TYPES**: Confirm each field has the expected data type. Do not coerce, guess, or silently reinterpret a value whose type does not match the declared schema.
- **VALIDATE CONSTRAINTS**: Confirm field values satisfy the declared constraints (ranges, enums, formats, referential requirements) before acceptance. Values outside constraints are rejected, not coerced.
- **MISSING REQUIRED DATA IS A VALIDATION FAILURE, NOT A PROCESSING BRANCH**: Missing required data at a boundary is a validation failure that MUST raise immediately. It is never a branch condition, filter, or silent-continue path. (Generalizes the existing fail-fast rule beyond one project's field names.)
- **RESOLVE ENTITY REFERENCES DYNAMICALLY**: All entity references MUST be resolved dynamically from validated sources (query, configuration, or API) at runtime. Never embed hardcoded entity IDs in code, and never resolve an entity from unvalidated input. (Generalizes the existing no-hardcoded-entity-IDs rule.)

## Serialization Integrity

- **VERSION ALL SERIALIZED FORMATS**: Every serialized format (wire protocol, file format, schema, message envelope) MUST carry a version identifier. Consumers MUST reject formats whose version they do not understand.
- **MAINTAIN BACKWARD COMPATIBILITY**: A change to a serialized format MUST remain readable by all existing consumers. Do not break readers that rely on the previous version. Where a breaking change is unavoidable, it MUST be introduced as a new explicit version, not a silent mutation of the existing one.
- **NO SILENT FORMAT CHANGES**: You MUST NOT change a serialized format without explicit, documented, versioned authorization. A format change is a data integrity event, not an implementation detail. (Generalizes the existing no-unauthorized-semantic-changes rule to serialization.)
- **EVERY TRANSFORMATION TRACEABLE TO ITS SOURCE**: Every data transformation MUST be traceable to its source input and the operation performed. A consumer MUST be able to reconstruct what produced any transformed artifact. Un-traceable transformations are integrity defects.

## Data Classification

- **CLASSIFY DATA BY SENSITIVITY**: Assign every dataset a classification — PII, internal, public, or production — at the point of ingress. Classification is explicit, never implicit or assumed.
- **PRODUCTION DATA HAS RESTRICTED ACCESS**: Access to production data is restricted. Code, notebooks, and reports MUST NOT access production data without explicit authorization in the current session. (Generalizes the existing production-data-protection rule.)
- **NO TESTS AGAINST PRODUCTION DATA**: Tests MUST never run against production or live data. Always use isolated test fixtures with dedicated test databases. (Consolidated here from Production Data Protection; the original rule is preserved verbatim above.)
- **NO SYNTHETIC OR FABRICATED DATA IN ANY CLASSIFICATION**: The Global Absolute Prohibition applies to every classification. No synthetic, placeholder, invented, proxy, mock-as-real, or guessed data is permitted in PII, internal, public, or production data. (References the Global Absolute Prohibition above rather than duplicating it.)

## Migration Integrity

- **MAKE ALL DATA MIGRATIONS REVERSIBLE**: Every data migration MUST have a defined rollback path. A migration that cannot be undone is not deployable.
- **VERIFY SOURCE AGAINST TARGET BEFORE DEPLOYMENT**: Before deploying a migration, verify that the target data matches the source. Do not rely on the migration "just working" — compare counts, samples, and integrity constraints between source and target.
- **NO UNREVIEWED TRANSFORMATIONS**: A transformation embedded in a migration MUST be reviewed and documented before it runs. Unreviewed transformations are integrity defects.
- **SAMPLE BEFORE RECOMMENDING SCHEMA CHANGES**: Never recommend backfills or schema changes based on assumptions. Verify the presence and distribution of source data with a robust sample before proposing any change. (Generalizes the existing verify-before-recommend rule.)

## Audit Trail

- **EVERY DATA MUTATION TRACEABLE TO SOURCE AND AUTHORIZATION**: Every data mutation MUST be traceable to its originating source and the authorization that permitted it. An untraceable mutation is an integrity defect.
- **NO SILENT DATA CHANGES**: You MUST NOT change data without an audit record. Silent data changes — updates, deletions, or reclassifications that leave no trace — are forbidden.
- **REQUIRE DOCUMENTED AUTHORIZATION FOR ALL FORMAT CHANGES**: Any change to a data format or structure MUST be accompanied by documented authorization. "Speculative" or "unannounced" format improvements are forbidden. (Consolidated here from Verify Before Recommend; the original rules are preserved verbatim above.)

## Data Retention

- **DEFINE RETENTION POLICIES PER CLASSIFICATION**: Establish a **retention window** — the defined duration a given data classification is permitted to persist — for each data classification. Retention is derived from sensitivity: production/PII data has the shortest window, public data the longest.
- **NO DATA PERSISTS BEYOND ITS RETENTION WINDOW WITHOUT REVIEW**: Any data that persists beyond its retention window MUST be reviewed for deletion, archival, or re-classification. Data MUST NOT silently persist past its window.

## Cross-References

- **200-errors.md** — Zero-tolerance rules for exception handling and missing data
- **Data Validation at System Boundaries** — Validate structure, types, and constraints at every data crossing point
- **Serialization Integrity** — Version all serialized formats and maintain backward compatibility
- **Data Classification** — Classify data by sensitivity at the point of ingress
- **Migration Integrity** — Make all data migrations reversible and verified
- **Audit Trail** — Trace every data mutation to its source and authorization
- **Data Retention** — Define retention policies and never persist beyond the window without review

______________________________________________________________________

This guideline works with the error handling series (200-203). When in doubt: **raise, don't return.**
