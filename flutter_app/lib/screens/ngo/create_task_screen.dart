import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reliefnet_app/core/api/api_client.dart';
import 'package:reliefnet_app/core/api/api_constants.dart';
import 'package:reliefnet_app/core/theme/app_theme.dart';
import 'package:reliefnet_app/providers/campaign_provider.dart';

class NgoCreateTaskScreen extends ConsumerStatefulWidget {
  final int? campaignId;

  const NgoCreateTaskScreen({super.key, this.campaignId});

  @override
  ConsumerState<NgoCreateTaskScreen> createState() => _NgoCreateTaskScreenState();
}

class _NgoCreateTaskScreenState extends ConsumerState<NgoCreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController();
  final _budgetController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  String _urgency = 'MEDIUM';
  String _category = 'GENERAL';
  int _familySize = 1;
  bool _submitting = false;

  final List<String> _urgencies = ['LOW', 'MEDIUM', 'HIGH', 'CRITICAL'];
  final List<String> _categories = ['GENERAL', 'FOOD', 'MEDICAL', 'SHELTER', 'EDUCATION', 'WATER'];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _locationController.dispose();
    _budgetController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.lightImpact();
    setState(() => _submitting = true);

    try {
      final client = ref.read(apiClientProvider);
      await client.post(ApiConstants.createTask, data: {
        'title': _titleController.text.trim(),
        if (_descController.text.trim().isNotEmpty)
          'description': _descController.text.trim(),
        if (widget.campaignId != null) 'campaign_id': widget.campaignId,
        'source_type': 'NGO_CAMPAIGN',
        'category': _category,
        'family_size': _familySize,
        'latitude': double.parse(_latController.text.trim()),
        'longitude': double.parse(_lngController.text.trim()),
        if (_locationController.text.trim().isNotEmpty)
          'location_text': _locationController.text.trim(),
        'urgency': _urgency,
        'budget_pkr': double.tryParse(_budgetController.text.trim()) ?? 0,
        'items_needed': [],
        'radius_km': 10,
      });

      HapticFeedback.heavyImpact();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task created! Volunteers can now discover and claim it.'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        context.pop();
      }
    } catch (e) {
      setState(() => _submitting = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create task: ${e.toString().split(':').last.trim()}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  Color _urgencyColor(String u) {
    switch (u) {
      case 'CRITICAL': return AppTheme.urgencyCritical;
      case 'HIGH': return AppTheme.urgencyHigh;
      case 'MEDIUM': return AppTheme.urgencyMedium;
      default: return AppTheme.urgencyLow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.campaignId != null ? 'Add Task to Campaign' : 'Create Task'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (widget.campaignId != null) ...[
              _buildCampaignBadge(),
              const SizedBox(height: 16),
            ],

            // Title
            TextFormField(
              controller: _titleController,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Task Title *',
                hintText: 'e.g. Food distribution — Larkana District',
                prefixIcon: Icon(Icons.assignment_outlined, size: 20),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Title is required' : null,
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descController,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.next,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Instructions / Description',
                hintText: 'Describe what the volunteer needs to do...',
                alignLabelWithHint: true,
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 40),
                  child: Icon(Icons.notes_outlined, size: 20),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Urgency & Category row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Urgency', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        children: _urgencies.map((u) {
                          final selected = _urgency == u;
                          final color = _urgencyColor(u);
                          return GestureDetector(
                            onTap: () => setState(() => _urgency = u),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: selected ? color.withValues(alpha: 0.15) : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: selected ? color : Colors.grey.shade300,
                                  width: selected ? 1.5 : 1,
                                ),
                              ),
                              child: Text(
                                u,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: selected ? color : Colors.grey.shade600,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Category
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.category_outlined, size: 20),
              ),
              items: _categories
                  .map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(c[0] + c.substring(1).toLowerCase()),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 16),

            // Family size
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Family / Household Size',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
                IconButton(
                  onPressed: _familySize > 1 ? () => setState(() => _familySize--) : null,
                  icon: const Icon(Icons.remove_circle_outline),
                  color: AppTheme.primaryColor,
                ),
                SizedBox(
                  width: 36,
                  child: Text(
                    '$_familySize',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ),
                IconButton(
                  onPressed: _familySize < 50 ? () => setState(() => _familySize++) : null,
                  icon: const Icon(Icons.add_circle_outline),
                  color: AppTheme.primaryColor,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Budget
            TextFormField(
              controller: _budgetController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Budget (PKR) — optional',
                prefixText: 'Rs ',
                prefixIcon: Icon(Icons.payments_outlined, size: 20),
                hintText: '0 for volunteer work',
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Location',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 4),
            const Text(
              'GPS coordinates are required so volunteers can find the task on the map.',
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 12),

            // Location text
            TextFormField(
              controller: _locationController,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Location Description',
                hintText: 'e.g. Village Kot Diji, Khairpur District',
                prefixIcon: Icon(Icons.location_on_outlined, size: 20),
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _latController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Latitude *',
                      hintText: '24.8607',
                      prefixIcon: Icon(Icons.explore_outlined, size: 20),
                    ),
                    validator: (v) {
                      final d = double.tryParse(v?.trim() ?? '');
                      if (d == null) return 'Required';
                      if (d < -90 || d > 90) return 'Invalid';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _lngController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: 'Longitude *',
                      hintText: '67.0104',
                    ),
                    validator: (v) {
                      final d = double.tryParse(v?.trim() ?? '');
                      if (d == null) return 'Required';
                      if (d < -180 || d > 180) return 'Invalid';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Row(
              children: [
                Icon(Icons.info_outline, size: 14, color: AppTheme.textDisabled),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Pakistan latitude: 23–37, longitude: 60–77',
                    style: TextStyle(fontSize: 11, color: AppTheme.textDisabled),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: _submitting ? null : _submit,
                icon: _submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.add_task),
                label: Text(_submitting ? 'Creating Task...' : 'Create Task'),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildCampaignBadge() {
    final campaignsAsync = ref.watch(allCampaignsProvider);
    return campaignsAsync.when(
      data: (list) {
        final campaign = list.where((c) => c.id == widget.campaignId).firstOrNull;
        if (campaign == null) return const SizedBox.shrink();
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.campaign_outlined, color: AppTheme.primaryColor, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Linked Campaign', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
                    Text(campaign.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.primaryColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
