import 'package:flutter/material.dart';

// === Label de Sección ===
class ProfileSectionLabel extends StatelessWidget {
  final String text;
  const ProfileSectionLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.outline;
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// === Tarjeta Blanca Estilizada ===
class ProfileStyledCard extends StatelessWidget {
  final List<Widget> children;
  const ProfileStyledCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(children: children),
    );
  }
}

// === Campo de Texto Estilo iOS ===
class ProfileStyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool readOnly;
  final bool showDivider;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;

  const ProfileStyledTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.readOnly = false,
    this.showDivider = true,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final mutedColor = theme.colorScheme.outline;
    return Column(
      children: [
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: TextStyle(
            color: readOnly ? mutedColor : onSurface,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(color: mutedColor, fontSize: 14),
            border: InputBorder.none,
            prefixIcon: Icon(
              icon,
              color: readOnly ? mutedColor : onSurface,
              size: 20,
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 40),
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            isDense: true,
          ),
          validator: validator,
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            color: theme.dividerColor,
            indent: 40, 
          ),
      ],
    );
  }
}

// === Decoración para Dropdowns ===
InputDecoration cardInputDecoration({required IconData icon, required BuildContext context}) {
  return InputDecoration(
    border: InputBorder.none,
    prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.onSurface, size: 20),
    contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 14),
    isDense: true,
  );
}