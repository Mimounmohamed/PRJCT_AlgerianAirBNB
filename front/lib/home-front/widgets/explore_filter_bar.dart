import 'package:flutter/material.dart';
import 'property_types.dart';

/// Stay shortcuts under the search bar on Explore: "All" plus 4 groups
/// (Apartments, Houses, Hotels, Cabins), each covering 2 property types —
/// see kStayGroups. Fits the screen width, no scrolling.
///
/// [selectedTypes] is owned by the page: a shortcut is highlighted when
/// the current type filter is exactly its group (or empty for All), so
/// picking types in Filters stays in sync. [onSelected] fires with the
/// group's types, or an empty set for All.
class ExploreFilterBar extends StatelessWidget {
  final Set<String> selectedTypes;
  final ValueChanged<Set<String>>? onSelected;

  const ExploreFilterBar({super.key, this.selectedTypes = const {}, this.onSelected});

  static const Color _selectedColor = Color(0xFF006972);
  static const Color _unselectedColor = Color(0xFF4F4540);

  Widget _item({required String label, required IconData icon, required bool isSelected, required VoidCallback onTap}) {
    final color = isSelected ? _selectedColor : _unselectedColor;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 28, color: color),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'HankenGrotesk',
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                  color: color,
                ),
              ),
              const SizedBox(height: 6),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 2,
                width: isSelected ? 20 : 0,
                decoration: BoxDecoration(color: _selectedColor, borderRadius: BorderRadius.circular(1)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedGroup = stayGroupFor(selectedTypes);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _item(
            label: 'All',
            icon: Icons.explore_outlined,
            isSelected: selectedTypes.isEmpty,
            onTap: () => onSelected?.call(const {}),
          ),
          for (final g in kStayGroups)
            _item(
              label: g.label,
              icon: g.icon,
              isSelected: selectedGroup == g,
              onTap: () => onSelected?.call(g.types),
            ),
        ],
      ),
    );
  }
}
