import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../utils/form_validation.dart';
import '../../widgets/common/custom_text_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  UserRole? _role;
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _companyController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final auth = context.read<AuthProvider>();
    if (auth.isLoading) return;

    String? errorMessage;
    if (_role == UserRole.candidate) {
      if (_firstNameController.text.trim().isEmpty) {
        errorMessage = 'El nombre es obligatorio.';
      } else if (_lastNameController.text.trim().isEmpty) {
        errorMessage = 'El apellido es obligatorio.';
      }
    } else if (_role == UserRole.employer && _companyController.text.trim().isEmpty) {
      errorMessage = 'El nombre de la empresa es obligatorio.';
    }
    if (errorMessage == null && !isValidEmail(_emailController.text)) {
      errorMessage = 'Ingresa un correo electrónico válido.';
    }
    if (errorMessage == null && _passwordController.text.isEmpty) {
      errorMessage = 'La contraseña es obligatoria.';
    }
    if (errorMessage != null) {
      _showError(errorMessage);
      return;
    }

    final data = <String, dynamic>{
      'email': _emailController.text.trim(),
      'password': _passwordController.text,
      'role': _role == UserRole.employer ? 'EMPLOYER' : 'CANDIDATE',
    };
    if (_role == UserRole.candidate) {
      data['firstName'] = _firstNameController.text.trim();
      data['lastName'] = _lastNameController.text.trim();
    } else {
      data['companyName'] = _companyController.text.trim();
    }

    final registered = await auth.register(data: data);
    if (!registered && mounted) {
      _showError(context.read<AuthProvider>().errorMessage ?? 'No fue posible registrarte.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_role == null) return _buildRoleSelection();
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 100,
        leading: TextButton.icon(
          onPressed: () => setState(() => _role = null),
          icon: const Icon(LucideIcons.arrowLeft, size: 16, color: Colors.grey),
          label: const Text('Atrás', style: TextStyle(color: Colors.grey)),
        ),
      ),
      body: Column(
        children: [
          const LinearProgressIndicator(
            value: 1,
            backgroundColor: Color(0xFFF3F4F6),
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
            minHeight: 6,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_role == UserRole.candidate) _buildCandidateFields() else _buildEmployerFields(),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('Finalizar Registro', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleSelection() {
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
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('Únete a Chamby', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              const SizedBox(height: 8),
              Text('Selecciona tu rol para comenzar', style: TextStyle(fontSize: 16, color: Colors.grey[500])),
              const SizedBox(height: 48),
              _BigRoleCard(
                icon: LucideIcons.user,
                title: 'Soy Candidato',
                subtitle: 'Busco mi próximo gran empleo',
                onTap: () => setState(() => _role = UserRole.candidate),
              ),
              const SizedBox(height: 16),
              _BigRoleCard(
                icon: LucideIcons.briefcase,
                title: 'Soy Empresa',
                subtitle: 'Busco el mejor talento local',
                onTap: () => setState(() => _role = UserRole.employer),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('¿Ya tienes cuenta? ', style: TextStyle(color: Colors.grey[500])),
                  GestureDetector(
                    onTap: () => context.read<AuthProvider>().setAppState(AppState.login),
                    child: const Text('Inicia sesión', style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCandidateFields() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Identidad Básica', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text('Comencemos con lo esencial', style: TextStyle(color: Colors.grey[500])),
          const SizedBox(height: 8),
          const Text('Completa foto, habilidades y experiencia después de crear tu cuenta.'),
          const SizedBox(height: 24),
          CustomTextField(controller: _firstNameController, icon: LucideIcons.user, hintText: 'Nombre(s)'),
          const SizedBox(height: 16),
          CustomTextField(controller: _lastNameController, icon: LucideIcons.user, hintText: 'Apellido(s)'),
          const SizedBox(height: 16),
          CustomTextField(controller: _emailController, icon: LucideIcons.mail, hintText: 'Email', keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 16),
          CustomTextField(controller: _passwordController, icon: LucideIcons.lock, hintText: 'Contraseña', obscureText: true),
        ],
      );

  Widget _buildEmployerFields() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Registro Corporativo', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text('Únete como reclutador', style: TextStyle(color: Colors.grey[500])),
          const SizedBox(height: 24),
          CustomTextField(controller: _companyController, icon: LucideIcons.building, hintText: 'Nombre de la empresa'),
          const SizedBox(height: 16),
          CustomTextField(controller: _emailController, icon: LucideIcons.mail, hintText: 'Email corporativo', keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 16),
          CustomTextField(controller: _passwordController, icon: LucideIcons.lock, hintText: 'Contraseña', obscureText: true),
        ],
      );
}

class _BigRoleCard extends StatelessWidget {
  const _BigRoleCard({required this.icon, required this.title, required this.subtitle, required this.onTap});

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.grey[100]!, width: 2),
        ),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(color: const Color(0xFFDBEAFE), borderRadius: BorderRadius.circular(16)),
              child: Icon(icon, size: 32, color: const Color(0xFF2563EB)),
            ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
