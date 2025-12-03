import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// === Header del Perfil (Avatar + Texto) ===
// This widget displays the user's profile header with their photo and name
class ProfileHeaderWidget extends StatelessWidget {
  final String title;
  final String subtitle;

  // STEP 1: Add an optional parameter to receive the photo URL
  // The '?' makes it nullable, meaning it can be null if no photo exists
  // This is the same pattern used in ProfileAvatarSelector in edit_user_data_preferences
  final String? imageUrl;

  const ProfileHeaderWidget({
    super.key,
    required this.title,
    required this.subtitle,
    this.imageUrl, // Optional parameter - can be null
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // STEP 2: Determine which image to display
    // This is the KEY LOGIC for loading user photos anywhere in your app
    // We need to decide between three options:
    // - NetworkImage: if user has uploaded a photo (imageUrl is not null/empty)
    // - AssetImage: if no photo exists (imageUrl is null or empty)
    // - Icon: as a fallback (we'll keep this as default)

    ImageProvider? backgroundImage;
    Widget? avatarChild;

    // STEP 3: Check if imageUrl exists and is not empty
    // This is CRITICAL - always check both null AND empty string
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      // USER HAS A PHOTO - use NetworkImage to load from URL
      // NetworkImage automatically handles downloading and caching the image
      backgroundImage = NetworkImage(imageUrl!);
      avatarChild = null; // Don't show icon when we have an image

      if (kDebugMode) {
        print('ProfileHeader: Loading user photo from URL: $imageUrl');
      }
    } else {
      // USER HAS NO PHOTO - use default icon
      // We set backgroundImage to null and provide a child icon instead
      backgroundImage = null;
      avatarChild = const Icon(Icons.person, size: 40, color: Colors.grey);

      if (kDebugMode) {
        print('ProfileHeader: No photo URL provided, showing default icon');
      }
    }

    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: theme.cardColor, width: 3),
            boxShadow: theme.brightness == Brightness.dark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
          ),
          // STEP 4: Apply the image logic to CircleAvatar
          // CircleAvatar has two main properties for displaying content:
          // - backgroundImage: for actual images (NetworkImage, AssetImage, FileImage)
          // - child: for widgets like icons or text when no image exists
          child: CircleAvatar(
            radius: 35,
            backgroundColor: Colors.grey[200],
            backgroundImage: backgroundImage, // Will be NetworkImage or null
            child: avatarChild, // Will be Icon or null
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      color: theme.colorScheme.outline,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// === Opción de Menú ===
class ProfileMenuOption extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const ProfileMenuOption({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 
                        Theme.of(context).brightness == Brightness.dark ? 0.35 : 1,
                      ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// === Divisor Sutil ===
class ProfileMenuDivider extends StatelessWidget {
  const ProfileMenuDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 60,
      endIndent: 0,
      color: Theme.of(context).dividerColor,
    );
  }
}

