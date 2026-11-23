import 'package:flutter/material.dart';

/// One listing category: the chip a guest taps in Discover and the tag a
/// host puts on their listing. The backend filters on `listing.categories`
/// with these exact labels, so keep this list the only source of them.
class ListingCategory {
  final String label;
  final IconData icon;
  const ListingCategory(this.label, this.icon);
}

const List<ListingCategory> kListingCategories = [
  ListingCategory('Riads', Icons.apartment_outlined),
  ListingCategory('Sea view', Icons.waves),
  ListingCategory('Casbah', Icons.fort_outlined),
  ListingCategory('Desert', Icons.landscape_outlined),
];

const int kMaxListingCategories = 3;

/// Chips for choosing up to [kMaxListingCategories] categories, used in
/// the creation flow and in Edit listing details.
class ListingCategoryPicker extends StatelessWidget {
  final List<String> selected;
  final ValueChanged<List<String>> onChanged;

  const ListingCategoryPicker({super.key, required this.selected, required this.onChanged});

  static const Color _teal = Color(0xFF006972);
  static const Color _dark = Color(0xFF2A1B12);
  static const Color _muted = Color(0xFF8A7B6E);
  static const Color _border = Color(0xFFE7DCCB);

  @override
  Widget build(BuildContext context) {
    final atMax = selected.length >= kMaxListingCategories;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pick up to $kMaxListingCategories so guests find you in the Discover filters.',
          style: const TextStyle(color: _muted, fontSize: 13, height: 1.35),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: kListingCategories.map((c) {
            final isOn = selected.contains(c.label);
            final enabled = isOn || !atMax;
            return GestureDetector(
              onTap: !enabled
                  ? null
                  : () {
                      final next = List<String>.from(selected);
                      isOn ? next.remove(c.label) : next.add(c.label);
                      onChanged(next);
                    },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isOn ? _teal : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: isOn ? _teal : _border),
                ),
                child: Opacity(
                  opacity: enabled ? 1 : 0.4,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(c.icon, size: 18, color: isOn ? Colors.white : _dark),
                      const SizedBox(width: 6),
                      Text(
                        c.label,
                        style: TextStyle(
                          color: isOn ? Colors.white : _dark,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
