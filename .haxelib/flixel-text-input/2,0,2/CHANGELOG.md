<!-- markdownlint-configure-file {"MD024": {"siblings_only": true}} -->
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

## 2.0.2 - 2024-01-24

### Changed

- Slightly optimized `FlxUITextInput.resize` and added comment to clarify what it resizes

### Fixed

- Fixed compile errors with `FlxUITextInput` and the samples when using HaxeFlixel 5.3.1 or older
- Fixed crash from `_currentCamera` being destroyed
- Fixed vertical-stacked stepper not being visible in flixel-ui sample

## 2.0.1 - 2023-12-26

### Changed

- Internal: Moved focus handling and `_currentCamera` variable from `FlxTextInput` to `FlxBaseTextInput`
- Internal: Removed `dispatch` argument from `onFocusInHandler`, use `checkForFocus` instead to check for focus without dispatching `onFocusGained`

### Fixed

- OpenFL events dispatched for a text input with focus are now dispatched for the stage
  - Flixel key bindings (volume up/down, debugger toggle, etc.) are now disabled while a text input has focus, since keyboard events are now dispatched for the stage
- Fixed text input having a single empty character when passing `null` or empty text in the constructor
- Fixed `FlxUINumericStepper` having no package declared if "flixel-ui" isn't installed ([#1](https://github.com/Starmapo/flixel-text-input/pull/1))

## 2.0.0 - 2023-12-22

### Added

- `pointerEnabled` variable to `FlxTextInput`

### Changed

- Set Dead Code Elimination to "full" in sample projects
- Internal: Simplified removing event listeners in `CustomTextField`

### Removed

- `flixel.addons.text.FlxUITextInput` (deprecated class)

### Fixed

- Fixed a bug in HaxeUI where the text input wouldn't gain focus if its background was pressed
- Fixed compatibility issues with flixel 4.11.0 and lime 7.9.0

## 1.1.0 - 2023-12-07

### Added

- `flixel.addons.text.ui.FlxUINumericStepper`: A recreation of the "flixel-ui" numeric stepper that uses this library's text input
- Added "basic" and "flixel-ui" sample projects

### Changed

- Moved `FlxUITextInput` to the `flixel.addons.text.ui` package

### Fixed

- Fixed a crash when text is `null` in the `FlxTextInput` constructor
- Fixed a bug with touch input

## 1.0.0 - 2023-12-04

### Added

- Everything (initial release)
