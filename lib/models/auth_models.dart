import 'json_parsing.dart';

enum AccountRole {
  candidate('CANDIDATE'),
  employer('EMPLOYER'),
  unknown('UNKNOWN');

  const AccountRole(this.value);

  final String value;

  static AccountRole fromJson(Object? value) => AccountRole.values.firstWhere(
    (role) => role.value == value,
    orElse: () => AccountRole.unknown,
  );
}

class AuthUser {
  const AuthUser({required this.id, required this.email, required this.role});

  final String id;
  final String email;
  final AccountRole role;

  factory AuthUser.fromJson(JsonObject json) => AuthUser(
    id: requiredStringValue(json, 'id'),
    email: requiredStringValue(json, 'email'),
    role: AccountRole.fromJson(json['role']),
  );
}

class AuthResponse {
  const AuthResponse({
    required this.message,
    required this.token,
    required this.user,
  });

  final String message;
  final String token;
  final AuthUser user;

  factory AuthResponse.fromJson(JsonObject json) {
    final user = requiredMapValue(json, 'user');
    return AuthResponse(
      message: requiredStringValue(json, 'message'),
      token: requiredStringValue(json, 'token'),
      user: AuthUser.fromJson(user),
    );
  }
}
