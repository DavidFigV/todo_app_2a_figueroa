import 'package:flutter/material.dart';
import 'package:duito/data/firebase/auth_repository_firebase.dart';
import 'package:duito/pages/home_page.dart';

class LoginPage extends StatelessWidget {
  final _authRepo = AuthRepositoryFirebase();

  LoginPage({super.key});

  void _handleLogin(BuildContext context) async {
    final success = await _authRepo.signInWithGoogle();

    if (!context.mounted) return;

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al iniciar sesión')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Iniciar sesión")),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.login),
          label: const Text("Continuar con Google"),
          onPressed: () => _handleLogin(context),
        ),
      ),
    );
  }
}
