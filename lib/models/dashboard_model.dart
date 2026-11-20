class DashboardModel {
  final Map<String, dynamic> data;

  const DashboardModel(this.data);

  String get firstName => data['first_name'] ?? 'Student';
  String get initials => data['initials'] ?? 'WB';
  bool get isVerified => data['is_verified'] ?? false;
  int get profileCompletion => data['profile_completion'] ?? 0;
  String get profileTip => data['profile_tip'] ?? '';
  List<dynamic> get recommendedGigs => data['recommended_gigs'] ?? [];
  Map<String, dynamic> get applications => data['applications'] ?? {};
  Map<String, dynamic> get projects => data['projects'] ?? {};
  Map<String, dynamic> get passport => data['passport'] ?? {};
}
