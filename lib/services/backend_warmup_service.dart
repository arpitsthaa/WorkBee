import 'package:http/http.dart' as http;

class BackendWarmUpService {
  static const String _backendUrl =
      'https://workbee-zi7l.onrender.com/';

  // This is a simple "wake up" request.
  // It runs in the background and does not block the login screen.
  static Future<void> start() async {
    try {
      await http
          .get(Uri.parse(_backendUrl))
          .timeout(const Duration(seconds: 60));
    } catch (_) {
      // The app can still open even if Render takes too long or is offline.
    }
  }
}
