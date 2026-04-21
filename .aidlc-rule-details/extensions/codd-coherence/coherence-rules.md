---
codd:
  node_id: "doc:codd-coherence-rules-en"
  type: document
  depends_on: []
---

# CoDD Coherence Rules

## Overview
These CoDD coherence rules are cross-cutting constraints that apply across all AI-DLC phases when CoDD is active. They ensure that every generated document participates in the dependency graph, that coherence issues are surfaced to humans at approval gates, and that project health is measured at completion.

**Activation Condition**: This extension is active when `codd/codd.yaml` or `.codd/codd.yaml` exists in the project root. If neither exists, all rules are marked N/A.

**Enforcement**: At each applicable stage, the model MUST verify compliance with these rules before presenting the stage completion message to the user.

### Blocking vs Non-Blocking Behavior

**Blocking finding** (CODD-01):
1. The finding MUST be listed in the stage completion message under a "CoDD Findings" section with the CODD rule ID and description
2. The stage MUST NOT present the "Continue to Next Stage" option until all blocking findings are resolved
3. The model MUST present only the "Request Changes" option with a clear explanation of what needs to change
4. The finding MUST be logged in `aidlc-docs/audit.md` with the CODD rule ID, description, and stage context

**Non-blocking finding** (CODD-02, CODD-03):
1. The finding MUST be displayed in the stage completion message under a "CoDD Coherence Warnings" section
2. The stage MAY still present the "Continue to Next Stage" option
3. Human judgment at the HITL gate determines whether to proceed or resolve first
4. The finding MUST be logged in `aidlc-docs/audit.md` for traceability

### Default Enforcement
CODD-01 is **blocking**. CODD-02 and CODD-03 are **non-blocking** (informational warnings only). If CODD-01 verification criteria are not met, follow the blocking finding behavior defined above.

### Verification Criteria Format
Verification items in this document are plain bullet points describing compliance checks. They are distinct from the `- [ ]` / `- [x]` progress-tracking checkboxes used in stage plan files. Each item should be evaluated as compliant or non-compliant during review.

---

## Applicability Question

CoDD Coherence Extension applicability is determined **automatically** — no question is posed to the user:

- If `codd/codd.yaml` or `.codd/codd.yaml` exists → CoDD Coherence Extension: **Enabled**
- If neither `codd/codd.yaml` nor `.codd/codd.yaml` exists → CoDD Coherence Extension: **N/A**

Record the enablement status in `aidlc-docs/aidlc-state.md` under `## Extension Configuration`:

```markdown
## Extension Configuration
- **CoDD Coherence Extension** (codd-coherence-v1): [Enabled / N/A]
  - Condition: codd/codd.yaml or .codd/codd.yaml [exists / does not exist]
```

---

## Rule CODD-01: CoDD Frontmatter on All Generated Documents

**Severity**: **BLOCKING**

**Rule**: Every document generated during AI-DLC phases MUST include a valid CoDD frontmatter block. This applies to all Markdown files created or modified during the workflow, including requirements, design, code summaries, and build/test instructions.

**Required frontmatter fields**:
```yaml
---
codd:
  node_id: "prefix:name"           # Format: allowed-prefix:descriptive-name
  type: <architecture|design|requirements|code|test|infra>
  depends_on:
    - {id: "parent:name", relation: "depends_on"}  # Empty list [] if no dependencies
  source_files:                     # RECOMMENDED for design/code docs: creates doc→code edges
    - "source/path/to/file.py"     # paths relative to project root (scanner R6.2)
  confidence: 0.9                   # Optional: AI-generated content confidence score (0.0–1.0)
  depended_by:                      # Optional: reverse references (reduces validate warnings)
    - {id: "child:name", relation: "depends_on"}
---
```

