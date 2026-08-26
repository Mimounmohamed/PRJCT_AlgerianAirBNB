import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
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
  final FocusNode _focusNode = FocusNode();
  final GlobalKey _addButtonKey = GlobalKey();

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
    _focusNode.dispose();
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

  Future<void> _pickMedia() async {
    // Find + button position to anchor the popup above it
    final renderBox = _addButtonKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !mounted) return;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    final choice = await showMenu<String>(
      context: context,
      color: Colors.white,
      elevation: 12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy - 130, // above the button
        offset.dx + size.width,
        offset.dy,
      ),
      items: [
        PopupMenuItem<String>(
          value: 'image',
          child: Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: const BoxDecoration(color: _C.inputFill, shape: BoxShape.circle),
                child: const Icon(Icons.image_outlined, color: _C.teal, size: 20),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Photo', style: TextStyle(fontFamily: 'HankenGrotesk', fontWeight: FontWeight.w600, color: _C.darkText, fontSize: 14)),
                  Text('From gallery', style: TextStyle(fontFamily: 'HankenGrotesk', fontSize: 11, color: _C.mutedText)),
                ],
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'video',
          child: Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: const BoxDecoration(color: _C.inputFill, shape: BoxShape.circle),
                child: const Icon(Icons.videocam_outlined, color: _C.teal, size: 20),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Video', style: TextStyle(fontFamily: 'HankenGrotesk', fontWeight: FontWeight.w600, color: _C.darkText, fontSize: 14)),
                  Text('Max 1 minute', style: TextStyle(fontFamily: 'HankenGrotesk', fontSize: 11, color: _C.mutedText)),
                ],
              ),
            ],
          ),
        ),
      ],
    );

    if (choice == null || !mounted) return;

    final picker = ImagePicker();

    if (choice == 'image') {
      final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (picked == null || !mounted) return;
      await _uploadAndSendImage(File(picked.path));
    } else {
      // Video source sub-popup
      final renderBox2 = _addButtonKey.currentContext?.findRenderObject() as RenderBox?;
      RelativeRect pos = RelativeRect.fromLTRB(offset.dx, offset.dy - 120, offset.dx + size.width, offset.dy);
      if (renderBox2 != null) {
        final o2 = renderBox2.localToGlobal(Offset.zero);
        pos = RelativeRect.fromLTRB(o2.dx, o2.dy - 120, o2.dx + size.width, o2.dy);
      }

      final src = await showMenu<ImageSource>(
        context: context,
        color: Colors.white,
        elevation: 12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        position: pos,
        items: [
          PopupMenuItem<ImageSource>(
            value: ImageSource.gallery,
            child: Row(children: [
              const Icon(Icons.photo_library_outlined, color: _C.teal),
              const SizedBox(width: 12),
              const Text('Gallery', style: TextStyle(fontFamily: 'HankenGrotesk', fontWeight: FontWeight.w600, color: _C.darkText)),
            ]),
          ),
          PopupMenuItem<ImageSource>(
            value: ImageSource.camera,
            child: Row(children: [
              const Icon(Icons.videocam_outlined, color: _C.teal),
              const SizedBox(width: 12),
              const Text('Record now', style: TextStyle(fontFamily: 'HankenGrotesk', fontWeight: FontWeight.w600, color: _C.darkText)),
            ]),
          ),
        ],
      );
      if (src == null || !mounted) return;

      final picked = await picker.pickVideo(source: src, maxDuration: const Duration(seconds: 60));
      if (picked == null || !mounted) return;

      final ctrl = VideoPlayerController.file(File(picked.path));
      await ctrl.initialize();
      final duration = ctrl.value.duration;
      await ctrl.dispose();

      if (duration.inSeconds > 60) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('⚠️ Video must be 1 minute or less'), backgroundColor: Colors.red),
        );
        return;
      }

      await _uploadAndSendVideo(File(picked.path));
    }
  }

  Future<void> _uploadAndSendImage(File file) async {
    _showUploadSnackbar('Uploading photo…');
    // Optimistic image bubble using local file
    final tempId = 'img_${DateTime.now().millisecondsSinceEpoch}';
    final optimistic = {
      '_id': tempId,
      'conversationId': widget.conversationId,
      'senderId': {'_id': _myId},
      'content': '📷 Photo',
      'messageType': 'image',
      'imageUrl': file.path, // local path for optimistic display
      'sentAt': DateTime.now().toIso8601String(),
      'read': false,
    };
    setState(() => _messages.add(optimistic));
    _scrollToBottom();
    try {
      final url = await AuthService.uploadToCloudinary(file);
      final sent = await AuthService.sendImageMessage(token: _token, conversationId: widget.conversationId, imageUrl: url);
      if (!mounted) return;
      setState(() {
        final idx = _messages.indexWhere((m) => m['_id'] == tempId);
        if (idx != -1) _messages[idx] = sent;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _messages.removeWhere((m) => m['_id'] == tempId));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) ScaffoldMessenger.of(context).hideCurrentSnackBar();
    }
  }

  Future<void> _uploadAndSendVideo(File file) async {
    _showUploadSnackbar('Uploading video…');
    final tempId = 'vid_${DateTime.now().millisecondsSinceEpoch}';
    final optimistic = {
      '_id': tempId,
      'conversationId': widget.conversationId,
      'senderId': {'_id': _myId},
      'content': '🎥 Video',
      'messageType': 'video',
      'imageUrl': file.path, // local path for optimistic display
      'sentAt': DateTime.now().toIso8601String(),
      'read': false,
    };
    setState(() => _messages.add(optimistic));
    _scrollToBottom();
    try {
      final url = await AuthService.uploadVideoToCloudinary(file);
      final sent = await AuthService.sendVideoMessage(token: _token, conversationId: widget.conversationId, videoUrl: url);
      if (!mounted) return;
      setState(() {
        final idx = _messages.indexWhere((m) => m['_id'] == tempId);
        if (idx != -1) _messages[idx] = sent;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _messages.removeWhere((m) => m['_id'] == tempId));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) ScaffoldMessenger.of(context).hideCurrentSnackBar();
    }
  }

  void _showUploadSnackbar(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
        const SizedBox(width: 12),
        Text(msg, style: const TextStyle(fontFamily: 'HankenGrotesk')),
      ]),
      duration: const Duration(seconds: 30),
      backgroundColor: const Color(0xFF006972),
    ));
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
                Text(widget.otherUserName, style: const TextStyle(color: _C.darkText, fontSize: 17, fontFamily: 'HankenGrotesk', fontWeight: FontWeight.w600)),
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
                            final msgType = msg['messageType'] as String? ?? 'text';
                            final mediaUrl = msg['imageUrl'] as String?;
                            return Column(
                              children: [
                                if (i == 0) ...[const _DatePill(label: 'TODAY'), const SizedBox(height: 16)],
                                _ChatBubble(
                                  text: msg['content'] as String? ?? '',
                                  time: time,
                                  isMe: isMe,
                                  read: read,
                                  messageType: msgType,
                                  mediaUrl: mediaUrl,
                                ),
                                const SizedBox(height: 12),
                              ],
                            );
                          },
            ),
          ),
          _MessageInputBar(
            controller: _controller,
            focusNode: _focusNode,
            onSend: _send,
            sending: _sending,
            onPickMedia: _pickMedia,
            addButtonKey: _addButtonKey,
          ),
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
  final String messageType;
  final String? mediaUrl;

  const _ChatBubble({
    required this.text,
    required this.time,
    required this.isMe,
    this.read = false,
    this.messageType = 'text',
    this.mediaUrl,
  });

  @override
  Widget build(BuildContext context) {
    final radius = isMe
        ? const BorderRadius.only(
            topLeft: Radius.circular(18), topRight: Radius.circular(18),
            bottomLeft: Radius.circular(18), bottomRight: Radius.circular(4),
          )
        : const BorderRadius.all(Radius.circular(18));

    final shadow = isMe
        ? null
        : [BoxShadow(color: const Color(0xFF3A271D).withValues(alpha: 0.07), blurRadius: 12, offset: const Offset(0, 3))];

    Widget content;

    if (messageType == 'image' && mediaUrl != null) {
      final isLocal = !mediaUrl!.startsWith('http');
      content = ClipRRect(
        borderRadius: radius,
        child: isLocal
            ? Image.file(
                File(mediaUrl!),
                width: MediaQuery.of(context).size.width * 0.65,
                fit: BoxFit.cover,
              )
            : Image.network(
                mediaUrl!,
                width: MediaQuery.of(context).size.width * 0.65,
                fit: BoxFit.cover,
                loadingBuilder: (_, child, progress) => progress == null
                    ? child
                    : Container(
                        width: MediaQuery.of(context).size.width * 0.65,
                        height: 180,
                        color: _C.border,
                        child: const Center(child: CircularProgressIndicator(color: _C.teal, strokeWidth: 2)),
                      ),
                errorBuilder: (_, __, ___) => Container(
                  width: MediaQuery.of(context).size.width * 0.65,
                  height: 100,
                  decoration: BoxDecoration(color: _C.border, borderRadius: radius),
                  child: const Icon(Icons.broken_image_outlined, color: _C.mutedText),
                ),
              ),
      );
    } else if (messageType == 'video' && mediaUrl != null) {
      content = _VideoThumbnail(url: mediaUrl!, borderRadius: radius);
    } else {
      content = Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: isMe ? _C.teal : Colors.white, borderRadius: radius, boxShadow: shadow),
        child: Text(text, style: TextStyle(color: isMe ? Colors.white : _C.darkText, fontSize: 15, fontFamily: 'HankenGrotesk', height: 1.45)),
      );
    }

    final ts = Padding(
      padding: const EdgeInsets.only(top: 5, left: 2, right: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(time, style: const TextStyle(color: Color(0xFF4F4540), fontSize: 10, fontFamily: 'HankenGrotesk', fontWeight: FontWeight.w400, height: 1.5)),
          if (isMe && read) ...[const SizedBox(width: 4), const Icon(Icons.done_all, size: 13, color: _C.teal)],
        ],
      ),
    );

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [content, ts],
      ),
    );
  }
}

