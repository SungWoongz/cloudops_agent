---
name: comment
description: Add a comment to a Jira issue. Use when the user says "add comment", "leave a note", "comment on ticket", or "write on the ticket".
argument-hint: "[issue-key] [comment-text]"
allowed-tools: mcp__atlassian__addCommentToJiraIssue mcp__atlassian__getJiraIssue
---

# comment

Add a comment to a Jira issue.

## Usage

```
/comment <issue-key> [comment-text]
```

- `issue-key`: Jira issue key (e.g., `TPM-123`). If only a number, prepend `TPM-`.
- `comment-text` (optional): The comment content. If omitted, ask the user.

## Execution

### 1. Validate input

- If `$0` is empty, ask the user for the issue key and abort.
- If `$0` is a plain number, convert to `TPM-<number>`.

### 2. Verify issue exists

Call `mcp__atlassian__getJiraIssue` to confirm the issue exists. If not found, inform the user and abort.

### 3. Prepare comment

- If `$1` onwards is provided, use it as the comment text.
- If no comment text, ask the user what to write.
- Support multiline content -- the user may provide structured text.

### 4. Confirm with user

```
## Comment Preview

Target: <issue-key> - <summary>

---
<comment content>
---
```

Post this comment? (Y/N/Edit)

### 5. Post comment

Call `mcp__atlassian__addCommentToJiraIssue` with the comment in Atlassian Document Format (ADF).

### 6. Report

```
Comment posted to <issue-key>.
```

## Important Guidelines

- Always confirm before posting.
- Preserve the user's formatting (bullets, headings, code blocks) when converting to ADF.
- Respond in Korean.
