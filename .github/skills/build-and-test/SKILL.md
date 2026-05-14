---
name: build-and-test
description: "Build the project and run the test suite. Use when validating a code change, checking that the project compiles, or verifying that all tests pass. Used by the Validator agent to produce validation.md. Customize the command placeholders for your project."
argument-hint: "Optional: specific test file or module to scope the run"
---

# Build and Test

Run the project build and test suite, capture results, and write them to `validation.md`.

## When to Use

- After every implementation to verify correctness.
- As part of the Validator agent's validation phase.
- When a reviewer requests a fresh test run.

## Customize for Your Project

> **Required setup**: Replace the placeholder commands below with your project's actual commands.
> Edit this SKILL.md file directly once you have bootstrapped the scaffold into your project.

## Procedure

### Step 1 — Install / verify dependencies

```bash
# JS/TS (Node.js)
npm ci

# Python
pip install -r requirements.txt

# Rust
cargo fetch

# ESP-IDF
# idf.py and toolchain must already be on PATH
# See the esp-idf-build skill for the full setup
```

### Step 2 — Build

Run the build command for your project:

```bash
# JS/TS
npm run build

# Python (type check + compile)
mypy src/
python -m py_compile src/**/*.py

# Rust
cargo build

# ESP-IDF
idf.py build

# C/C++ with CMake
cmake --build build/
```

Record: command used, exit code, and relevant output (errors + last 20 lines if successful).

### Step 3 — Run tests

Run only the tests relevant to the changed area:

```bash
# JS/TS — Jest, scoped to changed file
npx jest --testPathPattern="<changed-module>"

# Python — pytest, scoped to changed module
pytest tests/test_<changed_module>.py -v

# Rust
cargo test <module_name>

# Go
go test ./path/to/package/...
```

For a full suite run (e.g. pre-merge):

```bash
# JS/TS
npm test

# Python
pytest

# Rust
cargo test

# Go
go test ./...
```

Record: command used, number passed/failed, and any failure output.

### Step 4 — Record in validation.md

Fill in `tasks/<task-id>/validation.md`:
- Build section: command + result (PASS/FAIL)
- Tests section: command + counts + result (PASS/FAIL)
- Overall Verdict: PASS only if both pass

## Output

A `validation.md` with documented build and test results.
