---
name: setup-check
description: Verify and install required development tools (Python 3.10, gh, ruff, Atlassian MCP) with IDE-specific configuration for consistent environments.
disable-model-invocation: false
---

# Development Environment Setup & Verification

Verify the installation, authentication, and configuration of all required development tools.
For each tool, run the check commands, report the result, and if anything is missing, proceed to install or guide the user through setup.

---

## 1. Python 3.10

### 1-1. Check if Python 3.10 is installed

```bash
python3.10 --version 2>/dev/null
```

If the command fails or returns a version other than 3.10.x, Python 3.10 is not installed.

Also check if pyenv is available (preferred method for managing Python versions):
```bash
which pyenv && pyenv versions 2>/dev/null
```

### 1-2. Install Python 3.10

**Option A — via pyenv (preferred):**

Check if pyenv is installed:
```bash
which pyenv
```

If pyenv is NOT installed:
```bash
brew install pyenv
```

After pyenv is available, install Python 3.10:
```bash
pyenv install 3.10
```

Then set it as the local version for this project:
```bash
pyenv local 3.10
```

This creates a `.python-version` file in the project root. Verify:
```bash
python3.10 --version
pyenv which python3.10
```

**Option B — via Homebrew (fallback if user does not want pyenv):**
```bash
brew install python@3.10
```

After installation, verify:
```bash
python3.10 --version
```

### 1-3. Verify Python 3.10 is active

```bash
python3.10 --version
```

The output must show `Python 3.10.x`. If the user has pyenv configured, also confirm:
```bash
cat .python-version 2>/dev/null
```

If `.python-version` exists, it should contain `3.10` or a specific `3.10.x` version.

---

## 2. GitHub CLI (gh)

### 1-1. Check installation

```bash
which gh && gh --version
```

- If `gh` is NOT found → install via Homebrew:
  ```bash
  brew install gh
  ```
- After installation, verify again with `which gh && gh --version`.

### 1-2. Check authentication

```bash
gh auth status
```

Look for `✓ Logged in to github.com`. If NOT logged in, guide the user through interactive login.

Tell the user to run the following command themselves (it requires interactive input):

```
! gh auth login --web -p https
```

**Expected login flow:**
1. User runs the command above
2. A one-time code is displayed in the terminal
3. Browser opens automatically to https://github.com/login/device
4. User enters the one-time code in the browser
5. User authorizes the GitHub CLI
6. Terminal shows `✓ Logged in to github.com`

After the user completes login, verify:
```bash
gh auth status
```

### 1-3. Verify token scopes

```bash
gh auth status 2>&1 | grep "Token scopes"
```

Required scopes: `repo`, `read:org`, `workflow`. If scopes are insufficient, tell the user:
```
! gh auth refresh -s repo,read:org,workflow
```

---

## 3. Ruff (Python formatter & linter)

### 3-1. Check installation

```bash
which ruff && ruff version
```

- If `ruff` is NOT found → install via Homebrew:
  ```bash
  brew install ruff
  ```
- After installation, verify again with `which ruff && ruff version`.

### 3-2. Check IDE configuration

Detect which IDEs are installed and check their Ruff settings.

#### Detect installed IDEs

```bash
# VS Code
code --version 2>/dev/null && echo "VSCODE_INSTALLED=true" || echo "VSCODE_INSTALLED=false"

# Cursor
cursor --version 2>/dev/null && echo "CURSOR_INSTALLED=true" || echo "CURSOR_INSTALLED=false"

# PyCharm (macOS)
ls /Applications/ | grep -i pycharm && echo "PYCHARM_INSTALLED=true" || echo "PYCHARM_INSTALLED=false"
```

#### 3-2a. VS Code configuration

**Check if the Ruff extension is installed:**
```bash
code --list-extensions 2>/dev/null | grep -i "charliermarsh.ruff"
```

If NOT installed:
```bash
code --install-extension charliermarsh.ruff
```

**Check settings.json for format-on-save:**
Read the user-level settings file:
- macOS: `~/Library/Application Support/Code/User/settings.json`

Also check the project-level settings:
- `<project-root>/.vscode/settings.json`

The following settings MUST be present. Check both files — project-level settings override user-level:

```json
{
  "[python]": {
    "editor.defaultFormatter": "charliermarsh.ruff",
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": {
      "source.organizeImports.ruff": "explicit"
    }
  }
}
```

If these settings are missing from BOTH files, create or update the **project-level** `.vscode/settings.json` to include them. When updating, merge with existing content — do NOT overwrite other settings.

