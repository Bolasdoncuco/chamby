import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class JobCreationScreen extends StatefulWidget {
  const JobCreationScreen({super.key});

  @override
  State<JobCreationScreen> createState() => _JobCreationScreenState();
}

class _JobCreationScreenState extends State<JobCreationScreen> {
  final List<String> _tags = [];
  final _tagController = TextEditingController();
  final List<String> _benefits = [];

  final List<Map<String, dynamic>> _benefitOptions = [
    {'id': 'seguro', 'label': 'Seguro Social', 'icon': '🏥'},
    {'id': 'comida', 'label': 'Comida Incluida', 'icon': '🍱'},
    {'id': 'transporte', 'label': 'Transporte', 'icon': '🚌'},
    {'id': 'bonos', 'label': 'Bonos', 'icon': '💰'},
  ];

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _toggleBenefit(String id) {
    setState(() {
      if (_benefits.contains(id)) {
        _benefits.remove(id);
      } else {
        _benefits.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDBEAFE), // blue-100
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(LucideIcons.briefcase, color: Color(0xFF2563EB)), // blue-600
                    ),
                    const SizedBox(width: 12),
                    const Text('Nueva Vacante', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))), // slate-900
                  ],
                ),
                IconButton(
                  icon: const Icon(LucideIcons.x, color: Colors.grey),
                  onPressed: () => context.read<AuthProvider>().setCurrentView(CurrentView.dashboard),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InputLabel('Título del Puesto'),
                  _CustomTextField(hintText: 'Ej. Cajero Turno Vespertino'),
                  const SizedBox(height: 16),

                  _InputLabel('Sueldo Ofertado'),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _CustomTextField(hintText: 'Ej. 8000', icon: LucideIcons.dollarSign, keyboardType: TextInputType.number),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: 'mensual',
                              items: const [
                                DropdownMenuItem(value: 'mensual', child: Text('Mensual', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
                                DropdownMenuItem(value: 'quincenal', child: Text('Quincenal', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
                                DropdownMenuItem(value: 'semanal', child: Text('Semanal', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
                              ],
                              onChanged: (val) {},
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  _InputLabel('Ubicación del Puesto'),
                  Container(
                    height: 128,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(LucideIcons.map, size: 32, color: Colors.grey[400]),
                            const SizedBox(height: 4),
                            Text('PINPOINT EN MAPA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[400])),
                          ],
                        ),
                        Icon(LucideIcons.mapPin, size: 32, color: Colors.red.withOpacity(0.5)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  _CustomTextField(hintText: 'Dirección exacta', isWhite: true),
                  const SizedBox(height: 24),

                  _InputLabel('Requisitos (Skills)'),
                  Row(
                    children: [
                      Expanded(
                        child: _CustomTextField(
                          controller: _tagController,
                          hintText: 'Ej. Atención al cliente',
                          onSubmitted: (_) => _addTag(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(LucideIcons.plus, color: Colors.white),
                          onPressed: _addTag,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: _tags.map((tag) => Chip(
                      label: Text(tag, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2563EB), fontSize: 12)),
                      backgroundColor: const Color(0xFFEFF6FF),
                      deleteIcon: const Icon(LucideIcons.trash2, size: 14, color: Color(0xFF2563EB)),
                      onDeleted: () => setState(() => _tags.remove(tag)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide.none),
                    )).toList(),
                  ),
                  const SizedBox(height: 24),

                  _InputLabel('Beneficios'),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 3,
                    children: _benefitOptions.map((opt) {
                      final isSelected = _benefits.contains(opt['id']);
                      return GestureDetector(
                        onTap: () => _toggleBenefit(opt['id']),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.green[50] : Colors.grey[50],
                            border: Border.all(color: isSelected ? Colors.green[500]! : Colors.grey[100]!),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Text(opt['icon'], style: const TextStyle(fontSize: 18)),
                              const SizedBox(width: 8),
                              Expanded(child: Text(opt['label'], style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isSelected ? Colors.green[700] : Colors.grey[500]))),
                              if (isSelected) const Icon(LucideIcons.checkCircle2, size: 14, color: Colors.green),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  _InputLabel('Galería del Lugar'),
                  SizedBox(
                    height: 100,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                         Container(
                           width: 100,
                           margin: const EdgeInsets.only(right: 12),
                           decoration: BoxDecoration(
                             color: Colors.grey[100],
                             borderRadius: BorderRadius.circular(16),
                             border: Border.all(color: Colors.grey[300]!, width: 2),
                           ),
                           child: Column(
                             mainAxisAlignment: MainAxisAlignment.center,
                             children: [
                               Icon(LucideIcons.plus, color: Colors.grey[400]),
                               Text('AÑADIR FOTO', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.grey[400])),
                             ],
                           ),
                         ),
                         for (var i in [1, 2])
                           Container(
                             width: 100,
                             margin: const EdgeInsets.only(right: 12),
                             decoration: BoxDecoration(
                               color: Colors.grey[200],
                               borderRadius: BorderRadius.circular(16),
                               image: DecorationImage(image: NetworkImage('https://picsum.photos/seed/office$i/200/200'), fit: BoxFit.cover),
                             ),
                           ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.read<AuthProvider>().setCurrentView(CurrentView.dashboard),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 8,
                        shadowColor: const Color(0xFFBFDBFE),
                      ),
                      child: const Text('Publicar Vacante', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _InputLabel extends StatelessWidget {
  final String text;
  const _InputLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[500]),
      ),
    );
  }
}

class _CustomTextField extends StatelessWidget {
  final String hintText;
  final IconData? icon;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final Function(String)? onSubmitted;
  final bool isWhite;

  const _CustomTextField({required this.hintText, this.icon, this.keyboardType, this.controller, this.onSubmitted, this.isWhite = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isWhite ? Colors.white : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: icon != null ? Icon(icon, color: Colors.grey[400], size: 18) : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
