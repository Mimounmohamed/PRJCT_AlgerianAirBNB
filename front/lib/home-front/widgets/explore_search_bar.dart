import 'package:flutter/material.dart';

/// Search bar at the top of Explore. Tapping it opens the search screen
/// ([onTap]); typing happens there. Shows the current place (or a hint),
/// a ✕ to clear it, and the tune icon for Filters with a badge counting
/// the active filters.
class ExploreSearchBar extends StatelessWidget {
  final String? place;
  final String subtitle;
  final int activeFilters;
  final VoidCallback? onTap;
  final VoidCallback? onFilterTap;
  final VoidCallback? onClear;

  const ExploreSearchBar({
    super.key,
    this.place,
    this.subtitle = 'Anytime · Add guests',
    this.activeFilters = 0,
    this.onTap,
    this.onFilterTap,
    this.onClear,
  });

  static const Color _teal = Color(0xFF006972);
  static const Color _dark = Color(0xFF2A1B12);
  static const Color _muted = Color(0xFF8A7B6E);

  @override
  Widget build(BuildContext context) {
    final hasPlace = place != null && place!.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        elevation: 0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 6, 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4)),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.search, size: 26, color: _teal),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        hasPlace ? place! : 'Search destinations...',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: hasPlace ? _dark : _muted,
                          fontSize: 14,
                          fontWeight: hasPlace ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(subtitle, style: const TextStyle(color: _muted, fontSize: 12)),
                    ],
                  ),
                ),
                if (hasPlace)
                  IconButton(
                    onPressed: onClear,
                    splashRadius: 18,
                    icon: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(color: Color(0xFFE0D9D0), shape: BoxShape.circle),
                      child: const Icon(Icons.close, size: 14, color: _dark),
                    ),
                  ),
                IconButton(
                  onPressed: onFilterTap,
                  splashRadius: 20,
                  icon: Badge(
                    isLabelVisible: activeFilters > 0,
                    label: Text('$activeFilters'),
                    backgroundColor: _teal,
                    child: const Icon(Icons.tune, size: 26, color: _dark),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
