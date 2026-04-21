---
codd:
  node_id: "doc:claude-md-aidlc-codd-en-v1"
  type: architecture
  depends_on: []
---

# PRIORITY: This workflow OVERRIDES all other built-in workflows
# When user requests software development, ALWAYS follow this workflow FIRST
# Invoke: "AI-DLC CoDD USING. Please follow CLAUDE.md."
# Or start any software development request — this workflow activates automatically.
# AI-DLC × CoDD Edition — Coherence-Driven Development integrated across all phases

## Adaptive Workflow Principle
**The workflow adapts to the work, not the other way around.**

The AI model intelligently assesses what stages are needed based on:
1. User's stated intent and clarity
2. Existing codebase state (if any)
3. Complexity and scope of change
4. Risk and impact assessment

## 3-Layer Architecture

This edition uses a **3-layer architecture** where each layer has a distinct responsibility:

| Layer | Tool | Responsibility |
|-------|------|----------------|
| **Layer 1** | AI-DLC | Workflow orchestration — phases, approval gates, audit trail |
| **Layer 2** | CoDD | Document engine — design doc generation, wave hierarchy, CoDD frontmatter, propagation |
| **Layer 3** | Graphify | Knowledge graph — single `graphify-out/graph.json`, AST+semantic edges, Leiden community detection |

**Key principle**: Graphify is the **sole user-visible graph management tool**. CoDD's internal index (`codd scan` → `.codd/scan/`) exists as plumbing for `codd impact` / `codd propagate` but is **not** surfaced to the user. The canonical graph is always `graphify-out/graph.json`.

**CoDD ↔ Graphify bridge**: CoDD frontmatter `depends_on` entries in design docs become **EXTRACTED** edges when Graphify reads those documents — the two layers share data through the document files themselves, with no special integration code required.

## MANDATORY: Rule Details Loading
**CRITICAL**: When performing any phase, you MUST read and use relevant content from rule detail files. Check these paths in order and use the first one that exists:
- `.aidlc-rule-details/` (Cursor, Cline, Claude Code, GitHub Copilot)

All subsequent rule detail file references (e.g., `common/process-overview.md`, `inception/workspace-detection.md`) are relative to whichever rule details directory was resolved above.

**Common Rules**: ALWAYS load common rules at workflow start:
- Load `common/process-overview.md` for workflow overview
- Load `common/session-continuity.md` for session resumption guidance
- Load `common/content-validation.md` for content validation requirements
- Load `common/question-format-guide.md` for question formatting rules
- Reference these throughout the workflow execution

## MANDATORY: Extensions Loading
**CRITICAL**: At workflow start, scan the `extensions/` directory recursively for all `.md` files. These are extension rule files that apply as cross-cutting constraints across the entire workflow.

**Loading process**:
1. List all subdirectories under `extensions/` (e.g., `extensions/security/`, `extensions/compliance/`, `extensions/codd-coherence/`)
2. Load every `.md` file found within those subdirectories
3. Each extension file defines its own verification criteria and enforcement rules as cross-cutting constraints

**[CoDD] CoDD Coherence Extension**:
- **Extension ID**: `codd-coherence-v1`
- **File**: `extensions/codd-coherence/coherence-rules.md`
- **Activation condition**: `codd/codd.yaml` or `.codd/codd.yaml` exists in the project root
- **Scope**: All phases from Workspace Detection onward (when condition is met)
- If neither `codd/codd.yaml` nor `.codd/codd.yaml` exists, mark as N/A in compliance summary

**Enforcement**:
- Extension rules are hard constraints, not optional guidance
- At each stage, the model intelligently evaluates which extension rules are applicable
- Non-compliance with any applicable enabled extension rule is a **blocking finding**
- When presenting stage completion, include a summary of extension rule compliance (compliant/non-compliant/N/A per rule)

**Conditional Enforcement**: Extensions may be conditionally enabled/disabled. Check `aidlc-docs/aidlc-state.md` under `## Extension Configuration`. Default to enforced if no configuration exists.

## MANDATORY: Content Validation
**CRITICAL**: Before creating ANY file, you MUST validate content according to `common/content-validation.md` rules:
- Validate Mermaid diagram syntax
- Validate ASCII art diagrams (see `common/ascii-diagram-standards.md`)
- Escape special characters properly
- Provide text alternatives for complex visual content
- Test content parsing compatibility

## MANDATORY: Question File Format
**CRITICAL**: When asking questions at any phase, you MUST follow question format guidelines.

