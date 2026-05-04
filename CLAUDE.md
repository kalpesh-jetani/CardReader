# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

- App: CardReader — SwiftUI iOS/macOS app for reading and managing cards
- Platform: iOS 17+, Swift 6, Xcode 16
- Architecture: MVVM + SwiftUI
- Status: Early development, initial scaffold in place

## Directory Structure

- `CardReader/Views/`       — SwiftUI views only
- `CardReader/ViewModels/`  — @Observable classes
- `CardReader/Models/`      — Data models, Codable
- `CardReader/Services/`    — Networking, persistence
- `CardReaderTests/`        — XCTest + Swift Testing

## Coding Rules

- SwiftUI first, UIKit only when unavoidable
- async/await everywhere, no Combine
- Strict Sendable conformance (Swift 6)
- SF Symbols for all icons
- Use @Observable not ObservableObject

## ⚠️ Critical Rules

- NEVER modify .pbxproj files — add new files in Xcode manually
- NEVER hardcode API keys
- Break large View bodies into subviews (compiler limit)
- Min deployment: iOS 17.0

## Build & Test

```bash
# Build for simulator
xcodebuild -project CardReader.xcodeproj -scheme CardReader -destination 'platform=iOS Simulator,name=iPhone 16' build

# Run tests
xcodebuild -project CardReader.xcodeproj -scheme CardReader -destination 'platform=iOS Simulator,name=iPhone 16' test

# Run a single test class
xcodebuild -project CardReader.xcodeproj -scheme CardReader -destination 'platform=iOS Simulator,name=iPhone 16' test -only-testing:CardReaderTests/MyTestClass
```

- Build: use XcodeBuildMCP tool if available
- Lint: `swiftlint autocorrect`
- Tests: run via XcodeBuildMCP or xcodebuild

## Architecture

- **Entry point:** `CardReader/CardReaderApp.swift` — `@main` App struct, sets up the root `WindowGroup`.
- **Root view:** `CardReader/ContentView.swift` — SwiftUI view, currently the default template placeholder.

Add new views as Swift files under `CardReader/Views/` and wire them into `ContentView` or create a navigation hierarchy from `CardReaderApp`.

## Swift Package Dependencies

- (none yet — add key packages and their doc links here as they are added)
