import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/src/funcionalidades/alerts/presentacion/bloc/alert_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/alerts/presentacion/pages/create_alert_page.dart';

class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  @override
  void initState() {
    super.initState();
    context.read<AlertBloc>().add(LoadAlertsEvent());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new),
          iconSize: 22,
        ),
        title: Text(
          l10n.stationAlertsTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontSize: 26,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: BlocConsumer<AlertBloc, AlertState>(
          listener: (context, state) {
            if (state is AlertError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is AlertLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is AlertLoaded) {
              if (state.alerts.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_off_outlined,
                        size: 60,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.noAlertsConfigured,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.createAlertMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount: state.alerts.length,
                      itemBuilder: (context, index) {
                        final alert = state.alerts[index];
                        return _AlertCard(
                          alert: alert,
                          onToggle: (activa) {
                            context.read<AlertBloc>().add(
                              ToggleAlertEvent(id: alert.id, activa: activa),
                            );
                          },
                          onEdit: () {
                            final alertBloc = context.read<AlertBloc>();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BlocProvider.value(
                                  value: alertBloc,
                                  child: CreateAlertPage(alert: alert),
                                ),
                              ),
                            ).then((_) {
                              alertBloc.add(LoadAlertsEvent());
                            });
                          },
                          onDelete: () {
                            final alertBloc = context.read<AlertBloc>();
                            _showDeleteDialog(context, alert.id, alertBloc);
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            }

            if (state is AlertError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 60,
                      color: Colors.red[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.red[500],
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<AlertBloc>().add(LoadAlertsEvent());
                      },
                      child: Text(l10n.retry),
                    ),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
      floatingActionButton: Builder(
        builder: (context) {
          final l10nBuilder = AppLocalizations.of(context)!;
          return FloatingActionButton.extended(
            onPressed: () {
              final alertBloc = context.read<AlertBloc>();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider.value(
                    value: alertBloc,
                    child: const CreateAlertPage(),
                  ),
                ),
              ).then((_) {
                alertBloc.add(LoadAlertsEvent());
              });
            },
            icon: const Icon(Icons.add),
            label: Text(l10nBuilder.newAlert),
          );
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String alertId, AlertBloc alertBloc) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteAlert),
        content: Text(l10n.deleteAlertConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              alertBloc.add(DeleteAlertEvent(id: alertId));
              Navigator.pop(context);
            },
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final dynamic alert;
  final Function(bool) onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AlertCard({
    required this.alert,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  /// Obtiene el nombre de la estación para mostrar, con fallback si no está disponible
  String _getStationDisplayName(dynamic alert, AppLocalizations l10n) {
    // Si hay un nombre de estación válido y no es solo el ID, usarlo
    if (alert.stationNombre != null && 
        alert.stationNombre!.isNotEmpty && 
        alert.stationNombre != alert.stationId) {
      return alert.stationNombre!;
    }
    
    // Si hay dirección, usar una parte de ella como nombre
    if (alert.stationDireccion != null && alert.stationDireccion!.isNotEmpty) {
      // Extraer el nombre de la calle de la dirección (antes de la coma o número)
      final addressParts = alert.stationDireccion!.split(',');
      if (addressParts.isNotEmpty) {
        final streetName = addressParts[0].trim();
        if (streetName.isNotEmpty) {
          return streetName;
        }
      }
    }
    
    // Fallback: mostrar "Estación" seguido del ID
    return '${l10n.stationPrefix} ${alert.stationId}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    // Mapear los números de días (0=Lunes, 6=Domingo) a los nombres traducidos
    final diasSemanaList = (alert.diasSemana as List).map<int>((dia) {
      if (dia is int) return dia;
      return int.parse(dia.toString());
    }).toList();
    
    final diasNombresList = diasSemanaList.map<String>((dia) {
      switch (dia) {
        case 0:
          return l10n.monday;
        case 1:
          return l10n.tuesday;
        case 2:
          return l10n.wednesday;
        case 3:
          return l10n.thursday;
        case 4:
          return l10n.friday;
        case 5:
          return l10n.saturday;
        case 6:
          return l10n.sunday;
        default:
          return '';
      }
    }).toList();
    final diasNombres = diasNombresList.where((nombre) => nombre.isNotEmpty).join(', ');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: theme.brightness == Brightness.dark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _getStationDisplayName(alert, l10n),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Switch(
                  value: alert.activa,
                  onChanged: onToggle,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  alert.horas.join(', '),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    diasNombres,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, size: 18),
                  label: Text(l10n.edit),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete, size: 18),
                  label: Text(l10n.delete),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

