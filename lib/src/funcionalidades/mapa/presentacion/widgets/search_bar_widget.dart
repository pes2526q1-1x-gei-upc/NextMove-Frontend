import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/bloc/map_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/bloc/map_events.dart';

class SearchBarWidget extends StatefulWidget {
  final ValueChanged<String>? onChanged;
  final String hintText;
  final ValueChanged<bool>? onFocusChanged;

  const SearchBarWidget({
    super.key,
    this.onChanged,
    required this.hintText,
    this.onFocusChanged,
  });

  @override
  State<SearchBarWidget> createState() => SearchBarWidgetState();
}

class SearchBarWidgetState extends State<SearchBarWidget> {
  late final TextEditingController _searchController;
  late final FocusNode _focusNode;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _focusNode = FocusNode();
    
    _focusNode.addListener(() {
      if (kDebugMode) {
        print('🔍 Focus changed: ${_focusNode.hasFocus}');
      }
      widget.onFocusChanged?.call(_focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void clearSearch() {
    _searchController.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = theme.cardColor;
    final iconColor = theme.colorScheme.onSurface.withOpacity(0.7);
    final shadowColor = Colors.black.withOpacity(isDark ? 0.45 : 0.18);

    return Positioned(
      top: 70,
      left: 16,
      right: 80,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              spreadRadius: 1,
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: widget.hintText,
            prefixIcon: Icon(Icons.search, color: iconColor),
            suffixIcon: _searchController.text.isNotEmpty ? 
              IconButton(
                icon: Icon(Icons.clear, color: iconColor),
                onPressed: () {
                  _searchController.clear();
                  context.read<MapBloc>().add(const ClearSearchEvent());
                  setState(() {});
                },
              ) 
              : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          ),
          onChanged: (value) {
              setState(() {});
              if (_debounce?.isActive ?? false) _debounce!.cancel();

              _debounce = Timer(const Duration(milliseconds: 500), () {
                if (value.isNotEmpty) {
                  context.read<MapBloc>().add(SearchStationsEvent(value));
                } else {
                  context.read<MapBloc>().add(const ClearSearchEvent());
                }
              });
          },
        ),
      ),
    );
  }
}