import 'package:flutter/material.dart';
import 'package:nextmove_app/src/funcionalidades/profile/domain/entities/user_entity.dart';

class SelectedUsersChips extends StatelessWidget {
  final Map<String, UserEntity> selectedUsers;
  final Function(UserEntity) onUserDeleted;

  const SelectedUsersChips({
    super.key,
    required this.selectedUsers,
    required this.onUserDeleted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (selectedUsers.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: selectedUsers.length,
        itemBuilder: (context, index) {
          final user = selectedUsers.values.elementAt(index);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Chip(
              avatar: CircleAvatar(
                radius: 14,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                backgroundImage: user.photo.isNotEmpty
                    ? NetworkImage(user.photo)
                    : null,
                child: user.photo.isEmpty
                    ? Icon(
                        Icons.person,
                        size: 16,
                        color: theme.colorScheme.onSurface,
                      )
                    : null,
              ),
              label: Text(
                user.apodo,
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
              backgroundColor: theme.colorScheme.primaryContainer,
              deleteIcon: Icon(
                Icons.close,
                size: 18,
                color: theme.colorScheme.onPrimaryContainer,
              ),
              onDeleted: () => onUserDeleted(user),
            ),
          );
        },
      ),
    );
  }
}
