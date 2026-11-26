import 'package:flutter/material.dart';
import 'property_types.dart';

/// Stay-type shortcuts under the search bar on Explore: "All" plus every
/// property type a host can list (Apartment, House, Villa, …). Scrolls
/// sideways. [onTypeSelected] fires with the type label, or null for All.
///
/// [selected] is owned by the page, so picking a type in Filters or on the
/// search screen highlights the matching shortcut here too.
class ExploreFilterBar extends StatelessWidget {
  final String? selected;
  final ValueChanged<String?>? onTypeSelected;

  const ExploreFilterBar({super.key, this.selected, this.onTypeSelected});

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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 26, color: color),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
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
    return SizedBox(
      height: 76,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        children: [
          _item(
            label: 'All',
            icon: Icons.explore_outlined,
            isSelected: selected == null,
            onTap: () => onTypeSelected?.call(null),
          ),
          for (final t in kPropertyTypes)
            _item(
              label: t.label,
              icon: t.icon,
              isSelected: selected == t.label,
              onTap: () => onTypeSelected?.call(t.label),
            ),
        ],
      ),
    );
  }
}
