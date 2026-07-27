import 'dart:convert';

import 'package:dio/dio.dart';

import '../models/candidate.dart';
import '../models/json_parsing.dart';
import '../models/vacancy.dart';
import 'api_service.dart';

class VacancyDraft {
  const VacancyDraft({
    required this.title,
    required this.description,
    required this.salary,
    this.roleTitle = '',
    this.requirements = const [],
    this.availabilityTarget = '',
    this.providesTransport = false,
  });

  final String title;
  final String description;
  final String salary;
  final String roleTitle;
  final List<String> requirements;
  final String availabilityTarget;
  final bool providesTransport;
}

class VacancyCandidates {
  const VacancyCandidates({
    this.applied = const [],
    this.preApproved = const [],
    this.matches = const [],
  });

  final List<Candidate> applied;
  final List<Candidate> preApproved;
  final List<Candidate> matches;
}

abstract interface class EmployerGateway {
  Future<List<Vacancy>> loadVacancies();
  Future<Vacancy> createVacancy(VacancyDraft draft);
  Future<Vacancy> updateVacancy({required String vacancyId, required VacancyDraft draft});
  Future<VacancyCandidates> loadCandidates(String vacancyId);
}

class ApiEmployerGateway implements EmployerGateway {
  ApiEmployerGateway(this._client);

  final ApiClient _client;

  @override
  Future<List<Vacancy>> loadVacancies() async {
    final response = await _client.get<Object?>('/employers/vacancies');
    _expect(response, 200);
    final object = _object(response.data);
    final values = object['vacancies'];
    if (values is! List) throw const FormatException('Respuesta de vacantes inválida.');
    return values.whereType<Map>().map((value) => Vacancy.fromJson(_json(value))).toList(growable: false);
  }

  @override
  Future<Vacancy> createVacancy(VacancyDraft draft) async {
    final response = await _client.postMultipart<Object?>('/employers/vacancies', _form(draft));
    _expect(response, 201);
    return _vacancy(response.data);
  }

  @override
  Future<Vacancy> updateVacancy({required String vacancyId, required VacancyDraft draft}) async {
    final response = await _client.put<Object?>('/employers/vacancies/$vacancyId', _form(draft));
    _expect(response, 200);
    return _vacancy(response.data);
  }

  @override
  Future<VacancyCandidates> loadCandidates(String vacancyId) async {
    final response = await _client.get<Object?>('/employers/vacancies/$vacancyId/candidates');
    _expect(response, 200);
    final object = _object(response.data);
    return VacancyCandidates(
      applied: _candidates(object['applied']),
      preApproved: _candidates(object['preApproved']),
      matches: _candidates(object['matches']),
    );
  }

  FormData _form(VacancyDraft draft) => FormData.fromMap({
        'title': draft.title.trim(),
        'description': draft.description.trim(),
        'roleTitle': draft.roleTitle.trim(),
        'requirements': jsonEncode(draft.requirements),
        'salaryMin': draft.salary.trim(),
        'availabilityTarget': draft.availabilityTarget.trim(),
        'providesTransport': draft.providesTransport.toString(),
      });

  static Vacancy _vacancy(Object? data) {
    final vacancy = _object(data)['vacancy'];
    if (vacancy is! Map) throw const FormatException('Respuesta de vacante inválida.');
    return Vacancy.fromJson(_json(vacancy));
  }

  static List<Candidate> _candidates(Object? value) => value is List
      ? value.whereType<Map>().map((item) => Candidate.fromJson(_json(item))).toList(growable: false)
      : const [];

  static JsonObject _object(Object? value) => value is Map ? _json(value) : <String, Object?>{};
  static JsonObject _json(Map value) => Map<String, Object?>.from(value);

  static void _expect(Response<Object?> response, int expected) {
    if (response.statusCode != expected) throw const FormatException('Respuesta del servidor inválida.');
  }
}