> ⚠️ **`source_files:` vs `modules:` — Critical Distinction**:
> - **`source_files:`** — List of specific source file paths (relative to project root). This field creates `extracted_from` edges in CoDD's dependency graph between the design doc and source files (scanner.py R6.2: `for source_file in codd.get("source_files", [])`). Use this for design and code-level documents.
>   > ⚠️ **`source_files:` coverage clarification**: `source_files:` does **NOT** drive `coverage_ratio` in `codd measure` — that metric is driven by the `modules:` field. `source_files:` also does **NOT** automatically create EXTRACTED edges in Graphify; only CoDD frontmatter `depends_on` entries become Graphify EXTRACTED edges.
> - **`modules:`** — Does NOT create graph edges. A different field used by CoDD for propagation context. Do **not** rely on `modules:` for source file linkage.
>
> **Example** (for a component-level design doc):
> ```yaml
> source_files:
>   - "source/backend/app/router.py"
>   - "source/backend/app/models.py"
>   - "source/backend/app/service.py"
> ```
> **When to add `source_files:`**: Design documents that describe specific source files (code-structure, api-documentation, component-inventory, L1-L6 extracted docs). Architecture/business-overview docs that are not file-specific may omit this field.

**node_id naming convention** (allowed prefixes: req, design, doc, test, infra, file, module, etc.):
- Requirements: `req:<project-name>` (e.g., `req:my-app`)
- Architecture: `doc:<project_name>_<descriptor>` with `type: architecture` (e.g., `node_id: "doc:my_app_overview"` + `type: architecture`) — **use `doc:` prefix, NOT `arch:`**
- Design: `design:<project-name>-<descriptor>` (e.g., `design:my-app-auth`)
- Code summary: `doc:<name>` or `file:<name>` (e.g., `doc:auth-service`)
- Test instructions: `test:<project-name>-<type>` (e.g., `test:my-app-unit`)

> ⚠️ **CoDD 1.6.0 Validator Constraint**: The `arch:` prefix is **not supported** in CoDD 1.6.0 — the validator rejects any `arch:` node_id with a naming rule error. Use `doc:` prefix with `type: architecture` to designate architectural documents:
> ```yaml
> node_id: "doc:my_app_overview"
> type: architecture        # CoDD registers this node as architecture type
> ```
> The `arch:` prefix may be supported in a future CoDD version. For now, `doc:` with `type: architecture` achieves the same semantic meaning.

**Verification**:
- Every generated Markdown file in `aidlc-docs/` contains a `codd:` frontmatter wrapper block
- Each `codd:` block contains the required fields: `node_id`, `type`, `depends_on`
- `node_id` follows the `prefix:name` format using CoDD-allowed prefixes (req, design, doc, test, infra, etc.) — Note: `arch:` prefix not supported in CoDD 1.6.0, use `doc:` with `type: architecture`
- `node_id` values are unique within the project (no two documents share the same node_id)
- `depends_on` is a list of dicts with `id` and `relation` keys, or an empty list `[]`
- `type` uses one of the allowed values: `architecture`, `design`, `requirements`, `code`, `test`, `infra`
- Design and code-level documents that describe specific source files SHOULD include `source_files:` with actual file paths (relative to project root) — this creates `extracted_from` edges in CoDD's dependency graph (doc→code). Note: `source_files:` does NOT drive `coverage_ratio` in `codd measure` (which is driven by `modules:`), and does NOT create EXTRACTED edges in Graphify (only `depends_on` entries become Graphify EXTRACTED edges)
- `source_files:` is NOT required for architecture/business-overview docs that are not file-specific
- `depended_by:` is optional — add it to parent documents to reduce `codd validate` reciprocal reference warnings. Note: this field was added by AI-DLC × CoDD to improve developer experience; verify it is supported in your CoDD version before widespread use.
- `confidence:` is optional — use to record AI-generated content confidence (0.0–1.0); referenced in CoDD requirements spec (codd-requirements-v2.md)

