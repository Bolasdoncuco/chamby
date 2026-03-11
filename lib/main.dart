import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/app_shell.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const ChambyApp(),
    ),
  );
}

class ChambyApp extends StatelessWidget {
  const ChambyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chamby',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        fontFamily: 'Inter', // We can add this font later
      ),
      home: const RootNavigator(),
    );
  }
}

class RootNavigator extends StatelessWidget {
  const RootNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.select((AuthProvider p) => p.appState);

    switch (appState) {
      case AppState.welcome:
        return const WelcomeScreen();
      case AppState.login:
        return const LoginScreen();
      case AppState.signup:
        return const SignupScreen();
      case AppState.app:
        return const AppShell();
    }
  }
}
