# PRD: Android Tnum Debug Project

## Metadata

- Slug: `android-tnum-debug-project`
- Source Spec: [deep-interview-android-tnum-debug-project.md](/Users/wingchan/Project/flutter_tnum_font/.omx/specs/deep-interview-android-tnum-debug-project.md)
- Context Snapshot: [android-tnum-debug-project-20260422T084132Z.md](/Users/wingchan/Project/flutter_tnum_font/.omx/context/android-tnum-debug-project-20260422T084132Z.md)
- Planning Timestamp: `2026-04-22T09:05:28Z`
- Workflow: `ralplan`

## RALPLAN-DR Summary

### Principles

1. Prefer evidence over guesses for font attribution.
2. Make uncertainty explicit with `inconclusive`, never with a likely-but-unproven font name.
3. Keep v1 manual-first and inspection-first.
4. Use the lightest Flutter app structure that satisfies Android validation needs.
5. Avoid new dependencies unless they are strictly necessary.

### Decision Drivers

1. The user needs a practical way to investigate which fonts Android devices actually use for numeric rendering.
2. Android may not expose the final resolved font directly, so the app must present an evidence chain rather than false certainty.
3. The repository is greenfield, so the first delivery should optimize for speed and inspectability, not product polish.

### Viable Options

#### Option A: Single debug app with one investigation screen plus Android native evidence bridge

Pros:
- Smallest path to a usable result in a greenfield repo
- Keeps all required outputs visible in one place
- Supports strict evidence flow without overbuilding

Cons:
- Evidence fidelity depends on what Android exposes through native code and readable system files
- A single screen can become dense if not organized carefully

#### Option B: Multi-screen app with automated collection, screenshot capture, and report generation

Pros:
- More complete workflow if later expanded into a QA tool
- Better for repeated internal regression runs

Cons:
- Violates explicit v1 non-goals
- Adds substantial implementation surface before the core investigation path is proven

#### Option C: Native Android probe first, Flutter visualization later

Pros:
- Could expose lower-level Android details earlier
- Might simplify some device metadata gathering

Cons:
- Breaks the user's requested Flutter-first debug project path
- Splits the workflow into two tools instead of one

### Chosen Option

Choose **Option A**.

Reason:
- It is the smallest plan that satisfies the clarified acceptance criteria.
- It preserves a single local tool for on-device investigation.
- It can still surface strict `inconclusive` behavior when platform evidence is insufficient.

## ADR

- Decision: Build a Flutter Android debug app with a single investigation-focused flow backed by a small Android native bridge for device/font evidence.
- Drivers:
  - Need visible on-device comparison for `tnum on/off`
  - Need candidate font/evidence output rather than visual output alone
  - Need explicit `inconclusive` handling
  - Need a minimal greenfield implementation path
- Alternatives Considered:
  - Fully automated multi-screen QA tool
  - Native Android tool plus separate Flutter viewer
- Why Chosen:
  - It meets the v1 requirements with the lowest complexity and no required external dependencies.
- Consequences:
  - Some evidence remains heuristic because Android font resolution is not fully transparent.
  - The app must communicate evidence provenance clearly.
  - Manual `adb` assistance remains part of the broader validation workflow when needed.
- Follow-ups:
  - Evaluate whether a custom comparison font should be bundled after v1 proves useful.
  - Evaluate whether repeated device runs justify automated artifact capture later.

## Problem Statement

`FontFeature.tabularFigures()` is not behaving consistently across Android devices. The team currently lacks a deterministic local tool to:

- inspect relevant device information
- compare `tnum on/off` rendering side by side
- surface what candidate fonts the device may be using
- present a clear `inconclusive` state when the final font cannot be supported by evidence

## Users

- Primary user: engineers investigating numeric rendering differences on Android devices
- Secondary user: designers or QA validating alignment behavior manually on physical devices

## Goals

1. Create a local Flutter debug app for Android font investigation.
2. Show a clear evidence panel for font attribution.
3. Render a configurable numeric string matrix.
4. Compare `tnum on/off` rendering for the same content.
5. Mark unsupported attribution cases as `inconclusive`.

## Non-Goals

- Automatic screenshot generation
- Automatic report generation
- Reusable widget extraction
- Package hardening
- iOS support in v1
- Claims of final resolved fonts without enough evidence

## Product Requirements

### R1. Project scaffold

- Create a new Flutter app in this repository.
- Use `fvm` for Flutter commands.
- Keep the structure simple enough for a single-purpose local debug tool.

### R2. Investigation screen

The app should open into one main investigation view with clearly separated sections:

- device information
- font evidence panel
- string matrix viewer
- `tnum on/off` comparison

### R3. Device information section

The app must show:

- manufacturer
- model
- Android release/version
- Flutter configured font family for the displayed sample
- whether the sample is using a bundled custom font or a system/default path

Implementation note:
- Prefer a small Android native bridge over adding a device-info dependency.

### R4. Font evidence panel

The app must surface a candidate font / evidence list for the current device or rendering path.

The evidence panel should support at least these evidence categories:

- requested family name from Flutter style
- whether the family resolves to a bundled asset controlled by the app
- Android system font configuration findings when readable
- Android customization overlays when readable
- manual evidence notes / limitations

