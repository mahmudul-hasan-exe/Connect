class ConnectionRequestModel {
  final String id;
  final String fromUserId;
  final String fromUserName;
  final String? fromUserAvatar;
  final int createdAt;

  ConnectionRequestModel({
    required this.id,
    required this.fromUserId,
    required this.fromUserName,
    this.fromUserAvatar,
    required this.createdAt,
  });

  factory ConnectionRequestModel.fromJson(Map<String, dynamic> json) {
    return ConnectionRequestModel(
      id: json['id'] as String,
      fromUserId: json['fromUserId'] as String,
      fromUserName: json['fromUserName'] as String? ?? 'User',
      fromUserAvatar: json['fromUserAvatar'] as String?,
      createdAt: json['createdAt'] is int
          ? json['createdAt'] as int
          : (json['createdAt'] as num?)?.toInt() ?? 0,
    );
  }
}
