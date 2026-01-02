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
import 'package:nextmove_app/src/funcionalidades/profile/presentation/widgets/profile_form_widget.dart';

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
        debugPrint(
          '[AddParticipants] Deseleccionado: ${user.apodo} (${user.email})',
        );
      } else {
        _selectedUserEmails.add(user.email);
        _selectedUsers[user.email] = user;
        debugPrint(
          '[AddParticipants] Seleccionado: ${user.apodo} (${user.email})',
        );
      }
      debugPrint(
        '[AddParticipants] Total seleccionados: ${_selectedUserEmails.length}',
      );
    });
  }

  bool _isUserAlreadyParticipant(UserEntity user) {
    return widget.existingParticipantEmails.contains(user.email);
  }

  bool _isCurrentUser(UserEntity user) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUserEmail =
        userProvider.email ??
        userProvider.user?['email'] as String? ??
        FirebaseAuth.instance.currentUser?.email ??
        '';
    return user.email == currentUserEmail;
  }

  Future<void> _addParticipantsSequentially(
    BuildContext context,
    List<String> emails,
    ThemeData theme,
  ) async {
    final client = GraphQLProvider.of(context).value;
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    bool allSuccess = true;
    int successCount = 0;

    debugPrint(
      '[AddParticipants] Iniciando adición de ${emails.length} participantes',
    );
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
            variables: {'chatId': widget.chatId, 'userEmail': email},
          ),
        );

        if (result.hasException) {
          allSuccess = false;
          debugPrint('[AddParticipants] Error GraphQL: ${result.exception}');
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(
                'Error al añadir $email: ${result.exception.toString()}',
              ),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        } else {
          successCount++;
          debugPrint('[AddParticipants] ✅ Añadido: $email');
        }
      } catch (e) {
        allSuccess = false;
        debugPrint('[AddParticipants] Exception: $e');
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Error al añadir $email: $e'),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    }

    if (allSuccess && successCount > 0) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
            '$successCount participante(s) añadido(s) correctamente',
          ),
          backgroundColor: Colors.green,
        ),
      );
      navigator.pop(true);
    } else if (successCount > 0) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
            '$successCount participante(s) añadido(s), pero algunos fallaron',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      navigator.pop(true);
    } else {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: const Text('No se pudo añadir ningún participante'),
          backgroundColor: theme.colorScheme.error,
        ),
      );
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
                debugPrint(
                  '[AddParticipants] Botón presionado con emails: $emails',
                );
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
              padding: const EdgeInsets.all(24.0),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: theme.brightness == Brightness.dark
                      ? null
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {});
                    _onSearchChanged(value);
                  },
                  decoration: InputDecoration(
                    hintText: l10n.searchByNickname,
                    hintStyle: TextStyle(color: theme.colorScheme.outline),
                    prefixIcon: Icon(
                      Icons.search,
                      color: theme.colorScheme.outline,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.close,
                              color: theme.colorScheme.outline,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              _debounce?.cancel();
                              context.read<SocialBloc>().add(
                                ClearSearchEvent(),
                              );
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
                height: 70,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedUsers.length,
                  itemBuilder: (context, index) {
                    final user = _selectedUsers.values.elementAt(index);
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Chip(
                        avatar: CircleAvatar(
                          radius: 14,
                          backgroundColor:
                              theme.colorScheme.surfaceContainerHighest,
                          backgroundImage: user.photo.isNotEmpty
                              ? NetworkImage(user.photo)
                              : null,
                          child: user.photo.isEmpty
                              ? Icon(
                                  Icons.person,
                                  size: 16,
                                  color: theme.colorScheme.onSurface,
                                )
                              : null,
                        ),
                        label: Text(
                          user.apodo,
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        backgroundColor: theme.colorScheme.primaryContainer,
                        deleteIcon: Icon(
                          Icons.close,
                          size: 18,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
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
                      debugPrint(
                        '[AddParticipants] Usuario sin email: ${user.apodo}',
                      );
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
                            size: 64,
                            color: theme.colorScheme.outline.withValues(
                              alpha: 0.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            state.isSearching
                                ? l10n.noUsersFound
                                : 'No hay usuarios disponibles para añadir',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      final isSelected = _selectedUserEmails.contains(
                        user.email,
                      );

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: ProfileStyledCard(
                          children: [
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => _toggleUserSelection(user),
                                borderRadius: BorderRadius.circular(16),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 16,
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 28,
                                        backgroundColor: theme
                                            .colorScheme
                                            .surfaceContainerHighest,
                                        backgroundImage: user.photo.isNotEmpty
                                            ? NetworkImage(user.photo)
                                            : null,
                                        child: user.photo.isEmpty
                                            ? Icon(
                                                Icons.person,
                                                size: 28,
                                                color: theme
                                                    .colorScheme
                                                    .onSurface
                                                    .withValues(alpha: 0.6),
                                              )
                                            : null,
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              user.apodo,
                                              style: theme.textTheme.bodyLarge
                                                  ?.copyWith(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                            ),
                                            if (user
                                                .nombreCompleto
                                                .isNotEmpty) ...[
                                              const SizedBox(height: 4),
                                              Text(
                                                user.nombreCompleto,
                                                style: theme.textTheme.bodySmall
                                                    ?.copyWith(
                                                      color: theme
                                                          .colorScheme
                                                          .outline,
                                                    ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      Checkbox(
                                        value: isSelected,
                                        onChanged: (value) =>
                                            _toggleUserSelection(user),
                                        activeColor: theme.colorScheme.primary,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
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
