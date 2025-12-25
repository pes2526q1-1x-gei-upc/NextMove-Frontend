import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/graphql/queries.dart';
import 'package:nextmove_app/graphql/mutations.dart';
import 'package:nextmove_app/src/funcionalidades/auth/dominio/providers/user_provider.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/bloc/user/user_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/bloc/user/user_event.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/pages/edit_user_data_preferences.dart';
import 'package:nextmove_app/src/funcionalidades/social/presentation/friend_detail_page.dart';
import 'edit_group_page.dart';
import 'package:nextmove_app/src/funcionalidades/social/presentation/bloc/social_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/social/presentation/bloc/social_event.dart';
import 'package:provider/provider.dart';
import 'add_participants_page.dart';

class ChatRoomDetailsPage extends StatefulWidget {
  final String chatId;
  final String chatName;
  final String? chatDescription;

  const ChatRoomDetailsPage({
    super.key,
    required this.chatId,
    required this.chatName,
    this.chatDescription,
  });

  @override
  State<ChatRoomDetailsPage> createState() => _ChatRoomDetailsPageState();
}

class _ChatRoomDetailsPageState extends State<ChatRoomDetailsPage> {
  int _refreshKey = 0;
  Map<String, dynamic>? _updatedGroupData; // Guardar datos actualizados del grupo

