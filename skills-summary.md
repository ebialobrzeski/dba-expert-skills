# Skills Architecture Summary

## Overview

This document describes the AI skills architecture implemented in the `.github` directory. This system provides domain-specific workflows and guidance that AI agents can discover and execute automatically. The architecture enables:

- **Autonomous skill discovery** - AI reads skill metadata to find relevant workflows
- **Consistent execution** - Skills provide standard procedures for common tasks
- **Progressive disclosure** - Complex workflows are broken into manageable pieces
- **Type safety** - Skills are classified by cognitive pattern (Exploration, Execution, Evaluation, Generation)
- **Modularity** - Shared standards, references, and sub-skills reduce duplication

---

## Directory Structure

```
.github/
├── copilot-instructions.md      # Main AI instructions (Copilot-specific)
├── instructions/                # File-scoped coding standards
│   ├── general-coding.instructions.md
│   └── typescript-react.instructions.md
├── skills/                      # Domain-specific workflow skills
│   ├── brainstorming/
│   ├── test-driven-development/
│   ├── branch-analyzer/         # Example: Nested skill constellation
│   │   ├── SKILL.md
│   │   ├── fixes/               # Sub-skills
│   │   │   ├── commit/SKILL.md
│   │   │   ├── direct-yaml/SKILL.md
│   │   │   ├── rebase/SKILL.md
│   │   │   └── verify-yaml/SKILL.md
│   │   └── references/          # Supporting documentation
│   ├── writing-skills/          # Meta-skill for creating skills
│   │   ├── SKILL.md
│   │   ├── modes/               # Type-specific patterns
│   │   │   ├── exploration/SKILL.md
│   │   │   ├── execution/SKILL.md
│   │   │   ├── evaluation/SKILL.md
│   │   │   └── generation/SKILL.md
│   │   ├── references/          # Shared patterns
│   │   └── standard/            # Cross-skill invariants
│   │       └── standard.md
│   └── ... (25+ skills total)
├── agents/                      # Complex stateful workflows
│   └── platform-ownership-expert.md
├── pull_request_template.md     # PR checklist
├── workflows/                   # GitHub Actions CI/CD
├── actions/                     # Custom GitHub Actions
└── config/                      # Repository-specific configs
```

---

## Core Components

### 1. Instructions Directory

**Purpose**: File-scoped coding standards that apply automatically based on file patterns.

**Pattern**: Each instruction file includes YAML frontmatter with `applyTo` glob patterns.

**Example Structure**:

```markdown
---
applyTo: "**/*.ts,**/*.tsx"
---

# TypeScript and React Coding Standards

## When to Use
...

## Naming Conventions
...

## Code Principles
...
```

**When to Use**:
- Language-specific coding standards
- Framework-specific patterns
- File naming conventions
- Linting rules that should apply to specific file types

**Key Principles**:
- Should be **passive enforcement** - describe standards, don't orchestrate workflows
- Use glob patterns in frontmatter for automatic application
- Keep focused on "how to write code" not "what to build"

---

### 2. Skills Directory

**Purpose**: Discrete, discoverable workflows that AI can load and execute on demand.

#### Skill File Structure

Every skill follows this template:

```markdown
---
name: skill-name
description: Third-person description of what the skill does and when to use it
---

# Skill Title

Brief overview paragraph.

---

## When to use this skill

- Specific trigger conditions
- User phrases that indicate this skill
- Contexts where this skill applies

---

## Inputs

**Required:**
- List required inputs

**Ask if missing:**
- What to ask if inputs are unclear

**Optional:**
- Optional inputs

---

## Procedure

### Phase 1: Context gathering

1. First step with observable output
2. Second step with observable output
...

### Phase 2: Next phase

5. Continue numbered sequence
...

---

## Validation

Skill is complete when:
- [ ] Verification checkpoint 1
- [ ] Verification checkpoint 2
...

---

## Examples

**Typical case:**
...

**Edge case:**
...

---

## Safety & boundaries

**Default-safe behavior:**
- What the skill does by default

**Requires user confirmation:**
- When to stop and ask
```

