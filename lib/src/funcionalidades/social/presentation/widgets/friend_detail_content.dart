import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/src/funcionalidades/profile/domain/entities/user_entity.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/widgets/profile_form_widget.dart';
import 'package:nextmove_app/src/funcionalidades/social/presentation/widgets/profile_info_row_widget.dart';

enum _ProfileViewMode { personal, statistics }

class FriendDetailsContent extends StatefulWidget {
  final UserEntity user;

  const FriendDetailsContent({super.key, required this.user});

  @override
  State<FriendDetailsContent> createState() => _FriendDetailsContentState();
}

class _FriendDetailsContentState extends State<FriendDetailsContent> {
  _ProfileViewMode _selectedMode = _ProfileViewMode.personal;

  // Helper para normalizar el modo de transporte
  bool _isBike(String mode) {
    final m = mode.toUpperCase();
    return m == 'BIKE' || m == 'BICICLETA' || m == 'BICI';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasPhoto = widget.user.photo.isNotEmpty;
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
                            image: NetworkImage(widget.user.photo),
                            fit: BoxFit.cover,
                            onError: (exception, stackTrace) {
                              debugPrint(
                                "Error cargando foto detalle: $exception",
                              );
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
                  widget.user.nombreCompleto,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (widget.user.apodo.isNotEmpty)
                  Text(
                    "@${widget.user.apodo}",
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

          // --- TOGGLE: INFORMACIÓN / ESTADÍSTICAS ---
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                Expanded(
                  child: _ToggleButton(
                    label: l10n.information,
                    icon: Icons.person_outline,
                    isSelected: _selectedMode == _ProfileViewMode.personal,
                    onTap: () {
                      setState(() {
                        _selectedMode = _ProfileViewMode.personal;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: _ToggleButton(
                    label: l10n.myStatistics,
                    icon: Icons.bar_chart,
                    isSelected: _selectedMode == _ProfileViewMode.statistics,
                    onTap: () {
                      setState(() {
                        _selectedMode = _ProfileViewMode.statistics;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          if (_selectedMode == _ProfileViewMode.personal) ...[
            // --- SECCIÓN: INFORMACIÓN ---
            ProfileSectionLabel(text: l10n.information),
            ProfileStyledCard(
              children: [
                ProfileInfoRowWidget(
                  icon: Icons.email_outlined,
                  label: l10n.emailAddress,
                  value: widget.user.email,
                ),
                if (widget.user.descripcion.isNotEmpty) ...[
                  Divider(height: 1, indent: 50, color: theme.dividerColor),
                  ProfileInfoRowWidget(
                    icon: Icons.description_outlined,
                    label: l10n.userDescription,
                    value: widget.user.descripcion,
                  ),
                ],
                Divider(height: 1, indent: 50, color: theme.dividerColor),
                ProfileInfoRowWidget(
                  icon: Icons.cake_outlined,
                  label: l10n.birthdate,
                  value: DateFormat(
                    'dd/MM/yyyy',
                  ).format(widget.user.fechaNacimiento),
                ),
                Divider(height: 1, indent: 50, color: theme.dividerColor),
                ProfileInfoRowWidget(
                  icon: Icons.calendar_month_outlined,
                  label: l10n.memberSince,
                  value: DateFormat(
                    'MMMM yyyy',
                  ).format(widget.user.fechaRegistro),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // --- SECCIÓN: PREFERENCIAS ---
            ProfileSectionLabel(text: l10n.preferredMode),
            ProfileStyledCard(
              children: [
                ProfileInfoRowWidget(
                  icon: _isBike(widget.user.modoPreferido)
                      ? Icons.directions_bike
                      : Icons.electric_car,
                  label: l10n.preferredMode,
                  value: _isBike(widget.user.modoPreferido)
                      ? l10n.bicycle
                      : l10n.car,
                ),
                Divider(height: 1, indent: 50, color: theme.dividerColor),
                ProfileInfoRowWidget(
                  icon: Icons.language,
                  label: l10n.preferredLanguage,
                  value: widget.user.idiomaPreferido,
                ),
              ],
            ),
          ] else ...[
            // --- SECCIÓN: ESTADÍSTICAS ---
            if (widget.user.statistics != null) ...[
              // Points
              _buildSectionCard(
                context,
                icon: Icons.stars,
                iconColor: Colors.amber,
                title: l10n.totalPoints,
                isDark: isDark,
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        context,
                        icon: Icons.emoji_events,
                        label: l10n.totalPoints,
                        value: '${widget.user.statistics!.points}',
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Main Statistics Row
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      icon: Icons.route,
                      title: l10n.numberOfRoutes,
                      value: '${widget.user.statistics!.totalRoutes}',
                      color: Colors.blue,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      icon: Icons.straighten,
                      title: l10n.distance,
                      value:
                          '${widget.user.statistics!.distance.toStringAsFixed(2)} km',
                      color: Colors.purple,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Environmental Impact
              _buildSectionCard(
                context,
                icon: Icons.eco,
                iconColor: Colors.green,
                title: l10n.environmentalImpact,
                isDark: isDark,
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        context,
                        icon: Icons.cloud_queue,
                        label: l10n.co2Saved,
                        value:
                            '${widget.user.statistics!.co2Saved.toStringAsFixed(2)} kg',
                        color: Colors.blue,
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        context,
                        icon: Icons.local_fire_department,
                        label: l10n.caloriesBurned,
                        value:
                            '${widget.user.statistics!.caloriesBurned.toStringAsFixed(0)} kcal',
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Elevation
              _buildSectionCard(
                context,
                icon: Icons.terrain,
                iconColor: Colors.brown,
                title: l10n.elevation,
                isDark: isDark,
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        context,
                        icon: Icons.trending_up,
                        label: l10n.elevationGain,
                        value:
                            '${widget.user.statistics!.elevationGain.toStringAsFixed(1)} m',
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Challenges
              _buildSectionCard(
                context,
                icon: Icons.emoji_events,
                iconColor: Colors.amber,
                title: l10n.challenges,
                isDark: isDark,
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        context,
                        icon: Icons.group,
                        label: l10n.challengesParticipated,
                        value:
                            '${widget.user.statistics!.challengesParticipated.toInt()}',
                        color: Colors.blue,
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        context,
                        icon: Icons.check_circle,
                        label: l10n.challengesCompleted,
                        value:
                            '${widget.user.statistics!.challengesCompleted.toInt()}',
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ] else
              _NoStatisticsMessage(),
          ],

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? theme.cardColor : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildStatCard(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String value,
  required Color color,
  required bool isDark,
}) {
  final theme = Theme.of(context);
  final iconBgColor = color.withValues(alpha: isDark ? 0.2 : 0.1);

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
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

Widget _buildSectionCard(
  BuildContext context, {
  required IconData icon,
  required Color iconColor,
  required String title,
  required Widget child,
  required bool isDark,
}) {
  final theme = Theme.of(context);
  final iconBgColor = iconColor.withValues(alpha: isDark ? 0.2 : 0.1);

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
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    ),
  );
}

Widget _buildStatItem(
  BuildContext context, {
  required IconData icon,
  required String label,
  required String value,
  required Color color,
}) {
  final theme = Theme.of(context);

  return Column(
    children: [
      Icon(icon, color: color, size: 24),
      const SizedBox(height: 8),
      Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 4),
      Text(
        value,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: color,
        ),
        textAlign: TextAlign.center,
      ),
    ],
  );
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
