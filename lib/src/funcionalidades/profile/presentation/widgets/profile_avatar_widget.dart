import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';

class ProfileAvatarSelector extends StatefulWidget {
  final File? selectedImageFile;
  final String? imageUrl;
  final AssetImage defaultImage;
  final Function(File) onImagePicked;

  const ProfileAvatarSelector({
    super.key,
    required this.selectedImageFile,
    this.imageUrl,
    required this.defaultImage,
    required this.onImagePicked,
  });

  @override
  State<ProfileAvatarSelector> createState() => _ProfileAvatarSelectorState();
}

class _ProfileAvatarSelectorState extends State<ProfileAvatarSelector> {
  final ImagePicker _picker = ImagePicker();

  // === Lógica interna del Picker ===
  void _showImageSourceActionSheet(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.black87),
              title: Text(l10n.gallery),
              onTap: () {
                _pickImage(ImageSource.gallery, context);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.black87),
              title: Text(l10n.camera),
              onTap: () {
                _pickImage(ImageSource.camera, context);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source, BuildContext context) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        // Llamamos al callback del padre con la nueva imagen
        widget.onImagePicked(File(pickedFile.path));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.imagePickerError),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider;
    if (widget.selectedImageFile != null) {
      imageProvider = FileImage(widget.selectedImageFile!);
    } else if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
      imageProvider = NetworkImage(widget.imageUrl!);
    } else {
      imageProvider = widget.defaultImage;
    }

    return Center(
      child: GestureDetector(
        onTap: () => _showImageSourceActionSheet(context),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            children: [
              CircleAvatar(
                radius: 55,
                backgroundColor: Colors.grey[200],
                backgroundImage: imageProvider,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.edit, size: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
