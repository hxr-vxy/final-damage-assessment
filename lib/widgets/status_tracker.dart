import 'package:flutter/material.dart';

import '../models/damage_report.dart';
import '../theme/app_theme.dart';

class _Step {
  const _Step(this.label, this.icon);
  final String label;
  final IconData icon;
}

/// Vertical progress tracker:
/// Submitted -> Under Review -> Accepted -> Worker Assigned -> In Progress -> Resolved
class StatusTracker extends StatelessWidget {
  const StatusTracker({super.key, required this.status});

  final ReportStatus status;

  static const _steps = [
    _Step('Submitted', Icons.pending_actions),
    _Step('Under Review', Icons.visibility),
    _Step('Accepted', Icons.check_circle_outline),
    _Step('Worker Assigned', Icons.engineering),
    _Step('In Progress', Icons.autorenew),
    _Step('Resolved', Icons.task_alt),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    if (status == ReportStatus.rejected) {
      final red = tintFor(context, AppColors.red);
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: red.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: red.withOpacity(0.4)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.cancel, color: red),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'This report was rejected after review. It may have been invalid, '
                'a duplicate, or missing important information.',
                style: text.bodyMedium,
              ),
            ),
          ],
        ),
      );
    }

    final current = status.step;
    final green = tintFor(context, AppColors.green);
    final active = cs.primary;

    return Column(
      children: [
        for (var i = 0; i < _steps.length; i++)
          _row(context, i, current, green, active, cs, text),
      ],
    );
  }

  Widget _row(BuildContext context, int i, int current, Color green,
      Color active, ColorScheme cs, TextTheme text) {
    final isLast = i == _steps.length - 1;
    final done = i < current || (status == ReportStatus.resolved && i == current);
    final isCurrent = i == current && status != ReportStatus.resolved;

    final circleColor = done ? green : (isCurrent ? active : cs.outlineVariant);
    var label = _steps[i].label;
    if (isCurrent && status == ReportStatus.actionRequired) {
      label = 'Accepted - action required';
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 30,
          child: Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done || isCurrent
                      ? circleColor
                      : Colors.transparent,
                  border: Border.all(color: circleColor, width: 2),
                ),
                child: Icon(
                  done ? Icons.check : _steps[i].icon,
                  size: 15,
                  color: done || isCurrent ? cs.surface : cs.outline,
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 22,
                  color: done ? green : cs.outlineVariant,
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            label,
            style: text.bodyMedium?.copyWith(
              fontWeight: isCurrent ? FontWeight.w500 : FontWeight.w400,
              color: done || isCurrent ? cs.onSurface : cs.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
