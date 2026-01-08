import 'dart:io';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/src/funcionalidades/profile/data/dataproviders/user_remote_data_provider.dart';
import 'package:nextmove_app/src/funcionalidades/profile/domain/entities/user_entity.dart';
import 'package:nextmove_app/graphql/queries.dart';
import 'package:nextmove_app/src/funcionalidades/chat/datos/dataproviders/chat_remote_data_provider.dart';
import 'package:nextmove_app/src/funcionalidades/chat/presentacion/widgets/group_photo_selector.dart';
import 'package:nextmove_app/src/funcionalidades/chat/presentacion/widgets/group_name_description_fields.dart';
import 'package:nextmove_app/src/funcionalidades/chat/presentacion/widgets/add_participant_search_bar.dart';
import 'package:nextmove_app/src/funcionalidades/chat/presentacion/widgets/selected_users_chips.dart';
import 'package:nextmove_app/src/funcionalidades/chat/presentacion/widgets/user_selection_card.dart';
import 'package:nextmove_app/src/funcionalidades/chat/presentacion/widgets/empty_user_list_placeholder.dart';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  final Map<String, UserEntity> _selectedFriends = {};
  String _searchQuery = '';
  bool _isCreating = false;

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  void _toggleFriendSelection(UserEntity user) {
    setState(() {
      if (_selectedFriends.containsKey(user.email)) {
        _selectedFriends.remove(user.email);
      } else {
        _selectedFriends[user.email] = user;
      }
    });
  }

  Future<void> _createGroup(BuildContext context) async {
    final name = _nameController.text.trim();
    final l10n = AppLocalizations.of(context)!;

    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.groupNameRequired)));
      return;
    }

    if (_selectedFriends.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.selectAtLeastOneFriend)));
      return;
    }

    setState(() => _isCreating = true);

    final remoteProvider = UserRemoteDataProvider();
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);

    try {
      String? photoUrl;
      if (_selectedImage != null) {
        photoUrl = await remoteProvider.uploadPhoto(_selectedImage!);
      }

      debugPrint('[CreateGroupPage] Ejecutando mutación...');
      final chatProvider = ChatRemoteDataProvider();
      await chatProvider.createGroupChat(
        name: name,
        description: _descriptionController.text.trim(),
        participantEmails: _selectedFriends.keys.toList(),
        photo: photoUrl,
      );

      navigator.pop(true);
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(l10n.groupCreatedSuccessfully)),
      );
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('${l10n.error}: $e'),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.createGroup),
        actions: [
          if (_isCreating)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: () => _createGroup(context),
              child: Text(
                l10n.create,
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                GroupPhotoSelector(
                  selectedImage: _selectedImage,
                  onPickImage: _pickImage,
                  isLoading: _isCreating,
                ),
                const SizedBox(height: 24),
                GroupNameDescriptionFields(
                  nameController: _nameController,
                  descriptionController: _descriptionController,
                  nameLabel: l10n.groupName,
                  descriptionLabel: l10n.descriptionOptional,
                ),
              ],
            ),
          ),
          SelectedUsersChips(
            selectedUsers: _selectedFriends,
            onUserDeleted: _toggleFriendSelection,
          ),
          AddParticipantSearchBar(
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value),
            onClear: () {
              _searchController.clear();
              setState(() => _searchQuery = '');
            },
          ),
          Expanded(
            child: Query(
              options: QueryOptions(
                document: gql(GraphQLQueries.getFriends),
                fetchPolicy: FetchPolicy.networkOnly,
              ),
              builder: (result, {fetchMore, refetch}) {
                if (result.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (result.hasException) {
                  return Center(child: Text(l10n.errorLoadingFriendsList));
                }

                final friendsData =
                    result.data?['ListFriends'] as List<dynamic>? ?? [];

                final List<UserEntity> friends = friendsData.map((f) {
                  final map = {
                    'email': f['email'],
                    'nickname':
                        f['name'],
                    'name': f['name'],
                    'photo': f['photo'],
                  };
                  return UserEntity.fromRawData(map);
                }).toList();

                final filteredFriends = friends.where((f) {
                  return f.apodo.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      ) ||
                      f.email.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      );
                }).toList();

                if (filteredFriends.isEmpty) {
                  return EmptyUserListPlaceholder(
                    isSearching: _searchQuery.isNotEmpty,
                    message: _searchQuery.isNotEmpty
                        ? l10n.noFriendsFoundSearch
                        : l10n.noFriendsToAdd,
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  itemCount: filteredFriends.length,
                  itemBuilder: (context, index) {
                    final friend = filteredFriends[index];
                    return UserSelectionCard(
                      user: friend,
                      isSelected: _selectedFriends.containsKey(friend.email),
                      onTap: () => _toggleFriendSelection(friend),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
