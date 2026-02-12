import 'app_exception.dart';

enum FailureCode {
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

class Failure  {
  final FailureCode code;
  final String message;
  final int? statusCode;


  const Failure({required this.code, required this.message, this.statusCode});

  factory Failure.fromAppException(AppException appException) {
    switch (appException.code) {
      case AppErrorCode.network:
        return Failure(code: FailureCode.network, message: appException.message, statusCode: appException.statusCode);
      case AppErrorCode.timeout:
        return Failure(code: FailureCode.timeout, message: appException.message, statusCode: appException.statusCode);
      case AppErrorCode.cancelled:
        return Failure(code: FailureCode.cancelled, message: appException.message, statusCode: appException.statusCode);
      case AppErrorCode.rateLimited:
        return Failure(code: FailureCode.rateLimited, message: appException.message, statusCode: appException.statusCode);
      case AppErrorCode.unauthorized:
        return Failure(code: FailureCode.unauthorized, message: appException.message, statusCode: appException.statusCode);
      case AppErrorCode.forbidden:
        return Failure(code: FailureCode.forbidden, message: appException.message, statusCode: appException.statusCode);
      case AppErrorCode.notFound:
        return Failure(code: FailureCode.notFound, message: appException.message, statusCode: appException.statusCode);
      case AppErrorCode.validation:
        return Failure(code: FailureCode.validation, message: appException.message, statusCode: appException.statusCode);
      case AppErrorCode.server:
        return Failure(code: FailureCode.server, message: appException.message, statusCode: appException.statusCode);
      case AppErrorCode.unknown:
    default:
      return Failure(
        code: FailureCode.unknown,
        message: appException.message,
        statusCode: appException.statusCode,
      );
    }
   
  }

  @override
  String toString() {
    return 'Failure(code: $code, message: $message, statusCode: $statusCode)';
  }
}