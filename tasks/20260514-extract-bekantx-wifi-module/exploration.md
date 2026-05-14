# Exploration

**Task ID**: 20260514-extract-bekantx-wifi-module  
**Phase**: EXPLORE  
**Explore Agent run**: 2026-05-14 00:00 UTC

## Affected Files

| File | Role | Notes |
|------|------|-------|
| `Firmware/ESP32C3/BekantX/components/bekantx_application/include/application/wifi/WifiManager.hpp` | Primary public API | Defines `WifiManager`, `WifiState`, task model, state machine, and current external dependencies. |
| `Firmware/ESP32C3/BekantX/components/bekantx_application/src/wifi/WifiManager.cpp` | Primary implementation | Contains init/start logic, FreeRTOS task loop, ESP-IDF event bridging, STA/AP provisioning transitions, backoff, and optional deep-sleep path. |
| `Firmware/ESP32C3/BekantX/components/bekantx_application/include/application/wifi/WifiCredentialStore.hpp` | Reusable credential store API | Plain credential struct + storage interface suitable for extraction. |
| `Firmware/ESP32C3/BekantX/components/bekantx_application/src/wifi/WifiCredentialStore.cpp` | Reusable credential persistence | NVS-backed credential load/save/clear implementation. |
| `Firmware/ESP32C3/BekantX/components/bekantx_libs/include/libs/provisioning/wifi_mgr_event.h` | Shared C/C++ event boundary | Queue payload type passed from portal handlers into `WifiManager`. |
| `Firmware/ESP32C3/BekantX/components/bekantx_libs/include/libs/provisioning/captive_portal_http.h` | Provisioning portal API | HTTP server start/stop API used by `WifiManager` in portal mode. |
| `Firmware/ESP32C3/BekantX/components/bekantx_libs/src/provisioning/captive_portal_http.c` | Provisioning implementation | Serves portal UI, scans APs, receives credentials, posts queue events. |
| `Firmware/ESP32C3/BekantX/components/bekantx_libs/src/provisioning/dns_hijack.c` | Captive-portal support | DNS hijack helper started/stopped by `WifiManager` in portal mode. |
| `Firmware/ESP32C3/BekantX/components/bekantx_libs/assets/portal.html` | Provisioning UI asset | Embedded captive-portal page; currently BekantX-branded and German-language. |
| `Firmware/ESP32C3/BekantX/components/bekantx_application/CMakeLists.txt` | Current component packaging | Shows direct component-level dependencies on drivers, libs, mqtt, and ESP-IDF libs. |
| `Firmware/ESP32C3/BekantX/components/bekantx_libs/CMakeLists.txt` | Provisioning component packaging | Shows embedded asset and provisioning-related ESP-IDF dependencies. |
| `Firmware/ESP32C3/BekantX/components/bekantx_application/src/Application.cpp` | Current call site / integration point | Instantiates `WifiManager` together with `StatusIndicator` and `MqttCredentialStore`. |
| `Firmware/ESP32C3/BekantX/components/bekantx_mqtt/include/mqtt/MqttService.hpp` | Downstream integration surface | Confirms WiFi events currently trigger MQTT lifecycle coupling. |
| `Firmware/ESP32C3/BekantX/components/bekantx_mqtt/src/MqttService.cpp` | Downstream runtime dependency | Starts/stops MQTT on IP/WiFi events; indicates what should *not* live inside the reusable WiFi module. |
| `Firmware/ESP32C3/BekantX/APPLICATION_PLAN.md` | Requirements and intended decomposition | Documents the intended WiFi manager behaviour and original module boundaries. |

## Dependencies

- `WifiManager` directly depends on ESP-IDF WiFi, netif, event loop, sleep, NVS, FreeRTOS task/queue APIs.
- `WifiManager` depends on BekantX provisioning helpers:
  - `libs/provisioning/captive_portal_http.h`
  - `libs/provisioning/dns_hijack.h`
  - `libs/provisioning/wifi_mgr_event.h`
- `WifiManager` currently depends on BekantX application/MQTT types:
  - `application/StatusIndicator.hpp`
  - `mqtt/MqttCredentialStore.hpp`
- `WifiCredentialStore` is comparatively isolated and only depends on NVS + logging.
- `portal.html` is embedded through `EMBED_TXTFILES` in the provisioning component, so extraction must preserve the asset-embedding flow or replace it with an alternative packaging mechanism.
- The current BekantX component packaging couples WiFi logic to unrelated component groups (`bekantx_drivers`, `bekantx_mqtt`, `bekantx_libs`), which is the main structural blocker for publishing this as a standalone module.

## Control Flow

```text
BekantXApplication::Run()
→ WifiManager::Init(status, &mqtt_cred_store)
→ WifiManager::Start()
→ xTaskCreate(_task_entry)
→ WifiManager::_run_task()
→ store_.Load(creds) ? _enter_connecting(creds) : _enter_portal()
→ ESP-IDF event handlers post wifi_mgr_event_t into event_queue_
→ WifiManager::_dispatch_event(evt)
→ state transitions between kConnecting / kConnected / kPortal
→ portal_http_start + dns_hijack_start in provisioning mode
→ credential save event returns to _dispatch_event()
→ store_.Save(new_creds) + optional mqtt_store_->Save(...)
→ _enter_connecting(new_creds)
```

Key local behaviours identified:
- Boot path prefers stored credentials from NVS.
- Failed connect attempts follow bounded exponential backoff.
- Portal mode runs SoftAP + DNS hijack + HTTP server.
- Queue-based event handoff keeps HTTP and ESP-IDF event handlers out of the state-machine logic.
- Current implementation optionally enters deep sleep after repeated failures with stored credentials, which is likely v2 material for a reusable module.

## Test Coverage

- Covered by: no obvious dedicated WiFi-manager unit or integration tests were surfaced from the repository snippets.
- Coverage gaps:
  - state-machine transition tests
  - credential-store persistence tests
  - provisioning form parsing tests
  - reconnect backoff behaviour tests
  - packaging/integration test in a clean example project

## Risks

- The current `WifiManager` is not yet a clean module boundary because it depends on `StatusIndicator` and `MqttCredentialStore`; these must become optional callbacks/adapters or be removed from v1.
- `portal.html` is BekantX-branded and German-language; publishing as a reusable module likely requires neutral naming/text and maybe configurable branding.
- The portal currently accepts MQTT fields and passes them through the same form/event path; that broadens the module scope beyond WiFi and may make v1 harder to keep reusable.
- Deep-sleep behaviour is implementation-specific and currently uses target-specific wakeup branches; keeping it in the first release may overfit the module to BekantX assumptions.
- The module is currently split across two BekantX components (`bekantx_application`, `bekantx_libs`), so extraction requires a deliberate new component/repo structure, not a straight file copy.
- No visible standalone tests means extraction can regress silently unless a sample app and targeted tests are added during packaging.

## Open Questions

- Should the reusable module expose optional callback hooks for UI/status/MQTT integration, or should those concerns be excluded completely from the first public release?
- Should the portal UI stay embedded inside the component, or become an overridable asset/template surface?
- Should deep-sleep and wake-source policy be postponed until after the first reusable release?
- Should the first publication be an ESP-IDF component repository only, or also include Component Registry metadata if the publication target supports it?

## Next Phase

Implement → write `changes.md`
