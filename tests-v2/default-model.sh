# Default model for ALL opencode test runs. NO MODEL CHANGES — NO EXCEPTIONS.
# Failures are remediated through the R-18 defect classes or re-scoped at the
# spec — never by substituting a model (tests-v2/AGENTS.md §9, R-20).
# Single source of truth — do not embed model strings elsewhere.
DEFAULT_TEST_MODEL="${DEFAULT_TEST_MODEL:-ollama/qwen3.8:27b-128k-gguf4}"
