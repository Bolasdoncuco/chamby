import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:convert';
import '../../services/api_service.dart';

class CandidateProfileScreen extends StatefulWidget {
  const CandidateProfileScreen({super.key});

  @override
  State<CandidateProfileScreen> createState() => _CandidateProfileScreenState();
}

class _CandidateProfileScreenState extends State<CandidateProfileScreen> {
  Map<String, dynamic>? _profile;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final response = await ApiService.get('/candidates/profile');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _profile = data['profile'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Error cargando perfil: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error de conexión: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Center(child: Text(_error!, style: const TextStyle(color: Colors.red))),
      );
    }

    if (_profile == null) {
       return const Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: Center(child: Text('Perfil no encontrado.')),
      );
    }

    final p = _profile!;
    final name = '${p['firstName'] ?? ''} ${p['lastName'] ?? ''}'.trim();
    final role = p['role'] ?? 'Candidato';
    final location = p['latitude'] != null ? 'Ubicación Disponible' : 'Ubicación no especificada';
    final experience = '${p['experience'] ?? 0} años de experiencia';
    final availability = p['availability'] ?? 'Flexible';
    final bio = (p['bio'] == null || p['bio'].toString().isEmpty) ? 'Sin descripción' : p['bio'];
    final skills = List<String>.from(p['skills'] ?? []);
    final photoData = p['photoData'];

    return Container(
      color: Colors.grey[50], // slate-50
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Profile Card
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey[100]!),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                   Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Container(
                        height: 192, // h-48
                        color: const Color(0xFF2563EB), // blue-600
                        child: photoData != null 
                          ? Image.memory(
                              base64Decode(photoData),
                              width: double.infinity,
                              fit: BoxFit.cover,
                              color: Colors.black.withOpacity(0.2),
                              colorBlendMode: BlendMode.darken,
                            )
                          : Container(
                              width: double.infinity,
                              color: const Color(0xFF2563EB),
                            ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: CircleAvatar(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          child: IconButton(
                            icon: const Icon(LucideIcons.edit2, size: 18, color: Colors.white),
                            onPressed: () {},
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Transform.translate(
                          offset: const Offset(0, -64), // -mt-12 + extra for centering
                          child: Container(
                            width: 96, height: 96,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
                            ),
                            padding: const EdgeInsets.all(4),
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF), // blue-50
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(LucideIcons.user, size: 48, color: Color(0xFF2563EB)),
                            ),
                          ),
                        ),
                        Transform.translate(
                          offset: const Offset(0, -48),
                          child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                                Text(name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                                Text(role, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                                const SizedBox(height: 24),
                                _ProfileInfoRow(icon: LucideIcons.mapPin, text: location),
                                const SizedBox(height: 16),
                                _ProfileInfoRow(icon: LucideIcons.clock, text: availability),
                                const SizedBox(height: 16),
                                _ProfileInfoRow(icon: LucideIcons.award, text: experience),
                             ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // About Me
            const _SectionHeader(title: 'Sobre mí'),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[100]!),
              ),
              child: Text(
                bio,
                style: TextStyle(color: Colors.grey[600], height: 1.5),
              ),
            ),

            // Skills
            if (skills.isNotEmpty) ...[
              const _SectionHeader(title: 'Habilidades'),
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                width: double.infinity,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: skills
                    .map((skill) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey[100]!),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
                      ),
                      child: Text(skill, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[700])),
                    )).toList(),
                ),
              ),
            ],

            // Video Pitch (Optional / Placeholder if not set)
            const _SectionHeader(title: 'Mi Video Pitch'),
            Container(
              margin: const EdgeInsets.only(bottom: 32),
              width: double.infinity,
              child: AspectRatio(
                aspectRatio: 16/9,
                 child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                       Container(color: Colors.black.withOpacity(0.1)),
                       Center(
                         child: Column(
                           mainAxisAlignment: MainAxisAlignment.center,
                           children: [
                             Container(
                               width: 48, height: 48,
                               decoration: BoxDecoration(
                                 color: Colors.white,
                                 shape: BoxShape.circle,
                                 boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10)],
                               ),
                               child: const Icon(LucideIcons.play, color: Color(0xFF2563EB), size: 24),
                             ),
                             const SizedBox(height: 8),
                             Text('Video no disponible', style: TextStyle(color: Colors.grey[600], fontSize: 12))
                           ],
                         ),
                       )
                    ],
                  ),
                 ),
              )
            )

          ],
        ),
      ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ProfileInfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[400]),
        const SizedBox(width: 12),
        Text(text, style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Colors.grey[400],
          ),
        ),
      ),
    );
  }
}
