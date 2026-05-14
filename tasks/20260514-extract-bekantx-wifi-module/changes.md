# Changes

**Task ID**: 20260514-extract-bekantx-wifi-module  
**Phase**: IMPLEMENT  
**Implementer run**: <!-- YYYY-MM-DD HH:MM UTC -->  
**Work Package**: <!-- WP-N from plan.md -->

## Summary

<!-- One paragraph: what was changed and why. -->

## Files Modified

| File | Change type | Summary |
|------|------------|---------|
| `src/example.ts` | modified | |

## Key Decisions

<!-- Any implementation decisions that deviate from or go beyond plan.md. Explain the reasoning. -->

- 

## Diff Highlights

<!-- Paste or describe the most important diff sections — the ones a reviewer must understand. -->

```diff
// key change here
```

## Formatter Run

- [ ] Formatter executed on all modified files

## Open Questions / Deferred Items

<!-- Anything that could not be addressed in this work package. -->

- 

## Next Phase

Validate → write `validation.md`

## Update — 2026-05-14

**Implementer run**: 2026-05-14 00:00 UTC  
**Work Package**: WP-1

### Summary

Created the first standalone scaffold in the target repository `MootSeeker/ESP32-WiFiManager` to establish a reusable ESP-IDF component boundary and a BekantX-independent public API. The first slice intentionally focuses on structure and integration seams before porting the full WiFi/provisioning runtime.

### Files Modified

| File | Change type | Summary |
|------|------------|---------|
| `README.md` | modified | Replaced placeholder repository description with module scope, goals, and layout. |
| `CMakeLists.txt` | added | Added ESP-IDF component registration for the standalone module. |
| `idf_component.yml` | added | Added component metadata for packaging and dependency declaration. |
| `include/esp32_wifi_manager/WifiManagerTypes.hpp` | added | Added reusable public state/config/credential types. |
| `include/esp32_wifi_manager/WifiManager.hpp` | added | Added decoupled public class API using callbacks instead of product-specific dependencies. |
| `src/WifiManager.cpp` | added | Added initial implementation skeleton with lifecycle/state handling. |
| `examples/basic/main/main.cpp` | added | Added a minimal example integration entry point. |

### Key Decisions

- Started with a component scaffold instead of copying BekantX files directly, because the source implementation is still coupled to `StatusIndicator`, MQTT credential storage, and BekantX provisioning assets.
- Introduced callback-based state notification as the first reusable integration seam.
- Kept the initial implementation intentionally minimal so the public API can stabilise before the full ESP-IDF runtime logic is transplanted.

### Diff Highlights

```diff
+ include/esp32_wifi_manager/WifiManager.hpp
+ src/WifiManager.cpp
+ examples/basic/main/main.cpp
```

### Formatter Run

- [x] Formatter executed on all modified files

### Open Questions / Deferred Items

- The actual BekantX provisioning portal, credential store, and ESP-IDF event-driven state machine still need to be ported into this scaffold.
- MQTT passthrough fields from BekantX remain explicitly deferred from the first extraction slice.

## Update — 2026-05-14

**Implementer run**: 2026-05-14 00:00 UTC  
**Work Package**: WP-2

### Summary

Ported the BekantX credential persistence slice into the standalone module as a reusable NVS-backed `WifiCredentialStore`. This establishes the first real runtime service behind the scaffolded API and keeps credential handling independent from the still-deferred WiFi state machine and provisioning flow.

### Files Modified

| File | Change type | Summary |
|------|------------|---------|
| `CMakeLists.txt` | modified | Registered the new credential-store source file and added the `log` dependency used by ESP-IDF logging. |
| `include/esp32_wifi_manager/WifiCredentialStore.hpp` | added | Added the public credential-store interface with `Load`, `Save`, and `Clear` operations. |
| `src/WifiCredentialStore.cpp` | added | Added NVS-backed persistence for SSID/password storage using ESP-IDF `nvs_*` APIs. |

### Key Decisions

- Kept the store as a separate reusable class instead of wiring it into `WifiManager` immediately, so the persistence slice can be validated independently before the queue/state-machine port.
- Used the existing public `WifiCredentials` type so persistence and manager logic share one data contract.
- Made the NVS namespace configurable via constructor with a safe default (`wifi_mgr`) instead of introducing a Kconfig dependency in the extracted module's public API.

