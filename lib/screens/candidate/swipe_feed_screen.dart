import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../models/vacancy.dart';
import '../../providers/auth_provider.dart';
import '../../providers/candidate_feed_provider.dart';
import '../../services/candidate_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/app_state_view.dart';

class SwipeFeedScreen extends StatefulWidget {
  const SwipeFeedScreen({super.key, CandidateGateway? gateway})
    : _gateway = gateway;

  final CandidateGateway? _gateway;

  @override
  State<SwipeFeedScreen> createState() => _SwipeFeedScreenState();
}

class _SwipeFeedScreenState extends State<SwipeFeedScreen> {
  late final CandidateFeedProvider _feed;

  @override
  void initState() {
    super.initState();
    _feed = CandidateFeedProvider(widget._gateway ?? ApiCandidateGateway())
      ..load();
  }

  @override
  void dispose() {
    _feed.dispose();
    super.dispose();
  }

  Future<void> _decide(bool isLike) async {
    final vacancy = _feed.currentVacancy;
    final match = await _feed.decideCurrent(isLike: isLike);
    if (!mounted || match == null) return;
    if (match.isMatch && vacancy != null) {
      context.read<AuthProvider>().setMatchedUser(vacancy);
    }
  }

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider.value(
    value: _feed,
    child: Consumer<CandidateFeedProvider>(
      builder: (context, feed, _) => switch (feed.state) {
        CandidateFeedState.loading => const AppStateView.loading(),
        CandidateFeedState.error => AppStateView.error(
          message: feed.errorMessage ?? 'No fue posible cargar las vacantes.',
          onRetry: feed.load,
        ),
        CandidateFeedState.empty => _FeedMessage(
          message: 'No hay vacantes nuevas por ahora. Vuelve más tarde.',
          onRetry: feed.load,
        ),
        CandidateFeedState.ready => _FeedContent(
          vacancy: feed.currentVacancy!,
          isSubmitting: feed.isSubmitting,
          errorMessage: feed.errorMessage,
          onDecision: _decide,
        ),
      },
    ),
  );
}

class _FeedContent extends StatelessWidget {
  const _FeedContent({
    required this.vacancy,
    required this.isSubmitting,
    required this.onDecision,
    this.errorMessage,
  });

  final Vacancy vacancy;
  final bool isSubmitting;
  final String? errorMessage;
  final ValueChanged<bool> onDecision;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Vacantes para ti',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.slate900,
          ),
        ),
        const SizedBox(height: 4),
        const Text('Descarta o indica que te interesa una vacante.'),
        const SizedBox(height: 20),
        _VacancyCard(vacancy: vacancy),
        if (errorMessage != null) ...[
          const SizedBox(height: 12),
          _DecisionError(message: errorMessage!),
        ],
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Semantics(
                button: true,
                label:
                    'Descartar vacante ${vacancy.title ?? vacancy.role ?? 'sin título'}',
                child: OutlinedButton.icon(
                  onPressed: isSubmitting ? null : () => onDecision(false),
                  icon: const Icon(LucideIcons.x),
                  label: const Text('Descartar'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Semantics(
                button: true,
                label:
                    'Me interesa vacante ${vacancy.title ?? vacancy.role ?? 'sin título'}',
                child: FilledButton.icon(
                  onPressed: isSubmitting ? null : () => onDecision(true),
                  icon: isSubmitting
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(LucideIcons.heart),
                  label: Text(isSubmitting ? 'Enviando…' : 'Me interesa'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _VacancyCard extends StatelessWidget {
  const _VacancyCard({required this.vacancy});
  final Vacancy vacancy;

  @override
  Widget build(BuildContext context) {
    final imageUrl = vacancy.images.isNotEmpty
        ? vacancy.images.first
        : vacancy.photoUrl;
    final title = vacancy.title ?? vacancy.role ?? 'Vacante disponible';
    final company = vacancy.name ?? vacancy.employer?.companyName ?? 'Empresa';
    final tags = vacancy.tags.isNotEmpty ? vacancy.tags : vacancy.requirements;
    return Semantics(
      label: 'Vacante $title en $company',
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(
              color: Color(0x110F172A),
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 190,
              width: double.infinity,
              child: imageUrl == null || imageUrl.isEmpty
                  ? const ColoredBox(
                      color: AppColors.secondaryBlue,
                      child: Center(
                        child: Icon(
                          LucideIcons.briefcase,
                          size: 56,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    )
                  : Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const ColoredBox(
                            color: AppColors.secondaryBlue,
                            child: Center(
                              child: Icon(
                                LucideIcons.imageOff,
                                size: 48,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    company,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.slate900,
                    ),
                  ),
                  if (vacancy.location != null ||
                      vacancy.availability != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      [
                        vacancy.location,
                        vacancy.availability,
                      ].whereType<String>().join(' · '),
                    ),
                  ],
                  if (vacancy.description != null &&
                      vacancy.description!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      vacancy.description!,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (tags.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: tags
                          .map((tag) => Chip(label: Text(tag)))
                          .toList(growable: false),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedMessage extends StatelessWidget {
  const _FeedMessage({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.briefcase, size: 44),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(LucideIcons.refreshCw),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    ),
  );
}

class _DecisionError extends StatelessWidget {
  const _DecisionError({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE4E6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(message),
    ),
  );
}
