import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/auth_provider.dart';
import '../../utils/image_utils.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  UserRole? _role;
  int _step = 1;

  // Form State - Candidate
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _headlineController = TextEditingController();
  final _locationController = TextEditingController();
  final _minSalaryController = TextEditingController();
  final _videoUrlController = TextEditingController();

  List<String> _skills = [];
  final _skillController = TextEditingController();

  // Employer specific
  final _companyController = TextEditingController();
  String _selectedSector = '';

  String? _base64Photo;
  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _whatsappController.dispose();
    _headlineController.dispose();
    _locationController.dispose();
    _minSalaryController.dispose();
    _videoUrlController.dispose();
    _skillController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  void _handleNext() async {
    // Validaciones de campos obligatorios
    String? errorMsg;
    if (_role == UserRole.candidate) {
      if (_step == 1) {
        if (_firstNameController.text.trim().isEmpty) errorMsg = 'El nombre es obligatorio.';
        else if (_lastNameController.text.trim().isEmpty) errorMsg = 'El apellido es obligatorio.';
        else if (_emailController.text.trim().isEmpty) errorMsg = 'El email es obligatorio.';
        else if (_passwordController.text.isEmpty) errorMsg = 'La contraseña es obligatoria.';
      } else if (_step == 2) {
        if (_headlineController.text.trim().isEmpty) errorMsg = 'El Headline u ocupación es obligatorio.';
        else if (_locationController.text.trim().isEmpty) errorMsg = 'La ubicación es obligatoria.';
      } else if (_step == 3) {
        if (_skills.isEmpty) errorMsg = 'Por favor, agrega al menos una habilidad.';
      }
    } else if (_role == UserRole.employer) {
      if (_companyController.text.trim().isEmpty) errorMsg = 'El nombre de la empresa es obligatorio.';
      else if (_emailController.text.trim().isEmpty) errorMsg = 'El email corporativo es obligatorio.';
      else if (_passwordController.text.isEmpty) errorMsg = 'La contraseña es obligatoria.';
      else if (_selectedSector.isEmpty) errorMsg = 'Por favor, selecciona un sector industrial.';
    }

    if (errorMsg != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg, style: const TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_role == UserRole.candidate && _step < 3) {
      setState(() => _step++);
    } else if (_role == UserRole.employer && _step < 1) {
      setState(() => _step++);
    } else {
      // Final Registration
      setState(() => _isLoading = true);
      try {
        final registrationData = <String, dynamic>{
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
          'role': _role == UserRole.employer ? 'EMPLOYER' : 'CANDIDATE',
        };

        if (_role == UserRole.candidate) {
          registrationData['firstName'] = _firstNameController.text.trim();
          registrationData['lastName'] = _lastNameController.text.trim();
          registrationData['profile'] = {
            'bio': _headlineController.text,
            'role': _headlineController.text.isNotEmpty ? _headlineController.text.split(',').first : 'Candidato',
            'availability': _locationController.text,
            'phone': _whatsappController.text,
            'whatsapp': _whatsappController.text,
            'photoData': _base64Photo,
            'skills': _skills,
          };
        } else {
          registrationData['companyName'] = _companyController.text.trim();
          registrationData['profile'] = {
            'description': _selectedSector,
          };
        }

        await context.read<AuthProvider>().register(
          data: registrationData,
          role: _role!,
        );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _addSkill() {
    final skill = _skillController.text.trim();
    if (skill.isNotEmpty && !_skills.contains(skill)) {
      setState(() {
        _skills.add(skill);
        _skillController.clear();
      });
    }
  }

  void _removeSkill(String skill) {
    setState(() {
      _skills.remove(skill);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_role == null) {
      return _buildRoleSelection();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 100,
        leading: TextButton.icon(
          onPressed: () {
            if (_step == 1) {
              setState(() => _role = null);
            } else {
               setState(() => _step--);
            }
          },
          icon: const Icon(LucideIcons.arrowLeft, size: 16, color: Colors.grey),
          label: const Text('Atrás', style: TextStyle(color: Colors.grey)),
        ),
      ),
      body: Column(
        children: [
          // Progress Bar
          LinearProgressIndicator(
            value: _step / (_role == UserRole.candidate ? 3 : 1),
            backgroundColor: Colors.grey[100],
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)), // blue-600
            minHeight: 6,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_role == UserRole.candidate) ...[
                    if (_step == 1) _buildCandidateStep1(),
                    if (_step == 2) _buildCandidateStep2(),
                    if (_step == 3) _buildCandidateStep3(),
                  ] else ...[
                    _buildEmployerStep(),
                  ],
                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB), // blue-600
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_isLoading)
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          else ...[
                            Text(
                              _step == (_role == UserRole.candidate ? 3 : 1) ? 'Finalizar Registro' : 'Siguiente Paso',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Únete a Chamby',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Selecciona tu rol para comenzar',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[500],
                ),
              ),
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
                  Text(
                    '¿Ya tienes cuenta? ',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                  GestureDetector(
                    onTap: () => context.read<AuthProvider>().setAppState(AppState.login),
                    child: const Text(
                      'Inicia sesión',
                      style: TextStyle(
                        color: Color(0xFF2563EB),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCandidateStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Identidad Básica', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text('Comencemos con lo esencial', style: TextStyle(color: Colors.grey[500])),
        const SizedBox(height: 24),
        _CustomTextField(controller: _firstNameController, icon: LucideIcons.user, hintText: 'Nombre(s)'),
        const SizedBox(height: 16),
        _CustomTextField(controller: _lastNameController, icon: LucideIcons.user, hintText: 'Apellido(s)'),
        const SizedBox(height: 16),
        _CustomTextField(controller: _emailController, icon: LucideIcons.mail, hintText: 'Email', keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 16),
        _CustomTextField(controller: _passwordController, icon: LucideIcons.lock, hintText: 'Contraseña', obscureText: true),
        const SizedBox(height: 16),
        _CustomTextField(controller: _whatsappController, icon: LucideIcons.phone, hintText: 'WhatsApp', keyboardType: TextInputType.phone),
      ],
    );
  }

  Widget _buildCandidateStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tu Match Card', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text('Así te verán las empresas', style: TextStyle(color: Colors.grey[500])),
        const SizedBox(height: 24),
        Center(
          child: GestureDetector(
            onTap: () async {
              final base64 = await ImageUtils.pickAndCompressImage();
              if (base64 != null) {
                setState(() => _base64Photo = base64);
              }
            },
            child: Container(
               width: 96, height: 96,
               decoration: BoxDecoration(
                 color: Colors.grey[100],
                 borderRadius: BorderRadius.circular(24),
                 border: Border.all(color: _base64Photo != null ? const Color(0xFF2563EB) : Colors.grey[300]!, width: 2),
                 image: _base64Photo != null 
                   ? DecorationImage(
                       image: MemoryImage(base64Decode(_base64Photo!)), 
                       fit: BoxFit.cover
                     ) 
                   : null,
               ),
               child: _base64Photo == null ? Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   Icon(LucideIcons.camera, color: Colors.grey[400]),
                   const SizedBox(height: 4),
                   Text('FOTO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[400])),
                 ],
               ) : null,
            ),
          ),
        ),
        const SizedBox(height: 24),
         Text('HEADLINE (MAX 140)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[500])),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[100]!),
          ),
          child: TextField(
            controller: _headlineController,
            maxLength: 140,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Ej: Mesero con 5 años de experiencia, bilingüe y proactivo.',
              hintStyle: TextStyle(color: Colors.grey[400]),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _CustomTextField(controller: _locationController, icon: LucideIcons.mapPin, hintText: 'Ubicación o Código Postal'),
        const SizedBox(height: 16),
        _CustomTextField(controller: _minSalaryController, icon: LucideIcons.dollarSign, hintText: 'Rango salarial mínimo', keyboardType: TextInputType.number),
      ],
    );
  }

  Widget _buildCandidateStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Deep Dive', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text('Detalla tu experiencia y habilidades', style: TextStyle(color: Colors.grey[500])),
        const SizedBox(height: 24),
        Text('HABILIDADES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[500])),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _CustomTextField(controller: _skillController, icon: LucideIcons.star, hintText: 'Ej: Ventas'),
            ),
            const SizedBox(width: 8),
             Container(
               decoration: BoxDecoration(
                 color: const Color(0xFF2563EB),
                 borderRadius: BorderRadius.circular(16),
               ),
               child: IconButton(
                 icon: const Icon(LucideIcons.plus, color: Colors.white),
                 onPressed: _addSkill,
               ),
             ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _skills.map((skill) => Chip(
            label: Text(skill, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
            backgroundColor: const Color(0xFFEFF6FF), // blue-50
            deleteIcon: const Icon(LucideIcons.trash2, size: 14, color: Color(0xFF2563EB)),
            onDeleted: () => _removeSkill(skill),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide.none),
          )).toList(),
        ),
        const SizedBox(height: 24),
        Text('VIDEO PITCH (URL)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[500])),
        const SizedBox(height: 8),
        _CustomTextField(controller: _videoUrlController, icon: LucideIcons.video, hintText: 'Link a tu video de presentación', keyboardType: TextInputType.url),
      ],
    );
  }

  Widget _buildEmployerStep() {
     return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Registro Corporativo', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text('Únete como reclutador', style: TextStyle(color: Colors.grey[500])),
        const SizedBox(height: 24),
        Center(
          child: Container(
             width: 96, height: 96,
             decoration: BoxDecoration(
               color: Colors.grey[100],
               borderRadius: BorderRadius.circular(24),
               border: Border.all(color: Colors.grey[300]!, width: 2),
             ),
             child: Column(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 Icon(LucideIcons.building, color: Colors.grey[400]),
                 const SizedBox(height: 4),
                 Text('LOGO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[400])),
               ],
             ),
          ),
        ),
        const SizedBox(height: 24),
        _CustomTextField(controller: _companyController, icon: LucideIcons.building, hintText: 'Nombre de la empresa'),
        const SizedBox(height: 16),
        _CustomTextField(controller: _emailController, icon: LucideIcons.mail, hintText: 'Email corporativo', keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 16),
        _CustomTextField(controller: _passwordController, icon: LucideIcons.lock, hintText: 'Contraseña', obscureText: true),
        const SizedBox(height: 16),
        // Simple Dropdown substitute
        Container(
           decoration: BoxDecoration(
            color: Colors.grey[50], 
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[100]!), 
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: _selectedSector.isEmpty ? null : _selectedSector,
              hint: const Text('Sector Industrial'),
              icon: Icon(LucideIcons.globe, color: Colors.grey[400], size: 20),
              items: const [
                DropdownMenuItem(value: 'tecnologia', child: Text('Tecnología')),
                DropdownMenuItem(value: 'servicios', child: Text('Servicios')),
                DropdownMenuItem(value: 'retail', child: Text('Retail')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _selectedSector = val);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _BigRoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _BigRoleCard({
    required this.icon, required this.title, required this.subtitle, required this.onTap,
  });

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
              width: 64, height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFDBEAFE), // blue-100
                borderRadius: BorderRadius.circular(16),
              ),
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

class _CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final IconData icon;
  final String hintText;
  final bool obscureText;
  final TextInputType keyboardType;

  const _CustomTextField({
    required this.controller,
    required this.icon,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50], 
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[100]!), 
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(color: Color(0xFF0F172A)), 
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: Icon(icon, color: Colors.grey[400], size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}
