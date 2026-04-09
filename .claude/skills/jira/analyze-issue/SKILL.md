---
name: analyze-issue
description: Deep analysis of a Jira issue -- extract requirements, assess scope, identify risks, and post analysis as a comment. Use when the user says "analyze ticket", "analyze issue", "review requirements", or "what does this ticket need?".
argument-hint: "[issue-key]"
effort: high
allowed-tools: mcp__atlassian__getJiraIssue mcp__atlassian__getJiraIssueRemoteIssueLinks mcp__atlassian__searchJiraIssuesUsingJql mcp__atlassian__addCommentToJiraIssue mcp__atlassian__getConfluencePage mcp__atlassian__searchConfluenceUsingCql
---

# analyze-issue

Perform deep analysis of a Jira issue: extract requirements, assess technical scope, identify ambiguities and risks, then post the analysis as a structured comment on the ticket.

## Usage

```
/analyze-issue <issue-key>
```

- `issue-key`: Jira issue key (e.g., `TPM-123`). If only a number is provided, prepend `TPM-` automatically.

## Execution

### 1. Validate input

- If `$ARGUMENTS` is empty, ask the user for the issue key and abort.
- If `$ARGUMENTS` is a plain number, convert to `TPM-<number>`.

### 2. Gather context

Run the following in parallel:

**a) Fetch the issue**
Call `mcp__atlassian__getJiraIssue` with the issue key.

**b) Extract linked issues**
Jira-to-Jira issue links are included in the `getJiraIssue` response (`issuelinks` field). Extract them.
Optionally, call `mcp__atlassian__getJiraIssueRemoteIssueLinks` for external (remote) links.

**c) Search for related issues**
Extract key terms from the issue summary and search with `mcp__atlassian__searchJiraIssuesUsingJql`:
```
project = TPM AND text ~ "<key terms>" ORDER BY updated DESC
```

**d) Search Confluence for related docs (if applicable)**
If the issue references Confluence pages or the description mentions design docs, fetch them via `mcp__atlassian__searchConfluenceUsingCql`.

### 3. Analyze

Perform a structured analysis covering these areas:

#### a) Requirements extraction
- Functional requirements: What must the system do?
- Non-functional requirements: Performance, security, scalability constraints
- Acceptance criteria: Concrete, testable conditions for "done"

#### b) Technical scope assessment
- Affected components/services (infer from description and linked issues)
- API changes needed (new endpoints, modified contracts)
- Database changes (schema, migrations)
- Dependencies on other teams or services

#### c) Risk and ambiguity identification
- Ambiguous or missing requirements -- things not specified that should be
- Technical risks -- complexity, performance concerns, security implications
- Dependency risks -- external services, team coordination needed
- Open questions that need answers before development

#### d) Effort estimation hints
- Complexity level: Low / Medium / High / Very High
- Suggested breakdown into subtasks if complex

### 4. Present analysis to user

Show the full analysis to the user in the conversation BEFORE posting to Jira. Format:

```
## Analysis: <issue-key> - <summary>

### Requirements
<extracted requirements>

### Technical Scope
<scope assessment>

### Risks & Ambiguities
<identified risks and open questions>

### Suggested Subtasks
<breakdown if applicable>
```

### 5. Confirm and post

Ask the user:
- **A)** Post analysis as a comment on the ticket
- **B)** Edit the analysis first
- **C)** Cancel -- do not post

Only proceed to post after explicit user approval.

### 6. Post comment to Jira

Call `mcp__atlassian__addCommentToJiraIssue` with the analysis formatted in Atlassian Document Format (ADF).

Structure the comment with clear headings:
- `[Analysis] Requirements`
- `[Analysis] Technical Scope`
- `[Analysis] Risks & Ambiguities`
- `[Analysis] Suggested Subtasks` (if applicable)

### 7. Report

```
Analysis posted to <issue-key>.
```

## Important Guidelines

- Always present the analysis to the user BEFORE posting to Jira.
- Never skip the confirmation step.
- Be specific -- avoid vague statements like "this might be complex". State WHY it is complex.
- If the ticket description is too vague to analyze meaningfully, say so and list what information is missing.
- Respond in Korean.
