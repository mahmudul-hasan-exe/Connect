import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';
import '../services/storage_service.dart';

class AuthController with ChangeNotifier {
  UserModel? _user;
  String? _token;
  final ApiService _api = ApiService();
  final SocketService _socket = SocketService();
  bool _sessionChecked = false;

  UserModel? get user => _user;
  String? get token => _token;
  SocketService get socket => _socket;
  bool get isLoggedIn => _user != null && _token != null;
  bool get sessionChecked => _sessionChecked;
  bool get isOnline => _socket.isConnected;

  Future<void> loadSession() async {
    if (_sessionChecked) return;
    try {
      final data = await StorageService.loadSession();
      if (data != null &&
          data['token']!.isNotEmpty &&
          data['userId']!.isNotEmpty &&
          data['userName']!.isNotEmpty) {
        _token = data['token'];
        _user = UserModel(
          id: data['userId']!,
          name: data['userName']!,
          avatar: data['avatar']!.isEmpty ? null : data['avatar'],
          online: false,
        );
        _socket.connect(ApiService.baseUrl, _user!.id);
      }
    } catch (_) {}
    _sessionChecked = true;
    notifyListeners();
  }

  Future<bool> login(String name) async {
    try {
      final data = await _api.auth(name: name);
      _token = data['token'] as String?;
      _user = data['user'] != null
          ? UserModel.fromJson(data['user'] as Map<String, dynamic>)
          : null;
      if (_user != null && _token != null) {
        await StorageService.saveSession(
          token: _token!,
          userId: _user!.id,
          userName: _user!.name,
          avatar: _user!.avatar,
        );
        _socket.connect(ApiService.baseUrl, _user!.id);
      }
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  void disconnectSocket() {
    _socket.disconnect();
    notifyListeners();
  }

  void reconnectSocket() {
    if (_user != null && _token != null) {
      _socket.connect(ApiService.baseUrl, _user!.id);
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _socket.disconnect();
    await StorageService.clearSession();
    _user = null;
    _token = null;
    notifyListeners();
  }
}
