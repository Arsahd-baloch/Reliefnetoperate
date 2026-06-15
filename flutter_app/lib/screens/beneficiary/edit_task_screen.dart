import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:reliefnet_app/core/theme/app_theme.dart';
import 'package:reliefnet_app/features/tasks/domain/task_model.dart';
import 'package:reliefnet_app/providers/beneficiary_task_provider.dart';

class EditTaskScreen extends ConsumerStatefulWidget {
  final int taskId;

  const EditTaskScreen({super.key, required this.taskId});

  @override
  ConsumerState<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends ConsumerState<EditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  String? _category;
  TaskUrgency _urgency = TaskUrgency.medium;
  double? _latitude;
  double? _longitude;
  bool _initialized = false;
  bool _fetchingLocation = false;

  static const _categories = [
    ('FOOD', '🍞', 'Food & Water'),
    ('MEDICAL', '💊', 'Medical'),
    ('SHELTER', '🏠', 'Shelter'),
    ('CLOTHING', '👕', 'Clothing'),
    ('WATER', '💧', 'Water'),
    ('OTHER', '📦', 'Other'),
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _locationController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _initFields(TaskModel task) {
    if (_initialized) return;
    _titleController.text = task.title;
    _descriptionController.text = task.description ?? '';
    _locationController.text = task.locationText ?? '';
    _category = task.category;
    _urgency = task.urgency;
    _latitude = task.latitude;
    _longitude = task.longitude;
    _initialized = true;
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _fetchingLocation = true);
    HapticFeedback.lightImpact();
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          showDialog<void>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Location Permission'),
              content: const Text(
                  'Location permission is permanently denied. Enable it in app settings.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Geolocator.openAppSettings();
                  },
                  child: const Text('Open Settings'),
                ),
              ],
            ),
          );
        }
        setState(() => _fetchingLocation = false);
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
          locationSettings:
              const LocationSettings(accuracy: LocationAccuracy.high));
      setState(() {
        _latitude = pos.latitude;
        _longitude = pos.longitude;
        _fetchingLocation = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.location_on, color: Colors.white, size: 16),
                SizedBox(width: 8),
                Text('Location updated to current GPS'),
              ],
            ),
            backgroundColor: AppTheme.successColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() => _fetchingLocation = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not get location: $e'),
            backgroundColor: AppTheme.urgencyHigh,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.mediumImpact();

    final body = {
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'category': _category,
      'urgency': _urgency.value,
      'location_text': _locationController.text.trim(),
      if (_latitude != null) 'latitude': _latitude,
      if (_longitude != null) 'longitude': _longitude,
    };

    await ref.read(taskActionProvider.notifier).update(widget.taskId, body);

    if (mounted && !ref.read(taskActionProvider).hasError) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Request updated successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskAsync = ref.watch(beneficiaryTaskDetailProvider(widget.taskId));
    final actionState = ref.watch(taskActionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Request'),
        centerTitle: false,
      ),
      body: taskAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppTheme.textDisabled),
              const SizedBox(height: 12),
              Text('Could not load request: $err',
                  style: const TextStyle(color: AppTheme.textSecondary)),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () =>
                    ref.invalidate(beneficiaryTaskDetailProvider(widget.taskId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (task) {
          _initFields(task);

          if (task.status != TaskStatus.open) {
            return _LockedState(status: task.status);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Request Title',
                      hintText: 'e.g. Need medical supplies urgently',
                      prefixIcon: Icon(Icons.title_outlined),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Please enter a title'
                        : null,
                  ),
                  const SizedBox(height: 20),

                  // Category
                  const Text(
                    'Category',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _categories.map((c) {
                      final (value, emoji, label) = c;
                      final selected = _category == value;
                      return GestureDetector(
                        onTap: () => setState(() => _category = value),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppTheme.primaryColor
                                : AppTheme.cardColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: selected
                                  ? AppTheme.primaryColor
                                  : AppTheme.borderSubtle,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(emoji,
                                  style: const TextStyle(fontSize: 14)),
                              const SizedBox(width: 6),
                              Text(
                                label,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: selected
                                      ? Colors.white
                                      : AppTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Describe your needs in detail...',
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(bottom: 48),
                        child: Icon(Icons.notes_outlined),
                      ),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 4,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 20),

                  // Location
                  TextFormField(
                    controller: _locationController,
                    decoration: InputDecoration(
                      labelText: 'Location (Optional)',
                      hintText: 'Street, area, landmarks...',
                      prefixIcon: const Icon(Icons.location_on_outlined),
                      suffixIcon: _fetchingLocation
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2),
                              ),
                            )
                          : IconButton(
                              icon: const Icon(Icons.my_location),
                              tooltip: 'Use current GPS',
                              onPressed: _getCurrentLocation,
                            ),
                    ),
                  ),
                  if (_latitude != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.gps_fixed,
                            size: 13, color: AppTheme.successColor),
                        const SizedBox(width: 4),
                        Text(
                          'GPS: ${_latitude!.toStringAsFixed(4)}, ${_longitude!.toStringAsFixed(4)}',
                          style: const TextStyle(
                              fontSize: 11, color: AppTheme.successColor),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 24),

                  // Urgency
                  const Text(
                    'Urgency Level',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 10),
                  _UrgencySelector(
                    selected: _urgency,
                    onChanged: (u) => setState(() => _urgency = u),
                  ),
                  const SizedBox(height: 32),

                  // Submit
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: actionState.isLoading ? null : _submit,
                      child: actionState.isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2.5),
                            )
                          : const Text('Save Changes',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w700)),
                    ),
                  ),

                  if (actionState.hasError) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.urgencyHigh.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: AppTheme.urgencyHigh.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline,
                              color: AppTheme.urgencyHigh, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              actionState.error?.toString() ??
                                  'Failed to update request.',
                              style: const TextStyle(
                                  fontSize: 12, color: AppTheme.urgencyHigh),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Urgency Selector ──

