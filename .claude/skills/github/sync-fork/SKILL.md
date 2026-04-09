---
name: sync-fork
description: Synchronize both reference/ and work/ directories with upstream. Run this before starting any work — coding, analysis, review, or any git operation.
---

# sync-fork

Synchronize reference (upstream) and work (fork) directories to ensure you are working on the latest code.

## Usage

```
/sync-fork [repo-name]
```

- `repo-name` (optional): Specific repo to sync. If omitted, syncs the repo in the current directory.

## Preconditions

- The target repo must exist in either `reference/` or `work/` (or both).
- `gh` CLI is installed and authenticated.

---

## 1. Determine target repo

- If `repo-name` is provided, locate it in `reference/` and `work/`.
- If omitted, detect from current working directory.
- If the repo is not found in either location, abort and inform the user.

## 2. Sync reference/ (upstream pull)

If the repo exists in `reference/`:

```bash
cd reference/<topic>/<repo-name>
git pull origin master
```

**NEVER modify any files under `reference/`.** Only `git pull` is allowed.

## 3. Sync work/ (fork sync + pull)

If the repo exists in `work/`:

### 3-1. Check repository state

Run in parallel:

```bash
git rev-parse --show-toplevel
git remote -v
git status --short
git branch --show-current
```

Validation:

| Check | Action on failure |
|-------|-------------------|
| Inside a git repo | Abort and inform the user |
| `upstream` remote exists | Add it: `git remote add upstream https://github.com/mzc-cloudops-v2/<repo-name>.git` |
| Working tree is clean | Stash changes automatically with `git stash -m "sync-fork auto-stash"` and inform the user |

### 3-2. Fetch and merge upstream

```bash
git fetch upstream
git checkout master
git merge upstream/master --ff-only
```

If fast-forward merge fails (diverged history):

1. Warn the user about the divergence.
2. Ask whether to force-reset to upstream/master or abort.
3. Only proceed with `git reset --hard upstream/master` after explicit confirmation.

### 3-3. Push to origin

```bash
git push origin master
```

### 3-4. Return to working branch

If the user was on a branch other than `master`:

```bash
git checkout <original-branch>
git rebase master
```

If rebase conflicts occur, inform the user and provide guidance.

### 3-5. Restore stashed changes

If changes were auto-stashed:

```bash
git stash pop
```

If pop conflicts, inform the user.

## 4. Report

```
## 동기화 완료

| 대상 | 상태 |
|------|------|
| reference/<topic>/<repo> | OK Updated / SKIP Not found |
| work/<topic>/<repo> | OK Updated / SKIP Not found |
| Branch | <current-branch> |
| Stash | <restored / none> |
```

---

## Important Guidelines

- **This skill should run before any work.** Claude must suggest running `/sync-fork` when starting coding, analysis, or review tasks.
- **NEVER modify files under `reference/`.** Only `git pull` is allowed there.
- **Never force-reset without user confirmation.**
- **Auto-stash is silent** — always inform the user that changes were stashed and restored.
- **Do not include AI attribution** in any output.
