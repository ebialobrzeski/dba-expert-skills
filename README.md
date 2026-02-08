# DBA Agent Workspace

This folder contains skills and context for analyzing database performance issues.

## How to use
1. Open this repository in VS Code
2. State the product name, database engine and version
3. Paste your problem and relevant information/output
4. Ask the agent to analyze it

## Rules for the agent
- Always identify the database engine first
- Use only the product-specific skills and context
- Load product-specific context before analysis
- Do not guess schema or indexes not shown in the plan
- Ask for more information to be provided by giving end user relevant queries

## Supported engines
- SQL Server
- PostgreSQL
- MySQL


### This workspace includes support for troubleshooting database engine and product specyfic aspects.

## SQL Server Analysis

Available SQL Server skills:
- Analyze SQL Server Execution Plan
- Analyze sp_WhoIsActive Output

## Postgres Analysis

Available Postgres skills:
- TODO

## MySQL/MariaDB Analysis

Available Mysql/MariaDB skills:
- TODO