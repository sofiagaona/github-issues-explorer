enum AppErrorCode {
  network, //sin internet/dns/etc
  timeout, //tiempo de espera excedido
  cancelled, //request cancelado
  rateLimited, //403 por rate limit (GitHub)
  unauthorized, //401
  forbidden, //403
  notFound, //404
  validation, //422
  server, //500
  unknown, //otro error
}

class AppException implements Exception {
  final AppErrorCode code;
  final String message;
  final int? statusCode;
  final Object? cause;
  final StackTrace? stackTrace;

  const AppException({required this.code, required this.message, this.statusCode, this.cause, this.stackTrace});

  @override
  String toString() {
    return 'AppException(code: $code, message: $message, statusCode: $statusCode, cause: $cause, stackTrace: $stackTrace)';
  }
}

