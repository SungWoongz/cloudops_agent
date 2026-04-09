#!/usr/bin/env python3
"""3-Layer architecture violation checker.

Enforces the dependency direction used by FastAPI service projects:

    interface (REST router)  ->  service (business logic)  ->  manager (data access)

Rules:
  - files under .../manager/  must NOT import .../service/ or .../interface/
  - files under .../service/  must NOT import .../interface/
  - files under .../interface/ must NOT import .../manager/ (must go via service)

Triggered as a PostToolUse hook on Edit|Write|MultiEdit. Reads the standard
hook JSON from stdin, decides which layer the edited file belongs to, and
parses its imports with ast. Exits 2 with a structured error message when a
violation is found so Claude can fix it and retry.
"""

import ast
import json
import os
import sys

LAYERS = ("interface", "service", "manager")

FORBIDDEN = {
    "manager": ("service", "interface"),
    "service": ("interface",),
    "interface": ("manager",),
}


def detect_layer(path):
    parts = path.replace("\\", "/").split("/")
    for part in reversed(parts):
        if part in LAYERS:
            return part
    return None


def collect_imports(tree):
    modules = []
    for node in ast.walk(tree):
        if isinstance(node, ast.ImportFrom):
            if node.module:
                modules.append((node.lineno, node.module))
        elif isinstance(node, ast.Import):
            for alias in node.names:
                modules.append((node.lineno, alias.name))
    return modules


def main():
    try:
        data = json.load(sys.stdin)
    except Exception:
        return 0

    file_path = (data.get("tool_input") or {}).get("file_path") or ""
    if not file_path or not file_path.endswith(".py") or not os.path.isfile(file_path):
        return 0

    layer = detect_layer(file_path)
    if not layer:
        return 0

    forbidden = FORBIDDEN[layer]

    try:
        with open(file_path, encoding="utf-8") as f:
            source = f.read()
        tree = ast.parse(source, filename=file_path)
    except SyntaxError:
        return 0
    except Exception:
        return 0

    violations = []
    for lineno, mod in collect_imports(tree):
        parts = mod.split(".")
        for target in forbidden:
            if target in parts:
                violations.append((lineno, mod, target))
                break

    if not violations:
        return 0

    try:
        rel = os.path.relpath(file_path)
    except ValueError:
        rel = file_path

    print(
        f"[check-3layer] architecture violation in {rel} (layer: {layer})",
        file=sys.stderr,
    )
    print("----", file=sys.stderr)
    for lineno, mod, target in violations:
        print(
            f"  line {lineno}: imports `{mod}`  (forbidden layer: {target})",
            file=sys.stderr,
        )
    print("----", file=sys.stderr)
    print(
        f"Layer `{layer}` may NOT depend on: {', '.join(forbidden)}",
        file=sys.stderr,
    )
    print(
        "Required dependency direction: interface -> service -> manager",
        file=sys.stderr,
    )
    print(
        "Refactor the offending import(s) so the dependency flows downward only, "
        "then save again.",
        file=sys.stderr,
    )
    return 2


if __name__ == "__main__":
    sys.exit(main())