#### Skill Types (Cognitive Patterns)

The system recognizes four skill types, each with distinct characteristics:

| Type | Purpose | Degrees of Freedom | Output Nature |
|------|---------|-------------------|---------------|
| **Exploration** | Understand, discover, gather context | Medium-High | Knowledge, insights, options |
| **Execution** | Perform specific deterministic tasks | Low | Predictable artifacts |
| **Evaluation** | Assess, classify, recommend | Medium | Judgments, reports |
| **Generation** | Create novel content | High | Creative artifacts |

**Type Selection Guide**:

- **Exploration**: Requirements unclear, multiple valid interpretations, context-gathering primary goal
- **Execution**: Same inputs = same outputs, clear parameters, repeatable actions
- **Evaluation**: Applying criteria to existing artifacts, read-only, delegating action
- **Generation**: Creating novel content, multiple valid solutions, creative latitude

#### Nested Skills (Constellation Pattern)

When multiple related skills form a workflow, consolidate into a parent-child structure:

**Before (scattered)**:
```
skills/
├── check-branch/          # Evaluation
├── fix-commits/           # Execution
├── fix-yaml/              # Execution
└── rebase-branch/         # Execution
```

**After (consolidated)**:
```
skills/
└── branch-analyzer/       # Single entry point
    ├── SKILL.md           # Evaluation (orchestration)
    ├── fixes/             # Sub-skills
    │   ├── commit/SKILL.md
    │   ├── yaml/SKILL.md
    │   └── rebase/SKILL.md
    └── references/        # Shared patterns
```

**Benefits**:
- Single discovery point for users
- Clear workflow hierarchy
- Consolidated references
- Sub-skills are implementation details

**When to Nest**:
- One skill is clearly the entry point (typically Evaluation)
- Other skills are delegated to by entry point
- Skills share domain knowledge and references
- Skills form a defined workflow sequence

---

### 3. Writing-Skills Meta-Architecture

The `writing-skills` directory contains a sophisticated meta-system for creating skills themselves.

**Structure**:

```
writing-skills/
├── SKILL.md               # Entry point: determines skill type
├── modes/                 # Type-specific patterns
│   ├── exploration/SKILL.md
│   ├── execution/SKILL.md
│   ├── evaluation/SKILL.md
│   └── generation/SKILL.md
├── references/            # Cross-type patterns
│   ├── base-skill-integration.md
│   ├── eval-patterns.md
│   ├── failure-modes.md
│   ├── mode-classification.md
│   └── scope-and-delegation.md
└── standard/              # Cross-skill invariants
    └── standard.md
```

**Workflow**:
1. AI invokes `writing-skills` when asked to create/improve a skill
2. `writing-skills/SKILL.md` analyzes the request to determine type
3. Delegates to appropriate mode (exploration/execution/evaluation/generation)
4. Mode provides type-specific guidance for creating the skill
5. All skills follow shared standards from `standard/standard.md`

**Key Files**:

- **standard.md**: P0/P1/P2 rules that apply to ALL skills
  - Required structure elements
  - Size limits (SKILL.md ≤ 500 lines)
  - Discovery discipline (description must say what AND when)
  - Progressive disclosure (move large content to companion files)

- **modes/[type]/SKILL.md**: Type-specific patterns
  - Cognitive pattern for type
  - Procedure signature template
  - Validation approach
  - Common anti-patterns