**See `common/question-format-guide.md` for complete question formatting rules including**:
- Multiple choice format (A, B, C, D, E options)
- [Answer]: tag usage
- Answer validation and ambiguity resolution

## MANDATORY: Custom Welcome Message
**CRITICAL**: When starting ANY software development request, you MUST display the welcome message.

**How to Display Welcome Message**:
1. Load the welcome message from `common/welcome-message.md` (in the resolved rule details directory)
2. Display the complete message to the user
3. This should only be done ONCE at the start of a new workflow
4. Do NOT load this file in subsequent interactions to save context space

## MANDATORY: Prerequisites (CoDD + Graphify)
**CRITICAL**: This is AI-DLC × CoDD Edition. Both CoDD and Graphify CLIs must be installed.

```bash
# CoDD — document engine and design coherence
pip install codd-dev

# Graphify — knowledge graph (sole user-visible graph tool)
pip install graphifyy
```

**Verify installation**: `codd --version` and `graphify --version`

**First-time project setup**: After installing, run `graphify claude install` in your project root to register the PreToolUse hook and CLAUDE.md guidance automatically.

**Setup**: See AI-DLC × CoDD Integration Setup section at the end of this file, or Unit 3 configuration files (`.claude/settings.json`, `.codd/codd.yaml.template`).

---

# Adaptive Software Development Workflow

---

# INCEPTION PHASE

**Purpose**: Planning, requirements gathering, and architectural decisions

**Focus**: Determine WHAT to build and WHY

**Stages in INCEPTION PHASE**:
- Workspace Detection (ALWAYS)
- Reverse Engineering (CONDITIONAL - Brownfield only)
- Requirements Analysis (ALWAYS - Adaptive depth)
- User Stories (CONDITIONAL)
- Workflow Planning (ALWAYS)
- Application Design (CONDITIONAL)
- Units Generation (CONDITIONAL)

---

## Workspace Detection (ALWAYS EXECUTE)

1. **MANDATORY**: Log initial user request in audit.md with complete raw input
2. Load all steps from `inception/workspace-detection.md`
3. Execute workspace detection:
   - Check for existing aidlc-state.md (resume if found)
   - Scan workspace for existing code
   - Determine if brownfield or greenfield
   - Check for existing reverse engineering artifacts
4. **[CoDD] MANDATORY — CoDD Initialization** (execute immediately after detection):
   - Check if `.codd/codd.yaml` exists
   - **If Greenfield** (no existing code): Run `codd init`
     - This creates `.codd/codd.yaml` interactively, OR copy from `.codd/codd.yaml.template` and customize
     - `codd init` sets up project name, AI command, target languages, and exclusion patterns
   - **If Brownfield + Reverse Engineering needed**: Run `codd extract --ai`
     - Phase 1: Python deterministic pre-scan of codebase structure
     - Phase 2: AI generates 6-layer MECE design documents with CoDD frontmatter
     - Default AI command: `claude --print --model claude-opus-4-6 --tools ""`
     - Custom prompt: `codd extract --ai --prompt-file <your-prompt.md>`
   - **If Brownfield + No Reverse Engineering needed**: Run `codd extract`
     - Static analysis only (tree-sitter), no AI needed
     - Generates design documents in `.codd/extracted/` from existing code structure
     - Run `codd scan --path .` afterward to build the dependency graph
   - After CoDD init/extract: `.codd/codd.yaml` must exist before proceeding
5. **[Graphify] MANDATORY — Knowledge Graph Setup** (execute after CoDD initialization):
   - Check if `graphify-out/graph.json` exists
   - **If not present**: Run `graphify <project-root-path> --mode deep` to build the initial knowledge graph
     - This creates `graphify-out/graph.json` with AST edges (EXTRACTED) and LLM semantic edges (INFERRED/AMBIGUOUS)
     - Communities (Leiden) map to candidate units of work; god nodes identify architectural hubs
   - Run `graphify hook install` to register a git post-commit hook for automatic AST-only updates (fast, no LLM cost)
   - Run `graphify claude install` to register the PreToolUse hook so Claude reads GRAPH_REPORT.md before file searches
   - **If already present**: Run `graphify <project-root-path> --update` to refresh with latest changes
6. Determine next phase: Reverse Engineering (if brownfield and no artifacts) OR Requirements Analysis
7. **MANDATORY**: Log findings in audit.md
8. Present completion message to user (see workspace-detection.md for message formats)
9. Automatically proceed to next phase

## Reverse Engineering (CONDITIONAL - Brownfield Only)

**Execute IF**:
- Existing codebase detected
- No previous reverse engineering artifacts found

