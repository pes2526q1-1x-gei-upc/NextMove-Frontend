import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/bloc/user/user_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/bloc/user/user_event.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/bloc/user/user_state.dart';
import 'package:nextmove_app/src/funcionalidades/social/presentation/bloc/social_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/social/presentation/bloc/social_event.dart';
import 'package:nextmove_app/src/funcionalidades/social/presentation/bloc/social_state.dart';
import 'package:nextmove_app/src/funcionalidades/social/presentation/pages/friend_detail_page.dart';
import 'package:nextmove_app/src/funcionalidades/social/presentation/widgets/social_user_card_widget.dart';
import 'package:nextmove_app/src/funcionalidades/social/presentation/widgets/social_search_bar.dart';
import 'package:nextmove_app/src/funcionalidades/social/presentation/widgets/social_empty_state.dart';
import 'package:nextmove_app/src/funcionalidades/auth/dominio/providers/user_provider.dart';

class SocialPage extends StatefulWidget {
  const SocialPage({super.key});

  @override
  State<SocialPage> createState() => _SocialPageState();
}

class _SocialPageState extends State<SocialPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final userState = context.read<UserBloc>().state;
    
    // Carga inicial de amigos si el usuario ya está disponible
    if (userState is UserLoaded || userState is UserUpdated) {
      final nickname = (userState as dynamic).user.apodo;
      context.read<SocialBloc>().add(LoadFriendsEvent(nickname));
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    context.read<SocialBloc>().add(SearchUsersEvent(query));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.social,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SocialSearchBar(
                controller: _searchController,
                onSearchChanged: _onSearchChanged,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: BlocConsumer<SocialBloc, SocialState>(
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
                  builder: (context, state) {
                    if (state.status == SocialStatus.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final usersToShow =
                        state.isSearching ? state.searchResults : state.friends;
                    final String emptyMessage = state.isSearching
                        ? l10n.noUsersFound
                        : l10n.noFriendsAdded;

                    if (usersToShow.isEmpty) {
                      return SocialEmptyState(
                        isSearching: state.isSearching,
                        message: emptyMessage,
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12.0, left: 4),
                          child: Text(
                            state.isSearching ? l10n.results : l10n.yourFriends,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: usersToShow.length,
                            itemBuilder: (context, index) {
                              final user = usersToShow[index];

                              final bool isAlreadyFriend = state.friends.any(
                                (f) => f.apodo == user.apodo,
                              );
                              final bool showAddButton =
                                  state.isSearching && !isAlreadyFriend;

                              return SocialUserCard(
                                user: user,
                                isFriend: !showAddButton,
                                onTap: () {
                                  final socialBloc = context.read<SocialBloc>();

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return MultiBlocProvider(
                                          providers: [
                                            BlocProvider<UserBloc>(
                                              create: (context) {
                                                final bloc = UserBloc();
                                                bloc.add(
                                                  LoadUserProfile(user.apodo),
                                                );
                                                return bloc;
                                              },
                                            ),
                                            BlocProvider.value(
                                              value: socialBloc,
                                            ),
                                          ],
                                          child: const FriendDetailsPage(),
                                        );
                                      },
                                    ),
                                  );
                                },
                                onAddPressed: showAddButton
                                    ? () {
                                        final userProvider =
                                            Provider.of<UserProvider>(
                                          context,
                                          listen: false,
                                        ).user;
                                        final currentNickname =
                                            userProvider?['nickname'];
                                        context.read<SocialBloc>().add(
                                              AddFriendEvent(
                                                currentNickname,
                                                user.apodo,
                                              ),
                                            );
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              l10n.friendAdded(user.apodo),
                                            ),
                                            backgroundColor: Colors.green,
                                            duration: const Duration(
                                              seconds: 2,
                                            ),
                                          ),
                                        );
                                      }
                                    : null,
                              );
                            },
                          ),
                        ),
                      ],
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
