---
codd:
  node_id: "doc:codd-extract-prompt-addendum-en"
  type: document
  depends_on: []
---

# CoDD Extract AI — Output Format Supplemental Instructions

This file is used with `codd extract --ai --prompt-file .codd/extract-prompt-addendum.md`.
These are supplemental instructions appended to the default CoDD extraction prompt.

---

## ⚠️ CRITICAL: CoDD Frontmatter for L1–L6 Documents

Each L1–L6 Markdown document MUST begin with a valid CoDD frontmatter block. Include `source_files:` with the **actual paths of the files you analyzed for that layer** (relative to project root, using forward slashes). Only include paths you **confirmed exist** by running enumeration commands — **never guess or infer paths** from package names, import statements, or general knowledge. Dangling paths (paths that do not exist on disk) create dead `extracted_from` edges in the dependency graph.

```yaml
---
codd:
  node_id: "doc:L1_data_models"    # use layer name as node_id
  type: design
  source: extracted
  depends_on: []
  source_files:                    # List every source file path you analyzed for this layer
    - "<relative/path/to/file>"   # paths relative to project root (forward slashes)
---
```

### Why `source_files:` matters

CoDD scanner reads `source_files:` to create `extracted_from` edges linking this design document to the source files it covers. Without this field, source files remain unlinked orphan nodes and `codd measure` reports 0% source coverage. Include all file paths you enumerated when producing this layer's analysis.

---

## ⚠️ CRITICAL: Do NOT Wrap Document Content in Markdown Code Fences

Output each L1–L6 Markdown document as **raw Markdown content**. Do NOT prefix the document with `` ```markdown `` and do NOT suffix it with ` ``` `.

### Rules

1. File content MUST start directly with the CoDD frontmatter `---` block — no preceding code fence
2. File content MUST end with the document body text — no trailing ` ``` `
3. `` ```markdown ``, `` ```yaml ``, `` ```text ``, and all other code fence wrappers around complete documents are **FORBIDDEN**

**Why this matters**: When a document is wrapped in `` ```markdown ``, the frontmatter `---` delimiters appear inside a code fence and are invisible to the YAML parser. The document loses its CoDD identity and becomes an orphan node with zero edges in the dependency graph — `codd measure` reports 0% Source Coverage for those design layers.

---

## ⚠️ CRITICAL: File Marker Output Format

When separating each file's output, use **exactly this format**:

```
--- FILE: filename.md ---
```

### ✅ Correct format (MUST USE)

```
--- FILE: L1_data_models.md ---
(file content)

--- FILE: L2_api_endpoints.md ---
(file content)
```

### ❌ Prohibited formats (NEVER USE)

```markdown
## `--- FILE: L1_data_models.md ---`   ← WRONG: Markdown heading + backticks
### --- FILE: L1_data_models.md ---    ← WRONG: Markdown heading
`--- FILE: L1_data_models.md ---`      ← WRONG: wrapped in backticks
```

### Rules

1. Markers MUST be **plain text starting at the beginning of a line**
2. Do NOT wrap markers in Markdown headings (`#`, `##`, `###`)
3. Do NOT wrap markers in backticks (`` ` ``) or code blocks (` ``` `)
4. Do NOT add extra whitespace or characters around markers
5. `extract_result.yaml` uses the same format: `--- FILE: extract_result.yaml ---`
