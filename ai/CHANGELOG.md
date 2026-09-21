# AI changelog

This file records implementation and validation decisions for Reflex Godot.

## 2026-09-21 — v0.1.0 alpha

- Added a Godot 4.7 EditorDock addon, editable behavior Resource and runnable three-actor market.
- Added finite guarded effects, revision checks, resource conservation and journal replay.
- Added optional pinned Jev 1.13.0 HTTP choice adapter with explicit timeout, response bounds and failure signals.
- Kept provider keys in the local development environment; a production gateway is not included.
- Verified script loading, 510 runtime assertions, headless scene startup and the rendered playground in Godot 4.7.2.
- Added checksum-pinned Linux CI without game export/build. Live Jev inference has not been tested.
