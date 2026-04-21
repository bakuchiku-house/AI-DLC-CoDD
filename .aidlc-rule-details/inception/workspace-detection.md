---
codd:
  node_id: "doc:workspace-detection-en"
  type: document
  depends_on: []
---

# Workspace Detection

**Purpose**: Determine workspace state and check for existing AI-DLC projects

---

## Step 0: MANDATORY — Prerequisite Tool Check (Hard Gate)

> **CRITICAL**: This step MUST be executed before all other work. If any tool is missing, **do NOT proceed to the next step under any circumstances**. AI compensating for missing tools or simulating their behavior is strictly forbidden — the workflow operates exclusively when tools are correctly installed.

Run the following commands to verify all prerequisite tools:

```bash
# 1. Verify Git (required for CoDD hooks, codd impact, codd propagate)
git --version

# 2. Verify CoDD (document engine and design coherence)
codd --version

# 3. Verify Graphify (knowledge graph — sole user-visible graph tool)
graphify --version
```

**If any command fails → STOP immediately, display installation instructions, and suspend work until the user completes installation:**

```
🛑 Prerequisite tools are missing — cannot proceed until installation is complete

❌ Git not found (required):
   Install from: https://git-scm.com/downloads
   Windows: winget install Git.Git
   Verify: git --version

❌ CoDD not found (required):
   pip install codd-dev
   Verify: codd --version

❌ Graphify not found (required):
   pip install graphifyy
   Verify: graphify --version

Please restart the workflow after all tools are confirmed installed.
```

**Proceed to Step 1 ONLY when all three tools report their version successfully.**

> ⚠️ **AI compensation and workarounds are forbidden**: If tools are missing, the AI MUST NOT:
> - Continue operation without the tools
> - Simulate or emulate tool behavior
> - Proceed with "install later"
> - Replace CoDD/Graphify processing with AI-generated approximations
>
> Require the user to install the tools and verify with `--version` before proceeding. Stop completely until this is done.

---

## Step 1: Check for Existing AI-DLC Project

> **MANDATORY — Audit Log (BEFORE workspace scan)**: Log the user's initial request in `aidlc-docs/audit.md` immediately. Record the user's COMPLETE RAW INPUT, word-for-word as typed — **never summarize, shorten, or paraphrase**. Use this format:
> ```markdown
> ## Workspace Detection - Initial Request
> **Timestamp**: [ISO timestamp]
> **User Input**: "[User's complete input exactly as typed]"
> **AI Response**: "Workspace Detection initiated"
> **Context**: INCEPTION - Workspace Detection, initial request logged
> ```

Check if `aidlc-docs/aidlc-state.md` exists:
- **If exists**: Resume from last phase (load context from previous phases)
- **If not exists**: Continue with new project assessment

> ⚠️ **IMPORTANT — State Verification on Resume**: If `aidlc-state.md` exists, do NOT trust its recorded state without verification. Before resuming, check actual file existence on disk:
> - Verify `codd/codd.yaml` or `.codd/codd.yaml` actually exists (do not assume from state record)
> - Verify `codd/scan/nodes.jsonl` exists if the graph is recorded as initialized
> - Verify key artifact files exist (e.g., `aidlc-docs/inception/reverse-engineering/*.md`)
>
> Any discrepancy between `aidlc-state.md` and actual disk state must be corrected **before** resuming work. Update `aidlc-state.md` to reflect reality, then re-run any missing operations.

## Step 2: Scan Workspace for Existing Code

**Determine if workspace has existing code:**
- Scan workspace for source code files (.java, .py, .js, .ts, .jsx, .tsx, .kt, .kts, .scala, .groovy, .go, .rs, .rb, .php, .c, .h, .cpp, .hpp, .cc, .cs, .fs, etc.)
- Check for build files (pom.xml, package.json, build.gradle, etc.)
- Look for project structure indicators
- Identify workspace root directory (NOT aidlc-docs/)

