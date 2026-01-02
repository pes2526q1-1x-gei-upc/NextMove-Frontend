import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/src/funcionalidades/auth/dominio/providers/user_provider.dart';
import 'package:provider/provider.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_state.dart';
import '../widgets/chat_room_details_widgets.dart';
import '../widgets/chat_room_details_body.dart';

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
        if (state is GroupParticipantKickedState &&
            state.chatId == widget.chatId) {
          setState(() => _refreshKey++);
        }

        // Si el usuario actual fue expulsado del grupo, cerrar esta página y volver a la lista
        if (state is UserKickedFromGroupState &&
            state.chatId == widget.chatId &&
            !_isNavigatingAway) {
          _isNavigatingAway = true;
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.youHaveBeenKickedFrom(state.chatName)),
              backgroundColor: Theme.of(context).colorScheme.error,
              duration: const Duration(seconds: 2),
            ),
          );
          // Cerrar ChatRoomDetailsPage y luego ChatRoomPage
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              final navigator = Navigator.of(context);
              navigator.pop({'leftGroup': true});
              // Esperar un poco y cerrar también ChatRoomPage
              Future.delayed(const Duration(milliseconds: 100), () {
                if (mounted && navigator.canPop()) {
                  navigator.pop({'leftGroup': true});
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
    final userProvider = Provider.of<UserProvider>(context);
    final currentUserEmail =
        userProvider.email ??
        userProvider.user?['email'] as String? ??
        FirebaseAuth.instance.currentUser?.email ??
        '';

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context, updatedGroupData),
        ),
        title: Text(AppLocalizations.of(context)!.groupDetails),
        actions: [
          ChatRoomDetailsAdminEditButton(
            chatId: chatId,
            chatName: chatName,
            chatDescription: chatDescription,
            currentUserEmail: currentUserEmail,
            onRefresh: onRefresh,
            onGroupDataUpdated: onGroupDataUpdated,
          ),
        ],
      ),
      body: ChatRoomDetailsBody(
        chatId: chatId,
        chatName: chatName,
        chatDescription: chatDescription,
        refreshKey: refreshKey,
        onRefresh: onRefresh,
        onGroupDataUpdated: onGroupDataUpdated,
        updatedGroupData: updatedGroupData,
      ),
    );
  }
}
