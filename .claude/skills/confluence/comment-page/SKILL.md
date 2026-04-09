---
name: comment-page
description: Add a footer or inline comment to a Confluence page. Use when the user says "comment on page", "add note to doc", "leave feedback on page".
argument-hint: "[page-id] [comment-text]"
allowed-tools: mcp__atlassian__getConfluencePage mcp__atlassian__createConfluenceFooterComment mcp__atlassian__createConfluenceInlineComment mcp__atlassian__searchConfluenceUsingCql
---

# comment-page

Add a comment to a Confluence page (footer comment or inline comment).

## Usage

```
/comment-page <page-id> [comment-text]
```

- `page-id`: Page ID (numeric) or title to search for.
- `comment-text` (optional): The comment content. If omitted, ask the user.

## Execution

### 1. Validate input

- If `$ARGUMENTS` is empty, ask the user for the page ID and abort.
- Parse `$ARGUMENTS`: the first token is the page ID, the remainder is the comment text.

### 2. Resolve page

**If page ID is numeric:** Call `mcp__atlassian__getConfluencePage` to verify the page exists.

**If page ID is text:** Search via `mcp__atlassian__searchConfluenceUsingCql`:
```
type = page AND title = "<title>"
```

### 3. Determine comment type

Ask the user (if not clear from context):
- **A) Footer comment** -- general comment on the entire page
- **B) Inline comment** -- comment on a specific text selection

For inline comments, ask which section or text the comment refers to.

### 4. Prepare comment

- If comment text was provided in the arguments, use it.
- If no comment text, ask the user what to write.

### 5. Confirm

```
## Comment Preview

Target: <page-title> (ID: <page-id>)
Type: <Footer / Inline>

---
<comment content>
---
```

Post this comment? (Y/N/Edit)

### 6. Post comment

**Footer comment:** Call `mcp__atlassian__createConfluenceFooterComment` with ADF content.

**Inline comment:** Call `mcp__atlassian__createConfluenceInlineComment` with ADF content and the inline properties.

### 7. Report

```
<Comment type> posted to "<page-title>".
```

## Important Guidelines

- Always confirm before posting.
- Preserve the user's formatting when converting to ADF.
- Default to footer comment if the type is ambiguous.
- Respond in Korean.