  void _showLeaveGroupDialog(BuildContext context, VoidCallback onLeave) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Salir del grupo'),
        content: const Text('¿Estás seguro de que quieres salir de este grupo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.cancel,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onLeave();
            },
            child: const Text(
              'Salir',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToUserProfile(BuildContext context, String nickname, String? currentUserNickname) async {
    if (nickname.isEmpty) return;
    
    // Navegar al perfil del usuario
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return MultiBlocProvider(
            providers: [
              BlocProvider<UserBloc>(
                create: (context) {
                  final bloc = UserBloc();
                  bloc.add(LoadUserProfile(nickname));
                  return bloc;
                },
              ),
              BlocProvider<SocialBloc>(
                create: (context) {
                  final socialBloc = SocialBloc();
                  if (currentUserNickname != null && currentUserNickname.isNotEmpty) {
                    socialBloc.add(LoadFriendsEvent(currentUserNickname));
                  }
                  return socialBloc;
                },
              ),
            ],
            child: const FriendDetailsPage(),
          );
        },
      ),
    );
  }

  void _navigateToEditProfile(BuildContext context) {
    // Obtener el UserBloc del contexto (proporcionado globalmente en main.dart)
    // Usamos Builder para asegurarnos de tener el contexto correcto
    final userBloc = context.read<UserBloc>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: userBloc,
          child: const EditUserDataPreferencesPage(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final userProvider = Provider.of<UserProvider>(context);
    final currentUserEmail = userProvider.email ?? 
                            userProvider.user?['email'] as String? ?? 
                            FirebaseAuth.instance.currentUser?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () {
            // Devolver los datos actualizados si existen
            Navigator.pop(context, _updatedGroupData);
          },
        ),
        title: const Text('Detalles del grupo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Editar grupo',
            onPressed: () async {
              // Navegar a la página de edición
              final result = await Navigator.of(context).push<Map<String, dynamic>?>(
                MaterialPageRoute(
                  builder: (context) => Query(
                    options: QueryOptions(
                      document: gql(myChatsQuery),
                      fetchPolicy: FetchPolicy.networkOnly,
                    ),
                    builder: (queryResult, {fetchMore, refetch}) {
                      if (queryResult.isLoading) {
                        return const Scaffold(
                          body: Center(child: CircularProgressIndicator()),
                        );
                      }

                      // Buscar el chat específico
                      final chats = queryResult.data?['myChats'] as List<dynamic>? ?? [];
                      final chat = chats.firstWhere(
                        (c) => c['id'] == widget.chatId,
                        orElse: () => null,
                      );

                      if (chat == null) {
                        return Scaffold(
                          appBar: AppBar(title: const Text('Editar grupo')),
                          body: const Center(child: Text('Grupo no encontrado')),
                        );
                      }

                      return EditGroupPage(
                        chatId: widget.chatId,
                        currentName: chat['name'] as String? ?? widget.chatName,
                        currentDescription: chat['description'] as String? ?? widget.chatDescription,
                        currentPhotoUrl: chat['photo'] as String?,
                      );
                    },
                  ),
                ),
              );

              // Si se actualizó el grupo, refrescar los datos y quedarse en esta página
              if (result != null && mounted) {
                setState(() {
                  _refreshKey++;
                  _updatedGroupData = result; // Guardar los datos actualizados
                });
                // No hacer pop, quedarse en la página de detalles
                // El nombre se actualizará automáticamente al refrescar los datos
              }
            },
          ),
        ],
      ),
      body: Query(
        key: ValueKey('chat_details_$_refreshKey'),
        options: QueryOptions(
          document: gql(myChatsQuery),
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
                  Text(l10n.error),
                  const SizedBox(height: 8),
                  Text(result.exception.toString()),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => refetch?.call(),
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            );
          }

          // Buscar el chat específico en la lista
          final chats = result.data?['myChats'] as List<dynamic>? ?? [];
          final chat = chats.firstWhere(
            (c) => c['id'] == widget.chatId,
            orElse: () => null,
          );

          if (chat == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.group_off, size: 64, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text('Grupo no encontrado', style: theme.textTheme.titleLarge),
                ],
              ),
            );
          }

          final participants = chat['participants'] as List<dynamic>? ?? [];
          final description = chat['description'] as String? ?? widget.chatDescription;

          return Mutation(
            options: MutationOptions(
              document: gql(GraphQLMutations.leaveGroupMutation),
              onCompleted: (data) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Has salido del grupo')),
                  );
                  // Devolver un resultado especial para indicar que se salió del grupo
                  // Esto permitirá que ChatRoomPage y ChatListPage refresquen la lista
                  Navigator.of(context).pop({'leftGroup': true});
                }
              },
              onError: (error) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al salir del grupo: ${error.toString()}'),
                      backgroundColor: theme.colorScheme.error,
                    ),
                  );
                }
              },
            ),
            builder: (runMutation, mutationResult) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Foto y nombre del grupo
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                      ),
                      child: Column(
                        children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: theme.colorScheme.primaryContainer,
                              backgroundImage: chat['photo'] != null && (chat['photo'] as String).isNotEmpty
                                  ? NetworkImage(chat['photo'] as String)
                                  : null,
                              child: (chat['photo'] == null || (chat['photo'] as String).isEmpty)
                                  ? Icon(Icons.group, size: 50, color: theme.colorScheme.onPrimaryContainer)
                                  : null,
                            ),                      
                          const SizedBox(height: 16),
                          Text(
                            chat['name'] as String? ?? widget.chatName,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (description != null && description.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              description,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      ),
                    ),

                    const Divider(height: 1),

                    // Lista de participantes
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${participants.length} ${participants.length == 1 ? 'miembro' : 'miembros'}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: theme.colorScheme.outline.withValues(alpha: 0.2),
                                width: 1,
                              ),
                            ),
                            child: ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              itemCount: participants.length,
                              separatorBuilder: (context, index) => Divider(
                                height: 1,
                                indent: 72,
                                endIndent: 16,
                                color: theme.colorScheme.outline.withValues(alpha: 0.2),
                              ),
                              itemBuilder: (context, index) {
                                final participant = participants[index] as Map<String, dynamic>;
                                final participantEmail = participant['userEmail'] as String? ?? '';
                                final participantNickname = participant['nickname'] as String? ?? 'Usuario';
                                final participantPhoto = participant['photoUrl'] as String?;
                                final isCurrentUser = participantEmail == currentUserEmail;

                                return InkWell(
                                  onTap: () {
                                    if (isCurrentUser) {
                                      // Para el usuario actual, usar el UserBloc global
                                      _navigateToEditProfile(context);
                                    } else {
                                      final userProvider = Provider.of<UserProvider>(context, listen: false);
                                      final currentUserNickname = userProvider.user?['nickname'] as String?;
                                      _navigateToUserProfile(context, participantNickname, currentUserNickname);
                                    }
                                  },
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    leading: CircleAvatar(
                                      radius: 28,
                                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                                      backgroundImage: participantPhoto != null && participantPhoto.isNotEmpty
                                          ? NetworkImage(participantPhoto)
                                          : null,
                                      child: participantPhoto == null || participantPhoto.isEmpty
                                          ? Icon(
                                              Icons.person,
                                              size: 28,
                                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                            )
                                          : null,
                                    ),
                                    title: Text(
                                      participantNickname,
                                      style: theme.textTheme.bodyLarge?.copyWith(
                                        fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.w500,
                                      ),
                                    ),
                                    subtitle: isCurrentUser
                                        ? Text(
                                            'Tú',
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: theme.colorScheme.primary,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          )
                                        : null,
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (isCurrentUser)
                                          Icon(
                                            Icons.check_circle,
                                            color: theme.colorScheme.primary,
                                            size: 24,
                                          ),
                                        const SizedBox(width: 8),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          size: 16,
                                          color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Botón para añadir participantes
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            // Obtener emails de participantes existentes
                            final existingEmails = participants
                                .map((p) => p['userEmail'] as String)
                                .toList();

                            // Navegar a la página de selección de participantes
                            final success = await Navigator.of(context).push<bool>(
                              MaterialPageRoute(
                                builder: (context) {
                                  // Crear un nuevo SocialBloc para la página de añadir participantes
                                  final userProvider = Provider.of<UserProvider>(context, listen: false);
                                  final currentUserNickname = userProvider.user?['nickname'] as String?;
                                  final socialBloc = SocialBloc();
                                  if (currentUserNickname != null && currentUserNickname.isNotEmpty) {
                                    socialBloc.add(LoadFriendsEvent(currentUserNickname));
                                  }
                                  return BlocProvider<SocialBloc>.value(
                                    value: socialBloc,
                                    child: AddParticipantsPage(
                                      chatId: widget.chatId,
                                      existingParticipantEmails: existingEmails,
                                    ),
                                  );
                                },
                              ),
                            );

                            // Si se añadieron participantes exitosamente, refrescar la lista
                            if (success == true && mounted) {
                              setState(() {
                                _refreshKey++;
                              });
                            }
                          },
                          icon: const Icon(Icons.person_add),
                          label: const Text('Añadir participantes'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Botón para salir del grupo
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: mutationResult?.isLoading == true
                              ? null
                              : () {
                                  _showLeaveGroupDialog(context, () {
                                    runMutation({'chatId': widget.chatId});
                                  });
                                },
                          icon: mutationResult?.isLoading == true
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.exit_to_app, color: Colors.red),
                          label: const Text(
                            'Salir del grupo',
                            style: TextStyle(color: Colors.red),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
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
    );
  }
}
