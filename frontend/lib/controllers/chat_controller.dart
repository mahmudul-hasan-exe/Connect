import 'package:flutter/foundation.dart';
import '../models/chat_model.dart';
import '../models/connection_request_model.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class ChatController with ChangeNotifier {
  final ApiService _api = ApiService();
  List<ChatModel> _chats = [];
  List<MessageModel> _messages = [];
  List<UserModel> _users = [];
  List<UserModel> _usersWithStatus = [];
  List<ConnectionRequestModel> _receivedRequests = [];
  String? _currentChatId;
  bool _loading = false;
  final Map<String, String?> _typingUserByChat = {};

  List<ChatModel> get chats => _chats;
  List<MessageModel> get messages => _messages;
  List<UserModel> get users => _users;
  List<UserModel> get usersWithStatus => _usersWithStatus;
  List<ConnectionRequestModel> get receivedRequests => _receivedRequests;
  String? get currentChatId => _currentChatId;
  bool get loading => _loading;
  int get totalUnreadCount => _chats.fold<int>(0, (s, c) => s + c.unread);
  int get pendingRequestsCount => _receivedRequests.length;

  void setTyping(String chatId, String userId, bool isTyping) {
    if (isTyping) {
      _typingUserByChat[chatId] = userId;
    } else {
      _typingUserByChat.remove(chatId);
    }
    notifyListeners();
  }

  bool isOtherTyping(String chatId, String? otherUserId) {
    return otherUserId != null && _typingUserByChat[chatId] == otherUserId;
  }

  void setToken(String? token) {
    _api.token = token;
  }

  Future<void> loadChats(String userId) async {
    _loading = true;
    notifyListeners();
    try {
      _chats = await _api.getChats(userId);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadUsers() async {
    try {
      _users = await _api.getUsers();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> loadMessages(String chatId, {String? userId}) async {
    _currentChatId = chatId;
    try {
      final result = await _api.getMessages(chatId, userId: userId);
      _messages = result['messages'] as List<MessageModel>;
      final blockedByThem = result['blockedByThem'] as bool? ?? false;
      final iBlockedThem = result['iBlockedThem'] as bool? ?? false;
      final idx = _chats.indexWhere((c) => c.id == chatId);
      if (idx >= 0 && userId != null) {
        final list = List<ChatModel>.from(_chats);
        final c = list[idx];
        list[idx] = ChatModel(
          id: c.id,
          participants: c.participants,
          otherUser: c.otherUser,
          lastMessage: c.lastMessage,
          createdAt: c.createdAt,
          unread: 0,
          blockedByThem: blockedByThem,
          iBlockedThem: iBlockedThem,
        );
        _chats = list;
      }
      notifyListeners();
    } catch (_) {}
  }

  void addMessage(MessageModel msg, {String? myUserId}) {
    if (msg.chatId == _currentChatId) {
      _messages.add(msg);
      notifyListeners();
    }
    final idx = _chats.indexWhere((c) => c.id == msg.chatId);
    if (idx >= 0) {
      final list = List<ChatModel>.from(_chats);
      final c = list[idx];
      final isFromMe = myUserId != null && msg.senderId == myUserId;
      final isOtherChat = msg.chatId != _currentChatId;
      final newUnread = (isOtherChat && !isFromMe) ? c.unread + 1 : c.unread;
      list[idx] = ChatModel(
        id: c.id,
        participants: c.participants,
        otherUser: c.otherUser,
        lastMessage: msg,
        createdAt: c.createdAt,
        unread: newUnread,
        blockedByThem: c.blockedByThem,
        iBlockedThem: c.iBlockedThem,
      );
      list.sort((a, b) => (b.lastMessage?.createdAt ?? b.createdAt)
          .compareTo(a.lastMessage?.createdAt ?? a.createdAt));
      _chats = list;
      notifyListeners();
    }
  }

  void addChat(ChatModel chat) {
    if (_chats.any((c) => c.id == chat.id)) return;
    _chats.insert(0, chat);
    notifyListeners();
  }

  Future<void> loadUsersWithStatus(String userId) async {
    try {
      _usersWithStatus = await _api.getUsersWithStatus(userId);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> loadReceivedRequests(String userId) async {
    try {
      _receivedRequests = await _api.getReceivedRequests(userId);
      notifyListeners();
    } catch (_) {}
  }

  Future<bool> sendConnectionRequest(String fromUserId, String toUserId) async {
    try {
      await _api.sendConnectionRequest(fromUserId, toUserId);
      await loadUsersWithStatus(fromUserId);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  void addReceivedRequest(ConnectionRequestModel request) {
    if (_receivedRequests.any((r) => r.id == request.id)) return;
    _receivedRequests = [request, ..._receivedRequests];
    notifyListeners();
  }

  Future<bool> acceptConnectionRequest(
      String requestId, String myUserId) async {
    try {
      await _api.acceptConnectionRequest(requestId);
      _receivedRequests =
          _receivedRequests.where((r) => r.id != requestId).toList();
      await loadUsersWithStatus(myUserId);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> blockUser(String blockerId, String blockedId) async {
    try {
      await _api.blockUser(blockerId, blockedId);
      bool updated = false;
      final list = List<ChatModel>.from(_chats);
      for (int i = 0; i < list.length; i++) {
        if (list[i].otherUser?.id != blockedId) continue;
        final c = list[i];
        list[i] = ChatModel(
          id: c.id,
          participants: c.participants,
          otherUser: c.otherUser,
          lastMessage: c.lastMessage,
          createdAt: c.createdAt,
          unread: c.unread,
          blockedByThem: c.blockedByThem,
          iBlockedThem: true,
        );
        updated = true;
      }
      if (updated) _chats = list;
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> unblockUser(String blockerId, String blockedId) async {
    try {
      await _api.unblockUser(blockerId, blockedId);
      bool updated = false;
      final list = List<ChatModel>.from(_chats);
      for (int i = 0; i < list.length; i++) {
        if (list[i].otherUser?.id != blockedId) continue;
        final c = list[i];
        list[i] = ChatModel(
          id: c.id,
          participants: c.participants,
          otherUser: c.otherUser,
          lastMessage: c.lastMessage,
          createdAt: c.createdAt,
          unread: c.unread,
          blockedByThem: c.blockedByThem,
          iBlockedThem: false,
        );
        updated = true;
      }
      if (updated) _chats = list;
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<ChatModel?> createChat(String userId, String otherUserId) async {
    try {
      final chat = await _api.createChat(userId, [userId, otherUserId]);
      if (chat != null) addChat(chat);
      return chat;
    } catch (_) {
      return null;
    }
  }

  void updateMessageStatus(String messageId, String status) {
    final msgIdx = _messages.indexWhere((m) => m.id == messageId);
    if (msgIdx >= 0) {
      final m = _messages[msgIdx];
      _messages = List<MessageModel>.from(_messages);
      _messages[msgIdx] = MessageModel(
        id: m.id,
        chatId: m.chatId,
        senderId: m.senderId,
        text: m.text,
        createdAt: m.createdAt,
        status: status,
      );
    }
    for (int i = 0; i < _chats.length; i++) {
      final lm = _chats[i].lastMessage;
      if (lm != null && lm.id == messageId) {
        final list = List<ChatModel>.from(_chats);
        final c = list[i];
        list[i] = ChatModel(
          id: c.id,
          participants: c.participants,
          otherUser: c.otherUser,
          lastMessage: MessageModel(
            id: lm.id,
            chatId: lm.chatId,
            senderId: lm.senderId,
            text: lm.text,
            createdAt: lm.createdAt,
            status: status,
          ),
          createdAt: c.createdAt,
          unread: c.unread,
          blockedByThem: c.blockedByThem,
          iBlockedThem: c.iBlockedThem,
        );
        _chats = list;
        break;
      }
    }
    notifyListeners();
  }

  void updateUserStatus(String userId, bool online, int? lastSeen) {
    bool changed = false;
    final list = List<ChatModel>.from(_chats);
    for (int i = 0; i < list.length; i++) {
      final o = list[i].otherUser;
      if (o != null && o.id == userId) {
        list[i] = ChatModel(
          id: list[i].id,
          participants: list[i].participants,
          otherUser: o.copyWith(online: online, lastSeen: lastSeen),
          lastMessage: list[i].lastMessage,
          createdAt: list[i].createdAt,
          unread: list[i].unread,
          blockedByThem: list[i].blockedByThem,
          iBlockedThem: list[i].iBlockedThem,
        );
        changed = true;
      }
    }
    if (changed) _chats = list;
    final uIdx = _users.indexWhere((u) => u.id == userId);
    if (uIdx >= 0) {
      _users = List<UserModel>.from(_users);
      _users[uIdx] = _users[uIdx].copyWith(online: online, lastSeen: lastSeen);
      changed = true;
    }
    if (changed) notifyListeners();
  }

  void clearMessages() {
    _messages = [];
    _currentChatId = null;
    notifyListeners();
  }
}
