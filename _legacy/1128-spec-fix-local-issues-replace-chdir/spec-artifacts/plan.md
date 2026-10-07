# Plan: Replace Global-State chdir with PROJECT_DIR-Anchored Operations

**Spec:** #1128
**File:** `tools/local-issues` (1576 lines, Python 3.12 uv run script)
**Z3 Contract:** SAT — 7 phases, 21 variables, 31 constraints (linear dependency: p1→p2→p3→p4→p5→p6→p7)
**Concept**: Walk-up-to-`.opencode` → `PROJECT_DIR` → `repo_path / ".issues"` (no chdir, no heuristic)

---

## Phase 1: Add PROJECT_DIR Global (p1_add_project_dir)

**Concern:** Compute `PROJECT_DIR` once at module top using canonical walk-up-to-`.opencode` per `210-scripting.md:28-38`. All subsequent operations derive paths from `PROJECT_DIR`.

**Files:** `tools/local-issues`
**Entry:** `Path(__file__).resolve().parent` walk-up
**Exit:** `PROJECT_DIR` assignment at module level (line ~42), used nowhere yet (live until Phase 4)

### Step 1.1 — RED: Write string test verifying no `os.chdir()` call exists yet as baseline

```
grep "os.chdir" tools/local-issues | wc -l
```
→ Expect 8+ hits (all current chdir calls). Test passes (baseline established).

### Step 1.2 — GREEN: Add PROJECT_DIR + walk-up computation at module top

Insert after line 42 (`ISSUES_DIR`):
```python
_path = Path(__file__).resolve().parent
while _path.name != ".opencode":
    parent = _path.parent
    if parent == _path:
        raise RuntimeError("Could not find .opencode/ directory")
    _path = parent
PROJECT_DIR = _path.parent
```
This is the canonical method from `210-scripting.md:28-38`. No CWD dependency.

### Step 1.3 — REFACTOR: Ruff lint + verify

```bash
uvx ruff check --fix tools/local-issues && uvx ruff format tools/local-issues
```

### Step 1.4 — MERGED: Phase 1 string check

```
grep -c "^PROJECT_DIR" tools/local-issues
```
→ Expect exactly 1 match. Test passes. Commit.

---

## Phase 2: Replace _resolve_repo_name() (p2_replace_resolve_repo_name)

**Concern:** `_resolve_repo_name()` at line 1167-1180 walks script path looking for `.gitmodules`, always returning `opencode-config`. Replace: repo name = `path.name` where path is from `_resolve_repo_path()` or `PROJECT_DIR`-derived.

**Instruction:** `_resolve_repo_name()` is called by: `_collect_repos()` (line 583), `cmd_create()` (line 712, 720), `_resolve_repo_path()` (line 802), `_resolve_qualified()` (line 831), `_print_available_repos()` (line 1186), `cmd_search()` (line 1119), `cmd_list()` (line 1197). After the change, it returns a name derived from resolved path context, not from script-location heuristic.

### Step 2.1 — RED: Behavioral test — run `local-issues list` from within `.opencode/` and verify qualifier

```bash
cd .opencode && uv run tools/local-issues list 2>&1 | grep -o ".opencode#"
```
→ Currently expects to see `opencode-config#` for `.opencode` issues (wrong qualifier).

### Step 2.2 — GREEN: Rewrite _resolve_repo_name()

Replace body at line 1167-1180:
```python
def _resolve_repo_name() -> str:
    return Path(os.getcwd()).name
```
This works because after Phase 3, all operations use explicit paths — the fallback becomes correct when `os.getcwd()` reflects the actual repo being operated on. No heuristic, no `.gitmodules`.

### Step 2.3 — STRING: Verify no `.gitmodules` references in _resolve_repo_name

```
grep -n "\.gitmodules" tools/local-issues
```
→ Expect 0 hits in `_resolve_repo_name` (still in `_discover_repos` at line 259, which is correct).

### Step 2.4 — MERGED: Phase 2 string check

```
grep -c "return parent.name" tools/local-issues | grep "opencode-config"
```
→ Expect 0. Test passes. Commit.

---

## Phase 3: Remove os.chdir() from _ensure_repo() and All Callers (p3_remove_chdir)

