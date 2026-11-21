import 'dart:async';
import 'package:flutter/material.dart';

/// Search bar shown at the top of the Explore page.
/// Fires [onSearch] with the trimmed query after a 300 ms debounce.
/// Fires [onSearchCleared] when the field is emptied.
class ExploreSearchBar extends StatefulWidget {
  final String initialLocation;
  final String subtitle;
  final VoidCallback? onFilterTap;
  final ValueChanged<String>? onSearch;
  final VoidCallback? onSearchCleared;

  const ExploreSearchBar({
    super.key,
    this.initialLocation = 'Search destinations...',
    this.subtitle = 'Anytime · Add guests',
    this.onFilterTap,
    this.onSearch,
    this.onSearchCleared,
  });

  @override
  State<ExploreSearchBar> createState() => _ExploreSearchBarState();
}

class _ExploreSearchBarState extends State<ExploreSearchBar> {
  late final TextEditingController _controller;
  Timer? _debounce;
  bool _hasText = false;

  static const Color _teal = Color(0xFF006972);

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final text = _controller.text;
    final hasText = text.isNotEmpty;
    if (_hasText != hasText) {
      setState(() => _hasText = hasText);
    }
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      final trimmed = text.trim();
      if (trimmed.isEmpty) {
        widget.onSearchCleared?.call();
      } else {
        widget.onSearch?.call(trimmed);
      }
    });
  }

  void _clearSearch() {
    _debounce?.cancel();
    _controller.clear();
    setState(() => _hasText = false);
    widget.onSearchCleared?.call();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.search, size: 28, color: _teal),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _controller,
                    cursorColor: _teal,
                    style: const TextStyle(
                      color: Color(0xFF2A1B12),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'HankenGrotesk',
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                      hintText: widget.initialLocation,
                      hintStyle: const TextStyle(
                        color: Color(0xFF8A7B6E),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'HankenGrotesk',
                      ),
                    ),
                    textInputAction: TextInputAction.search,
                    onSubmitted: (value) {
                      _debounce?.cancel();
                      final trimmed = value.trim();
                      if (trimmed.isEmpty) {
                        widget.onSearchCleared?.call();
                      } else {
                        widget.onSearch?.call(trimmed);
                      }
                    },
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.subtitle,
                    style: const TextStyle(
                      color: Color(0xFF8A7B6E),
                      fontSize: 12,
                      fontFamily: 'HankenGrotesk',
                    ),
                  ),
                ],
              ),
            ),
            // Clear button while typing, filter button otherwise
            if (_hasText)
              GestureDetector(
                onTap: _clearSearch,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE0D9D0),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 14,
                    color: Color(0xFF2A1B12),
                  ),
                ),
              )
            else
              IconButton(
                onPressed: widget.onFilterTap,
                icon: const Icon(Icons.tune, size: 26, color: Color(0xFF2A1B12)),
                splashRadius: 20,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
      ),
    );
  }
}
