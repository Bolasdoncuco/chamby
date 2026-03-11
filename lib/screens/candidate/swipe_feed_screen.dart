import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

final List<Map<String, dynamic>> mockCandidates = [
  {
    'id': 1,
    'name': 'Alex, 22',
    'role': 'Barista / Cajero',
    'experience': '2 años',
    'location': 'Centro',
    'availability': 'Tiempo completo',
    'tags': ['Dinámico', 'Arte Latte', 'Sistemas POS'],
    'videoPlaceholder': 'https://picsum.photos/seed/alex/400/600',
    'bio': 'Barista energético buscando un ambiente de café concurrido. ¡Prospero bajo presión!'
  },
  {
    'id': 2,
    'name': 'Sarah, 25',
    'role': 'Asesora de Ventas',
    'experience': '3 años',
    'location': 'Zona Norte',
    'availability': 'Medio tiempo',
    'tags': ['Servicio al Cliente', 'Visual Merchandising', 'Bilingüe'],
    'videoPlaceholder': 'https://picsum.photos/seed/sarah/400/600',
    'bio': 'Asesora de ventas amable y accesible con facilidad para las ventas.'
  },
  {
    'id': 3,
    'name': 'Mike, 20',
    'role': 'Mesero / Server',
    'experience': '1 año',
    'location': 'Distrito Gastronómico',
    'availability': 'Flexible',
    'tags': ['Trabajo en Equipo', 'Alto Volumen', 'Seguridad Alimentaria'],
    'videoPlaceholder': 'https://picsum.photos/seed/mike/400/600',
    'bio': 'Rápido y siempre sonriente. Listo para unirme a un equipo dinámico.'
  }
];

final List<Map<String, dynamic>> mockJobs = [
  {
    'id': 101,
    'name': 'Café Central',
    'role': 'Barista Principal',
    'experience': '1+ año',
    'location': 'Centro Histórico',
    'availability': 'Mañana/Tarde',
    'tags': ['Sueldo Base + Propinas', 'Seguro Médico', 'Capacitación'],
    'videoPlaceholder': 'https://picsum.photos/seed/cafe/400/600',
    'bio': 'Buscamos un barista apasionado para unirse a nuestra familia. Ambiente vibrante y el mejor café de la ciudad.'
  },
  {
    'id': 102,
    'name': 'Moda Urbana',
    'role': 'Vendedor de Tienda',
    'experience': 'Sin experiencia',
    'location': 'Centro Comercial',
    'availability': 'Fines de semana',
    'tags': ['Comisiones', 'Descuento Empleado', 'Crecimiento'],
    'videoPlaceholder': 'https://picsum.photos/seed/fashion/400/600',
    'bio': '¿Te apasiona la moda? Únete a nuestro equipo de ventas. Buscamos gente con actitud y ganas de aprender.'
  },
  {
    'id': 103,
    'name': 'Restaurante El Faro',
    'role': 'Ayudante de Cocina',
    'experience': '6 meses',
    'location': 'Puerto Madero',
    'availability': 'Turno Noche',
    'tags': ['Comida incluida', 'Transporte', 'Bonos'],
    'videoPlaceholder': 'https://picsum.photos/seed/kitchen/400/600',
    'bio': 'Equipo de cocina profesional busca ayudante comprometido. Oportunidad de aprender de los mejores chefs.'
  }
];

class SwipeFeedScreen extends StatefulWidget {
  const SwipeFeedScreen({super.key});

  @override
  State<SwipeFeedScreen> createState() => _SwipeFeedScreenState();
}

class _SwipeFeedScreenState extends State<SwipeFeedScreen> {
  final CardSwiperController controller = CardSwiperController();
  List<Map<String, dynamic>> _cards = [];

  @override
  void initState() {
    super.initState();
    // Delay setting cards so we can read context
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initCards();
    });
  }

  void _initCards() {
    final authProvider = context.read<AuthProvider>();
    setState(() {
      _cards = List.from(authProvider.userRole == UserRole.employer ? mockCandidates : mockJobs);
    });
  }

  bool _onSwipe(int previousIndex, int? currentIndex, CardSwiperDirection direction) {
    if (direction == CardSwiperDirection.right) {
       final swipedUser = _cards[previousIndex];
       Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            context.read<AuthProvider>().setMatchedUser(swipedUser);
          }
       });
    }
    return true;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cards.isEmpty) return const Center(child: CircularProgressIndicator());

    final authProvider = context.watch<AuthProvider>();
    final isEmployer = authProvider.userRole == UserRole.employer;

    return Container(
      color: Colors.grey[50], // slate-50
      padding: const EdgeInsets.all(16.0),
      child: CardSwiper(
        controller: controller,
        cardsCount: _cards.length,
        onSwipe: _onSwipe,
        padding: EdgeInsets.zero,
        numberOfCardsDisplayed: 2, // Match the visual depth
        backCardOffset: const Offset(0, 20),
        cardBuilder: (context, index, horizontalThresholdPercentage, verticalThresholdPercentage) {
           return _CardView(item: _cards[index], isEmployer: isEmployer, controller: controller);
        },
        // Custom empty builder
        onEnd: () {
          // You could return a Widget here in a newer version or wrap CardSwiper if it doesn't support emptyBuilder directly well.
          // Since CardSwiper usually disappears when empty, we rely on state if needed.
        },
      ),
    );
  }
}

class _CardView extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isEmployer;
  final CardSwiperController controller;

  const _CardView({required this.item, required this.isEmployer, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ]
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Top Image/Video Section
          Expanded(
            flex: 6,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  item['videoPlaceholder'],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[300]),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.9),
                        Colors.black.withOpacity(0.2),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    )
                  ),
                ),
                Positioned(
                  bottom: 24, left: 24, right: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(item['name'], style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                          const SizedBox(width: 8),
                          Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF34D399), shape: BoxShape.circle)), // emerald-400
                        ],
                      ),
                      Text(item['role'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[100])),
                    ],
                  ),
                ),
                 Positioned(
                  top: 16, right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Text(
                      isEmployer ? 'PITCH 15S' : 'VACANTE',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                    ),
                  ),
                )
              ],
            ),
          ),
          
          // Bottom Details Section
          Expanded(
            flex: 4,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tags
                   Wrap(
                    spacing: 8, runSpacing: 8,
                    children: (item['tags'] as List).map((tag) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF), // blue-50
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(tag, style: const TextStyle(color: Color(0xFF1D4ED8), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)), // blue-700
                    )).toList(),
                  ),
                  const SizedBox(height: 16),
                  
                  // Location & Availability
                  Row(
                    children: [
                      const Icon(LucideIcons.mapPin, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(item['location'], style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(LucideIcons.clock, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(item['availability'], style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold)),
                    ],
                  ),
                  
                  const Spacer(),
                  
                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _ActionButton(
                        icon: LucideIcons.x,
                        color: Colors.grey[400]!,
                        backgroundColor: Colors.white,
                        borderColor: Colors.grey[200],
                        onTap: () => controller.swipe(CardSwiperDirection.left),
                      ),
                      const SizedBox(width: 32),
                      _ActionButton(
                        icon: LucideIcons.heart,
                        color: Colors.white,
                        backgroundColor: const Color(0xFF2563EB), // blue-600
                        onTap: () => controller.swipe(CardSwiperDirection.right),
                      ),
                    ],
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

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final Color? borderColor;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.color, required this.backgroundColor, this.borderColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56, height: 56, // 14 * 4
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          border: borderColor != null ? Border.all(color: borderColor!) : null,
          boxShadow: [
             BoxShadow(color: backgroundColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }
}
