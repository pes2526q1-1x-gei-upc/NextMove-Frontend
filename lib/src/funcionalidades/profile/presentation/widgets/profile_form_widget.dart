import 'package:flutter/material.dart';

// === Label de Sección ===
class ProfileSectionLabel extends StatelessWidget {
  final String text;
  const ProfileSectionLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
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
    return Column(
      children: [
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: TextStyle(
            color: readOnly ? Colors.grey[600] : const Color(0xFF1A1A1A),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
            border: InputBorder.none,
            prefixIcon: Icon(icon, color: readOnly ? Colors.grey[400] : Colors.black87, size: 20),
            prefixIconConstraints: const BoxConstraints(minWidth: 40),
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            isDense: true,
          ),
          validator: validator,
        ),
        if (showDivider)
          const Divider(
            height: 1,
            thickness: 1,
            color: Color(0xFFF0F0F0),
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
    prefixIcon: Icon(icon, color: Colors.black87, size: 20),
    contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 14),
    isDense: true,
  );
}