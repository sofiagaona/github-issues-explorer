import '../error/failure.dart';

abstract class Result<T> {
  const Result();
R when<R>({
  required R Function(T data) onSuccess,
  required R Function(Failure failure) onFailure,
});
 
}

class Success<T> extends Result<T>{
  final T data;
  const Success(this.data);

 @override
 R when<R>({
   required R Function(T data) onSuccess,
   required R Function(Failure failure) onFailure,
 }) {
   return onSuccess(data);
 }
}


class FailureResult<T> extends Result<T> {
  final  Failure error;
  const FailureResult(this.error);

  @override
R when<R>({
  required R Function(T data) onSuccess,
  required R Function (Failure failure) onFailure,
})
{
  return onFailure(error);
}
}

