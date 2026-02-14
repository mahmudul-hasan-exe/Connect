import 'message_model.dart';
import 'user_model.dart';

class ChatModel {
  final String id;
  final List<String> participants;
  final UserModel? otherUser;
  final MessageModel? lastMessage;
  final int createdAt;
  final int unread;
  final bool blockedByThem;
  final bool iBlockedThem;

  ChatModel({
    required this.id,
    required this.participants,
    this.otherUser,
    this.lastMessage,
    required this.createdAt,
    this.unread = 0,
    this.blockedByThem = false,
    this.iBlockedThem = false,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'] as String,
      participants: List<String>.from(json['participants'] as List? ?? []),
      otherUser: json['otherUser'] != null
          ? UserModel.fromJson(json['otherUser'] as Map<String, dynamic>)
          : null,
      lastMessage: json['lastMessage'] != null
          ? MessageModel.fromJson(json['lastMessage'] as Map<String, dynamic>)
          : null,
      createdAt: json['createdAt'] is int ? json['createdAt'] as int : 0,
      unread: json['unread'] as int? ?? 0,
      blockedByThem: json['blockedByThem'] as bool? ?? false,
      iBlockedThem: json['iBlockedThem'] as bool? ?? false,
    );
  }
}
