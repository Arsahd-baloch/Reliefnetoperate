import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:reliefnet_app/core/theme/app_theme.dart';
import 'package:reliefnet_app/providers/coordinator_volunteers_provider.dart';
import 'package:reliefnet_app/widgets/empty_state.dart';
import 'package:reliefnet_app/widgets/error_view.dart';
import 'package:reliefnet_app/widgets/shimmer_card.dart';

class CoordinatorVolunteerScreen extends ConsumerStatefulWidget {
  const CoordinatorVolunteerScreen({super.key});

  @override
  ConsumerState<CoordinatorVolunteerScreen> createState() => _CoordinatorVolunteerScreenState();
}

class _CoordinatorVolunteerScreenState extends ConsumerState<CoordinatorVolunteerScreen> {
  String _searchQuery = '';
  String _filterStatus = 'All';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final volunteersAsync = ref.watch(coordinatorVolunteersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Field Volunteers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(coordinatorVolunteersProvider),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search + filter bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search volunteers...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
                const SizedBox(height: 10),
                Row(
                  children: ['All', 'Active', 'Inactive'].map((s) {
                    final selected = _filterStatus == s;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(s),
                        selected: selected,
                        showCheckmark: false,
                        visualDensity: VisualDensity.compact,
                        onSelected: (_) => setState(() => _filterStatus = s),
                        selectedColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                        side: BorderSide(
                          color: selected ? AppTheme.primaryColor : Colors.grey.shade300,
                          width: selected ? 1.5 : 1,
                        ),
                        labelStyle: TextStyle(
                          color: selected ? AppTheme.primaryColor : Colors.grey.shade700,
                          fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),

          // List
          Expanded(
            child: volunteersAsync.when(
              loading: () => const ShimmerList(count: 5, itemHeight: 130),
              error: (err, _) => ErrorView(
                message: 'Could not load volunteers.',
                onRetry: () => ref.invalidate(coordinatorVolunteersProvider),
              ),
              data: (volunteers) {
                var filtered = volunteers;

                // Apply search
                if (_searchQuery.isNotEmpty) {
                  final q = _searchQuery.toLowerCase();
                  filtered = filtered
                      .where((v) =>
                          v.name.toLowerCase().contains(q) ||
                          v.email.toLowerCase().contains(q))
                      .toList();
                }

                // Apply status filter
                if (_filterStatus == 'Active') {
                  filtered = filtered.where((v) => v.status == 'ACTIVE').toList();
                } else if (_filterStatus == 'Inactive') {
                  filtered = filtered.where((v) => v.status != 'ACTIVE').toList();
                }

                if (volunteers.isEmpty) {
                  return const EmptyState(
                    icon: Icons.people_outline,
                    title: 'No volunteers found',
                    subtitle: 'Volunteers assigned to your area will appear here.',
                  );
                }

                if (filtered.isEmpty) {
                  return EmptyState(
                    icon: Icons.search_off_outlined,
                    title: 'No results',
                    subtitle: 'Try adjusting your search or filter.',
                    ctaLabel: 'Clear',
                    onCta: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                        _filterStatus = 'All';
                      });
                    },
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(coordinatorVolunteersProvider),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      return _VolunteerCard(volunteer: filtered[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _VolunteerCard extends StatelessWidget {
  final dynamic volunteer;
  const _VolunteerCard({required this.volunteer});

  @override
  Widget build(BuildContext context) {
    final isActive = volunteer.status == 'ACTIVE';
    final statusColor = isActive ? AppTheme.successColor : AppTheme.warningColor;
    final initial = volunteer.name.isNotEmpty ? volunteer.name[0].toUpperCase() : '?';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                  child: Text(
                    initial,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        volunteer.name,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        volunteer.email,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                _StatusDot(color: statusColor, label: isActive ? 'Active' : 'Inactive'),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(
                  icon: Icons.pending_actions_outlined,
                  label: 'Active',
                  value: volunteer.activeTasks.toString(),
                  color: AppTheme.infoColor,
                ),
                _StatItem(
                  icon: Icons.check_circle_outline,
                  label: 'Done',
                  value: volunteer.completedTasks.toString(),
                  color: AppTheme.successColor,
                ),
                _StatItem(
                  icon: Icons.star_outline,
                  label: 'Rating',
                  value: volunteer.rating.toStringAsFixed(1),
                  color: AppTheme.warningColor,
                ),
              ],
            ),
            if (volunteer.lastActivity != null) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.access_time, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      'Last active: ${DateFormat('MMM d, HH:mm').format(DateTime.parse(volunteer.lastActivity!))}',
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  final Color color;
  final String label;
  const _StatusDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: color)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}
