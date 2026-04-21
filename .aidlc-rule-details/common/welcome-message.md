---
codd:
  node_id: "doc:welcome-message-en"
  type: document
  depends_on: []
---

# AI-DLC × CoDD Welcome Message

**Purpose**: This file contains the user-facing welcome message that should be displayed ONCE at the start of any AI-DLC × CoDD workflow.

---

# 👋 Welcome to AI-DLC × CoDD! 👋

I'll guide you through an adaptive software development workflow that combines AI-DLC's structured lifecycle with CoDD's real-time design coherence — intelligently tailored to your specific needs.

## What is AI-DLC × CoDD?

AI-DLC × CoDD integrates three layers into a single development process. Think of it as having an experienced software architect who:

- **Analyzes your requirements** and asks clarifying questions when needed
- **Plans the optimal approach** based on complexity and risk
- **Maintains a live knowledge graph** (via Graphify) for architectural insight, community-based unit decomposition, and change impact analysis
- **Ensures design coherence** (via CoDD) so every artifact stays aligned with requirements through a wave-based document hierarchy
- **Skips unnecessary steps** for simple changes while providing comprehensive coverage for complex projects
- **Documents everything** so you have a complete record of decisions and rationale
- **Guides you through each phase** with clear checkpoints and approval gates

## The Three-Phase Lifecycle

```
                         User Request
                              |
                              v
        ╔═══════════════════════════════════════╗
        ║     INCEPTION PHASE                   ║
        ║     Planning & Application Design     ║
        ╠═══════════════════════════════════════╣
        ║ • Workspace Detection (ALWAYS)        ║
        ║   [CoDD] init + [Graphify] graph build║
        ║ • Reverse Engineering (COND)          ║
        ║   [CoDD] extract + [Graphify] update  ║
        ║ • Requirements Analysis (ALWAYS)      ║
        ║   [CoDD] codd scan (after gen)        ║
        ║ • User Stories (CONDITIONAL)          ║
        ║ • Workflow Planning (ALWAYS)          ║
        ║   [CoDD] validate (primary)           ║
        ║   [Graphify] sync (derived)           ║
        ║ • Application Design (CONDITIONAL)    ║
        ║ • Units Generation (CONDITIONAL)      ║
        ╚═══════════════════════════════════════╝
                              |
                              v
        ╔═══════════════════════════════════════╗
        ║     CONSTRUCTION PHASE                ║
        ║     Design, Implementation & Test     ║
        ╠═══════════════════════════════════════╣
        ║ • Per-Unit Loop (for each unit):      ║
        ║   - Functional Design (COND)          ║
        ║     [CoDD] codd scan                  ║
        ║   - NFR Requirements Assess (COND)    ║
        ║   - NFR Design (COND)                 ║
        ║   - Infrastructure Design (COND)      ║
        ║   - Code Generation (ALWAYS)          ║
        ║     [Three-Way Closure]               ║
        ║ • Build and Test (ALWAYS)             ║
        ║   [Three-Way Closure] + measure       ║
        ╚═══════════════════════════════════════╝
                              |
                              v
        ╔═══════════════════════════════════════╗
        ║     OPERATIONS PHASE                  ║
        ║     Placeholder for Future            ║
        ╠═══════════════════════════════════════╣
        ║ • Operations (PLACEHOLDER)            ║
        ╚═══════════════════════════════════════╝
                              |
                              v
                          Complete
```

### Phase Breakdown:

**INCEPTION PHASE** - *Planning & Application Design*
- **Purpose**: Determines WHAT to build and WHY
- **Activities**: Understanding requirements, analyzing existing code (if any), planning the approach
- **Graphify**: Builds knowledge graph (`graphify --mode deep`), detects Leiden communities (→ unit candidates) and god nodes (→ architectural hubs)
- **CoDD**: Initializes design coherence (`codd init` / `codd extract`), scans after every document generation
- **Output**: Clear requirements, execution plan, knowledge graph with unit candidates and architectural insights
- **Your Role**: Answer questions, review plans, approve direction

**CONSTRUCTION PHASE** - *Detailed Design, Implementation & Test*
- **Purpose**: Determines HOW to build it
- **Activities**: Detailed design (when needed), code generation, comprehensive testing
- **CoDD**: Primary design authority — `codd extract` + `codd validate` is the primary completion gate; measures final coherence score
- **Graphify**: Derived index — syncs after CoDD validation (`/graphify --update`), queries for CoDD/code↔Graphify verification
- **Output**: Working code, tests, build instructions, final knowledge graph report + CoDD coherence score
- **Your Role**: Review designs, approve implementation plans, validate results

**OPERATIONS PHASE** - *Deployment & Monitoring (Future)*
- **Purpose**: How to DEPLOY and RUN it
- **Status**: Placeholder for future deployment and monitoring workflows
- **Current State**: Build and test activities handled in CONSTRUCTION phase

## Key Principles:

- ⚡ **Fully Adaptive**: Each stage independently evaluated based on your needs
- 🎯 **Efficient**: Simple changes execute only essential stages
- 📋 **Comprehensive**: Complex changes get full treatment with all safeguards
- 🔍 **Transparent**: You see and approve the execution plan before work begins
- 📝 **Documented**: Complete audit trail of all decisions and changes
- 🎛️ **User Control**: You can request stages be included or excluded
- 🗺️ **Graphify Knowledge Graph**: Single canonical `graphify-out/graph.json` — AST+semantic edges, Leiden communities (unit candidates), god nodes (architectural hubs)
- 🔗 **CoDD Coherence**: Every generated artifact gets frontmatter; wave-based document hierarchy ensures requirements, design, and code stay aligned throughout

## What Happens Next:

1. **I'll analyze your workspace** to understand if this is a new or existing project
2. **CoDD initializes** — design coherence engine is set up (`codd init` for new projects, `codd extract` for existing ones)
3. **Graphify initializes** — knowledge graph is built (`graphify --mode deep`); communities and god nodes reported in `GRAPH_REPORT.md`
4. **I'll gather requirements** and ask clarifying questions if needed
5. **I'll create an execution plan** showing which stages I propose to run and why
6. **You'll review and approve** the plan (or request changes)
7. **We'll execute the plan** with checkpoints at each major stage; CoDD validates coherence first (primary), Graphify syncs after (derived)
8. **You'll get working code** with complete documentation, tests, a final knowledge graph report, and CoDD coherence score

The AI-DLC process adapts to:
- 📋 Your intent clarity and complexity
- 🔍 Existing codebase state
- 🎯 Scope and impact of changes
- ⚡ Risk and quality requirements

Let's begin!
