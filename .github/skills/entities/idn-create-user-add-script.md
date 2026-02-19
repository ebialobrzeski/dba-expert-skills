---
name: idn-create-user-add-script
description: Generates a SQL Server stored procedure execution script for creating a new IDN user. User must provide first name, last name, username, and email address. TeamCode is always 'BA'.
---

# Skill: IDN User Creation Script Generator

This utility generates a SQL Server stored procedure execution script for adding a new user to the IDN system.

## When to Use
- User needs to create a new IDN user account
- User asks to "add an IDN user" or "create an IDN user"
- User provides employee information for IDN provisioning

## Required Inputs

User must provide:
1. **FirstName**: User's first name
2. **LastName**: User's last name
3. **Email**: User's email address
4. **UserName** (optional): Network username (typically in format `res\adm-xxxx`)
   - If not provided, derive from email: extract prefix before @ and prepend `res\adm-`
   - Example: `jdoe@diligent.com` → `res\adm-jdoe`

**Fixed Values:**
- **TeamCode**: Always set to `'BA'`

## Output Template

```sql
EXEC dev.AdmAddUser @FirstName = N'[FirstName]', -- nvarchar(255)
                    @LastName = N'[LastName]',  -- nvarchar(255)
                    @UserName = N'[UserName]',  -- nvarchar(255)
                    @Email = '[Email]',      -- varchar(255)
                    @TeamCode = 'BA'    -- char(3)
```

## Example

**User Request:**
"Create an IDN user for John Doe with username res\adm-jdoe and email jdoe@diligent.com"

**Generated Script:**
```sql
EXEC dev.AdmAddUser @FirstName = N'John', -- nvarchar(255)
                    @LastName = N'Doe',  -- nvarchar(255)
                    @UserName = N'res\adm-jdoe',  -- nvarchar(255)
                    @Email = 'jdoe@diligent.com',      -- varchar(255)
                    @TeamCode = 'BA'    -- char(3)
```

## Workflow

1. **Collect Information**: 
   - If FirstName, LastName, or Email are missing, ask the user to provide them
   - If UserName is not provided, derive it from the email prefix
2. **Derive UserName** (if not provided):
   - Extract the portion before @ in the email address
   - Prepend `res\adm-` to create the username
   - Example: `jdoe@diligent.com` → `res\adm-jdoe`
3. **Validate Format**: 
   - FirstName and LastName should be single words
   - UserName typically follows pattern `res\adm-xxxx` or similar domain format
   - Email should be a valid email address format
4. **Generate Script**: Replace placeholders in the template with provided values
5. **Return Script**: Provide the complete EXEC statement ready to run

## Notes
- FirstName and LastName use N'' prefix (nvarchar Unicode strings)
- Email uses single quotes (varchar, non-Unicode)
- TeamCode is always 'BA' - do not ask user for this value
- Ensure backslashes in UserName are preserved (e.g., `res\adm-xxxx`)
- The script is ready to execute against the database containing the dev.AdmAddUser procedure
