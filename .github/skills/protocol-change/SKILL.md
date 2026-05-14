---
name: protocol-change
description: "Safely implement a change to a wire protocol, message format, serialisation schema, or API contract. Use when modifying data structures exchanged between components, changing codec logic, or updating a protocol version. Ensures backwards compatibility analysis, golden fixtures, and round-trip testing. Example specialist skill."
argument-hint: "Protocol name and change description, e.g. 'MQTT telemetry frame — add timestamp field'"
---

# Protocol Change

Safe procedure for modifying wire protocols, message schemas, and codec implementations.

## When to Use

- Adding, removing, or renaming fields in a message format.
- Changing serialisation/deserialisation logic.
- Updating an API contract (REST, gRPC, WebSocket, custom binary).
- Any change where two sides of a communication channel must stay compatible.

## Procedure

### Step 1 — Backwards-compatibility analysis

Before writing a line of code, document in `exploration.md`:

1. **Who sends and who receives** the message format.
2. **All known versions** of senders and receivers that are deployed.
3. **Impact of the proposed change** on each version combination:

   | Change | Existing senders | Existing receivers |
   |--------|-----------------|-------------------|
   | Add optional field | ✅ no change needed | ✅ ignore unknown fields |
   | Remove field | ❌ may break | ❌ may break |
   | Change field type | ❌ breaks | ❌ breaks |

4. **Migration path**: how will old and new versions coexist during rollout?

### Step 2 — Version bump strategy

Choose one:
- **Additive (no bump needed)**: new field is optional; old receivers silently ignore it.
- **Minor version bump**: new field is required but old senders can omit it (receiver must handle absence).
- **Major version bump**: breaking change; negotiation or simultaneous deployment required.

Document the choice in `plan.md` or `exploration.md`.

### Step 3 — Update golden fixtures

Golden fixtures are pairs of: known byte/JSON/binary input ↔ expected decoded struct.

1. Add a fixture for the **new** format.
2. Keep all existing fixtures — they test backwards compatibility.
3. If removing support for an old format, move the fixture to an `archived/` subfolder and note the version it was removed in.

Fixture location (adapt to your project):
```
tests/fixtures/protocol/<protocol-name>/
  v1_baseline.json
  v2_new_field.json
```

### Step 4 — Implement codec changes

1. Update the struct / schema definition.
2. Update the encoder: write new fields.
3. Update the decoder: handle both old (field absent) and new (field present) inputs.
4. Update error messages to reference the protocol version.

### Step 5 — Round-trip test

Add a property-based or parametric test:

```
for each fixture:
  decoded = decode(fixture.bytes)
  re_encoded = encode(decoded)
  assert re_encoded == fixture.bytes  # or structural equality
```

### Step 6 — Document the change

- Update the protocol specification document (if one exists).
- Update `changes.md` with a diff highlight of the codec change.
- Note the version bump in `changes.md`.

## Output

- Updated codec source file(s)
- New golden fixture file(s)
- Updated or new round-trip test(s)
- `changes.md` with protocol version noted