class _UrgencySelector extends StatelessWidget {
  final TaskUrgency selected;
  final void Function(TaskUrgency) onChanged;

  const _UrgencySelector({required this.selected, required this.onChanged});

  static const _options = [
    (TaskUrgency.low, 'Low', Icons.arrow_downward, Color(0xFF22C55E)),
    (TaskUrgency.medium, 'Medium', Icons.remove, Color(0xFFF59E0B)),
    (TaskUrgency.high, 'High', Icons.arrow_upward, Color(0xFFEF4444)),
    (TaskUrgency.critical, 'Critical', Icons.priority_high, Color(0xFF7C3AED)),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _options.map((opt) {
        final (urgency, label, icon, color) = opt;
        final isSelected = selected == urgency;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onChanged(urgency);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withValues(alpha: 0.12)
                    : AppTheme.cardColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? color : AppTheme.borderSubtle,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(icon,
                      size: 16,
                      color: isSelected ? color : AppTheme.textDisabled),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? color : AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Locked State ──

class _LockedState extends StatelessWidget {
  final TaskStatus status;

  const _LockedState({required this.status});

  @override
  Widget build(BuildContext context) {
    final label = switch (status) {
      TaskStatus.claimed => 'A volunteer has claimed this request',
      TaskStatus.inProgress => 'This request is currently in progress',
      TaskStatus.submitted => 'Delivery proof has been submitted',
      TaskStatus.coordinatorVerified => 'This request has been verified',
      TaskStatus.paid => 'This request has been completed',
      TaskStatus.cancelled => 'This request has been cancelled',
      _ => 'This request can no longer be edited',
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.textDisabled.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_outline,
                  size: 40, color: AppTheme.textDisabled),
            ),
            const SizedBox(height: 20),
            const Text(
              'Cannot Edit Request',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 14, color: AppTheme.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
