---
name: create-issue
description: Create a new Jira issue in the TPM project. Use when the user says "create ticket", "new issue", "make a ticket", or "register a bug/task/story".
argument-hint: "[summary]"
disable-model-invocation: true
allowed-tools: mcp__atlassian__createJiraIssue mcp__atlassian__getJiraProjectIssueTypesMetadata mcp__atlassian__getJiraIssueTypeMetaWithFields mcp__atlassian__lookupJiraAccountId
---

# create-issue

Create a new Jira issue in the TPM project with guided input.

## Usage

```
/create-issue [summary]
```

- `summary` (optional): If provided, use as the issue summary. Otherwise, ask the user.

## Execution

### 1. Gather issue type metadata

Call `mcp__atlassian__getJiraProjectIssueTypesMetadata` for project `TPM` to get available issue types and their required fields.

### 2. Collect issue details

Ask the user for the following (skip fields already provided):

| Field       | Required | Default          | Notes                              |
|-------------|----------|------------------|------------------------------------|
| Summary     | Yes      | `$ARGUMENTS`     | Short, descriptive title           |
| Type        | Yes      | Task             | Task / Bug / Story / Epic / Subtask |
| Description | Yes      | --               | Detailed explanation               |
| Priority    | No       | Medium           | Highest / High / Medium / Low / Lowest |
| Assignee    | No       | Current user     | Use `lookupJiraAccountId` to resolve |
| Labels      | No       | --               | Comma-separated                    |
| Sprint      | No       | --               | Current sprint if specified        |
| Parent      | No       | --               | Parent issue key for subtasks      |

### 3. Confirm with user

Present the issue details for confirmation:

```
## New Issue Preview

| Field       | Value              |
|-------------|--------------------|
| Project     | TPM                |
| Type        | <type>             |
| Summary     | <summary>          |
| Priority    | <priority>         |
| Assignee    | <assignee>         |
| Labels      | <labels>           |

### Description
<description>
```

Ask: Create this issue? (Y/N/Edit)

### 4. Create issue

Call `mcp__atlassian__createJiraIssue` with the collected fields.

### 5. Report

```
## Issue Created

| Field   | Value      |
|---------|------------|
| Key     | <TPM-xxx>  |
| Summary | <summary>  |
| Type    | <type>     |
| Status  | <status>   |
```

## Important Guidelines

- Always confirm with the user before creating.
- `disable-model-invocation: true` -- this skill is manual-only to prevent accidental ticket creation.
- Respond in Korean.
