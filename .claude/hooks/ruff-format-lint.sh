#!/bin/bash
# PostToolUse hook: run ruff format + ruff check --fix on edited Python files.
# If lint errors remain after auto-fix, exit 2 to feed errors back to Claude.
#
# Input : JSON on stdin (uses tool_input.file_path)
# Exit  : 0 - pass (regardless of whether the file was reformatted)
#         2 - lint errors remain -- Claude must fix and retry
#         1 - environment error (e.g. ruff missing); non-blocking

set -u

INPUT="$(cat)"

# jq missing -- non-blocking skip
if ! command -v jq >/dev/null 2>&1; then
  echo "[ruff-format-lint] jq not found; skipping" >&2
  exit 1
fi

FILE_PATH="$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // empty')"

# Skip when no file path, not a .py file, or file does not exist
if [[ -z "$FILE_PATH" ]]; then
  exit 0
fi
if [[ "$FILE_PATH" != *.py ]]; then
  exit 0
fi
if [[ ! -f "$FILE_PATH" ]]; then
  exit 0
fi

# ruff missing -- non-blocking warning
if ! command -v ruff >/dev/null 2>&1; then
  echo "[ruff-format-lint] ruff not found in PATH; skipping" >&2
  exit 1
fi

REL_PATH="${FILE_PATH#$PWD/}"

# 1) Apply formatting
FORMAT_OUT="$(ruff format "$FILE_PATH" 2>&1)"
FORMAT_RC=$?
if [[ $FORMAT_RC -ne 0 ]]; then
  {
    echo "[ruff-format-lint] ruff format failed: $REL_PATH"
    echo "$FORMAT_OUT"
  } >&2
  exit 2
fi

# 2) Auto-fix what ruff can fix
ruff check --fix --quiet "$FILE_PATH" >/dev/null 2>&1 || true

# 3) Check for remaining errors
CHECK_OUT="$(ruff check "$FILE_PATH" 2>&1)"
CHECK_RC=$?

if [[ $CHECK_RC -ne 0 ]]; then
  {
    echo "[ruff-format-lint] lint errors remain in $REL_PATH"
    echo "----"
    echo "$CHECK_OUT"
    echo "----"
    echo "Fix the errors above and save again. The hook will re-run automatically."
  } >&2
  exit 2
fi

# Pass: surface status to transcript via stderr
if [[ "$FORMAT_OUT" == *"reformatted"* ]] || [[ "$FORMAT_OUT" == *"formatted"* ]]; then
  echo "[ruff-format-lint] formatted + lint clean: $REL_PATH" >&2
else
  echo "[ruff-format-lint] lint clean: $REL_PATH" >&2
fi

exit 0
