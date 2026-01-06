import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/widgets/info_card_widget.dart';

void main() {
  Widget buildWidget({
    IconData icon = Icons.pedal_bike,
    String label = 'Bicicletas',
    String value = '5',
    Color color = Colors.blue,
    Color backgroundColor = Colors.white,
    ThemeData? theme,
  }) {
    return MaterialApp(
      theme: theme,
      home: Scaffold(
        body: InfoCard(
          icon: icon,
          label: label,
          value: value,
          color: color,
          backgroundColor: backgroundColor,
        ),
      ),
    );
  }

  group('InfoCard Widget Tests', () {
    testWidgets('should display icon, value and label correctly', (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.byIcon(Icons.pedal_bike), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('Bicicletas'), findsOneWidget);
    });

    testWidgets('should use correct colors', (WidgetTester tester) async {
      const testColor = Colors.orange;
      const testBackgroundColor = Colors.grey;

      await tester.pumpWidget(
        buildWidget(
          icon: Icons.electric_bike,
          color: testColor,
          backgroundColor: testBackgroundColor,
        ),
      );

      final iconWidget = tester.widget<Icon>(find.byIcon(Icons.electric_bike));
      expect(iconWidget.color, testColor);

      final containerWidget = tester.widget<Container>(
        find.byType(Container).first,
      );
      final decoration = containerWidget.decoration as BoxDecoration;
      expect(decoration.color, testBackgroundColor);
    });

    testWidgets('should display different values correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildWidget(
          icon: Icons.local_parking,
          label: 'Espacios libres',
          value: '15',
          color: Colors.green,
        ),
      );

      expect(find.text('15'), findsOneWidget);
      expect(find.text('Espacios libres'), findsOneWidget);
      expect(find.byIcon(Icons.local_parking), findsOneWidget);
    });

    testWidgets('should work in dark mode', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildWidget(
          theme: ThemeData.dark(),
          value: '3',
          backgroundColor: Colors.grey[800]!,
        ),
      );

      expect(find.text('3'), findsOneWidget);
      expect(find.text('Bicicletas'), findsOneWidget);
      expect(find.byIcon(Icons.pedal_bike), findsOneWidget);
    });

    testWidgets('should have correct structure with Column layout', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildWidget(
          icon: Icons.electric_bike,
          label: 'Test Label',
          value: 'Test Value',
          color: Colors.red,
        ),
      );

      expect(find.byType(Column), findsWidgets);
      expect(find.byType(Container), findsWidgets);
    });
  });
}
