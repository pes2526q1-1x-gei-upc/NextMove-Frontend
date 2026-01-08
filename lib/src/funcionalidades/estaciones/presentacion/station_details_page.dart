import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/src/funcionalidades/assessments/data/repositories/assessment_repository.dart';
import 'package:nextmove_app/src/funcionalidades/assessments/presentation/bloc/assessment_event.dart';
import 'package:nextmove_app/src/funcionalidades/assessments/presentation/bloc/assessment_state.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/station_model.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/stations_cache.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/presentacion/bloc/station_details_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/presentacion/widgets/station_connectors_widget.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/presentacion/widgets/station_features_widget.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/presentacion/widgets/station_header_widget.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/presentacion/widgets/station_shared_widgets.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/presentacion/widgets/station_stats_widget.dart';
import 'package:nextmove_app/src/funcionalidades/assessments/presentation/bloc/assessment_bloc.dart';

class StationDetailsPage extends StatelessWidget {
  final StationType stationType;
  final String stationID;
  final StationDetails? stationDetails;

  const StationDetailsPage({
    super.key,
    required this.stationType,
    required this.stationID,
    this.stationDetails,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => StationDetailsBloc(context.read<StationsCache>())
            ..add(LoadStationDetailsEvent(stationID, stationType, stationDetails)),
        ),
        BlocProvider(
          create: (context) =>
              AssessmentBloc(assessmentRepository: AssessmentRepository())
                ..add(GetStationAssessmentInfoEvent(stationId: stationID))
                ..add(CheckAssessedEvent(stationId: stationID)),
        ),
      ],
      child: BlocBuilder<StationDetailsBloc, StationDetailsState>(
        builder: (context, state) {
          if (state is StationDetailsLoading) {
            return Scaffold(
              body: const Center(child: CircularProgressIndicator()),
            );
          } else if (state is StationDetailsError) {
            return Scaffold(
              appBar: AppBar(title: Text(l10n.error)),
              body: Center(child: Text(state.message)),
            );
          } else if (state is StationDetailsLoaded) {
            return _buildDetailsPage(context, state.stationDetails);
          } else {
            return Scaffold(
              body: Center(child: Text(l10n.unknownState)),
            );
          }
        },
      ),
    );
  }

  Widget _buildDetailsPage(
    BuildContext context,
    StationDetails stationDetails,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final isBike = stationType == StationType.bicycle;
    final theme = Theme.of(context);
    final themeColor =
        isBike ? theme.colorScheme.secondary : theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.information,
          style: theme.textTheme.titleLarge?.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BlocBuilder<AssessmentBloc, AssessmentState>(
                builder: (context, assessmentState) {
                  final displayStation = (assessmentState.totalAssessments > 0)
                      ? stationDetails.copyWith(
                          rating: assessmentState.averageScore,
                        )
                      : stationDetails;

                  return StationHeaderWidget(
                    station: displayStation,
                    themeColor: themeColor,
                    onToggleFavorite: () => context.read<StationDetailsBloc>().add(
                      ToggleFavoriteEvent(displayStation.id),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              SectionLabel(text: l10n.state),
              StationStatsWidget(station: stationDetails, isBike: isBike),
              const SizedBox(height: 24),

              SectionLabel(text: l10n.accountDetails),
              StationFeaturesWidget(station: stationDetails, isBike: isBike),
              const SizedBox(height: 24),

              if (!isBike && stationDetails is EVStationDetails)
                StationConnectorsWidget(details: stationDetails),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
