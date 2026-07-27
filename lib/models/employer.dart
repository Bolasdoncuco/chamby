import 'json_parsing.dart';

class Employer {
  const Employer({
    required this.id,
    this.userId,
    this.companyName,
    this.description,
    this.logoUrl,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String? userId;
  final String? companyName;
  final String? description;
  final String? logoUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Employer.fromJson(JsonObject json) => Employer(
    id: requiredStringValue(json, 'id'),
    userId: stringValue(json['userId']),
    companyName: stringValue(json['companyName']),
    description: stringValue(json['description']),
    logoUrl: stringValue(json['logoUrl']),
    createdAt: dateTimeValue(json['createdAt']),
    updatedAt: dateTimeValue(json['updatedAt']),
  );
}