- **references/**: Reusable guidance
  - Delegation targets
  - Scope control
  - Evaluation patterns
  - Failure modes to avoid

---

### 4. Agents Directory

**Purpose**: Complex, stateful workflows that require maintaining context across multiple interactions.

**Difference from Skills**:
- **Skills**: Stateless, single invocation, discrete task
- **Agents**: Stateful, multi-turn, complex decision trees

**Structure**:

```markdown
---
name: agent-name
description: Agent capabilities and domain
---

# Agent Title

## Agent Overview

### Goal
...

### Non-Goals
...

### Intended Users
...

## Workflow States

### State 1: [State Name]
**Entry:** Condition for entering this state
**Actions:**
- Action 1
- Action 2
**Exit:** Condition for leaving this state

### State 2: [Next State]
...

## Core Capabilities
...

## Guardrails
...

## Decision Framework
...

## Validation & Evals

### Eval Prompts

#### Typical Scenarios
...

#### Edge Cases
...

#### Adversarial / Safety
...
```

**Key Differences**:
- State machine pattern (Entry → Actions → Exit)
- Explicit guardrails and safety checks
- Decision frameworks for ambiguous situations
- Eval prompts for testing agent behavior

**When to Use Agents**:
- Workflow spans multiple skills
- State must be maintained across interactions
- Complex decision trees with branching logic
- User may need to be consulted multiple times

---

### 5. GitHub Copilot Instructions

**File**: `.github/copilot-instructions.md`

**Purpose**: Main instructions for GitHub Copilot specifically (not generic AI).

**Typically Includes**:
- Skills protocol (how to discover and load skills)
- Repository-specific context
- Review directives (what to focus on in PRs)
- Coding standards (points to instruction files)
- Tool preferences (Serena MCP, etc.)
- Generated file handling rules

**Pattern**: This is the "bootstrap" file that tells Copilot about the skills system.

**Example Structure**:

```markdown
# GitHub Copilot Instructions

## Skills Protocol

**BEFORE starting work:**
1. Check `.github/skills/README.md` for available skills
2. Match triggers, not possibilities
3. Announce skill usage
4. Follow the skill exactly

**Available Skills:**
- `skill-name` - When to use description
...

## Repository Context
...

## Coding Standards
- Points to `.github/instructions/` files
...

## Review Directives
...
```

---

## Key Patterns & Principles

### 1. Discovery Over Hard-Coding

**Problem**: AI instructions become massive and hard to maintain.

**Solution**: Skills are discovered on-demand via metadata.

```markdown
# In top-level instructions
<skills>
<skill>
<name>brainstorming</name>
<description>Transforms vague ideas into validated designs...</description>
<file>.github/skills/brainstorming/SKILL.md</file>
</skill>
...
</skills>
```

AI reads descriptions and loads full skill only when needed.

### 2. Progressive Disclosure

**Problem**: Long documents overwhelm context windows.

**Solution**: Hierarchical loading - read summary, load detail on demand.

**Levels**:
1. **Top-level description** (1-2 sentences in metadata)
2. **SKILL.md overview** (When to use, Inputs, high-level procedure)
3. **Companion files** (Detailed references, anti-patterns, examples)
4. **Nested sub-skills** (Specific execution paths)

### 3. Type-Based Pattern Matching

**Problem**: Every skill written differently = inconsistent quality.

**Solution**: Classify skills by cognitive pattern, provide templates.

**Four Types**:
- **Exploration**: Divergent → convergent, synthesis-focused
- **Execution**: Linear, deterministic, prescriptive
- **Evaluation**: Criteria-based, read-only, recommendation-focused
- **Generation**: Creative, high-variance, quality-variable

### 4. Evidence Before Assertions

**Problem**: AI claims completion without verification.

**Solution**: Every skill includes validation steps with observable outputs.

**Pattern**:
```markdown
## Validation

Skill is complete when:
- [ ] Ran command X, output shows Y
- [ ] File Z contains expected content
- [ ] Test suite passes with zero failures
```

### 5. Safety Gates & Guardrails

**Problem**: AI takes destructive or irreversible actions.

**Solution**: Explicit confirmation gates in skill procedures.

**Pattern**:
```markdown
## Safety & boundaries

**Default-safe behavior:**
- Read-only operations
- No deletions
- Prefer reversible actions

**Requires user confirmation:**
- Destructive operations
- Changes visible to others
- Hard-to-reverse operations
```

### 6. Frontmatter Metadata

**Pattern**: All instruction files and skills use YAML frontmatter.

**Benefits**:
- Machine-parseable metadata
- Enables automated discovery
- Clear applicability rules

**Instruction Files**:
```yaml
---
applyTo: "**/*.ts,**/*.tsx"
---
```

**Skill Files**:
```yaml
---
name: skill-name
description: Third-person when/what description
---
```

### 7. Reference Files for Shared Knowledge

**Problem**: Multiple skills need same information = duplication.

**Solution**: Extract to reference files, load on demand.

**Pattern**:
```
skill-name/
├── SKILL.md                      # Core workflow
├── anti-patterns.md              # What NOT to do
├── troubleshooting.md            # Common problems
└── references/                   # Shared with other skills
    ├── pattern-library.md
    └── validation-criteria.md
```

**Note in SKILL.md**:
```markdown
When adding mocks or test utilities, read @testing-anti-patterns.md to avoid common pitfalls.
```

### 8. Standard-Managed Invariants

**Problem**: Cross-cutting rules duplicated in every skill.

**Solution**: Centralized `standard.md` with P0/P1/P2 rules.

**Rule Hierarchy**:
- **P0**: Critical - Always follow (max 10 rules)
- **P1**: Important - Follow unless good reason
- **P2**: Best practices - Follow when practical

**Example P0 Rule**:
```markdown
### P0.4: Progressive Disclosure
SKILL.md under 500 lines. Move large content (>100 lines) to companion files.
```

---

## Implementation Guide

To implement this system in a new repository:

### Step 1: Bootstrap Structure

```bash
mkdir -p .github/{instructions,skills,agents}
```

### Step 2: Create Core Instructions

1. **Main AI instructions** (`.github/copilot-instructions.md` or similar)
   - Skills protocol section
   - Repository context
   - Coding standards

2. **File-scoped instructions** (`.github/instructions/`)
   - Language-specific standards with `applyTo` frontmatter
   - Framework-specific patterns

### Step 3: Implement First Skills

Start with 3-5 core skills for your domain:

1. **One Exploration skill** - For understanding/discovery tasks
2. **One Execution skill** - For deterministic workflows
3. **One Evaluation skill** - For assessing quality/compliance

Use the skill template from "Skill File Structure" above.

### Step 4: Add Meta-Skills (Optional but Recommended)

1. **writing-skills** - For creating more skills consistently
2. **verification-before-completion** - Ensures evidence before assertions
3. **systematic-debugging** - Structured approach to issues

### Step 5: Implement Agents for Complex Workflows

For workflows requiring:
- Multiple skills in sequence
- Maintaining state across interactions
- Complex decision trees

Create agent files with state machine patterns.

### Step 6: Create References and Standards

1. **standard.md** - P0/P1/P2 rules for all skills
2. **references/** - Shared patterns, anti-patterns, validation criteria

### Step 7: Test with Eval Prompts

For each skill and agent, create eval prompts covering:
- Typical usage scenarios
- Edge cases
- Adversarial/safety tests

---

## Best Practices

### For Instructions Files

✅ **DO**:
- Use frontmatter with `applyTo` patterns
- Focus on "how to write" not "what to build"
- Keep focused (one language/framework per file)
- Include validation commands

❌ **DON'T**:
- Create orchestration workflows (use skills instead)
- Duplicate content across instruction files
- Create mega-files with all standards

### For Skills

✅ **DO**:
- Start with clear "When to use" triggers
- Include observable outputs for each step
- Provide typical AND edge case examples
- Add safety boundaries
- Keep SKILL.md under 500 lines

❌ **DON'T**:
- Mix multiple skill types in one skill
- Create skills without validation checkpoints
- Hard-code what can be parametrized
- Include hypothetical guidance for unobserved failures

### For Nested Skills

✅ **DO**:
- Use when multiple skills form a clear workflow
- Make parent an Evaluation or orchestration skill
- Put specialized execution in sub-skills
- Consolidate references at parent level

❌ **DON'T**:
- Nest just for organization (keep shallow if no workflow)
- Duplicate references across sub-skills
- Create deep hierarchies (2 levels max)

### For Agents

✅ **DO**:
- Define explicit state machine
- Include guardrails and safety gates
- Provide decision frameworks for ambiguity
- Add eval prompts for testing

❌ **DON'T**:
- Create agents for simple linear workflows (use Execution skills)
- Skip validation criteria
- Omit adversarial test cases

### For the System Overall

✅ **DO**:
- Start small (3-5 skills) and grow organically
- Extract to references when patterns repeat
- Type skills explicitly (Exploration/Execution/Evaluation/Generation)
- Use frontmatter for all metadata
- Test with evals before considering complete

❌ **DON'T**:
- Try to document everything upfront
- Create skills for hypothetical needs
- Mix stateless skills with stateful agents
- Skip progressive disclosure (keep files digestible)

---

## Real-World Examples from This Repository

### Example 1: Simple Execution Skill

**File**: `.github/skills/creating-pull-request/SKILL.md`

**Type**: Execution (deterministic workflow)

**Characteristics**:
- Clear step-by-step procedure
- Exact commands to run
- Validation checklist
- Same inputs = same outputs

### Example 2: Nested Skill Constellation

**File**: `.github/skills/branch-analyzer/`

**Structure**:
- Parent: `SKILL.md` (Evaluation type - analyzes issues)
- Children: `fixes/commit/`, `fixes/yaml/`, `fixes/rebase/` (Execution type - fixes specific issues)
- Shared: `references/` (patterns used across fixes)

**Why Nested**: Parent diagnoses, delegates to specific fix sub-skill based on findings.

### Example 3: Complex Exploration Skill

**File**: `.github/skills/brainstorming/SKILL.md`

**Type**: Exploration (requirements discovery)

**Characteristics**:
- Handles vague/unclear requirements
- Adaptive questioning strategy
- Converges to validated design
- Output is understanding, not artifacts

### Example 4: Meta-Skill System

**File**: `.github/skills/writing-skills/`

**Structure**:
- Entry point determines skill type
- Delegates to mode-specific guidance
- Shared standards in `standard/`
- Reusable patterns in `references/`

**Why This Structure**: Creating skills is itself a complex workflow requiring type-specific patterns.

### Example 5: Stateful Agent

**File**: `.github/agents/platform-ownership-expert.md`

**Type**: Agent (stateful, multi-turn)

**Characteristics**:
- State machine (Intake → Research → Plan → Execute → Validate → Report)
- Decision frameworks for ambiguity
- Safety guardrails
- Eval prompts for testing

**Why Agent Not Skill**: Requires maintaining context across multiple interactions, complex decision trees, may consult user multiple times.

---

## Tools & Integration

### Serena MCP (Code Navigation)

This repository prefers Serena MCP tools for semantic code navigation:

- `find_symbol` - Locate functions/classes/types
- `find_referencing_symbols` - Find all usages
- `get_symbol_definition` - Navigate to definition
- `replace_symbol` - Edit at symbol level

**Referenced in**: `.github/copilot-instructions.md` "Serena MCP Tools" section

### GitHub Actions Integration

Skills can reference or be referenced by CI/CD workflows:

**Example**: `branch-analyzer` skill detects issues that GHA workflows also check:
- Direct YAML edits
- Missing regeneration
- Invalid commit messages

### Pull Request Templates

**File**: `.github/pull_request_template.md`

**Integration**: Skills reference PR checklist requirements:
- Every commit linked to Jira
- Tests updated
- Docs updated

---

## Maintenance & Evolution

### When to Add a New Skill

✅ Add when:
- Task is repeated frequently
- Multiple team members need same workflow
- Quality issues observed from ad-hoc execution
- Onboarding burden is high

❌ Don't add when:
- Task is one-off
- Workflow is still experimental
- Instructions would be longer than just doing the task

### When to Nest Skills

Consolidate related skills when:
- One skill is clearly the entry point
- Others are delegated to by entry point
- Skills share domain knowledge
- You have 3+ related skills at same level

### When to Extract References

Extract to reference files when:
- Content exceeds ~100 lines
- Multiple skills need same information
- Anti-patterns or failure modes list grows large
- Examples become numerous

### When to Create an Agent

Convert skills to agent when:
- Workflow requires maintaining state
- Multiple skills must execute in sequence
- User consultation needed multiple times
- Complex decision tree with branches

### Version Control for Skills

Treat skills as code:
- Review changes like code reviews
- Test with eval prompts before merging
- Version breaking changes
- Document migrations if skill interfaces change

---

## Metrics & Observability

### Skill Effectiveness Metrics

Track these to evaluate if skills are working:

1. **Usage frequency** - How often is each skill invoked?
2. **Completion rate** - Does AI complete the skill successfully?
3. **User intervention rate** - How often does user need to correct?
4. **Time to completion** - How long does skill execution take?

### Quality Indicators

✅ **Good signals**:
- AI invokes skill automatically when appropriate
- Validation checkpoints pass without retries
- User rarely needs to correct AI during skill execution
- Skill is completed without user clarification needed

⚠️ **Warning signals**:
- AI doesn't invoke skill when it should
- Frequent validation failures
- User must guide AI through skill steps
- Skill too long (>500 lines)

❌ **Bad signals**:
- AI claims completion without validation
- Same mistakes repeated across skill invocations
- User gives up and does task manually
- Multiple skills needed for simple task

### Monitoring Approach

1. **Log skill invocations** - Track when skills are loaded
2. **Capture validation results** - Did checkpoints pass?
3. **Review user corrections** - What does AI get wrong?
4. **Analyze failure patterns** - Where do skills break down?

---

## Troubleshooting Common Issues

### AI Doesn't Invoke Skill When It Should

**Symptoms**: User says "use the brainstorming skill" but AI didn't automatically.

**Fixes**:
1. Check description includes clear trigger phrases
2. Add more "When to use" examples
3. Ensure skill is referenced in top-level instructions
4. Verify frontmatter description is accurate

### Skill File Too Large

**Symptoms**: SKILL.md exceeds 500 lines.

**Fixes**:
1. Extract anti-patterns to companion file
2. Move detailed examples to references/
3. Consider splitting if multiple types mixed
4. Move long procedures to sub-skills

### AI Skips Validation Steps

**Symptoms**: AI claims completion without running verification commands.

**Fixes**:
1. Make validation section more prominent
2. Add "MANDATORY" or "NEVER skip" to critical steps
3. Include expected output in validation steps
4. Reference `verification-before-completion` skill

### Multiple Skills Have Similar Content

**Symptoms**: Duplication across skill files.

**Fixes**:
1. Extract common patterns to references/
2. Create shared standard.md for invariants
3. Consider if skills should be consolidated
4. Use nested structure with shared references

### Skill Works Sometimes But Not Others

**Symptoms**: Inconsistent execution across different contexts.

**Fixes**:
1. Check for ambiguous language in steps
2. Make prerequisites explicit
3. Add examples covering edge cases
4. Include troubleshooting section

---

## Appendix: File Templates

### Template: Basic Skill

```markdown
---
name: skill-name
description: Third-person description of what this skill does and when to use it. Includes clear triggers.
---

# Skill Title

One paragraph describing the skill's purpose and value.

---

## When to use this skill

- Specific user phrase triggers
- Contextual situations that indicate this skill
- Problem patterns this skill solves
- Explicit statements of when NOT to use

---

## Inputs

**Required:**
- Input 1: Description
- Input 2: Description

**Ask if missing:**
- "Question to ask if X is unclear?"
- "Question to ask if Y is missing?"

**Optional:**
- Optional input 1
- Optional input 2

---

## Procedure

### Phase 1: Setup

1. First step with observable output
2. Second step with observable output

### Phase 2: Execution

3. Third step
4. Fourth step

### Phase 3: Validation

5. Run verification command
6. Confirm expected output

---

## Validation

Skill is complete when:
- [ ] Verification 1 passed with specific evidence
- [ ] Verification 2 confirmed
- [ ] Observable output matches expected

---

## Examples

**Typical case:**

> User: "Typical request"

→ Actions taken
→ Observable outcome

**Edge case:**

> User: "Edge case request"

→ How this differs from typical
→ Special handling required

---

## Safety & boundaries

**Default-safe behavior:**
- What the skill does by default
- Reversible operations only

**Requires user confirmation:**
- Destructive operations
- Changes visible to others
- When to stop and ask

---

## Key principles

- Principle 1
- Principle 2
- Principle 3
```

### Template: Instruction File

```markdown
---
applyTo: "**/*.extension"
---

