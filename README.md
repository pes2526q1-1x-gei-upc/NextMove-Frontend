# NextMove App

A Flutter application for sustainable urban mobility, featuring bicycle stations, EV charging points, and social features.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Testing

### Unit Tests

Run unit tests with:
```bash
flutter test
```

### Integration Tests

The project includes comprehensive integration tests that verify the app's functionality end-to-end.

#### Quick Start

```bash
# Run all integration tests
flutter test integration_test/app_test.dart

# Run feature-specific tests
flutter test integration_test/features_test.dart

# Run on a specific device
flutter test integration_test/app_test.dart -d chrome
```

#### Using the Test Runner Script

```bash
# Run with default settings
./run_integration_tests.sh

# Run on specific device
./run_integration_tests.sh -d chrome

# Run specific test file
./run_integration_tests.sh -f integration_test/features_test.dart

# Use flutter drive (more features)
./run_integration_tests.sh --driver

# See all options
./run_integration_tests.sh --help
```

#### Test Coverage

Integration tests cover:
- App launch and authentication flow
- Navigation between main sections (Map, Chat, Social, Profile)
- Map functionality and interactions
- Profile management and settings
- Social features
- Performance and memory management
- Error handling and recovery

For more details, see [integration_test/README.md](integration_test/README.md).

### CI/CD

Integration tests are automatically run on:
- Pull requests to `main` and `dev` branches
- Pushes to `main` and `dev` branches

See `.github/workflows/integration_tests.yml` for CI configuration.

