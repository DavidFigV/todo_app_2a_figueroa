import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:duito/data/firebase/auth_repository_firebase.dart';
import 'package:duito/pages/home_page.dart';
import 'package:duito/util/my_button.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  void _guardarPreferenciasYEntrar({
    required BuildContext context,
    required bool logueado,
    required bool modoLocal,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('inicio_completado', true);
    await prefs.setBool('logueado', logueado);
    await prefs.setBool('modo_local', modoLocal);

    if (!context.mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  void _iniciarSesion(BuildContext context) async {
    final auth = AuthRepositoryFirebase();
    final ok = await auth.signInWithGoogle();
    if (ok) {
      if (context.mounted) {
        _guardarPreferenciasYEntrar(
          context: context,
          logueado: true,
          modoLocal: false,
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al iniciar sesión")),
        );
      }
    }
  }

  void omitirInicioSesion(BuildContext context) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (alertContext) => AlertDialog(
        title: const Text("Atención"),
        content: const Text(
          "Trabajarás en modo local. Si borras la app, perderás tus datos. ¿Deseas continuar?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(alertContext, false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(alertContext, true),
            child: const Text("Continuar"),
          ),
        ],
      ),
    );

    if (confirmado == true && context.mounted) {
      _guardarPreferenciasYEntrar(
        context: context,
        logueado: false,
        modoLocal: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[200],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "¡Bienvenido a Duito!",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              MyButton(
                text: "Iniciar sesión con Google",
                onPressed: () => _iniciarSesion(context),
              ),
              const SizedBox(height: 15),
              MyButton(
                text: "Omitir e ir al modo local",
                onPressed: () => omitirInicioSesion(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
