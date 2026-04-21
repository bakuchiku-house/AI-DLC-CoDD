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

## Next Steps

- **[QUICKSTART.md](QUICKSTART.md)** — Start your first AI-DLC × CoDD project in 5 minutes
- **[AI-DLC-CoDD-GUIDE.md](AI-DLC-CoDD-GUIDE.md)** — Architecture, phase-by-phase operations, and extensibility reference