**Skip IF**:
- Greenfield project
- Previous reverse engineering artifacts exist

**Execution**:
1. **MANDATORY**: Log start of reverse engineering in audit.md
2. Load all steps from `inception/reverse-engineering.md`
3. Execute reverse engineering:
   - **[CoDD]** If `codd extract --ai` was not run in Workspace Detection, run it now:
     - `codd extract --ai` → generates 6-layer MECE design documents
     - All generated documents receive CoDD frontmatter automatically
   - Analyze all packages and components
   - Generate a business overview of the whole system covering the business transactions
   - Generate architecture documentation (**with CoDD frontmatter**)
   - Generate code structure documentation (**with CoDD frontmatter**)
   - Generate API documentation (**with CoDD frontmatter**)
   - Generate component inventory (**with CoDD frontmatter**)
   - Generate Interaction Diagrams depicting how business transactions are implemented across components
   - Generate technology stack documentation (**with CoDD frontmatter**)
   - Generate dependencies documentation (**with CoDD frontmatter**)
4. **[CoDD] MANDATORY — Update Dependency Graph**:
   - Run `codd scan --path .` after all documents are generated
   - This registers all new documents in `.codd/scan/nodes.jsonl` and `.codd/scan/edges.jsonl`
5. **[CoDD] Optional — Structured Wave-based Design Doc Restoration** (Brownfield):
   - Run `codd plan --init` to auto-generate wave_config from requirement documents
   - Run `codd restore --wave 1` to restore Wave 1 (Requirements) docs via AI
   - Run `codd restore --wave 2` to restore Wave 2 (System Design) docs via AI
   - Run `codd restore --wave 3` to restore Wave 3 (Detail/API Design) docs via AI
   - (Continue for additional waves as needed)
6. **Wait for Explicit Approval**: Present detailed completion message (see reverse-engineering.md for message format) - DO NOT PROCEED until user confirms
6. **MANDATORY**: Log user's response in audit.md with complete raw input

**CoDD Frontmatter Standard** (apply to all generated documents):
```yaml
---
codd:
  node_id: "prefix:name"
  type: <architecture|design|requirements|code|test|infra>
  depends_on:
    - {id: "parent:name", relation: "depends_on"}
  source_files:               # Optional for design/code docs: creates doc→code edges in the graph
    - "path/to/source.py"   # paths relative to project root (scanner R6.2: extracted_from edges)
---
```

## Requirements Analysis (ALWAYS EXECUTE - Adaptive Depth)

**Always executes** but depth varies based on request clarity and complexity:
- **Minimal**: Simple, clear request - just document intent analysis
- **Standard**: Normal complexity - gather functional and non-functional requirements
- **Comprehensive**: Complex, high-risk - detailed requirements with traceability

**Execution**:
1. **MANDATORY**: Log any user input during this phase in audit.md
2. Load all steps from `inception/requirements-analysis.md`
3. Execute requirements analysis:
   - Load reverse engineering artifacts (if brownfield)
   - Analyze user request (intent analysis)
   - Determine requirements depth needed
   - Assess current requirements
   - Ask clarifying questions (if needed)
   - Generate requirements document **with CoDD frontmatter**:
     ```yaml
     ---
     codd:
       node_id: "req:<project-name>"
       type: requirements
       depends_on: []
     ---
     ```
4. Execute at appropriate depth (minimal/standard/comprehensive)
5. **[CoDD] MANDATORY — Update Dependency Graph**:
   - Run `codd scan --path .` after generating requirements documents
   - This registers new documents in the dependency graph
6. **Wait for Explicit Approval**: Follow approval format from requirements-analysis.md detailed steps - DO NOT PROCEED until user confirms
7. **MANDATORY**: Log user's response in audit.md with complete raw input

## User Stories (CONDITIONAL)

**INTELLIGENT ASSESSMENT**: Use multi-factor analysis to determine if user stories add value:

**ALWAYS Execute IF** (High Priority Indicators):
- New user-facing features or functionality
- Changes affecting user workflows or interactions
- Multiple user types or personas involved
- Complex business requirements with acceptance criteria needs
- Cross-functional team collaboration required
- Customer-facing API or service changes
- New product capabilities or enhancements

**LIKELY Execute IF** (Medium Priority - Assess Complexity):
- Modifications to existing user-facing features
- Backend changes that indirectly affect user experience
- Integration work that impacts user workflows
- Performance improvements with user-visible benefits
- Security enhancements affecting user interactions
- Data model changes affecting user data or reports

