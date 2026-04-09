---
name: list-spaces
description: List all accessible Confluence spaces. Use when the user says "show spaces", "list spaces", "which spaces", or needs to find the right space key.
argument-hint: "[space-key]"
allowed-tools: mcp__atlassian__getConfluenceSpaces mcp__atlassian__getPagesInConfluenceSpace
---

# list-spaces

List all accessible Confluence spaces, optionally showing top-level pages in a space.

## Usage

```
/list-spaces [space-key]
```

- `space-key` (optional): If provided, show top-level pages in that space. Otherwise, list all spaces.

## Execution

### 1. Check arguments

- If `$ARGUMENTS` is empty: list all spaces.
- If `$ARGUMENTS` is provided: list pages in that space.

### 2a. List all spaces

Call `mcp__atlassian__getConfluenceSpaces`.

Display:

```
## Confluence Spaces (<count>)

| Key   | Name                    | Type     | Status |
|-------|-------------------------|----------|--------|
| ENG   | Engineering             | global   | current |
| API   | API Documentation       | global   | current |
| TEAM  | Team Space              | personal | current |
```

### 2b. List pages in a space

Call `mcp__atlassian__getPagesInConfluenceSpace` with the space key.

Display:

```
## Pages in <space-name> (<space-key>) -- <count> pages

| Title                      | ID     | Status  | Updated    |
|----------------------------|--------|---------|------------|
| Home                       | 123456 | current | 2026-04-08 |
| Architecture Overview      | 123457 | current | 2026-04-07 |
| API Design Guidelines      | 123458 | draft   | 2026-04-06 |
```

### 3. Follow-up

After listing, suggest:
- "View a page? `/get-page <id>`"
- "Search within a space? `/search-pages pages in <space-key>`"

## Important Guidelines

- Format dates as `YYYY-MM-DD`.
- If a space key is invalid, show the error and list available spaces.
- Respond in Korean.
