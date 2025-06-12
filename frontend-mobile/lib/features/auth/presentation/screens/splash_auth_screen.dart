import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_module_provider.dart';

class SplashAuthScreen extends ConsumerStatefulWidget {
  const SplashAuthScreen({super.key});

  @override
  ConsumerState<SplashAuthScreen> createState() => _SplashAuthScreenState();
}

class _SplashAuthScreenState extends ConsumerState<SplashAuthScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Wait for the widget to be built before navigating
    await Future.delayed(const Duration(milliseconds: 50));

    final checkAuthStatus = ref.read(checkAuthStatusUseCaseProvider);
    final result = await checkAuthStatus();

    if (mounted) {
      result.fold(
        (failure) => context.go('/login'),
        (user) => context.go('/dashboard'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
