---
codd:
  node_id: "doc:reverse-engineering-en"
  type: document
  depends_on: []
---

# Reverse Engineering

**Purpose**: Analyze existing codebase and generate comprehensive design artifacts

**Execute when**: Brownfield project detected (existing code found in workspace)

**Skip when**: Greenfield project (no existing code)

**Rerun behavior**: Always rerun when brownfield project detected, even if artifacts exist. This ensures artifacts reflect current code state

## [CoDD] Pre-Step: AI-Powered Codebase Extraction

**MANDATORY if `codd extract --ai` was not run in Workspace Detection**:

```bash
# AI-powered extraction (generates 6-layer MECE design documents) — recommended command
PYTHONIOENCODING=utf-8 PYTHONUTF8=1 codd extract --ai --prompt-file .codd/extract-prompt-addendum.md
# → Phase 1: Python deterministic pre-scan of codebase structure
# → Phase 2: AI generates 6-layer MECE design documents with CoDD frontmatter
# → --prompt-file: forces plain-text file markers (--- FILE: xxx ---) so CoDD parser can split output
# → Default AI command: claude --print --model claude-opus-4-6 --tools ""
# → Generated documents stored in .codd/extracted/ (DRAFT status)
```

> ⚠️ **Windows Environment Note**: If your workspace path contains non-ASCII characters (e.g., Japanese), `codd extract --ai` may fail with a cp932 encoding error. The recommended command above already includes `PYTHONIOENCODING=utf-8 PYTHONUTF8=1` — use it as-is.
>
> **Why `--prompt-file` is required**: Without it, the AI may output file markers as `` ## `--- FILE: xxx ---` `` (Markdown heading format) instead of `--- FILE: xxx ---` (plain text). The CoDD parser only recognizes the plain-text form; the Markdown form causes only `_raw_ai_output.txt` to be saved with no individual files generated.

If `codd extract --ai` was already run in Workspace Detection, skip this step and proceed.

**All documents generated in Steps 1–9 MUST include CoDD frontmatter** (node_id, type, depends_on, source_files).

> **[CoDD] Note on `source_files:`**: When generating design documents, if the document covers specific source files (e.g., code-structure.md, api-documentation.md, component-inventory.md), include `source_files:` in the frontmatter with the actual file paths (relative to project root). This creates `extracted_from` edges in the dependency graph. For architecture/overview documents that don't map to specific files, `source_files:` may be omitted.
>
> **Primary source file linkage** is handled automatically by `codd extract --ai` → L1-L6 files in `.codd/extracted/` (when `.codd/extracted/` is included in `codd.yaml` `doc_dirs`). The AI-DLC generated docs in `aidlc-docs/` supplement this coverage.

---

## Step 1: Multi-Package Discovery

### 1.1 Scan Workspace
- All packages (not just mentioned ones)
- Package relationships via config files
- Package types: Application, CDK/Infrastructure, Models, Clients, Tests

### 1.2 Understand the Business Context
- The core business that the system is implementing overall
- The business overview of every package
- List of Business Transactions that are implemented in the system

### 1.3 Infrastructure Discovery
- CDK packages (package.json with CDK dependencies)
- Terraform (.tf files)
- CloudFormation (.yaml/.json templates)
- Deployment scripts

### 1.4 Build System Discovery
- Build systems: Brazil, Maven, Gradle, npm
- Config files for build-system declarations
- Build dependencies between packages

### 1.5 Service Architecture Discovery
- Lambda functions (handlers, triggers)
- Container services (Docker/ECS configs)
- API definitions (Smithy models, OpenAPI specs)
- Data stores (DynamoDB, S3, etc.)

### 1.6 Code Quality Analysis
- Programming languages and frameworks
- Test coverage indicators
- Linting configurations
- CI/CD pipelines

### 1.7 Multi-Language Supplemental Analysis

**MANDATORY**: Before proceeding to document generation, ask the user about additional languages that may need manual supplementation:

> **Question for user**: Does your project contain languages or frameworks beyond the primary language configured in `codd.yaml`?
>
> Please select all that apply:
> A) TypeScript/JavaScript (CDK stacks, React frontend, Lambda handlers, etc.)
> B) Java (Spring Boot, AWS SDK, domain models, etc.)
> C) Go (handlers, services, etc.)
> D) Other (please describe)
> E) Primary language only — no supplemental analysis needed
>
> [Answer]:

