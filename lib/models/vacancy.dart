import 'employer.dart';
import 'json_parsing.dart';

class Vacancy {
  const Vacancy({
    required this.id,
    this.employerId,
    this.title,
    this.description,
    this.requirements = const [],
    this.salaryMin,
    this.salaryMax,
    this.isActive,
    this.roleTitle,
    this.availabilityTarget,
    this.latitude,
    this.longitude,
    this.providesTransport,
    this.images = const [],
    this.score,
    this.distanceKm,
    this.name,
    this.role,
    this.bio,
    this.tags = const [],
    this.location,
    this.availability,
    this.photoUrl,
    this.employer,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String? employerId;
  final String? title;
  final String? description;
  final List<String> requirements;
  final double? salaryMin;
  final double? salaryMax;
  final bool? isActive;
  final String? roleTitle;
  final String? availabilityTarget;
  final double? latitude;
  final double? longitude;
  final bool? providesTransport;
  final List<String> images;
  final double? score;
  final double? distanceKm;
  final String? name;
  final String? role;
  final String? bio;
  final List<String> tags;
  final String? location;
  final String? availability;
  final String? photoUrl;
  final Employer? employer;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Vacancy.fromJson(JsonObject json) => Vacancy(
    id: requiredStringValue(json, 'id'),
    employerId: stringValue(json['employerId']),
    title: stringValue(json['title']),
    description: stringValue(json['description']),
    requirements: stringListValue(json['requirements']),
    salaryMin: doubleValue(json['salaryMin']),
    salaryMax: doubleValue(json['salaryMax']),
    isActive: boolValue(json['isActive']),
    roleTitle:
        stringValue(json['roleTitle']) ?? stringValue(json['roleRequired']),
    availabilityTarget: stringValue(json['availabilityTarget']),
    latitude: doubleValue(json['latitude']),
    longitude: doubleValue(json['longitude']),
    providesTransport: boolValue(json['providesTransport']),
    images: stringListValue(json['images']),
    score: doubleValue(json['score']),
    distanceKm: doubleValue(json['distanceKm']),
    name: stringValue(json['name']),
    role: stringValue(json['role']),
    bio: stringValue(json['bio']),
    tags: stringListValue(json['tags']),
    location: stringValue(json['location']),
    availability: stringValue(json['availability']),
    photoUrl: stringValue(json['photoUrl']) ?? stringValue(json['photo']),
    employer: mapValue(json['employer']) == null
        ? null
        : Employer.fromJson(mapValue(json['employer'])!),
    createdAt: dateTimeValue(json['createdAt']),
    updatedAt: dateTimeValue(json['updatedAt']),
  );
}

class VacancySummary {
  const VacancySummary({this.title, this.roleRequired, this.employer});

  final String? title;
  final String? roleRequired;
  final EmployerSummary? employer;

  factory VacancySummary.fromJson(JsonObject json) {
    final employer = mapValue(json['employer']);
    return VacancySummary(
      title: stringValue(json['title']),
      roleRequired: stringValue(json['roleRequired']),
      employer: employer == null ? null : EmployerSummary.fromJson(employer),
    );
  }
}

class EmployerSummary {
  const EmployerSummary({this.companyName, this.logoUrl});

  final String? companyName;
  final String? logoUrl;

  factory EmployerSummary.fromJson(JsonObject json) => EmployerSummary(
    companyName: stringValue(json['companyName']),
    logoUrl: stringValue(json['logoUrl']),
  );
}
