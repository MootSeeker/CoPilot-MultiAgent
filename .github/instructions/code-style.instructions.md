---
description: "Use when writing, reviewing, or refactoring source code. Covers naming conventions, formatting, import order, and language-specific style rules. Customize the placeholder sections for your project's languages and tooling."
applyTo: ["src/**", "lib/**", "app/**", "tests/**"]
---

# Code Style

> **Project teams**: replace the placeholder sections below with your actual conventions.
> Reference your formatter config files (e.g. `.prettierrc`, `pyproject.toml`, `.clang-format`) rather than duplicating their content here.

## General Principles

- Favour readability over cleverness.
- One concern per function/method. Split when a function exceeds ~40 lines.
- Prefer explicit over implicit (explicit types, explicit error handling).
- Delete dead code; do not comment it out.

## Naming

| Construct | Convention | Example |
|-----------|-----------|---------|
| Variables & functions | `camelCase` (JS/TS) / `snake_case` (Python/C) | `parseFrame`, `parse_frame` |
| Classes & types | `PascalCase` | `FrameParser` |
| Constants | `UPPER_SNAKE_CASE` | `MAX_RETRY_COUNT` |
| Files | `kebab-case` | `frame-parser.ts` |

> Adjust the table above for your language(s).

## Imports / Includes

- Group imports: stdlib → third-party → local (blank line between groups).
- No unused imports. Linter should enforce this.
- Use absolute imports from the project root when available.

## Formatting

- **Indentation**: 2 spaces (JS/TS) / 4 spaces (Python) / 4 spaces (C/C++).
- **Line length**: 120 characters max.
- **Trailing commas**: yes in multi-line expressions (JS/TS).
- Run the project formatter before committing. See the `build-and-test` skill for the exact command.

## Error Handling

- Never swallow errors silently (`catch {}` or bare `except: pass`).
- Log the original error at the catch site before re-throwing or wrapping.
- Return typed error objects or use Result types; avoid magic error codes.

## Comments

- Write comments for *why*, not *what*. Code explains what; comments explain intent.
- Keep inline comments short (one line preferred).
- Remove TODO comments before merging — convert them to tracked issues.

## Language-Specific Rules

### TypeScript / JavaScript

<!-- Uncomment and fill in:
- Use `strict: true` in tsconfig.json.
- Prefer `const` over `let`; never `var`.
- Use optional chaining `?.` and nullish coalescing `??` over manual null checks.
-->

### Python

<!-- Uncomment and fill in:
- Follow PEP 8.
- Use type hints for all public functions.
- Use `pathlib.Path` over `os.path`.
-->

### C / C++

<!-- Uncomment and fill in:
- Follow the project's .clang-format config.
- Use `static` for file-local functions.
- Free all allocated memory; document ownership in comments.
-->
