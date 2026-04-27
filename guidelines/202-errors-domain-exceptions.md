# Error Handling: Domain-Specific Exceptions

## ✅ DOMAIN-SPECIFIC EXCEPTION CLASSES (ACCEPTABLE AND ENCOURAGED)

**Using API-specific exception classes is acceptable and encouraged for clarification methodology.**

Domain-specific exception classes improve error clarity by making it immediately obvious WHERE in the system an error occurred and WHAT component failed.

______________________________________________________________________

### Pattern: Wrap in domain-specific exceptions

```python
# ✅ GOOD - domain-specific exceptions clarify WHERE and WHAT failed
class MeshValidationError(Exception):
    """Raised when MeSH term validation fails."""
    pass

class MeshAPIError(Exception):
    """Raised when MeSH API calls fail."""
    pass

# Application layer
def validate_mesh_term(term: str) -> MeshValidationResult:
    try:
        result = mesh_client.lookup(term)
    except HTTPError as e:
        raise MeshAPIError(f"Failed to validate MeSH term '{term}': API request failed") from e
    
    if not result.is_valid:
        raise MeshValidationError(f"'{term}' is not a valid MeSH term")
    
    return result
```

**WHY THIS IS GOOD**:

1. **Immediate context**: Catching the error tells you it came from `validate_mesh_term`
2. **Component identification**: `MeshValidationError` immediately identifies the MeSH component
3. **Semantic clarity**: `MeshAPIError` vs `MeshValidationError` distinguishes API failures from validation failures
4. **Chain preservation**: `from e` preserves the original traceback and cause

______________________________________________________________________

### Pattern: Exception hierarchy for APIs

```python
# ✅ GOOD - exception hierarchy for an API/module
class PubMedError(Exception):
    """Base exception for PubMed-related errors."""
    pass

class PubMedAPIError(PubMedError):
    """Raised when PubMed API calls fail."""
    pass

class PubMedParseError(PubMedError):
    """Raised when PubMed XML parsing fails."""
    pass

class PubMedValidationError(PubMedError):
    """Raised when PubMed data validation fails."""
    pass

# Usage
def fetch_article(pmid: str) -> Article:
    try:
        response = pubmed_client.efetch(pmid)
    except HTTPError as e:
        raise PubMedAPIError(f"Failed to fetch PMID {pmid}: {e}") from e
    
    try:
        article = parse_article(response)
    except XMLParseError as e:
        raise PubMedParseError(f"Failed to parse PMID {pmid}: {e}") from e
    
    if not article.title:
        raise PubMedValidationError(f"PMID {pmid} missing required field: title")
    
    return article
```

______________________________________________________________________

### Pattern: Domain-specific vs generic exceptions

```python
# ❌ BAD - generic exception loses context
def validate_mesh_term(term: str):
    if not is_valid_mesh(term):
        raise Exception(f"Invalid term: {term}")  # Too generic

# ✅ GOOD - domain-specific exception clarifies component
def validate_mesh_term(term: str):
    if not is_valid_mesh(term):
        raise MeshValidationError(f"Invalid MeSH term: {term}")

# ✅ GOOD - wrapping generic errors with domain context
def validate_mesh_term(term: str):
    try:
        result = mesh_api.lookup(term)
    except Exception as e:
        # Wrap generic exception in domain-specific one
        raise MeshAPIError(f"MeSH API error for term '{term}': {e}") from e
```

______________________________________________________________________

### When to create domain-specific exceptions

**DO create domain-specific exceptions when**:

- You have a distinct API/module/component (MeSH, PubMed, Database, etc.)
- Different failure modes require different handling (API error vs validation error)
- The exception will bubble up through multiple layers
- You want handlers to catch specific exception types

**DON'T create domain-specific exceptions when**:

- The error is local to one function and will be caught immediately
- A generic `ValueError` or `TypeError` provides sufficient context
- The exception doesn't need to be distinguished from others at the call site

______________________________________________________________________

*Source: Content migrated from `095-never-hide-problems.md`*

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-04-25T00:00:00Z"
rules:
  - id: domain-exceptions-001
    title: "Use domain-specific exception classes for API/module boundaries"
    conditions:
      all:
        - "has_distinct_api_module == true"
        - "different_failure_modes == true"
        - "using_generic_Exception == true"
    actions:
      - PROCEED
    conflicts_with: []
    requires: []
    triggers: []
    source: "202-errors-domain-exceptions.md §When to create"

  - id: domain-exceptions-002
    title: "Preserve exception chain with from e"
    conditions:
      all:
        - "wrapping_exception == true"
        - "from_e_used == false"
    actions:
      - HALT
    conflicts_with: []
    requires: []
    triggers: []
    source: "202-errors-domain-exceptions.md §Pattern: Wrap"

  - id: domain-exceptions-003
    title: "Don't create domain exceptions for local-only errors"
    conditions:
      all:
        - "error_local_to_one_function == true"
        - "caught_immediately == true"
        - "ValueError_sufficient == true"
    actions:
      - PROCEED
    conflicts_with: []
    requires: []
    triggers: []
    source: "202-errors-domain-exceptions.md §When DON'T create"

  - id: domain-exceptions-004
    title: "Never use bare Exception for domain errors"
    conditions:
      all:
        - "raise_statement == 'Exception'"
    actions:
      - HALT
    conflicts_with: []
    requires: []
    triggers: []
    source: "202-errors-domain-exceptions.md §Domain-specific vs generic"
```
