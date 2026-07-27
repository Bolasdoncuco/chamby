import 'json_parsing.dart';

enum SwipeStatus {
  pending('PENDING'),
  liked('LIKED'),
  passed('PASSED'),
  unknown('UNKNOWN');

  const SwipeStatus(this.value);

  final String value;

  static SwipeStatus fromJson(Object? value) => SwipeStatus.values.firstWhere(
    (status) => status.value == value,
    orElse: () => SwipeStatus.unknown,
  );
}

class Connection {
  const Connection({
    required this.id,
    this.candidateId,
    this.vacancyId,
    this.candidateStatus = SwipeStatus.unknown,
    this.employerStatus = SwipeStatus.unknown,
    this.isMatch = false,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String? candidateId;
  final String? vacancyId;
  final SwipeStatus candidateStatus;
  final SwipeStatus employerStatus;
  final bool isMatch;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Connection.fromJson(JsonObject json) => Connection(
    id: requiredStringValue(json, 'id'),
    candidateId: stringValue(json['candidateId']),
    vacancyId: stringValue(json['vacancyId']),
    candidateStatus: SwipeStatus.fromJson(json['candidateStatus']),
    employerStatus: SwipeStatus.fromJson(json['employerStatus']),
    isMatch: boolValue(json['isMatch']) ?? false,
    createdAt: dateTimeValue(json['createdAt']),
    updatedAt: dateTimeValue(json['updatedAt']),
  );
}
