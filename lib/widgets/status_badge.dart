import 'package:flutter/material.dart';

import '../models/damage_report.dart';
import '../theme/app_theme.dart';
import 'pill.dart';

/// Shows the current report status (icon + text + color).
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final ReportStatus status;

  @override
  Widget build(BuildContext context) =>
      Pill(label: status.label, icon: status.icon, color: status.color);
}

/// Distinguishes Pending / Unverified from Accepted / Verified reports.
/// Rejected reports show nothing here.
class VerificationBadge extends StatelessWidget {
  const VerificationBadge({super.key, required this.status});

  final ReportStatus status;

  @override
  Widget build(BuildContext context) {
    if (status == ReportStatus.rejected) return const SizedBox.shrink();
    if (status.isVerified) {
      return const Pill(
        label: 'Verified',
        icon: Icons.verified,
        color: AppColors.green,
      );
    }
    return const Pill(
      label: 'Unverified',
      icon: Icons.help_outline,
      color: AppColors.orangeDeep,
    );
  }
}
