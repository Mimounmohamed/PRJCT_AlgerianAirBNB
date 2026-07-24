import 'package:flutter/material.dart';
import 'algeria_wilayas_data.dart';

/// Reusable Wilaya (province) + Baladiya (commune) cascading selector.
///
/// Shows two field-style pickers stacked vertically: selecting a Wilaya
/// resets and unlocks the Baladiya picker for that Wilaya's communes.
/// Both open a themed, searchable bottom sheet instead of a native
/// dropdown, styled to match the rest of the app's fields.
///
/// Usage:
/// ```dart
/// WilayaBaladiyaSelector(
///   selectedWilayaCode: _wilayaCode,
///   selectedBaladiya: _baladiya,
///   onWilayaChanged: (code) => setState(() {
///     _wilayaCode = code;
///     _baladiya = null; // reset commune when the province changes
///   }),
///   onBaladiyaChanged: (baladiya) => setState(() => _baladiya = baladiya),
/// )
/// ```
class WilayaBaladiyaSelector extends StatelessWidget {
  const WilayaBaladiyaSelector({
    super.key,
    required this.selectedWilayaCode,
    required this.selectedBaladiya,
    required this.onWilayaChanged,
    required this.onBaladiyaChanged,
    this.wilayaLabel = 'Wilaya',
    this.baladiyaLabel = 'Baladiya',
  });

  final String? selectedWilayaCode;
  final String? selectedBaladiya;
  final ValueChanged<String> onWilayaChanged;
  final ValueChanged<String> onBaladiyaChanged;
  final String wilayaLabel;
  final String baladiyaLabel;

  Future<void> _openPicker({
    required BuildContext context,
    required String title,
    required List<_PickerItem> items,
    required ValueChanged<String> onSelected,
  }) async {
    String query = '';
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFFFBF3E7),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = query.isEmpty
                ? items
                : items
                    .where((item) =>
                        item.label.toLowerCase().contains(query.toLowerCase()))
                    .toList();
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.75,
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD9CDB5),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'CormorantGaramond',
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        autofocus: false,
                        onChanged: (value) =>
                            setModalState(() => query = value),
                        decoration: InputDecoration(
                          hintText: 'Search $title',
                          hintStyle: const TextStyle(color: Color(0xFFB8AE9C)),
                          prefixIcon: const Icon(Icons.search,
                              color: Color(0xFFB0A48C), size: 20),
                          filled: true,
                          fillColor: const Color(0xFFF3E9D8),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: filtered.isEmpty
                            ? const Center(
                                child: Text(
                                  'No results',
                                  style: TextStyle(color: Color(0xFF6B6B6B)),
                                ),
                              )
                            : ListView.separated(
                                itemCount: filtered.length,
                                separatorBuilder: (context, index) =>
                                    const Divider(
                                  height: 1,
                                  color: Color(0xFFEFE6D6),
                                ),
                                itemBuilder: (context, index) {
                                  final item = filtered[index];
                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: Text(
                                      item.label,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Color(0xFF1A1A1A),
                                      ),
                                    ),
                                    trailing: const Icon(
                                      Icons.chevron_right,
                                      color: Color(0xFFB0A48C),
                                      size: 18,
                                    ),
                                    onTap: () {
                                      onSelected(item.value);
                                      Navigator.of(context).pop();
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _pickerField({
    required BuildContext context,
    required String label,
    required String? value,
    required String placeholder,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: enabled ? onTap : null,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: enabled
                  ? const Color(0xFFFBF3E7)
                  : const Color(0xFFF3EEE1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFD9CDB5)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value ?? placeholder,
                    style: TextStyle(
                      color: value != null
                          ? const Color(0xFF1A1A1A)
                          : const Color(0xFFB8AE9C),
                      fontSize: 15,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: enabled
                      ? const Color(0xFFB0A48C)
                      : const Color(0xFFD9CDB5),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedWilaya = selectedWilayaCode != null
        ? algeriaWilayas[selectedWilayaCode]
        : null;
    final baladiyas = selectedWilaya?.baladiyas ?? const <String>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _pickerField(
          context: context,
          label: wilayaLabel,
          value: selectedWilaya?.name,
          placeholder: 'Select your wilaya',
          onTap: () => _openPicker(
            context: context,
            title: wilayaLabel,
            items: algeriaWilayas.values
                .map((w) =>
                    _PickerItem(label: '${w.code} - ${w.name}', value: w.code))
                .toList(),
            onSelected: onWilayaChanged,
          ),
        ),
        const SizedBox(height: 16),
        _pickerField(
          context: context,
          label: baladiyaLabel,
          value: selectedBaladiya,
          placeholder: selectedWilaya == null
              ? 'Select a wilaya first'
              : 'Select your baladiya',
          enabled: selectedWilaya != null,
          onTap: () => _openPicker(
            context: context,
            title: baladiyaLabel,
            items: baladiyas
                .map((b) => _PickerItem(label: b, value: b))
                .toList(),
            onSelected: onBaladiyaChanged,
          ),
        ),
      ],
    );
  }
}

class _PickerItem {
  const _PickerItem({required this.label, required this.value});
  final String label;
  final String value;
}