import 'package:flutter/material.dart';

/// Colors sampled directly (pixel-picked) from the reference design —
/// kept consistent with the Notifications / Privacy & Security screens.
class _C {
  static const pageBg = Color(0xFFFFF9EE);
  static const cardBg = Color(0xFFFFFCF6);
  static const border = Color(0xFFEFE6D6);
  static const teal = Color(0xFF006972);
  static const darkText = Color(0xFF23130A);
  static const mutedText = Color(0xFF9B8C7E);
  static const incomingBubble = Color(0xFFEFE6D6);
  static const timestamp = Color(0xFFA79D91);
  static const pillBg = Color(0xFFF3EDE2);
  static const pillText = Color(0xFF6F675A);
  static const goldRing = Color(0xFF7D650F);
  static const onlineGreen = Color(0xFF2E7D5B);
  static const inputFill = Color(0xFFFBF7EF);
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
            _AvatarWithBadge(),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Sidi Ahmed',
                  style: TextStyle(
                    color: _C.darkText,
                    fontSize: 17,
                    fontFamily: 'HankenGrotesk',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: _C.onlineGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'Active now',
                      style: TextStyle(
                        color: _C.mutedText,
                        fontSize: 12.5,
                        fontFamily: 'HankenGrotesk',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: _C.darkText),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: _RegardingStayCard(),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                const _DatePill(label: 'TODAY'),
                const SizedBox(height: 16),
                const _ChatBubble(
                  text: 'Marhaban! We look forward to your stay.',
                  time: '10:04 AM',
                  isMe: false,
                ),
                const SizedBox(height: 14),
                const _ChatBubble(
                  text: 'Thank you! What time is check-in?',
                  time: '10:15 AM',
                  isMe: true,
                  read: true,
                ),
                const SizedBox(height: 14),
                const _ChatBubble(
                  text: 'Check-in is at 2 PM. See you soon!',
                  time: '10:16 AM',
                  isMe: false,
                ),
              ],
            ),
          ),
          _MessageInputBar(controller: _controller),
        ],
      ),
    );
  }
}

class _AvatarWithBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 40,
            height: 40,
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: _C.goldRing,
            ),
            // Placeholder avatar circle — swap the child for a real
            // CircleAvatar(backgroundImage: NetworkImage(...)/AssetImage(...))
            child: const CircleAvatar(
              backgroundColor: _C.border,
              child: Icon(Icons.person, color: _C.mutedText, size: 20),
            ),
          ),
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: _C.goldRing, width: 1.5),
              ),
              child: const Icon(Icons.check, color: _C.goldRing, size: 11),
            ),
          ),
        ],
      ),
    );
  }
}

class _RegardingStayCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.border),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(58, 39, 29, 0.04),
            offset: Offset(0, 4),
            blurRadius: 20,
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Placeholder thumbnail — swap for Image.network/Image.asset
          // of the actual property photo.
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 56,
              height: 56,
              color: const Color(0xFF5C4A38),
              child: const Icon(Icons.home_outlined,
                  color: Colors.white54, size: 24),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'REGARDING STAY',
                  style: TextStyle(
                    color: _C.teal,
                    fontSize: 11.5,
                    fontFamily: 'HankenGrotesk',
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Dar El-Bahia',
                  style: TextStyle(
                    color: _C.darkText,
                    fontSize: 18,
                    fontFamily: 'HankenGrotesk',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Oct 12 — Oct 15',
                  style: TextStyle(
                    color: _C.mutedText,
                    fontSize: 13,
                    fontFamily: 'HankenGrotesk',
                  ),
                ),
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
        decoration: BoxDecoration(
          color: _C.pillBg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: _C.pillText,
            fontSize: 11,
            fontFamily: 'HankenGrotesk',
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final String text;
  final String time;
  final bool isMe;
  final bool read;

  const _ChatBubble({
    required this.text,
    required this.time,
    required this.isMe,
    this.read = false,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(18),
      bottomLeft: Radius.circular(isMe ? 18 : 4),
      bottomRight: Radius.circular(isMe ? 4 : 18),
    );

    final bubble = Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isMe ? _C.teal : _C.incomingBubble,
        borderRadius: radius,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isMe ? Colors.white : _C.darkText,
          fontSize: 14.5,
          fontFamily: 'HankenGrotesk',
          height: 1.4,
        ),
      ),
    );

    final timestampRow = Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // NOTE: the reference uses a monospaced digit style for
          // timestamps — swap 'monospace' for a mono font you've
          // registered (e.g. 'RobotoMono') if you have one bundled.
          Text(
            time,
            style: const TextStyle(
              color: _C.timestamp,
              fontSize: 11.5,
              fontFamily: 'monospace',
            ),
          ),
          if (isMe && read) ...[
            const SizedBox(width: 4),
            const Icon(Icons.done_all, size: 14, color: _C.teal),
          ],
        ],
      ),
    );

    return Column(
      crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [bubble, timestampRow],
    );
  }
}

class _MessageInputBar extends StatelessWidget {
  final TextEditingController controller;
  const _MessageInputBar({required this.controller});

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
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: _C.inputFill,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: _C.darkText, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: _C.inputFill,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        style: const TextStyle(
                          color: _C.darkText,
                          fontSize: 14,
                          fontFamily: 'HankenGrotesk',
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(
                            color: _C.mutedText,
                            fontFamily: 'HankenGrotesk',
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const Icon(Icons.emoji_emotions_outlined,
                        color: _C.mutedText, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: _C.teal,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send, color: Colors.white, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}