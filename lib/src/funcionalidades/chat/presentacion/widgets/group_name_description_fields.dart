import 'package:flutter/material.dart';

class GroupNameDescriptionFields extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final String nameLabel;
  final String descriptionLabel;
  final String? Function(String?)? nameValidator;
  final bool isEnabled;

  const GroupNameDescriptionFields({
    super.key,
    required this.nameController,
    required this.descriptionController,
    required this.nameLabel,
    required this.descriptionLabel,
    this.nameValidator,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: nameController,
          enabled: isEnabled,
          decoration: InputDecoration(
            labelText: nameLabel,
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.group),
          ),
          maxLength: 50,
          validator: nameValidator,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: descriptionController,
          enabled: isEnabled,
          decoration: InputDecoration(
            labelText: descriptionLabel,
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.description),
          ),
          maxLines: 2,
          maxLength: 200,
        ),
      ],
    );
  }
}