class _VideoThumbnail extends StatefulWidget {
  final String url;
  final BorderRadius borderRadius;
  const _VideoThumbnail({required this.url, required this.borderRadius});

  @override
  State<_VideoThumbnail> createState() => _VideoThumbnailState();
}

class _VideoThumbnailState extends State<_VideoThumbnail> {
  late VideoPlayerController _ctrl;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    final isLocal = !widget.url.startsWith('http');
    _ctrl = isLocal
        ? VideoPlayerController.file(File(widget.url))
        : VideoPlayerController.networkUrl(Uri.parse(widget.url));
    _ctrl.initialize().then((_) {
      if (mounted) setState(() => _ready = true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _openFullscreen() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => _FullscreenVideo(url: widget.url),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width * 0.65;
    return GestureDetector(
      onTap: _openFullscreen,
      child: ClipRRect(
        borderRadius: widget.borderRadius,
        child: Stack(
          alignment: Alignment.center,
          children: [
            _ready
                ? SizedBox(
                    width: w,
                    height: w * 9 / 16,
                    child: FittedBox(fit: BoxFit.cover, child: SizedBox(width: _ctrl.value.size.width, height: _ctrl.value.size.height, child: VideoPlayer(_ctrl))),
                  )
                : Container(width: w, height: w * 9 / 16, color: const Color(0xFF2A2A2A)),
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.55), shape: BoxShape.circle),
              child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 30),
            ),
            if (_ready)
              Positioned(
                bottom: 6, right: 8,
                child: Text(
                  _formatDur(_ctrl.value.duration),
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontFamily: 'HankenGrotesk', fontWeight: FontWeight.w600, shadows: [Shadow(blurRadius: 4)]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDur(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

class _FullscreenVideo extends StatefulWidget {
  final String url;
  const _FullscreenVideo({required this.url});

  @override
  State<_FullscreenVideo> createState() => _FullscreenVideoState();
}

class _FullscreenVideoState extends State<_FullscreenVideo> {
  late VideoPlayerController _ctrl;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _ctrl = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        if (mounted) {
          setState(() => _ready = true);
          _ctrl.play();
        }
      });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, foregroundColor: Colors.white, elevation: 0),
      body: Center(
        child: _ready
            ? AspectRatio(aspectRatio: _ctrl.value.aspectRatio, child: VideoPlayer(_ctrl))
            : const CircularProgressIndicator(color: Colors.white),
      ),
      floatingActionButton: _ready
          ? FloatingActionButton(
              backgroundColor: _C.teal,
              onPressed: () => setState(() => _ctrl.value.isPlaying ? _ctrl.pause() : _ctrl.play()),
              child: Icon(_ctrl.value.isPlaying ? Icons.pause : Icons.play_arrow),
            )
          : null,
    );
  }
}


class _MessageInputBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSend;
  final bool sending;
  final VoidCallback onPickMedia;
  final GlobalKey addButtonKey;

  const _MessageInputBar({
    required this.controller,
    required this.focusNode,
    required this.onSend,
    required this.sending,
    required this.onPickMedia,
    required this.addButtonKey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            GestureDetector(
              onTap: onPickMedia,
              child: Container(
                key: addButtonKey,
                width: 44, height: 44,
                decoration: const BoxDecoration(color: _C.inputFill, shape: BoxShape.circle),
                child: const Icon(Icons.add, color: _C.darkText, size: 22),
              ),
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
                        focusNode: focusNode,
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
