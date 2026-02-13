import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _keyToken = 'connect_token';
  static const _keyUserId = 'connect_user_id';
  static const _keyUserName = 'connect_user_name';
  static const _keyUserAvatar = 'connect_user_avatar';
  static const _keyOnboardingDone = 'connect_onboarding_done';

  static Future<void> saveSession({
    required String token,
    required String userId,
    required String userName,
    String? avatar,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
    await prefs.setString(_keyUserId, userId);
    await prefs.setString(_keyUserName, userName);
    if (avatar != null) {
      await prefs.setString(_keyUserAvatar, avatar);
    } else {
      await prefs.remove(_keyUserAvatar);
    }
  }

  static Future<Map<String, String>?> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_keyToken);
    final userId = prefs.getString(_keyUserId);
    final userName = prefs.getString(_keyUserName);
    if (token == null || userId == null || userName == null) return null;
    return {
      'token': token,
      'userId': userId,
      'userName': userName,
      'avatar': prefs.getString(_keyUserAvatar) ?? '',
    };
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserName);
    await prefs.remove(_keyUserAvatar);
  }

  static Future<bool> isOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboardingDone) ?? false;
  }

  static Future<void> setOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingDone, true);
  }
}
