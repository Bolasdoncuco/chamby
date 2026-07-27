String? stringValue(Object? value) => value is String ? value : null;

typedef JsonObject = Map<String, Object?>;

String requiredStringValue(JsonObject json, String field) {
  final value = stringValue(json[field]);
  if (value == null || value.trim().isEmpty) {
    throw FormatException('Campo requerido ausente o inválido: $field');
  }
  return value;
}

JsonObject requiredMapValue(JsonObject json, String field) {
  final value = mapValue(json[field]);
  if (value == null) {
    throw FormatException('Objeto requerido ausente o inválido: $field');
  }
  return value;
}

double? doubleValue(Object? value) => value is num ? value.toDouble() : null;

bool? boolValue(Object? value) => value is bool ? value : null;

List<String> stringListValue(Object? value) {
  if (value is! List) return const [];
  return value.whereType<String>().toList(growable: false);
}

DateTime? dateTimeValue(Object? value) {
  final string = stringValue(value);
  return string == null ? null : DateTime.tryParse(string);
}

JsonObject? mapValue(Object? value) {
  if (value is! Map) return null;
  return Map<String, Object?>.from(value);
}
