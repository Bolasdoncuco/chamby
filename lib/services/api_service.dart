import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/api_error.dart';

abstract interface class AuthTokenStorage {
  Future<String?> readToken();
}

class SharedPreferencesAuthTokenStorage implements AuthTokenStorage {
  @override
  Future<String?> readToken() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString('auth_token');
  }
}

class ApiClient {
  ApiClient({
    Dio? dio,
    required AuthTokenStorage tokenStorage,
    required String baseUrl,
    Duration timeout = defaultTimeout,
  })  : dio = dio ?? Dio(),
        _tokenStorage = tokenStorage {
    this.dio.options
      ..baseUrl = baseUrl
      ..connectTimeout = timeout
      ..sendTimeout = timeout
      ..receiveTimeout = timeout
      ..headers.addAll(const {
        Headers.acceptHeader: Headers.jsonContentType,
      });
    this.dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            final token = await _tokenStorage.readToken();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          } catch (_) {
            // An unavailable local store must not disclose or fabricate credentials.
          }
          handler.next(options);
        },
      ),
    );
  }

  static const defaultTimeout = Duration(seconds: 10);

  final Dio dio;
  final AuthTokenStorage _tokenStorage;

  Future<Response<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) =>
      _request<T>(
        endpoint,
        method: 'GET',
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      );

  Future<Response<T>> post<T>(
    String endpoint,
    Object? data, {
    CancelToken? cancelToken,
  }) =>
      _request<T>(endpoint, method: 'POST', data: data, cancelToken: cancelToken);

  Future<Response<T>> put<T>(
    String endpoint,
    Object? data, {
    CancelToken? cancelToken,
  }) =>
      _request<T>(endpoint, method: 'PUT', data: data, cancelToken: cancelToken);

  Future<Response<T>> delete<T>(
    String endpoint, {
    CancelToken? cancelToken,
  }) =>
      _request<T>(endpoint, method: 'DELETE', cancelToken: cancelToken);

  Future<Response<T>> postMultipart<T>(
    String endpoint,
    FormData formData, {
    CancelToken? cancelToken,
  }) =>
      _request<T>(
        endpoint,
        method: 'POST',
        data: formData,
        cancelToken: cancelToken,
        options: Options(contentType: Headers.multipartFormDataContentType),
      );

  Future<Response<T>> _request<T>(
    String endpoint, {
    required String method,
    Object? data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
  }) async {
    final requestOptions = data is FormData && options == null
        ? Options(contentType: Headers.multipartFormDataContentType)
        : options;
    try {
      return await dio.request<T>(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: (requestOptions ?? Options()).copyWith(method: method),
      );
    } on DioException catch (exception) {
      throw ApiError.fromDio(exception);
    }
  }
}

class ApiService {
  static const developmentBaseUrl = 'http://10.0.2.2:3000/api';

  static ApiClient _client = _newClient(developmentBaseUrl);

  static ApiClient get client => _client;

  static ApiClient _newClient(String baseUrl) => ApiClient(
        tokenStorage: SharedPreferencesAuthTokenStorage(),
        baseUrl: baseUrl,
      );

  static String resolveBaseUrl({required String? apiUrl, required bool isProduction}) {
    final configuredUrl = apiUrl?.trim();
    if (configuredUrl != null && configuredUrl.isNotEmpty) {
      return configuredUrl.endsWith('/') ? configuredUrl.substring(0, configuredUrl.length - 1) : configuredUrl;
    }
    if (isProduction) {
      throw StateError('API_URL es obligatoria en producción. Configúrala antes de iniciar la aplicación.');
    }
    return developmentBaseUrl;
  }

  static void configure({required String? apiUrl, required bool isProduction}) {
    _client = _newClient(resolveBaseUrl(apiUrl: apiUrl, isProduction: isProduction));
  }

  static Future<Response<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) =>
      _client.get<T>(endpoint, queryParameters: queryParameters, cancelToken: cancelToken);

  static Future<Response<T>> post<T>(
    String endpoint,
    Object? data, {
    CancelToken? cancelToken,
  }) =>
      _client.post<T>(endpoint, data, cancelToken: cancelToken);

  static Future<Response<T>> put<T>(
    String endpoint,
    Object? data, {
    CancelToken? cancelToken,
  }) =>
      _client.put<T>(endpoint, data, cancelToken: cancelToken);

  static Future<Response<T>> delete<T>(
    String endpoint, {
    CancelToken? cancelToken,
  }) =>
      _client.delete<T>(endpoint, cancelToken: cancelToken);

  static Future<Response<T>> postMultipart<T>(
    String endpoint,
    FormData formData, {
    CancelToken? cancelToken,
  }) =>
      _client.postMultipart<T>(endpoint, formData, cancelToken: cancelToken);
}
