# Customization Guide

How to extend the scaffold with new agents, skills, MCP servers, and instructions.

## Adding a New Agent

1. **Create the file** at `.github/agents/<name>.agent.md`.

2. **Write the frontmatter**:
   ```yaml
   ---
   description: "Use when <specific trigger phrase>. <What the agent does>."
   name: "Agent Name"
   tools: [read, search]   # only what the role needs
   user-invocable: true
   ---
   ```
   Critical rules:
   - `description` must contain explicit "Use when…" trigger phrases — this is how VS Code and parent agents discover the agent.
   - `tools` should be the **minimal set** for the role. Resist adding tools "just in case".
   - Quote descriptions that contain colons: `description: "Use when: doing X"` (or single-quote the whole value).

3. **Write the body**:
   - Role statement (one sentence)
   - Inputs (what files/context it reads)
   - Process (numbered steps)
   - Constraints (`DO NOT …` list)
   - Exit criteria

4. **Add handoffs** (optional) if the agent leads into another:
   ```yaml
   handoffs:
     - label: "Run Next Phase"
       agent: next-agent-name
       prompt: "..."
       send: false
   ```

5. **Register as a subagent** (optional): if the Orchestrator should call it, add its name to the `agents:` list in `orchestrator.agent.md`.

6. **Test discovery**: open VS Code chat, switch to the new agent from the agent picker, and confirm it loads.

### Common Pitfalls

| Pitfall | Fix |
|---------|-----|
| Agent not appearing in picker | Check `user-invocable` is not `false`; verify the file is in `.github/agents/` |
| Subagent not found by Orchestrator | Add agent `name` to Orchestrator's `agents:` list |
| YAML parse error (silent) | Escape colons in `description` with quotes; use spaces not tabs |
| Agent does too much | Split into two agents with a handoff |

---

## Adding a New Skill

1. **Create the folder** at `.github/skills/<skill-name>/`.

2. **Create `SKILL.md`**:
   ```yaml
   ---
   name: skill-name         # must match folder name exactly
   description: "What this skill does. Use when <trigger phrases>."
   argument-hint: "What to type after the slash command"
   ---
   ```

3. **Write the body**:
   - When to use (bullet list of triggers)
   - Procedure (numbered steps with commands)
   - Output (what the skill produces)

4. **Add referenced assets** in subdirectories:
   ```
   .github/skills/my-skill/
     SKILL.md
     scripts/run-something.sh
     references/api-spec.md
     assets/template.md
   ```
   Reference them with relative paths: `[script](./scripts/run-something.sh)`.

5. **Test discovery**: type `/` in VS Code chat and confirm the skill appears in the list.

### Skill vs Agent?

| | Skill | Agent |
|-|-------|-------|
| Bundled scripts/templates | ✅ | ❌ |
| Different tool set per step | ❌ | ✅ |
| Appears as `/slash` command | ✅ | ❌ |
| Context isolation per invocation | ❌ | ✅ |

---

## Adding a New MCP Server

1. **Add an entry to `.vscode/mcp.json.example`**:
   ```json
   "_my-server": {
     "_about": "What this server does",
     "_enable": "Rename this key from '_my-server' to 'my-server' to activate.",
     "command": "npx",
     "args": ["-y", "@org/my-mcp-server"],
     "env": {
       "API_KEY": "${env:MY_API_KEY}"
     }
   }
   ```

2. **Use environment variables for secrets** — never hardcode values.

3. **Enable it locally**: copy/edit your `.vscode/mcp.json` (not the `.example` file) and rename the server key to remove the leading underscore.

4. **Expose it in an agent** by adding `<server-name>/*` to the agent's `tools` list:
   ```yaml
   tools: [read, search, my-server/*]
   ```

5. **Document the server** in this guide with:
   - What it provides
   - Which agents use it
   - Required environment variables (names only, not values)

### Available MCP Servers (preconfigured)

| Server | Purpose | Env var |
|--------|---------|---------|
| `github` | GitHub API (issues, PRs, code) | `GITHUB_TOKEN` |
| `filesystem` | Scoped local file access | none |
| `context7` | Library/API documentation | none |
| `playwright` | Browser automation | none |

---

## Adding a New Instruction File

1. **Create** `.github/instructions/<name>.instructions.md`.

2. **Write the frontmatter**:
   ```yaml
   ---
   description: "Use when <specific trigger>. Covers <topics>."
   applyTo: "src/**/*.ts"   # optional: auto-attach for these files
   ---
   ```
   Warning: `applyTo: "**"` loads the instruction into every chat request — use only if truly universal.

3. **Keep it focused**: one concern per file (style, testing, security, etc.).

4. **Use "Use when…" phrasing** in `description` so on-demand discovery works.

---

## Bootstrapping into a New Project

Minimum files to copy:

```
.github/
  copilot-instructions.md
  agents/
    orchestrator.agent.md
    explore.agent.md
    implementer.agent.md
    validator.agent.md
    reviewer.agent.md
  skills/
    explore-codebase/SKILL.md
    implement-slice/SKILL.md
    build-and-test/SKILL.md
    lint-and-typecheck/SKILL.md
    review-diff/SKILL.md
    write-task-artifact/SKILL.md
  instructions/
    handoff-artifacts.instructions.md
  prompts/
    new-task.prompt.md
    handoff.prompt.md
.vscode/
  mcp.json.example
  settings.json
tasks/
  README.md
  _template/
    plan.md
    exploration.md
    changes.md
    validation.md
    review.md
```

After copying:
1. Edit `.github/copilot-instructions.md` — add your project's architecture, build commands, and conventions.
2. Edit `.github/skills/build-and-test/SKILL.md` — replace placeholder commands with your actual `build` / `test` commands.
3. Edit `.github/skills/lint-and-typecheck/SKILL.md` — replace placeholder commands with your linter.
4. Enable specialist agents (`firmware-engineer`, `protocol-specialist`) if relevant.
5. Copy `.vscode/mcp.json.example` → `.vscode/mcp.json` and configure the servers you need.
