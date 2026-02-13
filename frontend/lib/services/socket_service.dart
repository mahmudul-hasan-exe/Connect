import 'package:socket_io_client/socket_io_client.dart' as io;
import '../models/message_model.dart';

class SocketService {
  io.Socket? _socket;
  String? _userId;

  void connect(String serverUrl, String userId) {
    _userId = userId;
    _socket = io.io(serverUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });
    _socket!.connect();
    _socket!.emit('auth', userId);
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _userId = null;
  }

  void sendMessage(String chatId, String text) {
    _socket?.emit('send_message', {
      'chatId': chatId,
      'senderId': _userId,
      'text': text,
    });
  }

  void setOnMessage(void Function(MessageModel) callback) {
    _socket?.off('message');
    _socket?.on('message', (data) {
      if (data is Map<String, dynamic>) {
        callback(MessageModel.fromJson(data));
      }
    });
  }

  void setOnMessageStatus(void Function(String messageId, String status) callback) {
    _socket?.off('message_status');
    _socket?.on('message_status', (data) {
      if (data is Map<String, dynamic>) {
        final messageId = data['messageId'] as String?;
        final messageIds = data['messageIds'] as List<dynamic>?;
        final status = data['status'] as String? ?? 'sent';
        if (messageId != null) {
          callback(messageId, status);
        } else if (messageIds != null) {
          for (final id in messageIds) {
            callback(id.toString(), status);
          }
        }
      }
    });
  }

  void offMessageStatus() {
    _socket?.off('message_status');
  }

  void setOnTyping(void Function(String chatId, String userId, bool isTyping) callback) {
    _socket?.off('typing');
    _socket?.on('typing', (data) {
      if (data is Map<String, dynamic>) {
        callback(
          data['chatId'] as String? ?? '',
          data['userId'] as String? ?? '',
          data['isTyping'] as bool? ?? false,
        );
      }
    });
  }

  void offTyping() {
    _socket?.off('typing');
  }

  void setOnFriendRequest(void Function(Map<String, dynamic> request) callback) {
    _socket?.off('friend_request');
    _socket?.on('friend_request', (data) {
      if (data is Map<String, dynamic>) callback(data);
    });
  }

  void setOnFriendRequestAccepted(void Function(Map<String, dynamic> data) callback) {
    _socket?.off('friend_request_accepted');
    _socket?.on('friend_request_accepted', (data) {
      if (data is Map<String, dynamic>) callback(data);
    });
  }

  void setOnUserOnline(void Function(String userId, bool online, int? lastSeen) callback) {
    _socket?.off('user_online');
    _socket?.on('user_online', (data) {
      if (data is Map<String, dynamic>) {
        final lastSeenRaw = data['lastSeen'];
        final lastSeen = lastSeenRaw is int
            ? lastSeenRaw
            : (lastSeenRaw is num ? lastSeenRaw.toInt() : null);
        callback(
          data['userId'] as String? ?? '',
          data['online'] as bool? ?? false,
          lastSeen,
        );
      }
    });
  }

  void emitTyping(String chatId, bool isTyping) {
    _socket?.emit('typing', {'chatId': chatId, 'userId': _userId, 'isTyping': isTyping});
  }

  bool get isConnected => _socket?.connected ?? false;
}
