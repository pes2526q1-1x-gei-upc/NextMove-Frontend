import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/graphql/queries.dart';
import 'package:nextmove_app/graphql/mutations.dart';
import 'package:nextmove_app/src/funcionalidades/auth/dominio/providers/user_provider.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/bloc/user/user_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/pages/edit_user_data_preferences.dart';
import 'package:nextmove_app/src/funcionalidades/social/presentation/bloc/social_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/social/presentation/bloc/social_event.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/widgets/profile_form_widget.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/widgets/profile_menu_widgets.dart';
import '../pages/edit_group_page.dart';
import '../pages/add_participants_page.dart';
import 'chat_room_details_widgets.dart';
import '../utils/chat_navigation_handler.dart';

class ChatRoomDetailsBody extends StatelessWidget {
  final String chatId;
  final String chatName;
  final String? chatDescription;
  final int refreshKey;
  final VoidCallback onRefresh;
  final Function(Map<String, dynamic>) onGroupDataUpdated;
  final Map<String, dynamic>? updatedGroupData;

  const ChatRoomDetailsBody({
    super.key,
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
    final currentUserEmail =
        userProvider.email ??
        userProvider.user?['email'] as String? ??
        FirebaseAuth.instance.currentUser?.email ??
        '';

    return Query(
      key: ValueKey('chat_details_$refreshKey'),
      options: QueryOptions(
        document: gql(GraphQLQueries.myChatsQuery),
        fetchPolicy: FetchPolicy.networkOnly,
      ),
      builder: (result, {fetchMore, refetch}) {
        if (result.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (result.hasException) {
          return ChatRoomDetailsErrorView(
            l10n: l10n,
            theme: theme,
            errorMessage: result.exception.toString(),
            onRetry: onRefresh,
          );
        }

        final chats = result.data?['myChats'] as List<dynamic>? ?? [];
        final chat = chats.firstWhere(
          (c) => c['id'] == chatId,
          orElse: () => null,
        );

        if (chat == null) {
          return ChatRoomDetailsNotFoundView(l10n: l10n, theme: theme);
        }

        final participants = chat['participants'] as List<dynamic>? ?? [];
        final isCurrentUserAdmin = participants.any(
          (p) =>
              p['userEmail'] == currentUserEmail &&
              (p['isAdmin'] as bool? ?? false),
        );

        return Mutation(
          options: MutationOptions(
            document: gql(GraphQLMutations.leaveGroupMutation),
            onCompleted: (_) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(l10n.youLeftTheGroup)));
              Navigator.of(context).pop({'leftGroup': true});
            },
          ),
          builder: (runLeaveMutation, leaveResult) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GroupInfoCard(
                    chat: chat,
                    fallbackName: chatName,
                    fallbackDescription: chatDescription,
                    isCurrentUserAdmin: isCurrentUserAdmin,
                    onEditTap: () => _navigateToEdit(context, chat),
                  ),
                  const SizedBox(height: 20),
                  _ParticipantsSection(
                    participants: participants,
                    currentUserEmail: currentUserEmail,
                    isCurrentUserAdmin: isCurrentUserAdmin,
                    chatId: chatId,
                    onRefresh: onRefresh,
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        GroupActionButtons(
                          onAddParticipants: () =>
                              _navigateToAddParticipants(context, participants),
                          onLeaveGroup: () =>
                              _confirmLeaveGroup(context, runLeaveMutation),
                          isLeaving: leaveResult?.isLoading ?? false,
                        ),
                        if (isCurrentUserAdmin) ...[
                          const SizedBox(height: 12),
                          _DeleteGroupSection(
                            chatId: chatId,
                            l10n: l10n,
                            theme: theme,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _navigateToEdit(BuildContext context, dynamic chat) async {
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
  }

  void _navigateToAddParticipants(
    BuildContext context,
    List<dynamic> participants,
  ) async {
    final existingEmails = participants
        .map((p) => p['userEmail'] as String)
        .toList();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUserNickname = userProvider.user?['nickname'] as String?;
    final socialBloc = SocialBloc();
    if (currentUserNickname != null && currentUserNickname.isNotEmpty) {
      socialBloc.add(LoadFriendsEvent(currentUserNickname));
    }
    final success = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => BlocProvider<SocialBloc>.value(
          value: socialBloc,
          child: AddParticipantsPage(
            chatId: chatId,
            existingParticipantEmails: existingEmails,
          ),
        ),
      ),
    );
    if (success == true) onRefresh();
  }

  void _confirmLeaveGroup(BuildContext context, RunMutation runMutation) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.leaveGroup),
        content: Text(l10n.areYouSureLeaveGroup),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              runMutation({'chatId': chatId});
            },
            child: Text(
              l10n.leave,
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ParticipantsSection extends StatelessWidget {
  final List<dynamic> participants;
  final String currentUserEmail;
  final bool isCurrentUserAdmin;
  final String chatId;
  final VoidCallback onRefresh;

  const _ParticipantsSection({
    required this.participants,
    required this.currentUserEmail,
    required this.isCurrentUserAdmin,
    required this.chatId,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileSectionLabel(
            text:
                '${participants.length} ${participants.length == 1 ? l10n.member : l10n.members}',
          ),
          const SizedBox(height: 8),
          ProfileStyledCard(
            children: List.generate(participants.length, (index) {
              final participant = participants[index] as Map<String, dynamic>;
              final participantEmail =
                  participant['userEmail'] as String? ?? '';
              final isAdmin = participant['isAdmin'] as bool? ?? false;
              final isCurrentUser = participantEmail == currentUserEmail;

              return Column(
                children: [
                  if (index > 0) const ProfileMenuDivider(),
                  ParticipantTile(
                    participant: participant,
                    isCurrentUser: isCurrentUser,
                    isAdmin: isAdmin,
                    isCurrentUserAdmin: isCurrentUserAdmin,
                    onTap: () => _handleParticipantTap(
                      context,
                      participant,
                      isCurrentUser,
                    ),
                    trailing: _buildTrailing(
                      context,
                      participant,
                      isAdmin,
                      isCurrentUser,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  void _handleParticipantTap(
    BuildContext context,
    Map<String, dynamic> participant,
    bool isCurrentUser,
  ) {
    final nickname = participant['nickname'] as String? ?? 'Usuario';
    if (isCurrentUser) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BlocProvider.value(
            value: context.read<UserBloc>(),
            child: const EditUserDataPreferencesPage(),
          ),
        ),
      );
    } else {
      ChatNavigationHandler.navigateToFriendDetail(context, nickname);
    }
  }

  Widget _buildTrailing(
    BuildContext context,
    Map<String, dynamic> participant,
    bool isAdmin,
    bool isCurrentUser,
  ) {
    if (!isCurrentUserAdmin || isCurrentUser) {
      return isCurrentUser
          ? Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            )
          : Icon(
              Icons.chevron_right_rounded,
              color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.6),
            );
    }

    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final participantEmail = participant['userEmail'] as String? ?? '';
    final nickname = participant['nickname'] as String? ?? 'Usuario';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Mutation(
          options: MutationOptions(
            document: gql(GraphQLMutations.toggleAdminStatusMutation),
            onCompleted: (_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isAdmin
                        ? l10n.adminRoleGranted(nickname)
                        : l10n.adminRoleRemoved(nickname),
                  ),
                ),
              );
              onRefresh();
            },
          ),
          builder: (runToggle, result) => IconButton(
            icon: Icon(
              isAdmin ? Icons.admin_panel_settings : Icons.person_add_alt_1,
              color: isAdmin
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
              size: 20,
            ),
            onPressed: result?.isLoading == true
                ? null
                : () => runToggle({
                    'chatId': chatId,
                    'userEmail': participantEmail,
                  }),
          ),
        ),
        Mutation(
          options: MutationOptions(
            document: gql(GraphQLMutations.kickParticipantFromGroupMutation),
            onCompleted: (_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.participantKicked(nickname))),
              );
              onRefresh();
            },
          ),
          builder: (runKick, result) => IconButton(
            icon: Icon(
              Icons.person_remove,
              color: theme.colorScheme.error,
              size: 20,
            ),
            onPressed: result?.isLoading == true
                ? null
                : () => _confirmKick(
                    context,
                    nickname,
                    participantEmail,
                    runKick,
                  ),
          ),
        ),
      ],
    );
  }

  void _confirmKick(
    BuildContext context,
    String nickname,
    String email,
    RunMutation runKick,
  ) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.kickParticipant),
        content: Text(l10n.areYouSureKickParticipant(nickname)),
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
              runKick({'chatId': chatId, 'userEmail': email});
            },
            child: Text(
              l10n.kick,
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeleteGroupSection extends StatelessWidget {
  final String chatId;
  final AppLocalizations l10n;
  final ThemeData theme;

  const _DeleteGroupSection({
    required this.chatId,
    required this.l10n,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Mutation(
      options: MutationOptions(
        document: gql(GraphQLMutations.deleteGroupMutation),
        onCompleted: (_) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.groupDeleted)));
          Navigator.of(context).pop({'groupDeleted': true});
        },
      ),
      builder: (runDelete, result) => DeleteGroupButton(
        onDelete: () => _confirmDelete(context, runDelete),
        isDeleting: result?.isLoading ?? false,
      ),
    );
  }

  void _confirmDelete(BuildContext context, RunMutation runDelete) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: theme.colorScheme.error,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.deleteGroup,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Text(l10n.areYouSureDeleteGroup),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.cancel,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              runDelete({'chatId': chatId});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(
              l10n.delete,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
