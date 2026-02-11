import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../error/app_exception.dart';



class GithubInterceptor extends Interceptor {

final Map<String, String> _defaultHeaders;
GithubInterceptor({Map<String, String>? defaultHeaders})
    : _defaultHeaders = defaultHeaders ?? const {};

 

 @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
   final mergedHeaders= {..._defaultHeaders, ...options.headers};
    options.headers = mergedHeaders;
    options.extra['start_time'] = DateTime.now().millisecondsSinceEpoch;

if(kDebugMode) {
  final method = options.method;
  final uri = options.uri;
  debugPrint('$method $uri');
}

     handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {

if(kDebugMode) {
final start= response.requestOptions.extra['start_time'] as int?;
final tookMs = start != null ? DateTime.now().millisecondsSinceEpoch - start : null;
final status = response.statusCode;
final method = response.requestOptions.method;
final uri = response.requestOptions.uri;
debugPrint('$method $uri $status ${tookMs ?? '-'}ms');
}

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {

  if(kDebugMode) {
   final start= err.requestOptions.extra['start_time'] as int?;
   final tookMs = start != null ? DateTime.now().millisecondsSinceEpoch - start : null;
   final status = err.response?.statusCode;
   final method = err.requestOptions.method;
   final uri = err.requestOptions.uri;
    debugPrint('❌ [${status ?? '-'}] [$method] $uri'
      '${tookMs != null ? ' (${tookMs}ms)' : ''} -> ${err.type}');

  }

  final appException =_mapDioError(err);
   // Rechazamos con el mismo DioException pero con "error" ya mapeado
   handler.reject(err.copyWith(error: appException));
   return;
  }

  AppException _mapDioError(DioException err) {
    if (err.type == DioExceptionType.cancel) {
      return AppException(
        code: AppErrorCode.cancelled,
        message: 'Request cancelled',
        statusCode: err.response?.statusCode,
        cause: err,
        stackTrace: err.stackTrace,
      );
    }

    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      return AppException(
        code: AppErrorCode.timeout,
        message: 'Request timeout. Please try again.',
        statusCode: err.response?.statusCode,
        cause: err,
        stackTrace: err.stackTrace,
      );
    }

    final isSocket = err.error is SocketException;
    if (isSocket || err.type == DioExceptionType.connectionError) {
      return AppException(
        code: AppErrorCode.network,
        message: 'No internet connection.',
        statusCode: err.response?.statusCode,
        cause: err,
        stackTrace: err.stackTrace,
      );
    }

    final status = err.response?.statusCode;
    if (status != null) {
      final remaining = err.response?.headers.value('x-ratelimit-remaining');
      final isRateLimited = status == 403 && remaining == '0';

      if (isRateLimited) {
        return AppException(
          code: AppErrorCode.rateLimited,
          message: 'GitHub API rate limit exceeded. Try again later.',
          statusCode: status,
          cause: err,
          stackTrace: err.stackTrace,
        );
      }

      if (status == 401) {
        return AppException(
          code: AppErrorCode.unauthorized,
          message: 'Unauthorized request.',
          statusCode: status,
          cause: err,
          stackTrace: err.stackTrace,
        );
      }

      if (status == 403) {
        return AppException(
          code: AppErrorCode.forbidden,
          message: 'Forbidden request.',
          statusCode: status,
          cause: err,
          stackTrace: err.stackTrace,
        );
      }

      if (status == 404) {
        return AppException(
          code: AppErrorCode.notFound,
          message: 'Not found.',
          statusCode: status,
          cause: err,
          stackTrace: err.stackTrace,
        );
      }

      if (status == 422) {
        return AppException(
          code: AppErrorCode.validation,
          message: 'Validation error.',
          statusCode: status,
          cause: err,
          stackTrace: err.stackTrace,
        );
      }

      if (status >= 500) {
        return AppException(
          code: AppErrorCode.server,
          message: 'Server error. Please try again later.',
          statusCode: status,
          cause: err,
          stackTrace: err.stackTrace,
        );
      }
    }

    return AppException(
      code: AppErrorCode.unknown,
      message: 'Unexpected error.',
      statusCode: err.response?.statusCode,
      cause: err,
      stackTrace: err.stackTrace,
    );
  }
}