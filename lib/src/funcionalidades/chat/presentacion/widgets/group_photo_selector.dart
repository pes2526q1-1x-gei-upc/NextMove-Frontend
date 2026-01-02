import 'dart:io';
import 'package:flutter/material.dart';

class GroupPhotoSelector extends StatelessWidget {
  final File? selectedImage;
  final String? currentPhotoUrl;
  final VoidCallback onPickImage;
  final bool isLoading;

  const GroupPhotoSelector({
    super.key,
    this.selectedImage,
    this.currentPhotoUrl,
    required this.onPickImage,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: GestureDetector(
        onTap: isLoading ? null : onPickImage,
        child: Stack(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: theme.colorScheme.primaryContainer,
              backgroundImage: selectedImage != null
                  ? FileImage(selectedImage!)
                  : (currentPhotoUrl != null
                            ? NetworkImage(currentPhotoUrl!)
                            : null)
                        as ImageProvider?,
              child: (selectedImage == null && currentPhotoUrl == null)
                  ? Icon(
                      Icons.group,
                      size: 60,
                      color: theme.colorScheme.onPrimaryContainer,
                    )
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 4,
              child: CircleAvatar(
                radius: 18,
                backgroundColor: theme.colorScheme.primary,
                child: const Icon(Icons.edit, size: 18, color: Colors.white),
              ),
            ),
            if (isLoading)
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.black26,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
