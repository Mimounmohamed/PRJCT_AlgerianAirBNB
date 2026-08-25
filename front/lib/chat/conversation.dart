import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/user_session.dart';
import '../services/socket_service.dart';

class _C {
  static const pageBg = Color(0xFFFBF7EF);
  static const cardBg = Color(0xFFFFFCF6);
  static const border = Color(0xFFEFE6D6);
  static const teal = Color(0xFF006972);
  static const darkText = Color(0xFF23130A);
  static const mutedText = Color(0xFF9B8C7E);

  static const timestamp = Color(0xFFA79D91);
  static const pillBg = Color(0xFFF3EDE2);
  static const pillText = Color(0xFF6F675A);
  static const goldRing = Color(0xFF7D650F);
  static const onlineGreen = Color(0xFF2E7D5B);
  static const inputFill = Color(0xFFFBF7EF);
}

class ChatScreen extends StatefulWidget {
  final String conversationId;
  final String otherUserName;
  final String otherUserInitials;
  final String? listingName;
  final String? listingLocation;

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.otherUserName,
    required this.otherUserInitials,
    this.listingName,
    this.listingLocation,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  List<Map<String, dynamic>> _messages = [];
  bool _loading = true;
  bool _sending = false;

  String get _myId => UserSession.instance.currentUser?.id ?? '';
  String get _token => UserSession.instance.token ?? '';

  @override
  void initState() {
    super.initState();
    _loadMessages();
    SocketService.instance.joinConversation(widget.conversationId);
    SocketService.instance.onNewMessage(_onIncoming);
  }

  @override
  void dispose() {
    SocketService.instance.leaveConversation(widget.conversationId);
    SocketService.instance.offNewMessage();
    _controller.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    try {
      final data = await AuthService.getMessages(
        token: _token,
        conversationId: widget.conversationId,
      );
      if (!mounted) return;
      setState(() {
        _messages = data.cast<Map<String, dynamic>>();
        _loading = false;
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _onIncoming(Map<String, dynamic> msg) {
    if (msg['conversationId']?.toString() != widget.conversationId) return;
    setState(() => _messages.add(msg));
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;

    _controller.clear();
    setState(() => _sending = true);

    final optimistic = {
      '_id': 'sending_${DateTime.now().millisecondsSinceEpoch}',
      'conversationId': widget.conversationId,
      'senderId': {'_id': _myId},
      'content': text,
      'messageType': 'text',
      'sentAt': DateTime.now().toIso8601String(),
      'read': false,
    };
    setState(() => _messages.add(optimistic));
    _scrollToBottom();

    try {
      final sent = await AuthService.sendMessage(
        token: _token,
        conversationId: widget.conversationId,
        content: text,
      );
      if (!mounted) return;
      setState(() {
        final idx = _messages.indexWhere((m) => m['_id'] == optimistic['_id']);
        if (idx != -1) _messages[idx] = sent;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _messages.removeWhere((m) => m['_id'] == optimistic['_id']));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send message'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  String _formatTime(String? iso) {
    if (iso == null) return '';
    final dt = DateTime.tryParse(iso)?.toLocal();
    if (dt == null) return '';
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.pageBg,
      appBar: AppBar(
        backgroundColor: _C.pageBg,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _C.darkText),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            _AvatarWithBadge(initials: widget.otherUserInitials),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.otherUserName,
                  style: const TextStyle(color: _C.darkText, fontSize: 17, fontFamily: 'HankenGrotesk', fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Container(width: 7, height: 7, decoration: const BoxDecoration(color: _C.onlineGreen, shape: BoxShape.circle)),
                    const SizedBox(width: 5),
                    const Text('Active now', style: TextStyle(color: _C.mutedText, fontSize: 12.5, fontFamily: 'HankenGrotesk', fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert, color: _C.darkText), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          if (widget.listingName != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: _RegardingStayCard(listingName: widget.listingName!, listingLocation: widget.listingLocation),
            ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: _C.teal))
                : _messages.isEmpty
                    ? const Center(child: Text('No messages yet. Say hello! 👋', style: TextStyle(color: _C.mutedText, fontFamily: 'HankenGrotesk')))
                    : ListView.builder(
                        controller: _scrollCtrl,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        itemCount: _messages.length,
                        itemBuilder: (context, i) {
                          final msg = _messages[i];
                          final senderId = (msg['senderId'] is Map)
                              ? msg['senderId']['_id']?.toString()
                              : msg['senderId']?.toString();
                          final isMe = senderId == _myId;
                          final time = _formatTime(msg['sentAt'] as String?);
                          final read = msg['read'] as bool? ?? false;
                          return Column(
                            children: [
                              if (i == 0) ...[const _DatePill(label: 'TODAY'), const SizedBox(height: 16)],
                              _ChatBubble(text: msg['content'] as String? ?? '', time: time, isMe: isMe, read: read),
                              const SizedBox(height: 12),
                            ],
                          );
                        },
                      ),
          ),
          _MessageInputBar(controller: _controller, onSend: _send, sending: _sending),
        ],
      ),
    );
  }
}

class _AvatarWithBadge extends StatelessWidget {
  final String initials;
  const _AvatarWithBadge({required this.initials});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44, height: 44,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 40, height: 40,
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(shape: BoxShape.circle, color: _C.goldRing),
            child: CircleAvatar(
              backgroundColor: _C.border,
              child: Text(initials, style: const TextStyle(color: _C.darkText, fontSize: 14, fontFamily: 'HankenGrotesk', fontWeight: FontWeight.w700)),
            ),
          ),
          Positioned(
            right: -2, bottom: -2,
            child: Container(
              width: 18, height: 18,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, border: Border.all(color: _C.goldRing, width: 1.5)),
              child: const Icon(Icons.check, color: _C.goldRing, size: 11),
            ),
          ),
        ],
      ),
    );
  }
}

