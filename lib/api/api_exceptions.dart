import 'package:dio/dio.dart';

class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.statusCode,
    this.cause,
  });

  final String message;
  final int? statusCode;
  final Object? cause;

  factory ApiException.fromDioException(DioException error) {
    final statusCode = error.response?.statusCode;
    final message = error.response?.data is Map
        ? _extractMessage(error.response!.data as Map)
        : error.message ?? 'Request failed.';

    switch (statusCode) {
      case 400:
        return BadRequestException(message: message, statusCode: statusCode, cause: error);
      case 401:
        return UnauthorizedException(message: message, statusCode: statusCode, cause: error);
      case 403:
        return ForbiddenException(message: message, statusCode: statusCode, cause: error);
      case 404:
        return NotFoundException(message: message, statusCode: statusCode, cause: error);
      case 409:
        return ConflictException(message: message, statusCode: statusCode, cause: error);
      case 429:
        return RateLimitException(message: message, statusCode: statusCode, cause: error);
      case 500:
      case 502:
      case 503:
      case 504:
        return ServerException(message: message, statusCode: statusCode, cause: error);
      default:
        if (error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout ||
            error.type == DioExceptionType.sendTimeout) {
          return NetworkException(message: 'Request timed out. Please try again.', cause: error);
        }
        return ApiException(message: message.isNotEmpty ? message : 'Request failed.', statusCode: statusCode, cause: error);
    }
  }

  static String _extractMessage(Map<dynamic, dynamic> payload) {
    if (payload.containsKey('message')) {
      final value = payload['message'];
      if (value is String && value.trim().isNotEmpty) return value;
    }
    if (payload.containsKey('error')) {
      final value = payload['error'];
      if (value is String && value.trim().isNotEmpty) return value;
    }
    return 'Request failed.';
  }

  @override
  String toString() => 'ApiException(statusCode: $statusCode, message: $message)';
}

class BadRequestException extends ApiException {
  const BadRequestException({required super.message, super.statusCode, super.cause});
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException({required super.message, super.statusCode, super.cause});
}

class ForbiddenException extends ApiException {
  const ForbiddenException({required super.message, super.statusCode, super.cause});
}

class NotFoundException extends ApiException {
  const NotFoundException({required super.message, super.statusCode, super.cause});
}

class ConflictException extends ApiException {
  const ConflictException({required super.message, super.statusCode, super.cause});
}

class RateLimitException extends ApiException {
  const RateLimitException({required super.message, super.statusCode, super.cause});
}

class NetworkException extends ApiException {
  const NetworkException({required super.message, super.statusCode, super.cause});
}

class ServerException extends ApiException {
  const ServerException({required super.message, super.statusCode, super.cause});
}
