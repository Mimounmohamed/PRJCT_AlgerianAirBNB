import 'package:flutter/material.dart';

/// Host row shown on the Listing Detail page — avatar, name,
/// "Superhost since <year>" (or fallback label), and a message button.
class HostSection extends StatelessWidget {
  final String hostName;
  final String? hostProfilePhotoUrl;
  final String? hostSinceLabel;
  final VoidCallback? onMessageTap;

  const HostSection({
    super.key,
    required this.hostName,
    required this.hostProfilePhotoUrl,
    required this.hostSinceLabel,
    this.onMessageTap,
  });

  String get _initials {
    final parts = hostName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    final first = parts.first[0];
    final second = parts.length > 1 && parts[1].isNotEmpty ? parts[1][0] : '';
    return (first + second).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: const Color(0xFFE7DCCB),
          backgroundImage: hostProfilePhotoUrl != null ? NetworkImage(hostProfilePhotoUrl!) : null,
          child: hostProfilePhotoUrl == null
              ? Text(
                  _initials,
                  style: const TextStyle(
                    color: Color(0xFF2A1B12),
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                )
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hosted by $hostName',
                style: const TextStyle(
                  color: Color(0xFF2A1B12),
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'HenkenGrotesk',
                ),
              ),
              if (hostSinceLabel != null) ...[
                const SizedBox(height: 2),
                Text(
                  hostSinceLabel!,
                  style: const TextStyle(
                    color: Color(0xFF8A7B6E),
                    fontSize: 13,
                    fontFamily: 'HenkenGrotesk',
                  ),
                ),
              ],
            ],
          ),
        ),
        IconButton(
          onPressed: onMessageTap,
          icon: const Icon(Icons.chat_bubble_outline, size: 28, color: Color(0xFF2A1B12)),
          splashRadius: 20,
        ),
      ],
    );
  }
}