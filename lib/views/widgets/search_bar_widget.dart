import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/note_provider.dart';
import '../../constants/app_constants.dart';

class SearchBarWidget extends StatefulWidget {
  final VoidCallback? onOpenFilter;

  const SearchBarWidget({
    super.key,
    this.onOpenFilter,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {});

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      Provider.of<NoteProvider>(context, listen: false).searchNotes(query);
    });
  }

  void _clearSearch() {
    _debounce?.cancel();
    _searchController.clear();
    Provider.of<NoteProvider>(context, listen: false).clearFilters();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: AppStrings.searchHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: _clearSearch,
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'Filter & Sort',
            onPressed: widget.onOpenFilter,
          ),
        ],
      ),
    );
  }
}
