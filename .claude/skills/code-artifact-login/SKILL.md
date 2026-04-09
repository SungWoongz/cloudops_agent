---
name: code-artifact-login
description: Authenticate pip against AWS CodeArtifact so private packages can be installed. Token is valid for 12 hours. Use when pip returns 401 or user says "codeartifact", "pip login", "aws login".
disable-model-invocation: true
allowed-tools: Bash(.claude/skills/code-artifact-login/scripts/code-artifact-login.sh:*)
---

# code-artifact-login

Authenticate pip against an AWS CodeArtifact repository by running `aws codeartifact login --tool pip`.

## Usage

```
/code-artifact-login
```

No arguments. All configuration is read from environment variables (auto-loaded from `.env.local` via SessionStart hook).

## Preconditions

- AWS CLI is installed and the target profile is configured.
- Required environment variables are set in `.env.local`:

| Variable | Example | Purpose |
|----------|---------|---------|
| `AWS_ACCOUNT_ID` | `123456789012` | Passed as `--domain-owner` |
| `CODEARTIFACT_DOMAIN` | `mzc-cloudops` | CodeArtifact domain name |
| `CODEARTIFACT_REPO` | `cloudops-pypi` | CodeArtifact repository name |

Optional overrides:

| Variable | Default |
|----------|---------|
| `AWS_PROFILE` | `sandbox` |
| `CODEARTIFACT_REGION` | `ap-northeast-2` |

## Execution

Run the bundled script:

```bash
.claude/skills/code-artifact-login/scripts/code-artifact-login.sh
```

The script:
1. Verifies all required environment variables are set.
2. Verifies AWS CLI is installed and the target profile is configured.
3. Runs `aws codeartifact login --tool pip` with the configured parameters.
4. On success, pip's `global.index-url` points at the authenticated CodeArtifact endpoint (valid for 12 hours).

## Report

Surface the script output verbatim. On success, confirm the repository name and 12-hour expiry. On failure, show the error and suggest running `/setup-check`.

## Important Guidelines

- Never commit AWS_ACCOUNT_ID, CODEARTIFACT_DOMAIN, or CODEARTIFACT_REPO values into this repository.
- Token expiry is 12 hours. A pip `401 Unauthorized` almost always means the token has expired -- rerun this skill.
- Respond in Korean.