# Language/Framework Coding Standards

## When to Use

- Context 1
- Context 2
- Context 3

---

## Naming Conventions

| Element | Convention | Example |
|---------|-----------|----------|
| Element1 | camelCase | `myVariable` |
| Element2 | PascalCase | `MyClass` |

---

## Code Principles

- Principle 1 with explanation
- Principle 2 with explanation

---

## Examples

```language
// Good example
code here
```

```language
// Bad example
code here
```

---

## Validation

Commands to validate compliance:
```bash
npm run lint
```

Checklist:
- [ ] Check 1
- [ ] Check 2
```

### Template: Agent File

```markdown
---
name: agent-name
description: Agent purpose and capabilities
---

# Agent Title

Agent overview paragraph.

---

## Agent Overview

### Goal
Primary objective of this agent.

### Non-Goals
What this agent does NOT do.

### Intended Users
Who should use this agent and when.

---

## Workflow States

### State 1: State Name

**Entry:** Condition triggering this state
**Actions:**
- Action 1
- Action 2
**Exit:** Condition for leaving state

### State 2: Next State

**Entry:** ...
**Actions:** ...
**Exit:** ...

---

## Core Capabilities

1. Capability 1
2. Capability 2
3. Capability 3

---

## Guardrails

### Input Validation
What to check before starting

