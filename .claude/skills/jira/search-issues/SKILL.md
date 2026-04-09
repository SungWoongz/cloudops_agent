---
name: search-issues
description: Search Jira issues using JQL or natural language. Use when the user says "search tickets", "find issues", "look for tickets", "JQL", or asks questions like "which tickets have label X?".
argument-hint: "[query]"
allowed-tools: mcp__atlassian__searchJiraIssuesUsingJql mcp__atlassian__lookupJiraAccountId
---

# search-issues

Search for Jira issues in the TPM project using JQL or natural language queries.

## Usage

```
/search-issues <query>
```

- `query`: A JQL query or natural language description of what to find.

## Execution

### 1. Validate input

- If `$ARGUMENTS` is empty, ask the user what they want to search for and abort.

### 2. Build JQL query

**If the input looks like JQL** (contains `=`, `~`, `AND`, `OR`, `ORDER BY`, field names like `status`, `assignee`, `priority`):
- Use it directly. Prepend `project = TPM AND` if the project is not already specified.

**If the input is natural language**, convert to JQL:

| Natural language pattern            | JQL translation                                        |
|-------------------------------------|--------------------------------------------------------|
| "bugs with high priority"          | `project = TPM AND issuetype = Bug AND priority = High` |
| "tasks assigned to <name>"         | `project = TPM AND assignee = <accountId>`             |
| "issues updated this week"         | `project = TPM AND updated >= startOfWeek()`           |
| "open issues with label <X>"       | `project = TPM AND labels = "<X>" AND statusCategory != Done` |
| "issues in current sprint"         | `project = TPM AND sprint in openSprints()`            |
| "<keyword>"                        | `project = TPM AND text ~ "<keyword>"`                 |

Always add `ORDER BY updated DESC` if no ordering is specified.

### 3. Search

Call `mcp__atlassian__searchJiraIssuesUsingJql` with the built JQL query.

### 4. Display results

```
## Search Results (<count> issues)

JQL: `<executed query>`

| Key     | Type  | Status      | Priority | Assignee | Summary                  | Updated    |
|---------|-------|-------------|----------|----------|--------------------------|------------|
| TPM-123 | Task  | In Progress | High     | user1    | Implement auth API       | 2026-04-08 |
| TPM-124 | Bug   | To Do       | Medium   | user2    | Fix redirect issue       | 2026-04-07 |
```

If more than 20 results, show the first 20 and inform the user of the total count.

### 5. Follow-up options

After showing results, suggest:
- "View details of a specific issue? `/get-issue <key>`"
- "Refine the search?"

## Important Guidelines

- Always show the executed JQL so the user can learn and refine.
- If JQL syntax is invalid, show the error and suggest corrections.
- If no results found, suggest alternative queries.
- Respond in Korean.
