---
codd:
  node_id: "doc:session-continuity-en"
  type: document
  depends_on: []
---

# Session Continuity Templates

## Welcome Back Prompt Template
When a user returns to continue work on an existing AI-DLC project, present this prompt:

```markdown
**Welcome back! I can see you have an existing AI-DLC project in progress.**

Based on your aidlc-state.md, here's your current status:
- **Project**: [project-name]
- **Current Phase**: [INCEPTION/CONSTRUCTION/OPERATIONS]
- **Current Stage**: [Stage Name]
- **Last Completed**: [Last completed step]
- **Next Step**: [Next step to work on]

**What would you like to work on today?**

A) Continue where you left off ([Next step description])
B) Review a previous stage ([Show available stages])

[Answer]: 
```

## MANDATORY: Session Continuity Instructions
1. **Always read aidlc-state.md first** when detecting existing project
2. **Parse current status** from the workflow file to populate the prompt
3. **MANDATORY: Load Previous Stage Artifacts** - Before resuming any stage, automatically read all relevant artifacts from previous stages:
   - **Reverse Engineering**: Read architecture.md, code-structure.md, api-documentation.md
   - **Requirements Analysis**: Read requirements.md, requirement-verification-questions.md
   - **User Stories**: Read stories.md, personas.md, story-generation-plan.md
   - **Application Design**: Read application-design artifacts (components.md, component-methods.md, services.md)
   - **Design (Units)**: Read unit-of-work.md, unit-of-work-dependency.md, unit-of-work-story-map.md
   - **Per-Unit Design**: Read functional-design.md, nfr-requirements.md, nfr-design.md, infrastructure-design.md
   - **Code Stages**: Read all code files, plans, AND all previous artifacts
4. **Smart Context Loading by Stage**:
   - **Early Stages (Workspace Detection, Reverse Engineering)**: Load workspace analysis
   - **Requirements/Stories**: Load reverse engineering + requirements artifacts
   - **Design Stages**: Load requirements + stories + architecture + design artifacts
   - **Code Stages**: Load ALL artifacts + existing code files
5. **Adapt options** based on architectural choice and current phase
6. **Show specific next steps** rather than generic descriptions
7. **Log the continuity prompt** in audit.md with timestamp
8. **Context Summary**: After loading artifacts, provide brief summary of what was loaded for user awareness
9. **Asking questions**: ALWAYS ask clarification or user feedback questions by placing them in .md files. DO NOT place the multiple-choice questions in-line in the chat session.

## CoDD State Verification (Mandatory when CoDD is active)

**CRITICAL**: When resuming a project that uses CoDD (i.e., `codd/codd.yaml` or `.codd/codd.yaml` is recorded as existing in `aidlc-state.md`), do NOT trust the recorded state blindly. Verify actual file existence on disk before resuming:

```
CoDD State Verification Checklist:
- [ ] codd/codd.yaml or .codd/codd.yaml actually exists on disk
      (Run: ls .codd/codd.yaml or ls codd/codd.yaml)
- [ ] codd/scan/nodes.jsonl or .codd/scan/nodes.jsonl exists
      (Confirms dependency graph has been initialized)
- [ ] All artifacts listed as "completed" in aidlc-state.md are actually present
      (Check key files like aidlc-docs/inception/reverse-engineering/*.md)
```

**If discrepancies found**:
1. Correct `aidlc-state.md` to reflect the actual state
2. Re-run any missing CoDD operations (e.g., `codd init`, `codd extract --ai`, `codd scan --path .`)
3. Log the correction in `aidlc-docs/audit.md` with timestamp and description of the discrepancy

## Error Handling
If artifacts are missing or corrupted during session resumption, see [error-handling.md](error-handling.md) for guidance on recovery procedures.