import 'package:flutter/foundation.dart';

import '../models/vacancy.dart';
import '../services/employer_service.dart';
import '../utils/api_error.dart';

enum EmployerListState { loading, ready, empty, error }

class EmployerVacanciesProvider extends ChangeNotifier {
  EmployerVacanciesProvider(this.gateway);

  final EmployerGateway gateway;
  EmployerListState _state = EmployerListState.loading;
  List<Vacancy> _vacancies = const [];
  String? _errorMessage;
  bool _isLoading = false;

  EmployerListState get state => _state;
  List<Vacancy> get vacancies => _vacancies;
  String? get errorMessage => _errorMessage;

  Future<void> load() async {
    if (_isLoading) return;
    _isLoading = true;
    _state = EmployerListState.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      _vacancies = await gateway.loadVacancies();
      _state = _vacancies.isEmpty ? EmployerListState.empty : EmployerListState.ready;
    } catch (error) {
      _state = EmployerListState.error;
      _errorMessage = _safeMessage(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  static String _safeMessage(Object error) => error is ApiError
      ? error.message
      : 'No fue posible cargar tus vacantes. Inténtalo nuevamente.';
}

class EmployerVacancyFormProvider extends ChangeNotifier {
  EmployerVacancyFormProvider(this.gateway);

  final EmployerGateway gateway;
  bool _isSubmitting = false;
  String? _errorMessage;
  String? _successMessage;
  Map<String, String> _validationErrors = const {};

  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  Map<String, String> get validationErrors => _validationErrors;

  Future<bool> submit(VacancyDraft draft, {String? vacancyId}) async {
    if (_isSubmitting) return false;
    _validationErrors = _validate(draft);
    _errorMessage = null;
    _successMessage = null;
    if (_validationErrors.isNotEmpty) {
      notifyListeners();
      return false;
    }
    _isSubmitting = true;
    notifyListeners();
    try {
      if (vacancyId == null) {
        await gateway.createVacancy(draft);
        _successMessage = 'Vacante publicada correctamente.';
      } else {
        await gateway.updateVacancy(vacancyId: vacancyId, draft: draft);
        _successMessage = 'Vacante actualizada correctamente.';
      }
      return true;
    } catch (error) {
      _errorMessage = error is ApiError ? error.message : 'No fue posible guardar la vacante. Inténtalo nuevamente.';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  static Map<String, String> _validate(VacancyDraft draft) {
    final errors = <String, String>{};
    if (draft.title.trim().isEmpty) errors['title'] = 'El título de la vacante es obligatorio.';
    if (draft.description.trim().isEmpty) errors['description'] = 'La descripción de la vacante es obligatoria.';
    final salary = double.tryParse(draft.salary.trim());
    if (salary == null || !salary.isFinite || salary <= 0) errors['salary'] = 'El sueldo debe ser un número mayor a cero.';
    return errors;
  }
}
