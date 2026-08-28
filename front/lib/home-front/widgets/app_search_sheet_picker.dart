import 'package:flutter/material.dart';

/// Searchable bottom-sheet list picker, styled to match the rest of the
/// Create Listing wizard (white rounded card, teal accents, same border
/// color as the field containers). Used for both Wilaya and Baladiya
/// selection so the two dropdowns look/behave identically.
class AppSearchSheetPicker {
  static const Color _dark = Color(0xFF2A1B12);
  static const Color _teal = Color(0xFF006972);
  static const Color _muted = Color(0xFF8A7B6E);
  static const Color _border = Color(0xFFE7DCCB);

  /// Shows the sheet and returns the selected item, or null if dismissed
  /// without a selection.
  static Future<String?> show({
    required BuildContext context,
    required String title,
    required List<String> options,
    String? selected,
    String emptyMessage = 'No results found.',
  }) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _SearchSheetBody(
        title: title,
        options: options,
        selected: selected,
        emptyMessage: emptyMessage,
      ),
    );
  }
}

class _SearchSheetBody extends StatefulWidget {
  final String title;
  final List<String> options;
  final String? selected;
  final String emptyMessage;

  const _SearchSheetBody({
    required this.title,
    required this.options,
    required this.selected,
    required this.emptyMessage,
  });

  @override
  State<_SearchSheetBody> createState() => _SearchSheetBodyState();
}

class _SearchSheetBodyState extends State<_SearchSheetBody> {
  static const Color _dark = Color(0xFF2A1B12);
  static const Color _teal = Color(0xFF006972);
  static const Color _muted = Color(0xFF8A7B6E);
  static const Color _border = Color(0xFFE7DCCB);

  late final TextEditingController _searchController = TextEditingController();
  late List<String> _filtered = widget.options;

  void _onSearchChanged(String query) {
    final normalized = query.trim().toLowerCase();
    setState(() {
      _filtered = normalized.isEmpty
          ? widget.options
          : widget.options.where((o) => o.toLowerCase().contains(normalized)).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFBF3E7),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: _border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.title,
                        style: const TextStyle(color: _dark, fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: _muted, size: 20),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _border),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    style: const TextStyle(color: _dark, fontSize: 15),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                      hintText: 'Search...',
                      hintStyle: TextStyle(color: _muted),
                      prefixIcon: Icon(Icons.search, color: _muted, size: 20),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _filtered.isEmpty
                    ? Center(
                        child: Text(widget.emptyMessage, style: const TextStyle(color: _muted)),
                      )
                    : ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                        itemCount: _filtered.length,
                        separatorBuilder: (_, __) => const Divider(height: 1, color: _border),
                        itemBuilder: (context, index) {
                          final option = _filtered[index];
                          final isSelected = option == widget.selected;
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              option,
                              style: TextStyle(
                                color: isSelected ? _teal : _dark,
                                fontSize: 15,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                            trailing: isSelected ? const Icon(Icons.check_circle, color: _teal, size: 20) : null,
                            onTap: () => Navigator.of(context).pop(option),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}