---
name: update-page
description: Update an existing Confluence page -- modify content, title, or status. Use when the user says "update page", "edit page", "modify doc", or "change page content".
argument-hint: "[page-id] [instruction]"
allowed-tools: mcp__atlassian__getConfluencePage mcp__atlassian__updateConfluencePage mcp__atlassian__searchConfluenceUsingCql
---

# update-page

Update the content, title, or status of an existing Confluence page.

## Usage

```
/update-page <page-id> [instruction]
```

- `page-id`: Page ID (numeric) or title to search for.
- `instruction` (optional): What to change. If omitted, ask the user.

## Execution

### 1. Validate input

- If `$ARGUMENTS` is empty, ask the user for the page ID and abort.
- Parse `$ARGUMENTS`: the first token is the page ID, the remainder is the instruction.

### 2. Fetch current page

**If page ID is numeric:** Call `mcp__atlassian__getConfluencePage` directly.

**If page ID is text:** Search via `mcp__atlassian__searchConfluenceUsingCql`:
```
type = page AND title = "<title>"
```

Note the current version number -- it is required for updates.

### 3. Determine update

If an instruction was provided, parse the intent. Otherwise, show current content summary and ask what to change.

Supported updates:
- **Content edit**: Modify specific sections, add/remove content, restructure
- **Title change**: Rename the page
- **Status change**: Publish a draft or archive a page

### 4. Prepare changes

For content edits:
- Show a clear diff or before/after comparison of the changed sections
- Do NOT show the entire page content -- only the relevant parts

```
## Update: <page-title> (v<version>)

### Changes
| Section     | Before (summary)       | After (summary)         |
|-------------|------------------------|-------------------------|
| <section>   | <old content summary>  | <new content summary>   |
```

Proceed? (Y/N/Edit)

### 5. Execute update

Call `mcp__atlassian__updateConfluencePage` with:
- Page ID
- New version number (current + 1)
- Updated content in ADF format
- Version message describing the change

### 6. Report

```
## Updated: <page-title>

| Field       | Value              |
|-------------|--------------------|
| Page ID     | <id>               |
| Version     | <old> -> <new>     |
| Change      | <summary>          |
```

## Important Guidelines

- Always show changes and confirm before updating.
- Include a meaningful version message for the update.
- Never overwrite the entire page when only a section needs changing -- preserve existing content.
- Respond in Korean.
