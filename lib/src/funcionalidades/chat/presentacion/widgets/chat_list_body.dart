import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/src/funcionalidades/auth/dominio/providers/user_provider.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_state.dart';
import '../bloc/chat_event.dart';
import '../../../../../graphql/queries.dart';
import '../utils/chat_list_data_handler.dart';
import 'chat_list_widgets.dart';
import 'chat_connection_status_views.dart';
import 'chat_empty_states.dart';

class ChatListBody extends StatelessWidget {
  final bool showFriends;
  final String searchQuery;
  final int refreshKey;
  final Future<List<dynamic>>? friendsFuture;
  final Future<List<dynamic>>? friendsForFilterFuture;
  final VoidCallback onRefresh;
  final Function(
    String,
    String, {
    String? otherUserPhoto,
    bool shouldRefreshOnReturn,
    bool isGroup,
  })
  onNavigateToRoom;
  final Function(BuildContext, String, String?, {String? friendPhoto})
  onOpenChatWithFriend;

  const ChatListBody({
    super.key,
    required this.showFriends,
    required this.searchQuery,
    required this.refreshKey,
    required this.friendsFuture,
    required this.friendsForFilterFuture,
    required this.onRefresh,
    required this.onNavigateToRoom,
    required this.onOpenChatWithFriend,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, chatState) {
        if (chatState is ChatConnecting) return const ChatConnectingView();
        if (chatState is ChatConnectionError) {
          return ChatConnectionErrorView(
            message: chatState.message,
            onRetry: () => _retryConnection(context),
          );
        }

        final currentUserEmail = FirebaseAuth.instance.currentUser?.email;

        return Query(
          key: ValueKey('chats_query_$refreshKey'),
          options: QueryOptions(
            document: gql(GraphQLQueries.myChatsQuery),
            fetchPolicy: FetchPolicy.networkOnly,
          ),
          builder: (chatsResult, {fetchMore, refetch}) {
            return FutureBuilder<List<dynamic>>(
              future: searchQuery.isNotEmpty
                  ? friendsFuture
                  : friendsForFilterFuture,
              builder: (context, friendsSnapshot) {
                if (chatsResult.isLoading ||
                    (searchQuery.isNotEmpty &&
                        friendsSnapshot.connectionState ==
                            ConnectionState.waiting)) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (chatsResult.hasException) {
                  return ChatLoadingErrorView(onRetry: onRefresh);
                }

                final filteredItems = ChatListDataHandler.getProcessedChatItems(
                  allChats:
                      chatsResult.data?['myChats'] as List<dynamic>? ?? [],
                  friendsData: friendsSnapshot.data,
                  currentUserEmail: currentUserEmail,
                  showFriends: showFriends,
                  searchQuery: searchQuery,
                );

                if (filteredItems.isEmpty && searchQuery.isEmpty) {
                  return showFriends
                      ? const EmptyChatsPlaceholder()
                      : const EmptyGroupsPlaceholder();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (searchQuery.isNotEmpty) _buildSearchResultsLabel(l10n),
                    Expanded(
                      child: showFriends
                          ? FriendsList(
                              theme: theme,
                              filteredFriends: filteredItems,
                              onRefresh: onRefresh,
                              onFriendTap: (friend) =>
                                  _handleFriendTap(context, friend),
                            )
                          : GroupsList(
                              theme: theme,
                              groups: filteredItems,
                              onRefresh: onRefresh,
                              onGroupTap: (group) => _handleGroupTap(group),
                            ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  void _retryConnection(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    context.read<ChatBloc>().add(
      InitializeChat(
        firebaseToken: userProvider.firebaseToken!,
        userId: userProvider.firebaseUserId!,
      ),
    );
  }

  Widget _buildSearchResultsLabel(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 4),
      child: Text(
        showFriends ? l10n.results : l10n.groupResults,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  void _handleFriendTap(BuildContext context, Map<String, dynamic> friend) {
    if (friend['chatId'] != null) {
      onNavigateToRoom(
        friend['chatId'],
        friend['name'],
        otherUserPhoto: friend['photo'],
      );
    } else {
      onOpenChatWithFriend(
        context,
        friend['name'],
        friend['email'],
        friendPhoto: friend['photo'],
      );
    }
  }

  void _handleGroupTap(Map<String, dynamic> group) {
    onNavigateToRoom(
      group['chatId'],
      group['name'],
      isGroup: true,
      otherUserPhoto: group['photo'],
    );
  }
}
