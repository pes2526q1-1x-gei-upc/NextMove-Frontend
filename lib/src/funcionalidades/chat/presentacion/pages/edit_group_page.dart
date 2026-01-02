import 'dart:io';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nextmove_app/src/funcionalidades/profile/data/dataproviders/user_remote_data_provider.dart';

const String updateGroupChatMutation = r'''
  mutation UpdateGroupChat($chatId: ID!, $name: String, $description: String, $photo: String) {
    updateGroupChat(chatId: $chatId, name: $name, description: $description, photo: $photo) {
      id
      name
      description
      photo
    }
  }
''';

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

  Future<void> _handleSave(RunMutation runMutation) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isUploading = true);

    try {
      String? finalPhotoUrl = widget.currentPhotoUrl;

      // 1. Si hay una nueva imagen, subirla primero
      if (_selectedImageFile != null) {
        debugPrint('[EditGroupPage] Subiendo imagen...');
        final remoteProvider = UserRemoteDataProvider();
        finalPhotoUrl = await remoteProvider.uploadProfilePhoto(
          _selectedImageFile!,
        );
        debugPrint('[EditGroupPage] Imagen subida: $finalPhotoUrl');
      }

      // 2. Ejecutar mutación GraphQL
      debugPrint('[EditGroupPage] Ejecutando mutación...');
      runMutation({
        'chatId': widget.chatId,
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'photo': finalPhotoUrl,
      });

      debugPrint('[EditGroupPage] Mutación ejecutada');
    } catch (e) {
      debugPrint('[EditGroupPage] Error: $e');
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Editar Grupo')),
      body: Mutation(
        options: MutationOptions(
          document: gql(updateGroupChatMutation),
          onCompleted: (data) {
            debugPrint('[EditGroupPage] onCompleted: $data');
            if (mounted) {
              setState(() => _isUploading = false);
              Navigator.pop(context, {
                'updated': true,
                'name': _nameController.text.trim(),
                'description': _descriptionController.text.trim(),
                'photo': data?['updateGroupChat']?['photo'],
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Grupo actualizado correctamente'),
                ),
              );
            }
          },
          onError: (error) {
            debugPrint('[EditGroupPage] onError: $error');
            if (mounted) {
              setState(() => _isUploading = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Error: ${error?.graphqlErrors.first.message ?? "Error desconocido"}',
                  ),
                  backgroundColor: theme.colorScheme.error,
                ),
              );
            }
          },
        ),
        builder: (runMutation, result) {
          final isLoading = _isUploading || (result?.isLoading ?? false);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // --- SECCIÓN DE FOTO ---
                  Center(
                    child: GestureDetector(
                      onTap: isLoading ? null : _pickImage,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: theme.colorScheme.primaryContainer,
                            backgroundImage: _selectedImageFile != null
                                ? FileImage(_selectedImageFile!)
                                : (widget.currentPhotoUrl != null
                                          ? NetworkImage(
                                              widget.currentPhotoUrl!,
                                            )
                                          : null)
                                      as ImageProvider?,
                            child:
                                (_selectedImageFile == null &&
                                    widget.currentPhotoUrl == null)
                                ? Icon(
                                    Icons.group,
                                    size: 60,
                                    color: theme.colorScheme.onPrimaryContainer,
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 4,
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: theme.colorScheme.primary,
                              child: const Icon(
                                Icons.edit,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          if (isLoading)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black26,
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // --- CAMPOS DE TEXTO ---
                  TextFormField(
                    controller: _nameController,
                    enabled: !isLoading,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del grupo',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.group),
                    ),
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'El nombre es obligatorio'
                        : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _descriptionController,
                    enabled: !isLoading,
                    decoration: const InputDecoration(
                      labelText: 'Descripción',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 40),

                  // --- BOTÓN GUARDAR ---
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () => _handleSave(runMutation),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Guardar cambios',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
