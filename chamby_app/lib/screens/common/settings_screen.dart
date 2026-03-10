import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isEmployer = authProvider.userRole == UserRole.employer;

    return Container(
      color: Colors.grey[50], // slate-50
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
                   // Flutter back arrow is typically not mirrored, but we match the React icon
                  icon: const Icon(LucideIcons.chevronLeft, color: Colors.grey, size: 28),
                  onPressed: () => authProvider.setCurrentView(isEmployer ? CurrentView.dashboard : CurrentView.feed),
                ),
                const SizedBox(width: 8),
                const Text('Configuración', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))), // slate-900
              ],
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Profile Mini Card
                  Container(
                    margin: const EdgeInsets.only(bottom: 32),
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
                            color: const Color(0xFFDBEAFE), // blue-100
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(isEmployer ? LucideIcons.briefcase : LucideIcons.user, color: const Color(0xFF2563EB), size: 32),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Alex Chamby', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F172A))),
                            Text(isEmployer ? 'Empresa Verificada' : 'Candidato Premium', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                          ],
                        )
                      ],
                    ),
                  ),

                  // Sections
                  _SettingsSection(
                    title: 'Cuenta',
                    items: [
                      _SettingsItem(id: 'profile', label: 'Editar Perfil', icon: LucideIcons.user, action: () => authProvider.setCurrentView(CurrentView.profile)), // Route to profile on edit for now
                      _SettingsItem(id: 'notifications', label: 'Notificaciones', icon: LucideIcons.bell),
                      _SettingsItem(id: 'privacy', label: 'Privacidad y Seguridad', icon: LucideIcons.shield),
                    ],
                  ),
                  
                  _SettingsSection(
                    title: 'Preferencias',
                    items: [
                      _SettingsItem(id: 'theme', label: 'Modo Oscuro', icon: LucideIcons.moon, isToggle: true),
                      _SettingsItem(id: 'language', label: 'Idioma', icon: LucideIcons.globe, value: 'Español'),
                    ],
                  ),

                  _SettingsSection(
                    title: 'Soporte',
                    items: [
                      _SettingsItem(id: 'help', label: 'Centro de Ayuda', icon: LucideIcons.helpCircle),
                      _SettingsItem(id: 'about', label: 'Acerca de Chamby', icon: LucideIcons.settings),
                    ],
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => authProvider.handleLogout(),
                      icon: const Icon(LucideIcons.logOut, size: 20),
                      label: const Text('Cerrar Sesión', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[50],
                        foregroundColor: Colors.red[600],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _SettingsItem {
  final String id;
  final String label;
  final IconData icon;
  final VoidCallback? action;
  final bool isToggle;
  final String? value;

  _SettingsItem({required this.id, required this.label, required this.icon, this.action, this.isToggle = false, this.value});
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<_SettingsItem> items;

  const _SettingsSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[400], letterSpacing: 1.2),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey[100]!),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: items.map((item) {
               final isLast = items.indexOf(item) == items.length - 1;
               return Container(
                 decoration: BoxDecoration(
                   border: isLast ? null : Border(bottom: BorderSide(color: Colors.grey[50]!)),
                 ),
                 child: Material(
                   color: Colors.transparent,
                   child: InkWell(
                     onTap: item.action ?? () {},
                     child: Padding(
                       padding: const EdgeInsets.all(16.0),
                       child: Row(
                         children: [
                           Container(
                             width: 40, height: 40,
                             decoration: BoxDecoration(
                               color: Colors.grey[50],
                               borderRadius: BorderRadius.circular(12),
                             ),
                             child: Icon(item.icon, size: 20, color: Colors.grey[400]),
                           ),
                           const SizedBox(width: 16),
                           Expanded(
                             child: Text(item.label, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF334155))), // slate-700
                           ),
                           if (item.value != null)
                             Text(item.value!, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[400])),
                           if (item.value != null) const SizedBox(width: 8),
                           if (item.isToggle)
                             Container(
                               width: 40, height: 20,
                               decoration: BoxDecoration(
                                 color: Colors.grey[200],
                                 borderRadius: BorderRadius.circular(10),
                               ),
                               padding: const EdgeInsets.all(2),
                               alignment: Alignment.centerLeft, // Off state visually
                               child: Container(
                                 width: 16, height: 16,
                                 decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                               ),
                             )
                           else
                             Icon(LucideIcons.chevronRight, size: 18, color: Colors.grey[300]),
                         ],
                       ),
                     ),
                   ),
                 ),
               );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
