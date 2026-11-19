import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../models/auth_result.dart';

class AuthController extends ChangeNotifier {
  bool isLoading = false;

  Future<AuthResult> login(String email, String password) {
    return _run(() => WorkBeeAuthService.post(
          'login/',
          {'email': email.trim().toLowerCase(), 'password': password},
          defaultErrorMessage: 'Invalid email or password.',
        ));
  }

  Future<AuthResult> registerStudent({
    required String name,
    required String email,
    required String password,
    required String college,
  }) {
    return _run(() => WorkBeeAuthService.post(
          'register/student/',
          {
            'name': name.trim(),
            'email': email.trim().toLowerCase(),
            'password': password,
            'college': college.trim(),
          },
          defaultSuccessMessage: 'Registration successful! Please log in.',
          defaultErrorMessage: 'Registration failed. Please check your details.',
        ));
  }

  Future<AuthResult> registerBusiness({
    required String businessName,
    required String contactPerson,
    required String email,
    required String phone,
    required String location,
    required String panNumber,
    required String password,
  }) {
    return _run(() => WorkBeeAuthService.post(
          'register/business/',
          {
            'business_name': businessName.trim(),
            'contact_person': contactPerson.trim(),
            'email': email.trim().toLowerCase(),
            'phone': phone.trim(),
            'location': location.trim(),
            'pan_number': panNumber.trim(),
            'password': password,
          },
          defaultSuccessMessage: 'Business account created! Please log in.',
          defaultErrorMessage: 'Registration failed',
        ));
  }

  Future<AuthResult> sendResetLink(String email) {
    return _run(() => WorkBeeAuthService.post(
          'forgot-password/',
          {'email': email.trim().toLowerCase()},
          defaultSuccessMessage:
              'If an account exists, a reset link has been sent.',
          defaultErrorMessage: 'Failed to send reset link',
        ));
  }

  Future<AuthResult> _run(Future<AuthResult> Function() request) async {
    isLoading = true;
    notifyListeners();
    try {
      return await request();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