**Record findings:**
```markdown
## Workspace State
- **Existing Code**: [Yes/No]
- **Programming Languages**: [List if found]
- **Build System**: [Maven/Gradle/npm/etc. if found]
- **Project Structure**: [Monolith/Microservices/Library/Empty]
- **Workspace Root**: [Absolute path]
```

## Step 3: Determine Next Phase

**IF workspace is empty (no existing code)**:
- Set flag: `brownfield = false`
- Next phase: Requirements Analysis

**IF workspace has existing code**:
- Set flag: `brownfield = true`
- Check for existing reverse engineering artifacts in `aidlc-docs/inception/reverse-engineering/`
- **IF reverse engineering artifacts exist**: Load them, skip to Requirements Analysis
- **IF no reverse engineering artifacts**: Next phase is Reverse Engineering

---

## [CoDD] Step 3.5: MANDATORY — CoDD Initialization

**CRITICAL**: Execute CoDD initialization immediately after workspace detection. CoDD initialization MUST be performed before any other phase.

### Check CoDD Status
- Check if `.codd/codd.yaml` (or `codd/codd.yaml`) exists

### Greenfield Project (no existing code)
```bash
# Initialize CoDD for a new project
codd init
# → Prompts: project name, primary language, config directory
# → Generates codd/codd.yaml by default (use --config-dir .codd for hidden directory)
# → Creates codd/scan/ directory (for dependency graph)
```
**Alternative**: Copy provided template and customize:
```bash
cp .codd/codd.yaml.template .codd/codd.yaml
# Edit .codd/codd.yaml: set project, language, source_dirs, ai_command
```

### [CoDD] Pre-flight: tree-sitter Language Parser Check (Brownfield)

**BEFORE running `codd extract --ai` or `codd scan`**, verify that tree-sitter language parsers are installed for the project's programming languages.

**Why tree-sitter matters for BOTH commands:**

| Without tree-sitter | With tree-sitter |
|---------------------|------------------|
| `codd extract --ai` Phase 1: "0 source files analyzed" | Phase 1 scans all source files |
| `codd scan`: `imports` edges → `module:` **empty** nodes | `codd scan`: `imports` edges → `file:path` actual file nodes |
| `codd impact` tracks only design-doc dependencies | `codd impact` tracks real code-to-code propagation |

> **Note**: This is a `codd scan` limitation, not just an extract limitation. Without tree-sitter, Python `from . import X` and TypeScript `import { Y } from './y'` resolve to broken `module:` nodes rather than actual `file:path` edges — making code dependency chains invisible to `codd impact`.

**Step 1 — Check installed parsers** based on detected project language(s):
```bash
# Python projects
python -c "import tree_sitter_python; print('tree-sitter-python: OK')" 2>/dev/null || echo "tree-sitter-python: MISSING"
# TypeScript/JavaScript projects
python -c "import tree_sitter_typescript; print('tree-sitter-typescript: OK')" 2>/dev/null || echo "tree-sitter-typescript: MISSING"
```

**Step 2 — If any parsers are MISSING, ask the user:**

> tree-sitter parser(s) for [DETECTED_LANGUAGES] are not installed.
>
> Installing them enables:
> - `codd extract --ai` Phase 1 to scan source files (instead of "0 files analyzed")
> - `codd scan` to create accurate `file:path` import edges (e.g., `router.py → repository.py → models.py` visible)
> - `codd impact` to track real code-to-code change propagation
>
> **A)** Install now (recommended):
> ```bash
> pip install tree-sitter-python          # Python projects
> pip install tree-sitter-typescript      # TypeScript/JavaScript projects
> pip install tree-sitter-javascript      # (optional: if TypeScript alone is insufficient)
> ```
>
> **B)** Skip — proceed without tree-sitter
> (`codd extract --ai` Phase 1 will show 0 files; `codd scan` import chains will be limited to `module:` nodes;
> you can install later and re-run `codd scan --path .` to create proper file→file edges)
>
> **[Answer]**: A