**Why this matters**: `codd extract` supports one primary language per `codd.yaml`. For multi-language projects, files in non-primary languages require manual AI reading to be included in the architecture documentation.

**If additional languages confirmed**, read the following files manually during Steps 2–8:
- **TypeScript/JavaScript**: CDK stacks (`lib/*.ts`, `cdk/*.ts`), frontend entry points (`src/App.tsx`, `src/pages/`), API modules (`src/api/`)
- **Java**: Domain models (`*Model.java`, `*Entity.java`), controllers (`*Controller.java`), services (`*Service.java`)
- **Go**: Entry points (`main.go`), handlers (`handler/*.go`), services (`service/*.go`)
- **Other**: User-specified file patterns

## Step 1: Generate Business Overview Documentation

Create `aidlc-docs/inception/reverse-engineering/business-overview.md`:

```markdown
# Business Overview

## Business Context Diagram
[Mermaid diagram showing the Business Context]

## Business Description
- **Business Description**: [Overall Business description of what the system does]
- **Business Transactions**: [List of Business Transactions that the system implements and their descriptions]
- **Business Dictionary**: [Business dictionary terms that the system follows and their meaning]

## Component Level Business Descriptions
### [Package/Component Name]
- **Purpose**: [What it does from the business perspective]
- **Responsibilities**: [Key responsibilities]
```

## Step 2: Generate Architecture Documentation

Create `aidlc-docs/inception/reverse-engineering/architecture.md`:

```markdown
# System Architecture

## System Overview
[High-level description of the system]

## Architecture Diagram
[Mermaid diagram showing all packages, services, data stores, relationships]

## Component Descriptions
### [Package/Component Name]
- **Purpose**: [What it does]
- **Responsibilities**: [Key responsibilities]
- **Dependencies**: [What it depends on]
- **Type**: [Application/Infrastructure/Model/Client/Test]

## Data Flow
[Mermaid sequence diagram of key workflows]

## Integration Points
- **External APIs**: [List with purposes]
- **Databases**: [List with purposes]
- **Third-party Services**: [List with purposes]

## Infrastructure Components
- **CDK Stacks**: [List with purposes]
- **Deployment Model**: [Description]
- **Networking**: [VPC, subnets, security groups]
```

## Step 3: Generate Code Structure Documentation

Create `aidlc-docs/inception/reverse-engineering/code-structure.md`:

```markdown
# Code Structure

## Build System
- **Type**: [Maven/Gradle/npm/Brazil]
- **Configuration**: [Key build files and settings]

## Key Classes/Modules
[Mermaid class diagram or module hierarchy]

### Existing Files Inventory
[List all source files with their purposes - these are candidates for modification in brownfield projects]

**Example format**:
- `[path/to/file]` - [Purpose/responsibility]

## Design Patterns
### [Pattern Name]
- **Location**: [Where used]
- **Purpose**: [Why used]
- **Implementation**: [How implemented]

## Critical Dependencies
### [Dependency Name]
- **Version**: [Version number]
- **Usage**: [How and where used]
- **Purpose**: [Why needed]
```

## Step 4: Generate API Documentation

Create `aidlc-docs/inception/reverse-engineering/api-documentation.md`:

```markdown
# API Documentation

## REST APIs
### [Endpoint Name]
- **Method**: [GET/POST/PUT/DELETE]
- **Path**: [/api/path]
- **Purpose**: [What it does]
- **Request**: [Request format]
- **Response**: [Response format]

## Internal APIs
### [Interface/Class Name]
- **Methods**: [List with signatures]
- **Parameters**: [Parameter descriptions]
- **Return Types**: [Return type descriptions]

## Data Models
### [Model Name]
- **Fields**: [Field descriptions]
- **Relationships**: [Related models]
- **Validation**: [Validation rules]
```

## Step 5: Generate Component Inventory

Create `aidlc-docs/inception/reverse-engineering/component-inventory.md`:

```markdown
# Component Inventory

## Application Packages
- [Package name] - [Purpose]

## Infrastructure Packages
- [Package name] - [CDK/Terraform] - [Purpose]

## Shared Packages
- [Package name] - [Models/Utilities/Clients] - [Purpose]

## Test Packages
- [Package name] - [Integration/Load/Unit] - [Purpose]

## Total Count
- **Total Packages**: [Number]
- **Application**: [Number]
- **Infrastructure**: [Number]
- **Shared**: [Number]
- **Test**: [Number]
```

