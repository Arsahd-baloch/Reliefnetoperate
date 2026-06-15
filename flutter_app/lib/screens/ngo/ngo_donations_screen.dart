import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:reliefnet_app/core/api/api_client.dart';
import 'package:reliefnet_app/models/donation_model.dart';
import 'package:reliefnet_app/widgets/empty_state.dart';
import 'package:reliefnet_app/widgets/error_view.dart';
import 'package:url_launcher/url_launcher.dart';

// ── Provider for NGO specific donations ──

final ngoDonationsProvider = FutureProvider.family<List<DonationModel>, String?>((ref, status) async {
  final client = ref.read(apiClientProvider);
  final response = await client.get('/donations/ngo', queryParameters: status != null ? {'status': status} : null);
  final list = (response.data['data'] as List? ?? []);
  return list.map((d) => DonationModel.fromJson(d as Map<String, dynamic>)).toList();
});

class NgoDonationsScreen extends ConsumerStatefulWidget {
  const NgoDonationsScreen({super.key});

  @override
  ConsumerState<NgoDonationsScreen> createState() => _NgoDonationsScreenState();
}

class _NgoDonationsScreenState extends ConsumerState<NgoDonationsScreen> {
  String _selectedStatus = 'PENDING';

  @override
  Widget build(BuildContext context) {
    final donationsAsync = ref.watch(ngoDonationsProvider(_selectedStatus));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Donation Verification'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _StatusTab(
                  label: 'Pending',
                  selected: _selectedStatus == 'PENDING',
                  onTap: () => setState(() => _selectedStatus = 'PENDING'),
                ),
                _StatusTab(
                  label: 'Confirmed',
                  selected: _selectedStatus == 'CONFIRMED',
                  onTap: () => setState(() => _selectedStatus = 'CONFIRMED'),
                ),
                _StatusTab(
                  label: 'Rejected',
                  selected: _selectedStatus == 'REJECTED',
                  onTap: () => setState(() => _selectedStatus = 'REJECTED'),
                ),
              ],
            ),
          ),
        ),
      ),
      body: donationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(
          message: 'Failed to load donations',
          onRetry: () => ref.invalidate(ngoDonationsProvider(_selectedStatus)),
        ),
        data: (donations) {
          if (donations.isEmpty) {
            return EmptyState(
              icon: Icons.payments_outlined,
              title: 'No $_selectedStatus donations',
              subtitle: 'New donation requests will appear here.',
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(ngoDonationsProvider(_selectedStatus)),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: donations.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _DonationCard(
                donation: donations[index],
                onAction: () => ref.invalidate(ngoDonationsProvider(_selectedStatus)),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StatusTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _StatusTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? Theme.of(context).primaryColor : Colors.grey;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? color : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? color : Colors.grey.shade700,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _DonationCard extends ConsumerStatefulWidget {
  final DonationModel donation;
  final VoidCallback onAction;

  const _DonationCard({required this.donation, required this.onAction});

  @override
  ConsumerState<_DonationCard> createState() => _DonationCardState();
}

class _DonationCardState extends ConsumerState<_DonationCard> {
  bool _busy = false;

  Future<void> _handleAction(bool approve) async {
    setState(() => _busy = true);
    try {
      final client = ref.read(apiClientProvider);
      final endpoint = approve ? 'approve' : 'reject';
      await client.post('/donations/${widget.donation.id}/$endpoint');
      widget.onAction();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to ${approve ? 'approve' : 'reject'}: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = widget.donation.createdAt != null 
        ? DateFormat('MMM d, h:mm a').format(DateTime.parse(widget.donation.createdAt!))
        : '';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Rs ${widget.donation.amountPkr.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.green),
                ),
                Text(
                  date,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Campaign: ${widget.donation.campaignTitle ?? "N/A"}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text('Donor: ${widget.donation.donorName ?? "Anonymous"}'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Manual Transfer Details:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Ref: ${widget.donation.referenceNumber ?? "N/A"}', style: const TextStyle(fontFamily: 'monospace')),
                  if (widget.donation.receiptUrl != null) ...[
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final url = Uri.tryParse(widget.donation.receiptUrl!);
                        if (url != null && await canLaunchUrl(url)) {
                          await launchUrl(url, mode: LaunchMode.externalApplication);
                        }
                      },
                      child: const Row(
                        children: [
                          Icon(Icons.image, size: 16, color: Colors.blue),
                          SizedBox(width: 4),
                          Text('View Payment Proof', style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline, fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (widget.donation.status == 'PENDING') ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _busy ? null : () => _handleAction(false),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Reject'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _busy ? null : () => _handleAction(true),
                      style: FilledButton.styleFrom(backgroundColor: Colors.green),
                      child: const Text('Confirm Receipt'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
