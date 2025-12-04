import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/src/funcionalidades/profile/domain/entities/user_entity.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/bloc/user/user_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/bloc/user/user_event.dart';
import 'dart:io';

class ProfileSaveButton extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final UserEntity currentUser;
  final TextEditingController telefonoController;
  final TextEditingController descripcionController;
  final String? selectedIdioma;
  final String? selectedModeAPI;
  final File? selectedImageFile;

  const ProfileSaveButton({
    super.key,
    required this.formKey,
    required this.currentUser,
    required this.telefonoController,
    required this.descripcionController,
    required this.selectedIdioma,
    required this.selectedModeAPI,
    this.selectedImageFile,
  });

  // --- LÓGICA DE GUARDADO  ---
  void _saveChanges(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    debugPrint("ProfileSaveButton: _saveChanges called");

    try {
      // 1. Validar el formulario usando la key que nos pasó el padre
      if (!formKey.currentState!.validate()) {
        debugPrint("ProfileSaveButton: Form validation failed");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.formError), backgroundColor: Colors.red),
        );
        return;
      }
      debugPrint(
        "ProfileSaveButton: Form validation passed. Creating updated user...",
      );

      // 2. Crear una copia del usuario con los datos actualizados
      final updatedUser = currentUser.copyWith(
        numeroTelefono: int.tryParse(telefonoController.text) ?? 0,
        descripcion: descripcionController.text.trim(),
        idiomaPreferido: selectedIdioma ?? currentUser.idiomaPreferido,
        modoPreferido: selectedModeAPI,
      );
      debugPrint(
        "ProfileSaveButton: Updated user object created: $updatedUser",
      );

      // 3. Enviar el evento al BLoC
      debugPrint("ProfileSaveButton: Dispatching UpdateUserProfile event...");
      context.read<UserBloc>().add(
        UpdateUserProfile(updatedUser, profilePhoto: selectedImageFile),
      );
      debugPrint("ProfileSaveButton: Event dispatched successfully");
    } catch (e, stackTrace) {
      debugPrint("ProfileSaveButton: Error in _saveChanges: $e");
      debugPrint("ProfileSaveButton: Stack trace: $stackTrace");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error interno al guardar: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _saveChanges(context),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: theme.colorScheme.primary,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Text(
                  l10n.saveChanges,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