## Step 6: Generate Technology Stack Documentation

Create `aidlc-docs/inception/reverse-engineering/technology-stack.md`:

```markdown
# Technology Stack

## Programming Languages
- [Language] - [Version] - [Usage]

## Frameworks
- [Framework] - [Version] - [Purpose]

## Infrastructure
- [Service] - [Purpose]

## Build Tools
- [Tool] - [Version] - [Purpose]

## Testing Tools
- [Tool] - [Version] - [Purpose]
```

## Step 7: Generate Dependencies Documentation

Create `aidlc-docs/inception/reverse-engineering/dependencies.md`:

```markdown
# Dependencies

## Internal Dependencies
[Mermaid diagram showing package dependencies]

### [Package A] depends on [Package B]
- **Type**: [Compile/Runtime/Test]
- **Reason**: [Why dependency exists]

## External Dependencies
### [Dependency Name]
- **Version**: [Version]
- **Purpose**: [Why used]
- **License**: [License type]
```

## Step 8: Generate Code Quality Assessment

Create `aidlc-docs/inception/reverse-engineering/code-quality-assessment.md`:

```markdown
# Code Quality Assessment

## Test Coverage
- **Overall**: [Percentage or Good/Fair/Poor/None]
- **Unit Tests**: [Status]
- **Integration Tests**: [Status]

## Code Quality Indicators
- **Linting**: [Configured/Not configured]
- **Code Style**: [Consistent/Inconsistent]
- **Documentation**: [Good/Fair/Poor]

## Technical Debt
- [Issue description and location]

## Patterns and Anti-patterns
- **Good Patterns**: [List]
- **Anti-patterns**: [List with locations]
```

## Step 8.5: Generate Interaction Diagrams

Create `aidlc-docs/inception/reverse-engineering/interaction-diagrams.md`:

```markdown
# Interaction Diagrams

## Overview
Key business transactions and their implementation flows across components.

## [Transaction Name] — Sequence Diagram

[Mermaid sequence diagram showing the call flow]

Example:
sequenceDiagram
    participant Client
    participant API Gateway
    participant Service
    participant Repository
    participant DB

    Client->>API Gateway: POST /api/resource
    API Gateway->>Service: create(request)
    Service->>Repository: save(entity)
    Repository->>DB: INSERT
    DB-->>Repository: OK
    Repository-->>Service: entity
    Service-->>API Gateway: response
    API Gateway-->>Client: 201 Created

## Component Interaction Map
[ASCII or Mermaid diagram showing which components call which]
```

**Coverage requirement**: Include one sequence diagram per major business transaction identified in `business-overview.md`.

## Step 9: Create Timestamp File

Create `aidlc-docs/inception/reverse-engineering/reverse-engineering-timestamp.md`:

```markdown
# Reverse Engineering Metadata

**Analysis Date**: [ISO timestamp]
**Analyzer**: AI-DLC
**Workspace**: [Workspace path]
**Total Files Analyzed**: [Number]

## Artifacts Generated
- [x] architecture.md
- [x] code-structure.md
- [x] api-documentation.md
- [x] component-inventory.md
- [x] technology-stack.md
- [x] dependencies.md
- [x] code-quality-assessment.md
```

## [CoDD] Step 9.5: Update Dependency Graph and Optional Wave Restoration

### MANDATORY — Update Dependency Graph and Validate Coherence
```bash
codd scan --path .
# → Registers all generated documents in .codd/scan/nodes.jsonl and .codd/scan/edges.jsonl
# → Run after all reverse engineering documents are complete

codd validate --path .
# → Checks frontmatter compliance and dependency reference consistency
# → Include any warnings in the Step 11 completion message (non-blocking)
```

> **Note on validate results**: `depended_by is missing reciprocal reference` warnings are non-blocking (CODD-02 Amber). Include the error/warning count in the Step 11 completion message so the user can see the graph's coherence state. They can be resolved by adding `depended_by:` to parent documents (see `coherence-rules.md`).

### STRONGLY RECOMMENDED (Brownfield) — Structured Wave-based Design Doc Restoration