**Concern:** `_ensure_repo()` at line 811-819 calls `os.chdir(str(repo_path))`. Remove the chdir, rename to indicate no side effects. All 7 callers must use the returned path explicitly instead of relying on CWD.

**Callers:** `cmd_create` (719), `cmd_update` (1017), `cmd_comment` (1044), `cmd_close` (1067), `cmd_delete` (1086), `cmd_link` (1261), `cmd_renumber` (1292), `cmd_promote` (1327).

### Step 3.1 — RED: String search — count os.chdir calls

```
grep -c "os.chdir" tools/local-issues
```
→ Expect current count ≥ 2.

### Step 3.2 — GREEN: Rename _ensure_repo to _resolve_and_validate_repo, remove chdir

Line 811-819:
```python
def _resolve_and_validate_repo(repo_name: str) -> Path:
    repo_path = _resolve_repo_path(repo_name)
    if repo_path is None:
        print(f"Error: repo '{repo_name}' not found.", file=sys.stderr)
        _print_available_repos()
        sys.exit(1)
    return repo_path
```

### Step 3.3 — GREEN: Update each caller to use returned path

Each caller: replace `_ensure_repo(name)` with `repo_path = _resolve_and_validate_repo(name)`.

**cmd_create** (line 717-722):
```python
repo_path = _resolve_and_validate_repo(repo_name)
# Use repo_path instead of CWD for subsequent operations
```
After chdir removal, `get_issue_path()` (line 136) still uses `Path(ISSUES_DIR)` which is relative to CWD. In Phase 4 this changes — for Phase 3, the chdir is simply removed and callers hold `repo_path` for Phase 4.

### Step 3.4 — GREEN: Also fix all non-command uses of _ensure_repo

Search for any remaining reference to `_ensure_repo` and replace with `_resolve_and_validate_repo`.

### Step 3.5 — STRING: Verify zero os.chdir calls

```
grep -c "os.chdir" tools/local-issues
```
→ Expect 0. **SC-2 PASS.**

### Step 3.6 — MERGED: Phase 3 complete

Commit. Tag `p3_merged`.

---

## Phase 4: Replace Relative ISSUES_DIR with repo_path / ISSUES_DIR (p4_replace_relative_issues_dir)

**Concern:** `ISSUES_DIR = ".issues"` at line 43 is used as bare `Path(ISSUES_DIR)` throughout, relying on CWD. Replace all `Path(ISSUES_DIR)` with `repo_path / ".issues"` where `repo_path` is the resolved repo path from `_resolve_and_validate_repo()` or `_collect_repos()`.

**Affected callers use ISSUES_DIR at:** `_find_issue_dir` (58), `get_issue_path` (145), `_find_issue_dir_in_repo` (94), `_worktree_active` (220), `_ensure_worktree` (452, 456, 527, 530, 537), `_push_issues_branch` (625, 633), `_auto_commit` (654, 662, 668), `_next_number` (682), `cmd_search` (1130), `cmd_list` (1209), `_sync_repo` (1345, 1348, 1353, 1362, 1371, 1389, 1393), `cmd_init` (1413), `cmd_sync` (1424).

### Step 4.1 — RED: String search — count bare ISSUES_DIR references

```
grep -n "Path(ISSUES_DIR)" tools/local-issues | wc -l
```
→ Baseline count.

### Step 4.2 — GREEN: Update `_find_issue_dir` (line 50) to accept repo_path

Change signature: `def _find_issue_dir(number: int, repo_path: Path | None = None) -> Path | None:`
If `repo_path` is None, use `PROJECT_DIR`. Use `repo_path / ".issues"` instead of `Path(".issues")`.

Canonical pattern:
```python
issues_dir = (repo_path or PROJECT_DIR) / ".issues"
```

### Step 4.3 — GREEN: Update `get_issue_path` (line 136)

Accept `repo_path` parameter; derive `ISSUES_DIR` from it.

### Step 4.4 — GREEN: Update all command handlers to pass repo_path

Each handler now passes `repo_path` from `_resolve_and_validate_repo()` to `_find_issue_dir`, `get_issue_path`, etc.

