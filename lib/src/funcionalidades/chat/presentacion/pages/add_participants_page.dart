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
import 'package:nextmove_app/src/funcionalidades/chat/presentacion/widgets/add_participant_search_bar.dart';
import 'package:nextmove_app/src/funcionalidades/chat/presentacion/widgets/selected_users_chips.dart';
import 'package:nextmove_app/src/funcionalidades/chat/presentacion/widgets/user_selection_card.dart';
import 'package:nextmove_app/src/funcionalidades/chat/presentacion/widgets/empty_user_list_placeholder.dart';

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

  void _clearSearch() {
    _searchController.clear();
    _debounce?.cancel();
    context.read<SocialBloc>().add(ClearSearchEvent());
    setState(() {});
  }

  void _toggleUserSelection(UserEntity user) {
    final l10n = AppLocalizations.of(context)!;
    if (user.email.isEmpty) {
      debugPrint('[AddParticipants] ERROR: Usuario ${user.apodo} sin email');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.userWithoutValidEmail)));
      return;
    }

    setState(() {
      if (_selectedUserEmails.contains(user.email)) {
        _selectedUserEmails.remove(user.email);
        _selectedUsers.remove(user.email);
      } else {
        _selectedUserEmails.add(user.email);
        _selectedUsers[user.email] = user;
      }
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
    final l10n = AppLocalizations.of(context)!;
    final client = GraphQLProvider.of(context).value;
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    bool allSuccess = true;
    int successCount = 0;

    for (final email in emails) {
      if (email.isEmpty) continue;

      try {
        final result = await client.mutate(
          MutationOptions(
            document: gql(GraphQLMutations.addParticipantToGroupMutation),
            variables: {'chatId': widget.chatId, 'userEmail': email},
          ),
        );

        if (result.hasException) {
          allSuccess = false;
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(
                l10n.errorAddingParticipant(email, result.exception.toString()),
              ),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        } else {
          successCount++;
        }
      } catch (e) {
        allSuccess = false;
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(l10n.errorAddingParticipant(email, e.toString())),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    }

    if (allSuccess && successCount > 0) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(l10n.participantsAddedCorrectly),
          backgroundColor: Colors.green,
        ),
      );
      navigator.pop(true);
    } else if (successCount > 0) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
            l10n.someParticipantsFailed,
          ),
          backgroundColor: Colors.orange,
        ),
      );
      navigator.pop(true);
    } else {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(l10n.couldNotAddParticipants),
          backgroundColor: theme.colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(l10n.addParticipants),
        actions: [
          if (_selectedUserEmails.isNotEmpty)
            TextButton(
              onPressed: () => _addParticipantsSequentially(
                context,
                _selectedUserEmails.toList(),
                theme,
              ),
              child: Text(
                '${l10n.add} (${_selectedUserEmails.length})',
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
            AddParticipantSearchBar(
              controller: _searchController,
              onChanged: (value) {
                setState(() {});
                _onSearchChanged(value);
              },
              onClear: _clearSearch,
            ),
            SelectedUsersChips(
              selectedUsers: _selectedUsers,
              onUserDeleted: _toggleUserSelection,
            ),
            Expanded(
              child: BlocBuilder<SocialBloc, SocialState>(
                builder: (context, state) {
                  if (state.status == SocialStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final usersToShow = state.isSearching
                      ? state.searchResults
                      : state.friends;

                  final filteredUsers = usersToShow.where((user) {
                    return user.email.isNotEmpty &&
                        !_isUserAlreadyParticipant(user) &&
                        !_isCurrentUser(user);
                  }).toList();

                  if (filteredUsers.isEmpty) {
                    return EmptyUserListPlaceholder(
                      isSearching: state.isSearching,
                      message: state.isSearching
                          ? l10n.noUsersFound
                          : l10n.noUsersAvailableToAdd,
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
                      return UserSelectionCard(
                        user: user,
                        isSelected: _selectedUserEmails.contains(user.email),
                        onTap: () => _toggleUserSelection(user),
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