class _RegardingStayCard extends StatelessWidget {
  final String listingName;
  final String? listingLocation;
  const _RegardingStayCard({required this.listingName, this.listingLocation});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.border),
        boxShadow: const [BoxShadow(color: Color.fromRGBO(58, 39, 29, 0.04), offset: Offset(0, 4), blurRadius: 20)],
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(width: 56, height: 56, color: const Color(0xFF5C4A38), child: const Icon(Icons.home_outlined, color: Colors.white54, size: 24)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('REGARDING STAY', style: TextStyle(color: _C.teal, fontSize: 11.5, fontFamily: 'HankenGrotesk', fontWeight: FontWeight.w700, letterSpacing: 1)),
                const SizedBox(height: 4),
                Text(listingName, style: const TextStyle(color: _C.darkText, fontSize: 18, fontFamily: 'HankenGrotesk', fontWeight: FontWeight.w700)),
                if (listingLocation != null) ...[
                  const SizedBox(height: 4),
                  Text(listingLocation!, style: const TextStyle(color: _C.mutedText, fontSize: 13, fontFamily: 'HankenGrotesk')),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DatePill extends StatelessWidget {
  final String label;
  const _DatePill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(color: _C.pillBg, borderRadius: BorderRadius.circular(20)),
        child: Text(label, style: const TextStyle(color: _C.pillText, fontSize: 11, fontFamily: 'HankenGrotesk', fontWeight: FontWeight.w700, letterSpacing: 1)),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final String text;
  final String time;
  final bool isMe;
  final bool read;

  const _ChatBubble({required this.text, required this.time, required this.isMe, this.read = false});

  @override
  Widget build(BuildContext context) {
    // Incoming: all corners 18px (fully rounded card look)
    // Outgoing: all 18px except bottom-right is 4px (tail effect)
    final radius = isMe
        ? const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(4),
          )
        : const BorderRadius.all(Radius.circular(18));

    final bubble = Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isMe ? _C.teal : Colors.white,
        borderRadius: radius,
        boxShadow: isMe
            ? null
            : [
                BoxShadow(
                  color: const Color(0xFF3A271D).withValues(alpha: 0.07),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isMe ? Colors.white : _C.darkText,
          fontSize: 15,
          fontFamily: 'HankenGrotesk',
          height: 1.45,
        ),
      ),
    );

    // Timestamp sits BELOW the bubble, outside it
    final ts = Padding(
      padding: const EdgeInsets.only(top: 5, left: 2, right: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            time,
            style: const TextStyle(
              color: Color(0xFF4F4540),
              fontSize: 10,
              fontFamily: 'HankenGrotesk',
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
          if (isMe && read) ...[
            const SizedBox(width: 4),
            const Icon(Icons.done_all, size: 13, color: _C.teal),
          ],
        ],
      ),
    );

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [bubble, ts],
      ),
    );
  }
}

class _MessageInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool sending;
  const _MessageInputBar({required this.controller, required this.onSend, required this.sending});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: const BoxDecoration(color: _C.inputFill, shape: BoxShape.circle),
              child: const Icon(Icons.add, color: _C.darkText, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(color: _C.inputFill, borderRadius: BorderRadius.circular(24)),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => onSend(),
                        style: const TextStyle(color: _C.darkText, fontSize: 14, fontFamily: 'HankenGrotesk'),
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(color: _C.mutedText, fontFamily: 'HankenGrotesk'),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const Icon(Icons.emoji_emotions_outlined, color: _C.mutedText, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: sending ? null : onSend,
              child: Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: sending ? _C.teal.withValues(alpha: 0.5) : _C.teal,
                  shape: BoxShape.circle,
                ),
                child: sending
                    ? const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.send, color: Colors.white, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
