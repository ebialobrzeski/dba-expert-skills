---
name: log-my-work
description: Records work the user has just completed as a standalone Jira Story or Task in the DBOS project, drafting the summary and description from the conversation itself. Use when the user says "log my work", "log this", "back this up in Jira", "create a ticket for what we just did", or "record this in Jira". No parent epic is set. Always asks permission before creating the issue.
---

# Skill: Log My Work to Jira

Creates a standalone Jira ticket in the **DBOS** project recording work the user has just completed,
so there is a written record of it. **No parent epic** - the ticket stands on its own.

Always asks user permission before creating anything.

## When to Use
- The user asks to log, record, or back up work they have just done
- An analysis, script, query, fix, or tool was completed in this conversation
- A configuration or architecture decision was made and should be recorded
- Investigation work was done that is worth having a record of

Err on the side of logging when asked. The user decides what is worth recording, not this skill.

## When NOT to Use
- **The user supplies the ticket title themselves** - that is `create-jira-task`. This skill exists
  for the case where the summary and description have to be derived from the conversation.
- Work that has not been done yet. That is planning, not logging.
- Work already covered by an existing open DBOS ticket - check with the user first.

## Fixed Values

| Field | Value |
|---|---|
| Jira cloud ID | `dd51259c-9b53-4449-bfde-228ba13b0123` |
| Project key | `DBOS` |
| Parent | none - do not set a parent or epic link |
| Issue type | `Task` (default) or `Story` - see step 2 |
| Assignee | Current user (resolve account ID via `atlassianUserInfo`) |
| Content format | `markdown` |

## Workflow

### 1. Extract the work from context
Review the conversation and identify:
- **What** was done - one line, max 80 chars, becomes the Jira summary
- **Why** it was needed, or what problem it solves
- **How** it works at a high level - key files, queries, functions, or commands
- **Caveats** - permissions required, known limitations, follow-up needed

If the user supplied a description alongside the request, use it as the seed and expand from context.

### 2. Choose the issue type
Default to **Task**. Use **Story** when the work delivers user-facing or business-visible capability
rather than internal or technical change. If genuinely ambiguous, ask in the same message as the
permission request rather than as a separate round trip.

### 3. Resolve the assignee
Call `mcp__atlassian__atlassianUserInfo` to get the current user's `account_id`. Do not hardcode it.

### 4. Ask permission
Present the proposed ticket **before** calling any create tool:

> I'll create a Jira `<Task|Story>` in DBOS with the following details:
>
> **Summary:** `<summary>`
>
> **Description:**
> `<description>`
>
> Shall I go ahead?

Wait for explicit confirmation. If the user edits the text, use their version verbatim.

### 5. Create the issue
Call `mcp__atlassian__createJiraIssue` with the values below. Do **not** pass a `parent` argument.

### 6. Report back
Give the issue key and a direct link: `https://diligentbrands.atlassian.net/browse/DBOS-<number>`

Do not create local files or commit anything as part of this skill.

## Tool Call

```
mcp__atlassian__createJiraIssue(
    cloudId              = "dd51259c-9b53-4449-bfde-228ba13b0123",
    projectKey           = "DBOS",
    issueTypeName        = "<Task or Story from step 2>",
    summary              = "<summary drafted in step 1>",
    description          = "<markdown description drafted in step 1>",
    contentFormat        = "markdown",
    assignee_account_id  = "<account_id from atlassianUserInfo>"
)
```

If that tool name does not resolve, the Atlassian MCP server is registered under a different prefix
in this workspace. Search the available tools for `createJiraIssue` and use the matching name - the
arguments are identical.

## Description Guidelines

Cover, in order:
1. **What was done** - the change, and the files or objects affected
2. **Problem it solves** - what was failing, missing, or unknown before
3. **Implementation detail** - key query, script, or decision in 1-3 sentences
4. **Caveats** - prerequisites, limitations, follow-up

Keep it under 10 sentences. Use code fences for SQL and commands.

Write it so someone reading the ticket in six months understands what changed without needing the
conversation that produced it. That is the entire point of the record.

## Constraints
- Never create the issue before the user has confirmed.
- Never set a parent or epic link.
- Never invent detail that did not happen in the conversation. If a section would be guesswork,
  leave it out and say so when presenting the draft.
- Resolve the assignee via `atlassianUserInfo` rather than hardcoding an account ID.

## Example

**User:** "log my work"

**Draft presented for approval:**

> I'll create a Jira **Task** in DBOS with the following details:
>
> **Summary:** Index review for Insightia - 12 new indexes, 146 unused identified
>
> **Description:**
> Reviewed missing-index and index-usage DMV output for activist_insight and proxy_insight,
> cross-checked against the readable secondary.
>
> Produced 12 validated index recommendations and identified 146 unused indexes totalling ~188 GB
> that carry ~397M index updates for zero reads.
>
> Evidence window was 105 days, governed by the secondary's DMV reset date. Does not cover an
> annual cycle, so `*_backup` and year-partitioned tables need confirmation before any drop.
>
> Shall I go ahead?

**After confirmation:**

> Created **DBOS-1402**: Index review for Insightia - 12 new indexes, 146 unused identified
> https://diligentbrands.atlassian.net/browse/DBOS-1402