**If user chooses A**: Install the listed packages, verify with the check commands above, then continue.
**If user chooses B**: Note in `aidlc-state.md` that tree-sitter was skipped, proceed.

**If all parsers are already installed**: Skip this step and proceed directly.

---

### Brownfield Project — Reverse Engineering Required

> ⚠️ **REQUIRED before running `codd extract --ai`**: Verify that `.codd/codd.yaml` has `source_dirs` pointing to your actual source directory (NOT the default `"src/"`). If left as default, Phase 1 scans 0 files and the AI phase cannot analyze any code.
>
> ```yaml
> # In .codd/codd.yaml, update:
> scan:
>   source_dirs:
>     - "source/"   # ← Replace with your actual source directory
> ```

```bash
# AI-powered extraction (generates 6-layer MECE design documents) — recommended command
PYTHONIOENCODING=utf-8 PYTHONUTF8=1 codd extract --ai --prompt-file .codd/extract-prompt-addendum.md
# → Phase 1: Python deterministic pre-scan (requires source_dirs to be correctly configured)
# → Phase 2: AI generates design documents with CoDD frontmatter
# → --prompt-file: forces plain-text file markers so CoDD parser can split output correctly
# → Default AI command: claude --print --model claude-opus-4-6 --tools ""
```

### Brownfield Project — No Reverse Engineering Needed
```bash
# Static analysis only (fast, no AI required)
codd extract
# → Builds dependency graph from existing code via tree-sitter
# → No AI cost, suitable for fast graph initialization
```

### After CoDD Initialization
- Verify `codd/codd.yaml` or `.codd/codd.yaml` exists
- Record CoDD initialization status in `aidlc-docs/aidlc-state.md`:
  ```markdown
  ## CoDD Status
  - **CoDD Initialized**: Yes
  - **Config Path**: codd/codd.yaml (or .codd/codd.yaml if --config-dir .codd was used)
  - **Initialization Method**: [codd init / codd extract / codd extract --ai]
  ```
- From this point, the **CoDD Coherence Extension** is active (codd.yaml existence condition met)

### Install Pre-commit Hook (MANDATORY after codd.yaml creation)

Run `codd hooks install --path .` to install the git pre-commit hook now that `codd.yaml` exists:

```bash
codd hooks install --path .
# → Installs .git/hooks/pre-commit for CoDD validation on git commit
# → On Windows: if symlink fails, guidance is displayed — continue without the hook
# → This step is required here because the SessionStart hook ran before codd.yaml existed (Brownfield projects)
```

> **Why this is needed**: The SessionStart hook runs `install-codd-pre-commit.sh` at session start. In Brownfield projects, `.codd/codd.yaml` does not yet exist at that point, so `codd hooks install` fails with "config dir not found". Running it explicitly here (after codd.yaml is created) ensures the pre-commit hook is installed.

---

## [Graphify] Step 3.6: MANDATORY — Knowledge Graph Setup

**CRITICAL**: Set up the Graphify knowledge graph immediately after CoDD initialization. Graphify is the **sole user-visible graph tool** in the 3-layer architecture.

### Check Graphify Status

- Check if `graphify-out/graph.json` exists

### If `graphify-out/graph.json` does NOT exist (first time)

```bash
# 1. Ensure Graphify is installed
pip install graphifyy

# 2. Register Claude Code integration (PreToolUse hook + CLAUDE.md guidance)
#    → Registers hook so Claude reads GRAPH_REPORT.md before Glob/Grep searches
graphify claude install

# 3. Register git post-commit hook for automatic AST updates (fast, no LLM cost)
graphify hook install
# → Windows: may fail with WinError 1314 (symlink creation requires elevated privileges)
#   This is non-blocking — skip and continue without the post-commit hook on Windows

# 4. Build initial knowledge graph — use the /graphify slash command in Claude Code:
/graphify . --mode deep
# → Creates graphify-out/graph.json
# → AST edges (EXTRACTED) from code + LLM semantic edges (INFERRED/AMBIGUOUS) from docs
# → Leiden community detection: communities = candidate units of work
# → God nodes = high-connectivity architectural hubs (widest blast radius on change)
```

