import 'package:flutter/material.dart';

import 'screens/cadastro_tecnico_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

void main() => runApp(const TechServiceApp());

class TechServiceApp extends StatelessWidget {
  const TechServiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TechService',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1F3A93)),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/cadastro': (context) => const CadastroTecnicoScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
