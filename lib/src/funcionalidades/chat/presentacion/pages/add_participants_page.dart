import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/graphql/mutations.dart';
import 'package:nextmove_app/src/funcionalidades/social/presentation/bloc/social_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/social/presentation/bloc/social_event.dart';
import 'package:nextmove_app/src/funcionalidades/social/presentation/bloc/social_state.dart';
import 'package:nextmove_app/src/funcionalidades/profile/domain/entities/user_entity.dart';
import 'package:provider/provider.dart';
import 'package:nextmove_app/src/funcionalidades/auth/dominio/providers/user_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddParticipantsPage extends StatefulWidget {
  final String chatId;
  final List<String> existingParticipantEmails; // Emails de participantes existentes

  const AddParticipantsPage({
    super.key,
    required this.chatId,
    required this.existingParticipantEmails,
  });

  @override
  State<AddParticipantsPage> createState() => _AddParticipantsPageState();
}

class _AddParticipantsPageState extends State<AddParticipantsPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  final Set<String> _selectedUserEmails = {}; // Set de emails seleccionados
  final Map<String, UserEntity> _selectedUsers = {}; // Map email -> UserEntity

  @override
  void initState() {
    super.initState();
    // Cargar amigos si el SocialBloc está disponible
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUserNickname = userProvider.user?['nickname'] as String?;
    if (currentUserNickname != null && currentUserNickname.isNotEmpty) {
      // Esperar un frame para asegurarse de que el BlocProvider esté disponible
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<SocialBloc>().add(LoadFriendsEvent(currentUserNickname));
        }
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isNotEmpty) {
        context.read<SocialBloc>().add(SearchUsersEvent(query));
      } else {
        context.read<SocialBloc>().add(ClearSearchEvent());
      }
    });
  }

  void _toggleUserSelection(UserEntity user) {
    setState(() {
      if (_selectedUserEmails.contains(user.email)) {
        _selectedUserEmails.remove(user.email);
        _selectedUsers.remove(user.email);
      } else {
        _selectedUserEmails.add(user.email);
        _selectedUsers[user.email] = user;
      }
    });
  }

  bool _isUserAlreadyParticipant(UserEntity user) {
    return widget.existingParticipantEmails.contains(user.email);
  }

  bool _isCurrentUser(UserEntity user) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUserEmail = userProvider.email ??
        userProvider.user?['email'] as String? ??
        FirebaseAuth.instance.currentUser?.email ?? '';
    return user.email == currentUserEmail;
  }

  Future<void> _addParticipantsSequentially(
    BuildContext context,
    List<String> emails,
    ThemeData theme,
  ) async {
    final client = GraphQLProvider.of(context).value;
    bool allSuccess = true;
    int successCount = 0;

    for (final email in emails) {
      try {
        final result = await client.mutate(
          MutationOptions(
            document: gql(GraphQLMutations.addParticipantToGroupMutation),
            variables: {
              'chatId': widget.chatId,
              'userEmail': email,
            },
          ),
        );

        if (result.hasException) {
          allSuccess = false;
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error al añadir participante: ${result.exception.toString()}'),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        } else {
          successCount++;
        }
      } catch (e) {
        allSuccess = false;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al añadir participante: $e'),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        }
      }
    }

    if (mounted) {
      if (allSuccess && successCount > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$successCount participante(s) añadido(s) correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else if (successCount > 0) {
        // Algunos se añadieron pero otros fallaron
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$successCount participante(s) añadido(s), pero algunos fallaron'),
            backgroundColor: Colors.orange,
          ),
        );
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Añadir participantes'),
        actions: [
          if (_selectedUserEmails.isNotEmpty)
            Mutation(
              options: MutationOptions(
                document: gql(GraphQLMutations.addParticipantToGroupMutation),
                onCompleted: (data) {
                  // Se manejará cuando se añadan todos los participantes
                },
                onError: (error) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error al añadir participante: ${error.toString()}'),
                        backgroundColor: theme.colorScheme.error,
                      ),
                    );
                  }
                },
              ),
              builder: (runMutation, mutationResult) {
                return TextButton(
                  onPressed: mutationResult?.isLoading == true
                      ? null
                      : () {
                          // Ejecutar todas las mutaciones en secuencia
                          _addParticipantsSequentially(
                            context,
                            _selectedUserEmails.toList(),
                            theme,
                          );
                        },
                  child: mutationResult?.isLoading == true
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              theme.colorScheme.primary,
                            ),
                          ),
                        )
                      : Text(
                          'Añadir (${_selectedUserEmails.length})',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                );
              },
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Barra de búsqueda
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: theme.brightness == Brightness.dark
                      ? null
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: l10n.searchByNickname,
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              _searchController.clear();
                              _debounce?.cancel();
                              context.read<SocialBloc>().add(ClearSearchEvent());
                              setState(() {});
                            },
                          )
                        : null,
                  ),
                ),
              ),
            ),

            // Lista de usuarios seleccionados (chips)
            if (_selectedUsers.isNotEmpty)
              Container(
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedUsers.length,
                  itemBuilder: (context, index) {
                    final user = _selectedUsers.values.elementAt(index);
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Chip(
                        avatar: CircleAvatar(
                          radius: 12,
                          backgroundImage: user.photo.isNotEmpty
                              ? NetworkImage(user.photo)
                              : null,
                          child: user.photo.isEmpty
                              ? Icon(Icons.person, size: 16)
                              : null,
                        ),
                        label: Text(user.apodo),
                        onDeleted: () => _toggleUserSelection(user),
                      ),
                    );
                  },
                ),
              ),

            // Lista de usuarios
            Expanded(
              child: BlocBuilder<SocialBloc, SocialState>(
                builder: (context, state) {
                  if (state.status == SocialStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final usersToShow = state.isSearching
                      ? state.searchResults
                      : state.friends;

                  // Filtrar usuarios que ya son participantes o el usuario actual
                  final filteredUsers = usersToShow.where((user) {
                    return !_isUserAlreadyParticipant(user) && !_isCurrentUser(user);
                  }).toList();

                  if (filteredUsers.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            state.isSearching
                                ? Icons.person_off_outlined
                                : Icons.people_outline,
                            size: 60,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            state.isSearching
                                ? l10n.noUsersFound
                                : 'No hay usuarios disponibles para añadir',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      final isSelected = _selectedUserEmails.contains(user.email);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 24,
                            backgroundImage: user.photo.isNotEmpty
                                ? NetworkImage(user.photo)
                                : null,
                            child: user.photo.isEmpty
                                ? Icon(Icons.person)
                                : null,
                          ),
                          title: Text(
                            user.apodo,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(user.nombreCompleto),
                          trailing: Checkbox(
                            value: isSelected,
                            onChanged: (value) => _toggleUserSelection(user),
                          ),
                          onTap: () => _toggleUserSelection(user),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

