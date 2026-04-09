---
name: create-page
description: Create a new Confluence page in a specified space. Use when the user says "create page", "new doc", "make a confluence page", or "write a design doc".
argument-hint: "[title]"
disable-model-invocation: true
allowed-tools: mcp__atlassian__createConfluencePage mcp__atlassian__getConfluenceSpaces mcp__atlassian__getPagesInConfluenceSpace mcp__atlassian__searchConfluenceUsingCql
---

# create-page

Create a new Confluence page with guided input.

## Usage

```
/create-page [title]
```

- `title` (optional): If provided, use as the page title. Otherwise, ask the user.

## Execution

### 1. Collect page details

Ask the user for the following (skip fields already provided):

| Field       | Required | Default        | Notes                              |
|-------------|----------|----------------|------------------------------------|
| Title       | Yes      | `$ARGUMENTS`   | Page title                         |
| Space       | Yes      | --             | Space key (show available spaces via `getConfluenceSpaces` if needed) |
| Parent page | No       | Space root     | Parent page ID for nesting         |
| Content     | Yes      | --             | Page body (user can provide or ask Claude to draft) |
| Status      | No       | `current`      | `current` (published) or `draft`   |

### 2. Draft content

If the user provides a topic instead of full content, draft the page content with:
- Proper heading structure (H1 = title, H2 = major sections)
- Placeholder sections based on document type
- Korean content (matching project conventions)

### 3. Confirm with user

```
## New Page Preview

| Field       | Value              |
|-------------|--------------------|
| Title       | <title>            |
| Space       | <space key>        |
| Parent      | <parent title or "Root"> |
| Status      | <current/draft>    |

### Content Preview
<first 500 chars of content...>
```

Create this page? (Y/N/Edit)

### 4. Create page

Call `mcp__atlassian__createConfluencePage` with the collected fields. Content must be in Atlassian Document Format (ADF).

### 5. Report

```
## Page Created

| Field   | Value              |
|---------|--------------------|
| Title   | <title>            |
| ID      | <page-id>          |
| Space   | <space key>        |
| Status  | <status>           |
| URL     | <page URL if available> |
```

## Important Guidelines

- Always confirm with the user before creating.
- `disable-model-invocation: true` -- manual-only to prevent accidental page creation.
- Convert markdown content to ADF before creating.
- Respond in Korean.
