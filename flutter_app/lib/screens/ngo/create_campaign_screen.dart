import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reliefnet_app/core/theme/app_theme.dart';
import 'package:reliefnet_app/providers/campaign_provider.dart';

class CreateCampaignScreen extends ConsumerStatefulWidget {
  const CreateCampaignScreen({super.key});

  @override
  ConsumerState<CreateCampaignScreen> createState() => _CreateCampaignScreenState();
}

class _CreateCampaignScreenState extends ConsumerState<CreateCampaignScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _goalController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.lightImpact();
    setState(() => _submitting = true);
    try {
      final repo = ref.read(campaignRepoProvider);
      await repo.createCampaign(
        title: _titleController.text.trim(),
        description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
        goalPkr: double.parse(_goalController.text.trim()),
      );
      HapticFeedback.heavyImpact();
      ref.invalidate(allCampaignsProvider);
      ref.invalidate(campaignsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Campaign created! It is pending admin approval.'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        context.pop();
      }
    } catch (e) {
      setState(() => _submitting = false);
      if (!mounted) return;
      final msg = e.toString().contains('403') || e.toString().contains('not verified')
          ? 'Your NGO profile must be verified before creating campaigns.'
          : 'Failed to create campaign. Please try again.';
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Campaign Creation Failed'),
          content: Text(msg),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Campaign')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Info banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.infoColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.infoColor.withValues(alpha: 0.25)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AppTheme.infoColor, size: 18),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'New campaigns start as DRAFT and require admin approval before going live.',
                      style: TextStyle(fontSize: 12, color: AppTheme.infoColor),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Title
            TextFormField(
              controller: _titleController,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Campaign Title *',
                hintText: 'e.g. Flood Relief — Sindh 2026',
                prefixIcon: Icon(Icons.campaign_outlined, size: 20),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Title is required';
                if (v.trim().length < 5) return 'Title must be at least 5 characters';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descController,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.next,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'Describe the purpose, target area, and people this campaign will help...',
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 56),
                  child: Icon(Icons.description_outlined, size: 20),
                ),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),

            // Goal amount
            TextFormField(
              controller: _goalController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Fundraising Goal (PKR) *',
                prefixText: 'Rs ',
                hintText: 'e.g. 500000',
                prefixIcon: Icon(Icons.account_balance_wallet_outlined, size: 20),
                helperText: 'Minimum Rs 1,000',
              ),
              validator: (v) {
                final parsed = double.tryParse(v?.trim() ?? '');
                if (parsed == null || parsed <= 0) return 'Please enter a valid goal amount';
                if (parsed < 1000) return 'Minimum fundraising goal is Rs 1,000';
                return null;
              },
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
                    : const Icon(Icons.save_outlined),
                label: Text(_submitting ? 'Creating...' : 'Create Campaign'),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
