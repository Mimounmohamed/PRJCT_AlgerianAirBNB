import 'package:flutter/material.dart';

class ExploreFilterItem {
  final String label;
  final IconData icon;

  const ExploreFilterItem({required this.label, required this.icon});
}

/// Category filter bar shown below the search bar on Explore.
///
/// Spans the full width of the page with items evenly spaced. Manages which
/// chip is selected locally (visual state only) — the actual category
/// filtering / API call is not wired up yet. [onCategorySelected] fires with
/// the selected label so that logic can be added later without changing
/// this widget.
class ExploreFilterBar extends StatefulWidget {
  final ValueChanged<String>? onCategorySelected;

  const ExploreFilterBar({super.key, this.onCategorySelected});

  @override
  State<ExploreFilterBar> createState() => _ExploreFilterBarState();
}

class _ExploreFilterBarState extends State<ExploreFilterBar> {
  static const Color _selectedColor = Color(0xFF006972);
  static const Color _unselectedColor = Color(0xFF4F4540);

  static const List<ExploreFilterItem> _items = [
    ExploreFilterItem(label: 'All', icon: Icons.explore_outlined),
    ExploreFilterItem(label: 'Riads', icon: Icons.apartment_outlined),
    ExploreFilterItem(label: 'Sea view', icon: Icons.waves),
    ExploreFilterItem(label: 'Casbah', icon: Icons.fort_outlined),
    ExploreFilterItem(label: 'Desert', icon: Icons.landscape_outlined),
  ];

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(_items.length, (index) {
          final item = _items[index];
          final isSelected = index == _selectedIndex;
          final color = isSelected ? _selectedColor : _unselectedColor;

          return Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                setState(() => _selectedIndex = index);
                widget.onCategorySelected?.call(item.label);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(item.icon, size: 28, color: color),
                    const SizedBox(height: 6),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'HenkenGrotesk',
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 6),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 2,
                      width: isSelected ? 20 : 0,
                      decoration: BoxDecoration(
                        color: _selectedColor,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}