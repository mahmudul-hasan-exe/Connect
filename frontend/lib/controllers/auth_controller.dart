import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';
import '../services/storage_service.dart';
import '../services/supabase_auth_service.dart';

class AuthController with ChangeNotifier {
  UserModel? _user;
  String? _token;
  String? _authError;
  final ApiService _api = ApiService();
  final SocketService _socket = SocketService();
  bool _sessionChecked = false;
  StreamSubscription? _authSubscription;

  UserModel? get user => _user;
  String? get token => _token;
  String? get authError => _authError;
  SocketService get socket => _socket;
  bool get sessionChecked => _sessionChecked;
  bool get isOnline => _socket.isConnected;

  void clearAuthError() {
    if (_authError != null) {
      _authError = null;
      notifyListeners();
    }
  }

  bool get isLoggedIn {
    if (_user == null || _token == null) return false;
    if (_user!.id.isEmpty || _token!.isEmpty) return false;
    return true;
  }

  bool get hasVerifiedSession => isLoggedIn;

  AuthController() {
    _authSubscription =
        SupabaseAuthService.authStateChanges.listen(_onAuthStateChange);
  }

  void _onAuthStateChange(AuthState state) {
    final session = state.session;
    if (session != null) {
      _syncWithBackend(session.accessToken);
    }
  }

  Future<void> _syncWithBackend(String accessToken) async {
    if (accessToken.isEmpty) return;
    _authError = null;
    for (var attempt = 1; attempt <= 3; attempt++) {
      try {
        final data = await _api.authWithSupabase(accessToken);
        final tokenRaw = data['token'];
        final token = tokenRaw?.toString().trim();
        final userRaw = data['user'];
        final userJson = userRaw is Map<String, dynamic> ? userRaw : null;
        if (token == null || token.isEmpty || userJson == null) {
          if (attempt >= 3) {
            _authError = 'Invalid server response.';
            notifyListeners();
          }
          return;
        }
        _token = token;
        _user = UserModel.fromJson(userJson);
        _authError = null;
        await StorageService.saveSession(
          token: _token!,
          userId: _user!.id,
          userName: _user!.name,
          avatar: _user!.avatar,
        );
        _socket.connect(ApiService.baseUrl, _user!.id);
        notifyListeners();
        return;
      } catch (e) {
        if (attempt >= 3) {
          _authError = e.toString().replaceFirst('Exception: ', '');
          if (_authError!.length > 80) {
            _authError = '${_authError!.substring(0, 80)}...';
          }
          notifyListeners();
        } else {
          await Future.delayed(Duration(milliseconds: 500 * attempt));
        }
      }
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> loadSession() async {
    if (_sessionChecked) return;
    try {
      final session = SupabaseAuthService.session;
      if (session != null) {
        await _syncWithBackend(session.accessToken);
      } else {
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
      }
    } catch (_) {}
    _sessionChecked = true;
    notifyListeners();
  }

  Future<void> signInWithGoogle() async {
    await SupabaseAuthService.signInWithGoogle();
    final session = SupabaseAuthService.session;
    if (session != null && session.accessToken.isNotEmpty) {
      await _syncWithBackend(session.accessToken);
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
    await SupabaseAuthService.signOut();
    await StorageService.clearSession();
    _user = null;
    _token = null;
    _authError = null;
    notifyListeners();
  }
}