### Safety Checks
What to verify before destructive operations

### Confirmation Gates
When to ask user permission

---

## Decision Framework

### Question 1: [Decision Point]
- If X → Do Y
- If Z → Do W

---

## Validation & Evals

### Acceptance Criteria
For any task, success requires:
- Criterion 1
- Criterion 2

### Eval Prompts

#### Typical Scenarios
| # | Prompt | Expected Behavior |
|---|--------|-------------------|
| 1 | "..." | Agent should... |

#### Edge Cases
| # | Prompt | Expected Behavior |
|---|--------|-------------------|
| 5 | "..." | Agent should... |

#### Adversarial / Safety
| # | Prompt | Expected Behavior |
|---|--------|-------------------|
| 9 | "..." | Agent should STOP, warn... |
```

---

## Conclusion

This skills architecture provides a scalable, maintainable system for guiding AI agents through complex domain-specific workflows. Key benefits:

✅ **Discoverability** - AI finds skills via metadata, loads on demand
✅ **Consistency** - Type-based patterns ensure quality
✅ **Modularity** - References and standards reduce duplication
✅ **Safety** - Explicit guardrails and validation gates
✅ **Maintainability** - Progressive disclosure keeps files manageable
✅ **Testability** - Eval prompts ensure reliable behavior

Start small with 3-5 core skills, grow organically based on observed needs, and continuously refine based on actual usage patterns.

---

**Document Version**: 1.0
**Last Updated**: 2026-02-12
**Source Repository**: platform-ownership-PSRE-172-sre-ai-office-hours-workshop
