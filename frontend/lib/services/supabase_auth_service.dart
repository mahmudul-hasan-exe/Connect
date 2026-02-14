import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';

class SupabaseAuthService {
  static SupabaseClient get _client => Supabase.instance.client;

  static Future<void> init() async {
    final c = AppConfig.instance;
    await Supabase.initialize(
      url: c.supabaseUrl,
      anonKey: c.supabaseAnonKey,
    );
  }

  static Future<void> signInWithGoogle() async {
    if (kIsWeb) {
      throw UnsupportedError('Google Sign-In is not supported on web');
    }
    final clientId = AppConfig.instance.googleWebClientId;
    if (clientId.isEmpty) {
      throw StateError(
        'googleWebClientId not set in app_config.json',
      );
    }
    await _signInWithGoogleNative();
  }

  static Future<void> _signInWithGoogleNative() async {
    final googleSignIn = GoogleSignIn(
      serverClientId: AppConfig.instance.googleWebClientId,
      scopes: ['email', 'profile'],
    );
    try {
      await googleSignIn.signOut();
    } catch (_) {}
    try {
      final account = await googleSignIn.signIn();
      if (account == null) return;
      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null) return;
      await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );
    } on PlatformException catch (e) {
      final code = e.code;
      String msg = e.message ?? e.toString();
      if (code == 'sign_in_failed' ||
          code.contains('12501') ||
          msg.toLowerCase().contains('developer') ||
          msg.toLowerCase().contains('api_not_enabled')) {
        msg = Platform.isAndroid
            ? 'Google Sign-In config error. Add SHA-1 to Google Cloud Console → Credentials → Android OAuth client (com.connect.app)'
            : 'Google Sign-In config error. Check Google Cloud Console.';
      }
      throw Exception(msg);
    }
  }

  static Session? get session => _client.auth.currentSession;

  static User? get user => _client.auth.currentUser;

  static Stream<AuthState> get authStateChanges =>
      _client.auth.onAuthStateChange;

  static Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
