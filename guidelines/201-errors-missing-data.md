# Error Handling: Missing Data

## 2. Missing Data Rules

### 🚫 FORBIDDEN PATTERNS

#### Silent defaults for required data

```python
# ❌ FORBIDDEN - missing required data filled with default
def build_report(data: dict):
    title = data.get("title", "Untitled Report")  # If title is required, this hides the problem
    return Report(title=title, ...)
```

**WHY**: If `title` is required, the caller must provide it. Using a default hides the problem until someone notices "Untitled Report" in production.

**CORRECT**:

```python
def build_report(data: dict):
    if "title" not in data:
        raise ValueError(f"Missing required field 'title' in report data")
    return Report(title=data["title"], ...)
```

______________________________________________________________________

#### Placeholder/synthetic data

```python
# ❌ FORBIDDEN - creating fake data to fill gaps
discovery_date = record.get("discovery_date") or date.today()  # WRONG
journal_name = record.get("journal") or "Unknown Journal"  # WRONG
```

**WHY**: Placeholder data corrupts downstream analysis. If you don't have real data, surface the gap.

**CORRECT**:

```python
discovery_date = record.get("discovery_date")
if discovery_date is None:
    raise ValueError(f"Missing required field 'discovery_date' in {record_id}")

journal_name = record.get("journal")
if not journal_name:
    raise ValueError(f"Missing required field 'journal' in {record_id}")
```

______________________________________________________________________

#### None returns for required data

```python
# ❌ FORBIDDEN - forces caller to check None
def fetch_user(user_id: int) -> User | None:
    try:
        return db.query(User).filter_by(id=user_id).first()
    except Exception:
        return None  # Hides the database error AND the missing user
```

**WHY**: Callers often forget to check `None`. Errors propagate invisibly.

**CORRECT**:

```python
def fetch_user(user_id: int) -> User:
    user = db.query(User).filter_by(id=user_id).first()
    if user is None:
        raise ValueError(f"User {user_id} not found")
    return user
```

______________________________________________________________________

### ✅ REQUIRED PATTERNS

#### Explicit validation with context

```python
# ✅ GOOD - fail fast with clear message
def process_config(config_path: Path) -> Config:
    if not config_path.exists():
        raise FileNotFoundError(f"Configuration file not found: {config_path}")
    
    content = config_path.read_text()
    if not content.strip():
        raise ValueError(f"Configuration file is empty: {config_path}")
    
    try:
        return Config.from_yaml(content)
    except yaml.YAMLError as e:
        raise ValueError(f"Invalid YAML in {config_path}: {e}") from e
```

______________________________________________________________________

#### Optional data is explicit

```python
# ✅ GOOD - use Optional type hint and handle None case
from typing import Optional

def find_user_by_email(email: str) -> Optional[User]:
    """Returns User if found, None if not exists. Does NOT raise on missing."""
    return db.query(User).filter_by(email=email).first()

# VS

def get_user_by_id(user_id: int) -> User:
    """Returns User. Raises ValueError if not found."""
    user = db.query(User).filter_by(id=user_id).first()
    if user is None:
        raise ValueError(f"User {user_id} not found")
    return user
```

**WHY**: The type signature tells the caller what to expect. `Optional` signals "might be None". Non-`Optional` signals "will raise if missing".

______________________________________________________________________

*Source: Content migrated from `095-never-hide-problems.md`*

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-04-25T00:00:00Z"
rules:
  - id: missing-data-001
    title: "No silent defaults for required data"
    conditions:
      all:
        - "data_field_required == true"
        - "default_applied == true"
    actions:
      - HALT
    conflicts_with: []
    requires: []
    triggers: []
    source: "201-errors-missing-data.md §Missing Data Rules"

  - id: missing-data-002
    title: "No placeholder or synthetic data for missing fields"
    conditions:
      any:
        - "code_pattern == 'or_date_today'"
        - "code_pattern == 'or_unknown_string'"
        - "code_pattern == 'fabricated_default'"
    actions:
      - HALT
    conflicts_with: []
    requires: []
    triggers: []
    source: "201-errors-missing-data.md §Missing Data Rules"

  - id: missing-data-003
    title: "No None returns for required data"
    conditions:
      all:
        - "function_return_type == 'Optional'"
        - "data_is_required == true"
    actions:
      - HALT
    conflicts_with: []
    requires: []
    triggers: []
    source: "201-errors-missing-data.md §Missing Data Rules"

  - id: missing-data-004
    title: "Required data must raise on missing"
    conditions:
      all:
        - "required_field_missing == true"
        - "exception_raised == false"
    actions:
      - HALT
    conflicts_with: []
    requires: []
    triggers: []
    source: "201-errors-missing-data.md §Required Patterns"

  - id: missing-data-005
    title: "Optional data must use Optional type hints explicitly"
    conditions:
      all:
        - "data_may_be_none == true"
        - "type_hint != 'Optional'"
    actions:
      - HALT
    conflicts_with: []
    requires: []
    triggers: []
    source: "201-errors-missing-data.md §Required Patterns"
```
