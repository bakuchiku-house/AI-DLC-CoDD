---
codd:
  node_id: "doc:readme-en"
  type: design
  depends_on: []
---

# AI-DLC × CoDD

AI-Driven Development Life Cycle with Coherence-Driven Development integration.
Bring structured AI workflows and automatic design coherence to any project.

---

## Overview

AI-DLC × CoDD is a 3-layer system:

- **AI-DLC** (Layer 1) — Workflow orchestration: phases, approval gates, audit trail
- **CoDD** (Layer 2) — Document engine: design doc generation, wave hierarchy, CoDD frontmatter, propagation
- **Graphify** (Layer 3) — Knowledge graph: single `graphify-out/graph.json`, AST+semantic edges, Leiden community detection

Together they ensure that AI-generated code stays aligned with design intent throughout the development lifecycle. Graphify is the sole user-visible graph — CoDD's internal scan index is plumbing for `codd impact`/`codd propagate`.

---

## Prerequisites

```bash
# Install CoDD CLI (document engine)
pip install codd-dev

# Install Graphify CLI (knowledge graph)
pip install graphifyy

# Verify installations
codd --version
graphify --version
claude --version   # Claude Code CLI
git --version      # Required for pre-commit hook
```

---

## Quick Setup

Copy the AI-DLC × CoDD files to your project root:

```bash
# From the  directory:
cp CLAUDE.md /path/to/your-project/
cp -r .claude/ /path/to/your-project/
cp -r .codd/ /path/to/your-project/

# Initialize CoDD config from template
cp .codd/codd.yaml.template /path/to/your-project/codd/codd.yaml
# Edit codd/codd.yaml — update project.name and scan.source_dirs

# First-time Graphify setup (run in your project root)
graphify claude install   # Registers PreToolUse hook + CLAUDE.md section
graphify hook install     # Registers git post-commit hook for AST updates
```

Then open Claude Code in your project and invoke:

```
AI-DLC CoDD USING. Please follow CLAUDE.md.
```

---

## Directory Structure

```
├── CLAUDE.md                          # AI-DLC × CoDD main workflow (copy to project root)
├── .claude/
│   ├── settings.json                  # Hooks + permissions (CoDD + Graphify)
│   ├── commands/                      # Slash commands
│   │   ├── codd-init.md
│   │   ├── codd-scan.md
│   │   ├── codd-validate.md
│   │   ├── codd-impact.md
│   │   ├── codd-propagate.md
│   │   ├── codd-restore.md
│   │   ├── codd-generate.md
│   │   ├── codd-assemble.md
│   │   └── graphify.md                # /graphify slash command (knowledge graph)
│   └── hooks/
│       └── install-codd-pre-commit.sh # Auto-installs CoDD pre-commit hook
├── .aidlc-rule-details/               # AI-DLC phase rule files (CoDD+Graphify integrated)
│   ├── common/
│   ├── inception/
│   ├── construction/
│   └── extensions/codd-coherence/
├── .codd/
│   └── codd.yaml.template             # CoDD config template for new projects
├── README.md                          # This file
├── QUICKSTART.md                      # 5-minute setup guide
└── AI-DLC-CoDD-GUIDE.md               # Architect's reference guide
```

---

## What's Inside

| Unit | Files | Purpose |
|------|-------|---------|
| **Unit 1** | `CLAUDE.md` | Main AI-DLC × CoDD workflow — copy to project root |
| **Unit 2** | `.aidlc-rule-details/` | Phase-by-phase rule files with CoDD + Graphify operations integrated |
| **Unit 3** | `.claude/` | Claude Code settings, hooks, and slash commands (CoDD + Graphify) |
| **Unit 4** | `README.md`, `QUICKSTART.md`, `AI-DLC-CoDD-GUIDE.md` | Documentation |

---

## Working with Graphs — How to View and Use Them

AI-DLC × CoDD generates two types of graphs. Understanding each one's role and how to use it dramatically improves development efficiency.

### What Gets Generated

