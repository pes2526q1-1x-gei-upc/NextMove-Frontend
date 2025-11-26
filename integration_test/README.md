# Integration Tests for NextMove App

This directory contains integration tests for the NextMove Flutter application.

## Overview

Integration tests verify that the different parts of the app work correctly together. They run on real devices or emulators and simulate user interactions.

## Test Coverage

The current integration tests cover:

1. **App Launch**: Verifies the app launches correctly and shows the welcome page when not logged in
2. **Navigation**: Tests navigation between tabs (Map, Chat, Social, Profile)
3. **Map Page**: Ensures the map page renders correctly
4. **Profile Navigation**: Tests accessing profile and settings
5. **Login Elements**: Verifies welcome page has login options
6. **Error Handling**: Ensures the app handles errors gracefully
7. **Rapid Navigation**: Tests multiple quick navigation actions
8. **Scaffold Structure**: Verifies UI structure is maintained throughout navigation

## Running the Tests

### Prerequisites

- Flutter SDK installed
- An emulator/simulator running or a physical device connected
- All dependencies installed (`flutter pub get`)

### Run All Integration Tests

```bash
# On Android
flutter test integration_test/app_test.dart

# On iOS (macOS only)
flutter test integration_test/app_test.dart

# On a specific device
flutter test integration_test/app_test.dart -d <device_id>
```

### Run with Integration Test Driver

For better performance and additional features:

```bash
# Android
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/app_test.dart

# iOS
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/app_test.dart \
  -d iPhone
```

### List Available Devices

```bash
flutter devices
```

## Test Structure

```
integration_test/
├── app_test.dart           # Main integration test file
test_driver/
└── integration_test.dart   # Test driver for advanced test runs
```

## Writing New Tests

To add new integration tests:

1. Create a new test file in the `integration_test/` directory
2. Import the required packages:
   ```dart
   import 'package:flutter_test/flutter_test.dart';
   import 'package:integration_test/integration_test.dart';
   ```
3. Initialize the binding:
   ```dart
   IntegrationTestWidgetsFlutterBinding.ensureInitialized();
   ```
4. Write your tests using `testWidgets()`

## Tips

- **Wait for animations**: Use `await tester.pumpAndSettle()` to wait for animations and async operations
- **Find widgets**: Use `find.byType()`, `find.byKey()`, `find.text()`, etc.
- **Tap elements**: Use `await tester.tap(finder)`
- **Enter text**: Use `await tester.enterText(finder, 'text')`
- **Scroll**: Use `await tester.drag()` or `await tester.scrollUntilVisible()`

## Debugging Tests

To see more detailed output:

```bash
flutter test integration_test/app_test.dart --verbose
```

## CI/CD Integration

These tests can be integrated into your CI/CD pipeline. Example for GitHub Actions:

```yaml
- name: Run Integration Tests
  run: flutter test integration_test/app_test.dart
```

## Notes

- Some tests may require authentication. Consider mocking authentication for testing purposes.
- Tests assume certain UI elements exist. Update tests if the UI changes significantly.
- Integration tests take longer to run than unit tests.
- Make sure to have a stable internet connection if tests interact with backend services.

## Troubleshooting

### Test Timeout
If tests timeout, increase the timeout duration:
```dart
testWidgets('test name', (WidgetTester tester) async {
  // ...
}, timeout: const Timeout(Duration(minutes: 5)));
```

### Widget Not Found
Use `finder.evaluate().isEmpty` to check if a widget exists before interacting with it.

### Firebase Issues
Ensure Firebase is properly configured for test environments and that `.env` file exists.
