import 'package:flutter/material.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';

class BlockedUserPage extends StatelessWidget {
  const BlockedUserPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icono de bloqueo
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.block_rounded,
                    size: 60,
                    color: Colors.red,
                  ),
                ),

                const SizedBox(height: 32),

                // Título
                Text(
                  'Cuenta suspendida',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Mensaje explicativo
                Text(
                  'Tu cuenta ha sido suspendida temporalmente.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        height: 1.5,
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                // Información adicional
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: Theme.of(context).brightness == Brightness.dark
                        ? null
                        : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(
                        context,
                        Icons.access_time_rounded,
                        'Duración',
                        'Suspensión temporal',
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        context,
                        Icons.warning_rounded,
                        'Motivo de suspensión',
                        'Violación de normas de comunidad',
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        context,
                        Icons.support_agent_rounded,
                        '¿Necesitas ayuda?',
                        'Contacta con soporte',
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        context,
                        Icons.email_rounded,
                        'Email',
                        'support@nextmove.com',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Botón de contacto
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Aquí iría la lógica para contactar soporte
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Funcionalidad de contacto próximamente'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.contact_support_rounded),
                    label: const Text('Contactar soporte'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Nota adicional
                Text(
                  'Revisa nuestras normas de comunidad para evitar futuras suspensiones.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String title, String value) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.7),
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}