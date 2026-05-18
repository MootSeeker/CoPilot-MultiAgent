#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$repo_root"

required_files=(
  "README.md"
  ".gitignore"
  ".github/copilot-instructions.md"
  ".vscode/mcp.json.example"
  "docs/architecture.md"
  "docs/task-lifecycle.md"
  "docs/agent-roles.md"
  "docs/customization-guide.md"
  "tasks/README.md"
  "tasks/_template/plan.md"
  "tasks/_template/exploration.md"
  "tasks/_template/changes.md"
  "tasks/_template/validation.md"
  "tasks/_template/review.md"
)

for path in "${required_files[@]}"; do
  if [[ ! -f "$path" ]]; then
    echo "Missing required scaffold file: $path" >&2
    exit 1
  fi
done

if ! grep -Fq "meta-template" README.md; then
  echo "README.md must describe the repository as a meta-template." >&2
  exit 1
fi

if ! grep -Fq "cp -r docs/ /path/to/your-project/" README.md; then
  echo "README.md must instruct users to copy docs/." >&2
  exit 1
fi

if ! grep -Fq "tasks/README.md" README.md; then
  echo "README.md must instruct users to copy tasks/README.md." >&2
  exit 1
fi

if ! grep -Fq ".vscode/mcp.json" .gitignore; then
  echo ".gitignore must ignore .vscode/mcp.json." >&2
  exit 1
fi

if ! grep -Fq 'copy the companion `docs/` folder' .github/copilot-instructions.md; then
  echo ".github/copilot-instructions.md must explain the docs/ dependency." >&2
  exit 1
fi

if ! grep -Fq "The first owner write may replace the copied template content in place." .github/prompts/handoff.prompt.md; then
  echo ".github/prompts/handoff.prompt.md must describe the initial template seed rule." >&2
  exit 1
fi

if ! grep -Fq "The lifecycle has two modes:" .github/skills/write-task-artifact/SKILL.md; then
  echo ".github/skills/write-task-artifact/SKILL.md must distinguish initial seeding from later append-only updates." >&2
  exit 1
fi

shopt -s nullglob
workflow_files=(.github/workflows/*.yml .github/workflows/*.yaml)
shopt -u nullglob

if [[ ${#workflow_files[@]} -eq 0 ]]; then
  echo "At least one GitHub Actions workflow is expected." >&2
  exit 1
fi

for workflow in "${workflow_files[@]}"; do
  if ! grep -Eq '^[[:space:]]*pull_request:[[:space:]]*$' "$workflow"; then
    echo "Workflow must trigger on pull_request only: $workflow" >&2
    exit 1
  fi

  if grep -Eq '^[[:space:]]*push:[[:space:]]*$' "$workflow"; then
    echo "Workflow must not trigger on push: $workflow" >&2
    exit 1
  fi
done

echo "Scaffold validation passed."