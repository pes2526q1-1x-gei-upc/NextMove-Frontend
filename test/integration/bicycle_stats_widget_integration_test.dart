import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/station_model.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/widgets/bicycle_stats_widget.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/widgets/info_card_widget.dart';

/// Test de integración que prueba cómo BicycleStatsWidget integra
/// StationDetails con InfoCard para mostrar estadísticas.
void main() {
  group('BicycleStatsWidget Integration Tests', () {
    Widget buildWidget(BicycleStationDetails station) {
      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('es'),
        home: Scaffold(
          body: BicycleStatsWidget(station: station),
        ),
      );
    }

    testWidgets('should integrate station data with InfoCard widgets', (WidgetTester tester) async {
      // Arrange: Crear datos de estación de bicicletas
      final station = BicycleStationDetails(
        id: 'station-1',
        name: 'Estación Test',
        availableMechanicalBikes: 5,
        availableElectricBikes: 3,
        availableSlots: 10,
      );

      // Act: Renderizar el widget con los datos de la estación
      await tester.pumpWidget(buildWidget(station));

      // Assert: Verificar que el widget integra correctamente los datos
      // y los muestra a través de los InfoCard widgets

      // Verificar que se muestran los 3 InfoCard (mecánicas, eléctricas, slots)
      expect(find.byType(InfoCard), findsNWidgets(3));

      // Verificar que los valores de la estación se muestran correctamente
      expect(find.text('5'), findsOneWidget); // Bicicletas mecánicas
      expect(find.text('3'), findsOneWidget); // Bicicletas eléctricas
      expect(find.text('10'), findsOneWidget); // Slots libres

      // Verificar que los iconos correctos se muestran
      expect(find.byIcon(Icons.pedal_bike_rounded), findsOneWidget);
      expect(find.byIcon(Icons.electric_bike_rounded), findsOneWidget);
      expect(find.byIcon(Icons.local_parking_rounded), findsOneWidget);
    });

    testWidgets('should handle null values in station data correctly', (WidgetTester tester) async {
      // Arrange: Crear estación con valores null
      final station = BicycleStationDetails(
        id: 'station-2',
        name: 'Estación Sin Datos',
        availableMechanicalBikes: null,
        availableElectricBikes: null,
        availableSlots: null,
      );

      // Act: Renderizar el widget
      await tester.pumpWidget(buildWidget(station));

      // Assert: Verificar que el widget maneja correctamente los valores null
      // y muestra "-" como valor por defecto
      expect(find.text('-'), findsNWidgets(3)); // Los 3 campos muestran "-"
      expect(find.byType(InfoCard), findsNWidgets(3));
    });

    testWidgets('should integrate with theme colors correctly', (WidgetTester tester) async {
      // Arrange: Crear estación y usar tema personalizado
      final station = BicycleStationDetails(
        id: 'station-3',
        availableMechanicalBikes: 8,
        availableElectricBikes: 4,
        availableSlots: 12,
      );

      // Act: Renderizar con tema claro
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('es'),
          home: Scaffold(
            body: BicycleStatsWidget(station: station),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert: Verificar que el widget se integra correctamente con el tema
      // y obtiene el cardColor del tema
      expect(find.byType(BicycleStatsWidget), findsOneWidget);
      expect(find.byType(InfoCard), findsNWidgets(3));

      // Verificar que los colores de los iconos son correctos
      final mechanicalIcon = tester.widget<Icon>(find.byIcon(Icons.pedal_bike_rounded));
      expect(mechanicalIcon.color, Colors.orange);

      final electricIcon = tester.widget<Icon>(find.byIcon(Icons.electric_bike_rounded));
      expect(electricIcon.color, Colors.blue);

      final slotsIcon = tester.widget<Icon>(find.byIcon(Icons.local_parking_rounded));
      expect(slotsIcon.color, Colors.grey);
    });

    testWidgets('should integrate with different station data values', (WidgetTester tester) async {
      // Arrange: Crear estación con diferentes valores
      final station = BicycleStationDetails(
        id: 'station-4',
        availableMechanicalBikes: 7,
        availableElectricBikes: 5,
        availableSlots: 15,
      );

      await tester.pumpWidget(buildWidget(station));
      await tester.pumpAndSettle();

      // Assert: Verificar que el widget muestra correctamente los diferentes valores
      expect(find.text('7'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('15'), findsOneWidget);
      expect(find.byType(InfoCard), findsNWidgets(3));
    });
  });
}

