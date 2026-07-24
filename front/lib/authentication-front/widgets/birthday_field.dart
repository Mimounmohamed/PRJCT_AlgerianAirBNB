import 'package:flutter/material.dart';

/// Reusable date-of-birth field. Tapping anywhere on the field (or the
/// calendar icon) opens a themed [showDatePicker].
///
/// Usage:
/// ```dart
/// BirthdayField(
///   label: 'Birthday',
///   selectedDate: _birthday,
///   onDateSelected: (date) => setState(() => _birthday = date),
/// )
/// ```
class BirthdayField extends StatelessWidget {
  const BirthdayField({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.label = 'Birthday',
    this.hint = 'mm/dd/yyyy',
  });

  final String label;
  final String hint;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  String _format(DateTime date) {
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    return '$mm/$dd/${date.year}';
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(now.year - 100),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0F4C4C), // header background / selected day
              onPrimary: Colors.white, // header text / selected day text
              onSurface: Color(0xFF1A1A1A), // calendar body text
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF0F4C4C), // OK / Cancel
              ),
            ),
            dialogBackgroundColor: const Color(0xFFFBF3E7),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      onDateSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
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
          onTap: () => _pickDate(context),
          child: AbsorbPointer(
            child: TextField(
              controller: TextEditingController(
                text: selectedDate != null ? _format(selectedDate!) : '',
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: Color(0xFFB8AE9C)),
                suffixIcon: const Icon(
                  Icons.calendar_today_outlined,
                  color: Color(0xFFB0A48C),
                  size: 19,
                ),
                filled: true,
                fillColor: const Color(0xFFFBF3E7),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFD9CDB5)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFD9CDB5)),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}