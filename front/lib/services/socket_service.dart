import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'user_session.dart';

/// Singleton Socket.io client.
/// Call [connect] once after login, [disconnect] on logout.
class SocketService {
  SocketService._();
  static final SocketService instance = SocketService._();

  IO.Socket? _socket;
  IO.Socket? get socket => _socket;
  bool get isConnected => _socket?.connected ?? false;

  static const _baseUrl =
      'https://krili-backend-api-f4aahwhndfd6bpb0.francecentral-01.azurewebsites.net';

  void connect() {
    final token = UserSession.instance.token;
    if (token == null) return;

    _socket = IO.io(
      _baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .disableAutoConnect()
          .build(),
    );

    _socket!.connect();

    _socket!.onConnect((_) => print('[Socket] Connected'));
    _socket!.onDisconnect((_) => print('[Socket] Disconnected'));
    _socket!.onConnectError((e) => print('[Socket] Error: $e'));
  }

  /// Join a conversation room to receive live messages.
  void joinConversation(String conversationId) {
    _socket?.emit('join_conversation', conversationId);
  }

  /// Leave a conversation room.
  void leaveConversation(String conversationId) {
    _socket?.emit('leave_conversation', conversationId);
  }

  /// Listen for new messages in the current conversation.
  void onNewMessage(void Function(Map<String, dynamic>) handler) {
    _socket?.on('new_message', (data) {
      if (data is Map<String, dynamic>) handler(data);
    });
  }

  /// Listen for inbox updates (badge counts, last message preview).
  void onConversationUpdated(void Function(Map<String, dynamic>) handler) {
    _socket?.on('conversation_updated', (data) {
      if (data is Map<String, dynamic>) handler(data);
    });
  }

  void offNewMessage() => _socket?.off('new_message');
  void offConversationUpdated() => _socket?.off('conversation_updated');

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }
}
