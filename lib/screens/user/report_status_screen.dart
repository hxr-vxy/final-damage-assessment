import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/report_service.dart';
import '../../utils/formatters.dart';
import '../../widgets/app_card.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/damage_report_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/report_photo.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/status_tracker.dart';
import '../../widgets/urgency_badge.dart';
import 'report_damage_screen.dart';

/// Lets residents follow the status of reports submitted from this device.
class ReportStatusScreen extends StatelessWidget {
  const ReportStatusScreen({super.key});

  void _openDetails(BuildContext context, String reportId) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (ctx, controller) =>
            _UserReportSheet(reportId: reportId, controller: controller),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<ReportService>();
    final reports = service.myReports;

    return Scaffold(
      appBar: AppBar(title: const Text('My Reports')),
      body: reports.isEmpty
          ? EmptyState(
              icon: Icons.assignment_outlined,
              title: 'No reports yet',
              message: 'Reports you submit from this device will appear here so you can follow their status.',
              action: CustomButton(
                label: 'Report a Damage',
                icon: Icons.report_problem,
                expanded: false,
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const ReportDamageScreen()),
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: service.refresh,
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: reports.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (ctx, i) => DamageReportCard(
                  report: reports[i],
                  onTap: () => _openDetails(ctx, reports[i].id),
                ),
              ),
            ),
    );
  }
}

class _UserReportSheet extends StatelessWidget {
  const _UserReportSheet({required this.reportId, required this.controller});

  final String reportId;
  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    final report = context.watch<ReportService>().byId(reportId);
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    if (report == null) {
      return const EmptyState(
        icon: Icons.delete_outline,
        title: 'Report removed',
        message: 'This report is no longer available.',
      );
    }

    Widget row(String label, String value) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 104,
                child: Text(label,
                    style: text.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
              ),
              Expanded(child: Text(value, style: text.bodyMedium)),
            ],
          ),
        );

    return ListView(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        Text(report.damageTitle, style: text.titleLarge),
        Text(report.id, style: text.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
        const SizedBox(height: 12),
        ReportPhoto(report: report, height: 200),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            StatusBadge(status: report.status),
            VerificationBadge(status: report.status),
            UrgencyBadge(urgency: report.urgency),
          ],
        ),
        const SizedBox(height: 16),
        Text('Progress', style: text.titleMedium),
        const SizedBox(height: 10),
        AppCard(child: StatusTracker(status: report.status)),
        if (report.assignedTeam != null) ...[
          const SizedBox(height: 12),
          AppCard(
            child: Row(
              children: [
                Icon(Icons.engineering, color: cs.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Assigned to ${report.assignedTeam}', style: text.bodyMedium),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        Text('Details', style: text.titleMedium),
        const SizedBox(height: 10),
        AppCard(
          child: Column(
            children: [
              row('Submitted', formatDateTime(report.dateSubmitted)),
              row('Barangay', report.barangay),
              row('Purok', report.purok),
              row('Location', report.specificLocation),
              row('Description', report.description),
            ],
          ),
        ),
      ],
    );
  }
}
