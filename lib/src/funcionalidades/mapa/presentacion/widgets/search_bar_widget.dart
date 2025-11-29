import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/bloc/map_bloc.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/bloc/map_events.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/presentacion/bloc/map_state.dart';

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
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  late final TextEditingController _searchController;
  late final FocusNode _focusNode;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _focusNode = FocusNode();
    
    _focusNode.addListener(() {
      print('🔍 Focus changed: ${_focusNode.hasFocus}');
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

  @override
  Widget build(BuildContext context) {
    // AÑADIR: Escuchar cambios en el estado para limpiar el texto
    return BlocListener<MapBloc, MapState>(
      listener: (context, state) {
        // Limpiar el texto cuando se limpia la búsqueda
        if (state is MapLoadedState && 
            state.searchQuery == null && 
            _searchController.text.isNotEmpty) {
          _searchController.clear();
          setState(() {});
        }
      },
      child: Positioned(
        top: 70,
        left: 16,
        right: 80,
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 5,
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _focusNode,
            decoration: InputDecoration(
              hintText: widget.hintText,
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: _searchController.text.isNotEmpty ? 
                IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
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
      ),
    );
  }
}