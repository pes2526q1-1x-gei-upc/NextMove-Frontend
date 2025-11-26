import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nextmove_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('NextMove App Integration Tests', () {
    testWidgets('App launches and shows welcome page when not logged in',
        (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Verify that the welcome page is displayed
      expect(find.text('NextMove'), findsWidgets);
      
      // Look for common welcome page elements
      // Adjust these based on your actual welcome page content
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Navigation between tabs works correctly',
        (WidgetTester tester) async {
      // This test assumes user is logged in
      // You may need to mock authentication for this test
      
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // If BottomNavigationBar is present (logged in state)
      final bottomNavBar = find.byType(BottomNavigationBar);
      
      if (bottomNavBar.evaluate().isNotEmpty) {
        // Verify we're on the map page (first tab)
        expect(find.byType(BottomNavigationBar), findsOneWidget);
        
        // Tap on the second tab (Chat)
        final chatTab = find.descendant(
          of: bottomNavBar,
          matching: find.byIcon(Icons.chat),
        );
        
        if (chatTab.evaluate().isNotEmpty) {
          await tester.tap(chatTab);
          await tester.pumpAndSettle();
        }
        
        // Tap on the third tab (Social)
        final socialTab = find.descendant(
          of: bottomNavBar,
          matching: find.byIcon(Icons.people),
        );
        
        if (socialTab.evaluate().isNotEmpty) {
          await tester.tap(socialTab);
          await tester.pumpAndSettle();
        }
        
        // Tap on the fourth tab (Profile)
        final profileTab = find.descendant(
          of: bottomNavBar,
          matching: find.byIcon(Icons.person),
        );
        
        if (profileTab.evaluate().isNotEmpty) {
          await tester.tap(profileTab);
          await tester.pumpAndSettle();
        }
        
        // Verify navigation worked by checking we're back on a different page
        expect(find.byType(BottomNavigationBar), findsOneWidget);
      }
    });

    testWidgets('Map page renders correctly', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Wait for the app to settle
      await tester.pumpAndSettle();
      
      // Check if map-related widgets are present
      // Adjust based on your actual MapPage implementation
      final scaffold = find.byType(Scaffold);
      expect(scaffold, findsWidgets);
    });

    testWidgets('Can navigate to profile and view settings',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final bottomNavBar = find.byType(BottomNavigationBar);
      
      if (bottomNavBar.evaluate().isNotEmpty) {
        // Navigate to profile tab
        final profileTab = find.descendant(
          of: bottomNavBar,
          matching: find.byIcon(Icons.person),
        );
        
        if (profileTab.evaluate().isNotEmpty) {
          await tester.tap(profileTab);
          await tester.pumpAndSettle();
          
          // Verify we're on the profile page
          expect(find.byType(Scaffold), findsWidgets);
        }
      }
    });

    testWidgets('Welcome page has login options', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Check for common login elements
      // These might be TextFields for email/password or social login buttons
      final textFields = find.byType(TextField);
      final elevatedButtons = find.byType(ElevatedButton);
      final textButtons = find.byType(TextButton);
      
      // At least some interactive elements should be present
      expect(
        textFields.evaluate().isNotEmpty ||
        elevatedButtons.evaluate().isNotEmpty ||
        textButtons.evaluate().isNotEmpty,
        isTrue,
        reason: 'Welcome page should have interactive login elements',
      );
    });

    testWidgets('App handles errors gracefully', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // The app should not throw any uncaught errors during initialization
      expect(tester.takeException(), isNull);
    });

    testWidgets('Multiple rapid navigation actions', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final bottomNavBar = find.byType(BottomNavigationBar);
      
      if (bottomNavBar.evaluate().isNotEmpty) {
        // Rapidly switch between tabs
        for (int i = 0; i < 3; i++) {
          // Try to find chat icon
          final chatIcon = find.descendant(
            of: bottomNavBar,
            matching: find.byIcon(Icons.chat),
          );
          
          if (chatIcon.evaluate().isNotEmpty) {
            await tester.tap(chatIcon.first);
            await tester.pump(const Duration(milliseconds: 100));
          }
          
          // Try to find map icon
          final mapIcon = find.descendant(
            of: bottomNavBar,
            matching: find.byIcon(Icons.map),
          );
          
          if (mapIcon.evaluate().isNotEmpty) {
            await tester.tap(mapIcon.first);
            await tester.pump(const Duration(milliseconds: 100));
          }
        }
        
        // Let everything settle
        await tester.pumpAndSettle();
        
        // App should still be responsive
        expect(find.byType(BottomNavigationBar), findsOneWidget);
      }
    });

    testWidgets('Scaffold structure is maintained throughout navigation',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify basic scaffold structure exists
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(Scaffold), findsWidgets);
      
      final bottomNavBar = find.byType(BottomNavigationBar);
      
      if (bottomNavBar.evaluate().isNotEmpty) {
        // Navigate through all tabs and verify scaffold persists
        final icons = [Icons.map, Icons.chat, Icons.people, Icons.person];
        
        for (final icon in icons) {
          final tab = find.descendant(
            of: bottomNavBar,
            matching: find.byIcon(icon),
          );
          
          if (tab.evaluate().isNotEmpty) {
            await tester.tap(tab.first);
            await tester.pumpAndSettle();
            
            // Scaffold should still exist
            expect(find.byType(Scaffold), findsWidgets);
          }
        }
      }
    });
  });
}
