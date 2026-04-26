# Context Snapshot

- Timestamp: 2026-04-22T08:41:32Z
- Task Slug: android-tnum-debug-project
- Context Type: greenfield

## Task Statement

Build a local Flutter debug project to validate Android numeric rendering behavior when `FontFeature.tabularFigures()` enables the OpenType `tnum` feature.

## Desired Outcome

Create an execution-ready project brief that can later drive a local debug app, device test matrix, screenshots, and a summary of font behavior differences across Android OEM devices and custom/system fonts.

## Stated Solution

The user proposed a dedicated local debug project with:
- rendering test cases for system and custom fonts
- side-by-side `tnum` on/off comparisons
- runtime device/debug metadata
- screenshots and a findings report

## Probable Intent Hypothesis

The underlying need is not only to build a demo app, but to produce a repeatable validation environment that can answer whether inconsistent digit alignment is caused by font support, Android fallback, OEM overrides, or Flutter rendering assumptions.

## Known Facts / Evidence

- The workspace currently contains only `.omx/` state files and no existing Flutter project files.
- No `pubspec.yaml`, `lib/`, or Dart source files are present in the repository root.
- The proposal assumes device-to-device variance, especially across OEM Android builds.
- The proposal names deliverables beyond code: screenshots, report, and production font strategy recommendation.

## Constraints

- Flutter commands must use the `fvm` prefix.
- Do not run build commands such as `fvm flutter build` or `fvm dart run build_runner build`.
- Prefer explicit parameters over default values in code.
- Exhaustive `switch` handling is preferred over `default`.
- Deep-interview mode must clarify intent and boundaries before planning or implementation.

## Unknowns / Open Questions

- Whether the first execution target is the debug app itself, the investigation workflow, or the production recommendation.
- Which outputs are mandatory for the first iteration versus later manual device-testing work.
- Whether the user wants this repo to stay as a disposable debug harness or evolve into a reusable internal validation tool.
- Which decisions Codex may make without asking during planning/execution.

## Decision-Boundary Unknowns

- Can the implementation pick the debug app structure, screens, fonts, and logging format without confirmation?
- Can the implementation add local sample assets/fonts if needed?
- Is screenshot capture/report generation part of the first delivery or a later human-run phase?

## Likely Codebase Touchpoints

- New Flutter app scaffold in this repository
- `pubspec.yaml`
- `lib/main.dart`
- potential `assets/fonts/`
- documentation under `README.md` or `.omx/specs/`
