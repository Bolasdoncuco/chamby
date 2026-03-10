import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CandidateProfileScreen extends StatelessWidget {
  const CandidateProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                        child: Image.network(
                          'https://picsum.photos/seed/alex/400/300',
                          width: double.infinity,
                          fit: BoxFit.cover,
                          color: Colors.black.withOpacity(0.2),
                          colorBlendMode: BlendMode.darken,
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
                                const Text('Alex, 22', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                                const Text('Barista / Cajero', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                                const SizedBox(height: 24),
                                _ProfileInfoRow(icon: LucideIcons.mapPin, text: 'Centro, Ciudad'),
                                const SizedBox(height: 16),
                                _ProfileInfoRow(icon: LucideIcons.clock, text: 'Tiempo completo'),
                                const SizedBox(height: 16),
                                _ProfileInfoRow(icon: LucideIcons.award, text: '2 años de experiencia'),
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
            _SectionHeader(title: 'Sobre mí'),
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
                'Barista energético buscando un ambiente de café concurrido. ¡Prospero bajo presión y me encanta el arte latte!',
                style: TextStyle(color: Colors.grey[600], height: 1.5),
              ),
            ),

            // Skills
            _SectionHeader(title: 'Habilidades'),
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              width: double.infinity,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['Dinámico', 'Arte Latte', 'Sistemas POS', 'Atención al Cliente', 'Inglés Básico']
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

            // Video Pitch
            _SectionHeader(title: 'Mi Video Pitch'),
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
                       Image.network('https://picsum.photos/seed/alex/600/400', fit: BoxFit.cover),
                       Container(color: Colors.black.withOpacity(0.2)),
                       Center(
                         child: Container(
                           width: 48, height: 48,
                           decoration: BoxDecoration(
                             color: Colors.white,
                             shape: BoxShape.circle,
                             boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10)],
                           ),
                           child: const Icon(LucideIcons.play, color: Color(0xFF2563EB), size: 24),
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
