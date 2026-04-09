---
name: get-page
description: Retrieve and display a Confluence page with content, comments, and child pages. Use when the user says "page check", "show page", "read confluence", or references a Confluence page.
argument-hint: "[page-id-or-title]"
allowed-tools: mcp__atlassian__getConfluencePage mcp__atlassian__getConfluencePageDescendants mcp__atlassian__getConfluencePageFooterComments mcp__atlassian__getConfluencePageInlineComments mcp__atlassian__searchConfluenceUsingCql
---

# get-page

Retrieve a Confluence page and display its full content, comments, and child pages.

## Usage

```
/get-page <page-id-or-title>
```

- `page-id-or-title`: A numeric page ID (e.g., `123456`) or a page title to search for.

## Execution

### 1. Validate input

- If `$ARGUMENTS` is empty, ask the user for the page ID or title and abort.

### 2. Resolve page

**If `$ARGUMENTS` is numeric:** Call `mcp__atlassian__getConfluencePage` directly with the page ID.

**If `$ARGUMENTS` is text:** Search by title using `mcp__atlassian__searchConfluenceUsingCql`:
```
type = page AND title = "<title>"
```
If multiple results, present the list and ask the user to pick one. If one result, use it.

### 3. Fetch additional context

Run in parallel:

**a) Child pages**
Call `mcp__atlassian__getConfluencePageDescendants` to list child pages.

**b) Footer comments**
Call `mcp__atlassian__getConfluencePageFooterComments` to get page-level comments.

**c) Inline comments**
Call `mcp__atlassian__getConfluencePageInlineComments` to get inline comments.

### 4. Display results

```
## <page-title>

| Field      | Value                     |
|------------|---------------------------|
| Page ID    | <id>                      |
| Space      | <space key - space name>  |
| Author     | <author>                  |
| Status     | <current/draft/archived>  |
| Created    | <created date>            |
| Updated    | <updated date>            |
| Version    | <version number>          |

### Content
<page body content -- render as markdown>

### Child Pages (<count>)
| Title | ID | Updated |
|-------|----|---------|
| ...   | .. | ...     |

### Footer Comments (<count>)
<list of comments with author and date>

### Inline Comments (<count>)
<list of inline comments with context and author>
```

## Important Guidelines

- Convert Confluence storage format (HTML/ADF) to readable markdown for display.
- Format dates as `YYYY-MM-DD HH:MM`.
- If the page does not exist, inform the user clearly.
- Respond in Korean.
