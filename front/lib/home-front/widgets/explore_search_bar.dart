import 'package:flutter/material.dart';

/// Search bar shown at the top of the Explore page, below the app bar.
///
/// The location field is a real, editable TextField — the user can tap and
/// type directly into it with normal typing/deleting behavior. The default
/// location shows as a placeholder hint (not pre-filled text), so there's
/// nothing to delete before typing a search. No search/backend logic is
/// wired up yet; typed text currently goes nowhere. [onFilterTap] is
/// exposed for the tune button.
class ExploreSearchBar extends StatefulWidget {
  final String initialLocation;
  final String subtitle;
  final VoidCallback? onFilterTap;

  const ExploreSearchBar({
    super.key,
    this.initialLocation = 'Algiers',
    this.subtitle = 'Anytime · Add guests',
    this.onFilterTap,
  });

  @override
  State<ExploreSearchBar> createState() => _ExploreSearchBarState();
}

class _ExploreSearchBarState extends State<ExploreSearchBar> {
  late final TextEditingController _controller;

  static const Color _teal = Color(0xFF006972);

  @override
  void initState() {
    super.initState();
    // Starts empty — the default location is shown as a hint, not real
    // editable text, so typing/backspacing behaves normally right away.
    _controller = TextEditingController();
  }

  @override
  void dispose() {
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
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(
              Icons.search,
              size: 28,
              color: _teal,
            ),
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
                      fontFamily: 'HenkenGrotesk',
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                      hintText: widget.initialLocation,
                      hintStyle: const TextStyle(
                        color: Color(0xFF2A1B12),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'HenkenGrotesk',
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.subtitle,
                    style: const TextStyle(
                      color: Color(0xFF8A7B6E),
                      fontSize: 12,
                      fontFamily: 'HenkenGrotesk',
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: widget.onFilterTap,
              icon: const Icon(
                Icons.tune,
                size: 26,
                color: Color(0xFF2A1B12),
              ),
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