#### 3-2b. Cursor configuration

Cursor is a VS Code fork and uses the same settings system and extensions.

**Check if the Ruff extension is installed:**
```bash
cursor --list-extensions 2>/dev/null | grep -i "charliermarsh.ruff"
```

If NOT installed:
```bash
cursor --install-extension charliermarsh.ruff
```

**Check settings.json for format-on-save:**
Read the user-level settings file:
- macOS: `~/Library/Application Support/Cursor/User/settings.json`

Cursor also reads the project-level `.vscode/settings.json` (NOT `.cursor/settings.json`).

Required settings are identical to VS Code:

```json
{
  "[python]": {
    "editor.defaultFormatter": "charliermarsh.ruff",
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": {
      "source.organizeImports.ruff": "explicit"
    }
  }
}
```

If these settings are missing, create or update the **project-level** `.vscode/settings.json` (shared with VS Code). Merge with existing content.

#### 3-2c. PyCharm configuration

PyCharm 2024.2+ has built-in Ruff support for linting. For format-on-save, a File Watcher is required.

**Check if File Watchers are configured:**
Read `<project-root>/.idea/watcherTasks.xml` if it exists and look for a watcher with program `ruff`.

If no ruff File Watcher exists, inform the user they need to configure it manually in PyCharm:

**File Watcher 1 — Ruff Format:**

| Field | Value |
|-------|-------|
| Name | `Ruff Format` |
| File type | `Python` |
| Scope | `Project Files` |
| Program | `ruff` |
| Arguments | `format $FilePath$` |
| Output paths to refresh | `$FilePath$` |
| Working directory | `$ProjectFileDir$` |
| Auto-save edited files to trigger the watcher | OK checked |

**File Watcher 2 — Ruff Organize Imports:**

| Field | Value |
|-------|-------|
| Name | `Ruff Organize Imports` |
| File type | `Python` |
| Scope | `Project Files` |
| Program | `ruff` |
| Arguments | `check --select I --fix $FilePath$` |
| Output paths to refresh | `$FilePath$` |
| Working directory | `$ProjectFileDir$` |

Also remind the user to enable built-in Ruff support:
**Settings → Tools → Ruff → Enable Ruff** (check the box).

---

## 4. Atlassian MCP

### 4-1. Check if configured

```bash
claude mcp list
```

Look for an `atlassian` entry in the output.

- If `atlassian` is NOT listed → add it:
  ```bash
  claude mcp add --transport http atlassian https://mcp.atlassian.com/v1/mcp
  ```
- After adding, verify with `claude mcp list` again.

### 4-2. Check connection status

From the `claude mcp list` output, check the status of the `atlassian` entry:

- `✓ Connected` → all good
- `! Needs authentication` → guide the user through authentication:

**Atlassian MCP Authentication Flow (user must do this manually):**

1. Type `/mcp` in Claude Code to open MCP settings
2. Select `atlassian` (it will show "Needs authentication")
3. A web browser will open automatically
4. Select the `mzdevs` domain
5. Confirm "Authentication Successful" screen
6. Return to Claude Code

Tell the user:
> Please run `/mcp` and select `atlassian` to complete authentication. After you see "Authentication Successful" in the browser, come back here and I'll verify the connection.

After user confirms, verify again:
```bash
claude mcp list
```

---

## Output Format

After all checks are complete, present the results in this table:

```
## Development Environment Status
| Tool            | Status | Details                          |
|-----------------|--------|----------------------------------|
| Python 3.10     | OK/FAIL  | version, install method (pyenv/brew) |
| gh              | OK/FAIL  | version, logged-in account       |
| ruff            | OK/FAIL  | version                          |
| ruff (VS Code)  | OK/FAIL/SKIP | extension + format-on-save      |
| ruff (Cursor)   | OK/FAIL/SKIP | extension + format-on-save      |
| ruff (PyCharm)  | OK/FAIL/SKIP | file watcher config             |
| Atlassian MCP   | OK/FAIL  | connection status                |
```

Use SKIP for IDEs that are not installed (skipped).

If any items required installation or configuration changes, list what was done at the end.

---

## Troubleshooting

For detailed troubleshooting guides, see the docs directory:
- [T-1. Python 3.10 dyld freeze fix](${CLAUDE_SKILL_DIR}/docs/python310-dyld-fix.md) -- `python3.10` hangs at `_dyld_start` on macOS 26+ with pyenv ad-hoc binary
