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
    _descriptionController = TextEditingController(text: widget.currentDescription ?? '');
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Grupo'),
      ),
      body: Mutation(
        options: MutationOptions(
          document: gql(updateGroupChatMutation),
          onCompleted: (data) {
            if (data != null) {
              Navigator.pop(context, true); // Retornamos true para refrescar la pantalla anterior
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Grupo actualizado correctamente')),
              );
            }
          },
          onError: (error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${error?.graphqlErrors.first.message ?? "Error desconocido"}')),
            );
          },
        ),
        builder: (runMutation, result) {
          // Combinamos el estado de carga de GraphQL con el de nuestra subida de imagen
          final isLoading = (result?.isLoading ?? false) || _isUploading;

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
                                    ? NetworkImage(widget.currentPhotoUrl!)
                                    : null) as ImageProvider?,
                            child: (_selectedImageFile == null && widget.currentPhotoUrl == null)
                                ? Icon(Icons.group, size: 60, color: theme.colorScheme.onPrimaryContainer)
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 4,
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: theme.colorScheme.primary,
                              child: const Icon(Icons.edit, size: 18, color: Colors.white),
                            ),
                          ),
                          if (_isUploading)
                            const Positioned.fill(
                              child: CircularProgressIndicator(),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // --- CAMPOS DE TEXTO ---
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del grupo',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.group),
                    ),
                    validator: (value) =>
                        (value == null || value.isEmpty) ? 'El nombre es obligatorio' : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _descriptionController,
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
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() => _isUploading = true);
                                
                                try {
                                  String? finalPhotoUrl = widget.currentPhotoUrl;

                                  // 1. Si hay una nueva imagen, la subimos
                                  if (_selectedImageFile != null) {
                                    final remoteProvider = UserRemoteDataProvider();
                                    finalPhotoUrl = await remoteProvider.uploadProfilePhoto(_selectedImageFile!);
                                  }

                                  // 2. Ejecutamos mutación de GraphQL
                                  runMutation({
                                    'chatId': widget.chatId,
                                    'name': _nameController.text.trim(),
                                    'description': _descriptionController.text.trim(),
                                    'photo': finalPhotoUrl,
                                  });
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error al subir la imagen: $e')),
                                  );
                                } finally {
                                  setState(() => _isUploading = false);
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Guardar cambios', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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