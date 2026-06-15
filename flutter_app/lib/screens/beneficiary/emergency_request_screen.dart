import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:reliefnet_app/core/theme/app_theme.dart';
import 'package:reliefnet_app/features/auth/presentation/auth_provider.dart';
import 'package:reliefnet_app/providers/beneficiary_task_provider.dart';

enum _LocationStatus { idle, requesting, granted, denied, deniedForever, error }

class EmergencyRequestScreen extends ConsumerStatefulWidget {
  const EmergencyRequestScreen({super.key});

  @override
  ConsumerState<EmergencyRequestScreen> createState() =>
      _EmergencyRequestScreenState();
}

class _EmergencyRequestScreenState
    extends ConsumerState<EmergencyRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  String _category = 'FOOD';
  double? _latitude;
  double? _longitude;
  _LocationStatus _locationStatus = _LocationStatus.idle;

  @override
  void initState() {
    super.initState();
    _requestLocation();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _requestLocation() async {
    setState(() => _locationStatus = _LocationStatus.requesting);
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() => _locationStatus = _LocationStatus.deniedForever);
        return;
      }
      if (permission == LocationPermission.denied) {
        setState(() => _locationStatus = _LocationStatus.denied);
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      );
      setState(() {
        _latitude = pos.latitude;
        _longitude = pos.longitude;
        _locationStatus = _LocationStatus.granted;
      });
    } catch (_) {
      setState(() => _locationStatus = _LocationStatus.error);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.heavyImpact();

    final userId = ref.read(authProvider).user?.id;
    if (userId == null) return;

    // Use default Pakistan center coords if location not available
    final lat = _latitude ?? 30.3753;
    final lng = _longitude ?? 69.3451;

    final body = {
      'title': '🚨 EMERGENCY: $_category Request',
      'description': _descriptionController.text.trim(),
      'category': _category,
      'urgency': 'CRITICAL',
      'source_type': 'BENEFICIARY_REQUEST',
      'is_emergency': true,
      'latitude': lat,
      'longitude': lng,
      'location_text': _locationStatus == _LocationStatus.granted
          ? '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}'
          : 'Location unavailable — coordinates estimated',
      'family_size': 1,
      'items_needed': [],
      'budget_pkr': 0,
    };

    await ref.read(createTaskProvider.notifier).submit(
          userId: userId,
          body: body,
        );

    if (mounted &&
        ref.read(createTaskProvider).status == CreateTaskStatus.success) {
      if (!context.mounted) return;
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Emergency alert broadcasted to nearby volunteers!'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createTaskProvider);
    final isLoading = state.status == CreateTaskStatus.loading;

    return Scaffold(
      backgroundColor: Colors.red.shade50,
      appBar: AppBar(
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        title: const Text('Emergency Request'),
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Top warning banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red.shade700, Colors.red.shade900],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.sos_outlined, color: Colors.white, size: 32),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Emergency Broadcast',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Nearby volunteers will be alerted immediately.',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Location status card
                    _LocationStatusCard(
                      status: _locationStatus,
                      latitude: _latitude,
                      longitude: _longitude,
                      onRetry: _requestLocation,
                      onOpenSettings: () async {
                        await Geolocator.openAppSettings();
                      },
                    ),
                    const SizedBox(height: 24),

                    // Category selector
                    const Text(
                      'What do you need urgently?',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _CategoryGrid(
                      selected: _category,
                      onSelected: (cat) {
                        HapticFeedback.lightImpact();
                        setState(() => _category = cat);
                      },
                    ),
                    const SizedBox(height: 24),

                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Describe the emergency *',
                        hintText:
                            'e.g. Trapped in flooded house, need rescue...',
                        prefixIcon:
                            Icon(Icons.description_outlined, size: 20),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 4,
                      textCapitalization: TextCapitalization.sentences,
                      validator: (v) => v == null || v.trim().length < 5
                          ? 'Please describe the emergency (min 5 chars)'
                          : null,
                    ),
                    const SizedBox(height: 12),

                    // Warning note
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.amber.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline,
                              size: 16, color: Colors.amber.shade800),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Only use for genuine emergencies. Misuse may block your account.',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.amber.shade900),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),

          // Sticky submit bar
          Container(
            padding: EdgeInsets.fromLTRB(
                20, 12, 20, 12 + MediaQuery.of(context).padding.bottom),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                onPressed: isLoading ? null : _submit,
                child: isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.white),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.sos_outlined, size: 22),
                          SizedBox(width: 8),
                          Text(
                            'SEND EMERGENCY ALERT',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationStatusCard extends StatelessWidget {
  final _LocationStatus status;
  final double? latitude;
  final double? longitude;
  final VoidCallback onRetry;
  final VoidCallback onOpenSettings;

  const _LocationStatusCard({
    required this.status,
    required this.latitude,
    required this.longitude,
    required this.onRetry,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    final (color, icon, title, subtitle, action) = switch (status) {
      _LocationStatus.idle || _LocationStatus.requesting => (
          Colors.blue,
          Icons.my_location,
          'Detecting Location...',
          'Pinpointing your GPS coordinates for responders.',
          null
        ),
      _LocationStatus.granted => (
          Colors.green,
          Icons.location_on,
          'Location Detected',
          '${latitude?.toStringAsFixed(4)}, ${longitude?.toStringAsFixed(4)}',
          null
        ),
      _LocationStatus.denied => (
          Colors.orange,
          Icons.location_off,
          'Location Denied',
          'Location helps volunteers find you faster.',
          ('Retry', onRetry)
        ),
      _LocationStatus.deniedForever => (
          Colors.red,
          Icons.location_disabled,
          'Location Blocked',
          'Enable location in Settings for faster response.',
          ('Open Settings', onOpenSettings)
        ),
      _LocationStatus.error => (
          Colors.orange,
          Icons.signal_wifi_off,
          'Location Unavailable',
          'Could not get GPS. Submit anyway — default coordinates used.',
          ('Retry', onRetry)
        ),
    };

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          status == _LocationStatus.requesting
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5, color: color),
                )
              : Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: color)),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 11,
                        color: color.withValues(alpha: 0.8))),
              ],
            ),
          ),
          if (action != null) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: action.$2,
              style: TextButton.styleFrom(foregroundColor: color),
              child: Text(action.$1,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700)),
            ),
          ],
        ],
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;

  const _CategoryGrid(
      {required this.selected, required this.onSelected});

  static const _cats = [
    ('FOOD', 'Food', Icons.lunch_dining_outlined, Color(0xFFF59E0B)),
    ('MEDICAL', 'Medical', Icons.medical_services_outlined, Color(0xFFF43F5E)),
    ('SHELTER', 'Shelter', Icons.home_outlined, Color(0xFF3B82F6)),
    ('RESCUE', 'Rescue', Icons.sos_outlined, Color(0xFFF97316)),
    ('WATER', 'Water', Icons.water_drop_outlined, Color(0xFF06B6D4)),
    ('OTHER', 'Other', Icons.help_outline, AppTheme.primaryColor),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.1,
      children: _cats.map((cat) {
        final isSelected = selected == cat.$1;
        final color = cat.$4;
        return GestureDetector(
          onTap: () => onSelected(cat.$1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: isSelected ? color.withValues(alpha: 0.12) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? color : Colors.grey.shade200,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                          color: color.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2))
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(cat.$3,
                    size: 26, color: isSelected ? color : Colors.grey.shade500),
                const SizedBox(height: 6),
                Text(
                  cat.$2,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                    color: isSelected ? color : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
