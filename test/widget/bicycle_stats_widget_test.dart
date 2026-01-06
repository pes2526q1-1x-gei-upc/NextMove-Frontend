import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/station_model.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/widgets/bicycle_stats_widget.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/widgets/info_card_widget.dart';

void main() {
  Widget appWith(BicycleStationDetails station) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('es'),
      home: Scaffold(
        body: BicycleStatsWidget(station: station),
      ),
    );
  }

  testWidgets('renders available values', (tester) async {
    final station = BicycleStationDetails(
      id: '1',
      availableMechanicalBikes: 5,
      availableElectricBikes: 3,
      availableSlots: 7,
    );

    await tester.pumpWidget(appWith(station));

    expect(find.byType(InfoCard), findsNWidgets(3));
    expect(find.text('5'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('7'), findsOneWidget);
  });

  testWidgets('shows hyphen when values are null', (tester) async {
    final station = BicycleStationDetails(id: '1');

    await tester.pumpWidget(appWith(station));

    expect(find.text('-'), findsNWidgets(3));
  });
}
