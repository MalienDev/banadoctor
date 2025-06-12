import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/providers/auth_module_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logoutUseCase = ref.watch(logoutUseCaseProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await logoutUseCase();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Bienvenue sur votre tableau de bord !'),
      ),
    );
  }
}
