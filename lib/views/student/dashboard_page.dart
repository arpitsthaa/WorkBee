import 'package:flutter/material.dart';

import '../../controllers/dashboard_controller.dart';
import '../auth/login_page.dart';

class StudentDashboardPage extends StatefulWidget {
  final String accessToken;

  const StudentDashboardPage({super.key, required this.accessToken});

  @override
  State<StudentDashboardPage> createState() => _StudentDashboardPageState();
}

class _StudentDashboardPageState extends State<StudentDashboardPage> {
  late final DashboardController _controller;
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color softBlueBg = Color(0xFFEFF6FF);
  static const Color darkNavy = Color(0xFF1E293B);
  static const Color mutedGrey = Color(0xFF64748B);
  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color cardBorder = Color(0xFFE2E8F0);

  int _selectedIndex = 0;
  @override
  void initState() {
    super.initState();
    _controller = DashboardController(accessToken: widget.accessToken);
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    await _controller.loadDashboard();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = _controller.isLoading;
    final errorMessage = _controller.errorMessage;
    return Scaffold(
      backgroundColor: lightBg,
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: primaryBlue))
            : errorMessage != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      errorMessage,
                      style: const TextStyle(color: mutedGrey),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _fetchDashboardData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                      ),
                      child: const Text(
                        'Retry',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              )
            : _selectedIndex == 4
            ? SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: _buildProfileContent(),
              )
            : RefreshIndicator(
                onRefresh: _fetchDashboardData,
                color: primaryBlue,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: _buildHomeContent(),
                ),
              ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildHomeContent() {
    final data = _controller.dashboard!.data;
    final String firstName = data['first_name'] ?? 'Student';
    final String initials = data['initials'] ?? 'WB';
    final bool isVerified = data['is_verified'] ?? false;
    final int completion = data['profile_completion'] ?? 0;
    final String profileTip = data['profile_tip'] ?? '';
    final List<dynamic> gigs = data['recommended_gigs'] ?? [];
    final Map<String, dynamic> apps = data['applications'] ?? {};
    final Map<String, dynamic> projects = data['projects'] ?? {};
    final Map<String, dynamic> passport = data['passport'] ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Brand Header & Avatar Initials
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primaryBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.diamond_outlined,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WorkBee',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: darkNavy,
                      ),
                    ),
                    Text(
                      'Bee Busy Be Paid',
                      style: TextStyle(fontSize: 11, color: mutedGrey),
                    ),
                  ],
                ),
              ],
            ),
            CircleAvatar(
              radius: 20,
              backgroundColor: softBlueBg,
              child: Text(
                initials,
                style: const TextStyle(
                  color: primaryBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 22),

        // Dynamic Greeting
        Text(
          'Hi, $firstName!',
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: darkNavy,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Your next opportunity starts here.',
          style: TextStyle(fontSize: 14, color: mutedGrey),
        ),

        const SizedBox(height: 12),

        // Verified Pill Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: softBlueBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isVerified ? Icons.check : Icons.hourglass_empty_rounded,
                size: 15,
                color: primaryBlue,
              ),
              const SizedBox(width: 6),
              Text(
                isVerified ? 'Student verified' : 'Verification pending',
                style: const TextStyle(
                  color: primaryBlue,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // Profile Completion Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: softBlueBg,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Profile $completion% complete',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: darkNavy,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() => _selectedIndex = 4);
                    },
                    child: const Text(
                      'Edit',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: primaryBlue,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: (completion / 100).clamp(0.0, 1.0),
                  minHeight: 6,
                  backgroundColor: Colors.white,
                  valueColor: const AlwaysStoppedAnimation<Color>(primaryBlue),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                profileTip,
                style: const TextStyle(fontSize: 12, color: mutedGrey),
              ),
            ],
          ),
        ),

        const SizedBox(height: 22),

        // Recommended Gigs Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recommended gigs',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: darkNavy,
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() => _selectedIndex = 1);
              },
              child: const Text(
                'View all →',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: primaryBlue,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Dynamic Gig Cards
        if (gigs.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: cardBorder),
            ),
            child: const Text(
              'No gigs available right now. Pull down to refresh.',
              style: TextStyle(color: mutedGrey, fontSize: 13),
            ),
          )
        else
          ...gigs.map((gig) => _buildGigCard(gig)),

        const SizedBox(height: 8),

        // Applications & Projects Stats Row
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: '${apps['total'] ?? 0} applications',
                subtitle:
                    '${apps['pending'] ?? 0} pending · ${apps['shortlisted'] ?? 0} shortlisted',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: '${projects['total'] ?? 0} projects',
                subtitle:
                    '${projects['active'] ?? 0} active · ${projects['approved'] ?? 0} approved',
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Career Passport Card
        GestureDetector(
          onTap: () {
            setState(() => _selectedIndex = 3);
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: softBlueBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.verified_outlined,
                    color: primaryBlue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Career Passport →',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${passport['verified_projects'] ?? 0} verified projects · ${passport['average_rating'] ?? 0.0}/5 average rating',
                        style: const TextStyle(fontSize: 12, color: mutedGrey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildGigCard(Map<String, dynamic> gig) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            gig['title'] ?? '',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: darkNavy,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${gig['business_name']} · ${gig['location']}',
            style: const TextStyle(fontSize: 13, color: mutedGrey),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                gig['budget_npr'] ?? '',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: primaryBlue,
                ),
              ),
              Text(
                '${gig['duration']} · ${gig['due_date']}',
                style: const TextStyle(fontSize: 12, color: mutedGrey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({required String title, required String subtitle}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: darkNavy,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 11, color: mutedGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent() {
    final data = _controller.dashboard!.data;
    final String firstName = data['first_name'] ?? 'Student';
    final String initials = data['initials'] ?? 'WB';
    final String email = data['email'] ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Profile',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: darkNavy,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: cardBorder),
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 38,
                backgroundColor: softBlueBg,
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: primaryBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                firstName,
                style: const TextStyle(
                  color: darkNavy,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (email.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  email,
                  style: const TextStyle(color: mutedGrey, fontSize: 13),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded),
            label: const Text(
              'Log out',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFDC2626),
              side: const BorderSide(color: Color(0xFFFCA5A5)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _logout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  Widget _buildBottomNavBar() {
    final items = [
      {
        'icon': Icons.home_outlined,
        'activeIcon': Icons.home_rounded,
        'label': 'Home',
      },
      {
        'icon': Icons.search_rounded,
        'activeIcon': Icons.search_rounded,
        'label': 'Gigs',
      },
      {
        'icon': Icons.work_outline_rounded,
        'activeIcon': Icons.work_rounded,
        'label': 'My work',
      },
      {
        'icon': Icons.verified_outlined,
        'activeIcon': Icons.verified_rounded,
        'label': 'Passport',
      },
      {
        'icon': Icons.person_outline_rounded,
        'activeIcon': Icons.person_rounded,
        'label': 'Profile',
      },
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: cardBorder)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (index) {
            final isSelected = _selectedIndex == index;
            final item = items[index];
            return GestureDetector(
              onTap: () => setState(() => _selectedIndex = index),
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? softBlueBg : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      (isSelected ? item['activeIcon'] : item['icon'])
                          as IconData,
                      color: isSelected ? primaryBlue : mutedGrey,
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item['label'] as String,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: isSelected ? primaryBlue : mutedGrey,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
