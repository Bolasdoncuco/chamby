import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../models/candidate.dart';
import '../../models/vacancy.dart';
import '../../services/api_service.dart';
import '../../services/employer_service.dart';
import '../../utils/api_error.dart';

class VacancyCandidatesScreen extends StatefulWidget {
  const VacancyCandidatesScreen({super.key, this.vacancy, this.gateway, this.onBack});
  final Vacancy? vacancy;
  final EmployerGateway? gateway;
  final VoidCallback? onBack;

  @override
  State<VacancyCandidatesScreen> createState() => _VacancyCandidatesScreenState();
}

class _VacancyCandidatesScreenState extends State<VacancyCandidatesScreen> {
  VacancyCandidates _groups = const VacancyCandidates();
  String? _error;
  bool _loading = true;
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final vacancy = widget.vacancy;
    if (vacancy == null) {
      setState(() { _loading = false; _error = 'Selecciona una vacante para ver sus candidatos.'; });
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final groups = await (widget.gateway ?? ApiEmployerGateway(ApiService.client)).loadCandidates(vacancy.id);
      if (mounted) setState(() { _groups = groups; _loading = false; });
    } catch (error) {
      final message = error is ApiError
          ? error.message
          : 'No fue posible cargar los candidatos. Inténtalo nuevamente.';
      if (mounted) setState(() { _error = message; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.vacancy?.title ?? 'Vacante';
    final candidates = [_groups.matches, _groups.preApproved, _groups.applied][_tab];
    return Material(
      color: Colors.transparent,
      child: Column(
        children: [
        ListTile(
          leading: Semantics(label: 'Regresar al dashboard', button: true, child: IconButton(tooltip: 'Regresar al dashboard', icon: const Icon(LucideIcons.arrowLeft), onPressed: widget.onBack ?? () => Navigator.maybePop(context))),
          title: const Text('Candidatos', style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(title),
        ),
        if (!_loading && _error == null)
          Row(children: [
            _Tab(label: 'Ver seleccionados', text: 'Seleccionados', selected: _tab == 0, onTap: () => setState(() => _tab = 0)),
            _Tab(label: 'Ver preaprobados', text: 'Preaprobados', selected: _tab == 1, onTap: () => setState(() => _tab = 1)),
            _Tab(label: 'Ver interesados', text: 'Interesados', selected: _tab == 2, onTap: () => setState(() => _tab = 2)),
          ]),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator(semanticsLabel: 'Cargando candidatos'))
              : _error != null
                  ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Text(_error!, textAlign: TextAlign.center), const SizedBox(height: 12), OutlinedButton(onPressed: _load, child: const Text('Reintentar'))]))
                  : candidates.isEmpty
                      ? const Center(child: Text('No hay candidatos en esta sección.'))
                      : ListView.builder(padding: const EdgeInsets.all(20), itemCount: candidates.length, itemBuilder: (_, i) => _CandidateTile(candidate: candidates[i])),
        ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({required this.label, required this.text, required this.selected, required this.onTap});
  final String label;
  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(child: Semantics(label: label, button: true, selected: selected, child: TextButton(onPressed: onTap, child: Text(text))));
}

class _CandidateTile extends StatelessWidget {
  const _CandidateTile({required this.candidate});
  final Candidate candidate;

  @override
  Widget build(BuildContext context) => Card(child: ListTile(
        leading: const CircleAvatar(child: Icon(LucideIcons.user)),
        title: Text(candidate.name ?? '${candidate.firstName ?? ''} ${candidate.lastName ?? ''}'.trim()),
        subtitle: Text(candidate.role ?? 'Perfil de candidato'),
        trailing: candidate.isMatch == true ? const Icon(Icons.check_circle, semanticLabel: 'Match') : null,
      ));
}
