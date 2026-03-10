import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class CandidateData {
  final int id;
  final String name;
  final String role;
  final String location;
  final String availability;
  final String photo;

  CandidateData({required this.id, required this.name, required this.role, required this.location, required this.availability, required this.photo});
}

final List<CandidateData> mockCandidatesList = [
  CandidateData(id: 1, name: 'Alex, 22', role: 'Barista / Cajero', location: 'Centro', availability: 'Tiempo completo', photo: 'https://picsum.photos/seed/alex/200/200'),
  CandidateData(id: 2, name: 'Sarah, 25', role: 'Asesora de Ventas', location: 'Zona Norte', availability: 'Medio tiempo', photo: 'https://picsum.photos/seed/sarah/200/200'),
  CandidateData(id: 3, name: 'Mike, 20', role: 'Mesero / Server', location: 'Distrito Gastronómico', availability: 'Flexible', photo: 'https://picsum.photos/seed/mike/200/200'),
];

class VacancyCandidatesScreen extends StatelessWidget {
  const VacancyCandidatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vacancy = context.read<AuthProvider>().selectedVacancy;
    final title = vacancy != null ? vacancy.title : 'Vacante Desconocida';

    return Container(
      color: Colors.grey[50],
      child: Column(
        children: [
          // Header
           Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(LucideIcons.arrowLeft, color: Colors.grey),
                  onPressed: () => context.read<AuthProvider>().setCurrentView(CurrentView.dashboard),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Candidatos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                      Text(title.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: mockCandidatesList.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final c = mockCandidatesList[index];
                return Container(
                   padding: const EdgeInsets.all(16),
                   decoration: BoxDecoration(
                     color: Colors.white,
                     borderRadius: BorderRadius.circular(24),
                     border: Border.all(color: Colors.grey[100]!),
                     boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
                   ),
                   child: Row(
                     children: [
                        Container(
                          width: 64, height: 64,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            image: DecorationImage(image: NetworkImage(c.photo), fit: BoxFit.cover),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A)), maxLines: 1, overflow: TextOverflow.ellipsis),
                              Text(c.role, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF2563EB))),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(LucideIcons.mapPin, size: 10, color: Colors.grey[400]),
                                  const SizedBox(width: 4),
                                  Text(c.location, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[500])),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(LucideIcons.clock, size: 10, color: Colors.grey[400]),
                                  const SizedBox(width: 4),
                                  Text(c.availability, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[500])),
                                ],
                              )
                            ],
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: IconButton(
                                icon: Icon(LucideIcons.phone, size: 18, color: Colors.green[600]),
                                onPressed: () {},
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF), // blue-50
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: IconButton(
                                icon: const Icon(LucideIcons.messageCircle, size: 18, color: Color(0xFF2563EB)), // blue-600
                                onPressed: () {},
                              ),
                            ),
                          ],
                        )
                     ],
                   ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