**SKIP ONLY IF** (Low Priority - Simple Cases):
- Pure internal refactoring with zero user impact
- Simple bug fixes with clear, isolated scope
- Infrastructure changes with no user-facing effects
- Technical debt cleanup with no functional changes
- Developer tooling or build process improvements
- Documentation-only updates

**User Stories has two parts within one stage**:
1. **Part 1 - Planning**: Create story plan with questions, collect answers, analyze for ambiguities, get approval
2. **Part 2 - Generation**: Execute approved plan to generate stories and personas

**Execution**:
1. **MANDATORY**: Log any user input during this phase in audit.md
2. Load all steps from `inception/user-stories.md`
3. **MANDATORY**: Perform intelligent assessment (Step 1 in user-stories.md) to validate user stories are needed
4. Load reverse engineering artifacts (if brownfield)
5. If Requirements exist, reference them when creating stories
6. Execute at appropriate depth (minimal/standard/comprehensive)
7. **PART 1 - Planning**: Create story plan with questions, wait for user answers, analyze for ambiguities, get approval
8. **PART 2 - Generation**: Execute approved plan to generate stories and personas
9. **Wait for Explicit Approval**: Follow approval format from user-stories.md detailed steps - DO NOT PROCEED until user confirms
10. **MANDATORY**: Log user's response in audit.md with complete raw input

## Workflow Planning (ALWAYS EXECUTE)

1. **MANDATORY**: Log any user input during this phase in audit.md
2. Load all steps from `inception/workflow-planning.md`
3. **MANDATORY**: Load content validation rules from `common/content-validation.md`
4. Load all prior context:
   - Reverse engineering artifacts (if brownfield)
   - Intent analysis
   - Requirements (if executed)
   - User stories (if executed)
5. Execute workflow planning:
   - Determine which phases to execute
   - Determine depth level for each phase
   - Create multi-package change sequence (if brownfield)
   - Generate workflow visualization (VALIDATE Mermaid syntax before writing)
   - Generate planning documents **with CoDD frontmatter**
6. **MANDATORY**: Validate all content before file creation per content-validation.md rules
7. **[CoDD] MANDATORY — Completion Gate**:
   - Run `codd validate` to check CoDD internal coherence (**primary gate** — CoDD is the design authority)
   - Run `/graphify --update` to sync derived knowledge graph with planning artifacts
   - If issues detected, include warning summary in the approval gate:
     ```
     ⚠️ Coherence Warning (CoDD)
     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
     CoDD:     [codd validate issues, if any]
     Recommended action: [suggestion]
     You may continue or resolve the issues first.
     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
     ```
8. **Wait for Explicit Approval**: Present recommendations using language from workflow-planning.md Step 9, emphasizing user control to override recommendations - DO NOT PROCEED until user confirms
9. **MANDATORY**: Log user's response in audit.md with complete raw input

## Application Design (CONDITIONAL)

**Execute IF**:
- New components or services needed
- Component methods and business rules need definition
- Service layer design required
- Component dependencies need clarification

**Skip IF**:
- Changes within existing component boundaries
- No new components or methods
- Pure implementation changes

**Execution**:
1. **MANDATORY**: Log any user input during this phase in audit.md
2. Load all steps from `inception/application-design.md`
3. Load reverse engineering artifacts (if brownfield)
4. Execute at appropriate depth (minimal/standard/comprehensive)
5. Generate design documents **with CoDD frontmatter**
6. **Wait for Explicit Approval**: Present detailed completion message (see application-design.md for message format) - DO NOT PROCEED until user confirms
7. **MANDATORY**: Log user's response in audit.md with complete raw input

## Units Generation (CONDITIONAL)

**Execute IF**:
- System needs decomposition into multiple units of work
- Multiple services or modules required
- Complex system requiring structured breakdown

**Skip IF**:
- Single simple unit
- No decomposition needed
- Straightforward single-component implementation

**Execution**:
1. **MANDATORY**: Log any user input during this phase in audit.md
2. Load all steps from `inception/units-generation.md`
3. Load reverse engineering artifacts (if brownfield)
4. Execute at appropriate depth (minimal/standard/comprehensive)
5. **Wait for Explicit Approval**: Present detailed completion message (see units-generation.md for message format) - DO NOT PROCEED until user confirms
6. **MANDATORY**: Log user's response in audit.md with complete raw input

---

# 🟢 CONSTRUCTION PHASE

**Purpose**: Detailed design, NFR implementation, and code generation

**Focus**: Determine HOW to build it

