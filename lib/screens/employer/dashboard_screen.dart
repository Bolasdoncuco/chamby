import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';

class EmployerDashboardScreen extends StatefulWidget {
  const EmployerDashboardScreen({super.key});

  @override
  State<EmployerDashboardScreen> createState() => _EmployerDashboardScreenState();
}

class _EmployerDashboardScreenState extends State<EmployerDashboardScreen> {
  List<Map<String, dynamic>> _vacancies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVacancies();
  }

  Future<void> _loadVacancies() async {
    try {
      final response = await ApiService.get('/employers/vacancies');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _vacancies = List<Map<String, dynamic>>.from(data['vacancies'] ?? []);
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[50], // slate-50
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Mis Vacantes', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))), // slate-900
                    Text('Gestiona tus ofertas activas', style: TextStyle(fontSize: 14, color: Colors.grey[500])),
                  ],
                ),
                ElevatedButton(
                  onPressed: () => context.read<AuthProvider>().setCurrentView(CurrentView.create),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB), // blue-600
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.all(16),
                    minimumSize: const Size(56, 56), // w-12 h-12
                    elevation: 4,
                  ),
                  child: const Icon(LucideIcons.plus, size: 24),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _vacancies.isEmpty 
                ? const Center(child: Text('No has publicado ninguna vacante.', style: TextStyle(color: Colors.grey)))
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    itemCount: _vacancies.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return _VacancyCard(vacancy: _vacancies[index]);
                    },
                  ),
          )
        ],
      ),
    );
  }
}

class _VacancyCard extends StatelessWidget {
  final Map<String, dynamic> vacancy;

  const _VacancyCard({required this.vacancy});

  @override
  Widget build(BuildContext context) {
    final isActive = vacancy['isActive'] == true;
    final title = vacancy['title'] ?? 'Sin título';
    final salary = vacancy['salaryMin'] ?? 0;
    // En el futuro puedes añadir conteo real de backend
    final int matches = 0;
    final int views = 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: isActive ? Colors.green[50] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  LucideIcons.briefcase, 
                  color: isActive ? Colors.green[600] : Colors.grey[400],
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A))),
                    Text('\$${salary.toStringAsFixed(0)} / mes', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF2563EB))),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(LucideIcons.edit2, size: 20, color: Colors.grey),
                onPressed: () => context.read<AuthProvider>().setSelectedVacancy(vacancy, CurrentView.editVacancy),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey[50]!)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatItem(label: 'Matches', value: matches.toString(), icon: LucideIcons.users, iconColor: Colors.blue[500]!),
                Container(width: 1, height: 32, color: Colors.grey[50]),
                _StatItem(label: 'Vistas', value: views.toString(), icon: LucideIcons.eye, iconColor: Colors.grey[400]!),
                Container(width: 1, height: 32, color: Colors.grey[50]),
                Column(
                  children: [
                    Text('ESTADO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[400])),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(isActive ? LucideIcons.checkCircle2 : LucideIcons.pauseCircle, size: 12, color: isActive ? Colors.green[600] : Colors.grey[400]),
                        const SizedBox(width: 4),
                        Text(
                          isActive ? 'ACTIVA' : 'PAUSADA', 
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isActive ? Colors.green[600] : Colors.grey[400]),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => context.read<AuthProvider>().setSelectedVacancy(vacancy, CurrentView.candidates),
               style: TextButton.styleFrom(
                 backgroundColor: Colors.grey[50], // slate-50
                 foregroundColor: Colors.grey[600], // slate-600
                 padding: const EdgeInsets.symmetric(vertical: 12),
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
               ),
              child: const Text('Ver Candidatos', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _StatItem({required this.label, required this.value, required this.icon, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[400])),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(icon, size: 14, color: iconColor),
            const SizedBox(width: 4),
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          ],
        ),
      ],
    );
  }
}
