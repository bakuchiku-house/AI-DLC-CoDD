---
codd:
  node_id: "docs:guide"
  type: design
  depends_on:
    - {id: "docs:quickstart", relation: "depends_on"}
---

# AI-DLC × CoDD — Architect's Guide

Reference for architects and lead engineers. Covers the full file catalog,
invocation relationships, per-scenario flow diagrams, and CoDD command sequences.

---

## Table of Contents

1. [System Overview](#1-system-overview)
2. [.aidlc-rule-details/ File Catalog](#2-aidlc-rule-details-file-catalog)
3. [CLAUDE.md Orchestration Logic](#3-claudemd-orchestration-logic)
4. [Scenario Flow Diagrams](#4-scenario-flow-diagrams)
5. [CoDD + Graphify Command Integration per Phase](#5-codd--graphify-command-integration-per-phase)
6. [Architecture and Component Map](#6-architecture-and-component-map)
7. [Impact Band Decision Flow](#7-impact-band-decision-flow)
8. [Extensibility and Customization](#8-extensibility-and-customization)
9. [Graphify Knowledge Graph Reference](#9-graphify-knowledge-graph-reference)

---

## 1. System Overview

AI-DLC × CoDD is a 3-layer system:

```
Layer 1: AI-DLC Workflow Engine
  CLAUDE.md             ← Orchestrator: reads user request, loads rule files, controls stage flow
  .aidlc-rule-details/  ← Rule files: detailed instructions for each stage
  aidlc-docs/           ← Artifacts: audit log, state, design docs

Layer 2: CoDD Document Engine
  codd CLI              ← Design doc generation, wave hierarchy, frontmatter, propagation
  .claude/hooks/        ← Automation: auto-scan after edits, auto-validate on commit
  .claude/commands/     ← Slash commands: /codd-init through /codd-assemble
  .codd/                ← Internal doc index: scan/, codd.yaml (plumbing, not user-facing)

Layer 3: Graphify Knowledge Graph
  graphify CLI          ← Single canonical graph: graphify-out/graph.json
                           AST + semantic edges (EXTRACTED / INFERRED / AMBIGUOUS)
                           Leiden community detection → candidate units of work
                           God nodes → high-connectivity architectural hubs
  PreToolUse hook       ← Claude reads GRAPH_REPORT.md before Glob/Grep searches
  git post-commit hook  ← Automatic AST updates after every commit
```

**Key principle**: Graphify is the sole user-visible graph. CoDD's `.codd/scan/` is internal plumbing for `codd impact`/`codd propagate` only. The canonical graph is always `graphify-out/graph.json`.

**CoDD ↔ Graphify bridge**: CoDD frontmatter `depends_on` entries become EXTRACTED edges when Graphify reads design docs — no special integration code required.

---

## 2. .aidlc-rule-details/ File Catalog

### 2.1 Common Files (Always Loaded at Workflow Start)

| File | Role | Key Instructions to AI |
|------|------|------------------------|
| `common/process-overview.md` | Workflow overview | Adaptive execution principle; which stages to run conditionally |
| `common/session-continuity.md` | Session resumption | Read `aidlc-docs/aidlc-state.md` to detect prior session; resume from last incomplete stage |
| `common/content-validation.md` | Content quality | Validate Mermaid/ASCII diagrams before writing; escape special chars |
| `common/question-format-guide.md` | Q&A format | Multiple-choice format (A/B/C/D); embed `[Answer]:` tags; resolve ambiguities |
| `common/welcome-message.md` | Welcome display | Display ONCE per new workflow; AI-DLC × CoDD phase diagram + CoDD integration summary |

### 2.2 Inception Phase Files (Loaded per Stage)

| File | Stage | Condition | Key Instructions to AI |
|------|-------|-----------|------------------------|
| `inception/workspace-detection.md` | Workspace Detection | **ALWAYS** | Scan for existing code; check `aidlc-state.md`; run `codd init` (Greenfield) or `codd extract --ai` (Brownfield); log to `audit.md` |
| `inception/reverse-engineering.md` | Reverse Engineering | Brownfield only | Run `codd extract --ai` → generates 6-layer MECE docs in `.codd/extracted/`; then generate architecture/component/API docs; HITL gate required |
| `inception/requirements-analysis.md` | Requirements Analysis | **ALWAYS** | Role: product owner; adaptive depth (minimal/standard/comprehensive); load RE artifacts if brownfield; run `codd generate --wave 1` for req docs |
| `inception/workflow-planning.md` | Workflow Planning | **ALWAYS** | Load all prior context; detect transformation scope; create stage execution plan; CoDD Completion Gate (`codd scan` + `codd validate`); HITL gate |
| `inception/user-stories.md` | User Stories | User-facing features | Two-part (plan → generate); reference requirements; HITL gate |
| `inception/application-design.md` | Application Design | New components needed | Component/service design; HITL gate |
| `inception/units-generation.md` | Units Generation | Multi-component system | Break into parallel units; HITL gate |

### 2.3 Construction Phase Files (Loaded per Unit)

| File | Stage | Condition | Key Instructions to AI |
|------|-------|-----------|------------------------|
| `construction/functional-design.md` | Functional Design | New business logic | Generate business-logic-model.md / business-rules.md / domain-entities.md; HITL gate |
| `construction/nfr-requirements.md` | NFR Requirements | Performance/security needs | Assess non-functional requirements; HITL gate |
| `construction/nfr-design.md` | NFR Design | NFR requirements exist | Design NFR patterns; HITL gate |
| `construction/infrastructure-design.md` | Infrastructure Design | Infrastructure changes | Map cloud resources; HITL gate |
| `construction/code-generation.md` | Code Generation | **ALWAYS per unit** | Two-part (plan → generate); Three-Way Coherence Closure (`codd extract` → `codd validate` primary → `/graphify --update` derived → query); `codd propagate` after code changes; HITL gate |
| `construction/build-and-test.md` | Build and Test | **ALWAYS** (final) | Generate build/test instructions; `/graphify --update` + `graphify query` final report + `codd measure` score; HITL gate |

### 2.4 Extension Files (Cross-Cutting Constraints)

| File | Enabled | Activation Condition | Enforces |
|------|---------|---------------------|----------|
| `extensions/codd-coherence/coherence-rules.md` | When `codd/codd.yaml` exists | `codd/codd.yaml` or `.codd/codd.yaml` present | CoDD frontmatter on all `doc_dirs` `.md` files; validate before HITL; Impact Band report |
| `extensions/security/baseline/security-baseline.md` | Yes (always) | All stages | OWASP Top 10; no hardcoded secrets; input validation at boundaries |

---

## 3. CLAUDE.md Orchestration Logic

### 3.1 How CLAUDE.md Loads Rule Files

```
User sends request to Claude Code
        │
        ▼
CLAUDE.md reads request
        │
        ├── Load MANDATORY common files:
        │     common/process-overview.md
        │     common/session-continuity.md
        │     common/content-validation.md
        │     common/question-format-guide.md
        │
        ├── Scan extensions/ for all .md files
        │     → Check enabled status in aidlc-state.md
        │     → Load enabled extensions as hard constraints
        │
        ├── Check aidlc-state.md
        │     → Exists? Resume from last incomplete stage
        │     → Not exists? Start new workflow
        │
        └── Display welcome-message.md (first time only)
                │
                ▼
        Begin Inception Phase
```

### 3.2 Stage Loading Sequence

```
For each stage that executes:

CLAUDE.md detects stage is needed
        │
        ▼
Load stage rule file (e.g., inception/workspace-detection.md)
        │
        ▼
Execute stage steps from rule file
        │
        ▼
Generate stage artifacts → aidlc-docs/
        │
        ▼
Run Completion Gate (if defined in rule file)
        │       → CoDD: codd validate (primary) + Graphify: /graphify --update (derived)
        │
        ▼
Log to audit.md (MANDATORY: capture raw user input)
        │
        ▼
Display HITL gate message
        │
        ▼
Wait for user approval
        │
        ▼
Update aidlc-state.md
        │
        ▼
Load next stage rule file
```

---

## 4. Scenario Flow Diagrams

### Scenario A: Greenfield New Development

**Trigger**: Empty workspace, new project idea

```
User: "AI-DLC CoDD USING. Please follow CLAUDE.md."
         │
         ▼
[CLAUDE.md] Load common files + extensions
         │
         ▼
[workspace-detection.md]
  Check aidlc-state.md → not found (new project)
  Scan workspace → no existing code detected
  → Greenfield path
  codd init --project-name "<name>" --language <lang> --dest .
  → Creates: codd/codd.yaml
  CoDD Coherence Extension activates
  [Graphify] graphify claude install  → PreToolUse hook + CLAUDE.md section
  [Graphify] graphify hook install    → git post-commit hook (AST auto-update)
         │
         ▼
[requirements-analysis.md]
  Role: product owner
  Adaptive depth assessment → Comprehensive (new project)
  Gather requirements via questions
  codd generate --wave 1 --path .
  → Creates: docs/requirements/requirements.md (with CoDD frontmatter)
  codd scan --path . → updates internal index
  HITL gate
         │
         ▼
[workflow-planning.md]
  Load: requirements.md
  Assess: which stages to run
  Create: execution plan with stage list
  [CoDD] Completion Gate:
    codd validate --path .                            (primary: CoDD internal coherence)
    /graphify --update → sync graph + generate GRAPH_REPORT.md  (derived sync)
  HITL gate
         │
         ▼
[units-generation.md] (if multi-component)
  Break project into units
  Read graphify-out/GRAPH_REPORT.md → communities guide unit decomposition
  HITL gate
         │
         ▼
For each unit:
  ┌──────────────────────────────────────────────────┐
  │ [functional-design.md]                           │
  │   Generate: business-logic-model.md              │
  │             business-rules.md                    │
  │             domain-entities.md                   │
  │   Add CoDD frontmatter to each                   │
  │   HITL gate                                      │
  │              │                                   │
  │              ▼                                   │
  │ [code-generation.md]                             │
  │   Part 1: Plan (with checkboxes)                 │
  │   HITL gate                                      │
  │   Part 2: Generate code                          │
  │   [Three-Way Coherence Closure]:                 │
  │     codd extract       (Step 1: extract code→CoDD) │
  │     codd validate      (Step 2: primary gate)    │
  │     /graphify --update (Step 3: derived sync)    │
  │     /graphify query "coverage, risks"            │
  │     codd propagate --path . (if design changed)  │
  │   HITL gate                                      │
  └──────────────────────────────────────────────────┘
         │
         ▼
[build-and-test.md]
  Generate: build/test instructions
  [Three-Way Coherence Closure — Final]:
    codd extract + codd validate  → CoDD coherence (primary)
    /graphify --update            → derived graph sync
    /graphify query "coverage %, community count, risks"
    codd measure   → CoDD coherence score
  HITL gate
```

---

### Scenario B: Brownfield Reverse Engineering

**Trigger**: Existing codebase, no design documentation

```
User: "AI-DLC CoDD USING. Please follow CLAUDE.md.
       I need to document and add a new feature to this project."
         │
         ▼
[CLAUDE.md] Load common files + extensions
         │
         ▼
[workspace-detection.md]
  Check aidlc-state.md → not found
  Scan workspace → existing code detected → Brownfield path
  codd extract --ai
    Phase 1: Python static analysis of codebase
    Phase 2: AI generates 6-layer MECE design docs
      → .codd/extracted/: architecture, components, APIs, etc.
      → All with CoDD frontmatter
  Record in aidlc-state.md: Brownfield = true
  [Graphify] graphify <path> --mode deep → builds graphify-out/graph.json
    → Leiden communities (candidate units) + god nodes (architectural hubs)
  [Graphify] graphify hook install + graphify claude install
         │
         ▼
[reverse-engineering.md]
  codd extract --ai (if not run in workspace-detection)
  codd plan --init
    → Generates wave_config from extracted docs
  Generate artifacts:
    aidlc-docs/inception/reverse-engineering/
      architecture.md / component-inventory.md /
      technology-stack.md / dependencies.md / etc.
  All artifacts get CoDD frontmatter
  [Graphify] Read graphify-out/GRAPH_REPORT.md → Leiden communities (unit candidates) + god nodes (high-risk hubs)
  HITL gate (user reviews reverse-engineered docs + GRAPH_REPORT.md community report)
         │
         ▼
[requirements-analysis.md]
  Load: architecture.md, component-inventory.md, technology-stack.md
  Analyze new feature request in context of existing system
  codd restore --wave 0 --path .   → infer requirements from code
  codd generate --wave 1 --path .  → generate new requirement docs
  HITL gate
         │
         ▼
[workflow-planning.md]
  Scope: what files need to change (brownfield = modify in-place)
  [CoDD] Completion Gate:
    codd validate --path .  (primary: CoDD internal coherence)
    /graphify --update      (derived sync)
  HITL gate
         │
         ▼
[code-generation.md]
  Brownfield rule: modify existing files, no duplicates
  After source code changes:
    codd propagate --path .          → check affected design docs
    codd propagate --path . --update → AI updates affected docs
  [Three-Way Coherence Closure]:
    codd extract                (Step 1: extract code→CoDD)
    codd validate --path .      (Step 2: primary gate)
    /graphify --update          (Step 3: derived sync)
    /graphify query "coherence issues or missing links?"
  HITL gate
         │
         ▼
[build-and-test.md]
  codd extract + codd validate  → CoDD coherence (primary)
  /graphify --update
  /graphify query "coverage %, community count, key risks"
  codd measure → report coherence health
  HITL gate
```

---

### Scenario C: Feature Addition (Existing AI-DLC × CoDD Project)

**Trigger**: Session resume, project has `aidlc-state.md`

```
User: "AI-DLC CoDD USING. Please follow CLAUDE.md.
       Add a user authentication module."
         │
         ▼
[CLAUDE.md] Load common files + extensions
         │
         ▼
[workspace-detection.md]
  Check aidlc-state.md → FOUND
  Load prior context from aidlc-state.md
  CoDD: codd/codd.yaml already exists → Coherence Extension activates
  Skip Reverse Engineering (artifacts exist)
         │
         ▼
[requirements-analysis.md]
  Load prior reverse-engineering artifacts
  Analyze "add authentication module" request
  Depth: Standard (clear request, bounded scope)
  No codd generate needed (requirements clear from discussion)
  HITL gate
         │
         ▼
[workflow-planning.md]
  Scope: 1-2 new units (auth module)
  [CoDD] Completion Gate:
    codd validate --path .  (primary: CoDD internal coherence)
    /graphify --update      (derived sync)
  HITL gate
         │
         ▼
[units-generation.md]
  Define Unit: auth-service
  HITL gate
         │
         ▼
[functional-design.md] for auth-service unit
  Design: auth entities, rules, flows
  HITL gate
         │
         ▼
[code-generation.md] for auth-service unit
  Generate auth code
  codd propagate → update design docs impacted by new code
  [Three-Way Coherence Closure]:
    codd extract                (Step 1: extract code→CoDD)
    codd validate --path .      (Step 2: primary gate)
    /graphify --update          (Step 3: derived sync)
  HITL gate
         │
         ▼
[build-and-test.md]
  codd impact --path .   → check blast radius of auth changes
  /graphify query "impact of auth changes on existing communities"
  codd measure
  HITL gate
```

---

### Scenario D: Simple Bug Fix

**Trigger**: Isolated bug, no design changes expected

```
User: "Fix the null pointer exception in user service."
         │
         ▼
[CLAUDE.md] Load common files + extensions
         │
         ▼
[workspace-detection.md]
  aidlc-state.md → resume
  CoDD: codd/codd.yaml exists
         │
         ▼
[requirements-analysis.md]
  Depth: MINIMAL (clear, isolated bug fix)
  No questions needed, no CoDD generate
  HITL gate (lightweight)
         │
         ▼
[workflow-planning.md]
  Skip: User Stories, Application Design, Units Generation
  Skip: Functional Design, NFR stages, Infrastructure Design
  Execute: Code Generation only
  [CoDD] Completion Gate:
    codd validate --path .  (primary: CoDD internal coherence)
    /graphify --update      (derived sync)
  HITL gate
         │
         ▼
[code-generation.md]
  Modify existing file in-place (no new files)
  codd propagate --path .   → check if bug fix affects design docs
    → Likely no affected docs for pure bug fix
  [Three-Way Coherence Closure]:
    codd extract                (Step 1: extract code→CoDD)
    codd validate --path .      (Step 2: primary gate)
    /graphify --update          (Step 3: derived sync — fast, AST-only for isolated bug fix)
  HITL gate
         │
         ▼
[build-and-test.md]
  codd measure (quick check)
  HITL gate
```

---

## 5. CoDD + Graphify Command Integration per Phase

### 5.1 Command Sequences per Phase

| Phase / Stage | Rule File | Commands | Purpose |
|--------------|-----------|----------|---------|
| Workspace Detection | `workspace-detection.md` | `codd init` (Greenfield) | Bootstrap CoDD |
| Workspace Detection | `workspace-detection.md` | `codd extract --ai` (Brownfield) | AI-powered code extraction |
| Workspace Detection | `workspace-detection.md` | `graphify <path> --mode deep` | Build initial knowledge graph |
| Workspace Detection | `workspace-detection.md` | `graphify claude install`, `graphify hook install` | Register hooks |
| Reverse Engineering | `reverse-engineering.md` | `codd extract --ai`, `codd plan --init` | Generate wave_config |
| Reverse Engineering | `reverse-engineering.md` | `codd restore --wave 0`, `--wave 2` | Reconstruct design from code |
| Reverse Engineering | `reverse-engineering.md` | Read `graphify-out/GRAPH_REPORT.md` | Community + god node info for unit decomposition |
| Requirements Analysis | `requirements-analysis.md` | `codd generate --wave 1` | Generate req docs from requirements |
| Workflow Planning | `workflow-planning.md` | `codd validate` (primary) + `/graphify --update` (derived sync) | Completion Gate before HITL |
| Code Generation | `code-generation.md` | `codd extract` → `codd validate` → `/graphify --update` → query | Three-Way Coherence Closure before HITL |
| Code Generation | `code-generation.md` | `codd propagate [--update]` | Sync code changes to design docs |
| Build and Test | `build-and-test.md` | `/graphify --update` + `/graphify query "..."` | Final knowledge graph report |
| Build and Test | `build-and-test.md` | `codd measure` | CoDD coherence score |
| **All phases (auto)** | PostToolUse hook | `codd scan --path .` | Auto-refresh CoDD index after file edits |
| **All phases (auto)** | git post-commit hook | `graphify --update` (AST only) | Auto-refresh knowledge graph after commit |
| **All phases (auto)** | Pre-commit hook | `codd validate --path .` | Gate before every git commit |

### 5.2 Slash Command → Rule File Mapping (CoDD)

| Slash Command | Underlying CLI | When AI Uses It | Rule File That Triggers It |
|--------------|----------------|-----------------|---------------------------|
| `/codd-init` | `codd init` | New project bootstrap | `workspace-detection.md` |
| `/codd-scan` | `codd scan` | Manual CoDD index refresh | Any stage, user-triggered |
| `/codd-validate` | `codd validate` | Check frontmatter + CoDD internal coherence | Completion Gates (primary gate) |
| `/codd-impact` | `codd impact` | Blast radius analysis | `workflow-planning.md`, `build-and-test.md` |
| `/codd-propagate` | `codd propagate` | Code→design sync | `code-generation.md` |
| `/codd-restore` | `codd restore` | Reconstruct design | `reverse-engineering.md` |
| `/codd-generate` | `codd generate` | Generate from reqs | `requirements-analysis.md` |
| `/codd-assemble` | `codd assemble` | Final assembly | Advanced greenfield only |

### 5.3 Slash Command → Rule File Mapping (Graphify)

| Slash Command | Underlying CLI | When AI Uses It | Rule File That Triggers It |
|--------------|----------------|-----------------|---------------------------|
| `/graphify --update` | `graphify --update` | Sync derived graph + GRAPH_REPORT.md | Completion Gates (derived sync, after codd validate) |
| `/graphify query "<q>"` | `graphify query` | CoDD/code↔Graphify coherence check | Completion Gates (three-way verification), Build & Test |
| (read GRAPH_REPORT.md) | — | Communities + god nodes auto-reported | After any `/graphify --update` run |

---

## 6. Architecture and Component Map

### 6.1 Component Roles

| Unit | Files | Layer | Role | Input | Output |
|------|-------|-------|------|-------|--------|
| **1 — Workflow** | `CLAUDE.md` | Layer 1 | Orchestrator | User request | Staged execution |
| **2 — Rules** | `.aidlc-rule-details/` | Layer 1 | Instructions | Stage trigger | Stage artifacts |
| **3 — Automation** | `.claude/` | Layer 2+3 | CoDD + Graphify hooks | File/commit events | Index + graph updates |
| **4 — Docs** | `README`, `QUICKSTART`, `GUIDE` | — | Onboarding | — | Human understanding |

### 6.2 Full System Interaction Map

```
┌──────────────────────────────────────────────────────────────────────┐
│  Claude Code (AI + User Interface)                                   │
│                                                                      │
│  CLAUDE.md ──loads──► .aidlc-rule-details/                           │
│      │                    common/ (always)                            │
│      │                    inception/ (per-stage)                      │
│      │                    construction/ (per-unit)                    │
│      │                    extensions/ (always, conditional)           │
│      │                                                               │
│      ▼                                                               │
│  Stage Execution ──writes──► aidlc-docs/                             │
│      │                         audit.md (all events)                  │
│      │                         aidlc-state.md (progress)              │
│      │                         inception/ (req, RE docs)              │
│      │                         construction/ (design, code docs)      │
│      │                                                               │
│  .claude/settings.json                                               │
│      ├── SessionStart ──────► install-codd-pre-commit.sh             │
│      ├── PostToolUse ────────► codd scan --path .  [Layer 2]         │
│      └── PreToolUse ─────────► reads GRAPH_REPORT.md  [Layer 3]      │
│                                                                      │
│  .claude/commands/codd-xxx.md ──activates──► /codd-xxx  [Layer 2]   │
│  .claude/commands/graphify.md ──activates──► /graphify  [Layer 3]   │
│                                                                      │
│  git hooks (installed by graphify hook install):                     │
│      └── post-commit ────────► graphify --update (AST)  [Layer 3]   │
└──────────────────────────────────────────────────────────────────────┘
         │                    │                       │
         ▼                    ▼                       ▼
  Application Code      CoDD Index            Graphify Graph
  (workspace root)      .codd/scan/           graphify-out/
                          nodes.jsonl           graph.json
                          edges.jsonl           (canonical, user-facing)
                        [Layer 2 internal]    [Layer 3 — sole user graph]
```

---

## 7. Impact Band Decision Flow

`codd impact --path .` classifies each affected artifact after any change:

```
codd impact --path .
        │
        ▼
For each affected artifact:
        │
        ├── confidence ≥ 0.90 AND evidence ≥ 2?
        │       └── YES → GREEN BAND
        │                   AI updates doc autonomously
        │                   Human reviews after
        │
        ├── confidence ≥ 0.50?
        │       └── YES → AMBER BAND
        │                   AI proposes update
        │                   Human approves BEFORE AI edits
        │
        └── Below Amber threshold
                └── GRAY BAND
                        AI reports only
                        No edits made
```

Thresholds configured in `codd.yaml`:
```yaml
bands:
  green:
    min_confidence: 0.90
    min_evidence_count: 2
  amber:
    min_confidence: 0.50
```

---

## 8. Extensibility and Customization

### 8.1 Adding a New AI-DLC Extension (Low Effort)

```
1. Create: .aidlc-rule-details/extensions/<your-ext>/<your-ext>.md
2. Add extension header with: Applicability, Verification Criteria, Enforcement
3. Register in aidlc-state.md:
   | <Your Extension> | Yes | Requirements Analysis |
4. CLAUDE.md automatically scans extensions/ and loads it
```

### 8.2 Adding a New Slash Command (Low-Medium Effort)

```
1. Create: codd-yourskill/SKILL.md with full instructions
2. Add CoDD frontmatter:
   node_id: "skill:codd-yourskill"
3. Copy to: .claude/commands/codd-yourskill.md
4. /codd-yourskill is now available in Claude Code
```

### 8.3 Adding a New Phase Rule File (Medium Effort)

```
1. Create: .aidlc-rule-details/construction/your-stage.md
2. Follow structure: Purpose / Prerequisites / Steps / Completion Message
3. Add HITL gate in Steps
4. Reference from CLAUDE.md with conditional execution criteria
```

### 8.4 codd.yaml Key Customization Points

| Field | Effect | When to Change |
|-------|--------|----------------|
| `project.language` | Controls source file patterns | When using non-default language |
| `scan.doc_dirs` | Which dirs CoDD tracks | When docs are not in `aidlc-docs/` |
| `scan.source_dirs` | Source code for module mapping | Required: set to your actual source dir |
| `bands.green.min_confidence` | Auto-update sensitivity | Lower = more autonomous (use with caution) |
| `bands.amber.min_confidence` | Review threshold | Lower = more items need human review |
| `propagation.max_depth` | How deep impact cascades | Lower = faster analysis, fewer transitive impacts |

---

## 9. Graphify Knowledge Graph Reference

### 9.1 Graph Anatomy

`graphify-out/graph.json` contains:

| Element | Description |
|---------|-------------|
| **Nodes** | Source files, design docs, modules, functions, classes |
| **EXTRACTED edges** | Deterministically derived: AST imports, CoDD frontmatter `depends_on` |
| **INFERRED edges** | LLM-semantic extraction: conceptual relationships between components |
| **AMBIGUOUS edges** | Low-certainty relationships flagged for human review |
| **Communities** | Leiden algorithm clusters — natural module boundaries → candidate units of work |
| **God nodes** | High in-degree/out-degree nodes — architectural hubs with widest blast radius |

### 9.2 Edge Confidence Labels

| Label | Confidence | Source | Review |
|-------|-----------|--------|--------|
| EXTRACTED | 0.9–1.0 | AST / CoDD frontmatter `depends_on` | Trust directly |
| INFERRED | 0.7–0.9 | LLM semantic analysis | Usually reliable, spot-check |
| AMBIGUOUS | 0.4–0.6 | LLM low-confidence | Human review recommended |

These labels align with CoDD `confidence:` field values in frontmatter.

### 9.3 Key Graphify Commands

| Command | When to Use |
|---------|-------------|
| `graphify <path> --mode deep` | Initial graph build (AST + LLM; run once per project) |
| `graphify <path> --update` | Refresh after code/doc changes (AST + LLM) |
| `graphify claude install` | Register PreToolUse hook (Claude reads GRAPH_REPORT.md before searches) |
| `graphify hook install` | Register git post-commit hook (fast AST-only update, no LLM cost) |
| `/graphify --update` | Slash command: sync graph + produce GRAPH_REPORT.md for current session |
| `/graphify query "<q>"` | Natural language query: coherence check, blast radius, community analysis |
| (read `graphify-out/GRAPH_REPORT.md`) | Communities + god nodes auto-reported in GRAPH_REPORT.md after every update |

**Note**: `/graphify community list` and `/graphify god-nodes` are NOT valid commands. Communities and god nodes appear automatically in `graphify-out/GRAPH_REPORT.md` when running `/graphify --update` or `/graphify <path>`.

### 9.4 Graphify in the AI-DLC Loop

```
Workspace Detection
  └── graphify --mode deep         ← initial graph (Brownfield) or prepare hooks (Greenfield)

Reverse Engineering
  └── Read graphify-out/GRAPH_REPORT.md  ← communities (unit candidates) + god nodes (high-risk hubs)

Units Generation (Brownfield)
  └── Read graphify-out/GRAPH_REPORT.md  ← community-guided unit decomposition (Step 0.5)

Workflow Planning (CoDD primary gate)
  └── codd validate                ← primary: CoDD internal coherence check
  └── /graphify --update           ← derived sync

Code Generation (per unit) — Three-Way Coherence Closure
  └── codd extract                 ← Step 1: extract code→CoDD (CoDD = primary authority)
  └── codd validate                ← Step 2: CoDD internal coherence (primary gate)
  └── /graphify --update           ← Step 3: sync derived graph index
  └── /graphify query "..."        ← Step 4: CoDD/code↔Graphify verification

Build and Test
  └── codd extract + codd validate ← final CoDD coherence
  └── /graphify --update           ← final graph sync
  └── /graphify query "coverage %, communities, risks"
  └── codd measure                 ← CoDD coherence score
```

### 9.5 CoDD ↔ Graphify Data Flow

```
Design document (Markdown)
  ├── CoDD frontmatter:
  │     depends_on:
  │       - {id: "req:my-app", relation: "depends_on"}
  │     source_files:
  │       - "src/app/router.py"
  │
  └── When Graphify scans this document:
        ├── depends_on entries → EXTRACTED edges in graph.json
        └── source_files entries → extracted_from edges (doc → code)

No special integration code required — the document file itself is the bridge.
```
