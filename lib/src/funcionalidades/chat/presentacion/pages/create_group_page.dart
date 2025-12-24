// lib/src/funcionalidades/chat/presentacion/pages/create_group_page.dart
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

const String createGroupChatMutation = r'''
  mutation CreateGroupChat($name: String!, $description: String, $participantEmails: [String!]!) {
    createGroupChat(name: $name, description: $description, participantEmails: $participantEmails) {
      id
      name
      description
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

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _createGroup(BuildContext context) async {
    final client = GraphQLProvider.of(context).value;

    final name = _nameController.text.trim();
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

    try {
      final result = await client.mutate(
        MutationOptions(
          document: gql(createGroupChatMutation),
          variables: {
            'name': name,
            'description': _descriptionController.text.trim(),
            'participantEmails': _selectedFriends.toList(),
          },
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Grupo creado exitosamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
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
          // Información del grupo
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del grupo',
                    hintText: 'Ej: Equipo NextMove',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.group),
                  ),
                  maxLength: 50,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción (opcional)',
                    hintText: '¿De qué trata este grupo?',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 3,
                  maxLength: 200,
                ),
              ],
            ),
          ),

          // Contador de seleccionados
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

          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
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

          // Lista de amigos
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
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
                        const SizedBox(height: 16),
                        const Text('Error cargando amigos'),
                        const SizedBox(height: 8),
                        Text(result.exception.toString()),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => refetch!(),
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }

                final friends = result.data?['ListFriends'] as List<dynamic>? ?? [];

                if (friends.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline, size: 64, color: theme.colorScheme.onSurface.withOpacity(0.3)),
                        const SizedBox(height: 16),
                        const Text('No tienes amigos para agregar'),
                      ],
                    ),
                  );
                }

                // Filtrar amigos por búsqueda
                final filteredFriends = _searchQuery.isEmpty
                    ? friends
                    : friends.where((friend) {
                        final name = friend['name'] as String? ?? '';
                        return name.toLowerCase().contains(_searchQuery.toLowerCase());
                      }).toList();

                if (filteredFriends.isEmpty) {
                  return const Center(
                    child: Text('No se encontraron amigos'),
                  );
                }

                return ListView.builder(
                  itemCount: filteredFriends.length,
                  itemBuilder: (context, index) {
                    final friend = filteredFriends[index];
                    final friendEmail = friend['email'] as String;
                    final friendName = friend['name'] as String? ?? 'Usuario';
                    final friendPhoto = friend['photo'] as String?;
                    final isSelected = _selectedFriends.contains(friendEmail);

                    return CheckboxListTile(
                      value: isSelected,
                      onChanged: (selected) {
                        setState(() {
                          if (selected == true) {
                            _selectedFriends.add(friendEmail);
                          } else {
                            _selectedFriends.remove(friendEmail);
                          }
                        });
                      },
                      secondary: CircleAvatar(
                        backgroundImage: friendPhoto != null ? NetworkImage(friendPhoto) : null,
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: friendPhoto == null
                            ? Text(
                                friendName[0].toUpperCase(),
                                style: TextStyle(color: theme.colorScheme.onPrimaryContainer),
                              )
                            : null,
                      ),
                      title: Text(friendName),
                      subtitle: Text(friendEmail),
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