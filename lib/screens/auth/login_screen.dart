import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/auth_provider.dart';
import '../../utils/form_validation.dart';
import '../../widgets/common/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    final email = _emailController.text.trim();
    if (!isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa un correo electrónico válido.')),
      );
      return;
    }
    if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa tu contraseña.')),
      );
      return;
    }
    if (context.read<AuthProvider>().isLoading) return;

    final authenticated = await context.read<AuthProvider>().login(
          email: email,
          password: _passwordController.text,
        );
    if (!authenticated && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.read<AuthProvider>().errorMessage ?? 'No fue posible iniciar sesión.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 100,
        leading: TextButton.icon(
          onPressed: () => context.read<AuthProvider>().setAppState(AppState.welcome),
          icon: const Icon(LucideIcons.arrowLeft, size: 16, color: Colors.grey),
          label: const Text('Volver', style: TextStyle(color: Colors.grey)),
          style: TextButton.styleFrom(
             padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Bienvenido',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A), // slate-900
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ingresa tus credenciales para continuar',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[500], // slate-500
                ),
              ),
              const SizedBox(height: 8),
              const Text('El tipo de cuenta se determina con tu sesión.'),
              const SizedBox(height: 32),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextField(
                        controller: _emailController,
                        icon: LucideIcons.mail,
                        hintText: 'Correo electrónico',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _passwordController,
                        icon: LucideIcons.lock,
                        hintText: 'Contraseña',
                        obscureText: true,
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _handleSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB), // blue-600
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                            shadowColor: const Color(0xFFBFDBFE), // blue-200
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (isLoading)
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              else ...[
                                const Text(
                                  'Iniciar Sesión',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 8),
                                const Icon(LucideIcons.arrowRight, size: 20),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '¿No tienes cuenta? ',
                        style: TextStyle(color: Colors.grey[500]), // slate-500
                      ),
                      GestureDetector(
                        onTap: () => context.read<AuthProvider>().setAppState(AppState.signup),
                        child: const Text(
                          'Regístrate aquí',
                          style: TextStyle(
                            color: Color(0xFF2563EB), // blue-600
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
