#!/usr/bin/env python3
"""PreToolUse hook: enforce Conventional Commits on `git commit -m ...`.

Reads the standard hook JSON from stdin. Only reacts when the Bash command
being executed is a `git commit` invocation that supplies a message via
-m / --message. Interactive `git commit` (no -m, opens editor) is allowed
through unchanged.

On a malformed message, exits 2 and prints a helpful error to stderr so
Claude can rewrite the commit and retry.
"""

import json
import re
import shlex
import sys

ALLOWED_TYPES = (
    "feat",
    "fix",
    "docs",
    "style",
    "refactor",
    "perf",
    "test",
    "build",
    "ci",
    "chore",
    "revert",
)

PATTERN = re.compile(r"^(?:" + "|".join(ALLOWED_TYPES) + r")(?:\([^)]+\))?!?: .+")

HEREDOC_RE = re.compile(
    r"<<-?\s*['\"]?(\w+)['\"]?\s*\n(.*?)\n\s*\1\b",
    re.DOTALL,
)


def extract_message(command: str) -> str | None:
    """Pull the first line of the commit subject out of a git commit command."""
    m = HEREDOC_RE.search(command)
    if m:
        body = m.group(2).strip()
        if body:
            return body.splitlines()[0]

    try:
        tokens = shlex.split(command, posix=True)
    except ValueError:
        return None

    i = 0
    while i < len(tokens):
        tok = tokens[i]
        if tok in ("-m", "--message"):
            if i + 1 < len(tokens) and tokens[i + 1]:
                return tokens[i + 1].splitlines()[0]
        elif tok.startswith("-m") and len(tok) > 2:
            return tok[2:].splitlines()[0]
        elif tok.startswith("--message="):
            return tok[len("--message="):].splitlines()[0]
        i += 1

    return None


def is_git_commit(command: str) -> bool:
    return bool(re.search(r"(?:^|[\s&|;`(])git\s+commit(?:\s|$)", command))


def has_message_flag(command: str) -> bool:
    return bool(re.search(r"(?:^|\s)(?:-m\b|--message\b|--message=)", command))


def main() -> int:
    try:
        data = json.load(sys.stdin)
    except Exception:
        return 0

    if data.get("tool_name") != "Bash":
        return 0

    command = (data.get("tool_input") or {}).get("command") or ""
    if not command or not is_git_commit(command):
        return 0

    if not has_message_flag(command):
        return 0

    msg = extract_message(command)
    if not msg:
        return 0

    if PATTERN.match(msg):
        return 0

    print(
        "[conventional-commit] commit message does not follow Conventional Commits",
        file=sys.stderr,
    )
    print("", file=sys.stderr)
    print(f"  Got:      {msg}", file=sys.stderr)
    print("", file=sys.stderr)
    print("  Expected: <type>(<optional scope>): <description>", file=sys.stderr)
    print("", file=sys.stderr)
    print("  Allowed types:", file=sys.stderr)
    print(f"    {', '.join(ALLOWED_TYPES)}", file=sys.stderr)
    print("", file=sys.stderr)
    print("  Examples:", file=sys.stderr)
    print("    feat(auth): add OAuth2 login flow", file=sys.stderr)
    print("    fix(api): handle 404 in items endpoint", file=sys.stderr)
    print("    docs: update CLAUDE.md hook section", file=sys.stderr)
    print("    chore(deps): bump fastapi to 0.110", file=sys.stderr)
    print("", file=sys.stderr)
    print("  Reference: https://www.conventionalcommits.org", file=sys.stderr)
    return 2


if __name__ == "__main__":
    sys.exit(main())
