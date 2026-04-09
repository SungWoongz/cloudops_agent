---
name: get-repo
description: Clone an upstream repo into the reference/ directory for read-only analysis and code review. Never modifies reference code.
---

# get-repo

Clone an upstream repo into the `reference/` directory for read-only analysis. This is NOT for working — use `/create-branch` to start work.

## Usage

```
/get-repo <repo-name> [org]
```

- `repo-name`: Repository name (required)
- `org`: GitHub organization (optional, default: `mzc-cloudops-v2`)

## Execution

Run the bundled script:

```bash
${CLAUDE_SKILL_DIR}/scripts/get-repo.sh <repo-name> [org] <project-root>
```

- `$1` = `$ARGUMENTS` (first argument: repo name)
- `$2` = second argument if provided, otherwise defaults to `mzc-cloudops-v2`
- `$3` = project root (pass the current working directory)

## What the script does

1. Validates the target repo exists via `gh repo view`
2. Reads repo topics to determine clone destination:
   - `core` topic → `reference/cores/`
   - `plugin` topic → `reference/plugins/`
   - neither → `reference/others/`
3. Clones the upstream repo directly (NO fork)
4. Reports results

## After execution

Present the script output to the user. If the script fails, show the error and suggest fixes.

## CRITICAL RULE

**NEVER modify any files under `reference/`.** This directory is strictly read-only for analysis and code review purposes.