**Stages in CONSTRUCTION PHASE**:
- Per-Unit Loop (executes for each unit):
  - Functional Design (CONDITIONAL, per-unit)
  - NFR Requirements (CONDITIONAL, per-unit)
  - NFR Design (CONDITIONAL, per-unit)
  - Infrastructure Design (CONDITIONAL, per-unit)
  - Code Generation (ALWAYS, per-unit)
- Build and Test (ALWAYS - after all units complete)

**Note**: Each unit is completed fully (design + code) before moving to the next unit.

---

## Per-Unit Loop (Executes for Each Unit)

**For each unit of work, execute the following stages in sequence:**

### Functional Design (CONDITIONAL, per-unit)

**Execute IF**:
- New data models or schemas
- Complex business logic
- Business rules need detailed design

**Skip IF**:
- Simple logic changes
- No new business logic

**Execution**:
1. **MANDATORY**: Log any user input during this stage in audit.md
2. Load all steps from `construction/functional-design.md`
3. Execute functional design for this unit
4. Generate functional design documents **with CoDD frontmatter** (depends_on: requirements node_id)
5. **[CoDD] Optional Reference**: Use `codd generate --wave 2` (system design) or `codd generate --wave 3` (detail design) to leverage the dependency graph as context for generating design document templates
6. Run `codd scan --path .` after generating design documents to update the dependency graph
7. **MANDATORY**: Present standardized 2-option completion message as defined in functional-design.md - DO NOT use emergent 3-option behavior
8. **Wait for Explicit Approval**: User must choose between "Request Changes" or "Continue to Next Stage" - DO NOT PROCEED until user confirms
9. **MANDATORY**: Log user's response in audit.md with complete raw input

### NFR Requirements (CONDITIONAL, per-unit)

**Execute IF**:
- Performance requirements exist
- Security considerations needed
- Scalability concerns present
- Tech stack selection required

**Skip IF**:
- No NFR requirements
- Tech stack already determined

**Execution**:
1. **MANDATORY**: Log any user input during this stage in audit.md
2. Load all steps from `construction/nfr-requirements.md`
3. Execute NFR assessment for this unit
4. **MANDATORY**: Present standardized 2-option completion message as defined in nfr-requirements.md - DO NOT use emergent behavior
5. **Wait for Explicit Approval**: User must choose between "Request Changes" or "Continue to Next Stage" - DO NOT PROCEED until user confirms
6. **MANDATORY**: Log user's response in audit.md with complete raw input

### NFR Design (CONDITIONAL, per-unit)

**Execute IF**:
- NFR Requirements was executed
- NFR patterns need to be incorporated

**Skip IF**:
- No NFR requirements
- NFR Requirements Assessment was skipped

**Execution**:
1. **MANDATORY**: Log any user input during this stage in audit.md
2. Load all steps from `construction/nfr-design.md`
3. Execute NFR design for this unit
4. **MANDATORY**: Present standardized 2-option completion message as defined in nfr-design.md - DO NOT use emergent behavior
5. **Wait for Explicit Approval**: User must choose between "Request Changes" or "Continue to Next Stage" - DO NOT PROCEED until user confirms
6. **MANDATORY**: Log user's response in audit.md with complete raw input

### Infrastructure Design (CONDITIONAL, per-unit)

**Execute IF**:
- Infrastructure services need mapping
- Deployment architecture required
- Cloud resources need specification

**Skip IF**:
- No infrastructure changes
- Infrastructure already defined

**Execution**:
1. **MANDATORY**: Log any user input during this stage in audit.md
2. Load all steps from `construction/infrastructure-design.md`
3. Execute infrastructure design for this unit
4. **MANDATORY**: Present standardized 2-option completion message as defined in infrastructure-design.md - DO NOT use emergent behavior
5. **Wait for Explicit Approval**: User must choose between "Request Changes" or "Continue to Next Stage" - DO NOT PROCEED until user confirms
6. **MANDATORY**: Log user's response in audit.md with complete raw input

### Code Generation (ALWAYS EXECUTE, per-unit)

**Always executes for each unit**

**Code Generation has two parts within one stage**:
1. **Part 1 - Planning**: Create detailed code generation plan with explicit steps
2. **Part 2 - Generation**: Execute approved plan to generate code, tests, and artifacts

