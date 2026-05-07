class ApiException implements Exception {
  final String message;
  ApiException(this.message);
}

class UnauthorizedException extends ApiException {
  UnauthorizedException() : super("Unauthorized");
}

class ServerException extends ApiException {
  ServerException(String msg) : super(msg);
}
