---
name: commit-push
description: Stage changes, generate a commit message from the diff, commit, and push to the fork's remote branch. Use when the user says "커밋", "푸시", "commit", "push", or "올려줘".
---

# commit-push

Analyze the current diff, generate a commit message, commit, and push to origin.

## Usage

```
/commit-push [message]
```

- `message` (optional): If provided, use this as the commit message instead of auto-generating.

## Preconditions

- The current directory is inside a git repository.
- There are staged or unstaged changes to commit. If no changes, inform the user and abort.
- The current branch is NOT `master`. If on master, warn the user and abort — work should be on a feature branch.

---

## 1. Inspect changes

Run in parallel:

```bash
git status --short
git branch --show-current
git diff --stat
git diff --cached --stat
```

Validation:

| Check | Action on failure |
|-------|-------------------|
| Has changes (staged or unstaged) | Abort — nothing to commit |
| Not on `master` branch | Abort — create a branch first via `/create-branch` |
| Branch tracks a remote | OK if not — will push with `-u` |

## 2. Stage changes

If there are unstaged changes, show the list and ask the user:

- **A)** Stage all changes (`git add -A`)
- **B)** Stage specific files (list them for selection)

Sensitive files (`.env`, `credentials`, `*secret*`, `*.key`) must NEVER be staged. If detected, warn the user and exclude them.

## 3. Generate commit message

If no message was provided, analyze the diff:

```bash
git diff --cached
git diff --cached --stat
```

### Commit message format

```
<type>: <subject>

<body>
```

**Type** — infer from the diff:

| Type | When |
|------|------|
| `feat` | New files, new functions, new endpoints |
| `fix` | Bug fixes, error corrections |
| `refactor` | Code restructuring without behavior change |
| `docs` | Documentation, comments only |
| `test` | Test files only |
| `chore` | Config, dependencies, CI/CD |
| `style` | Formatting, whitespace only |

**Subject rules:**
- Korean, max 50 characters
- No period at end
- Imperative mood

**Body rules:**
- Korean, wrap at 72 characters
- Explain *why*, not *what* (the diff shows what)
- List key changes with `-` bullets
- 2-5 lines max

### Example

```
feat: 파일 업로드 API 추가

- POST /api/files 엔드포인트 구현
- FileService에 upload_file 메서드 추가
- 최대 파일 크기 10MB 제한 적용
```

## 4. Confirm with user

Show the draft commit message:

```
Branch: <branch-name>
Files: <n> changed (+<added> / -<removed>)

Commit message:
<generated message>
```

Apply any edits the user requests. **Never commit without confirmation.**

## 5. Commit and push

```bash
git commit -m "<message>"
git push -u origin <branch-name>
```

If push fails due to remote being ahead:

1. `git pull --rebase origin <branch-name>`
2. Resolve conflicts if any (inform user)
3. `git push origin <branch-name>`

## 6. Report

```
## 커밋 & 푸시 완료

| 항목 | 값 |
|------|-----|
| Branch | <branch-name> |
| Commit | <short-hash> |
| Message | <subject line> |
| Files | <n> changed (+<added> / -<removed>) |
| Remote | origin/<branch-name> |
```

---

## Important Guidelines

- **Never commit to `master`.** Always work on a feature branch.
- **Never stage sensitive files.** Warn and exclude `.env`, credentials, keys.
- **Require user confirmation** before committing.
- **No AI attribution.** Never add `Co-Authored-By: Claude` or similar strings.
- **Korean commit messages.** Technical terms (API, CI/CD, file paths) stay as-is.
- **Do not amend** existing commits unless explicitly asked.
