import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:reliefnet_app/core/theme/app_theme.dart';
import 'package:reliefnet_app/models/donation_model.dart';
import 'package:reliefnet_app/providers/donation_provider.dart';
import 'package:reliefnet_app/widgets/empty_state.dart';
import 'package:reliefnet_app/widgets/error_view.dart';
import 'package:reliefnet_app/widgets/shimmer_card.dart';

class ActivityFeedScreen extends ConsumerWidget {
  const ActivityFeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final donationsAsync = ref.watch(myDonationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Donation Activity'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(myDonationsProvider),
          ),
        ],
      ),
      body: donationsAsync.when(
        loading: () => const ShimmerList(count: 6, itemHeight: 100),
        error: (err, _) => ErrorView(
          message: 'Could not load activity.',
          onRetry: () => ref.invalidate(myDonationsProvider),
        ),
        data: (donations) {
          if (donations.isEmpty) {
            return const EmptyState(
              icon: Icons.volunteer_activism_outlined,
              title: 'No donations yet',
              subtitle: 'Your donation history will appear here once you contribute to a campaign.',
            );
          }

          // Group by status for the summary header
          final confirmed = donations.where((d) => d.status == 'CONFIRMED').length;
          final pending = donations.where((d) => d.status == 'PENDING').length;
          final totalPkr = donations
              .where((d) => d.status == 'CONFIRMED')
              .fold<double>(0, (sum, d) => sum + d.amountPkr);

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(myDonationsProvider),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _SummaryBar(
                    totalPkr: totalPkr,
                    confirmed: confirmed,
                    pending: pending,
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => _ActivityCard(donation: donations[i]),
                      childCount: donations.length,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SummaryBar extends StatelessWidget {
  final double totalPkr;
  final int confirmed;
  final int pending;

  const _SummaryBar({required this.totalPkr, required this.confirmed, required this.pending});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0');
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryColor, Color(0xFF0E7490)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.volunteer_activism, color: Colors.white70, size: 16),
              SizedBox(width: 6),
              Text('Total Impact', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Rs ${fmt.format(totalPkr)}',
            style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.5),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _SummaryChip(label: '$confirmed Confirmed', color: Colors.greenAccent.shade400),
              const SizedBox(width: 8),
              if (pending > 0)
                _SummaryChip(label: '$pending Pending', color: Colors.amberAccent.shade200),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final Color color;

  const _SummaryChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final DonationModel donation;

  const _ActivityCard({required this.donation});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0');
    final amount = 'Rs ${fmt.format(donation.amountPkr)}';

    String? dateLabel;
    if (donation.createdAt != null) {
      final dt = DateTime.tryParse(donation.createdAt!);
      if (dt != null) {
        dateLabel = DateFormat('dd MMM yyyy · hh:mm a').format(dt.toLocal());
      }
    }

    final (statusColor, statusText, statusIcon) = switch (donation.status) {
      'CONFIRMED' => (AppTheme.successColor, 'Confirmed', Icons.check_circle_outline),
      'REJECTED' => (AppTheme.errorColor, 'Rejected', Icons.cancel_outlined),
      _ => (AppTheme.warningColor, 'Pending', Icons.schedule_outlined),
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: donation.campaignId != null
            ? () => context.push('/donor/campaign/${donation.campaignId}')
            : null,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status icon circle
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(statusIcon, color: statusColor, size: 20),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            donation.campaignTitle ?? 'Direct Donation',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          amount,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.primaryColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(statusText, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor)),
                        ),
                        if (dateLabel != null) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.access_time, size: 11, color: AppTheme.textDisabled),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(dateLabel, style: const TextStyle(fontSize: 11, color: AppTheme.textDisabled), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ],
                    ),
                    if (donation.campaignId != null) ...[
                      const SizedBox(height: 4),
                      const Row(
                        children: [
                          Icon(Icons.open_in_new, size: 11, color: AppTheme.primaryColor),
                          SizedBox(width: 3),
                          Text('View campaign', style: TextStyle(fontSize: 11, color: AppTheme.primaryColor, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
