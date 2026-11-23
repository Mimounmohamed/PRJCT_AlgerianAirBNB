import 'package:flutter/material.dart';

/// loading: spinner instead of an icon — stays until replaced or hidden
/// with ScaffoldMessenger.of(context).hideCurrentSnackBar().
enum AppToastType { success, error, info, loading }

/// The app's one style for short messages ("Booking accepted", "Failed to
/// save", …) — replaces Flutter's default dark snackbar everywhere.
///
/// Looks like the app's "Changes saved" popup: a cream rounded card with a
/// coloured circle icon (teal ✓ success, red ! error, teal i info),
/// floating above the bottom of the screen.
///
///   AppToast.show(context, 'Booking accepted.', type: AppToastType.success);
class AppToast {
  static const Color _cream = Color(0xFFFBF3E7);
  static const Color _dark = Color(0xFF2A1B12);
  static const Color _teal = Color(0xFF006972);
  static const Color _danger = Color(0xFFB3261E);
  static const Color _border = Color(0xFFE7DCCB);

  static void show(
    BuildContext context,
    String message, {
    AppToastType type = AppToastType.info,
    Duration? duration,
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    final color = type == AppToastType.error ? _danger : _teal;
    final icon = switch (type) {
      AppToastType.success => Icons.check_rounded,
      AppToastType.error => Icons.priority_high_rounded,
      AppToastType.info || AppToastType.loading => Icons.info_outline_rounded,
    };
    final defaultDuration = switch (type) {
      AppToastType.error => const Duration(milliseconds: 4000),
      AppToastType.loading => const Duration(minutes: 2),
      _ => const Duration(milliseconds: 2600),
    };

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
          padding: EdgeInsets.zero,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          duration: duration ?? defaultDuration,
          content: Container(
            padding: const EdgeInsets.fromLTRB(12, 12, 16, 12),
            decoration: BoxDecoration(
              color: _cream,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: type == AppToastType.error ? _danger.withValues(alpha: 0.35) : _border),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 18, offset: const Offset(0, 6)),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  padding: type == AppToastType.loading ? const EdgeInsets.all(8) : null,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  child: type == AppToastType.loading
                      ? const CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                      : Icon(icon, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message.replaceFirst('Exception: ', ''),
                    style: const TextStyle(
                      color: _dark,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                      fontFamily: 'HankenGrotesk',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }

  static void success(BuildContext context, String message) => show(context, message, type: AppToastType.success);
  static void error(BuildContext context, String message) => show(context, message, type: AppToastType.error);
  static void info(BuildContext context, String message) => show(context, message, type: AppToastType.info);
  static void loading(BuildContext context, String message, {Duration? duration}) =>
      show(context, message, type: AppToastType.loading, duration: duration);
}
