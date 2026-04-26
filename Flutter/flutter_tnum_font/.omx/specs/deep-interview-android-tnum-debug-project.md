# Deep Interview Spec

## Metadata

- Slug: `android-tnum-debug-project`
- Profile: `standard`
- Context Type: `greenfield`
- Rounds: `5`
- Final Ambiguity: `9.3%`
- Threshold: `20%`
- Context Snapshot: [android-tnum-debug-project-20260422T084132Z.md](/Users/wingchan/Project/flutter_tnum_font/.omx/context/android-tnum-debug-project-20260422T084132Z.md)
- Transcript: [android-tnum-debug-project-20260422T085722Z.md](/Users/wingchan/Project/flutter_tnum_font/.omx/interviews/android-tnum-debug-project-20260422T085722Z.md)

## Clarity Breakdown

| Dimension | Score | Notes |
| --- | --- | --- |
| Intent | 0.93 | Primary goal is to determine actual numeric rendering fonts on Android devices. |
| Outcome | 0.92 | v1 must expose candidate fonts/evidence and visible rendering results, not just a demo. |
| Scope | 0.88 | v1 is a local manual-first debug tool, not a polished reusable package. |
| Constraints | 0.85 | Use `fvm`; prefer strong evidence; do not make unsupported font claims. |
| Success | 0.95 | Minimum on-screen outputs are explicit. |

## Intent

Build a local Flutter debug project that helps determine which fonts different Android devices actually use for numeric rendering, especially when `FontFeature.tabularFigures()` enables OpenType `tnum`, and show the real rendering effect of chosen strings under those conditions.

## Desired Outcome

Produce a local debug app that can be run on Android devices to:

- show device metadata relevant to the investigation
- surface candidate font information and the evidence chain behind it
- clearly mark `inconclusive` devices instead of guessing
- render a configured string matrix for visual inspection
- compare `tnum on/off` rendering for the same strings

The result should support a practical debugging decision about whether Android device behavior comes from actual font choice/support differences rather than only Flutter layout assumptions.

## In Scope

- A new local Flutter debug app in this repository
- Android-focused validation flow
- App UI that shows:
  - device info
  - candidate font / evidence list
  - explicit `inconclusive` state when proof is insufficient
  - string matrix rendering area
  - `tnum on/off` comparison for the same content
- Manual-first evidence gathering flow that may include `adb`-assisted validation steps
- Use of `FontFeature.tabularFigures()` for `tnum` comparison
- Investigation-oriented presentation over production polish

## Out of Scope / Non-goals

- Automatic screenshot generation
- Automatic report generation
- Production-ready reusable widget extraction
- Package-ization / library hardening
- Unsupported claims about final resolved fonts when evidence is insufficient
- Non-Android platform support in v1

## Decision Boundaries

Binding boundaries from the interview:

- If final resolved font evidence is insufficient, the app must show `inconclusive / unable to confirm`.
- The app must optimize for visible manual inspection rather than automation-heavy output.
- Flutter commands must use `fvm`.

Operational boundaries inferred for planning/execution:

- The exact debug screen structure, candidate-evidence presentation format, and local configuration shape may be decided during planning as long as the mandatory outputs and non-goals remain intact.
- A bundled comparison font may be added if it materially helps the investigation, but it is not the primary objective of v1.

## Constraints

- Use `fvm` for all Flutter commands.
- Do not run long build commands such as `fvm flutter build` or `fvm dart run build_runner build`.
- Prefer strong evidence over weak inference for font attribution.
- The platform may not expose the exact final resolved font directly; the design must tolerate that limitation.
- When certainty is not possible, prefer explicit uncertainty over a likely-but-unproven guess.

## Testable Acceptance Criteria

V1 is complete when all of the following are true:

- The repository contains a runnable Flutter debug app scaffold targeted at Android.
- Running the app on an Android device shows device info on screen.
- The app shows a candidate font / evidence list for the current device or rendering path.
- The app can display an explicit `inconclusive` state for devices where final font attribution cannot be supported.
- The app renders a string matrix using configured sample strings.
- The app shows a side-by-side or otherwise directly comparable `tnum on/off` view for the same strings.
- The app does not depend on automatic screenshot/report generation.
- The validation flow documents or exposes enough evidence for a human to inspect the result manually.

## Assumptions Exposed And Resolutions

- Assumption: a visual demo alone would be enough.
  - Resolution: rejected; the project must pursue near-final font evidence.
- Assumption: uncertain font attribution should still pick the most likely font.
  - Resolution: rejected; use `inconclusive`.
- Assumption: v1 should generate screenshots/reports automatically.
  - Resolution: rejected; manual inspection is enough.
- Assumption: v1 should be shaped like a reusable production component.
  - Resolution: rejected; debug utility is the priority.

## Pressure-Pass Findings

- Revisited Answer: the original broad project proposal and first-round outcome framing.
- Pressure Applied: contrarian evidence-standard follow-up.
- What Changed: the task moved from “build a debug app” to “build an evidence-oriented investigation tool with strict failure semantics.”

## Repository Grounding Notes

Evidence-backed findings:

- The repository is currently greenfield for this task.
- No `pubspec.yaml`, Dart source files, `README.md`, or `analysis_options.yaml` were present during preflight.

Inference notes:

- Because the repo is empty, planning may choose the simplest Flutter app structure that satisfies the acceptance criteria.
- The likely implementation will need a mix of Flutter UI and externally assisted Android inspection, but the exact mechanism remains a planning task.

## Technical Context Findings

- The investigation centers on Android numeric rendering and the effect of `FontFeature.tabularFigures()`.
- The user expects concrete candidate font evidence and actual on-screen rendering samples.
- The user accepts manual investigation steps to approach final resolved font evidence.
- The user prefers a hard `inconclusive` label over weak attribution.

## Condensed Transcript

1. Core decision: determine actual fonts used on different Android phones and show rendering results for chosen strings.
2. Evidence standard: get as close as possible to final resolved font evidence, even if manual steps are needed.
3. Failure policy: mark unsupported cases as `inconclusive`.
4. Non-goals: no auto screenshots, no auto reports, no package/reusable widget work.
5. Minimum v1 outputs: device info, candidate font/evidence list, `inconclusive` label, string matrix, and `tnum on/off` comparison.
