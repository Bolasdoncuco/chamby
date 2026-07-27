import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AppStateView extends StatelessWidget {
  const AppStateView.loading({super.key, this.label = 'Cargando'})
      : message = null,
        onRetry = null,
        isEmpty = false;

  const AppStateView.empty({super.key, required this.message})
      : label = null,
        onRetry = null,
        isEmpty = true;

  const AppStateView.error({super.key, required this.message, required this.onRetry})
      : label = null,
        isEmpty = false;

  final String? label;
  final String? message;
  final VoidCallback? onRetry;
  final bool isEmpty;

  @override
  Widget build(BuildContext context) {
    if (label != null) {
      return Center(child: Semantics(label: label, liveRegion: true, child: const CircularProgressIndicator()));
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isEmpty ? LucideIcons.inbox : LucideIcons.alertCircle, size: 44),
            const SizedBox(height: 12),
            Semantics(liveRegion: true, child: Text(message!, textAlign: TextAlign.center)),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              Semantics(
                button: true,
                label: 'Reintentar',
                child: OutlinedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(LucideIcons.refreshCw),
                  label: const Text('Reintentar'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
