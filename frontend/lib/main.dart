import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:connect_app/config/app_config.dart';
import 'package:connect_app/controllers/auth_controller.dart';
import 'package:connect_app/controllers/chat_controller.dart';
import 'package:connect_app/services/supabase_auth_service.dart';
import 'package:connect_app/theme/app_theme.dart';
import 'package:connect_app/views/app_entry_view.dart';
import 'package:connect_app/widgets/app_lifecycle_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.load();
  await SupabaseAuthService.init();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const ConnectApp());
}

class ConnectApp extends StatelessWidget {
  const ConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => ChatController()),
      ],
      child: MaterialApp(
        title: 'Connect',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const AppLifecycleHandler(child: AppEntryView()),
      ),
    );
  }
}