```
your-project/
├── graphify-out/              ← [Graphify] User-facing graph (Layer 3)
│   ├── graph.html             ← Interactive visualization (open in browser)
│   ├── GRAPH_REPORT.md        ← Plain-language audit report (Claude auto-reads this)
│   ├── graph.json             ← Canonical knowledge graph (persistent, queryable)
│   └── cost.json              ← Cumulative token cost log
│
└── .codd/scan/                ← [CoDD] Internal dependency graph (Layer 2, plumbing only)
    ├── nodes.jsonl
    └── edges.jsonl
```

> **Key distinction**: `graphify-out/` is the graph you view and interact with. `.codd/scan/` is internal plumbing for `codd impact`/`codd propagate` — do not modify it directly.

---

### How to Read Each File

#### `graph.html` — Interactive Graph (Visual Exploration)

**How to open**: Just open in any browser — no server required.

```bash
# Windows
start graphify-out/graph.html

# Mac / Linux
open graphify-out/graph.html
```

**What you see**:
- **Nodes (dots)**: Classes, functions, design docs, and other concepts in your codebase
- **Edges (lines)**: Relationships between nodes (depends on, calls, references, etc.)
- **Color-coded clusters**: Communities detected by the Leiden algorithm — each cluster is a candidate unit of work
- **Large nodes (god nodes)**: High-connectivity hubs — architectural centers with maximum change impact

**When to use**: Getting a visual overview of your architecture, identifying candidate units for AI-DLC, spotting high-risk nodes before changes.

#### `GRAPH_REPORT.md` — Audit Report (Claude Auto-Reads This)

**Claude Code reads this automatically** — the PreToolUse hook notifies Claude before every Glob/Grep search.

**How to open**: Any text editor or Markdown preview.

**Contents**:
- **God Nodes**: Top-connected nodes (highest change impact — touch these carefully)
- **Surprising Connections**: Unexpected links between components (refactoring candidates)
- **Community Structure**: Leiden-detected functional clusters with cohesion scores
- **Suggested Questions**: Auto-generated exploration queries from the graph structure

**When to use**: Before starting implementation (understand what you're touching), during architecture reviews, as evidence for design decisions.

#### `graph.json` — Canonical Knowledge Graph (Query Interface)

**Not meant to be read directly** — query it with `/graphify` commands.

```
# Ask questions in natural language
/graphify query "What does the authentication flow depend on?"
/graphify query "Which modules have the highest change risk?"

# Trace paths between concepts
/graphify path "UserService" "Database"

# Get a plain-language explanation of any node
/graphify explain "AuthModule"
```

---

### How the Graphs Stay in Sync Automatically

The graphs are kept current through multiple automatic mechanisms:

| Trigger | CoDD graph | Graphify graph | Mechanism |
|---------|-----------|----------------|-----------|
| File edit (Write/Edit) | ✅ Immediately | ✅ Async incremental | PostToolUse hook |
| `git commit` | — | ✅ AST-only (no LLM) | post-commit hook |
| Completion Gate | ✅ `codd extract` | ✅ `/graphify --update` | Three-way coherence closure |

> **When to update manually**: After large-scale changes, or for the initial build when `graphify-out/graph.json` does not yet exist, run `/graphify . --mode deep`.

---

### Graph Usage Flow in Daily Development

```
1. Before implementing → Read GRAPH_REPORT.md (understand impact + architecture)
        ↓
2. During development → Files auto-update on every edit (PostToolUse hook)
        ↓
3. Design review → /graphify query "coherence summary"
        ↓
4. git commit → AST auto-update (post-commit hook, no LLM cost)
        ↓
5. Completion Gate → Three-way coherence closure (CoDD primary, Graphify derived)
```

---

### Troubleshooting: Graph Is Stale or Missing

```bash
# Incremental update (re-extracts only changed files)
/graphify . --update

# Full rebuild (re-scans everything — use after large refactors)
/graphify . --mode deep

# Re-run clustering only (re-analyzes existing graph structure)
/graphify . --cluster-only
```

---

## Next Steps

- **[QUICKSTART.md](QUICKSTART.md)** — Start your first AI-DLC × CoDD project in 5 minutes
- **[AI-DLC-CoDD-GUIDE.md](AI-DLC-CoDD-GUIDE.md)** — Architecture, phase-by-phase operations, and extensibility reference
