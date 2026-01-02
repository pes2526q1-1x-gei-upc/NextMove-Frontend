import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/graphql/queries.dart';
import '../bloc/chat_state.dart';
import '../../dominio/entities/message.dart';
import '../utils/chat_room_data_handler.dart';
import 'chat_room_widgets.dart';

class ChatRoomBody extends StatelessWidget {
  final ChatState state;
  final String roomId;
  final bool isGroup;
  final String currentUserEmail;
  final ScrollController scrollController;
  final TextEditingController messageController;
  final bool isEditing;
  final Function(Message) onEditMessage;
  final Function(Message) onDeleteMessage;
  final VoidCallback onSendMessage;
  final VoidCallback onCancelEdit;
  final ValueChanged<String> onTextChanged;

  const ChatRoomBody({
    super.key,
    required this.state,
    required this.roomId,
    required this.isGroup,
    required this.currentUserEmail,
    required this.scrollController,
    required this.messageController,
    required this.isEditing,
    required this.onEditMessage,
    required this.onDeleteMessage,
    required this.onSendMessage,
    required this.onCancelEdit,
    required this.onTextChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    if (state is ChatConnecting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is ChatConnectionError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(l10n.connectionError, style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text((state as ChatConnectionError).message),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.back),
            ),
          ],
        ),
      );
    }

    if (state is ChatDisconnected ||
        state is GroupDeletedState ||
        state is FriendshipDeletedState) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is! ChatRoomActive) {
      return Center(child: Text(l10n.loadingRoom));
    }

    final messages = (state as ChatRoomActive).messages;

    return Column(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: messages.isEmpty
                ? ChatEmptyMessagesView(l10n: l10n, theme: theme)
                : isGroup
                ? Query(
                    options: QueryOptions(
                      document: gql(GraphQLQueries.myChatsQuery),
                      fetchPolicy: FetchPolicy.cacheAndNetwork,
                    ),
                    builder: (result, {fetchMore, refetch}) {
                      final participantsMap =
                          ChatRoomDataHandler.getParticipantsMap(
                            result.data,
                            roomId,
                          );
                      return ChatMessageList(
                        messages: messages,
                        currentUserEmail: currentUserEmail,
                        isGroup: isGroup,
                        participantsMap: participantsMap,
                        scrollController: scrollController,
                        onEditMessage: onEditMessage,
                        onDeleteMessage: onDeleteMessage,
                      );
                    },
                  )
                : ChatMessageList(
                    messages: messages,
                    currentUserEmail: currentUserEmail,
                    isGroup: isGroup,
                    scrollController: scrollController,
                    onEditMessage: onEditMessage,
                    onDeleteMessage: onDeleteMessage,
                  ),
          ),
        ),
        ChatBottomBar(
          controller: messageController,
          isEditing: isEditing,
          onSend: onSendMessage,
          onCancelEdit: onCancelEdit,
          onChanged: onTextChanged,
        ),
      ],
    );
  }
}
