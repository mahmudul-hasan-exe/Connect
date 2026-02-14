class UserModel {
  final String id;
  final String name;
  final String? avatar;
  final bool online;
  final int? lastSeen;
  final String? connectionStatus;

  UserModel({
    required this.id,
    required this.name,
    this.avatar,
    this.online = false,
    this.lastSeen,
    this.connectionStatus,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String;
    final online = json['online'] as bool? ?? false;
    return UserModel(
      id: id,
      name: json['name'] as String? ?? 'User',
      avatar: json['avatar'] as String?,
      online: online,
      lastSeen: json['lastSeen'] is int
          ? json['lastSeen'] as int
          : (json['lastSeen'] as num?)?.toInt(),
      connectionStatus: json['connectionStatus'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'avatar': avatar,
        'online': online,
        'lastSeen': lastSeen,
        'connectionStatus': connectionStatus,
      };

  UserModel copyWith({
    String? id,
    String? name,
    String? avatar,
    bool? online,
    int? lastSeen,
    String? connectionStatus,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      online: online ?? this.online,
      lastSeen: lastSeen ?? this.lastSeen,
      connectionStatus: connectionStatus ?? this.connectionStatus,
    );
  }

  bool get isConnected => connectionStatus == 'connected';
}
