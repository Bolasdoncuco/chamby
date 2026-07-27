import 'dart:async';
import 'dart:typed_data';

import 'package:chamby_app/models/auth_models.dart';
import 'package:chamby_app/models/candidate.dart';
import 'package:chamby_app/models/connection.dart';
import 'package:chamby_app/models/employer.dart';
import 'package:chamby_app/models/match.dart';
import 'package:chamby_app/models/vacancy.dart';
import 'package:chamby_app/main.dart';
import 'package:chamby_app/services/api_service.dart';
import 'package:chamby_app/utils/api_error.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('model parsing', () {
    test('parses documented auth and domain response fields', () {
      final auth = AuthResponse.fromJson({
        'message': 'Login exitoso',
        'token': 'never-log-this-token',
        'user': {
          'id': 'user-1',
          'email': 'ana@example.com',
          'role': 'CANDIDATE',
        },
      });
      final candidate = Candidate.fromJson({
        'id': 'candidate-1',
        'userId': 'user-1',
        'firstName': 'Ana',
        'lastName': 'López',
        'skills': ['Ventas', 'POS'],
        'experience': 2,
        'availability': 'Tiempo completo',
        'latitude': 19.4326,
        'longitude': -99.1332,
        'maxDistanceKm': 15,
        'phone': '5555555555',
        'whatsapp': '5555555555',
        'photoUrl': 'https://example.test/ana.jpg',
      });
      final employer = Employer.fromJson({
        'id': 'employer-1',
        'userId': 'user-2',
        'companyName': 'Café Chamby',
        'description': 'Cafetería',
        'logoUrl': 'https://example.test/logo.png',
      });
      final vacancy = Vacancy.fromJson({
        'id': 'vacancy-1',
        'employerId': 'employer-1',
        'title': 'Barista',
        'description': 'Atención a clientes',
        'requirements': ['Servicio al cliente'],
        'salaryMin': 9000,
        'salaryMax': 11000,
        'isActive': true,
        'roleTitle': 'Barista',
        'availabilityTarget': 'Tiempo completo',
        'latitude': 19.4,
        'longitude': -99.1,
        'providesTransport': false,
        'images': ['https://example.test/vacancy.jpg'],
        'score': 42,
        'distanceKm': 2.5,
        'name': 'Café Chamby',
        'role': 'Barista',
        'bio': 'Atención a clientes',
        'tags': ['Servicio al cliente'],
        'location': 'Ubicación Disponible',
        'availability': 'Tiempo completo',
        'photo': 'https://example.test/vacancy.jpg',
      });
      final connection = Connection.fromJson({
        'id': 'connection-1',
        'candidateId': 'candidate-1',
        'vacancyId': 'vacancy-1',
        'candidateStatus': 'LIKED',
        'employerStatus': 'PENDING',
        'isMatch': false,
      });
      final match = Match.fromJson({
        'id': 'connection-2',
        'candidateId': 'candidate-1',
        'vacancyId': 'vacancy-1',
        'candidateStatus': 'LIKED',
        'employerStatus': 'LIKED',
        'isMatch': true,
        'candidate': {'firstName': 'Ana', 'lastName': 'López', 'photoUrl': 'https://example.test/ana.jpg'},
        'vacancy': {'title': 'Barista', 'employer': {'companyName': 'Café Chamby'}},
      });

      expect(auth.user.role, AccountRole.candidate);
      expect(candidate.skills, ['Ventas', 'POS']);
      expect(candidate.maxDistanceKm, 15);
      expect(employer.companyName, 'Café Chamby');
      expect(vacancy.requirements, ['Servicio al cliente']);
      expect(vacancy.photoUrl, 'https://example.test/vacancy.jpg');
      expect(connection.candidateStatus, SwipeStatus.liked);
      expect(match.isMatch, isTrue);
      expect(match.candidate?.firstName, 'Ana');
      expect(match.vacancy?.employer?.companyName, 'Café Chamby');
    });

    test('rejects malformed payloads instead of inventing empty required fields', () {
      expect(() => AuthResponse.fromJson({'message': 'ok', 'token': 'token'}), throwsFormatException);
      expect(() => Candidate.fromJson({'firstName': 'Ana'}), throwsFormatException);
      expect(() => Employer.fromJson({'companyName': 'Café'}), throwsFormatException);
      expect(() => Vacancy.fromJson({'title': 'Barista'}), throwsFormatException);
      expect(() => Connection.fromJson({'isMatch': false}), throwsFormatException);
      expect(() => Match.fromJson({'candidate': {}}), throwsFormatException);
    });
  });

  group('ApiError', () {
    test('uses vetted status messages and never returns arbitrary server text', () {
      final errors = [
        _dioError(401, 'JWT secret=do-not-return'),
        _dioError(401, 'password=do-not-return'),
        _dioError(400, 'internal stack trace and credentials'),
        _dioError(500, 'database connection secret'),
      ];

      expect(ApiError.fromDio(errors[0]).message, 'Tu sesión no es válida. Inicia sesión nuevamente.');
      expect(ApiError.fromDio(errors[1]).message, 'Tu sesión no es válida. Inicia sesión nuevamente.');
      expect(ApiError.fromDio(errors[2]).message, 'La solicitud no es válida. Revisa los datos e inténtalo de nuevo.');
      expect(ApiError.fromDio(errors[3]).message, 'No fue posible completar la solicitud. Inténtalo más tarde.');
      for (final error in errors) {
        expect(ApiError.fromDio(error).message, isNot(contains('do-not-return')));
        expect(ApiError.fromDio(error).message, isNot(contains('secret')));
      }
    });

    test('maps timeout and cancellation to Spanish user-safe messages', () {
      final timeout = ApiError.fromDio(
        DioException(
          requestOptions: RequestOptions(path: '/feed'),
          type: DioExceptionType.receiveTimeout,
        ),
      );
      final cancelled = ApiError.fromDio(
        DioException(
          requestOptions: RequestOptions(path: '/feed'),
          type: DioExceptionType.cancel,
        ),
      );

      expect(timeout.message, 'La solicitud tardó demasiado. Inténtalo de nuevo.');
      expect(cancelled.isCancelled, isTrue);
      expect(cancelled.message, 'La solicitud fue cancelada.');
    });
  });

  group('ApiClient', () {
    test('shares auth, timeout and transport behavior across request types', () async {
      final adapter = RecordingAdapter();
      final client = ApiClient(
        dio: Dio(),
        tokenStorage: const FakeAuthTokenStorage('test-token'),
        baseUrl: 'https://api.example.test/api',
        timeout: const Duration(seconds: 3),
      );
      client.dio.httpClientAdapter = adapter;

      await client.get('/items');
      await client.post('/items', {'title': 'Nueva'});
      await client.put('/items/1/images', FormData.fromMap({'image': 'bytes'}));
      await client.postMultipart('/items/1/images', FormData.fromMap({'images': 'image-bytes'}));

      expect(adapter.options, hasLength(4));
      for (final options in adapter.options) {
        expect(options.headers['Authorization'], 'Bearer test-token');
        expect(options.connectTimeout, const Duration(seconds: 3));
        expect(options.sendTimeout, const Duration(seconds: 3));
        expect(options.receiveTimeout, const Duration(seconds: 3));
      }
      expect(adapter.options[2].method, 'PUT');
      expect(adapter.options[2].contentType, startsWith('multipart/form-data'));
    });

    test('maps an already cancelled request without reaching the network', () async {
      final adapter = RecordingAdapter();
      final client = ApiClient(
        dio: Dio(),
        tokenStorage: const FakeAuthTokenStorage(null),
        baseUrl: 'https://api.example.test/api',
      );
      client.dio.httpClientAdapter = adapter;
      final cancelToken = CancelToken()..cancel();

      await expectLater(
        client.get('/items', cancelToken: cancelToken),
        throwsA(isA<ApiError>().having((error) => error.isCancelled, 'isCancelled', isTrue)),
      );
      expect(adapter.options, isEmpty);
    });

    test('uses the emulator fallback only outside production', () {
      expect(
        ApiService.resolveBaseUrl(apiUrl: null, isProduction: false),
        'http://10.0.2.2:3000/api',
      );
      expect(
        () => ApiService.resolveBaseUrl(apiUrl: '  ', isProduction: true),
        throwsA(isA<StateError>()),
      );
    });

    test('tolerates missing env in tests but rejects missing API_URL in production', () async {
      await expectLater(
        configureApiEnvironment(
          isProduction: false,
          environmentLoader: () async => throw StateError('missing .env'),
          apiUrlOverride: null,
        ),
        completes,
      );
      await expectLater(
        configureApiEnvironment(
          isProduction: true,
          environmentLoader: () async {},
          apiUrlOverride: null,
        ),
        throwsA(isA<StateError>()),
      );
    });
  });
}

DioException _dioError(int statusCode, String serverText) => DioException(
      requestOptions: RequestOptions(path: '/test'),
      response: Response(
        requestOptions: RequestOptions(path: '/test'),
        statusCode: statusCode,
        data: {'error': serverText},
      ),
      type: DioExceptionType.badResponse,
    );

class FakeAuthTokenStorage implements AuthTokenStorage {
  const FakeAuthTokenStorage(this.token);

  final String? token;

  @override
  Future<String?> readToken() async => token;
}

class RecordingAdapter implements HttpClientAdapter {
  final List<RequestOptions> options = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions requestOptions,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    options.add(requestOptions);
    return ResponseBody.fromString(
      '{}',
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