> **When to run**: After `codd extract --ai` has generated 3 or more files in `.codd/extracted/`. This leverages CoDD's core Wave structure to restore full design document hierarchy.

> ⚠️ **Pre-requisite for `codd plan --init`**: This command requires `type: requirements` documents to exist in the project. These are only generated during the **Requirements Analysis** phase. If run now (at Reverse Engineering stage), it will exit with an error ("no requirements documents found"). **Re-run after completing Requirements Analysis**, or skip now and run it then.

```bash
# Auto-generate wave_config from requirements documents
codd plan --init

# Restore Wave 1 (Requirements) docs via AI
codd restore --wave 1

# Restore Wave 2 (System Design) docs via AI
codd restore --wave 2

# Restore Wave 3 (Detail/API Design) docs via AI
codd restore --wave 3
# (Continue for additional waves as needed)
```

> **Why this matters**: Without Wave restoration, the dependency graph has no structured requirement→design→code chain, making `codd impact` analysis incomplete. This is the mechanism that enables full CoDD traceability.

## [Graphify] Step 9.6: Update Knowledge Graph

**MANDATORY**: After all reverse engineering documents are generated, update the Graphify knowledge graph to include the new design documents and re-run community detection.

```bash
# Update graph with newly generated design documents and extracted code
# (AST-only update if run via git hook — use --mode deep if docs were also added)
graphify <project-root-path> --update
# → Adds new design docs from aidlc-docs/inception/reverse-engineering/ to the graph
# → CoDD frontmatter depends_on entries become EXTRACTED edges in the graph
# → Re-runs Leiden community detection with updated node set
```

**After update, read GRAPH_REPORT.md and query for architectural insights:**

```bash
# Communities and god nodes are auto-reported in GRAPH_REPORT.md
# Read graphify-out/GRAPH_REPORT.md for:
# → Community list (Leiden communities with member files — each is a candidate unit of work)
# → God nodes (highest-connectivity architectural hubs — widest blast radius on change)

# Use /graphify query for specific architectural questions:
/graphify query "What are the key architectural clusters and their boundaries?"
```

**Record findings in reverse-engineering artifacts** (add to `architecture.md`):
```markdown
## Graphify Knowledge Graph Insights
- **Communities**: [N communities from Leiden detection]
  - Community 0: [label] — [top nodes]
  - Community 1: [label] — [top nodes]
  - ...
- **God Nodes (Architectural Hubs)**: [list top 3-5 nodes]
- **Preliminary Unit Candidates**: [communities that look like natural unit boundaries]
```

> **AI-DLC × CoDD note**: These community labels and god node data feed directly into Units Generation. Record them here so the Units Generation phase can reference them without re-running the graph.

---

## Step 10: Update State Tracking

Update `aidlc-docs/aidlc-state.md`:

```markdown
## Reverse Engineering Status
- [x] Reverse Engineering - Completed on [timestamp]
- **Artifacts Location**: aidlc-docs/inception/reverse-engineering/
```

## Step 11: Present Completion Message to User

```markdown
# 🔍 Reverse Engineering Complete

[AI-generated summary of key findings from analysis in the form of bullet points]

> **[CoDD]** `codd validate` result: **[X] error(s), [X] warning(s)**  
> *Errors must be resolved before proceeding. Warnings (e.g., `depended_by` references) are non-blocking — see `coherence-rules.md`.*

> **[Graphify]** Knowledge graph updated: **[N] nodes, [M] communities, [K] god nodes**  
> *Communities: [brief list of community labels — these are candidate units of work]*  
> *God Nodes: [top architectural hubs — highest blast radius on change]*

> **📋 <u>**REVIEW REQUIRED:**</u>**  
> Please examine the reverse engineering artifacts at: `aidlc-docs/inception/reverse-engineering/`

> **🚀 <u>**WHAT'S NEXT?**</u>**
>
> **You may:**
>
> 🔧 **Request Changes** - Ask for modifications to the reverse engineering analysis if required
> ✅ **Approve & Continue** - Approve analysis and proceed to **Requirements Analysis**
```

## Step 12: Wait for User Approval

- **MANDATORY**: Do not proceed until user explicitly approves
- **MANDATORY**: Log user's response in audit.md with complete raw input
