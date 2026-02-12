import 'package:dio/dio.dart';

import '../error/app_exception.dart';
import '../error/failure.dart';
import 'result.dart';

Future<Result<T>> guard<T>(Future<T> Function() action) async {

try{
final data= await action();
return Success<T>(data);
}
catch(e,_){
  if (e is DioException) {
    final inner = e.error;
    if (inner is AppException) {
      return FailureResult<T>(Failure.fromAppException(inner));
    }
  } else if (e is AppException) {
    return FailureResult<T>(Failure.fromAppException(e));
  }

  return FailureResult<T>(
    const Failure(code:FailureCode.unknown, message: 'Unexpected error')
  );

}


}