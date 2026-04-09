---
name: my-issues
description: List Jira issues assigned to me. Use when the user says "my tickets", "my issues", "what am I working on", "assigned to me", or "my tasks".
argument-hint: "[status-filter]"
allowed-tools: mcp__atlassian__searchJiraIssuesUsingJql mcp__atlassian__lookupJiraAccountId
---

# my-issues

List all Jira issues assigned to the current user in the TPM project.

## Usage

```
/my-issues [status-filter]
```

- `status-filter` (optional): Filter by status. Options: `todo`, `progress`, `done`, `all`. Default: shows open issues (not done).

## Execution

### 1. Resolve current user

Call `mcp__atlassian__lookupJiraAccountId` to get the current user's account ID.

### 2. Build JQL query

Base query: `project = TPM AND assignee = <accountId>`

Apply status filter from `$ARGUMENTS`:

| Argument     | JQL addition                                   |
|--------------|-------------------------------------------------|
| (empty)      | `AND statusCategory != Done ORDER BY updated DESC` |
| `todo`       | `AND statusCategory = "To Do" ORDER BY priority DESC` |
| `progress`   | `AND statusCategory = "In Progress" ORDER BY updated DESC` |
| `done`       | `AND statusCategory = Done ORDER BY updated DESC` |
| `all`        | `ORDER BY updated DESC`                        |

### 3. Search issues

Call `mcp__atlassian__searchJiraIssuesUsingJql` with the built JQL query.

### 4. Display results

Present issues as a table:

```
## My Issues (<count> total)

| Key     | Type | Status      | Priority | Summary                    | Updated    |
|---------|------|-------------|----------|----------------------------|------------|
| TPM-123 | Task | In Progress | High     | Implement user auth API    | 2026-04-08 |
| TPM-124 | Bug  | To Do       | Medium   | Fix login redirect issue   | 2026-04-07 |
```

## Important Guidelines

- If no issues found, inform the user clearly.
- Sort and group by status category when showing all statuses.
- Format dates as `YYYY-MM-DD`.
- Respond in Korean.
