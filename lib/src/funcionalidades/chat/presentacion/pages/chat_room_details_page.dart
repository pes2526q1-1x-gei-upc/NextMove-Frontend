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
import '../bloc/chat_bloc.dart';
import '../bloc/chat_state.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/widgets/profile_form_widget.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/widgets/profile_menu_widgets.dart';

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
  Map<String, dynamic>? _updatedGroupData;
  bool _isNavigatingAway = false;

  @override
  Widget build(BuildContext context) {
    // Escuchar eventos de Socket.IO para actualizar lista de participantes
    return BlocListener<ChatBloc, ChatState>(
      listener: (context, state) {
        // Si se expulsó a un participante del grupo actual, refrescar la lista
        if (state is GroupParticipantKickedState && state.chatId == widget.chatId) {
          setState(() => _refreshKey++);
        }
        
        // Si el usuario actual fue expulsado del grupo, cerrar esta página y volver a la lista
        if (state is UserKickedFromGroupState && 
            state.chatId == widget.chatId && 
            !_isNavigatingAway) {
          _isNavigatingAway = true;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Has sido expulsado de ${state.chatName}'),
              backgroundColor: Theme.of(context).colorScheme.error,
              duration: const Duration(seconds: 2),
            ),
          );
          // Cerrar ChatRoomDetailsPage y luego ChatRoomPage
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Navigator.of(context).pop({'leftGroup': true});
              // Esperar un poco y cerrar también ChatRoomPage
              Future.delayed(const Duration(milliseconds: 100), () {
                if (mounted && Navigator.of(context).canPop()) {
                  Navigator.of(context).pop({'leftGroup': true});
                }
              });
            }
          });
        }
      },
      child: _ChatRoomDetailsContent(
        chatId: widget.chatId,
        chatName: widget.chatName,
        chatDescription: widget.chatDescription,
        refreshKey: _refreshKey,
        onRefresh: () => setState(() => _refreshKey++),
        onGroupDataUpdated: (data) => setState(() => _updatedGroupData = data),
        updatedGroupData: _updatedGroupData,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Escuchar eventos de participante expulsado desde el socket
    // Usaremos BlocListener para escuchar el evento GroupParticipantKicked
  }

}

class _ChatRoomDetailsContent extends StatelessWidget {
  final String chatId;
  final String chatName;
  final String? chatDescription;
  final int refreshKey;
  final VoidCallback onRefresh;
  final Function(Map<String, dynamic>) onGroupDataUpdated;
  final Map<String, dynamic>? updatedGroupData;

