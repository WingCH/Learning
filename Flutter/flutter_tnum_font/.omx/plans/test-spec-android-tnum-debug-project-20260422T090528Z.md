# Test Spec: Android Tnum Debug Project

## Metadata

- Slug: `android-tnum-debug-project`
- PRD: [prd-android-tnum-debug-project-20260422T090528Z.md](/Users/wingchan/Project/flutter_tnum_font/.omx/plans/prd-android-tnum-debug-project-20260422T090528Z.md)
- Planning Timestamp: `2026-04-22T09:05:28Z`

## Test Strategy

The test strategy is intentionally split across:

- static validation for project integrity
- widget tests for the debug UI
- focused Dart tests for evidence summarization logic
- manual Android device validation for platform-specific behavior

This split is necessary because final Android font resolution cannot be proven purely through unit tests.

## Verification Commands

Use only these non-build commands during implementation:

```bash
fvm flutter analyze
fvm flutter test
```

Do not use:

```bash
fvm flutter build
fvm dart run build_runner build
```

## Test Areas

### T1. Scaffold integrity

Purpose:
- confirm the repository becomes a valid Flutter app

Checks:
- `pubspec.yaml` exists
- Android, `lib/`, and `test/` structure exist
- app boots into the planned investigation shell

### T2. Device info rendering

Purpose:
- confirm the UI displays native Android metadata

Automated checks:
- widget test verifies labels and rendering fallback states

Manual checks:
- run on Android device and confirm manufacturer, model, and Android version render on screen

### T3. Font evidence panel

Purpose:
- confirm evidence items and evidence states render correctly

Automated checks:
- Dart test verifies summarization logic for:
  - `confirmed`
  - `candidate`
  - `inconclusive`
- widget test verifies evidence list rendering from fake data

Manual checks:
- on a real device, confirm the evidence panel shows readable provenance and not just a raw dump

### T4. Inconclusive handling

Purpose:
- prevent false certainty

Automated checks:
- Dart test verifies that insufficient evidence produces `inconclusive`
- widget test verifies `inconclusive / unable to confirm` is visible when given incomplete evidence

Manual checks:
- simulate or run a device path where proof is unavailable and confirm the UI shows `inconclusive`

### T5. String matrix rendering

Purpose:
- confirm all configured sample strings render in the matrix

Automated checks:
- widget test verifies each configured sample string appears

Manual checks:
- confirm the matrix is readable on device and does not collapse or truncate critical values

### T6. Tnum comparison

Purpose:
- confirm the same sample strings render in `tnum off` and `tnum on` lanes

Automated checks:
- widget test verifies both comparison lanes exist for each sample string

Manual checks:
- inspect visual differences on device for strings such as:
  - `111111`
  - `888888`
  - `1234567890`
  - `00:00:00`
  - `1,111.11`

### T7. Manual operator note

Purpose:
- confirm the repository documents the human validation flow

Automated checks:
- none required

Manual checks:
- verify the run steps, evidence-state meanings, and optional `adb` notes match the actual app behavior

## Test Data Plan

Use a small but representative numeric matrix:

- repeated narrow digits
- repeated wide digits
- mixed digits
- timer format
- monetary format

The exact source list should live in one local configuration file so tests can assert against a single source of truth.

## Failure Conditions

The implementation fails the test spec if any of the following happen:

- the app shows a font name without supporting evidence state/provenance
- an uncertain case silently omits `inconclusive`
- the `tnum on/off` comparison is missing for configured sample strings
- device info is absent on Android
- analysis or tests fail

## Manual Device Validation Script

1. Run `fvm flutter analyze`.
2. Run `fvm flutter test`.
3. Launch the app on an Android device.
4. Confirm device info appears.
5. Confirm the evidence panel appears with one of `confirmed`, `candidate`, or `inconclusive`.
6. Confirm the configured sample strings appear in both `tnum off` and `tnum on` lanes.
7. If deeper validation is needed, use optional `adb` inspection outside the app and compare it against the evidence panel.
8. Record observations manually; screenshot capture is optional and out of scope for v1 automation.

## Coverage Expectations

- Widget tests should cover the main investigation screen and section rendering.
- Dart tests should cover evidence-state mapping and summary logic.
- Manual validation should cover at least one Android device before calling the feature ready.

## Exit Criteria

The implementation is ready for execution handoff only when:

- the PRD acceptance criteria are all mapped to at least one verification step
- the command set stays within allowed `fvm` non-build commands
- the plan preserves the explicit `inconclusive` policy
