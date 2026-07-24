import 'package:flutter/material.dart';

/// Reusable app bar used across onboarding / sign-up screens.
///
/// Usage:
/// ```dart
/// Scaffold(
///   appBar: AkriliAppBar(
///     title: 'AKRILI',
///     onBack: () => Navigator.pop(context),
///   ),
///   body: ...,
/// )
/// ```
class AkriliAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AkriliAppBar({
    super.key,
    required this.title,
    this.onBack,
    this.showBackButton = true,
  });

  final String title;
  final VoidCallback? onBack;
  final bool showBackButton;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFFBF3E7), // cream background
      elevation: 0,
      centerTitle: true,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF0F4C4C)),
              onPressed: onBack ?? () => Navigator.of(context).maybePop(),
            )
          : null,
      title: Text(
          title,
          style: TextStyle(
            fontFamily: 'CormorantGaramond',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
            color: Color(0xFF1A1A1A),
          ),
        ),
    );
  }
}