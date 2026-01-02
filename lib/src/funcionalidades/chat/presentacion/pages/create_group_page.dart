import 'dart:io';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nextmove_app/src/funcionalidades/profile/data/dataproviders/user_remote_data_provider.dart';

// Mutación corregida para incluir photo y participantEmails
const String createGroupChatMutation = r'''
  mutation CreateGroupChat($name: String!, $description: String, $participantEmails: [String!]!, $photo: String) {
    createGroupChat(name: $name, description: $description, participantEmails: $participantEmails, photo: $photo) {
      id
      name
      description
      photo
      type
    }
  }
''';

const String getFriendsQuery = r'''
  query ListFriends {
    ListFriends {
      name
      email
      photo
    }
  }
''';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  final Set<String> _selectedFriends = {};
  String _searchQuery = '';
  bool _isCreating = false;

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  Future<void> _createGroup(BuildContext context) async {
    final name = _nameController.text.trim();

    // Validaciones previas
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre del grupo es obligatorio')),
      );
      return;
    }

    if (_selectedFriends.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona al menos un amigo')),
      );
      return;
    }

    setState(() => _isCreating = true);

    final remoteProvider = UserRemoteDataProvider();
    final client = GraphQLProvider.of(context).value;
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);

    try {
      String? photoUrl;

      // 1. SUBIR FOTO (Solo si el usuario seleccionó una)
      // Usamos el método genérico que creamos para no actualizar tu perfil
      if (_selectedImage != null) {
        photoUrl = await remoteProvider.uploadPhoto(_selectedImage!);
      }

      // 2. EJECUTAR MUTACIÓN
      final result = await client.mutate(
        MutationOptions(
          document: gql(createGroupChatMutation),
          variables: {
            'name': name,
            'description': _descriptionController.text.trim(),
            'participantEmails': _selectedFriends.toList(),
            'photo': photoUrl, // La URL de S3 que recibimos arriba
          },
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      navigator.pop(true); // Retorna true para refrescar la lista
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Grupo creado exitosamente')),
      );
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Grupo'),
        actions: [
          if (_isCreating)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: () => _createGroup(context),
              child: Text(
                'Crear',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // SECCIÓN SUPERIOR: Foto + Nombre + Desc
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Center(
                  child: GestureDetector(
                    onTap: _isCreating ? null : _pickImage,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: theme.colorScheme.primaryContainer,
                          backgroundImage: _selectedImage != null
                              ? FileImage(_selectedImage!)
                              : null,
                          child: _selectedImage == null
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
                        if (_isCreating && _selectedImage != null)
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
                const SizedBox(height: 24),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del grupo',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.group),
                  ),
                  maxLength: 50,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción (opcional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 2,
                  maxLength: 200,
                ),
              ],
            ),
          ),

          // BARRA DE SELECCIONADOS
          if (_selectedFriends.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: theme.colorScheme.primaryContainer,
              child: Row(
                children: [
                  Icon(
                    Icons.people,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_selectedFriends.length} amigos seleccionados',
                    style: TextStyle(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

          // BUSCADOR
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Buscar amigos...',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
            ),
          ),

          // LISTA DE AMIGOS
          Expanded(
            child: Query(
              options: QueryOptions(
                document: gql(getFriendsQuery),
                fetchPolicy: FetchPolicy.networkOnly,
              ),
              builder: (result, {fetchMore, refetch}) {
                if (result.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (result.hasException) {
                  return const Center(child: Text('Error al cargar amigos'));
                }

                final friends =
                    result.data?['ListFriends'] as List<dynamic>? ?? [];
                final filteredFriends = friends.where((f) {
                  final name = f['name'] as String? ?? '';
                  return name.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  );
                }).toList();

                if (filteredFriends.isEmpty) {
                  return const Center(child: Text('No se encontraron amigos'));
                }

                return ListView.builder(
                  itemCount: filteredFriends.length,
                  itemBuilder: (context, index) {
                    final friend = filteredFriends[index];
                    final email = friend['email'] as String;
                    final isSelected = _selectedFriends.contains(email);

                    return CheckboxListTile(
                      value: isSelected,
                      onChanged: (selected) {
                        setState(() {
                          if (selected == true) {
                            _selectedFriends.add(email);
                          } else {
                            _selectedFriends.remove(email);
                          }
                        });
                      },
                      secondary: CircleAvatar(
                        backgroundImage: friend['photo'] != null
                            ? NetworkImage(friend['photo'])
                            : null,
                        child: friend['photo'] == null
                            ? Text(friend['name'][0])
                            : null,
                      ),
                      title: Text(friend['name'] ?? 'Usuario'),
                      subtitle: Text(email),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
