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
  final List<String> existingParticipantEmails;

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
  final Set<String> _selectedUserEmails = {};
  final Map<String, UserEntity> _selectedUsers = {};

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUserNickname = userProvider.user?['nickname'] as String?;
    if (currentUserNickname != null && currentUserNickname.isNotEmpty) {
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
    // ✅ VALIDAR EMAIL
    if (user.email.isEmpty) {
      debugPrint('[AddParticipants] ERROR: Usuario ${user.apodo} sin email');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Este usuario no tiene email válido')),
      );
      return;
    }

    setState(() {
      if (_selectedUserEmails.contains(user.email)) {
        _selectedUserEmails.remove(user.email);
        _selectedUsers.remove(user.email);
        debugPrint('[AddParticipants] Deseleccionado: ${user.apodo} (${user.email})');
      } else {
        _selectedUserEmails.add(user.email);
        _selectedUsers[user.email] = user;
        debugPrint('[AddParticipants] Seleccionado: ${user.apodo} (${user.email})');
      }
      debugPrint('[AddParticipants] Total seleccionados: ${_selectedUserEmails.length}');
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

    debugPrint('[AddParticipants] Iniciando adición de ${emails.length} participantes');
    debugPrint('[AddParticipants] Emails a añadir: $emails');

    for (final email in emails) {
      if (email.isEmpty) {
        debugPrint('[AddParticipants] SKIP: Email vacío detectado');
        continue;
      }

      debugPrint('[AddParticipants] Añadiendo: "$email"');

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
          debugPrint('[AddParticipants] Error GraphQL: ${result.exception}');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error al añadir $email: ${result.exception.toString()}'),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        } else {
          successCount++;
          debugPrint('[AddParticipants] ✅ Añadido: $email');
        }
      } catch (e) {
        allSuccess = false;
        debugPrint('[AddParticipants] Exception: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al añadir $email: $e'),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$successCount participante(s) añadido(s), pero algunos fallaron'),
            backgroundColor: Colors.orange,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No se pudo añadir ningún participante'),
            backgroundColor: theme.colorScheme.error,
          ),
        );
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
            TextButton(
              onPressed: () {
                final emails = _selectedUserEmails.toList();
                debugPrint('[AddParticipants] Botón presionado con emails: $emails');
                _addParticipantsSequentially(context, emails, theme);
              },
              child: Text(
                'Añadir (${_selectedUserEmails.length})',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
                            color: Colors.black.withOpacity(0.05),
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

            // Chips de usuarios seleccionados
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
                              ? const Icon(Icons.person, size: 16)
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

                  // ✅ FILTRAR CORRECTAMENTE
                  final filteredUsers = usersToShow.where((user) {
                    // Verificar que tenga email
                    if (user.email.isEmpty) {
                      debugPrint('[AddParticipants] Usuario sin email: ${user.apodo}');
                      return false;
                    }
                    
                    // No mostrar si ya es participante
                    if (_isUserAlreadyParticipant(user)) {
                      return false;
                    }
                    
                    // No mostrar si es el usuario actual
                    if (_isCurrentUser(user)) {
                      return false;
                    }
                    
                    return true;
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
                                ? const Icon(Icons.person)
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