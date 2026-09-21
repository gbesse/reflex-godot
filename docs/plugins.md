# Extending Reflex

This guide describes the implemented Godot resource, runtime and decision adapter boundaries.

`ReflexBehaviorPack` is a Resource with `instructions`, `minimum_probability` and `model`. Create one from the Reflex dock, edit it in the Inspector and save it as a `.tres` resource. To use a saved pack in your scene, load it and pass it to `adapter.choose(world, actor_id, available, behavior)`. The bundled playground constructs its default resource in code.

The adapter emits `decision_ready(action_id, revision, probability)` or `decision_failed(message)`. Consume success by calling the authoritative runtime's `apply`; never directly mutate resources based on a model reply. Handle every failure visibly and connect production alerting in your application. The standalone example has no administrator email configuration.

The runtime's finite actions currently cover wait, rest, greet and sell in the included fixed market. To add actions, update both action availability and guarded effects, then add conservation and replay tests. There is no arbitrary script execution from model output, dynamic action loading or universal world schema in this release. A separate provider can implement the same signal contract; preserve the requested revision when returning asynchronous decisions.

Replay starts from this demo's fixed initial state and compares each event's complete resulting state. Keep a journal per uninterrupted runtime; persist it yourself if needed. A reset discards the in-memory journal. Replay is not a cryptographic attestation and does not validate live model decisions.

Custom GDScript is trusted code. For a shipped game, implement a server-side gateway rather than distribute a provider key. Explicit deadlines and resource bounds remain required for any replacement transport.