### Diff Highlights

```diff
+ include/esp32_wifi_manager/WifiCredentialStore.hpp
+ src/WifiCredentialStore.cpp
~ CMakeLists.txt
```

### Formatter Run

- [x] Formatter executed on all modified files

### Open Questions / Deferred Items

- `WifiManager` does not consume `WifiCredentialStore` yet; the next slice should wire persistence into startup/provisioning transitions.
- BekantX-specific namespace configuration via `CONFIG_WIFI_MGR_NVS_NAMESPACE` remains intentionally deferred until the module's configuration model is defined.

## Update — 2026-05-14

**Implementer run**: 2026-05-14 00:00 UTC  
**Work Package**: WP-2

### Summary

Wired the extracted credential store into `WifiManager::Start()` so the module now makes its initial runtime decision from persisted WiFi credentials: stored credentials lead to the connect path, while missing credentials fall back to the provisioning portal. This is the first functional bridge between the scaffolded manager API and the extracted runtime services.

### Files Modified

| File | Change type | Summary |
|------|------------|---------|
| `include/esp32_wifi_manager/WifiManager.hpp` | modified | Added private storage for active credentials and tracked whether credentials were loaded from NVS. |
| `src/WifiManager.cpp` | modified | Changed startup logic to load credentials through `WifiCredentialStore` and choose `kConnecting` vs `kPortal` accordingly. |
| `src/WifiCredentialStore.cpp` | modified | Added defensive zero-initialisation on load and a null-safe fallback for the NVS namespace. |

### Key Decisions

- Kept the integration at startup-state selection only; the manager still does not perform the real ESP-IDF connect flow until the event/queue state machine is ported.
- Stored credentials are cached inside `WifiManager` now so the later connect implementation can reuse the same data instead of reloading from NVS again.
- `ForceProvisioning()` continues to override stored credentials without deleting them, matching the expected operational behaviour for a temporary provisioning reset.

### Diff Highlights

```diff
~ include/esp32_wifi_manager/WifiManager.hpp
~ src/WifiManager.cpp
~ src/WifiCredentialStore.cpp
```

### Formatter Run

- [x] Formatter executed on all modified files

### Open Questions / Deferred Items

- `kConnecting` is still only a state transition; the actual ESP-IDF station connect sequence and retry handling remain to be ported.
- The next extraction slice should add the queue/event boundary (`wifi_mgr_event` equivalent) so WiFi, portal, and credential-save events can drive one dispatcher.

## Update — 2026-05-14

**Implementer run**: 2026-05-14 00:00 UTC  
**Work Package**: WP-3

### Summary

Added the missing ESP-IDF application CMake scaffolding under `examples/basic` so the repository now contains a structurally valid example app alongside the reusable component. This does not remove the external toolchain dependency, but it eliminates the repository-local build blocker that previously prevented any real example build attempt.

### Files Modified

| File | Change type | Summary |
|------|------------|---------|
| `examples/basic/CMakeLists.txt` | added | Added the top-level ESP-IDF project definition and pointed `EXTRA_COMPONENT_DIRS` at the reusable component root. |
| `examples/basic/main/CMakeLists.txt` | added | Added component registration for the example app entry point and declared the WiFi manager component dependency. |

### Key Decisions

- Kept the example app minimal and focused on buildability instead of adding product-specific runtime behaviour.
- Reused the component directly from the repository root via `EXTRA_COMPONENT_DIRS` so the example exercises the same extracted module layout that downstream users will consume.

### Diff Highlights

```diff
+ examples/basic/CMakeLists.txt
+ examples/basic/main/CMakeLists.txt
```

### Formatter Run

- [x] Formatter executed on all modified files

### Open Questions / Deferred Items

- The example app still depends on a locally installed ESP-IDF environment (`idf.py` and `IDF_PATH`) before it can be built.
- Runtime example behaviour remains intentionally minimal until the actual WiFi connection and provisioning loop are ported.

## Update — 2026-05-14

**Implementer run**: 2026-05-14 00:00 UTC  
**Work Package**: WP-2

### Summary

Added the first generic event boundary to `WifiManager` by introducing public manager events for provisioning requests and credential submission. This mirrors the architecture discovered in BekantX, where HTTP handlers and ESP-IDF callbacks hand off events to the manager instead of mutating state directly.

