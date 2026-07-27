import 'dart:convert';

import 'package:dio/dio.dart';

import '../models/candidate.dart';
import '../models/json_parsing.dart';
import '../models/match.dart';
import '../models/vacancy.dart';
import '../utils/api_error.dart';
import 'api_service.dart';

abstract interface class CandidateGateway {
  Future<Candidate> loadProfile();
  Future<Candidate> saveProfile(CandidateProfileDraft draft);
  Future<List<Vacancy>> loadFeed();
  Future<Match> swipe({required String vacancyId, required bool isLike});
}

class CandidateProfileDraft {
  const CandidateProfileDraft({
    required this.firstName,
    required this.lastName,
    this.role = '',
    this.bio = '',
    this.skills = const [],
    this.experience,
    this.availability = '',
    this.phone = '',
    this.whatsapp = '',
  });

  final String firstName;
  final String lastName;
  final String role;
  final String bio;
  final List<String> skills;
  final int? experience;
  final String availability;
  final String phone;
  final String whatsapp;

  factory CandidateProfileDraft.fromCandidate(Candidate candidate) =>
      CandidateProfileDraft(
        firstName: candidate.firstName ?? '',
        lastName: candidate.lastName ?? '',
        role: candidate.role ?? '',
        bio: candidate.bio ?? '',
        skills: candidate.skills,
        experience: candidate.experience?.toInt(),
        availability: candidate.availability ?? '',
        phone: candidate.phone ?? '',
        whatsapp: candidate.whatsapp ?? '',
      );

  Map<String, String> toMultipartFields() {
    final fields = <String, String>{
      'firstName': firstName.trim(),
      'lastName': lastName.trim(),
      'role': role.trim(),
      'bio': bio.trim(),
      'skills': jsonEncode(
        skills
            .where((skill) => skill.trim().isNotEmpty)
            .map((skill) => skill.trim())
            .toList(),
      ),
      'availability': availability.trim(),
      'phone': phone.trim(),
      'whatsapp': whatsapp.trim(),
    };
    if (experience != null) fields['experience'] = experience!.toString();
    return fields;
  }
}

class ApiCandidateGateway implements CandidateGateway {
  ApiCandidateGateway([ApiClient? client])
    : _client = client ?? ApiService.client;

  final ApiClient _client;

  @override
  Future<Candidate> loadProfile() async {
    final response = await _client.get<Object?>('/candidates/profile');
    return Candidate.fromJson(_requiredObject(response.data, 'profile'));
  }

  @override
  Future<Candidate> saveProfile(CandidateProfileDraft draft) async {
    final response = await _client.put<Object?>(
      '/candidates/profile',
      FormData.fromMap(draft.toMultipartFields()),
    );
    return Candidate.fromJson(_requiredObject(response.data, 'profile'));
  }

  @override
  Future<List<Vacancy>> loadFeed() async {
    final response = await _client.get<Object?>('/candidates/feed');
    final body = _requiredMap(response.data);
    final feed = body['feed'];
    if (feed is! List) {
      throw const FormatException('El feed no tiene un formato válido.');
    }
    return feed
        .map((item) {
          if (item is! Map) {
            throw const FormatException(
              'Una vacante no tiene un formato válido.',
            );
          }
          return Vacancy.fromJson(Map<String, Object?>.from(item));
        })
        .toList(growable: false);
  }

  @override
  Future<Match> swipe({required String vacancyId, required bool isLike}) async {
    final response = await _client.post<Object?>('/candidates/swipe', {
      'vacancyId': vacancyId,
      'isLike': isLike,
    });
    final body = _requiredMap(response.data);
    final connection = _requiredObject(body, 'connection');
    return Match.fromJson(<String, Object?>{
      ...connection,
      'isMatch': body['isMatch'] ?? connection['isMatch'],
    });
  }

  static JsonObject _requiredObject(Object? response, String field) {
    final body = _requiredMap(response);
    final value = body[field];
    if (value is! Map) {
      throw const FormatException('La respuesta del servidor no es válida.');
    }
    return Map<String, Object?>.from(value);
  }

  static JsonObject _requiredMap(Object? response) {
    if (response is! Map) {
      throw const FormatException('La respuesta del servidor no es válida.');
    }
    return Map<String, Object?>.from(response);
  }
}

int? parseCandidateExperience(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return null;
  final parsed = int.tryParse(trimmed);
  return parsed == null || parsed < 0 ? null : parsed;
}

String candidateErrorMessage(Object error) {
  if (error is ApiError) return error.message;
  if (error is FormatException) {
    return 'La información recibida no es válida. Inténtalo de nuevo.';
  }
  return 'No fue posible completar la solicitud. Inténtalo más tarde.';
}
