import 'package:reliefnet_app/core/theme/app_theme.dart';
import 'package:reliefnet_app/features/tasks/domain/task_model.dart';
import 'package:flutter/material.dart';

class StatusChip extends StatelessWidget {
  final TaskStatus status;
  final double fontSize;

  const StatusChip({super.key, required this.status, this.fontSize = 11});

  Color get _color {
    switch (status) {
      case TaskStatus.open:
      case TaskStatus.pending:
        return AppTheme.statusPending;
      case TaskStatus.assigned:
      case TaskStatus.claimed:
        return AppTheme.statusAction;
      case TaskStatus.inProgress:
        return AppTheme.statusInProgress;
      case TaskStatus.submitted:
        return AppTheme.infoColor;
      case TaskStatus.coordinatorVerified:
      case TaskStatus.paid:
      case TaskStatus.completed:
      case TaskStatus.active:
      case TaskStatus.confirmed:
      case TaskStatus.approved:
        return AppTheme.statusActive;
      case TaskStatus.flagged:
      case TaskStatus.failed:
      case TaskStatus.refunded:
      case TaskStatus.rejected:
        return AppTheme.statusFailed;
      case TaskStatus.cancelled:
      case TaskStatus.draft:
      default:
        return AppTheme.statusNeutral;
    }
  }

  String get _label {
    switch (status) {
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.coordinatorVerified:
        return 'Verified';
      case TaskStatus.pending:
        return 'Pending';
      default:
        return status.value
            .replaceAll('_', ' ')
            .split(' ')
            .map((w) => w.isEmpty
                ? w
                : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
            .join(' ');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _color.withValues(alpha: 0.4)),
      ),
      child: Text(
        _label,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: _color,
        ),
      ),
    );
  }
}
