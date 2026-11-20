import 'package:flutter/foundation.dart';
import '../models/dashboard_model.dart';
import '../services/dashboard_service.dart';

class DashboardController extends ChangeNotifier {
  DashboardController({
    required this.accessToken,
    DashboardService? service,
  }) : _service = service ?? DashboardService();

  final String accessToken;
  final DashboardService _service;

  DashboardModel? dashboard;
  bool isLoading = true;
  String? errorMessage;

  Future<void> loadDashboard() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      dashboard = await _service.fetchDashboard(accessToken);
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