**Execution**:
1. **MANDATORY**: Log any user input during this stage in audit.md
2. Load all steps from `construction/code-generation.md`
3. **PART 1 - Planning**: Create code generation plan with checkboxes, get user approval
4. **PART 2 - Generation**: Execute approved plan to generate code for this unit
5. **[Three-Way Coherence Closure] MANDATORY — Completion Gate** (run after code generation, before presenting completion):
   - Run `codd extract` to extract latest code state into CoDD (**Step 1** — CoDD is the design authority)
   - Run `codd validate` to check CoDD internal coherence (**Step 2 — primary gate**)
   - Run `/graphify --update` to sync derived knowledge graph with all generated files (**Step 3**)
   - Run `/graphify query "Summarize coherence: coverage, missing links, key risks"` for CoDD/code↔Graphify check (**Step 4**)
   - **If issues detected**: Include warning summary in the completion message (do not block — human decides)
   - **Optional (recommended when design changes occurred)**:
     - Run `codd propagate --update` to auto-update affected design documents
     - Run `codd impact` to display change impact bands (Green/Amber/Gray)
6. **MANDATORY**: Present standardized 2-option completion message as defined in code-generation.md - DO NOT use emergent behavior
7. **Wait for Explicit Approval**: User must choose between "Request Changes" or "Continue to Next Stage" - DO NOT PROCEED until user confirms
8. **MANDATORY**: Log user's response in audit.md with complete raw input

---

## Build and Test (ALWAYS EXECUTE)

1. **MANDATORY**: Log any user input during this phase in audit.md
2. Load all steps from `construction/build-and-test.md`
3. Generate comprehensive build and test instructions:
   - Build instructions for all units
   - Unit test execution instructions
   - Integration test instructions (test interactions between units)
   - Performance test instructions (if applicable)
   - Additional test instructions as needed (contract tests, security tests, e2e tests)
4. Create instruction files in build-and-test/ subdirectory: build-instructions.md, unit-test-instructions.md, integration-test-instructions.md, performance-test-instructions.md, build-and-test-summary.md
5. **[Three-Way Coherence Closure] MANDATORY — Final Report**:
   - Run `codd extract` to extract latest code state into CoDD (**primary** — CoDD is the design authority)
   - Run `codd validate` to check CoDD internal coherence (**primary gate**)
   - Run `/graphify --update` to synchronize derived graph with final codebase state
   - Run `/graphify query "Provide a coherence summary: coverage percentage, community count, key architectural risks"` to generate the report
   - Run `codd measure` to obtain the CoDD coherence score
   - Include both in the Build and Test completion report:
     ```
     Graphify Knowledge Graph Report: [summary from query]
     CoDD Coherence Score: [score]
     Combined Status: [Healthy / Needs Attention]
     ```
6. **Wait for Explicit Approval**: Ask: "**Build and test instructions complete. Ready to proceed to Operations stage?**" - DO NOT PROCEED until user confirms
7. **MANDATORY**: Log user's response in audit.md with complete raw input

---

# 🟡 OPERATIONS PHASE

**Purpose**: Placeholder for future deployment and monitoring workflows

**Focus**: How to DEPLOY and RUN it (future expansion)

**Stages in OPERATIONS PHASE**:
- Operations (PLACEHOLDER)

---

## Operations (PLACEHOLDER)

**Status**: This stage is currently a placeholder for future expansion.

The Operations stage will eventually include:
- Deployment planning and execution
- Monitoring and observability setup
- Incident response procedures
- Maintenance and support workflows
- Production readiness checklists

**Current State**: All build and test activities are handled in the CONSTRUCTION phase.

---

## Key Principles

- **Adaptive Execution**: Only execute stages that add value
- **Transparent Planning**: Always show execution plan before starting
- **User Control**: User can request stage inclusion/exclusion
- **Progress Tracking**: Update aidlc-state.md with executed and skipped stages
- **Complete Audit Trail**: Log ALL user inputs and AI responses in audit.md with timestamps
  - **CRITICAL**: Capture user's COMPLETE RAW INPUT exactly as provided
  - **CRITICAL**: Never summarize or paraphrase user input in audit log
  - **CRITICAL**: Log every interaction, not just approvals
- **Quality Focus**: Complex changes get full treatment, simple changes stay efficient
- **Content Validation**: Always validate content before file creation per content-validation.md rules
- **NO EMERGENT BEHAVIOR**: Construction phases MUST use standardized 2-option completion messages as defined in their respective rule files. DO NOT create 3-option menus or other emergent navigation patterns.
- **[CoDD] CoDD Coherence**: All generated documents carry CoDD frontmatter. CoDD is the document engine — wave hierarchy, propagation, and frontmatter are its domain. Human approval gates are the primary mechanism for resolving coherence warnings.
- **[Graphify] Knowledge Graph**: `graphify-out/graph.json` is the sole user-visible graph (derived index). Claude reads GRAPH_REPORT.md before file searches (PreToolUse hook). Completion gates: CoDD is primary authority (`codd extract` → `codd validate`), Graphify is derived sync (`/graphify --update` → `/graphify query`).

