import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/vacancy.dart';
import '../../providers/auth_provider.dart';
import '../../providers/employer_provider.dart';
import '../../services/api_service.dart';
import '../../services/employer_service.dart';

class JobCreationScreen extends StatefulWidget {
  const JobCreationScreen({super.key, this.gateway});
  final EmployerGateway? gateway;

  @override
  State<JobCreationScreen> createState() => _JobCreationScreenState();
}

class _JobCreationScreenState extends State<JobCreationScreen> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _salary = TextEditingController();
  final _location = TextEditingController();
  late final EmployerVacancyFormProvider _provider;
  Vacancy? _editing;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _provider = EmployerVacancyFormProvider(widget.gateway ?? ApiEmployerGateway(ApiService.client));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final selected = context.read<AuthProvider>().selectedVacancy;
    if (selected is Vacancy) {
      _editing = selected;
      _title.text = selected.title ?? '';
      _description.text = selected.description ?? '';
      if (selected.salaryMin != null) _salary.text = selected.salaryMin!.toStringAsFixed(0);
      _location.text = selected.availabilityTarget ?? '';
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _salary.dispose();
    _location.dispose();
    _provider.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final success = await _provider.submit(VacancyDraft(
      title: _title.text,
      description: _description.text,
      salary: _salary.text,
      availabilityTarget: _location.text,
    ), vacancyId: _editing?.id);
    if (!mounted || !success) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_provider.successMessage!)));
    context.read<AuthProvider>().setCurrentView(CurrentView.dashboard);
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _provider,
        builder: (context, _) => Column(
          children: [
            ListTile(
              leading: Semantics(label: 'Cancelar y regresar', button: true, child: IconButton(icon: const Icon(Icons.close), onPressed: () => context.read<AuthProvider>().setCurrentView(CurrentView.dashboard))),
              title: Text(_editing == null ? 'Crear vacante' : 'Editar vacante', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Column(children: [
              _field('Título de la vacante', _title, 'title', 'Ej. Cajero'),
              _field('Descripción', _description, 'description', 'Describe las actividades', maxLines: 4),
              _field('Sueldo mensual', _salary, 'salary', 'Ej. 8000', keyboardType: TextInputType.number),
              _field('Ubicación o disponibilidad', _location, null, 'Ej. Tiempo completo'),
              const SizedBox(height: 24),
              SizedBox(width: double.infinity, child: Semantics(button: true, label: _provider.isSubmitting ? 'Guardando vacante' : 'Guardar vacante', child: ElevatedButton(onPressed: _provider.isSubmitting ? null : _submit, child: Text(_provider.isSubmitting ? 'Guardando…' : 'Guardar vacante')))),
              if (_provider.errorMessage != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(_provider.errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error))),
            ]))),
          ],
        ),
      );

  Widget _field(String label, TextEditingController controller, String? errorKey, String hint, {int maxLines = 1, TextInputType? keyboardType}) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(labelText: label, hintText: hint, errorText: errorKey == null ? null : _provider.validationErrors[errorKey], border: const OutlineInputBorder()),
        ),
      );
}