> **Note**: `--mode deep` is recommended for initial build. It performs thorough LLM semantic extraction and produces richer INFERRED edges. For large codebases (>200 files), consider running on a subfolder first.

### If `graphify-out/graph.json` ALREADY exists (resume)

```bash
# Refresh with latest changes — use the /graphify slash command in Claude Code:
/graphify . --update
```

### After Graphify Setup

- Record Graphify initialization status in `aidlc-docs/aidlc-state.md`:
  ```markdown
  ## Graphify Status
  - **Graph Initialized**: Yes
  - **Graph Path**: graphify-out/graph.json
  - **Initialization Method**: [graphify <path> --mode deep / --update]
  - **Communities**: [N — from Leiden detection]
  - **God Nodes**: [list top architectural hubs]
  ```
- The PreToolUse hook is now active: Claude reads `graphify-out/GRAPH_REPORT.md` before file searches
- The git post-commit hook is active: AST auto-updates on every commit (no LLM cost)
- **CoDD ↔ Graphify bridge**: CoDD frontmatter `depends_on` entries are now EXTRACTED edges in the graph
- **Initial git commit required**: Run `git init && git add -A && git commit -m "chore: initial AI-DLC setup"` after workspace setup. `codd impact` and `codd propagate` require at least one git commit to function — they use `git diff HEAD` to detect changes. Without an initial commit, these commands will fail with a git error.

---

## Step 4: Create Initial State File

Create `aidlc-docs/aidlc-state.md`:

```markdown
# AI-DLC State Tracking

## Project Information
- **Project Type**: [Greenfield/Brownfield]
- **Start Date**: [ISO timestamp]
- **Current Stage**: INCEPTION - Workspace Detection

## Workspace State
- **Existing Code**: [Yes/No]
- **Reverse Engineering Needed**: [Yes/No]
- **Workspace Root**: [Absolute path]

## CoDD Status
- **CoDD Initialized**: [Yes/No]
- **Config Path**: [.codd/codd.yaml or codd/codd.yaml]
- **Initialization Method**: [codd init / codd extract / codd extract --ai]

## Graphify Status
- **Graph Initialized**: [Yes/No]
- **Graph Path**: graphify-out/graph.json
- **Initialization Method**: [graphify <path> --mode deep / --update]

## Code Location Rules
- **Application Code**: Workspace root (NEVER in aidlc-docs/)
- **Documentation**: aidlc-docs/ only
- **Structure patterns**: See code-generation.md Critical Rules

## Stage Progress
[Will be populated as workflow progresses]
```

## Step 5: Present Completion Message

**For Brownfield Projects:**
```markdown
# 🔍 Workspace Detection Complete

Workspace analysis findings:
• **Project Type**: Brownfield project
• [AI-generated summary of workspace findings in bullet points]
• **[CoDD]** CoDD initialization complete: `codd extract [--ai]` executed successfully
• **[Graphify]** Knowledge graph initialized: `graphify-out/graph.json` created with [N] nodes, [M] communities
• **Next Step**: Proceeding to **Reverse Engineering** to analyze existing codebase...
```

**For Greenfield Projects:**
```markdown
# 🔍 Workspace Detection Complete

Workspace analysis findings:
• **Project Type**: Greenfield project
• **[CoDD]** CoDD initialization complete: `codd init` executed and `codd/codd.yaml` created
• **[Graphify]** Knowledge graph initialized: `graphify-out/graph.json` created
• **Next Step**: Proceeding to **Requirements Analysis**...
```

## Step 6: Automatically Proceed

- **No user approval required** - this is informational only
- Automatically proceed to next phase:
  - **Brownfield**: Reverse Engineering (if no existing artifacts) or Requirements Analysis (if artifacts exist)
  - **Greenfield**: Requirements Analysis
