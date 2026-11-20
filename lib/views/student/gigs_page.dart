import 'package:flutter/material.dart';

class StudentGigsPage extends StatefulWidget {
  const StudentGigsPage({
    super.key,
    required this.gigs,
    required this.onRefresh,
  });

  final List<dynamic> gigs;
  final Future<void> Function() onRefresh;

  @override
  State<StudentGigsPage> createState() => _StudentGigsPageState();
}

class _StudentGigsPageState extends State<StudentGigsPage> {
  static const primaryBlue = Color(0xFF2563EB);
  static const darkNavy = Color(0xFF1E293B);
  static const mutedGrey = Color(0xFF64748B);
  static const cardBorder = Color(0xFFE2E8F0);
  static const lightBg = Color(0xFFF8FAFC);

  final _searchController = TextEditingController();
  String _category = 'Design & creative';
  String _budget = 'Any budget';
  String _sort = 'Newest first';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredGigs {
    final query = _searchController.text.trim().toLowerCase();
    final allGigs = widget.gigs
        .whereType<Map>()
        .map((gig) => Map<String, dynamic>.from(gig))
        .where((gig) {
          final title = '${gig['title'] ?? ''}'.toLowerCase();
          final business = '${gig['business_name'] ?? ''}'.toLowerCase();
          final category = '${gig['category'] ?? ''}'.toLowerCase();
          final categoryLabel = '${gig['category_label'] ?? ''}'.toLowerCase();
          final matchesSearch =
              query.isEmpty ||
              title.contains(query) ||
              business.contains(query) ||
              category.contains(query);
          final matchesCategory =
              _category == 'Any category' ||
              (category.isEmpty && categoryLabel.isEmpty) ||
              category.contains(_category.toLowerCase()) ||
              categoryLabel.contains(_category.toLowerCase());
          final budget = _budgetValue(gig);
          final matchesBudget = switch (_budget) {
            'Under NPR 2,500' => budget < 2500,
            'NPR 2,500 - 5,000' => budget >= 2500 && budget <= 5000,
            'Above NPR 5,000' => budget > 5000,
            _ => true,
          };
          return matchesSearch && matchesCategory && matchesBudget;
        })
        .toList();

    allGigs.sort((a, b) {
      if (_sort == 'Lowest budget') {
        return _budgetValue(a).compareTo(_budgetValue(b));
      }
      if (_sort == 'Highest budget') {
        return _budgetValue(b).compareTo(_budgetValue(a));
      }
      return '${b['due_date'] ?? ''}'.compareTo('${a['due_date'] ?? ''}');
    });

    return allGigs;
  }

  int _budgetValue(Map<String, dynamic> gig) {
    final value = '${gig['budget_npr'] ?? gig['budget'] ?? '0'}';
    return int.tryParse(value.replaceAll(RegExp(r'[^\d]'), '')) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final gigs = _filteredGigs;

    return Container(
      color: lightBg,
      child: RefreshIndicator(
        onRefresh: widget.onRefresh,
        color: primaryBlue,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            const Text(
              'Browse gigs',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: darkNavy,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Small projects. Real experiences.',
              style: TextStyle(fontSize: 13, color: mutedGrey),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search gigs or businesses',
                hintStyle: const TextStyle(fontSize: 14, color: mutedGrey),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: mutedGrey,
                  size: 21,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 13,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: cardBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: cardBorder),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _FilterDropdown(
                    value: _category,
                    items: const [
                      'Design & creative',
                      'Development',
                      'Marketing',
                      'Writing',
                      'Any category',
                    ],
                    onChanged: (value) => setState(() => _category = value),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _FilterDropdown(
                    value: _budget,
                    items: const [
                      'Any budget',
                      'Under NPR 2,500',
                      'NPR 2,500 - 5,000',
                      'Above NPR 5,000',
                    ],
                    onChanged: (value) => setState(() => _budget = value),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${gigs.length} ${gigs.length == 1 ? 'gig' : 'gigs'} for your skills',
                  style: const TextStyle(fontSize: 12, color: mutedGrey),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) => setState(() => _sort = value),
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'Newest first',
                      child: Text('Newest first'),
                    ),
                    PopupMenuItem(
                      value: 'Lowest budget',
                      child: Text('Lowest budget'),
                    ),
                    PopupMenuItem(
                      value: 'Highest budget',
                      child: Text('Highest budget'),
                    ),
                  ],
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _sort,
                        style: const TextStyle(fontSize: 12, color: mutedGrey),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 18,
                        color: mutedGrey,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (gigs.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: cardBorder),
                ),
                child: const Text(
                  'No gigs match your filters.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: mutedGrey),
                ),
              )
            else
              ...gigs.map(_buildGigCard),
          ],
        ),
      ),
    );
  }

  Widget _buildGigCard(Map<String, dynamic> gig) {
    final title = '${gig['title'] ?? 'Untitled gig'}';
    final category =
        '${gig['category_label'] ?? gig['category'] ?? 'General project'}';
    final business = '${gig['business_name'] ?? 'Business'}';
    final location = '${gig['location'] ?? 'Location not provided'}';
    final budget = '${gig['budget_npr'] ?? gig['budget'] ?? 'Price not set'}';
    final duration = '${gig['duration'] ?? ''}';
    final dueDate = '${gig['due_date'] ?? ''}';
    final workType = '${gig['work_type'] ?? 'Flexible'}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            business,
            style: const TextStyle(fontSize: 11, color: mutedGrey),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              height: 1.25,
              fontWeight: FontWeight.bold,
              color: darkNavy,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            '$category · $business',
            style: const TextStyle(fontSize: 12, color: mutedGrey),
          ),
          const SizedBox(height: 9),
          Text(
            budget,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: primaryBlue,
            ),
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: mutedGrey,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  location,
                  style: const TextStyle(fontSize: 12, color: mutedGrey),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  [
                    workType,
                    if (duration.isNotEmpty) duration,
                    if (dueDate.isNotEmpty) 'Due $dueDate',
                  ].join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: mutedGrey),
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => _showGigDetails(gig),
                style: TextButton.styleFrom(
                  foregroundColor: primaryBlue,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Details',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(Icons.arrow_forward_rounded, size: 14),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showGigDetails(Map<String, dynamic> gig) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        final description =
            '${gig['description'] ?? 'No description has been added for this gig yet.'}';
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cardBorder,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${gig['title'] ?? 'Untitled gig'}',
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: darkNavy,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${gig['business_name'] ?? 'Business'}',
                style: const TextStyle(fontSize: 13, color: mutedGrey),
              ),
              const SizedBox(height: 18),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: darkNavy,
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Apply for this gig',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: (value) {
            if (value != null) onChanged(value);
          },
        ),
      ),
    );
  }
}
