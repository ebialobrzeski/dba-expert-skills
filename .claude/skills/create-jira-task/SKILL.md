---
name: create-jira-task
description: Creates a Jira task in the DBOS project when the user asks to create a Jira task/ticket/issue. User must provide a summary (title); description is optional. The task is assigned to the current user.
---

# Skill: Create Jira Task

This utility creates a Jira Task in the DBOS project using the Atlassian MCP tools, assigned to the current user.

## When to Use
- User asks to "create a Jira task", "create a Jira ticket", "open a Jira issue", or similar
- User wants to log work or track a DBA task in Jira

## Fixed Values

| Field | Value |
|---|---|
| Jira cloud ID | `dd51259c-9b53-4449-bfde-228ba13b0123` |
| Project key | `DBOS` |
| Issue type | `Task` |
| Assignee | Current user (resolve account ID via `atlassianUserInfo`) |
| Content format | `markdown` |

## Required Inputs

User must provide:
1. **Summary**: The task title (required). If missing, ask the user for it.
2. **Description** (optional): The task body in Markdown. If not provided, create the task without a description.

## Workflow

1. **Collect Information**:
   - If the summary is missing, ask the user for it before proceeding.
   - Accept an optional description in Markdown.
2. **Resolve Assignee**:
   - Call `mcp__atlassian__atlassianUserInfo` to get the current user's `account_id`.
   - Use this value for `assignee_account_id`.
3. **Create the Issue**:
   - Call `mcp__atlassian__createJiraIssue` with the fixed values below and the collected inputs.
4. **Return Result**:
   - Report the created issue key and URL back to the user.

## Tool Call

```
mcp__atlassian__createJiraIssue(
    cloudId              = "dd51259c-9b53-4449-bfde-228ba13b0123",
    projectKey           = "DBOS",
    issueTypeName        = "Task",
    summary              = "<user-provided summary>",
    description          = "<user-provided markdown description, if any>",
    contentFormat        = "markdown",
    assignee_account_id  = "<account_id from atlassianUserInfo>"
)
```

## Example

**User Request:**
"Create a Jira task titled 'Rebuild fragmented indexes on ProdDB' with a note to run during the maintenance window."

**Actions:**
1. `atlassianUserInfo` → returns current user's `account_id`.
2. `createJiraIssue` with:
   - `summary` = `Rebuild fragmented indexes on ProdDB`
   - `description` = `Run during the scheduled maintenance window.`
   - fixed values (cloudId, DBOS, Task, markdown, assignee)

**Result:**
"Created DBOS-1234 — Rebuild fragmented indexes on ProdDB."

## Notes
- Always assign to the current user; resolve the account ID via `atlassianUserInfo` rather than hardcoding it.
- Description is optional — do not block creation if the user only provides a summary.
- Content format is always `markdown`.
- If the summary is missing, ask for it; do not invent a title.
