class Result<S, F> {
  final S? success;
  final F? failure;
  Result.success(this.success) : failure = null;
  Result.failure(this.failure) : success = null;
  bool get isSuccess => success != null;
  bool get isFailure => failure != null;
}
