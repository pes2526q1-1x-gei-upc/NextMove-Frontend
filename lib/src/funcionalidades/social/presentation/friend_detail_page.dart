import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/bloc/user/user_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/bloc/user/user_state.dart';
import 'package:nextmove_app/src/funcionalidades/social/presentation/bloc/social_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/social/presentation/bloc/social_event.dart';
import 'package:nextmove_app/src/funcionalidades/social/presentation/bloc/social_state.dart';
import 'package:nextmove_app/src/funcionalidades/social/presentation/widgets/friend_detail_content.dart';
import 'package:provider/provider.dart';
import 'package:nextmove_app/src/funcionalidades/auth/dominio/providers/user_provider.dart';

class FriendDetailsPage extends StatelessWidget {
  const FriendDetailsPage({super.key});

  // --- Lógica para Bloquear Usuario ---
  Future<void> _onBlockPressed(BuildContext context, String userToBlock) async {
    final l10n = AppLocalizations.of(context)!;

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.blockUser),
        content: Text(
          l10n.blockUserConfirmation(userToBlock),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              l10n.cancel,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              l10n.block,
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final userProvider = Provider.of<UserProvider>(
        context,
        listen: false,
      ).user;
      final myNickname = userProvider?['nickname'];

      if (myNickname != null) {
        context.read<SocialBloc>().add(BlockUserEvent(myNickname, userToBlock));

        Navigator.pop(context); // Cerramos la página de detalles

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Has bloqueado a $userToBlock"),
            backgroundColor: const Color(0xFF333333),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    try {
      final userBloc = context.read<UserBloc>();
      if (kDebugMode) {
        print("FriendDetailsPage: Found UserBloc ${userBloc.hashCode}");
      }
    } catch (e) {
      if (kDebugMode) {
        print("FriendDetailsPage: Could not find UserBloc: $e");
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black87,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,

        // === BOTÓN DE BLOQUEO EN APPBAR ===
        actions: [
          BlocBuilder<UserBloc, UserState>(
            builder: (context, state) {
              if (state is UserLoaded) {
                return IconButton(
                  icon: const Icon(
                    Icons.block_rounded,
                    color: Colors.redAccent,
                  ),
                  tooltip: "Bloquear usuario",
                  onPressed: () => _onBlockPressed(context, state.user.apodo),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: BlocListener<SocialBloc, SocialState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Column(
          children: [
            // --- CONTENIDO DEL PERFIL ---
            Expanded(
              child: BlocBuilder<UserBloc, UserState>(
                builder: (context, state) {
                  if (state is UserLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is UserError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.redAccent,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "${l10n.errorLoadingProfile}\n${state.message}",
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else if (state is UserLoaded) {
                    return FriendDetailsContent(user: state.user);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),

            // --- BOTÓN DE ELIMINAR AMIGO ---
            BlocBuilder<UserBloc, UserState>(
              builder: (context, userState) {
                if (userState is UserLoaded) {
                  final viewedUser = userState.user;

                  return BlocBuilder<SocialBloc, SocialState>(
                    builder: (context, socialState) {
                      // Verificamos si está en la lista de amigos
                      final isFriend = socialState.friends.any(
                        (friend) => friend.apodo == viewedUser.apodo,
                      );

                      if (isFriend) {
                        return _DeleteFriendButton(
                          friendNickname: viewedUser.apodo,
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}

// === Widget Privado: Botón Eliminar ===
class _DeleteFriendButton extends StatelessWidget {
  final String friendNickname;

  const _DeleteFriendButton({required this.friendNickname});

  Future<void> _onRemovePressed(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.deleteFriendship),
        content: Text(l10n.deleteFriendConfirmation(friendNickname)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              l10n.cancel,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              l10n.delete,
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final userProvider = Provider.of<UserProvider>(
        context,
        listen: false,
      ).user;
      final myNickname = userProvider?['nickname'];

      if (myNickname != null) {
        context.read<SocialBloc>().add(
          DeleteFriendEvent(myNickname, friendNickname),
        );

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.deletedFriend(friendNickname)),
            backgroundColor: const Color(0xFF333333),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 40),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _onRemovePressed(context),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.person_remove_rounded,
                    color: Colors.redAccent,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    l10n.deleteFriend,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
