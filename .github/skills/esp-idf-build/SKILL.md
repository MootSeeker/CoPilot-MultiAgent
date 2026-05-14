---
name: esp-idf-build
description: "Build and flash an ESP-IDF firmware project. Use when compiling ESP-IDF firmware, checking that a firmware change compiles for the target chip, running ESP-IDF component unit tests, or flashing a device. Example specialist skill for embedded/firmware projects."
argument-hint: "Optional: target chip, e.g. esp32s3 or esp32c6"
---

# ESP-IDF Build

Build, test, and optionally flash an ESP-IDF firmware project.

## When to Use

- Verifying a firmware change compiles cleanly.
- Running component unit tests.
- Flashing a development board during debugging.

## Prerequisites

- ESP-IDF installed and `idf.py` on `PATH` (or activate with `. $IDF_PATH/export.sh`).
- Target chip configured (`CONFIG_IDF_TARGET` in `sdkconfig` or via `-DIDF_TARGET=`).
- USB connection to the device (for flash/monitor only).

## Procedure

### Step 1 — Activate IDF environment

```bash
# Linux / macOS
. $IDF_PATH/export.sh

# Windows (PowerShell)
. $env:IDF_PATH\export.ps1
```

### Step 2 — Set the target (first time or when changing chip)

```bash
idf.py set-target esp32s3   # replace with your target
```

### Step 3 — Build

```bash
idf.py build
```

Expected output on success:
```
Project build complete. To flash, run:
 idf.py flash
```

Record the binary size (from `idf.py size`) in `validation.md` for reference.

### Step 4 — Run component unit tests (optional)

If the component has a `test/` subdirectory with a CMakeLists.txt test app:

```bash
cd components/<component>/test
idf.py build
idf.py flash monitor   # requires connected device
```

For host-based tests (not all components support this):

```bash
idf.py -T components/<component> test
```

### Step 5 — Record results in validation.md

Build section:
```
Command: idf.py build
Result:  PASS / FAIL
Binary:  <size from idf.py size>
Output excerpt: <last 20 lines or error output>
```

### Step 6 — Flash (optional, only during development)

```bash
idf.py -p /dev/ttyUSB0 flash monitor
```

> Flashing requires explicit user confirmation — it writes to a physical device.

## Common Failures

| Error | Likely cause | Fix |
|-------|-------------|-----|
| `Component X not found` | Missing dependency in `CMakeLists.txt` | Add to `REQUIRES` or `PRIV_REQUIRES` |
| `Undefined reference to ...` | Missing source file in `COMPONENT_SRCS` | Add file to component CMakeLists.txt |
| `IRAM overflow` | Too much code placed in IRAM | Remove `IRAM_ATTR` from non-critical functions |
| `Stack overflow` | Task stack too small | Increase `configMINIMAL_STACK_SIZE` for the task |
| `sdkconfig mismatch` | Config stale after target change | Run `idf.py fullclean` then rebuild |

## Notes

- Always run `idf.py build` before flashing to catch compile errors without touching hardware.
- Use `idf.py size-components` to identify which components are largest when fighting binary size limits.
- Adapt the port (`/dev/ttyUSB0`, `COM3`, etc.) to your host OS and device.
