import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reliefnet_app/core/theme/app_theme.dart';
import 'package:reliefnet_app/providers/ngo_provider.dart';
import 'package:reliefnet_app/widgets/error_view.dart';

class NgoProfileSettingsScreen extends ConsumerStatefulWidget {
  const NgoProfileSettingsScreen({super.key});

  @override
  ConsumerState<NgoProfileSettingsScreen> createState() => _NgoProfileSettingsScreenState();
}

class _NgoProfileSettingsScreenState extends ConsumerState<NgoProfileSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _bankNameController;
  late TextEditingController _accTitleController;
  late TextEditingController _accNumberController;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _bankNameController = TextEditingController();
    _accTitleController = TextEditingController();
    _accNumberController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bankNameController.dispose();
    _accTitleController.dispose();
    _accNumberController.dispose();
    super.dispose();
  }

  void _initialize(dynamic profile) {
    if (_initialized) return;
    _nameController.text = profile.orgName;
    _bankNameController.text = profile.bankName ?? '';
    _accTitleController.text = profile.accountTitle ?? '';
    _accNumberController.text = profile.accountNumber ?? '';
    _initialized = true;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.lightImpact();

    final body = {
      'org_name': _nameController.text.trim(),
      'bank_name': _bankNameController.text.trim().isEmpty ? null : _bankNameController.text.trim(),
      'account_title': _accTitleController.text.trim().isEmpty ? null : _accTitleController.text.trim(),
      'account_number': _accNumberController.text.trim().isEmpty ? null : _accNumberController.text.trim(),
    };

    await ref.read(ngoProfileActionsProvider.notifier).updateProfile(body);
    if (!mounted) return;

    final state = ref.read(ngoProfileActionsProvider);
    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save: ${state.error}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } else {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(ngoProfileProvider);
    final actionsState = ref.watch(ngoProfileActionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('NGO Settings'),
        actions: [
          if (actionsState.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(right: 16),
                child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
              ),
            )
          else
            TextButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save_outlined, size: 18),
              label: const Text('Save'),
              style: TextButton.styleFrom(foregroundColor: AppTheme.primaryColor),
            ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(
          message: 'Failed to load NGO profile.',
          onRetry: () => ref.invalidate(ngoProfileProvider),
        ),
        data: (profile) {
          _initialize(profile);
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Verification status banner
                _buildVerificationBanner(profile),
                const SizedBox(height: 24),

                const _SectionLabel(
                  icon: Icons.business_outlined,
                  title: 'Organization',
                  subtitle: 'Basic identity information',
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Organization Name *',
                    prefixIcon: Icon(Icons.corporate_fare_outlined, size: 20),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Organization name is required' : null,
                ),
                const SizedBox(height: 32),

                const _SectionLabel(
                  icon: Icons.account_balance_outlined,
                  title: 'Bank / Payment Details',
                  subtitle: 'Donors transfer funds to these details',
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.infoColor.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.infoColor.withValues(alpha: 0.2)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: AppTheme.infoColor),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'These details appear on campaign donation pages so donors can do manual bank transfers.',
                          style: TextStyle(fontSize: 12, color: AppTheme.infoColor),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _bankNameController,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Bank / Provider Name',
                    hintText: 'e.g. HBL, Easypaisa, JazzCash',
                    prefixIcon: Icon(Icons.account_balance_outlined, size: 20),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _accTitleController,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Account Title',
                    hintText: 'e.g. Flood Relief Foundation',
                    prefixIcon: Icon(Icons.badge_outlined, size: 20),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _accNumberController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'Account Number / Mobile',
                    hintText: 'e.g. 03001234567 or PK86HABB000...',
                    prefixIcon: Icon(Icons.dialpad_outlined, size: 20),
                  ),
                ),
                const SizedBox(height: 36),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: actionsState.isLoading ? null : _save,
                    icon: actionsState.isLoading
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.save_outlined),
                    label: Text(actionsState.isLoading ? 'Saving...' : 'Save Changes'),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildVerificationBanner(dynamic profile) {
    final isVerified = profile.status == 'VERIFIED';
    final color = isVerified ? AppTheme.successColor : AppTheme.warningColor;
    final icon = isVerified ? Icons.verified_outlined : Icons.pending_outlined;
    final text = isVerified
        ? 'Your organization is verified. You can create campaigns and withdraw funds.'
        : 'Verification pending. An admin will review your NGO registration.';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isVerified ? 'Verified NGO' : 'Pending Verification',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color),
                ),
                const SizedBox(height: 2),
                Text(text, style: TextStyle(fontSize: 11, color: color.withValues(alpha: 0.8))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SectionLabel({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: AppTheme.primaryColor),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            Text(subtitle, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
          ],
        ),
      ],
    );
  }
}
