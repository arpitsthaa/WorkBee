import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/auth_result.dart';

class WorkBeeAuthService {
  static const String _baseUrl = 'https://workbee-zi7l.onrender.com/api/accounts';

  static String? validateEmail(String? val) {
    if (val == null ||
        !RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(val.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static Future<AuthResult> post(
      String endpoint,
      Map<String, dynamic> body, {
        String defaultSuccessMessage = 'Success',
        String defaultErrorMessage = 'Request failed. Please try again.',
      }) async {
    try {
      final response = await http
          .post(
        Uri.parse('$_baseUrl/$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      )
          .timeout(const Duration(seconds: 15));

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AuthResult(
          success: true,
          message: decoded['message'] ?? defaultSuccessMessage,
          data: decoded is Map<String, dynamic> ? decoded : null,
        );
      }

      String errorMessage = defaultErrorMessage;
      if (decoded is Map<String, dynamic>) {
        if (decoded['error'] != null) {
          errorMessage = decoded['error'].toString();
        } else if (decoded['detail'] != null) {
          errorMessage = decoded['detail'].toString();
        } else if (decoded.isNotEmpty) {
          final firstError = decoded.values.first;
          errorMessage = firstError is List
              ? firstError.first.toString()
              : firstError.toString();
        }
      }

      return AuthResult(success: false, message: errorMessage);
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Network error. Could not connect to server.',
      );
    }
  }
}