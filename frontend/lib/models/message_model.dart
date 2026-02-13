class MessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String text;
  final int createdAt;
  final String status;

  MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.text,
    required this.createdAt,
    this.status = 'sent',
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      chatId: json['chatId'] as String,
      senderId: json['senderId'] as String,
      text: json['text'] as String,
      createdAt: json['createdAt'] is int ? json['createdAt'] as int : 0,
      status: json['status'] as String? ?? 'sent',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'chatId': chatId,
        'senderId': senderId,
        'text': text,
        'createdAt': createdAt,
        'status': status,
      };
}
