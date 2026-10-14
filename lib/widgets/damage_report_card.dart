import 'package:flutter/material.dart';

import '../models/damage_report.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'app_card.dart';
import 'icon_badge.dart';
import 'report_photo.dart';
import 'status_badge.dart';
import 'urgency_badge.dart';

/// Card used in both the admin report list and the resident "My Reports" list.
class DamageReportCard extends StatelessWidget {
  const DamageReportCard({
    super.key,
    required this.report,
    required this.onTap,
    this.compact = false,
  });

  final DamageReport report;
  final VoidCallback onTap;

  /// Compact hides the "View Report" button (the whole card is still tappable).
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final muted = text.bodyMedium?.copyWith(color: cs.onSurfaceVariant);
    final strong = text.bodyMedium?.copyWith(fontWeight: FontWeight.w500);

    final accent = report.status.isClosed
        ? cs.outlineVariant
        : tintFor(context, report.urgency.color);

    Widget line(String label, String value, {int maxLines = 1}) => Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Text.rich(
            TextSpan(children: [
              TextSpan(text: '$label: ', style: muted),
              TextSpan(text: value, style: strong),
            ]),
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          ),
        );

    return AppCard(
      accentColor: accent,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ReportThumbnail(report: report, size: 56),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.damageTitle.toUpperCase(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: text.titleSmall?.copyWith(letterSpacing: 0.5),
                    ),
                    Text(report.id, style: text.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
              if (report.isUrgentActive)
                Tooltip(
                  message: 'Priority report',
                  child: Icon(Icons.priority_high, color: tintFor(context, AppColors.red)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          line('Barangay', report.barangay),
          line('Purok', report.purok),
          line('Location', report.specificLocation, maxLines: 2),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              UrgencyBadge(urgency: report.urgency),
              StatusBadge(status: report.status),
              VerificationBadge(status: report.status),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: cs.onSurfaceVariant),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Submitted: ${formatDateTime(report.dateSubmitted)}',
                  style: text.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (!compact)
                TextButton.icon(
                  onPressed: onTap,
                  icon: const Icon(Icons.arrow_forward, size: 18),
                  label: const Text('View Report'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
