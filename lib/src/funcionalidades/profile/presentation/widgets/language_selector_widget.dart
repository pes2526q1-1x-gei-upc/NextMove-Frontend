import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:nextmove_app/src/funcionalidades/profile/domain/entities/user_entity.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/bloc/user/user_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/bloc/user/user_event.dart';
import 'package:nextmove_app/src/funcionalidades/auth/dominio/providers/locale_provider.dart';

class ProfileLanguageSelector {
  // Método estático para mostrar el modal
  static void show(BuildContext context, UserEntity currentUser) {
    final l10n = AppLocalizations.of(context)!;
    final List<String> languages = ['Español', 'English', 'Català'];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Text(
                    l10n.appLanguage,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Divider(height: 1),
                ...languages.map((lang) {
                  final isSelected = currentUser.idiomaPreferido == lang;
                  return ListTile(
                    title: Text(
                      lang,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check, color: Theme.of(context).primaryColor)
                        : null,
                    onTap: () {
                      // 1. Actualizar UI inmediatamente (LocaleProvider)
                      Provider.of<LocaleProvider>(context, listen: false)
                          .setLocaleFromLanguage(lang);

                      // 2. Guardar en Backend (UserBloc)
                      if (currentUser.idiomaPreferido != lang) {
                        final updatedUser = currentUser.copyWith(idiomaPreferido: lang);
                        context.read<UserBloc>().add(UpdateUserProfile(updatedUser));
                      }

                      // 3. Cerrar el modal
                      Navigator.pop(modalContext);
                    },
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }
}