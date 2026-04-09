---
name: get-issue
description: Retrieve and display a Jira issue with full details. Use when the user says "ticket check", "issue check", "tiket", "TPM-", or asks about a specific Jira issue.
argument-hint: "[issue-key]"
allowed-tools: mcp__atlassian__getJiraIssue mcp__atlassian__getJiraIssueRemoteIssueLinks
---

# get-issue

Retrieve a Jira issue and display its full details.

## Usage

```
/get-issue <issue-key>
```

- `issue-key`: Jira issue key (e.g., `TPM-123`). If only a number is provided, prepend `TPM-` automatically.

## Execution

### 1. Validate input

- If `$ARGUMENTS` is empty, ask the user for the issue key and abort.
- If `$ARGUMENTS` is a plain number (e.g., `123`), convert to `TPM-123`.

### 2. Fetch issue

Call `mcp__atlassian__getJiraIssue` with the issue key.

### 3. Check linked issues

Jira-to-Jira issue links are already included in the `getJiraIssue` response (`issuelinks` field). Extract and display them.

Optionally, call `mcp__atlassian__getJiraIssueRemoteIssueLinks` to fetch external (remote) links if needed.

### 4. Display results

Present the issue in this format:

```
## <issue-key>: <summary>

| Field       | Value                    |
|-------------|--------------------------|
| Status      | <status>                 |
| Type        | <issue type>             |
| Priority    | <priority>               |
| Assignee    | <assignee>               |
| Reporter    | <reporter>               |
| Sprint      | <sprint name or "None">  |
| Created     | <created date>           |
| Updated     | <updated date>           |
| Labels      | <labels or "None">       |
| Components  | <components or "None">   |

### Description
<description content>

### Comments (<count>)
<list of comments with author and date>

### Linked Issues
<linked issues if any>
```

## Important Guidelines

- Always display ALL comments -- do not truncate.
- Format dates as `YYYY-MM-DD HH:MM`.
- If the issue does not exist, inform the user clearly.
- Respond in Korean.
