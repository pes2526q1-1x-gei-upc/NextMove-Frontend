import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/src/funcionalidades/profile/domain/entities/user_entity.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/widgets/profile_form_widget.dart';
import 'package:nextmove_app/src/funcionalidades/social/presentation/widgets/profile_info_row_widget.dart';

class FriendDetailsContent extends StatelessWidget {
  final UserEntity user;

  const FriendDetailsContent({super.key, required this.user});

  // Helper para normalizar el modo de transporte
  bool _isBike(String mode) {
    final m = mode.toUpperCase();
    return m == 'BIKE' || m == 'BICICLETA' || m == 'BICI';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasPhoto = user.photo.isNotEmpty;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final muted = theme.colorScheme.outline;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          
          // --- AVATAR Y NOMBRE ---
          Center(
            child: Column(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: theme.cardColor, width: 4),
                    boxShadow: isDark
                        ? null
                        : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                    color: theme.colorScheme.surfaceContainerHighest,
                    image: hasPhoto 
                        ? DecorationImage(
                            image: NetworkImage(user.photo),
                            fit: BoxFit.cover,
                            onError: (exception, stackTrace) {
                               debugPrint("Error cargando foto detalle: $exception");
                            },
                          )
                        : null,
                  ),
                  // Si no hay foto o falla, mostramos el icono
                  child: !hasPhoto 
                      ? Icon(
                          Icons.person,
                          size: 60,
                          color: theme.iconTheme.color?.withValues(alpha: 0.8),
                        )
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  user.nombreCompleto,
                  style: theme.textTheme.headlineSmall?.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                if (user.apodo.isNotEmpty)
                  Text(
                    "@${user.apodo}",
                    style: TextStyle(
                      fontSize: 16,
                      color: muted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // --- SECCIÓN: INFORMACIÓN ---
          ProfileSectionLabel(text: l10n.information),
          ProfileStyledCard(
            children: [
              ProfileInfoRowWidget(
                icon: Icons.email_outlined,
                label: l10n.emailAddress,
                value: user.email,
              ),
              if (user.descripcion.isNotEmpty) ...[
                Divider(
                  height: 1,
                  indent: 50,
                  color: theme.dividerColor,
                ),
                ProfileInfoRowWidget(
                  icon: Icons.description_outlined,
                  label: l10n.userDescription,
                  value: user.descripcion,
                ),
              ],
              Divider(height: 1, indent: 50, color: theme.dividerColor),
              ProfileInfoRowWidget(
                icon: Icons.cake_outlined,
                label: l10n.birthdate,
                value: DateFormat('dd/MM/yyyy').format(user.fechaNacimiento),
              ),
              Divider(height: 1, indent: 50, color: theme.dividerColor),
              ProfileInfoRowWidget(
                icon: Icons.calendar_month_outlined,
                label: l10n.memberSince,
                value: DateFormat('MMMM yyyy').format(user.fechaRegistro),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // --- SECCIÓN: PREFERENCIAS ---
          ProfileSectionLabel(text: l10n.preferredMode),
          ProfileStyledCard(
            children: [
              ProfileInfoRowWidget(
                icon: _isBike(user.modoPreferido)
                    ? Icons.directions_bike 
                    : Icons.electric_car,
                label: l10n.preferredMode,
                value: _isBike(user.modoPreferido) ? l10n.bicycle : l10n.car,
              ),
              Divider(height: 1, indent: 50, color: theme.dividerColor),
              ProfileInfoRowWidget(
                icon: Icons.language,
                label: l10n.preferredLanguage,
                value: user.idiomaPreferido,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // --- SECCIÓN: ESTADÍSTICAS ---
          ProfileSectionLabel(text: "Statistics"),
          user.statistics != null
              ? _StatisticsGrid(statistics: user.statistics!)
              : _NoStatisticsMessage(),
            
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _StatisticsGrid extends StatelessWidget {
  final UserStatistics statistics;

  const _StatisticsGrid({required this.statistics});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Debug: print statistics data
    debugPrint('_StatisticsGrid: statistics = $statistics');

    final statItems = [
      _StatItem(
        icon: Icons.route,
        label: l10n.numberOfRoutes,
        value: '${statistics.totalRoutes}',
        color: Colors.blue,
      ),
      _StatItem(
        icon: Icons.straighten,
        label: l10n.distance,
        value: '${statistics.distance.toStringAsFixed(1)} km',
        color: Colors.green,
      ),
      _StatItem(
        icon: Icons.trending_up,
        label: l10n.elevationGain,
        value: '${statistics.elevationGain.toStringAsFixed(0)} m',
        color: Colors.orange,
      ),
      _StatItem(
        icon: Icons.local_fire_department,
        label: l10n.caloriesBurned,
        value: '${statistics.caloriesBurned.toStringAsFixed(0)} kcal',
        color: Colors.red,
      ),
      _StatItem(
        icon: Icons.eco,
        label: l10n.co2Saved,
        value: '${statistics.co2Saved.toStringAsFixed(1)} kg',
        color: Colors.teal,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      padding: const EdgeInsets.all(16),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: statItems.map((item) => _StatCard(item: item)).toList(),
      ),
    );
  }
}

class _StatItem {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
}

class _StatCard extends StatelessWidget {
  final _StatItem item;

  const _StatCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              item.icon,
              color: item.color,
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            item.label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _NoStatisticsMessage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.bar_chart_outlined,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noStatisticsAvailable,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}