### Files Modified

| File | Change type | Summary |
|------|------------|---------|
| `include/esp32_wifi_manager/WifiManagerTypes.hpp` | modified | Added public `WifiManagerEventType` and `WifiManagerEvent` types. |
| `include/esp32_wifi_manager/WifiManager.hpp` | modified | Added `DispatchEvent()` as the manager's first neutral event-ingress API. |
| `src/WifiManager.cpp` | modified | Implemented event handling for provisioning requests and provisioned credentials, including credential persistence and transition back to `kConnecting`. |

### Key Decisions

- Started with only the two event types already justified by the extracted control flow: provisioning request and credentials received.
- Kept the event API synchronous for now; the later FreeRTOS queue can target the same boundary without changing the manager's core state transition logic.
- Reused `WifiCredentialStore` inside the event path so the future portal flow persists credentials through the same code path as the startup loader.

### Diff Highlights

```diff
~ include/esp32_wifi_manager/WifiManagerTypes.hpp
~ include/esp32_wifi_manager/WifiManager.hpp
~ src/WifiManager.cpp
```

### Formatter Run

- [x] Formatter executed on all modified files

### Open Questions / Deferred Items

- The manager still lacks the actual asynchronous queue, ESP-IDF event adapters, and retry/backoff logic around these events.
- Additional event types for connection success/failure and stop/shutdown should be added only when the corresponding runtime paths are ported.

## Update — 2026-05-14

**Implementer run**: 2026-05-14 00:00 UTC  
**Work Package**: WP-2

### Summary

Ported the next state-machine slice by adding explicit connection success/failure events, bounded retry tracking, and fallback to portal mode after the configured retry threshold. To keep this logic testable outside ESP-IDF, the retry and transition rules now live in a dedicated `WifiManagerStateMachine` class, and a small host-side regression test target has been added for future execution once a compiler is available.

### Files Modified

| File | Change type | Summary |
|------|------------|---------|
| `CMakeLists.txt` | modified | Added the state-machine source file to the ESP-IDF component build. |
| `include/esp32_wifi_manager/WifiManagerTypes.hpp` | modified | Added connection success/failure event types to the public event contract. |
| `include/esp32_wifi_manager/WifiManager.hpp` | modified | Wired the manager to the reusable state machine helper. |
| `include/esp32_wifi_manager/WifiManagerStateMachine.hpp` | added | Added a testable state-machine abstraction for retry and transition rules. |
| `src/WifiManager.cpp` | modified | Delegated start/provisioning/connect/failure transitions to the state machine. |
| `src/WifiManagerStateMachine.cpp` | added | Implemented retry counting, success reset, and portal fallback behaviour. |
| `tests/CMakeLists.txt` | added | Added a host-side test target definition for the state machine. |
| `tests/WifiManagerStateMachine.test.cpp` | added | Added regression coverage for retry threshold and reset behaviour. |

### Key Decisions

- Extracted transition logic into a dedicated class before adding more runtime paths, so subsequent ESP-IDF event integration can stay thin and the core behaviour remains testable.
- Kept retry handling synchronous and state-only for now; exponential backoff timing remains deferred until the actual WiFi task/event loop exists.
- Moved the state-machine header onto the exported include path so `WifiManager.hpp` does not depend on a private `src/` header.

### Diff Highlights

```diff
+ include/esp32_wifi_manager/WifiManagerStateMachine.hpp
+ src/WifiManagerStateMachine.cpp
+ tests/WifiManagerStateMachine.test.cpp
~ include/esp32_wifi_manager/WifiManagerTypes.hpp
~ include/esp32_wifi_manager/WifiManager.hpp
~ src/WifiManager.cpp
```

### Formatter Run

- [x] Formatter executed on all modified files

### Open Questions / Deferred Items

- Retry timing/backoff is still policy-only; there is no timer-driven reconnect scheduling yet.
- The manager still needs the asynchronous event queue and ESP-IDF adapters that will emit these new connection outcome events.
- The new host-side tests are prepared but cannot yet run in this environment because no host C++ compiler is installed.

## Update — 2026-05-14

**Implementer run**: 2026-05-14 00:00 UTC  
**Work Package**: WP-2

### Summary

