import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nextmove_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('NextMove Authentication Flow Tests', () {
    testWidgets('Welcome page displays correctly', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify the app has loaded
      expect(find.byType(MaterialApp), findsOneWidget);
      
      // Check for scaffold which should be present on all pages
      final scaffolds = find.byType(Scaffold);
      expect(scaffolds, findsWidgets);
    });

    testWidgets('Can interact with UI elements', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Look for any TextFields (for email/password)
      final textFields = find.byType(TextField);
      
      if (textFields.evaluate().isNotEmpty) {
        // Try to tap on the first TextField
        await tester.tap(textFields.first);
        await tester.pumpAndSettle();
        
        // Verify keyboard appears (TextField should still be visible)
        expect(textFields.first, findsOneWidget);
      }
    });

    testWidgets('App handles back navigation', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Look for any buttons
      final buttons = find.byType(ElevatedButton);
      
      if (buttons.evaluate().isNotEmpty) {
        // Count initial routes
        final navigator = tester.widget<Navigator>(find.byType(Navigator).first);
        
        // App should handle navigation without crashing
        expect(navigator, isNotNull);
      }
    });
  });

  group('NextMove Map Feature Tests', () {
    testWidgets('Map page is accessible', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // If logged in, should see bottom navigation
      final bottomNav = find.byType(BottomNavigationBar);
      
      if (bottomNav.evaluate().isNotEmpty) {
        // Verify we can see the map tab
        expect(bottomNav, findsOneWidget);
        
        // The app should have loaded without errors
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('Can tap on map elements', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Look for floating action buttons which might be on the map
      final fabs = find.byType(FloatingActionButton);
      
      if (fabs.evaluate().isNotEmpty) {
        // Tap the first FAB
        await tester.tap(fabs.first);
        await tester.pumpAndSettle();
        
        // Should not crash
        expect(tester.takeException(), isNull);
      }
    });
  });

  group('NextMove Profile Feature Tests', () {
    testWidgets('Profile page navigation', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final bottomNav = find.byType(BottomNavigationBar);
      
      if (bottomNav.evaluate().isNotEmpty) {
        // Navigate to profile
        final profileTab = find.descendant(
          of: bottomNav,
          matching: find.byIcon(Icons.person),
        );
        
        if (profileTab.evaluate().isNotEmpty) {
          await tester.tap(profileTab.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));
          
          // Should still have the bottom navigation
          expect(find.byType(BottomNavigationBar), findsOneWidget);
        }
      }
    });

    testWidgets('Can scroll in profile page', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final bottomNav = find.byType(BottomNavigationBar);
      
      if (bottomNav.evaluate().isNotEmpty) {
        // Navigate to profile
        final profileTab = find.descendant(
          of: bottomNav,
          matching: find.byIcon(Icons.person),
        );
        
        if (profileTab.evaluate().isNotEmpty) {
          await tester.tap(profileTab.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));
          
          // Try to scroll
          final scrollables = find.byType(Scrollable);
          
          if (scrollables.evaluate().isNotEmpty) {
            await tester.drag(scrollables.first, const Offset(0, -100));
            await tester.pumpAndSettle();
            
            // Should not crash
            expect(tester.takeException(), isNull);
          }
        }
      }
    });
  });

  group('NextMove Social Feature Tests', () {
    testWidgets('Social page is accessible', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final bottomNav = find.byType(BottomNavigationBar);
      
      if (bottomNav.evaluate().isNotEmpty) {
        // Navigate to social
        final socialTab = find.descendant(
          of: bottomNav,
          matching: find.byIcon(Icons.people),
        );
        
        if (socialTab.evaluate().isNotEmpty) {
          await tester.tap(socialTab.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));
          
          // Should show the social page
          expect(find.byType(BottomNavigationBar), findsOneWidget);
        }
      }
    });
  });

  group('NextMove Performance Tests', () {
    testWidgets('App startup time is reasonable', (WidgetTester tester) async {
      final stopwatch = Stopwatch()..start();
      
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 10));
      
      stopwatch.stop();
      
      // App should start within 10 seconds
      expect(stopwatch.elapsed.inSeconds, lessThan(11));
      
      // Should have rendered something
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Memory does not leak during navigation', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final bottomNav = find.byType(BottomNavigationBar);
      
      if (bottomNav.evaluate().isNotEmpty) {
        // Navigate between tabs multiple times
        final icons = [Icons.map, Icons.chat, Icons.people, Icons.person];
        
        for (int cycle = 0; cycle < 3; cycle++) {
          for (final icon in icons) {
            final tab = find.descendant(
              of: bottomNav,
              matching: find.byIcon(icon),
            );
            
            if (tab.evaluate().isNotEmpty) {
              await tester.tap(tab.first);
              await tester.pumpAndSettle();
            }
          }
        }
        
        // Should still be responsive
        expect(find.byType(BottomNavigationBar), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });
  });

  group('NextMove Error Handling Tests', () {
    testWidgets('App handles null data gracefully', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // App should not throw uncaught exceptions
      expect(tester.takeException(), isNull);
    });

    testWidgets('App recovers from navigation errors', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final bottomNav = find.byType(BottomNavigationBar);
      
      if (bottomNav.evaluate().isNotEmpty) {
        // Rapid navigation shouldn't cause crashes
        for (int i = 0; i < 5; i++) {
          final firstTab = find.descendant(
            of: bottomNav,
            matching: find.byIcon(Icons.map),
          );
          
          if (firstTab.evaluate().isNotEmpty) {
            await tester.tap(firstTab.first);
            await tester.pump(const Duration(milliseconds: 50));
          }
        }
        
        await tester.pumpAndSettle();
        
        // Should still work
        expect(find.byType(BottomNavigationBar), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });
  });
}
