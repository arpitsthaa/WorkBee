import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/dashboard_model.dart';

class DashboardService {
  static const String _url =
      'https://workbee-zi7l.onrender.com/api/student-dashboard/';

  Future<DashboardModel> fetchDashboard(String accessToken) async {
    final response = await http.get(
      Uri.parse(_url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    ).timeout(const Duration(seconds: 12));

    if (response.statusCode != 200) {
      throw Exception('Failed to load dashboard (${response.statusCode})');
    }

    return DashboardModel(jsonDecode(response.body));
  }
}