  const _ChatRoomDetailsContent({
    required this.chatId,
    required this.chatName,
    this.chatDescription,
    required this.refreshKey,
    required this.onRefresh,
    required this.onGroupDataUpdated,
    this.updatedGroupData,
  });

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
            Navigator.pop(context, updatedGroupData);
          },
        ),
        title: const Text('Detalles del grupo'),
        actions: [
          // Botón de editar grupo (solo visible si es admin)
          Query(
            options: QueryOptions(
              document: gql(myChatsQuery),
              fetchPolicy: FetchPolicy.cacheFirst,
            ),
            builder: (result, {fetchMore, refetch}) {
              if (result.hasException || result.data == null) {
                return const SizedBox.shrink();
              }

              final chats = result.data?['myChats'] as List<dynamic>? ?? [];
              final chat = chats.firstWhere(
                (c) => c['id'] == chatId,
                orElse: () => null,
              );

              if (chat == null) {
                return const SizedBox.shrink();
              }

              final participants = chat['participants'] as List<dynamic>? ?? [];
              final isCurrentUserAdmin = participants.any((p) => 
                p['userEmail'] == currentUserEmail && (p['isAdmin'] as bool? ?? false)
              );

              if (!isCurrentUserAdmin) {
                return const SizedBox.shrink();
              }

              return IconButton(
                icon: const Icon(Icons.edit),
                tooltip: 'Editar grupo',
                onPressed: () async {
                  final editResult = await Navigator.of(context).push<Map<String, dynamic>?>(
                    MaterialPageRoute(
                      builder: (context) => EditGroupPage(
                        chatId: chatId,
                        currentName: chat['name'] as String? ?? chatName,
                        currentDescription: chat['description'] as String? ?? chatDescription,
                        currentPhotoUrl: chat['photo'] as String?,
                      ),
                    ),
                  );

                  if (editResult != null) {
                    onRefresh();
                    onGroupDataUpdated(editResult);
                  }
                },
              );
            },
          ),
        ],
      ),
      body: Query(
        key: ValueKey('chat_details_$refreshKey'),
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

          final chats = result.data?['myChats'] as List<dynamic>? ?? [];
          final chat = chats.firstWhere(
            (c) => c['id'] == chatId,
            orElse: () => null,
          );

          if (chat == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.group_off, size: 64, color: theme.colorScheme.onSurface.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text('Grupo no encontrado', style: theme.textTheme.titleLarge),
                ],
              ),
            );
          }

          final participants = chat['participants'] as List<dynamic>? ?? [];
          final description = chat['description'] as String? ?? chatDescription;
          
    
          final isCurrentUserAdmin = participants.any((p) => 
            p['userEmail'] == currentUserEmail && (p['isAdmin'] as bool? ?? false)
          );

          return Mutation(
            options: MutationOptions(
              document: gql(GraphQLMutations.leaveGroupMutation),
              onCompleted: (data) {
                // Mostrar mensaje
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Has salido del grupo')),
                  );
                // Cerrar ChatRoomDetailsPage y luego ChatRoomPage
                // Usar popUntil para volver directamente a la lista de chats
                  Navigator.of(context).pop({'leftGroup': true});
                // El ChatRoomPage detectará el resultado y cerrará también
              },
              onError: (error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al salir del grupo: ${error.toString()}'),
                      backgroundColor: theme.colorScheme.error,
                    ),
                  );
              },
            ),
            builder: (runMutation, mutationResult) {
              return Container(
                color: theme.scaffoldBackgroundColor,
                child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Foto y nombre del grupo
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: theme.scaffoldBackgroundColor,
                        ),
                      child: Column(
                        children: [
                          Stack(
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
                           
                              if (isCurrentUserAdmin)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () async {
                                      final result = await Navigator.of(context).push<Map<String, dynamic>?>(
                                        MaterialPageRoute(
                                          builder: (context) => EditGroupPage(
                                            chatId: chatId,
                                            currentName: chat['name'] as String? ?? chatName,
                                            currentDescription: chat['description'] as String? ?? chatDescription,
                                            currentPhotoUrl: chat['photo'] as String?,
                                          ),
                                        ),
                                      );

                                      if (result != null) {
                                        onRefresh();
                                        onGroupDataUpdated(result);
                                      }
                                    },
                                    child: CircleAvatar(
                                      radius: 18,
                                      backgroundColor: theme.colorScheme.primary,
                                      child: const Icon(Icons.edit, size: 18, color: Colors.white),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            chat['name'] as String? ?? chatName,
                            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          if (description != null && description.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              description,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Lista de participantes
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ProfileSectionLabel(
                            text: '${participants.length} ${participants.length == 1 ? 'miembro' : 'miembros'}',
                          ),
                          const SizedBox(height: 8),
                          ProfileStyledCard(
                            children: List.generate(participants.length, (index) {
                                final participant = participants[index] as Map<String, dynamic>;
                                final participantEmail = participant['userEmail'] as String? ?? '';
                                final participantNickname = participant['nickname'] as String? ?? 'Usuario';
                                final participantPhoto = participant['photoUrl'] as String?;
                                final isCurrentUser = participantEmail == currentUserEmail;
                                final isAdmin = participant['isAdmin'] as bool? ?? false;

                                return Column(
                                  children: [
                                    if (index > 0) const ProfileMenuDivider(),
                                    Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                  onTap: () {
                                    if (isCurrentUser) {
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
                                    } else {
                                      final userProvider = Provider.of<UserProvider>(context, listen: false);
                                      final currentUserNickname = userProvider.user?['nickname'] as String?;
                                            if (participantNickname.isNotEmpty) {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) {
                                                    return MultiBlocProvider(
                                                      providers: [
                                                        BlocProvider<UserBloc>(
                                                          create: (context) {
                                                            final bloc = UserBloc();
                                                            bloc.add(LoadUserProfile(participantNickname));
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
                                          }
                                        },
                                        borderRadius: BorderRadius.circular(16),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 24,
                                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                                      backgroundImage: participantPhoto != null && participantPhoto.isNotEmpty
                                          ? NetworkImage(participantPhoto)
                                          : null,
                                      child: participantPhoto == null || participantPhoto.isEmpty
                                                    ? Icon(Icons.person, size: 24, color: theme.colorScheme.onSurface.withOpacity(0.6))
                                          : null,
                                    ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            participantNickname,
                                            style: theme.textTheme.bodyLarge?.copyWith(
                                                              fontSize: 16,
                                              fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.w500,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (isAdmin) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: theme.colorScheme.primaryContainer,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              'Admin',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: theme.colorScheme.onPrimaryContainer,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                                    if (isCurrentUser)
                                                      Text(
                                            'Tú',
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: theme.colorScheme.primary,
                                              fontStyle: FontStyle.italic,
                                            ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                              if (isCurrentUserAdmin && !isCurrentUser) ...[
                                                // Botón para hacer admin/quitar admin
                                                Mutation(
                                                  options: MutationOptions(
                                                    document: gql(GraphQLMutations.toggleAdminStatusMutation),
                                                    onCompleted: (data) {
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            isAdmin 
                                                              ? 'Se quitó el rol de admin a $participantNickname'
                                                              : '$participantNickname ahora es admin'
                                                          ),
                                                        ),
                                                      );
                                                      onRefresh();
                                                    },
                                                    onError: (error) {
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(
                                                          content: Text('Error: ${error?.graphqlErrors.first.message ?? "Error desconocido"}'),
                                                          backgroundColor: theme.colorScheme.error,
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                  builder: (runToggleAdminMutation, toggleAdminResult) {
                                                    return IconButton(
                                                      icon: Icon(
                                                        isAdmin ? Icons.admin_panel_settings : Icons.person_add_alt_1,
                                                        color: isAdmin ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                                                        size: 20,
                                                      ),
                                                      tooltip: isAdmin ? 'Quitar admin' : 'Hacer admin',
                                                      onPressed: toggleAdminResult?.isLoading == true
                                                          ? null
                                                          : () {
                                                              runToggleAdminMutation({
                                                                'chatId': chatId,
                                                                'userEmail': participantEmail,
                                                              });
                                                            },
                                                    );
                                                  },
                                                ),
                                                const SizedBox(width: 4),
                                                // Botón para expulsar
                                          Mutation(
                                            options: MutationOptions(
                                              document: gql(r'''
                                                mutation Kick($chatId: ID!, $userEmail: String!) {
                                                  kickParticipantFromGroup(chatId: $chatId, userEmail: $userEmail)
                                                }
                                              '''),
                                              onCompleted: (data) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text('$participantNickname expulsado del grupo')),
                                                  );
                                                      onRefresh();
                                              },
                                              onError: (error) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text('Error: ${error?.graphqlErrors.first.message ?? "Error desconocido"}'),
                                                      backgroundColor: theme.colorScheme.error,
                                                    ),
                                                  );
                                              },
                                            ),
                                            builder: (runKickMutation, kickResult) {
                                              return IconButton(
                                                icon: Icon(
                                                  Icons.person_remove,
                                                  color: theme.colorScheme.error,
                                                  size: 20,
                                                ),
                                                      tooltip: 'Expulsar',
                                                onPressed: kickResult?.isLoading == true
                                                    ? null
                                                    : () {
                                                              showDialog(
                                                                context: context,
                                                                builder: (context) => AlertDialog(
                                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                                  title: const Text('Expulsar participante'),
                                                                  content: Text('¿Estás seguro de que quieres expulsar a $participantNickname del grupo?'),
                                                                  actions: [
                                                                    TextButton(
                                                                      onPressed: () => Navigator.pop(context),
                                                                      child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                                                                    ),
                                                                    TextButton(
                                                                      onPressed: () {
                                                                        Navigator.pop(context);
                                                            runKickMutation({
                                                                          'chatId': chatId,
                                                              'userEmail': participantEmail,
                                                            });
                                                          },
                                                                      child: const Text('Expulsar', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                                                    ),
                                                                  ],
                                                                ),
                                                        );
                                                      },
                                              );
                                            },
                                          ),
                                              ],
                                        if (isCurrentUser)
                                          Icon(Icons.check_circle, color: theme.colorScheme.primary, size: 24),
                                        Icon(
                                                Icons.chevron_right_rounded,
                                                color: theme.iconTheme.color?.withValues(alpha: 0.6),
                                        ),
                                      ],
                                    ),
                                  ),
                                      ),
                                    ),
                                  ],
                                );
                              }),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Botones de añadir participantes y salir del grupo (uno al lado del otro)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          // Botón para añadir participantes
                          Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final existingEmails = participants.map((p) => p['userEmail'] as String).toList();
                            final success = await Navigator.of(context).push<bool>(
                              MaterialPageRoute(
                                builder: (context) {
                                  final userProvider = Provider.of<UserProvider>(context, listen: false);
                                  final currentUserNickname = userProvider.user?['nickname'] as String?;
                                  final socialBloc = SocialBloc();
                                  if (currentUserNickname != null && currentUserNickname.isNotEmpty) {
                                    socialBloc.add(LoadFriendsEvent(currentUserNickname));
                                  }
                                  return BlocProvider<SocialBloc>.value(
                                    value: socialBloc,
                                    child: AddParticipantsPage(
                                          chatId: chatId,
                                      existingParticipantEmails: existingEmails,
                                    ),
                                  );
                                },
                              ),
                            );

                                if (success == true) {
                                  onRefresh();
                            }
                          },
                              icon: const Icon(Icons.person_add, size: 20),
                              label: const Text('Añadir'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                          const SizedBox(width: 12),
                    // Botón para salir del grupo
                          Expanded(
                        child: OutlinedButton.icon(
                          onPressed: mutationResult?.isLoading == true
                              ? null
                              : () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                          title: const Text('Salir del grupo'),
                                          content: const Text('¿Estás seguro de que quieres salir de este grupo?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context),
                                              child: Text(l10n.cancel, style: const TextStyle(color: Colors.grey)),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                runMutation({'chatId': chatId});
                                              },
                                              child: const Text('Salir', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                            ),
                                          ],
                                        ),
                                      );
                                },
                          icon: mutationResult?.isLoading == true
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                                  : const Icon(Icons.exit_to_app, size: 20),
                              label: const Text('Salir'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                                side: BorderSide(color: theme.colorScheme.outline),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                          ),
                        ],
                      ),
                    ),

                    // Botón para borrar grupo (solo admins) - Estilo destructivo
                    if (isCurrentUserAdmin) ...[
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Mutation(
                          options: MutationOptions(
                            document: gql(GraphQLMutations.deleteGroupMutation),
                            onCompleted: (data) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Grupo eliminado')),
                              );
                              Navigator.of(context).pop({'groupDeleted': true});
                            },
                            onError: (error) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: ${error?.graphqlErrors.first.message ?? "Error desconocido"}'),
                                  backgroundColor: theme.colorScheme.error,
                                ),
                              );
                            },
                          ),
                          builder: (runDeleteMutation, deleteResult) {
                            return SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: deleteResult?.isLoading == true
                                    ? null
                                    : () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                            title: Row(
                                              children: [
                                                Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error, size: 28),
                                                const SizedBox(width: 12),
                                                const Expanded(
                                                  child: Text(
                                                    'Eliminar grupo',
                                                    style: TextStyle(fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            content: const Text(
                                              '¿Estás seguro de que quieres eliminar este grupo? Esta acción no se puede deshacer y todos los participantes serán removidos.',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context),
                                                child: Text(l10n.cancel, style: const TextStyle(color: Colors.grey)),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  runDeleteMutation({'chatId': chatId});
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                  foregroundColor: Colors.white,
                                                ),
                                                child: const Text('Eliminar', style: TextStyle(fontWeight: FontWeight.bold)),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                icon: deleteResult?.isLoading == true
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.delete_forever, size: 20),
                                label: const Text('Eliminar grupo', style: TextStyle(fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 2,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}