### Step 4.5 — GREEN: Update worktree functions (_ensure_worktree, _worktree_active, etc.)

These already accept `repo_path` parameter. Replace `root / ISSUES_DIR` → `root / ".issues"` (inline, no macro dependency). Keep `ISSUES_DIR` global as constant for context but don't use `Path(ISSUES_DIR)` bare.

### Step 4.6 — STRING: Verify no bare Path(ISSUES_DIR) remains

```
grep -n "Path(ISSUES_DIR)" tools/local-issues | grep -v "repo_path" | grep -v "PROJECT_DIR"
```
→ Expect 0 matches for bare (non-repo_path-anchored) ISSUES_DIR references.

### Step 4.7 — MERGED: Phase 4 complete

Commit.

---

## Phase 5: Eliminate All Bare `except Exception: pass` (p5_eliminate_bare_except)

**Concern:** 5 locations silently swallow all exceptions. Each must propagate, report diagnostic to stderr, or return explicit sentinel.

### Locations

| # | Location | Lines | Call |
|---|----------|-------|------|
| 1 | `_discover_repos()` | 289-290 | `except (configparser.Error, Exception): pass` |
| 2 | `_ensure_all_worktrees()` | 396 | `except Exception: all_ok = False` |
| 3 | `_ensure_worktree()` | 554 | `except Exception: return False` |
| 4 | `_push_orphan_if_needed()` | 611 | `except Exception: pass` |
| 5 | `_push_issues_branch()` | 637 | `except Exception: pass` |
| 6 | `_auto_commit()` | 672 | `except Exception: pass` |

### Step 5.1 — RED: String test — count bare except Exception

```
grep -c "except Exception:" tools/local-issues
```
→ Expect current count. After Phase 5: expect 0.

### Step 5.2 — GREEN: Fix _discover_repos (line 289)

Replace bare `except (configparser.Error, Exception): pass` with printing error to stderr:
```python
except configparser.Error as e:
    print(f"warn: skipping submodule config parsing: {e}", file=sys.stderr)
```

### Step 5.3 — GREEN: Fix _ensure_all_worktrees (line 396)

```python
except Exception as e:
    print(f"warn: worktree setup failed for {repo}: {e}", file=sys.stderr)
    all_ok = False
```

### Step 5.4 — GREEN: Fix _ensure_worktree (line 554)

Replace line 554:
```python
except Exception as e:
    print(f"warn: worktree setup failed for {root}: {e}", file=sys.stderr)
    return False
```

### Step 5.5 — GREEN: Fix _push_orphan_if_needed (line 611)

```python
except Exception:
    print(f"warn: failed to push orphan branch {branch}", file=sys.stderr)
```

### Step 5.6 — GREEN: Fix _push_issues_branch (line 637)

```python
except Exception:
    print("warn: failed to push issues branch", file=sys.stderr)
```

### Step 5.7 — GREEN: Fix _auto_commit (line 672)

```python
except Exception:
    print("warn: auto-commit failed", file=sys.stderr)
```

### Step 5.8 — STRING: SC-4 verification

```
grep -c "except Exception:" tools/local-issues
```
→ Expect 0. **SC-4 PASS.**

### Step 5.9 — REFACTOR: Ruff lint + verify

### Step 5.10 — MERGED: Phase 5 complete

Commit.

---

## Phase 6: Worktree Error Handling (p6_worktree_error_handling)

**Concern:** `_ensure_worktree()` has 6+ subprocess calls with zero return code checks (lines 459-505). Prune failures silently ignored (445-449). Worktree creation and migration have zero error checking (530-534). Add return code checks at each subprocess call and emit diagnostics on failure.

### Step 6.1 — RED: String test — count subprocess.run calls without returncode check

```
grep -c "subprocess.run" tools/local-issues
```
→ Baseline for Phase 6.

### Step 6.2 — GREEN: Add return code checks to orphan branch creation block (lines 459-505)

Each of the 7 subprocess calls in the orphan creation block must be checked:
```python
result = subprocess.run([...], capture_output=True, text=True, timeout=15)
if result.returncode != 0:
    print(f"warn: orphan branch step failed: {result.stderr.strip()}", file=sys.stderr)
```

