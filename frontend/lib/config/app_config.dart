import 'dart:convert';

import 'package:flutter/services.dart';

class AppConfig {
  AppConfig._();
  static AppConfig? _instance;
  static AppConfig get instance => _instance!;

  late String apiBaseUrl;
  late String supabaseUrl;
  late String supabaseAnonKey;
  late String googleWebClientId;

  static Future<AppConfig> load() async {
    final json = await rootBundle.loadString('assets/config/app_config.json');
    final map = jsonDecode(json) as Map<String, dynamic>;
    _instance = AppConfig._()
      ..apiBaseUrl = map['apiBaseUrl'] as String
      ..supabaseUrl = map['supabaseUrl'] as String
      ..supabaseAnonKey = map['supabaseAnonKey'] as String
      ..googleWebClientId = map['googleWebClientId'] as String;
    return _instance!;
  }
}
