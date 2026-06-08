# Task: selection-guide

## Purpose

Notebook operations use the-notebook-mcp exclusively. Guideline text uses .opencode/tools/guidelines. The rest is tool-description-driven.

## Srclight Setup and Troubleshooting

If srclight reports missing index or errors:

```bash
uvx srclight index --embed qwen3-embedding
```

### Manual Operations

```bash
# Check index status
uvx srclight status

# Search symbols
uvx srclight search "function_name"

# Reindex after major changes
uvx srclight index --embed qwen3-embedding
```

### Troubleshooting

| Error | Solution |
|-------|----------|
| "Index not found" | Run `uvx srclight index --embed qwen3-embedding` |
| "Cannot reach Ollama" | Start Ollama: `ollama serve` |
| "Model not found" | Pull model: `ollama pull qwen3-embedding` |
| "No semantic results" | Reindex with embeddings: `uvx srclight index --embed qwen3-embedding` |

## File-Type Tool Boundaries

| File Extension | Linter | Formatter |
|----------------|--------|-----------|
| `.py` | `ruff check` | `ruff format` |
| `.md` | `pymarkdownlnt scan` | `mdformat` |

**CRITICAL:** Never run `ruff` on `.md` files. Never run `pymarkdownlnt` on `.py` files.