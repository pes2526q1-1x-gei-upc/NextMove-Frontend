import 'package:flutter/material.dart';
import 'package:nextmove_app/src/funcionalidades/profile/domain/entities/user_entity.dart';
import 'package:nextmove_app/src/funcionalidades/profile/presentation/widgets/profile_form_widget.dart';

class UserSelectionCard extends StatelessWidget {
  final UserEntity user;
  final bool isSelected;
  final VoidCallback onTap;

  const UserSelectionCard({
    super.key,
    required this.user,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ProfileStyledCard(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                      backgroundImage: user.photo.isNotEmpty
                          ? NetworkImage(user.photo)
                          : null,
                      child: user.photo.isEmpty
                          ? Icon(
                              Icons.person,
                              size: 28,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
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
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (user.nombreCompleto.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              user.nombreCompleto,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Checkbox(
                      value: isSelected,
                      onChanged: (value) => onTap(),
                      activeColor: theme.colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
