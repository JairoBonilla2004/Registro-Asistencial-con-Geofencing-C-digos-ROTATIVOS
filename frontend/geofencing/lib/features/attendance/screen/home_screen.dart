import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geofencing/features/auth/presentation/state/auth_notifier_state.dart';


class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    return authState.when(
      initial: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      authenticated: (user) {
        // 🎯 Mostrar UI según el rol
        if (user.isStudent) {
          return const StudentHomeScreen();
        } else if (user.isTeacher) {
          return const TeacherHomeScreen();
        } else {
          return const Scaffold(
            body: Center(
              child: Text('Rol no reconocido'),
            ),
          );
        }
      },
      unauthenticated: () => const Scaffold(
        body: Center(child: Text('No autenticado')),
      ),
      error: (message) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $message'),
              ElevatedButton(
                onPressed: () {
                  ref.read(authNotifierProvider.notifier).logout();
                },
                child: const Text('Volver al login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}