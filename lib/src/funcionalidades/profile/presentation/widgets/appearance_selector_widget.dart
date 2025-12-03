import 'package:flutter/material.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/src/funcionalidades/auth/dominio/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class AppearanceSelector {
  static void show(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        return SafeArea(
          child: Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              final currentMode = themeProvider.themeMode;
              final theme = Theme.of(context);
              final options = [
                _ThemeOption(
                  label: l10n.systemMode,
                  icon: Icons.phone_iphone,
                  mode: ThemeMode.system,
                ),
                _ThemeOption(
                  label: l10n.lightMode,
                  icon: Icons.wb_sunny_outlined,
                  mode: ThemeMode.light,
                ),
                _ThemeOption(
                  label: l10n.darkMode,
                  icon: Icons.dark_mode_outlined,
                  mode: ThemeMode.dark,
                ),
              ];

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        l10n.appearance,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    const Divider(height: 1),
                    ...options.map(
                      (option) {
                        final isSelected = option.mode == currentMode;
                        return ListTile(
                          leading: Icon(
                            option.icon,
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.iconTheme.color,
                          ),
                          title: Text(
                            option.label,
                            style: TextStyle(
                              fontWeight:
                                  isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                          trailing: isSelected
                              ? Icon(
                                  Icons.check,
                                  color: theme.colorScheme.primary,
                                )
                              : null,
                          onTap: () {
                            themeProvider.setThemeMode(option.mode);
                            Navigator.pop(modalContext);
                          },
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _ThemeOption {
  final String label;
  final IconData icon;
  final ThemeMode mode;

  const _ThemeOption({
    required this.label,
    required this.icon,
    required this.mode,
  });
}

