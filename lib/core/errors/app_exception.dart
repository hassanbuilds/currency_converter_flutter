abstract class AppException implements Exception {
  final String message;
  final StackTrace? stackTrace;

  const AppException(this.message, [this.stackTrace]);

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException(String message, [StackTrace? stackTrace])
    : super(message, stackTrace);
}

class ConversionException extends AppException {
  const ConversionException(String message, [StackTrace? stackTrace])
    : super(message, stackTrace);
}

class CacheException extends AppException {
  const CacheException(String message, [StackTrace? stackTrace])
    : super(message, stackTrace);
}

class ChartException extends AppException {
  const ChartException(String message) : super(message);
}
