import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../models/vacancy.dart';
import '../../providers/auth_provider.dart';
import '../../providers/employer_provider.dart';
import '../../services/api_service.dart';
import '../../services/employer_service.dart';
import '../../widgets/common/app_state_view.dart';

class EmployerDashboardScreen extends StatefulWidget {
  const EmployerDashboardScreen({super.key, this.gateway});

  final EmployerGateway? gateway;

  @override
  State<EmployerDashboardScreen> createState() => _EmployerDashboardScreenState();
}

class _EmployerDashboardScreenState extends State<EmployerDashboardScreen> {
  late final EmployerVacanciesProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = EmployerVacanciesProvider(widget.gateway ?? ApiEmployerGateway(ApiService.client));
    _provider.load();
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _provider,
        builder: (context, _) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Mis vacantes', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('Gestiona tus ofertas activas'),
                      ],
                    ),
                  ),
                  Semantics(
                    label: 'Crear vacante',
                    button: true,
                    child: FloatingActionButton(
                      heroTag: 'crear-vacante',
                      onPressed: () => context.read<AuthProvider>().setCurrentView(CurrentView.create),
                      child: const Icon(LucideIcons.plus),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _body(context)),
          ],
        ),
      );

  Widget _body(BuildContext context) {
    switch (_provider.state) {
      case EmployerListState.loading:
        return const AppStateView.loading(label: 'Cargando vacantes');
      case EmployerListState.error:
        return _MessageState(
          message: _provider.errorMessage ?? 'No fue posible cargar tus vacantes.',
          actionLabel: 'Reintentar',
          onAction: _provider.load,
        );
      case EmployerListState.empty:
        return const AppStateView.empty(message: 'No has publicado ninguna vacante.');
      case EmployerListState.ready:
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          itemCount: _provider.vacancies.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) => _VacancyCard(vacancy: _provider.vacancies[index]),
        );
    }
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({required this.message, this.actionLabel, this.onAction});
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message, textAlign: TextAlign.center),
              if (actionLabel != null) ...[
                const SizedBox(height: 16),
                Semantics(
                  button: true,
                  label: actionLabel,
                  child: OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
                ),
              ],
            ],
          ),
        ),
      );
}

class _VacancyCard extends StatelessWidget {
  const _VacancyCard({required this.vacancy});
  final Vacancy vacancy;

  @override
  Widget build(BuildContext context) {
    final title = vacancy.title?.trim().isNotEmpty == true ? vacancy.title! : 'Sin título';
    final salary = vacancy.salaryMin == null ? 'Sueldo no especificado' : '\$${vacancy.salaryMin!.toStringAsFixed(0)} / mes';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(LucideIcons.briefcase, semanticLabel: 'Vacante'),
              const SizedBox(width: 12),
              Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17))),
              Semantics(
                label: 'Editar vacante $title',
                button: true,
                child: IconButton(
                  tooltip: 'Editar vacante',
                  icon: const Icon(LucideIcons.edit2),
                  onPressed: () => context.read<AuthProvider>().setSelectedVacancy(vacancy, CurrentView.editVacancy),
                ),
              ),
            ]),
            const SizedBox(height: 8),
            Text(salary),
            const SizedBox(height: 12),
            Text(vacancy.isActive == false ? 'Pausada' : 'Activa'),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: Semantics(
                button: true,
                label: 'Ver candidatos de $title',
                child: OutlinedButton(
                  onPressed: () => context.read<AuthProvider>().setSelectedVacancy(vacancy, CurrentView.candidates),
                  child: const Text('Ver candidatos'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
