import 'json_parsing.dart';

class Candidate {
  const Candidate({
    required this.id,
    this.userId,
    this.firstName,
    this.lastName,
    this.name,
    this.bio,
    this.role,
    this.skills = const [],
    this.tags = const [],
    this.experience,
    this.availability,
    this.latitude,
    this.longitude,
    this.maxDistanceKm,
    this.phone,
    this.whatsapp,
    this.photoUrl,
    this.location,
    this.isMatch,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String? userId;
  final String? firstName;
  final String? lastName;
  final String? name;
  final String? bio;
  final String? role;
  final List<String> skills;
  final List<String> tags;
  final double? experience;
  final String? availability;
  final double? latitude;
  final double? longitude;
  final double? maxDistanceKm;
  final String? phone;
  final String? whatsapp;
  final String? photoUrl;
  final String? location;
  final bool? isMatch;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Candidate.fromJson(JsonObject json) => Candidate(
    id: requiredStringValue(json, 'id'),
    userId: stringValue(json['userId']),
    firstName: stringValue(json['firstName']),
    lastName: stringValue(json['lastName']),
    name: stringValue(json['name']),
    bio: stringValue(json['bio']),
    role: stringValue(json['role']),
    skills: stringListValue(json['skills']),
    tags: stringListValue(json['tags']),
    experience: doubleValue(json['experience']),
    availability: stringValue(json['availability']),
    latitude: doubleValue(json['latitude']),
    longitude: doubleValue(json['longitude']),
    maxDistanceKm: doubleValue(json['maxDistanceKm']),
    phone: stringValue(json['phone']),
    whatsapp: stringValue(json['whatsapp']),
    photoUrl: stringValue(json['photoUrl']) ?? stringValue(json['photo']),
    location: stringValue(json['location']),
    isMatch: boolValue(json['isMatch']),
    createdAt: dateTimeValue(json['createdAt']),
    updatedAt: dateTimeValue(json['updatedAt']),
  );
}

class CandidateSummary {
  const CandidateSummary({
    this.firstName,
    this.lastName,
    this.role,
    this.bio,
    this.skills = const [],
    this.photoUrl,
    this.phone,
    this.whatsapp,
  });

  final String? firstName;
  final String? lastName;
  final String? role;
  final String? bio;
  final List<String> skills;
  final String? photoUrl;
  final String? phone;
  final String? whatsapp;

  factory CandidateSummary.fromJson(JsonObject json) => CandidateSummary(
    firstName: stringValue(json['firstName']),
    lastName: stringValue(json['lastName']),
    role: stringValue(json['role']),
    bio: stringValue(json['bio']),
    skills: stringListValue(json['skills']),
    photoUrl: stringValue(json['photoUrl']) ?? stringValue(json['photo']),
    phone: stringValue(json['phone']),
    whatsapp: stringValue(json['whatsapp']),
  );
}
