import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/damage_report.dart';
import '../../models/worker.dart';
import '../../services/report_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/app_card.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/form_helpers.dart';
import '../../widgets/report_photo.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/status_tracker.dart';
import '../../widgets/urgency_badge.dart';
import 'photo_viewer_screen.dart';

/// Full report view with admin actions (accept, reject, delete,
/// assign team, update status).
class ReportDetailsScreen extends StatelessWidget {
  const ReportDetailsScreen({super.key, required this.reportId});

  final String reportId;

  @override
  Widget build(BuildContext context) {
    final service = context.watch<ReportService>();
    final report = service.byId(reportId);

    if (report == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Report')),
        body: const EmptyState(
          icon: Icons.delete_outline,
          title: 'Report not found',
          message: 'This report may have been deleted.',
        ),
      );
    }

    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text('Report ${report.id}')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ---- Photo -------------------------------------------------------------
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PhotoViewerScreen(report: report)),
              ),
              child: Stack(
                children: [
                  ReportPhoto(report: report, height: 280),
                  Positioned(
                    right: 10,
                    bottom: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.zoom_out_map, size: 16, color: Colors.white),
                          SizedBox(width: 6),
                          Text('Tap to enlarge',
                              style: TextStyle(color: Colors.white, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Text(report.damageTitle, style: text.titleLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                StatusBadge(status: report.status),
                VerificationBadge(status: report.status),
                UrgencyBadge(urgency: report.urgency),
              ],
            ),
            if (report.status.isPending) ...[
              const SizedBox(height: 12),
              _Notice(
                icon: Icons.info,
                color: AppColors.orangeDeep,
                message:
                    'This report is unverified. Review the photo and details before accepting.',
              ),
            ],
            const SizedBox(height: 16),

            // ---- Actions -----------------------------------------------------------
            _ActionsSection(report: report),
            const SizedBox(height: 20),

            // ---- Details -----------------------------------------------------------
            Text('Report details', style: text.titleMedium),
            const SizedBox(height: 8),
            AppCard(
              child: Column(
                children: [
                  _InfoRow('Report ID', report.id),
                  _InfoRow('Date submitted',
                      formatDateTime(report.dateSubmitted)),
                  _InfoRow('Barangay', report.barangay),
                  _InfoRow('Purok', report.purokLabel),
                  _InfoRow('Location', report.specificLocation),
                  _InfoRow('Damage type', report.damageTitle),
                  _InfoRow('Urgency', report.urgency.label),
                  _InfoRow('Status', report.status.label),
                  _InfoRow('Assigned team',
                      report.assignedTeam ?? 'Not assigned yet'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text('Description', style: text.titleMedium),
            const SizedBox(height: 8),
            AppCard(child: Text(report.description, style: text.bodyLarge)),
            const SizedBox(height: 16),
            Text('Reporter', style: text.titleMedium),
            const SizedBox(height: 8),
            AppCard(
              child: report.hasReporterInfo
                  ? Column(
                      children: [
                        _InfoRow('Name',
                            report.reporterName ?? 'Not provided'),
                        _InfoRow('Contact',
                            report.contactNumber ?? 'Not provided'),
                      ],
                    )
                  : Text('The reporter did not provide contact information.',
                      style: text.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
            ),
            const SizedBox(height: 16),
            Text('Progress', style: text.titleMedium),
            const SizedBox(height: 8),
            AppCard(child: StatusTracker(status: report.status)),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 112,
            child: Text(label,
                style: text.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
          ),
          Expanded(
            child: Text(value, style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.icon, required this.color, required this.message});

  final IconData icon;
  final Color color;
  final String message;

  @override
  Widget build(BuildContext context) {
    final c = tintFor(context, color);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.withOpacity(0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: c, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(message, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

/// Buttons that change depending on where the report is in the workflow.
class _ActionsSection extends StatelessWidget {
  const _ActionsSection({required this.report});

  final DamageReport report;

  Future<void> _accept(BuildContext context) async {
    await context.read<ReportService>().acceptReport(report.id);
    if (context.mounted) {
      showFeedback(context, 'Report accepted. It is now marked as verified.');
    }
  }

  Future<void> _markUnderReview(BuildContext context, {bool reopen = false}) async {
    await context.read<ReportService>().updateStatus(report.id, ReportStatus.underReview);
    if (context.mounted) {
      showFeedback(context, reopen ? 'Report reopened for review.' : 'Status updated: Under Review');
    }
  }

  Future<void> _reject(BuildContext context) async {
    final ok = await showConfirmDialog(
      context,
      title: 'Reject this report?',
      message:
          'It will be marked as rejected and kept in your records. Use this for fake, duplicate, or unreliable reports.',
      confirmLabel: 'Reject',
      icon: Icons.cancel,
      destructive: true,
    );
    if (!ok || !context.mounted) return;
    await context.read<ReportService>().rejectReport(report.id);
    if (context.mounted) showFeedback(context, 'Report rejected.', icon: Icons.cancel);
  }

  Future<void> _delete(BuildContext context) async {
    final ok = await showConfirmDialog(
      context,
      title: 'Delete this report?',
      message: 'This report will be removed from the active reports.',
      confirmLabel: 'Delete',
      icon: Icons.delete_outline,
      destructive: true,
    );
    if (!ok || !context.mounted) return;

    final service = context.read<ReportService>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    await service.deleteReport(report.id);
    navigator.pop();
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Report deleted.')));
  }

  Future<void> _assign(BuildContext context) async {
    final worker = await showModalBottomSheet<Worker>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text('Assign a team', style: Theme.of(ctx).textTheme.titleLarge),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final w in Worker.all)
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            Theme.of(ctx).colorScheme.primary.withOpacity(0.12),
                        child: Icon(w.icon, color: Theme.of(ctx).colorScheme.primary),
                      ),
                      title: Text(w.name),
                      subtitle: Text(w.description),
                      trailing: report.assignedTeam == w.name
                          ? const Icon(Icons.check_circle)
                          : null,
                      onTap: () => Navigator.pop(ctx, w),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    if (worker == null || !context.mounted) return;
    await context.read<ReportService>().assignTeam(report.id, worker.name);
    if (context.mounted) {
      showFeedback(context, 'Worker assigned: ${worker.name}', icon: Icons.engineering);
    }
  }

  Future<void> _updateStatus(BuildContext context) async {
    const options = [
      ReportStatus.underReview,
      ReportStatus.accepted,
      ReportStatus.actionRequired,
      ReportStatus.workerAssigned,
      ReportStatus.inProgress,
      ReportStatus.resolved,
    ];
    final picked = await showModalBottomSheet<ReportStatus>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text('Update status', style: Theme.of(ctx).textTheme.titleLarge),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final s in options)
                    ListTile(
                      leading: Icon(s.icon, color: tintFor(ctx, s.color)),
                      title: Text(s.label),
                      trailing: report.status == s ? const Icon(Icons.check) : null,
                      onTap: () => Navigator.pop(ctx, s),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    if (picked == null || picked == report.status || !context.mounted) return;

    final needsTeam = picked == ReportStatus.workerAssigned ||
        picked == ReportStatus.inProgress ||
        picked == ReportStatus.resolved;
    if (needsTeam && report.assignedTeam == null) {
      showFeedback(context, 'Assign a team first before setting this status.',
          isError: true, icon: Icons.engineering);
      return;
    }
    await context.read<ReportService>().updateStatus(report.id, picked);
    if (context.mounted) showFeedback(context, 'Status updated: ${picked.label}');
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final status = report.status;
    final buttons = <Widget>[];

    if (status.isPending) {
      buttons.add(CustomButton(
        label: 'Accept Report',
        icon: Icons.check_circle,
        kind: ButtonKind.success,
        onPressed: () => _accept(context),
      ));
      if (status == ReportStatus.submitted) {
        buttons.add(CustomButton(
          label: 'Mark as Under Review',
          icon: Icons.visibility,
          kind: ButtonKind.outline,
          onPressed: () => _markUnderReview(context),
        ));
      }
      buttons.add(CustomButton(
        label: 'Reject Report',
        icon: Icons.cancel,
        kind: ButtonKind.dangerOutline,
        onPressed: () => _reject(context),
      ));
    } else if (status.isVerified) {
      buttons.add(CustomButton(
        label: report.assignedTeam == null ? 'Assign Team' : 'Change Assigned Team',
        icon: Icons.person_add,
        onPressed: () => _assign(context),
      ));
      buttons.add(CustomButton(
        label: 'Update Status',
        icon: Icons.autorenew,
        kind: ButtonKind.outline,
        onPressed: () => _updateStatus(context),
      ));
    } else {
      // Rejected
      buttons.add(CustomButton(
        label: 'Reopen for Review',
        icon: Icons.undo,
        kind: ButtonKind.outline,
        onPressed: () => _markUnderReview(context, reopen: true),
      ));
    }

    buttons.add(CustomButton(
      label: 'Delete Report',
      icon: Icons.delete_outline,
      kind: ButtonKind.dangerOutline,
      onPressed: () => _delete(context),
    ));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Actions', style: text.titleMedium),
        const SizedBox(height: 10),
        for (var i = 0; i < buttons.length; i++) ...[
          buttons[i],
          if (i != buttons.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}
