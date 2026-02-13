import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../services/storage_service.dart';
import 'splash_view.dart';
import 'onboarding_view.dart';
import 'login_view.dart';
import 'chats_view.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (!mounted) return;
      _navigateNext();
    });
  }

  Future<void> _navigateNext() async {
    final done = await StorageService.isOnboardingDone();
    if (!mounted) return;
    if (done) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SessionLoader()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingView()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SplashView(showSpinner: true);
  }
}

class SessionLoader extends StatefulWidget {
  const SessionLoader({super.key});

  @override
  State<SessionLoader> createState() => _SessionLoaderState();
}

class _SessionLoaderState extends State<SessionLoader> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthController>().loadSession().then((_) {
        if (mounted) setState(() {});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    if (!auth.sessionChecked) {
      return const SplashView(showSpinner: true);
    }
    return auth.isLoggedIn ? const ChatsView() : const LoginView();
  }
}
