import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/src/funcionalidades/social/presentation/bloc/social_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/social/presentation/bloc/social_event.dart';

class SocialSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onSearchChanged;

  const SocialSearchBar({
    super.key,
    required this.controller,
    required this.onSearchChanged,
  });

  @override
  State<SocialSearchBar> createState() => _SocialSearchBarState();
}

class _SocialSearchBarState extends State<SocialSearchBar> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _handleSearch(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    // Debounce de 500ms para evitar spam de peticiones
    _debounce = Timer(const Duration(milliseconds: 500), () {
      widget.onSearchChanged(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: Theme.of(context).brightness == Brightness.dark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: TextField(
        controller: widget.controller,
        onChanged: _handleSearch,
        decoration: InputDecoration(
          hintText: l10n.searchByNickname,
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          suffixIcon: widget.controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    widget.controller.clear();
                    _debounce?.cancel();
                    context.read<SocialBloc>().add(ClearSearchEvent());
                    setState(() {});
                  },
                )
              : null,
        ),
      ),
    );
  }
}
