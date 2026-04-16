import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/app_shell.dart';
import 'package:google_fonts/google_fonts.dart';
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
      scrollBehavior: const NoStretchScrollBehavior(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme().copyWith(
          // Títulos de tarjetas (Puesto de trabajo)
          titleLarge: const TextStyle(
            fontFamily: 'Satoshi',
            fontWeight: FontWeight.bold, // 700
            fontSize: 24,
            letterSpacing: -0.48, // -0.02em
          ),
          headlineSmall: const TextStyle(
            fontFamily: 'Satoshi',
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: -0.48,
          ),
          headlineMedium: const TextStyle(
            fontFamily: 'Satoshi',
            fontWeight: FontWeight.bold,
            fontSize: 28,
            letterSpacing: -0.56,
          ),
          // Cuerpo de texto (Descripción del empleo/Bio)
          bodyLarge: GoogleFonts.inter(
            fontWeight: FontWeight.w400, // Regular
            fontSize: 16,
            height: 1.5, // line-height
          ),
          bodyMedium: GoogleFonts.inter(
            fontWeight: FontWeight.w400,
            fontSize: 14,
            height: 1.5,
          ),
          // Botones y Etiquetas (UI)
          labelLarge: GoogleFonts.inter(
            fontWeight: FontWeight.w500, // Medium
            fontSize: 14,
          ),
        ),
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
      case AppState.loading:
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
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

/// Elimina el efecto visual de rebote/estiramiento al scrollear en los bordes
class NoStretchScrollBehavior extends ScrollBehavior {
  const NoStretchScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    // ClampingScrollPhysics garantiza que el scroll se detenga en seco en el límite,
    // eliminando rebotes de iOS y estiramientos de Android de tajo.
    return const ClampingScrollPhysics();
  }

  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    // Retorna el child directamente para anular el efecto de color/onda en Android antiguo
    return child;
  }
}
