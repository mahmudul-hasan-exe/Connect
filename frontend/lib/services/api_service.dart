import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000';

  String? token;

  ApiService([this.token]);

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': token!,
      };

  Future<Map<String, dynamic>> auth({required String name, String? avatar}) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/auth'),
      headers: _headers,
      body: jsonEncode({'name': name, 'avatar': avatar}),
    );
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return data;
  }

  Future<List<UserModel>> getUsers() async {
    final res = await http.get(Uri.parse('$baseUrl/api/users'), headers: _headers);
    final list = jsonDecode(res.body) as List;
    return list.map((e) => UserModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<UserModel>> getUsersWithStatus(String userId) async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/connection-requests/users-with-status/$userId'),
      headers: _headers,
    );
    final list = jsonDecode(res.body) as List;
    return list.map((e) => UserModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> sendConnectionRequest(String fromUserId, String toUserId) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/connection-requests'),
      headers: _headers,
      body: jsonEncode({'fromUserId': fromUserId, 'toUserId': toUserId}),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      final err = jsonDecode(res.body) as Map<String, dynamic>?;
      throw Exception(err?['error'] as String? ?? 'Failed to send request');
    }
  }

  Future<List<ConnectionRequestModel>> getReceivedRequests(String userId) async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/connection-requests/received/$userId'),
      headers: _headers,
    );
    final list = jsonDecode(res.body) as List;
    return list
        .map((e) => ConnectionRequestModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> acceptConnectionRequest(String requestId) async {
    final res = await http.patch(
      Uri.parse('$baseUrl/api/connection-requests/$requestId/accept'),
      headers: _headers,
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Failed to accept');
    }
  }

  Future<List<ChatModel>> getChats(String userId) async {
    final res = await http.get(Uri.parse('$baseUrl/api/chats/$userId'), headers: _headers);
    final list = jsonDecode(res.body) as List;
    return list.map((e) => ChatModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Map<String, dynamic>> getMessages(String chatId, {String? userId}) async {
    var url = '$baseUrl/api/messages/$chatId';
    if (userId != null && userId.isNotEmpty) url += '?userId=$userId';
    final res = await http.get(Uri.parse(url), headers: _headers);
    final data = jsonDecode(res.body);
    if (data is Map<String, dynamic>) {
      final list = data['messages'] as List? ?? [];
      return {
        'messages': list.map((e) => MessageModel.fromJson(e as Map<String, dynamic>)).toList(),
        'blockedByThem': data['blockedByThem'] as bool? ?? false,
        'iBlockedThem': data['iBlockedThem'] as bool? ?? false,
      };
    }
    final list = data as List;
    return {
      'messages': list.map((e) => MessageModel.fromJson(e as Map<String, dynamic>)).toList(),
      'blockedByThem': false,
      'iBlockedThem': false,
    };
  }

  Future<void> blockUser(String blockerId, String blockedId) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/blocks'),
      headers: _headers,
      body: jsonEncode({'blockerId': blockerId, 'blockedId': blockedId}),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) throw Exception('Failed to block');
  }

  Future<void> unblockUser(String blockerId, String blockedId) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/api/blocks'),
      headers: _headers,
      body: jsonEncode({'blockerId': blockerId, 'blockedId': blockedId}),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) throw Exception('Failed to unblock');
  }

  Future<ChatModel?> createChat(String userId, List<String> participantIds) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/chats'),
      headers: _headers,
      body: jsonEncode({'userId': userId, 'participantIds': participantIds}),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) return null;
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return ChatModel.fromJson(data);
  }
}
