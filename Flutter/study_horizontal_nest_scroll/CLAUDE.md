# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a basic Flutter project named "study_horizontal_nest_scroll" created with the standard Flutter template. The project appears to be a learning/study project focused on exploring horizontal nested scrolling functionality in Flutter.

## Development Commands

### Setup
```bash
# Use FVM to set Flutter version
fvm use

# Get Flutter dependencies
fvm flutter pub get

# Run the app in debug mode
fvm flutter run

# Run with hot reload (automatically enabled in debug mode)
fvm flutter run --hot
```

### Development
```bash
# Analyze the code for potential issues
fvm flutter analyze

# Format the code
fvm dart format .

# Run unit tests
fvm flutter test

# Run a specific test file
fvm flutter test test/widget_test.dart

# Run tests with coverage
fvm flutter test --coverage
```

### Building
```bash
# Build APK for Android
fvm flutter build apk

# Build app bundle for Android
fvm flutter build appbundle

# Build for iOS (requires macOS and Xcode)
fvm flutter build ios

# Build for web
fvm flutter build web

# Build for specific platforms
fvm flutter build windows
fvm flutter build macos
fvm flutter build linux
```

### Debugging
```bash
# Run in debug mode with verbose logging
fvm flutter run --verbose

# Clean build artifacts
fvm flutter clean

# Doctor check for Flutter installation
fvm flutter doctor
```

## Project Structure

### Standard Flutter Architecture
```
lib/
├── main.dart          # App entry point with MaterialApp setup
test/
├── widget_test.dart   # Basic widget tests

Platform-specific directories:
android/               # Android-specific configuration
ios/                   # iOS-specific configuration  
web/                   # Web-specific configuration
windows/               # Windows-specific configuration
macos/                 # macOS-specific configuration
linux/                 # Linux-specific configuration
```

### Current Implementation
- **main.dart**: Contains the standard Flutter counter app with:
  - `MyApp`: Root application widget with Material Design theme
  - `MyHomePage`: Stateful widget demonstrating basic state management
  - Counter functionality using `setState()`

## Dependencies

### Runtime Dependencies
- **flutter**: Flutter framework SDK
- **cupertino_icons**: iOS-style icons (^1.0.8)

### Development Dependencies  
- **flutter_test**: Flutter testing framework
- **flutter_lints**: Recommended lints for Flutter (^4.0.0)

## Configuration Files

- **pubspec.yaml**: Package configuration and dependencies
- **analysis_options.yaml**: Dart analyzer configuration using flutter_lints
- **README.md**: Basic Flutter project documentation

## Environment Requirements

- **Dart SDK**: ^3.5.4
- **Flutter**: Managed by FVM (Flutter Version Management)
- **FVM**: Required for version management
- Material Design 3 enabled by default

## FVM Setup

This project uses FVM for Flutter version management. Install FVM first:

```bash
# Install FVM globally
dart pub global activate fvm

# Or using Homebrew on macOS
brew tap leoafarias/fvm
brew install fvm
```

Then use FVM commands as shown in the Development Commands section above.