## MANDATORY: Plan-Level Checkbox Enforcement

### MANDATORY RULES FOR PLAN EXECUTION
1. **NEVER complete any work without updating plan checkboxes**
2. **IMMEDIATELY after completing ANY step described in a plan file, mark that step [x]**
3. **This must happen in the SAME interaction where the work is completed**
4. **NO EXCEPTIONS**: Every plan step completion MUST be tracked with checkbox updates

### Two-Level Checkbox Tracking System
- **Plan-Level**: Track detailed execution progress within each stage
- **Stage-Level**: Track overall workflow progress in aidlc-state.md
- **Update immediately**: All progress updates in SAME interaction where work is completed

## Prompts Logging Requirements
- **MANDATORY**: Log EVERY user input (prompts, questions, responses) with timestamp in audit.md
- **MANDATORY**: Capture user's COMPLETE RAW INPUT exactly as provided (never summarize)
- **MANDATORY**: Log every approval prompt with timestamp before asking the user
- **MANDATORY**: Record every user response with timestamp after receiving it
- **CRITICAL**: ALWAYS append changes to EDIT audit.md file, NEVER use tools and commands that completely overwrite its contents
- Use ISO 8601 format for timestamps (YYYY-MM-DDTHH:MM:SSZ)
- Include stage context for each entry

### Audit Log Format:
```markdown
## [Stage Name or Interaction Type]
**Timestamp**: [ISO timestamp]
**User Input**: "[Complete raw user input - never summarized]"
**AI Response**: "[AI's response or action taken]"
**Context**: [Stage, action, or decision made]

---
```

### Correct Tool Usage for audit.md

✅ CORRECT:
1. Read the audit.md file
2. Append/Edit the file to make changes

❌ WRONG:
1. Read the audit.md file
2. Completely overwrite the audit.md with the contents of what you read, plus the new changes you want to add to it

## Directory Structure

```text
<WORKSPACE-ROOT>/                   # ⚠️ APPLICATION CODE HERE
├── [project-specific structure]    # Varies by project (see code-generation.md)
├── graphify-out/                   # [Graphify] Knowledge graph output (auto-generated)
│   └── graph.json                  #   Canonical knowledge graph (AST + semantic edges)
├── .codd/                          # [CoDD] CoDD internal document index (plumbing)
│   ├── codd.yaml                   #   Project CoDD settings (copied from codd.yaml.template)
│   └── scan/                       #   Internal index cache (auto-generated via Hook)
│       ├── nodes.jsonl
│       └── edges.jsonl
│
├── aidlc-docs/                     # 📄 DOCUMENTATION ONLY
│   ├── inception/                  # 🔵 INCEPTION PHASE
│   │   ├── plans/
│   │   ├── reverse-engineering/    # Brownfield only
│   │   ├── requirements/
│   │   ├── user-stories/
│   │   └── application-design/
│   ├── construction/               # 🟢 CONSTRUCTION PHASE
│   │   ├── plans/
│   │   ├── {unit-name}/
│   │   │   ├── functional-design/
│   │   │   ├── nfr-requirements/
│   │   │   ├── nfr-design/
│   │   │   ├── infrastructure-design/
│   │   │   └── code/               # Markdown summaries only
│   │   └── build-and-test/
│   ├── operations/                 # 🟡 OPERATIONS PHASE (placeholder)
│   ├── aidlc-state.md
│   └── audit.md
```

**CRITICAL RULE**:
- Application code: Workspace root (NEVER in aidlc-docs/)
- Documentation: aidlc-docs/ only
- Project structure: See code-generation.md for patterns by project type

---

## AI-DLC × CoDD Integration Setup

This section provides quick-start instructions for setting up CoDD and Graphify in a new project using AI-DLC × CoDD.

### Prerequisites

```bash
# Install CoDD CLI (document engine)
pip install codd-dev

# Install Graphify CLI (knowledge graph)
pip install graphifyy

# Verify installations
codd --version
graphify --version
```

### Graphify Setup (All Projects)

