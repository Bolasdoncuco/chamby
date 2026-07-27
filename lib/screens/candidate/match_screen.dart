import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../models/vacancy.dart';

class MatchScreen extends StatelessWidget {
  const MatchScreen({super.key, this.user, required this.onContinue});

  final Object? user;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final vacancy = user is Vacancy ? user! as Vacancy : null;
    if (vacancy == null) {
      return Material(
        color: Colors.white,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  LucideIcons.heartOff,
                  size: 56,
                  color: Color(0xFF64748B),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Aún no tienes matches.',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Cuando una empresa comparta tu interés, aparecerá aquí.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                OutlinedButton(
                  onPressed: onContinue,
                  child: const Text('Explorar vacantes'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    final employer =
        vacancy.name ?? vacancy.employer?.companyName ?? 'la empresa';
    final position = vacancy.title ?? vacancy.role ?? 'esta vacante';
    return Container(
      color: const Color(0xFF1D4ED8),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.sparkles, color: Colors.white, size: 72),
                const SizedBox(height: 24),
                const Text(
                  '¡Hicieron match!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Tu interés por $position coincide con el de $employer.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Color(0xFFDBEAFE),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'La empresa podrá consultar tu información de contacto desde sus candidatos conectados.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFFDBEAFE)),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: onContinue,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF1D4ED8),
                      minimumSize: const Size.fromHeight(52),
                    ),
                    child: const Text('Seguir explorando'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
