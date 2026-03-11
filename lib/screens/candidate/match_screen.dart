import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class MatchScreen extends StatelessWidget {
  final dynamic user;
  final VoidCallback onContinue;

  const MatchScreen({super.key, this.user, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2563EB), Color(0xFF1E3A8A)], // blue-600 to blue-900
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success Icon & Text
              Container(
                width: 80, height: 80,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20)],
                ),
                child: const Icon(LucideIcons.checkCircle2, size: 48, color: Colors.white),
              ),
              const Text(
                'CONEXIÓN ESTABLECIDA',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -0.5),
              ),
              const SizedBox(height: 8),
              Text(
                'Se ha generado un interés mutuo.',
                style: TextStyle(fontSize: 18, color: Colors.blue[100], fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 48),

              // Avatars
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 96, height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20)],
                      image: const DecorationImage(
                        image: NetworkImage('https://picsum.photos/seed/employer/200/200'),
                        fit: BoxFit.cover,
                      )
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(-32, 0),
                    child: Container(
                      width: 96, height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20)],
                        image: DecorationImage(
                          image: NetworkImage(user?['videoPlaceholder'] ?? 'https://picsum.photos/seed/user/200/200'),
                          fit: BoxFit.cover,
                        )
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 48),

              // Actions
               SizedBox(
                 width: double.infinity,
                 child: ElevatedButton.icon(
                   onPressed: () {},
                   icon: const Icon(LucideIcons.messageCircle, size: 24),
                   label: const Text('Contactar por WhatsApp', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                   style: ElevatedButton.styleFrom(
                     backgroundColor: Colors.white,
                     foregroundColor: const Color(0xFF1D4ED8), // blue-700
                     padding: const EdgeInsets.symmetric(vertical: 16),
                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                     elevation: 8,
                   ),
                 ),
               ),
               const SizedBox(height: 16),
               SizedBox(
                 width: double.infinity,
                 child: OutlinedButton(
                   onPressed: onContinue,
                   style: OutlinedButton.styleFrom(
                     side: BorderSide(color: Colors.white.withOpacity(0.3), width: 2),
                     foregroundColor: Colors.white,
                     padding: const EdgeInsets.symmetric(vertical: 16),
                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                   ),
                   child: const Text('Seguir Explorando', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                 ),
               ),
            ],
          ),
        ),
      ),
    );
  }
}
