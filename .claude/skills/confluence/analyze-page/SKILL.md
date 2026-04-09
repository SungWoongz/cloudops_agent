---
name: analyze-page
description: Deep analysis of a Confluence page -- evaluate structure, quality, completeness, and summarize key points. Use when the user says "analyze page", "review document", or "check doc quality".
argument-hint: "[page-id-or-title]"
effort: high
allowed-tools: mcp__atlassian__getConfluencePage mcp__atlassian__getConfluencePageDescendants mcp__atlassian__getConfluencePageFooterComments mcp__atlassian__getConfluencePageInlineComments mcp__atlassian__searchConfluenceUsingCql mcp__atlassian__createConfluenceFooterComment
---

# analyze-page

Deep analysis of a Confluence page: evaluate document structure, content quality, completeness, and post the analysis as a comment.

## Usage

```
/analyze-page <page-id-or-title>
```

- `page-id-or-title`: A numeric page ID or page title.

## Execution

### 1. Validate input

- If `$ARGUMENTS` is empty, ask the user for the page ID or title and abort.

### 2. Resolve and fetch page

**If numeric:** Call `mcp__atlassian__getConfluencePage` directly.

**If text:** Search via `mcp__atlassian__searchConfluenceUsingCql`:
```
type = page AND title = "<title>"
```

### 3. Gather context

Run in parallel:

**a) Child pages**
Call `mcp__atlassian__getConfluencePageDescendants`.

**b) Footer comments**
Call `mcp__atlassian__getConfluencePageFooterComments`.

**c) Inline comments**
Call `mcp__atlassian__getConfluencePageInlineComments`.

### 4. Analyze

Perform a structured analysis covering:

#### a) Document structure assessment
- Heading hierarchy: Are headings properly nested (H1 > H2 > H3)?
- Section organization: Is the flow logical?
- Table of contents: Would one be beneficial given the page length?
- Child page structure: Is the page tree well-organized?

#### b) Content quality evaluation
- Clarity: Is the writing clear and unambiguous?
- Completeness: Are there sections that feel incomplete or placeholder-like?
- Accuracy: Are there obvious inconsistencies or outdated information?
- Code blocks: Are they properly formatted with language hints?
- Links: Are there broken or placeholder links?

#### c) Missing sections identification
Based on the document type (design doc, runbook, API spec, meeting notes, etc.), identify commonly expected sections that are absent:
- Design doc: Problem statement, proposed solution, alternatives considered, risks, timeline
- Runbook: Prerequisites, steps, rollback, monitoring
- API spec: Endpoints, request/response schemas, error codes, examples
- Meeting notes: Attendees, decisions, action items, next steps

#### d) Key points summary
- 3-5 bullet points capturing the essential information
- Highlight decisions, action items, or open questions

### 5. Present analysis to user

Show the full analysis BEFORE posting to Confluence:

```
## Analysis: <page-title>

### Document Structure
<assessment>

### Content Quality
<evaluation>

### Missing Sections
<identified gaps>

### Key Points Summary
<3-5 bullets>

### Recommendations
<actionable improvements>
```

### 6. Confirm and post

Ask the user:
- **A)** Post analysis as a footer comment on the page
- **B)** Edit the analysis first
- **C)** Cancel -- do not post

### 7. Post comment

Call `mcp__atlassian__createConfluenceFooterComment` with the analysis formatted in Atlassian Document Format (ADF).

Prefix the comment with `[Page Analysis]` for easy identification.

### 8. Report

```
Analysis posted to "<page-title>" (ID: <page-id>).
```

## Important Guidelines

- Always present the analysis to the user BEFORE posting.
- Never skip the confirmation step.
- Be specific with recommendations -- avoid vague advice.
- If the page is too short or empty to analyze meaningfully, say so.
- Respond in Korean.
