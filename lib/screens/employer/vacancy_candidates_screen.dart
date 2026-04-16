import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';

class CandidateData {
  final int id;
  final String name;
  final String role;
  final String location;
  final String availability;
  final String photo;
  final bool isMutualMatch;

  CandidateData({required this.id, required this.name, required this.role, required this.location, required this.availability, required this.photo, this.isMutualMatch = false});
}

final List<CandidateData> mockCandidatesList = [
  CandidateData(id: 1, name: 'Alex, 22', role: 'Barista / Cajero', location: 'Centro', availability: 'Tiempo completo', photo: 'https://picsum.photos/seed/alex/200/200', isMutualMatch: true),
  CandidateData(id: 2, name: 'Sarah, 25', role: 'Asesora de Ventas', location: 'Zona Norte', availability: 'Medio tiempo', photo: 'https://picsum.photos/seed/sarah/200/200', isMutualMatch: false),
  CandidateData(id: 3, name: 'Mike, 20', role: 'Mesero / Server', location: 'Distrito Gastronómico', availability: 'Flexible', photo: 'https://picsum.photos/seed/mike/200/200', isMutualMatch: false),
];

class VacancyCandidatesScreen extends StatefulWidget {
  const VacancyCandidatesScreen({super.key});

  @override
  State<VacancyCandidatesScreen> createState() => _VacancyCandidatesScreenState();
}

class _VacancyCandidatesScreenState extends State<VacancyCandidatesScreen> {
  int _activeTab = 0; // 0: Pre-aprobados, 1: Interesados
  bool _isLoading = true;
  
  List<dynamic> _applied = [];
  List<dynamic> _preApproved = [];
  List<dynamic> _matches = [];

  @override
  void initState() {
    super.initState();
    _fetchCandidates();
  }

  Future<void> _fetchCandidates() async {
    final vacancy = context.read<AuthProvider>().selectedVacancy;
    if (vacancy == null) return;

    try {
      final response = await ApiService.get('/employers/vacancies/${vacancy['id']}/candidates');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _applied = data['applied'];
            _preApproved = data['preApproved'];
            _matches = data['matches'];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar candidatos: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vacancy = context.read<AuthProvider>().selectedVacancy;
    final title = vacancy != null ? vacancy['title'] ?? 'Vacante' : 'Vacante Desconocida';

    List<dynamic> currentList = [];
    if (_activeTab == 0) {
      // Pre-aprobados + Matches (para que la empresa vea a los que aceptó)
      currentList = [..._matches, ..._preApproved];
    } else {
      currentList = _applied;
    }

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
          
          // Custom Tabs
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _activeTab = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: _activeTab == 0 ? const Color(0xFF2563EB) : Colors.transparent, width: 2)),
                      ),
                      child: Center(
                        child: Text(
                          'Seleccionados', 
                          style: TextStyle(color: _activeTab == 0 ? const Color(0xFF2563EB) : Colors.grey[400], fontWeight: FontWeight.bold)
                        )
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _activeTab = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: _activeTab == 1 ? const Color(0xFF2563EB) : Colors.transparent, width: 2)),
                      ),
                      child: Center(
                        child: Text(
                          'Interesados', 
                          style: TextStyle(color: _activeTab == 1 ? const Color(0xFF2563EB) : Colors.grey[400], fontWeight: FontWeight.bold)
                        )
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : currentList.isEmpty 
                ? Center(child: Text('No hay candidatos en esta sección', style: TextStyle(color: Colors.grey[400])))
                : ListView.separated(
                    padding: const EdgeInsets.all(24),
                    itemCount: currentList.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final c = currentList[index];
                      final bool isMatch = c['isMatch'] ?? false;
                      final bool canContact = c['phone'] != null || c['whatsapp'] != null;

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
                                  color: Colors.grey[100],
                                  image: c['photo'] != null 
                                    ? DecorationImage(image: MemoryImage(base64Decode(c['photo'])), fit: BoxFit.cover)
                                    : null,
                                ),
                                child: c['photo'] == null ? const Icon(LucideIcons.user, color: Colors.grey) : null,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(c['name'] ?? 'Candidato', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A)), maxLines: 1, overflow: TextOverflow.ellipsis),
                                    Text(c['role'] ?? 'Sin rol', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF2563EB))),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(LucideIcons.mapPin, size: 10, color: Colors.grey[400]),
                                        const SizedBox(width: 4),
                                        Text(c['location'] ?? 'Ubicación oculta', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[500])),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(LucideIcons.clock, size: 10, color: Colors.grey[400]),
                                        const SizedBox(width: 4),
                                        Text('Disponible', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[500])),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              if (canContact)
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (c['phone'] != null)
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
                                    if (c['whatsapp'] != null)
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
                              else
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Icon(LucideIcons.clock, size: 16, color: Colors.orange[400]),
                                    const SizedBox(height: 4),
                                    Text(isMatch ? 'Cargando...' : 'Esperando\nRespuesta', textAlign: TextAlign.right, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange[400])),
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