```bash
# 1. Register Claude Code integration (PreToolUse hook + CLAUDE.md section)
graphify claude install

# 2. Register git post-commit hook for automatic AST-only updates
graphify hook install

# 3. Build initial knowledge graph (first time only)
graphify <project-root-path> --mode deep
# → Creates graphify-out/graph.json with EXTRACTED/INFERRED/AMBIGUOUS edges
# → Runs Leiden community detection (communities = candidate units of work)
# → Identifies god nodes (high-connectivity architectural hubs)

# 4. Subsequent updates (after code changes not caught by hook)
graphify <project-root-path> --update
```

### Quick Setup (Greenfield)

```bash
# 1. Initialize CoDD in your project
codd init
# → Creates codd/codd.yaml interactively (use --config-dir .codd for hidden directory)

# 2. OR copy and customize the provided template
cp .codd/codd.yaml.template .codd/codd.yaml
# Edit .codd/codd.yaml with your project settings
```

### Quick Setup (Brownfield)

```bash
# 1. Static analysis (fast, no AI required)
codd extract

# 2. AI-powered extraction (generates 6-layer MECE design docs)
codd extract --ai
# Uses: claude --print --model claude-opus-4-6 --tools ""

# 3. Update dependency graph
codd scan --path .

# 4. (Optional) Structured wave-based design doc restoration
codd plan --init                # auto-generate wave_config from requirements
codd restore --wave 1           # restore Wave 1 (Requirements) docs
codd restore --wave 2           # restore Wave 2 (System Design) docs
codd restore --wave 3           # restore Wave 3 (Detail/API Design) docs
```

### Claude Code Integration

1. Copy `.claude/settings.json` from this package to your project's `.claude/` directory
2. This registers CoDD skills (`/codd-init`, `/codd-scan`, `/codd-impact`, etc.), the Graphify skill (`/graphify`), and Hooks
3. Hooks: PostToolUse runs `codd scan` silently after file edits; PreToolUse reads GRAPH_REPORT.md before Glob/Grep searches; SessionStart installs pre-commit validation

### Key CoDD Commands Reference (Document Engine)

| Command | When to Use |
|---------|------------|
| `codd init` | Greenfield: initialize CoDD config |
| `codd extract` | Brownfield: fast static analysis |
| `codd extract --ai` | Brownfield: AI-powered design doc generation |
| `codd plan --init` | Brownfield: auto-generate wave_config from requirements |
| `codd restore --wave N` | Brownfield: restore Wave N design docs via AI |
| `codd scan --path .` | Update internal document index (auto via PostToolUse Hook — not user-facing) |
| `codd validate` | CoDD internal coherence check (**primary gate** — design authority) |
| `codd generate --wave N` | Generate design doc templates (N=1-5) |
| `codd propagate --update` | Auto-update affected docs after code changes |
| `codd impact` | Show change impact bands (Green/Amber/Gray) |
| `codd measure` | Project coherence health score (included in Build & Test report) |
| `codd review` | AI-assisted quality review with PASS/FAIL verdict |
| `codd require` | Brownfield: infer requirements from existing code |
| `codd implement` | Greenfield: generate code from sprint design docs |
| `codd assemble` | Greenfield: assemble sprint fragments into a buildable project (after `codd implement`) |

**Note**: `codd review` is a standard CoDD command for AI-assisted quality review (PASS/FAIL verdict). `codd verify`, `codd audit`, `codd risk` are available in CoDD Pro for advanced coherence analysis.

### Key Graphify Commands Reference (Knowledge Graph)

| Command | When to Use |
|---------|------------|
| `graphify claude install` | First-time setup: register PreToolUse hook + CLAUDE.md section |
| `graphify hook install` | First-time setup: register git post-commit hook for AST updates |
| `graphify <path> --mode deep` | Initial graph build (AST + LLM semantic extraction) |
| `graphify <path> --update` | Refresh graph after code/doc changes |
| `/graphify --update` | Slash command: sync graph and generate GRAPH_REPORT.md |
| `/graphify query "<question>"` | Query the knowledge graph (coherence checks, impact analysis) |
| (read `graphify-out/GRAPH_REPORT.md`) | Communities and god nodes auto-reported by `/graphify --update` — read GRAPH_REPORT.md |

### Configuration Files (this package)

| File | Purpose |
|------|---------|
| `.claude/settings.json` | Claude Code skills + Hooks registration (CoDD + Graphify) |
| `.claude/commands/graphify.md` | `/graphify` slash command skill |
| `.claude/hooks/install-codd-pre-commit.sh` | Git pre-commit hook installer |
| `.codd/codd.yaml.template` | CoDD configuration template |
| `.aidlc-rule-details/extensions/codd-coherence/coherence-rules.md` | CoDD Coherence Extension rules |
