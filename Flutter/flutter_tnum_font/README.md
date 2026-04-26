# flutter_tnum_font

Local Flutter debug app for investigating Android numeric rendering and `tnum`
behavior.

## What It Shows

The v1 app focuses on one investigation screen with:

- device info
- candidate font / evidence list
- explicit `inconclusive / unable to confirm` state
- `tnum off` vs `tnum on` comparison

## Run

All Flutter commands in this repo must use `fvm`.

```bash
fvm flutter pub get
fvm flutter run
```

Verification commands:

```bash
fvm flutter analyze
fvm flutter test
```

Do not use long build commands such as:

```bash
fvm flutter build
fvm dart run build_runner build
```

## Evidence States

- `confirmed`: only for directly controlled bundled-font evidence
- `candidate`: Android-readable font config points to possible font files
- `inconclusive / unable to confirm`: not enough evidence to support attribution

The app must prefer `inconclusive` over a likely-but-unproven font guess.

## Current Probe Strategy

The Android method channel first uses public Android native font APIs when
available:

- `Typeface.getSystemFontFamilyName()` on Android 14 / API 34+
- `SystemFonts.getAvailableFonts()` on Android 10 / API 29+

It then falls back to readable system font config files when possible, including
paths such as:

- `/system/etc/fonts.xml`
- `/system_ext/etc/fonts.xml`
- `/product/etc/fonts.xml`
- `/product/etc/fonts_customization.xml`
- `/vendor/etc/fonts.xml`

It then combines:

- requested Flutter font family
- Android device metadata
- readable config file paths
- candidate font file names from matching family / alias lookups
- probe limitations when files are missing, unreadable, or inconclusive

## Manual Validation Flow

1. Launch the app on an Android device with `fvm flutter run`.
2. Pick a render profile such as `system default`, `sans-serif`, or `monospace`.
3. Review `Device info`.
4. Review `Font evidence` and note whether the result is `candidate` or
   `inconclusive`.
5. Compare the same sample strings and measured widths in `tnum off` and
   `tnum on`.

Sample strings currently included in the app:

- `04-22 中場`
- `04-22 點球PK`
- `04-22 加時賽`

The top comparison also includes mixed-style lines, such as `04-22 中場`,
`04-22 點球PK`, and `04-22 加時賽`, where `04-22` uses the default text style
and the status text uses the `tnum` text style.

## Optional adb Cross-Checks

When a device needs deeper inspection, use `adb` outside the app and compare the
output against the evidence panel. Examples:

```bash
adb shell getprop ro.product.manufacturer
adb shell getprop ro.product.model
adb shell cat /system/etc/fonts.xml
adb shell cat /product/etc/fonts_customization.xml
```

Not every device exposes the same files or permissions. If the platform evidence
is incomplete, the expected app result is `inconclusive / unable to confirm`.
