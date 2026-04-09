---
name: update-issue
description: Update a Jira issue -- change status, assignee, priority, or other fields. Use when the user says "update ticket", "change status", "move to in progress", "assign to", or "transition issue".
argument-hint: "[issue-key] [action]"
allowed-tools: mcp__atlassian__getJiraIssue mcp__atlassian__editJiraIssue mcp__atlassian__getTransitionsForJiraIssue mcp__atlassian__transitionJiraIssue mcp__atlassian__lookupJiraAccountId
---

# update-issue

Update fields or transition the status of a Jira issue.

## Usage

```
/update-issue <issue-key> [action]
```

- `issue-key`: Jira issue key (e.g., `TPM-123`). If only a number, prepend `TPM-`.
- `action` (optional): What to update. If omitted, ask the user.

## Execution

### 1. Validate input

- If `$0` is empty, ask the user for the issue key and abort.
- If `$0` is a plain number, convert to `TPM-<number>`.

### 2. Fetch current issue state

Call `mcp__atlassian__getJiraIssue` to get the current values.

### 3. Determine update action

If `$1` is provided, parse the intent. Otherwise, show current state and ask what to change.

Supported actions:

#### a) Status transition
Call `mcp__atlassian__getTransitionsForJiraIssue` to get available transitions, then present them:

```
Available transitions for <issue-key> (current: <status>):
1. In Progress
2. Done
3. Closed
```

After user selection, call `mcp__atlassian__transitionJiraIssue`.

#### b) Field update
For fields like assignee, priority, labels, summary, description:
Call `mcp__atlassian__editJiraIssue` with the updated fields.

Use `mcp__atlassian__lookupJiraAccountId` when resolving assignee names.

### 4. Confirm with user

Show the proposed change:

```
## Update: <issue-key>

| Field    | Before         | After           |
|----------|----------------|-----------------|
| <field>  | <old value>    | <new value>     |
```

Proceed? (Y/N)

### 5. Execute update

Apply the change using the appropriate MCP tool.

### 6. Report

```
## Updated: <issue-key>

| Field    | Value          |
|----------|----------------|
| <field>  | <new value>    |
```

## Important Guidelines

- Always show before/after comparison before applying changes.
- Never update without user confirmation.
- If the requested transition is not available, explain which transitions are possible.
- Respond in Korean.
