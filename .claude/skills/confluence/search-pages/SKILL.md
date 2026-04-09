---
name: search-pages
description: Search Confluence pages using CQL or natural language. Use when the user says "search confluence", "find page", "look for docs", or asks about Confluence content.
argument-hint: "[query]"
allowed-tools: mcp__atlassian__searchConfluenceUsingCql mcp__atlassian__getConfluenceSpaces
---

# search-pages

Search for Confluence pages using CQL or natural language queries.

## Usage

```
/search-pages <query>
```

- `query`: A CQL query or natural language description of what to find.

## Execution

### 1. Validate input

- If `$ARGUMENTS` is empty, ask the user what they want to search for and abort.

### 2. Build CQL query

**If the input looks like CQL** (contains `=`, `~`, `AND`, `OR`, `ORDER BY`, field names like `type`, `space`, `title`, `creator`):
- Use it directly.

**If the input is natural language**, convert to CQL:

| Natural language pattern             | CQL translation                                              |
|--------------------------------------|--------------------------------------------------------------|
| "pages about <topic>"               | `type = page AND text ~ "<topic>" ORDER BY lastModified DESC` |
| "pages in <space>"                  | `type = page AND space = "<space>" ORDER BY lastModified DESC` |
| "pages by <user>"                   | `type = page AND creator = "<user>" ORDER BY lastModified DESC` |
| "pages titled <title>"              | `type = page AND title ~ "<title>" ORDER BY lastModified DESC` |
| "recently updated pages"            | `type = page ORDER BY lastModified DESC`                      |
| "pages updated this week"           | `type = page AND lastModified >= now("-7d") ORDER BY lastModified DESC` |
| "<keyword>"                         | `type = page AND (title ~ "<keyword>" OR text ~ "<keyword>") ORDER BY lastModified DESC` |

If no space is specified, search across all spaces.

### 3. Search

Call `mcp__atlassian__searchConfluenceUsingCql` with the built CQL query.

### 4. Display results

```
## Search Results (<count> pages)

CQL: `<executed query>`

| Title                    | Space | Author  | Updated    | ID     |
|--------------------------|-------|---------|------------|--------|
| Design: Auth Service     | ENG   | user1   | 2026-04-08 | 123456 |
| API Specification v2     | API   | user2   | 2026-04-07 | 789012 |
```

If more than 20 results, show the first 20 and inform the user of the total count.

### 5. Follow-up options

After showing results, suggest:
- "View a specific page? `/get-page <id>`"
- "Analyze a page? `/analyze-page <id>`"
- "Refine the search?"

## Important Guidelines

- Always show the executed CQL so the user can learn and refine.
- If CQL syntax is invalid, show the error and suggest corrections.
- If no results found, suggest alternative queries or check if the space key is correct.
- Respond in Korean.
