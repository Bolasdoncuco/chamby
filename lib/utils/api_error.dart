import 'package:dio/dio.dart';

class ApiError implements Exception {
  const ApiError({
    required this.message,
    this.statusCode,
    this.isCancelled = false,
  });

  final String message;
  final int? statusCode;
  final bool isCancelled;

  factory ApiError.fromDio(DioException exception) {
    final statusCode = exception.response?.statusCode;
    if (exception.type == DioExceptionType.cancel) {
      return ApiError(message: 'La solicitud fue cancelada.', statusCode: statusCode, isCancelled: true);
    }
    if (exception.type == DioExceptionType.connectionTimeout ||
        exception.type == DioExceptionType.sendTimeout ||
        exception.type == DioExceptionType.receiveTimeout) {
      return ApiError(message: 'La solicitud tardó demasiado. Inténtalo de nuevo.', statusCode: statusCode);
    }

    return ApiError(message: _fallbackMessage(statusCode, exception.type), statusCode: statusCode);
  }

  static String _fallbackMessage(int? statusCode, DioExceptionType type) {
    switch (statusCode) {
      case 400:
      case 422:
        return 'La solicitud no es válida. Revisa los datos e inténtalo de nuevo.';
      case 401:
        return 'Tu sesión no es válida. Inicia sesión nuevamente.';
      case 403:
        return 'No tienes permiso para realizar esta acción.';
      case 404:
        return 'No se encontró la información solicitada.';
      case 408:
        return 'La solicitud tardó demasiado. Inténtalo de nuevo.';
      case 429:
        return 'Hay demasiadas solicitudes. Inténtalo más tarde.';
    }
    switch (type) {
      case DioExceptionType.connectionError:
        return 'No se pudo conectar con el servidor. Revisa tu conexión e inténtalo de nuevo.';
      case DioExceptionType.badCertificate:
        return 'No se pudo verificar la conexión segura.';
      default:
        return 'No fue posible completar la solicitud. Inténtalo más tarde.';
    }
  }

  @override
  String toString() => message;
}