Added the next handoff slice by introducing a small FIFO `WifiManagerEventQueue` and wiring `WifiManager` with `EnqueueEvent()` and `ProcessNextEvent()`. This gives future HTTP handlers, WiFi callbacks, or task loops a neutral buffering boundary that matches the explored BekantX architecture without pulling FreeRTOS queue dependencies into the module yet.

### Files Modified

| File | Change type | Summary |
|------|------------|---------|
| `include/esp32_wifi_manager/WifiManagerEventQueue.hpp` | added | Added a fixed-capacity FIFO event queue for manager events. |
| `include/esp32_wifi_manager/WifiManager.hpp` | modified | Added enqueue/process APIs and tracked pending events through the manager. |
| `src/WifiManager.cpp` | modified | Cleared the queue on lifecycle boundaries and routed queued events through `DispatchEvent()`. |
| `tests/WifiManagerStateMachine.test.cpp` | modified | Extended host-side tests to cover FIFO ordering and queue capacity behaviour. |

### Key Decisions

- Kept the queue header-only and dependency-free so it stays usable from both host-side tests and the ESP-IDF component without extra runtime glue.
- Preserved `DispatchEvent()` as the direct synchronous path while adding queued ingress APIs, which keeps current behaviour intact and lets later runtime code adopt the queue incrementally.
- Cleared queued events on `Init()` and `Stop()` so stale portal or connection events cannot leak across lifecycle restarts.

### Diff Highlights

```diff
+ include/esp32_wifi_manager/WifiManagerEventQueue.hpp
~ include/esp32_wifi_manager/WifiManager.hpp
~ src/WifiManager.cpp
~ tests/WifiManagerStateMachine.test.cpp
```

### Formatter Run

- [x] Formatter executed on all modified files

### Open Questions / Deferred Items

- The queue is still polled manually; it is not yet backed by a task loop or FreeRTOS event source.
- The actual ESP-IDF WiFi and provisioning adapters still need to enqueue real connection and credential events into this boundary.

## Update — 2026-05-14

**Implementer run**: 2026-05-14 00:00 UTC  
**Work Package**: WP-2

### Summary

Added the bounded reconnect backoff policy identified during exploration to the extracted state machine. Connection failures now produce a recommended retry delay derived from configuration, with exponential growth between attempts and saturation at a configured maximum. The public manager API exposes the current delay so a later task loop or ESP-IDF timer can schedule reconnect attempts without re-deriving policy outside the state machine.

### Files Modified

| File | Change type | Summary |
|------|------------|---------|
| `include/esp32_wifi_manager/WifiManagerTypes.hpp` | modified | Added configuration fields for initial and maximum reconnect delay. |
| `include/esp32_wifi_manager/WifiManagerStateMachine.hpp` | modified | Added reconnect-delay tracking and accessor methods to the state machine API. |
| `include/esp32_wifi_manager/WifiManager.hpp` | modified | Exposed the current recommended reconnect delay through the manager. |
| `src/WifiManagerStateMachine.cpp` | modified | Implemented exponential backoff calculation, saturation, and reset semantics. |
| `src/WifiManager.cpp` | modified | Routed connection-failure events through the new backoff-aware state-machine API. |
| `tests/WifiManagerStateMachine.test.cpp` | modified | Added regression coverage for reconnect delay growth, reset, and max-delay saturation. |

### Key Decisions

- Kept backoff policy computation inside the state machine so retries, portal fallback, and delay resets remain one coherent behavioural surface.
- Exposed only the resulting recommended delay, not a timer or scheduler, because runtime orchestration still belongs to the later ESP-IDF task/event layer.
- Reset reconnect delay on success, provisioning, stop, and portal fallback so stale timing state cannot leak across lifecycle transitions.

### Diff Highlights

```diff
~ include/esp32_wifi_manager/WifiManagerTypes.hpp
~ include/esp32_wifi_manager/WifiManagerStateMachine.hpp
~ include/esp32_wifi_manager/WifiManager.hpp
~ src/WifiManagerStateMachine.cpp
~ src/WifiManager.cpp
~ tests/WifiManagerStateMachine.test.cpp
```

### Formatter Run

- [x] Formatter executed on all modified files

### Open Questions / Deferred Items

- The reconnect delay is policy-only until a later runtime layer actually waits/schedules between attempts.
- The extracted module still lacks the ESP-IDF task loop or timer integration that will consume the recommended delay value.