The panel must also support a final state field:

- `confirmed`
- `candidate`
- `inconclusive`

For v1, `confirmed` may only be used when the implementation has direct supporting evidence.

### R5. String matrix

The app must render a configurable list of sample strings optimized for numeric investigation, including cases such as:

- repeated narrow digits
- repeated wide digits
- mixed digits
- timer-like strings
- monetary strings

Configuration decision:
- Keep v1 simple by storing the sample strings in one local source file that can be edited directly.

### R6. Tnum comparison

For each sample string, the app must show at least:

- `tnum off`
- `tnum on`

The comparison must make width differences visually inspectable.

### R7. Custom font comparison lane

The app should include a controlled comparison lane for one bundled font with known `tnum` support if this can be added without new package dependencies.

Purpose:
- provide a known-good baseline against the system/default path

If the bundled lane is not included in the first cut, the plan still passes as long as the system/default path plus evidence panel and `tnum on/off` comparison are delivered.

### R8. Inconclusive handling

If the app cannot support final font attribution with evidence, it must display `inconclusive / unable to confirm`.

The UI must not silently degrade this into a likely guess.

### R9. Manual validation notes

The repository should include a short operator note describing:

- how to run the app with `fvm`
- what the evidence states mean
- which additional `adb` checks may be used manually when deeper Android confirmation is needed

## Technical Approach

### App structure

- `lib/main.dart` boots the app
- `lib/app.dart` wires the debug shell
- `lib/features/font_debug/` contains the investigation screen and sections
- `lib/core/` contains models, string configuration, and shared style helpers
- `android/` contains a minimal platform channel for device and readable Android font configuration details

### Data model

Likely core models:

- `DeviceDebugInfo`
- `FontEvidenceItem`
- `FontEvidenceSummary`
- `SampleStringCase`
- `RenderedComparisonRow`

### Evidence strategy

The app should combine:

1. Flutter-side requested font info
2. Native Android metadata
3. Readable system font config probing when available
4. Hard-coded provenance rules for bundled custom fonts
5. Explicit fallback to `inconclusive`

### Dependency policy

- No new third-party packages by default
- If a package becomes necessary, it should be justified separately before implementation

## Acceptance Criteria

1. The repository contains a Flutter app scaffold created and managed with `fvm`.
2. `fvm flutter analyze` passes.
3. `fvm flutter test` passes for the planned test surface.
4. Running the app on Android shows device info on screen.
5. The app shows a candidate font / evidence list with explicit evidence states.
6. The app can show `inconclusive / unable to confirm`.
7. The app renders the configured string matrix.
8. The app shows a direct `tnum on/off` comparison for the same strings.
9. The repository includes short manual validation guidance.

## Risks

1. Android may not expose enough information to ever reach `confirmed` on many devices.
2. OEM-specific overlays may vary in file location or readability.
3. A very dense one-screen layout can reduce readability if not grouped carefully.
4. Without a bundled known-good font lane, diagnosis may be slower on ambiguous devices.

## Mitigations

1. Use explicit evidence categories and provenance labels.
2. Keep `inconclusive` as a first-class state.
3. Group the screen into sections with clear labels.
4. Make the sample-string source easy to edit.

## Implementation Sequence

1. Scaffold the Flutter app with `fvm`.
2. Build the main investigation screen with placeholder sections.
3. Add the sample string matrix and `tnum on/off` comparison widgets.
4. Add Android native bridge for device metadata and readable font config probing.
5. Implement evidence summarization and `inconclusive` handling.
6. Add a short operator guide.
7. Run `fvm flutter analyze` and `fvm flutter test`.

## Available Agent Types

- `executor`: implementation and refactoring
- `architect`: review of Android evidence strategy and app boundaries
- `test-engineer`: test-plan execution and coverage review
- `verifier`: completion evidence and acceptance validation
- `debugger`: Android-side investigation if evidence probing is unstable

## Suggested Staffing Guidance

### If using `ralph`

- Lane 1: `executor` owns scaffold, UI, and native bridge
- Lane 2: `verifier` checks acceptance criteria after implementation

### If using `team`

- Lane 1: `executor` owns Flutter scaffold and screen composition
- Lane 2: `executor` or `debugger` owns Android platform channel and system-font probing
- Lane 3: `test-engineer` owns widget tests, manual test script, and verification checklist

## Reasoning Guidance By Lane

- Scaffold/UI lane: `medium`
- Android evidence lane: `high`
- Test/verification lane: `medium`

## Launch Hints

- Sequential execution: `$ralph /Users/wingchan/Project/flutter_tnum_font/.omx/specs/deep-interview-android-tnum-debug-project.md`
- Parallel execution: `$team /Users/wingchan/Project/flutter_tnum_font/.omx/specs/deep-interview-android-tnum-debug-project.md`

## Team Verification Path

1. Confirm scaffold exists and runs with `fvm`.
2. Confirm each mandatory UI section appears.
3. Confirm `tnum on/off` comparison is visible for the configured strings.
4. Confirm evidence states include `inconclusive`.
5. Confirm tests and analyze pass.
6. Confirm operator note matches actual workflow.
