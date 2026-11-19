class AuthResult {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;

  const AuthResult({
    required this.success,
    required this.message,
    this.data,
  });
}
