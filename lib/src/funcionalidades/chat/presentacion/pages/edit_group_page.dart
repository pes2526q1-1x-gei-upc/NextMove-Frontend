import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/src/funcionalidades/profile/data/dataproviders/user_remote_data_provider.dart';
import 'package:nextmove_app/src/funcionalidades/chat/presentacion/widgets/group_photo_selector.dart';
import 'package:nextmove_app/src/funcionalidades/chat/presentacion/widgets/group_name_description_fields.dart';
import 'package:nextmove_app/src/funcionalidades/chat/datos/dataproviders/chat_remote_data_provider.dart';

class EditGroupPage extends StatefulWidget {
  final String chatId;
  final String currentName;
  final String? currentDescription;
  final String? currentPhotoUrl;

  const EditGroupPage({
    super.key,
    required this.chatId,
    required this.currentName,
    this.currentDescription,
    this.currentPhotoUrl,
  });

  @override
  State<EditGroupPage> createState() => _EditGroupPageState();
}

class _EditGroupPageState extends State<EditGroupPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  File? _selectedImageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _descriptionController = TextEditingController(
      text: widget.currentDescription ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (pickedFile != null) {
      setState(() => _selectedImageFile = File(pickedFile.path));
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isUploading = true);

    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      String? finalPhotoUrl = widget.currentPhotoUrl;

      if (_selectedImageFile != null) {
        debugPrint('[EditGroupPage] Subiendo imagen...');
        final userProvider = UserRemoteDataProvider();
        finalPhotoUrl = await userProvider.uploadPhoto(_selectedImageFile!);
        debugPrint('[EditGroupPage] Imagen subida: $finalPhotoUrl');
      }

      debugPrint('[EditGroupPage] Ejecutando mutación...');
      final chatProvider = ChatRemoteDataProvider();
      final updatedData = await chatProvider.updateGroupChat(
        chatId: widget.chatId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        photo: finalPhotoUrl,
      );

      debugPrint('[EditGroupPage] Mutación finalizada con éxito');

      if (mounted) {
        navigator.pop({
          'updated': true,
          'name': _nameController.text.trim(),
          'description': _descriptionController.text.trim(),
          'photo': updatedData['photo'],
        });

        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text(l10n.groupUpdatedSuccessfully)),
        );
      }
    } catch (e) {
      debugPrint('[EditGroupPage] Error: $e');
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('${l10n.error}: $e'),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.editGroup)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // --- SECCIÓN DE FOTO ---
              GroupPhotoSelector(
                selectedImage: _selectedImageFile,
                currentPhotoUrl: widget.currentPhotoUrl,
                onPickImage: _pickImage,
                isLoading: _isUploading,
              ),
              const SizedBox(height: 32),

              // --- CAMPOS DE TEXTO ---
              GroupNameDescriptionFields(
                nameController: _nameController,
                descriptionController: _descriptionController,
                nameLabel: l10n.groupName,
                descriptionLabel: l10n.description,
                isEnabled: !_isUploading,
                nameValidator: (value) => (value == null || value.isEmpty)
                    ? l10n.nameIsRequired
                    : null,
              ),
              const SizedBox(height: 20),

              // --- BOTÓN GUARDAR ---
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isUploading ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isUploading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          l10n.saveChanges,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
