import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:duito/pages/home_page.dart';
import 'package:duito/pages/welcome_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _navegar();
  }

  Future<void> _navegar() async {
    await Future.delayed(const Duration(seconds: 1)); // Simula carga

    final prefs = await SharedPreferences.getInstance();
    final bool inicioCompletado = prefs.getBool('inicio_completado') ?? false;

    if (!inicioCompletado) {
      _irA(const WelcomePage());
    } else {
      _irA(const HomePage());
    }
  }

  void _irA(Widget destino) {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => destino),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.blue,
      body: Center(child: CircularProgressIndicator(color: Colors.white)),
    );
  }
}
