# CoPilot-MultiAgent

A reusable **meta-template** for multi-agent AI orchestration inside VS Code with GitHub Copilot.
Copy the scaffold into another project, then customize the placeholder commands, conventions, and project-specific guidance before using the pipeline: **Plan → Explore → Implement → Validate → Review**.

> This repository is intentionally generic. It is meant to be adapted inside a target project, not used unchanged as a turnkey workflow.

## What you get

| Primitive | Count | Purpose |
|-----------|-------|---------|
| Custom Agents | 8 | Role-based personas with minimal tool sets and handoffs |
| Skills | 7 | On-demand reusable workflows (explore, implement, build, lint, review, …) |
| Instructions | 4 | Always-on or glob-scoped rules (style, testing, security, handoffs) |
| Prompts | 2 | `/new-task` bootstrap and `/handoff` phase transition |
| MCP template | 1 | Pre-configured entries for GitHub, Filesystem, Context7, Playwright |
| Task skeleton | 1 | `tasks/_template/` with all five phase artifact files |

## Quick Start

### 1 — Bootstrap into your project

```bash
# From this repo, copy the scaffold into your target project
mkdir -p /path/to/your-project/.vscode /path/to/your-project/tasks
cp -r .github/ /path/to/your-project/
cp -r docs/ /path/to/your-project/
cp tasks/README.md /path/to/your-project/tasks/README.md
cp -r tasks/_template/ /path/to/your-project/tasks/
cp .vscode/mcp.json.example /path/to/your-project/.vscode/mcp.json.example
```

### 2 — Configure MCP (optional)

```bash
cd /path/to/your-project
cp .vscode/mcp.json.example .vscode/mcp.json
# Edit .vscode/mcp.json — fill in server paths and secrets via env vars
```

Ensure your target project's `.gitignore` contains:

```gitignore
.vscode/mcp.json
```

Commit only `mcp.json.example`.

### 3 — Start a task

In VS Code chat, select the **Orchestrator** agent from the agent picker, then describe your goal:

```
Add JWT authentication to the /api/users endpoint
```

The Orchestrator creates `tasks/20260514-add-jwt-auth/plan.md` and dispatches the pipeline.

Alternatively, type `/new-task` in chat to bootstrap the task folder manually before invoking the Orchestrator.

### 4 — Adapt for your project

- Edit `.github/copilot-instructions.md` — add project-specific architecture notes, build commands, and team conventions.
- Update skill bodies in `.github/skills/build-and-test/SKILL.md` and `.github/skills/lint-and-typecheck/SKILL.md` — replace placeholder build/test commands with your actual commands.
- Replace placeholder project rules in `.github/instructions/code-style.instructions.md` and any specialist templates you keep enabled.
- Keep `docs/` if you want the copied scaffold to retain the built-in architecture and lifecycle references; otherwise replace those links with project-local docs.
- Enable specialist agents (`firmware-engineer`, `protocol-specialist`) by removing `user-invocable: false` from their frontmatter if relevant.

## Repository Layout

```
.github/
  copilot-instructions.md           ← always-on project rules
  instructions/                     ← file-scoped or on-demand rules
  agents/                           ← 8 custom agent definitions
  skills/                           ← 7 reusable skill workflows
  prompts/                          ← /new-task and /handoff prompts
.vscode/
  mcp.json.example                  ← MCP server template (copy → mcp.json)
  settings.json                     ← workspace settings for agent discovery
tasks/
  README.md                         ← task lifecycle + folder schema
  _template/                        ← skeleton for each new task
docs/
  architecture.md                   ← system design + Mermaid diagram
  task-lifecycle.md                 ← phase definitions + gating rules
  agent-roles.md                    ← per-agent reference card
  customization-guide.md            ← how to add agents, skills, MCP servers
```

## Documentation

- [Architecture & sequence diagram](docs/architecture.md)
- [Task lifecycle & gating rules](docs/task-lifecycle.md)
- [Agent roles reference](docs/agent-roles.md)
- [Customization guide](docs/customization-guide.md)

## Design Decisions

- **File-based handoffs** over in-memory state: artifacts survive crashes, are human-readable, and enable async review.
- **Strict tool allowlists**: each agent can only use what its role requires — prevents accidental destructive operations.
- **Append-only artifacts**: phase outputs are never deleted, enabling full audit trails.
- **Generic core + optional specialists**: the pipeline works for any codebase; firmware and protocol specialists are opt-in templates.

## Requirements

- VS Code 1.99 or later
- GitHub Copilot subscription with agent mode enabled
