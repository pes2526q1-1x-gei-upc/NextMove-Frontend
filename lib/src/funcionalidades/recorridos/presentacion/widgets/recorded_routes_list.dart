import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/src/funcionalidades/auth/dominio/providers/user_provider.dart';
import 'package:nextmove_app/src/funcionalidades/recorridos/presentacion/bloc/route_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/recorridos/presentacion/widgets/recorded_route_statistics.dart';
import 'package:provider/provider.dart';
import '../bloc/route_events.dart';
import '../bloc/route_state.dart';

class RouteHistoryList extends StatelessWidget {
  const RouteHistoryList({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final String userEmail = userProvider.email!;
    return BlocProvider(
      create: (context) => RouteBloc()
        ..add(LoadRecordedRoutesEvent(userEmail)),
      child: BlocBuilder<RouteBloc, RouteState>(
        builder: (context, state) {
          if (state is RouteLoadingState) {
            return Scaffold(
              appBar: AppBar(
                title: Text(l10n.routeHistory),
                elevation: 0,
              ),
              body: const Center(child: CircularProgressIndicator()),
            );
          } else if (state is RouteErrorState) {
            return Scaffold(
              appBar: AppBar(
                title: Text(l10n.routeHistory),
                elevation: 0,
              ),
              body: Center(child: Text('${l10n.error}: ${state.message}')),
            );
          } else if (state is RouteLoadedState) {
            final recorridos = state.recordedRoutes;

            if (recorridos.isEmpty) {
              return Scaffold(
                appBar: AppBar(
                  title: Text(l10n.routeHistory),
                  elevation: 0,
                ),
                body: Center(
                  child: Text(l10n.noRoutesFound),
                ),
              );
            }

            return Scaffold(
              appBar: AppBar(
                title: Text(l10n.routeHistory),
                elevation: 0,
              ),
              body: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                itemCount: recorridos.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, i) {
                  final recorrido = recorridos[i];
                  return _RouteCard(
                    recorrido: recorrido,
                    l10n: l10n,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => RecordedRouteStatistics(track: recorrido),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          } else {
            return Scaffold(
              appBar: AppBar(
                title: Text(l10n.routeHistory),
                elevation: 0,
              ),
              body: Center(child: Text(l10n.unknownState)),
            );
          }
        },
      ),
    );
  }
}

class _RouteCard extends StatelessWidget {
  final dynamic recorrido;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  const _RouteCard({
    required this.recorrido,
    required this.l10n,
    required this.onTap,
  });

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    
    if (dateOnly == today) {
      return 'Hoy, ${DateFormat('HH:mm').format(date)}';
    } else if (dateOnly == today.subtract(const Duration(days: 1))) {
      return 'Ayer, ${DateFormat('HH:mm').format(date)}';
    } else {
      return DateFormat('dd/MM/yyyy, HH:mm').format(date);
    }
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return '';
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}min';
    }
    return '${minutes}min';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final mainColor = Colors.purple;
    final iconBgColor = mainColor.withValues(alpha: isDark ? 0.2 : 0.1);
    
    final distanceKm = (recorrido.distance / 1000).toStringAsFixed(2);
    final avgSpeed = recorrido.averageSpeed?.toStringAsFixed(1) ?? 'N/A';
    final maxSpeed = recorrido.maxSpeed?.toStringAsFixed(1);
    final duration = recorrido.startTime != null && recorrido.endTime != null
        ? recorrido.endTime!.difference(recorrido.startTime!)
        : null;
    
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Container
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.route,
                    color: mainColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date/Time (Title)
                      Text(
                        _formatDate(recorrido.timestamp.toLocal()),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 8),

                      // Stats Row
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          // Distance Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: mainColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: mainColor.withValues(alpha: 0.5),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.straighten,
                                  size: 14,
                                  color: mainColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '$distanceKm km',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: mainColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Average Speed Badge
                          if (recorrido.averageSpeed != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.speed,
                                    size: 14,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$avgSpeed km/h',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          
                          // Duration Badge
                          if (duration != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 14,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatDuration(duration),
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      
                      // Additional stats
                      if (recorrido.co2 != null || recorrido.kcal != null || maxSpeed != null) ...[
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            if (recorrido.co2 != null)
                              Text(
                                'CO₂: ${recorrido.co2!.toStringAsFixed(2)} kg',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.secondary,
                                ),
                              ),
                            if (recorrido.kcal != null)
                              Text(
                                '${recorrido.kcal!.toStringAsFixed(0)} kcal',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.secondary,
                                ),
                              ),
                            if (maxSpeed != null)
                              Text(
                                'Max: $maxSpeed km/h',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.secondary,
                                ),
                              ),
                          ],
                        ),
                      ],
                      
                      // Elevation info
                      if (recorrido.elevationGain != null || recorrido.elevationLoss != null) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            if (recorrido.elevationGain != null) ...[
                              Icon(
                                Icons.trending_up,
                                size: 12,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '+${recorrido.elevationGain!.toStringAsFixed(0)}m',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: Colors.green,
                                ),
                              ),
                            ],
                            if (recorrido.elevationGain != null && recorrido.elevationLoss != null)
                              const SizedBox(width: 12),
                            if (recorrido.elevationLoss != null) ...[
                              Icon(
                                Icons.trending_down,
                                size: 12,
                                color: Colors.red,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '-${recorrido.elevationLoss!.toStringAsFixed(0)}m',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Arrow Icon
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
