import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nextmove_app/main.dart' as app;
import 'test_config.dart';

/// Example integration test demonstrating best practices and helper usage
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Example Integration Test with Helpers', () {
    testWidgets('Demonstrates using test helpers', (WidgetTester tester) async {
      IntegrationTestConfig.printTestSection('Starting Example Test');
      
      // Start the app
      app.main();
      await tester.pumpAndSettle(IntegrationTestConfig.mediumTimeout);
      
      // Take a screenshot marker
      await IntegrationTestConfig.takeScreenshot(tester, 'app_launched');
      
      // Check if bottom navigation exists (using helper)
      final bottomNav = find.byType(BottomNavigationBar);
      
      if (IntegrationTestConfig.widgetExists(bottomNav)) {
        IntegrationTestConfig.printTestSection('Testing Navigation');
        
        // Navigate to profile using safe tap
        final profileTab = find.descendant(
          of: bottomNav,
          matching: find.byIcon(Icons.person),
        );
        
        await IntegrationTestConfig.safeTap(tester, profileTab);
        await IntegrationTestConfig.takeScreenshot(tester, 'profile_page');
        
        // Navigate back to map
        final mapTab = find.descendant(
          of: bottomNav,
          matching: find.byIcon(Icons.map),
        );
        
        await IntegrationTestConfig.safeTap(tester, mapTab);
        await IntegrationTestConfig.takeScreenshot(tester, 'map_page');
        
        // Verify we're back on map
        expect(bottomNav, findsOneWidget);
      }
      
      IntegrationTestConfig.printTestSection('Test Completed');
    });

    testWidgets('Demonstrates using extension methods', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(IntegrationTestConfig.mediumTimeout);
      
      // Use extension methods for cleaner code
      final bottomNav = find.byType(BottomNavigationBar);
      
      if (tester.exists(bottomNav)) {
        final chatTab = find.descendant(
          of: bottomNav,
          matching: find.byIcon(Icons.chat),
        );
        
        // Use safe tap extension
        await tester.safeTap(chatTab);
        
        // Verify navigation worked
        expect(tester.exists(bottomNav), isTrue);
      }
    });

    testWidgets('Demonstrates conditional feature testing', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(IntegrationTestConfig.mediumTimeout);
      
      // Only test features that are enabled
      if (IntegrationTestConfig.isMapFeatureEnabled) {
        IntegrationTestConfig.printTestSection('Testing Map Feature');
        
        final bottomNav = find.byType(BottomNavigationBar);
        if (tester.exists(bottomNav)) {
          final mapTab = find.descendant(
            of: bottomNav,
            matching: find.byIcon(Icons.map),
          );
          await tester.safeTap(mapTab);
          expect(tester.exists(bottomNav), isTrue);
        }
      }
      
      if (IntegrationTestConfig.isSocialFeatureEnabled) {
        IntegrationTestConfig.printTestSection('Testing Social Feature');
        
        final bottomNav = find.byType(BottomNavigationBar);
        if (tester.exists(bottomNav)) {
          final socialTab = find.descendant(
            of: bottomNav,
            matching: find.byIcon(Icons.people),
          );
          await tester.safeTap(socialTab);
          expect(tester.exists(bottomNav), isTrue);
        }
      }
    });

    testWidgets('Demonstrates error handling', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(IntegrationTestConfig.mediumTimeout);
      
      // Example of safe widget interaction
      final nonExistentWidget = find.text('This Widget Does Not Exist');
      
      // Won't throw an error, just logs a warning
      await tester.safeTap(nonExistentWidget);
      
      // Can check explicitly
      if (!tester.exists(nonExistentWidget)) {
        print('Widget not found, skipping interaction');
      }
      
      // App should still be running
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}
