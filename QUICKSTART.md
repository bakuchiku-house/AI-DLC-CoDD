---
codd:
  node_id: "doc:quickstart-en"
  type: design
  depends_on:
    - {id: "doc:readme-en", relation: "depends_on"}
---

# QUICKSTART — AI-DLC × CoDD

---

## How to Start AI-DLC × CoDD

### Step 1: Copy Files to Your Project

```bash
# Run from the AI-DLC_CoDD/en/ directory:
cp CLAUDE.md /path/to/your-project/
cp -r .claude/ /path/to/your-project/
cp -r .codd/ /path/to/your-project/
cp -r .aidlc-rule-details/ /path/to/your-project/
cp .codd/codd.yaml.template /path/to/your-project/.codd/codd.yaml
```

Edit `.codd/codd.yaml` — update at minimum:
- `project.name` — your project name
- `scan.source_dirs` — your source code directory

### Step 2: Invoke AI-DLC × CoDD in Claude Code

Open Claude Code in your project directory and type:

```
AI-DLC CoDD USING. Please follow CLAUDE.md.
```

Claude Code will display the AI-DLC × CoDD welcome message and automatically begin
**Workspace Detection** — the first stage of the AI-DLC workflow.

> **What happens automatically:**
> - SessionStart hook installs the CoDD pre-commit hook
> - Workspace Detection reads `CLAUDE.md` and detects Greenfield or Brownfield
> - CoDD Coherence Extension activates when `.codd/codd.yaml` (or `codd/codd.yaml`) is detected

---

## Prerequisites Check

```bash
codd --version      # e.g., codd-dev 0.2.0a1
graphify --version  # e.g., graphifyy 0.1.0
claude --version    # Claude Code CLI
git --version       # Required for pre-commit hook
```

---

## Option A: Greenfield (New Project, No Existing Code)

### Step 1: Initialize CoDD and Graphify

```bash
# Initialize CoDD (document engine)
codd init --project-name "my-project" --language python --dest .
# Creates: codd/codd.yaml, codd/scan/, codd/reports/

# Set up Graphify (knowledge graph)
graphify claude install   # Registers PreToolUse hook + CLAUDE.md section
graphify hook install     # Registers git post-commit hook for AST updates
```

Or use `/codd-init` slash command in Claude Code after invoking AI-DLC × CoDD.

### Step 2: Invoke AI-DLC × CoDD and Describe Your Project

```
AI-DLC CoDD USING. Please follow CLAUDE.md.
I want to build [your project description].
```

The workflow will run: Workspace Detection → Requirements Analysis → Workflow Planning

### Step 3: Generate Design Documents from Requirements

After Requirements Analysis is approved, run:

```bash
codd generate --wave 1 --path .
codd scan --path .
codd validate --path .
```

Or use `/codd-generate` and `/codd-scan` slash commands.

### Step 4: Develop with AI — Construction Phase

The workflow enters Construction Phase (Functional Design → Code Generation per unit).
After every file edit, the PostToolUse hook automatically runs:

```bash
codd scan --path .  # automatic — triggered by Write/Edit hooks
```

At each Code Generation completion gate, run:

```bash
# Three-Way Coherence Closure
codd extract        # Step 1: extract code→CoDD (CoDD = primary authority)
codd validate       # Step 2: CoDD internal coherence (primary gate)
/graphify --update  # Step 3: sync derived knowledge graph
/graphify query "Summarize coherence: coverage, missing links, key risks"  # Step 4: verify
```

### Step 5: Commit — Pre-commit Hook Validates CoDD

```bash
git add -A
git commit -m "feat: initial implementation"
# Pre-commit hook automatically runs: codd validate --path .
# Commit blocked if any staged .md file is missing CoDD frontmatter
```

---

## Option B: Brownfield (Existing Project, Existing Code)

### Step 1: Extract Code Structure and Build Knowledge Graph

```bash
# Extract code structure (CoDD — document engine)
codd extract
# Generates: codd/extracted/ with static analysis of your codebase

# Set up Graphify (knowledge graph)
graphify claude install                    # Register PreToolUse hook + CLAUDE.md section
graphify hook install                      # Register git post-commit hook for AST updates
graphify /path/to/your-project --mode deep # Build initial knowledge graph
# → graphify-out/graph.json with Leiden communities (unit candidates) and god nodes
```

### Step 2: Generate Plan from Extracted Docs

```bash
codd plan --init
# Generates: wave_config in codd/codd.yaml from extracted docs
```

### Step 3: Restore Design Documents from Code

```bash
codd restore --wave 1 --path .   # Restore Wave 1 (Requirements) docs from code
codd restore --wave 2 --path .   # Restore Wave 2 (System Design) docs
# Review every restored document — inferred content needs human verification
```

> **Note**: Use `codd require` to infer requirements from code before running `codd restore --wave 1`. Wave numbering starts at 1 (Wave 1 = Requirements, Wave 2 = System Design, Wave 3 = Detail Design).

Or use `/codd-restore` slash command in Claude Code.

### Step 4: Validate and Build Dependency Graph

