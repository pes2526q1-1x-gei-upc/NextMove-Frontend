import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/src/funcionalidades/social/presentation/bloc/social_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/social/presentation/bloc/social_event.dart';
import 'package:nextmove_app/src/funcionalidades/social/presentation/bloc/social_state.dart';

class BlockedUsersPage extends StatefulWidget {
  const BlockedUsersPage({super.key});

  @override
  State<BlockedUsersPage> createState() => _BlockedUsersPageState();
}

class _BlockedUsersPageState extends State<BlockedUsersPage> {
  @override
  void initState() {
    super.initState();
    context.read<SocialBloc>().add(LoadBlockedUsersEvent());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new),
          iconSize: 22,
        ),
        title: Text(
          l10n.bloquedUsers,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 26,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Lista de usuarios (sin cambios)
              Expanded(
                child: BlocConsumer<SocialBloc, SocialState>(
                  listener: (context, state) {
                    if (state.errorMessage != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.errorMessage!), backgroundColor: Colors.red),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state.status == SocialStatus.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    if (state.blockedUsers.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.block_flipped,
                              size: 60,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "No tienes usuarios bloqueados",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey[500], fontSize: 16),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: state.blockedUsers.length,
                      itemBuilder: (context, index) {
                        final user = state.blockedUsers[index];
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow:
                                Theme.of(context).brightness == Brightness.dark
                                    ? null
                                    : [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.03,
                                          ),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.surfaceContainerHighest,
                                    shape: BoxShape.circle,
                                    image: user.photo.isNotEmpty
                                        ? DecorationImage(
                                            image: NetworkImage(user.photo),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: user.photo.isEmpty
                                      ? Icon(
                                          Icons.person,
                                          color: Theme.of(context)
                                              .iconTheme
                                              .color
                                              ?.withValues(alpha: 0.7),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 16),
                                
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user.apodo,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        "Bloqueado",
                                        style: TextStyle(
                                          color: Colors.red[300],
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                IconButton(
                                  onPressed: () {
                                     context.read<SocialBloc>().add(UnblockUserEvent(user.apodo));
                                  },
                                  icon: const Icon(Icons.lock_open_rounded),
                                  color: Colors.red,
                                  tooltip: "Desbloquear usuario",
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.red.withValues(alpha: 0.1),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              ],
                            ),
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
      ),
    );
  }
}