### Step 6.3 — GREEN: Add return code check to worktree migration (line 530-534)

```python
result = subprocess.run([...], capture_output=True, text=True, timeout=15)
if result.returncode != 0:
    print(f"warn: worktree add failed: {result.stderr.strip()}", file=sys.stderr)
```

### Step 6.4 — GREEN: Add return code check to prune (line 445-449)

```python
subprocess.run([...], capture_output=True, timeout=15)
```
→ Add return code check: `if result.returncode != 0: print warning`.

### Step 6.5 — MERGED: Phase 6 complete

Commit.

---

## Phase 7: Integration Verification (p7_integration_verification)

**Concern:** Verify all SCs pass. Run the full suite of behavioral and string tests.

### Step 7.1 — RED: No tests exist yet; baseline check

```
test -f .opencode/tests/behaviors/local-issues-chdir.sh && echo "exists" || echo "missing"
```
→ Expect "missing" (RED phase creates the test).

### Step 7.2 — GREEN: Write behavioral+string enforcement tests

Create `.opencode/tests/behaviors/local-issues-chdir.sh` with:

| SC | Type | Test |
|----|------|------|
| SC-1 | behavioral | `local-issues create --number .opencode#1125 --title "test"` → verify issue dir at `.opencode/.issues/1125-test/` |
| SC-2 | string | `grep -c "os.chdir" tools/local-issues` → 0 |
| SC-3 | behavioral | `_resolve_repo_name()` returns correct names for root, submodule, standalone |
| SC-4 | string | `grep -c "except Exception:" tools/local-issues` → 0 |
| SC-5 | string | `grep "while.*name.*!=\".opencode\"` → 1 (walk-up-to-.opencode used) |
| SC-6 | behavioral | `list`, `search`, `read` output shows correct qualifier for submodules |
| SC-7 | behavioral | `create --number 1125` bare creates in current repo with correct label |
| SC-8 | behavioral | `sync`, `init` commands function correctly |
| SC-9 | string | Each worktree/auto-commit failure produces diagnostic |

**SC-specific assertion pattern:**
```bash
# SC-1: create --number .opencode#1125 writes to correct path
# SC-2: zero os.chdir calls
# SC-3: correct repo name resolution
# SC-4: zero bare except Exception
# SC-5: walk-up-to-.opencode used for PROJECT_DIR
```

### Step 7.3 — REFACTOR: Run full test suite

```bash
bash .opencode/tests/behaviors/local-issues-chdir.sh
```

### Step 7.4 — MERGED: All SCs verified PASS

Commit final test artifact.

---

## Success Criteria Summary

| ID | Criterion | Phase | Type | Verification |
|----|-----------|-------|------|-------------|
| SC-1 | `create --number .opencode#N` creates at correct path with correct label | p7 | behavioral | enforcement test |
| SC-2 | Zero `os.chdir()` calls in file | p3 | string | grep count = 0 |
| SC-3 | `_resolve_repo_name()` resolves correctly for all repo types | p2 | behavioral | enforcement test |
| SC-4 | No bare `except Exception: pass` remains | p5 | string | grep count = 0 |
| SC-5 | Walk-up-to-`.opencode` method used for PROJECT_DIR | p1 | string | grep pattern match |
| SC-6 | list/search/read correct qualifiers | p7 | behavioral | enforcement test |
| SC-7 | Bare `create --number N` works in current repo | p7 | behavioral | enforcement test |
| SC-8 | sync/init function across root+child repos | p7 | behavioral | enforcement test |
| SC-9 | Worktree/auto-commit emit diagnostics on failure | p6 | string | grep diagnostic pattern |

## Dependency Graph

```
p1 (PROJECT_DIR global)
 └─ p2 (resolve_repo_name — no longer depends on script path)
     └─ p3 (remove chdir — callers use returned paths)
         └─ p4 (replace relative ISSUES_DIR — use repo_path / ".issues")
             └─ p5 (eliminate bare except)
                 ├─ p6 (worktree error handling)
                 └─ p7 (integration verification)
```

**Z3 contract:** SAT — linear chain, all postconditions satisfiable.