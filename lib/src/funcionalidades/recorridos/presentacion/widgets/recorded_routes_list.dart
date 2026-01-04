import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/src/core/theme/app_theme.dart';
import 'package:nextmove_app/src/funcionalidades/auth/dominio/providers/user_provider.dart';
import 'package:nextmove_app/src/funcionalidades/recorridos/domain/recorded_route.dart';
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
              ),
              body: const Center(child: CircularProgressIndicator()),
            );
          } else if (state is RouteErrorState) {
            return Scaffold(
              appBar: AppBar(
                title: Text(l10n.routeHistory),
              ),
              body: Center(child: Text('${l10n.error}: ${state.message}')),
            );
          } else if (state is RouteLoadedState) {
            final recorridos = state.recordedRoutes;

            if (recorridos.isEmpty) {
              return Scaffold(
                appBar: AppBar(
                  title: Text(l10n.routeHistory),
                ),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.route_outlined,
                        size: 64,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.noRoutesFound,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
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
                  return _RecordedRouteCard(
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
              ),
              body: Center(child: Text(l10n.unknownState)),
            );
          }
        },
      ),
    );
  }
}

class _RecordedRouteCard extends StatelessWidget {
  final RecordedRoute recorrido;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  const _RecordedRouteCard({
    required this.recorrido,
    required this.l10n,
    required this.onTap,
  });

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String _formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  String _formatDuration(DateTime? start, DateTime? end) {
    if (start == null || end == null) return '-';
    final duration = end.difference(start);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}min';
    }
    return '${minutes}min';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
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
                    color: Colors.blue.withValues(alpha: isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.route_rounded,
                    color: Colors.blue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date and Time
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 14,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(recorrido.timestamp),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatTime(recorrido.timestamp),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 8),

                      // Distance
                      Row(
                        children: [
                          Icon(
                            Icons.straighten_rounded,
                            size: 16,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${((recorrido.distance)/1000).toStringAsFixed(2)} km',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 6),

                      // Average Speed
                      if (recorrido.averageSpeed != null)
                        Row(
                          children: [
                            Icon(
                              Icons.speed_rounded,
                              size: 16,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${l10n.averageSpeed}: ${recorrido.averageSpeed!.toStringAsFixed(1)} km/h',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      
                      const SizedBox(height: 6),

                      // Duration
                      if (recorrido.startTime != null && recorrido.endTime != null)
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 16,
                              color: Colors.purple,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _formatDuration(recorrido.startTime, recorrido.endTime),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                
                // Arrow icon
                Icon(
                  Icons.chevron_right_rounded,
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
