---
name: create-branch
description: Set up a working copy and create a new branch for a task. Forks and clones the repo into work/ if needed, syncs with upstream, and creates a branch based on task description or Jira issue key.
---

# create-branch

Set up the working environment and create a new branch. Handles fork, clone, sync, and branch creation in one step.

## Usage

```
/create-branch <repo-name> <description-or-jira-key>
```

- `repo-name`: Repository name in `mzc-cloudops-v2` org (required)
- `description-or-jira-key`: A Jira issue key (e.g. `TPM-123`) or a free-text task description (required)

## Preconditions

- `gh` CLI is installed and authenticated.
- The repo must exist in `mzc-cloudops-v2` org.

---

## 1. Ensure work/ directory exists

Check if `work/` directory has the repo:

```bash
# Determine topic-based destination
REPO_JSON="$(gh repo view mzc-cloudops-v2/<repo-name> --json name,repositoryTopics)"
```

Topic mapping:
- `core` topic → `work/cores/<repo-name>`
- `plugin` topic → `work/plugins/<repo-name>`
- neither → `work/others/<repo-name>`

### If work directory does NOT exist → Fork + Clone

1. Fork with prefix `{org}-` (e.g. `mzc-cloudops-v2-console-api-v2`):

```bash
MY_ACCOUNT="$(gh api user --jq '.login')"
FORK_NAME="mzc-cloudops-v2-<repo-name>"

# Fork if not exists
gh repo fork "mzc-cloudops-v2/<repo-name>" --fork-name "${FORK_NAME}" --clone=false

# Clone into work/
gh repo clone "${MY_ACCOUNT}/${FORK_NAME}" "work/<topic>/<repo-name>"
```

2. Verify `upstream` remote is set:

```bash
cd work/<topic>/<repo-name>
git remote -v | grep upstream || echo "ERROR: upstream not configured"
```

If `upstream` is missing:
```bash
git remote add upstream https://github.com/mzc-cloudops-v2/<repo-name>.git
```

### If work directory exists → Sync only

Proceed to step 2.

## 2. Sync with upstream

```bash
cd work/<topic>/<repo-name>
git fetch upstream
git checkout master
git merge upstream/master --ff-only
git push origin master
```

If fast-forward fails, warn the user and ask whether to force-reset or abort.

## 3. Determine branch name

### If a Jira issue key is provided (matches `[A-Z]+-[0-9]+`)

1. Fetch the issue via `mcp__atlassian__getJiraIssue` (site: `mzdevs.atlassian.net`).
2. Extract `issuetype.name` and `summary`.
3. Generate branch name:

| Issue type | Prefix |
|------------|--------|
| Bug | `fix/` |
| Task, Sub-task | `feat/` |
| Story | `feat/` |
| Improvement | `imp/` |
| Other | `feat/` |

Format: `<prefix><ISSUE-KEY>-<slugified-summary>`

Example: `feat/TPM-123-add-file-upload-api`

### If free text is provided

1. Infer the type from keywords:
   - "fix", "bug", "error", "오류" → `fix/`
   - "refactor", "리팩토링" → `refactor/`
   - "docs", "문서" → `docs/`
   - "test", "테스트" → `test/`
   - otherwise → `feat/`
2. Slugify the description (lowercase, spaces → hyphens, max 50 chars, ASCII only).

Format: `<prefix><slugified-description>`

Example: `feat/add-file-upload-api`

## 4. Confirm with user

Present the plan before executing:

```
Repo: mzc-cloudops-v2/<repo-name>
Work dir: work/<topic>/<repo-name>
Branch: <generated-branch-name>
Base: upstream/master (synced)
```

Apply any edits the user requests. **Never create the branch without confirmation.**

## 5. Create and push

```bash
git checkout -b <branch-name>
git push -u origin <branch-name>
```

## 6. Report

```
## Branch 생성 완료

| 항목 | 값 |
|------|-----|
| Repo | mzc-cloudops-v2/<repo-name> |
| Work dir | work/<topic>/<repo-name> |
| Fork | <account>/<fork-name> |
| Branch | <branch-name> |
| Base | upstream/master |
| Jira Issue | <issue key 또는 없음> |
```

---

## Important Guidelines

- **Always sync upstream first** before branching.
- **Require user confirmation** before creating the branch.
- **Branch names are ASCII only** — transliterate Korean to English.
- **Max 60 characters** for the full branch name.
- **NEVER modify files under `reference/`.** Only `work/` is for editing.
- **Do not include AI attribution** in any output.
