import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_share/core/providers/auth_state_provider.dart';
import 'package:room_share/features/auth/presentation/screen/login_screen.dart';
import 'package:room_share/navigation_menu.dart';


class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (data) {
        final session = data.session;

        if (session != null) {
          return const NavigationMenu();
        } else {
          return const LoginPage();
        }
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }
}