> **Graphify Edge Confidence Alignment** — When setting `confidence:` in CoDD frontmatter, align with Graphify's edge confidence model:
>
> | CoDD `confidence:` | Graphify label | Meaning |
> |--------------------|----------------|---------|
> | 0.9–1.0 | EXTRACTED | Deterministically derived from code/structure (high certainty) |
> | 0.7–0.9 | INFERRED | LLM-semantic extraction with reasonable confidence |
> | 0.4–0.6 | AMBIGUOUS | Low-certainty relationship — may need human review |
>
> This alignment ensures that when Graphify reads CoDD design documents and creates graph edges, the confidence level in both systems is consistent.

---

## Rule CODD-02: CoDD Validate Warning Display at HITL Gates

**Severity**: **NON-BLOCKING** (informational warning)

**Rule**: At each stage Completion Gate, `codd validate` MUST be run as the **primary gate** and its output MUST be included in the stage completion message when issues are detected. CoDD is the design authority — its validation takes precedence. Graphify is a derived index, synced after CoDD validation.

**When to apply**: At every stage that includes a Completion Gate step:
- Workflow Planning (`codd validate` primary gate, then `/graphify --update` derived sync)
- Code Generation (Three-Way Coherence Closure: `codd extract` → `codd validate` primary → `/graphify --update` derived → query)

**Warning display format** (include in the approval gate message when coherence issues detected):
```
⚠️ Coherence Warning (CoDD — Primary Design Authority)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
CoDD (primary): [codd validate issues, if any]
Graphify (derived): [query result summary, if any]
Recommended action: [suggestion]
You may continue or resolve the issues first.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Impact Band Reference**:
- **Green**: No issues — fully coherent
- **Amber**: Warnings present — review recommended before proceeding
- **Gray**: Minor issues — low priority, may proceed

**Verification**:
- `codd validate` is run at every applicable Completion Gate
- If `codd validate` exits 0 (no issues), the gate proceeds without a warning block
- If `codd validate` exits 1 (issues found), the warning summary is included in the approval gate message
- The warning is logged in `aidlc-docs/audit.md` with timestamp and stage context
- The stage still allows "Continue to Next Stage" — human judgment decides whether to proceed

---

## Rule CODD-03: CoDD Measure Score at Build and Test Completion

**Severity**: **NON-BLOCKING** (informational reporting)

**Rule**: At the completion of the Build and Test phase, `codd measure` MUST be run and its output MUST be included in the Build and Test completion report. This provides a final coherence health snapshot before proceeding to Operations.

**When to apply**: Build and Test phase only (Step 7.5 in `construction/build-and-test.md`)

**Score display format** (include in the Build and Test completion message):
```
CoDD Coherence Score: [score]
Status: [Healthy / Needs Attention]
```

Also include the score in `aidlc-docs/construction/build-and-test/build-and-test-summary.md` under a `## CoDD Coherence Health` section.

**Score interpretation**:
- **Healthy** (≥80%): Project documents are well-connected and coherent
- **Needs Attention** (<80%): Some documents may have missing dependencies, stale edges, or orphaned nodes — review before Operations

**Verification**:
- `codd measure` is run at Build and Test completion
- The score is included in the Build and Test completion message
- The score is written to `build-and-test-summary.md` under `## CoDD Coherence Health`
- If score < 80%, a note recommending review is included (non-blocking — human decides)

---

## Enforcement Integration

These rules are cross-cutting constraints that apply to every AI-DLC stage when CoDD is active. At each stage:
- Evaluate CODD-01 for every generated document — missing frontmatter is a blocking finding
- Evaluate CODD-02 at every Completion Gate — include validate warnings in approval message when present
- Evaluate CODD-03 at Build and Test completion — include measure score in completion report
- Include a "CoDD Coherence Compliance" section in stage completion summaries listing each rule as compliant, non-compliant, or N/A

**CoDD Compliance Summary format** (append to each stage completion message):
```markdown
## CoDD Coherence Compliance
- CODD-01 (Frontmatter): [Compliant / Non-compliant / N/A] — [brief rationale]
- CODD-02 (Validate): [Compliant / N/A] — [exit 0: no issues / exit 1: warnings shown]
- CODD-03 (Measure): [Compliant / N/A — only applies at Build and Test]
```
