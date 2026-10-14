import 'package:flutter/material.dart';

import '../../models/damage_report.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/status_badge.dart';
import 'report_status_screen.dart';

class ReportSuccessScreen extends StatelessWidget {
  const ReportSuccessScreen({super.key, required this.report});

  final DamageReport report;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final green = tintFor(context, AppColors.green);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.6, end: 1),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.elasticOut,
                  builder: (_, scale, child) => Transform.scale(scale: scale, child: child),
                  child: Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: green.withOpacity(0.14),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.check_circle, size: 72, color: green),
                  ),
                ),
                const SizedBox(height: 24),
                Text('Report Submitted Successfully',
                    style: text.headlineSmall, textAlign: TextAlign.center),
                const SizedBox(height: 10),
                Text(
                  'Your report has been sent to the municipality for assessment.',
                  style: text.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                AppCard(
                  child: Column(
                    children: [
                      Text('Report ID', style: text.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                      const SizedBox(height: 2),
                      SelectableText(report.id, style: text.titleLarge),
                      const SizedBox(height: 12),
                      StatusBadge(status: report.status),
                      const SizedBox(height: 8),
                      Text(
                        'Your report is unverified until a municipality administrator reviews it.',
                        style: text.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                CustomButton(
                  label: 'Back to Home',
                  icon: Icons.home,
                  onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
                ),
                const SizedBox(height: 10),
                CustomButton(
                  label: 'Track My Reports',
                  icon: Icons.list_alt,
                  kind: ButtonKind.outline,
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const ReportStatusScreen()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