```bash
codd scan --path .
codd validate --path .
# Fix any reported issues before continuing
```

### Step 5: Invoke AI-DLC × CoDD for Ongoing Development

```
AI-DLC CoDD USING. Please follow CLAUDE.md.
```

The workflow detects existing CoDD artifacts → skips Reverse Engineering → goes directly to
Requirements Analysis or Workflow Planning based on what already exists.

---

## Daily Development Loop

Once set up, most operations happen automatically:

| When | What Happens | Command |
|------|-------------|---------|
| After editing `.md` files | **Automatic** | PostToolUse hook → `codd scan --path .` |
| After `git commit` | **Automatic** | Post-commit hook → `graphify --update` (AST only) |
| At Code Generation gate | **Manual** | `codd extract` → `codd validate` (primary) → `/graphify --update` (derived) → query |
| Before PR / code review | **Manual** | `/codd-impact` |
| After modifying source code | **Manual** | `/codd-propagate` or `/codd-propagate --update` |
| On `git commit` | **Automatic** | Pre-commit hook → `codd validate --path .` |
| When graph looks stale | **Manual** | `/graphify --update` or `/codd-scan` |
| When frontmatter errors appear | **Manual** | `/codd-validate` |
| Query architecture insights | **Manual** | `/graphify query "<question>"` |

---

## Slash Commands Reference

| Command | When to Use |
|---------|-------------|
| `/graphify --update` | Sync derived knowledge graph and generate GRAPH_REPORT.md (Step 3 of Three-Way Coherence Closure) |
| `/graphify query "<q>"` | Query the knowledge graph for coherence checks or impact analysis |
| `/codd-init` | Bootstrap CoDD in a new project |
| `/codd-scan` | Manually refresh the CoDD dependency index |
| `/codd-validate` | Check frontmatter and dependency references |
| `/codd-impact` | Analyze change blast radius before a PR |
| `/codd-propagate` | Sync source code changes back to design docs |
| `/codd-restore` | Reconstruct design docs from existing code (brownfield) |
| `/codd-generate` | Generate design docs from requirements (greenfield) |
| `/codd-assemble` | Assemble sprint fragments into a complete project (requires `codd implement` first) |

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| `codd: command not found` | `pip install codd-dev` |
| `graphify: command not found` | `pip install graphifyy` |
| Pre-commit hook blocks commit | Run `codd validate --path .` and fix reported errors |
| `graphify-out/graph.json` not found | Run `graphify <project-root> --mode deep` to build the initial graph |
| Graph counts look wrong | Run `/graphify --update` or `/codd-scan` manually |
| Design docs missing frontmatter | Add CoDD frontmatter block at top of each `.md` file |
| `.codd/codd.yaml` not found | Copy from template: `cp .codd/codd.yaml.template .codd/codd.yaml` |
| `codd extract --ai` says "0 source files analyzed" | See Windows tree-sitter setup below |
| `codd scan` shows `imports` edges to `module:` nodes instead of `file:` paths | Same root cause: install tree-sitter parsers and re-run `codd scan --path .` |
| Pre-commit hook not installed at session start | Expected on Brownfield; runs in Workspace Detection Step 3.5 |

---

## Windows — tree-sitter Phase 1 Setup

`codd extract --ai` runs in two phases. Phase 1 uses tree-sitter for static pre-scan; Phase 2 uses AI. On Windows, Phase 1 may report `0 source files analyzed` due to missing tree-sitter language parsers. Phase 2 (AI) still works correctly even when Phase 1 fails.

**Symptoms**: `codd extract --ai` output shows `Source: 0 python files` or `0 source files analyzed`

**Cause**: tree-sitter language grammars (Python, TypeScript, etc.) are not installed in the CoDD environment.

**Fix**:

```bash
# Install tree-sitter language bindings for your project's languages
pip install tree-sitter-python      # for Python projects
pip install tree-sitter-typescript  # for TypeScript/JavaScript projects
pip install tree-sitter-javascript  # (if tree-sitter-typescript alone is insufficient)

# Verify: re-run the extract command
PYTHONIOENCODING=utf-8 PYTHONUTF8=1 codd extract --ai --prompt-file .codd/extract-prompt-addendum.md
# Phase 1 should now report: "Source: N python files" (N > 0)
```

**Note**: Even without Phase 1 (0 files), Phase 2 (AI analysis) reads source files directly and generates correct L1–L6 design documents.

However, tree-sitter absence also affects **`codd scan`** beyond just Phase 1 of extract:
- Without tree-sitter: Python/TypeScript `import` statements resolve to `module:` **empty** nodes
- With tree-sitter: `import` statements create `file:path → file:path` edges (e.g., `router.py → repository.py → models.py`)
- Impact: `codd impact` cannot track code-to-code change propagation without these edges

To restore full dependency chains after installing tree-sitter:
```bash
PYTHONIOENCODING=utf-8 PYTHONUTF8=1 codd scan --path .
# Re-running codd scan after installation creates proper file→file import edges
```

**Workspace Detection (Step 3.5) will prompt you** to install tree-sitter before running these commands. You can also install at any time and re-run `codd scan --path .`.
