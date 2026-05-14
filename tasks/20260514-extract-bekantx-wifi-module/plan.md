# Plan

**Task ID**: 20260514-extract-bekantx-wifi-module  
**Created**: 2026-05-14  
**Status**: READY_FOR_IMPLEMENTATION

## Goal

Extract the WiFi Manager from the BekantX ESP32 firmware into a reusable ESP32/ESP-IDF module that can be published on GitHub and integrated into future projects without rebuilding the provisioning and connection logic from scratch.

## Work Packages

- [ ] WP-1: Isolate the reusable WiFi Manager public API and remove BekantX-specific application coupling.
- [ ] WP-2: Extract provisioning, credential storage, event types, and connection state-machine logic into a standalone ESP-IDF component/module layout.
- [ ] WP-3: Add packaging, documentation, configuration surface, and an example integration project so the module can be published and consumed from GitHub.
- [ ] WP-4: Validate the extracted module in a clean ESP32 sample project and record the publish/release workflow.

## Constraints

- The reusable module must target ESP32/ESP-IDF usage first; it does not need to be vendor-neutral beyond the ESP-IDF ecosystem in this task.
- The extracted module must not depend on BekantX application classes such as status indication, desk logic, MQTT service internals, or SPI-specific behaviour.
- Preserve the core user-facing WiFi-manager behaviour: stored credentials, auto-connect on boot, provisioning portal fallback, and reconnect with backoff.
- Publishing must be GitHub-friendly: clear repository structure, reusable license choice, README, usage instructions, and example configuration.
- No secrets, real WiFi credentials, or private broker information may be written into the repository or task artifacts.

## Out of Scope

- Extracting the BekantX MQTT service as part of the first WiFi Manager module release.
- Porting the module to non-ESP-IDF frameworks in this task.
- Carrying over BekantX-specific LED, SPI, desk-control, or Home Assistant integration logic.
- Designing a vendor-agnostic microcontroller networking layer outside ESP-IDF.

## Open Questions

- Which GitHub repository should host the extracted module: a new dedicated repository or a subfolder/module inside an existing repository?
- Should MQTT credential passthrough remain part of v1, or should the first release focus strictly on WiFi provisioning and connection management?
- Should deep-sleep behaviour remain part of v1, or be deferred until the base module is proven reusable?
- What naming should the published module use (`esp32-wifi-manager`, `idf-wifi-manager`, etc.)?

## Next Phase

Explore → write `exploration.md`
