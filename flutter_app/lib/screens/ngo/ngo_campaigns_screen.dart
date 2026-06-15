import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:reliefnet_app/core/theme/app_theme.dart';
import 'package:reliefnet_app/features/auth/presentation/auth_provider.dart';
import 'package:reliefnet_app/models/campaign_model.dart';
import 'package:reliefnet_app/providers/campaign_provider.dart';
import 'package:reliefnet_app/widgets/error_view.dart';
import 'package:reliefnet_app/widgets/empty_state.dart';
import 'package:reliefnet_app/widgets/shimmer_card.dart';

class NgoCampaignsScreen extends ConsumerStatefulWidget {
  const NgoCampaignsScreen({super.key});

  @override
  ConsumerState<NgoCampaignsScreen> createState() => _NgoCampaignsScreenState();
}

class _NgoCampaignsScreenState extends ConsumerState<NgoCampaignsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _tabs = ['All', 'Active', 'Paused', 'Draft'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<CampaignModel> _filter(List<CampaignModel> all, int tabIdx) {
    switch (tabIdx) {
      case 1:
        return all.where((c) => c.status == 'ACTIVE').toList();
      case 2:
        return all.where((c) => c.status == 'PAUSED').toList();
      case 3:
        return all.where((c) => c.status == 'DRAFT' || c.status == 'PENDING_APPROVAL').toList();
      default:
        return all;
    }
  }

  @override
  Widget build(BuildContext context, ) {
    final campaignsAsync = ref.watch(allCampaignsProvider);
    final user = ref.watch(authProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Campaigns'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Create Campaign',
            onPressed: () => context.push('/ngo/create-campaign'),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(allCampaignsProvider),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withValues(alpha: 0.65),
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          dividerColor: Colors.transparent,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'ngo_create_campaign_fab',
        onPressed: () => context.push('/ngo/create-campaign'),
        icon: const Icon(Icons.add),
        label: const Text('New Campaign'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: campaignsAsync.when(
        loading: () => const ShimmerList(count: 4, itemHeight: 140),
        error: (err, _) => ErrorView(
          message: 'Failed to load campaigns.',
          onRetry: () => ref.invalidate(allCampaignsProvider),
        ),
        data: (all) {
          final myCampaigns = user != null
              ? all.where((c) => c.createdBy == user.id).toList()
              : all;
          final filtered = _filter(myCampaigns, _tabController.index);

          if (myCampaigns.isEmpty) {
            return EmptyState(
              icon: Icons.campaign_outlined,
              title: 'No campaigns yet',
              subtitle: 'Create your first campaign to start raising funds.',
              ctaLabel: 'Create Campaign',
              onCta: () => context.push('/ngo/create-campaign'),
            );
          }

          if (filtered.isEmpty) {
            return EmptyState(
              icon: Icons.filter_list_outlined,
              title: 'No ${_tabs[_tabController.index].toLowerCase()} campaigns',
              subtitle: 'Switch to a different tab to see your other campaigns.',
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(allCampaignsProvider),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                return _CampaignCard(campaign: filtered[index]);
              },
            ),
          );
        },
      ),
    );
  }
}

class _CampaignCard extends StatelessWidget {
  final CampaignModel campaign;
  const _CampaignCard({required this.campaign});

  Color _statusColor() {
    switch (campaign.status) {
      case 'ACTIVE':
        return AppTheme.successColor;
      case 'PAUSED':
        return AppTheme.warningColor;
      case 'CLOSED':
      case 'REJECTED':
        return AppTheme.errorColor;
      case 'DRAFT':
      case 'PENDING_APPROVAL':
        return AppTheme.infoColor;
      default:
        return AppTheme.textDisabled;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pct = (campaign.progressFraction * 100).round();
    final color = _statusColor();

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/ngo/campaign-report/${campaign.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Expanded(
                    child: Text(
                      campaign.title,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StatusBadge(status: campaign.status, color: color),
                ],
              ),
              if (campaign.description != null && campaign.description!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  campaign.description!,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 14),

              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: campaign.progressFraction,
                  backgroundColor: Colors.grey.shade100,
                  color: color,
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 8),

              // Stats row
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Rs ${NumberFormat('#,##0').format(campaign.raisedPkr)} raised',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    'Goal: Rs ${NumberFormat('#,##0').format(campaign.goalPkr)}',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$pct%',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Action row
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => context.push('/ngo/create-task?campaignId=${campaign.id}'),
                    icon: const Icon(Icons.add_task, size: 16),
                    label: const Text('Add Task'),
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => context.push('/ngo/campaign-report/${campaign.id}'),
                    icon: const Icon(Icons.analytics_outlined, size: 16),
                    label: const Text('Report'),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final Color color;
  const _StatusBadge({required this.status, required this.color});

  String get _label {
    switch (status) {
      case 'PENDING_APPROVAL': return 'Pending';
      default: return status[0] + status.substring(1).toLowerCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        _label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700),
      ),
    );
  }
}
