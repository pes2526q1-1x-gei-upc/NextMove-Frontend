import 'package:flutter_test/flutter_test.dart';

/// Configuration for integration tests
class IntegrationTestConfig {
  // Timeout durations
  static const Duration shortTimeout = Duration(seconds: 2);
  static const Duration mediumTimeout = Duration(seconds: 5);
  static const Duration longTimeout = Duration(seconds: 10);
  
  // Pump durations
  static const Duration quickPump = Duration(milliseconds: 100);
  static const Duration normalPump = Duration(milliseconds: 500);
  
  // Retry configuration
  static const int maxRetries = 3;
  
  // Test data
  static const String testEmail = 'test@example.com';
  static const String testPassword = 'TestPassword123!';
  
  // Feature flags for conditional testing
  static bool get isAuthenticationEnabled => true;
  static bool get isMapFeatureEnabled => true;
  static bool get isSocialFeatureEnabled => true;
  static bool get isProfileFeatureEnabled => true;
  
  /// Wait for a widget to appear with timeout
  static Future<void> waitForWidget(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = mediumTimeout,
  }) async {
    final endTime = DateTime.now().add(timeout);
    
    while (DateTime.now().isBefore(endTime)) {
      await tester.pump(quickPump);
      
      if (finder.evaluate().isNotEmpty) {
        return;
      }
    }
    
    throw Exception('Widget not found within timeout: $finder');
  }
  
  /// Safely tap a widget if it exists
  static Future<void> safeTap(
    WidgetTester tester,
    Finder finder, {
    bool warnIfNotFound = true,
  }) async {
    if (finder.evaluate().isEmpty) {
      if (warnIfNotFound) {
        print('Warning: Widget not found for tap: $finder');
      }
      return;
    }
    
    await tester.tap(finder.first);
    await tester.pumpAndSettle();
  }
  
  /// Scroll until a widget is visible
  static Future<void> scrollUntilVisible(
    WidgetTester tester,
    Finder item,
    Finder scrollable, {
    double delta = 100,
    int maxScrolls = 50,
  }) async {
    for (int i = 0; i < maxScrolls; i++) {
      if (item.evaluate().isNotEmpty) {
        break;
      }
      
      await tester.drag(scrollable, Offset(0, -delta));
      await tester.pump(normalPump);
    }
  }
  
  /// Check if widget exists without throwing
  static bool widgetExists(Finder finder) {
    return finder.evaluate().isNotEmpty;
  }
  
  /// Take a screenshot (for debugging)
  static Future<void> takeScreenshot(
    WidgetTester tester,
    String name,
  ) async {
    // Screenshots are automatically captured during test failures
    // This method can be extended with custom screenshot logic
    print('Screenshot marker: $name');
  }
  
  /// Print test section header
  static void printTestSection(String section) {
    print('');
    print('=' * 60);
    print('  $section');
    print('=' * 60);
    print('');
  }
}

/// Helper extension for WidgetTester
extension IntegrationTestExtensions on WidgetTester {
  /// Wait for widget with default timeout
  Future<void> waitFor(Finder finder) {
    return IntegrationTestConfig.waitForWidget(this, finder);
  }
  
  /// Safe tap with default settings
  Future<void> safeTap(Finder finder) {
    return IntegrationTestConfig.safeTap(this, finder);
  }
  
  /// Check if widget exists
  bool exists(Finder finder) {
    return IntegrationTestConfig.widgetExists(finder);
  }
}
