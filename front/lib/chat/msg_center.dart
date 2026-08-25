import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/user_session.dart';
import '../services/socket_service.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});
  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  List<Map<String, dynamic>> _conversations = [];
  bool _loading = true;
  String? _error;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadConversations();
    // Live badge updates when we receive a new message while on inbox
    SocketService.instance.onConversationUpdated(_onConversationUpdated);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    SocketService.instance.offConversationUpdated();
    super.dispose();
  }

  Future<void> _loadConversations() async {
    try {
      final token = UserSession.instance.token ?? '';
      final data = await AuthService.getConversations(token: token);
      if (!mounted) return;
      setState(() {
        _conversations = data.cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _loading = false;
      });
    }
  }

  void _onConversationUpdated(Map<String, dynamic> update) {
    final updatedId = update['conversationId']?.toString();
    setState(() {
      final idx = _conversations.indexWhere((c) => c['_id']?.toString() == updatedId);
      if (idx != -1) {
        _conversations[idx]['lastMessage'] = update['lastMessage'];
        _conversations[idx]['unreadCount'] = update['unreadCount'];
        // Re-sort by sentAt descending
        _conversations.sort((a, b) {
          final aT = DateTime.tryParse(a['lastMessage']?['sentAt'] ?? '') ?? DateTime(0);
          final bT = DateTime.tryParse(b['lastMessage']?['sentAt'] ?? '') ?? DateTime(0);
          return bT.compareTo(aT);
        });
      }
    });
  }

  List<Map<String, dynamic>> get _filtered {
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) return _conversations;
    return _conversations.where((c) {
      final other = _otherParticipant(c);
      final name = (other?['fullName'] ?? '').toString().toLowerCase();
      final last = (c['lastMessage']?['content'] ?? '').toString().toLowerCase();
      return name.contains(q) || last.contains(q);
    }).toList();
  }

  Map<String, dynamic>? _otherParticipant(Map<String, dynamic> conv) {
    final myId = UserSession.instance.currentUser?.id;
    final participants = conv['participants'] as List<dynamic>? ?? [];
    try {
      return participants
          .cast<Map<String, dynamic>>()
          .firstWhere((p) => p['_id']?.toString() != myId, orElse: () => participants.cast<Map<String, dynamic>>().first);
    } catch (_) {
      return null;
    }
  }

  int _unreadCount(Map<String, dynamic> conv) {
    final myId = UserSession.instance.currentUser?.id ?? '';
    final unread = conv['unreadCount'];
    if (unread == null) return 0;
    if (unread is Map) return (unread[myId] ?? 0) as int;
    return 0;
  }

  String _formatTime(String? isoString) {
    if (isoString == null) return '';
    final dt = DateTime.tryParse(isoString)?.toLocal();
    if (dt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays < 7) {
      const days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
      return days[dt.weekday - 1];
    } else {
      const months = ['JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC'];
      return '${months[dt.month - 1]} ${dt.day}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFFFF9EE),
      child: Column(
        children: [
          // ── Search bar ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFEFE8DC),
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(color: Color(0xFF2A1B12), fontSize: 14, fontFamily: 'HankenGrotesk'),
                decoration: const InputDecoration(
                  hintText: 'Search conversations',
                  hintStyle: TextStyle(color: Color(0xFF9B8C7E), fontSize: 14, fontFamily: 'HankenGrotesk'),
                  prefixIcon: Icon(Icons.search, color: Color(0xFF9B8C7E), size: 22),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                ),
              ),
            ),
          ),

          // ── Body ────────────────────────────────────────
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF006972)))
                : _error != null
                    ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red, fontFamily: 'HankenGrotesk')))
                    : _filtered.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.chat_bubble_outline, size: 56, color: Color(0xFFD3C3BD)),
                                SizedBox(height: 12),
                                Text('No conversations yet', style: TextStyle(color: Color(0xFF9B8C7E), fontFamily: 'HankenGrotesk', fontSize: 15)),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            color: const Color(0xFF006972),
                            onRefresh: _loadConversations,
                            child: ListView.builder(
                              itemCount: _filtered.length,
                              itemBuilder: (context, i) {
                                final conv = _filtered[i];
                                final other = _otherParticipant(conv);
                                final unread = _unreadCount(conv);
                                final hasUnread = unread > 0;
                                final lastMsg = conv['lastMessage'] as Map<String, dynamic>?;
                                final lastText = lastMsg?['content'] as String? ?? '';
                                final lastTime = _formatTime(lastMsg?['sentAt'] as String?);
                                final name = other?['fullName'] as String? ?? 'Unknown';
                                final initials = name.trim().split(' ').take(2).map((w) => w.isNotEmpty ? w[0].toUpperCase() : '').join();
                                final listing = conv['listingId'] as Map<String, dynamic>?;
                                final location = (listing?['location']?['city'] ?? listing?['title'] ?? '').toString().toUpperCase();

                                return _ConversationTile(
                                  conversationId: conv['_id']?.toString() ?? '',
                                  initials: initials,
                                  name: name,
                                  location: location,
                                  message: lastText,
                                  time: lastTime,
                                  hasUnread: hasUnread,
                                  unreadCount: unread,
                                  onTap: () {
                                    // TODO: push to chat thread screen
                                  },
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

// ── Single conversation row ──────────────────────────────────
class _ConversationTile extends StatelessWidget {
  final String conversationId;
  final String initials;
  final String name;
  final String location;
  final String message;
  final String time;
  final bool hasUnread;
  final int unreadCount;
  final VoidCallback onTap;

  const _ConversationTile({
    required this.conversationId,
    required this.initials,
    required this.name,
    required this.location,
    required this.message,
    required this.time,
    required this.hasUnread,
    required this.unreadCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: hasUnread ? const Color(0xFFFFFCF6) : Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: const Color(0xFF8B6E5A),
                        child: Text(initials, style: const TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'HankenGrotesk', fontWeight: FontWeight.w700)),
                      ),
                      if (hasUnread)
                        Positioned(
                          bottom: 1, right: 1,
                          child: Container(
                            width: 12, height: 12,
                            decoration: BoxDecoration(
                              color: const Color(0xFFB5451B),
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFFFFF9EE), width: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  // Text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(name, style: const TextStyle(color: Color(0xFF2A1B12), fontSize: 16, fontFamily: 'HankenGrotesk', fontWeight: FontWeight.w700)),
                            Text(time, style: TextStyle(color: hasUnread ? const Color(0xFFB5451B) : const Color(0xFF9B8C7E), fontSize: 13, fontFamily: 'HankenGrotesk', fontWeight: FontWeight.w500)),
                          ],
                        ),
                        if (location.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(location, style: const TextStyle(color: Color(0xFF006972), fontSize: 10, fontFamily: 'HankenGrotesk', fontWeight: FontWeight.w700, letterSpacing: 1.1)),
                        ],
                        const SizedBox(height: 5),
                        Text(message, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: const Color(0xFF4F4540), fontSize: 14, fontFamily: 'HankenGrotesk', fontWeight: hasUnread ? FontWeight.w500 : FontWeight.w400)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const Divider(height: 1, thickness: 0.6, color: Color(0x80D3C3BD), indent: 20, endIndent: 20),
      ],
    );
  }
}
