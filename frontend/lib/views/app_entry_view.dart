import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../services/storage_service.dart';
import 'splash_view.dart';
import 'onboarding_view.dart';
import 'login_view.dart';
import 'inbox_view.dart';

class AppEntryView extends StatefulWidget {
  const AppEntryView({super.key});

  @override
  State<AppEntryView> createState() => _AppEntryViewState();
}

class _AppEntryViewState extends State<AppEntryView> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    const minSplash = Duration(milliseconds: 1200);
    final stopwatch = Stopwatch()..start();
    final done = await StorageService.isOnboardingDone();
    if (!mounted) return;
    if (done) {
      await context.read<AuthController>().loadSession();
      if (!mounted) return;
    }
    final elapsed = stopwatch.elapsed;
    if (elapsed < minSplash) {
      await Future.delayed(minSplash - elapsed);
    }
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

class SessionLoader extends StatelessWidget {
  const SessionLoader({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final loggedIn = auth.hasVerifiedSession;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: child,
      ),
      child: loggedIn
          ? const InboxView(key: ValueKey('home'))
          : const LoginView(key: ValueKey('login')),
    );
  }
}
